// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:taxitaxi_driver/helpers/constants.dart';
import 'package:taxitaxi_driver/helpers/custom_dialog.dart';
import 'package:taxitaxi_driver/helpers/style.dart';
import 'package:taxitaxi_driver/models/ride_request.dart';
import 'package:taxitaxi_driver/models/rider.dart';
import 'package:taxitaxi_driver/models/route.dart';
import 'package:taxitaxi_driver/services/map_requests.dart';
import 'package:taxitaxi_driver/services/ride_request.dart';
import 'package:taxitaxi_driver/services/rider.dart';
import 'package:taxitaxi_driver/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';

import '../services/push_notifications.dart';
import '../widgets/cab_button.dart';
import '../widgets/cab_text.dart';

enum Show { base, rider, trip }

class AppStateProvider with ChangeNotifier {
  static const accepted = 'accepted';
  static const cancelled = 'rejected';
  static const pending = 'pending';
  static const expired = 'expired';
  static const arrived = 'arrived';
  static const started = 'started';
  static const completed = 'completed';
  // ANCHOR: VARIABLES DEFINITION
  Set<Marker> _markers = {};
  Set<Polyline> _poly = {};
  final GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  late GoogleMapController _mapController;
  Position? position;
  static LatLng? _center;
  LatLng? _lastPosition = _center;
  final TextEditingController _locationController = TextEditingController();

  LatLng? get center => _center;
  LatLng? get lastPosition => _lastPosition;
  TextEditingController get locationController => _locationController;
  Set<Marker> get markers => _markers;
  Set<Polyline> get poly => _poly;
  GoogleMapController get mapController => _mapController;
  RouteModel? routeModel;
  String pickupString = "";
  String get getPickupString => pickupString;
  //Location location = Location();
  bool hasNewRideRequest = false;
  final UserServices _userServices = UserServices();
  late RideRequestModel rideRequestModel;
  // RequestModelFirebase? requestModelFirebase;
  Position? myCurrentPosition;
  RiderModel? riderModel;
  final RiderServices _riderServices = RiderServices();
  double distanceFromRider = 0;
  double totalRideDistance = 0;
  late StreamSubscription<QuerySnapshot> requestStream;
  int timeCounter = 0;
  double percentage = 0;
  late Timer periodicTimer;
  final RideRequestServices _requestServices = RideRequestServices();
  Show show = Show.base;
  SharedPreferences? prefs;
  AppStateProvider() {
//    _subscribeUser();
    _saveDeviceToken();

//     fcm.configure(
// //      this callback is used when the app runs on the foreground
//         onMessage: handleOnMessage,
// //        used when the app is closed completely and is launched using the notification
//         onLaunch: handleOnLaunch,
// //        when its on the background and opened using the notification drawer
//         onResume: handleOnResume);
    _getUserLocation();
    Geolocator.getPositionStream().listen(_userCurrentLocationUpdate);
  }

  // ANCHOR LOCATION METHODS
  _userCurrentLocationUpdate(Position updatedPosition) async {
    myCurrentPosition = updatedPosition;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double distance = Geolocator.distanceBetween(
        prefs.getDouble('lat') ?? 0,
        prefs.getDouble('lng') ?? 0,
        updatedPosition.latitude,
        updatedPosition.longitude);
    Map<String, dynamic> values = {
      "id": prefs.getString(authPref),
      "position": updatedPosition.toJson()
    };
    if (distance >= 50) {
      if (show == Show.rider) {
        sendRequest(coordinates: rideRequestModel.getPickupCoordinates());
      }
      if (show == Show.trip) {
        _requestServices.updateRequest(
            {"id": rideRequestModel.id, "position": updatedPosition.toJson()});
      }
      _userServices.updateUserData(values);
      await prefs.setDouble('lat', updatedPosition.latitude);
      await prefs.setDouble('lng', updatedPosition.longitude);
      _mapController.animateCamera(CameraUpdate.newLatLng(
          LatLng(updatedPosition.latitude, updatedPosition.longitude)));
    }
  }

  _getUserLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    position = await Geolocator.getCurrentPosition();
    List<Placemark> placemark =
        await placemarkFromCoordinates(position!.latitude, position!.longitude);
    _center = LatLng(position!.latitude, position!.longitude);
    await prefs.setDouble('lat', position!.latitude);
    await prefs.setDouble('lng', position!.longitude);
    _locationController.text = placemark[0].name ?? "";
    notifyListeners();
  }

  // ANCHOR MAPS METHODS

  onCreate(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  setLastPosition(LatLng position) {
    _lastPosition = position;
    notifyListeners();
  }

  onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
    notifyListeners();
  }

  void sendRequest({required LatLng coordinates}) async {
    LatLng origin =
        LatLng(myCurrentPosition!.latitude, myCurrentPosition!.longitude);

    LatLng destination = coordinates;
    RouteModel route =
        await _googleMapsServices.getRouteByCoordinates(origin, destination);
    routeModel = route;
    addLocationMarker(
        destination, routeModel!.endAddress, routeModel!.distance.text);
    _center = destination;
    pickupString = routeModel!.endAddress;

    _createRoute(route.points);
    notifyListeners();
  }

  void _createRoute(String decodeRoute) {
    _poly = {};
    var uuid = const Uuid();
    String polyId = uuid.v1();
    poly.add(Polyline(
        polylineId: PolylineId(polyId),
        width: 3,
        color: primaryColor,
        onTap: () {},
        points: _convertToLatLong(_decodePoly(decodeRoute))));
    notifyListeners();
  }

  List<LatLng> _convertToLatLong(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = [];
    int index = 0;
    int len = poly.length;
    int c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

/*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) {
      lList[i] += lList[i - 2];
    }

    return lList;
  }

  // ANCHOR MARKERS
  addLocationMarker(LatLng position, String destination, [String? distance]) {
    _markers = {};
    var uuid = const Uuid();
    String markerId = uuid.v1();
    _markers.add(Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(title: destination, snippet: distance),
        icon: BitmapDescriptor.defaultMarker));
    notifyListeners();
  }

  Future<Uint8List> getMarker(BuildContext context) async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/car.png");
    return byteData.buffer.asUint8List();
  }

  clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  _saveDeviceToken() async {
    prefs = await SharedPreferences.getInstance();

    if (prefs!.getString('token') == null) {
      String? deviceToken = await fcm.getToken();
      await prefs!.setString('token', deviceToken ?? "");
    }

    notifyListeners();
  }

// ANCHOR PUSH NOTIFICATION METHODS
  // Future handleOnMessage(Map<String, dynamic> data) async {
  //   _handleNotificationData(data);
  // }

  // Future handleOnLaunch(Map<String, dynamic> data) async {
  //   _handleNotificationData(data);
  // }

  // Future handleOnResume(Map<String, dynamic> data) async {
  //   _handleNotificationData(data);
  // }

  handleNotificationData(Map<String, dynamic> data) async {
    hasNewRideRequest = true;
    rideRequestModel = RideRequestModel.fromMap(data);
    prefs!.setString(requestIdPref, rideRequestModel.id);
    riderModel = await _riderServices.getRiderById(rideRequestModel.userId);
    notifyListeners();
  }

// ANCHOR RIDE REQUEST METHODS
  changeRideRequestStatus() {
    hasNewRideRequest = false;
    notifyListeners();
  }

  Future listenToRequest(
      {required String id, required BuildContext context}) async {
//    requestModelFirebase = await _requestServices.getRequestById(id);

    requestStream =
        _requestServices.requestStream().listen((querySnapshot) async {
      for (var doc in querySnapshot.docChanges) {
        Map docData = doc.doc.data() as Map;
        if (docData['id'] == id) {
          rideRequestModel = RideRequestModel.fromMap(doc.doc.data() as Map);

          riderModel ??=
              await _riderServices.getRiderById(rideRequestModel.userId);
          prefs!.setString(requestIdPref, rideRequestModel.id);
          notifyListeners();
          switch (docData['status']) {
            case cancelled:
              showCustomDialog(
                  context,
                  230,
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.remove_circle_outline,
                            color: Colors.red, size: 60),
                        const CabText(
                          "This booking has been cancelled.",
                          color: black,
                          align: TextAlign.center,
                        ),
                        CabButton(
                            height: 40,
                            width: 180,
                            text: "Back to Home",
                            func: () async {
                              cancelRequest(requestId: rideRequestModel.id);
                              Navigator.of(context).pop();
                            },
                            isLoading: false)
                      ],
                    ),
                  ));
              break;
            case accepted:
            case arrived:
              changeWidgetShowed(showWidget: Show.rider);
              sendRequest(coordinates: rideRequestModel.getPickupCoordinates());
              break;
            case expired:
              break;
            case started:
              changeWidgetShowed(showWidget: Show.trip);
              sendRequest(
                  coordinates: rideRequestModel.getDestinationCoordinates());
              startedRide(docData);

              break;
            case completed:
              completeRequest(
                requestId: rideRequestModel.id,
                title: "Ride Completed",
                body:
                    "Please pay ${rideRequestModel.price} & Share your feedback.",
                deviceToken: riderModel!.token,
              );
              break;
            default:
              break;
          }
        }
      }
    });
  }

  startedRide(Map docData) async {
    var org =
        LatLng(myCurrentPosition!.latitude, docData["position"]["longitude"]);
    var dest = LatLng(docData["destination"]["latitude"],
        docData["destination"]["longitude"]);
    RouteModel route =
        await _googleMapsServices.getRouteByCoordinates(org, dest);
    routeModel = route;
    addLocationMarker(dest, routeModel!.distance.text);
    _center = dest;

    _createRoute(route.points);
  }

  //  Timer counter for driver request
  percentageCounter(
      {required String requestId, required BuildContext context}) {
    notifyListeners();
    periodicTimer = Timer.periodic(const Duration(seconds: 1), (time) {
      timeCounter = timeCounter + 1;
      percentage = timeCounter / 100;

      if (timeCounter == 100) {
        timeCounter = 0;
        percentage = 0;
        time.cancel();
        hasNewRideRequest = false;
        requestStream.cancel();
      }
      notifyListeners();
    });
  }

  acceptRequest(
      {required String requestId,
      required String driverId,
      required String deviceToken,
      required String title,
      required String body}) {
    hasNewRideRequest = false;
    _userServices.updateUserData({"online": false});
    _requestServices.updateRequest(
        {"id": requestId, "status": "accepted", "driverId": driverId});
    PushNotificationServices.sendNotification(
        deviceToken: deviceToken, title: title, body: body);
    notifyListeners();
  }

  startRequest(
      {required String requestId,
      required String deviceToken,
      required String title,
      required String body}) {
    hasNewRideRequest = false;
    _requestServices.updateRequest({"id": requestId, "status": "started"});
    PushNotificationServices.sendNotification(
        deviceToken: deviceToken, title: title, body: body);
    notifyListeners();
  }

  cancelRequest({required String requestId, bool? isReject}) {
    hasNewRideRequest = false;
    clearMarkers();
    requestStream.cancel();
    _poly = {};
    changeWidgetShowed(showWidget: Show.base);

    if (isReject ?? false) {
      _requestServices.updateRequest({
        "id": requestId,
        "rejectedDrivers":
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
      });
    } else {
      _requestServices.updateRequest({"id": requestId, "status": "cancelled"});
    }

    notifyListeners();
  }

  completeRequest(
      {required String requestId,
      required String deviceToken,
      required String title,
      required String body}) async {
    clearMarkers();
    _poly = {};
    requestStream.cancel();
    hasNewRideRequest = false;
    changeWidgetShowed(showWidget: Show.base);
    _userServices.updateUserData({"online": true});
    _requestServices.updateRequest({"id": requestId, "status": "completed"});
    PushNotificationServices.sendNotification(
        deviceToken: deviceToken, title: title, body: body);
    notifyListeners();
  }

  //  ANCHOR UI METHODS
  changeWidgetShowed({required Show showWidget}) {
    show = showWidget;
    notifyListeners();
  }
}
