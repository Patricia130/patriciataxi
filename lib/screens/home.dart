import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxitaxi_driver/helpers/constants.dart';
import 'package:taxitaxi_driver/helpers/screen_navigation.dart';
import 'package:taxitaxi_driver/helpers/style.dart';
import 'package:taxitaxi_driver/providers/app_provider.dart';
import 'package:taxitaxi_driver/providers/user.dart';
import 'package:taxitaxi_driver/screens/login.dart';
import 'package:taxitaxi_driver/screens/profile.dart';
import 'package:taxitaxi_driver/screens/ride_request.dart';
import 'package:taxitaxi_driver/services/user.dart';
import 'package:taxitaxi_driver/widgets/custom_text.dart';
import 'package:taxitaxi_driver/widgets/loading.dart';
import 'package:taxitaxi_driver/widgets/rider_draggable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import "package:google_maps_webservice/places.dart";
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/cab_text.dart';
import '../widgets/trip_draggable.dart';
import 'history_screen.dart';

GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: googleMapsAPIKey);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  var scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _deviceToken();
    _updatePosition();
  }

  _deviceToken() async {
    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isActive = user.userModel?.online ?? true;
    if (user.userModel!.token != prefs.getString('token')) {
      user.saveDeviceToken();
    }

    setState(() {});
  }

  _updatePosition() async {
    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    AppStateProvider app =
        Provider.of<AppStateProvider>(context, listen: false);
    //    this section down here will update the drivers current position on the DB when the app is opened
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString(authPref) ?? "";
    Geolocator.getPositionStream().listen(
        (value) => user.updateUserData({"id": id, "position": value.toJson()}));
    if (prefs.getString(requestIdPref) != null &&
        prefs.getString(requestIdPref)!.isNotEmpty) {
      await app.listenToRequest(
          id: prefs.getString(requestIdPref)!, context: context);

      // if (showPrefValue == "trip") {
      //   app.changeWidgetShowed(showWidget: Show.trip);
      //   app.sendRequest(
      //       coordinates: app.rideRequestModel.getDestinationCoordinates());
      // } else if (showPrefValue == "rider") {
      //   app.changeWidgetShowed(showWidget: Show.rider);
      //   app.sendRequest(
      //       coordinates: app.rideRequestModel.getPickupCoordinates());
      // }
    }
  }

  bool isActive = false;
  @override
  Widget build(BuildContext context) {
    AppStateProvider appState = Provider.of<AppStateProvider>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);
    Widget home = Scaffold(
        key: scaffoldState,
        drawer: Drawer(
            child: ListView(
          children: [
            UserAccountsDrawerHeader(
                onDetailsPressed: () =>
                    changeScreen(context, const ProfileScreen()),
                accountName: CustomText(
                  text: userProvider.userModel?.name ?? "",
                  size: 18,
                  weight: FontWeight.bold,
                ),
                accountEmail: CustomText(
                  text: userProvider.userModel?.email ?? "",
                )),
            ListTile(
              leading: const Icon(Icons.wallet),
              title: const CustomText(text: "Wallet and History"),
              onTap: () {
                changeScreen(context, const HistoryScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const CustomText(text: "Log out"),
              onTap: () {
                userProvider.signOut();
                changeScreenReplacement(context, const LoginScreen());
              },
            )
          ],
        )),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("requests")
                .where("status", isEqualTo: "pending")
                // .where("driverId",
                //     isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .where("type", isEqualTo: userProvider.userModel?.type)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Loading();
              }

              if (snapshot.data!.docs.isNotEmpty) {
                int i = snapshot.data!.docs.indexWhere((element) =>
                    !((element.data()["rejectedDrivers"] as List)
                        .contains(FirebaseAuth.instance.currentUser!.uid)));
                if (i != -1) {
                  appState
                      .handleNotificationData(snapshot.data!.docs[i].data());
                }
              } else if (appState.hasNewRideRequest) {
                appState.changeRideRequestStatus();
              }

              return Stack(
                children: [
                  MapScreen(scaffoldState),
                  Positioned(
                      top: 40,
                      left: MediaQuery.of(context).size.width / 4,
                      right: MediaQuery.of(context).size.width / 4,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.only(left: 00),
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CabText(
                                  isActive ? "Online" : "Offline",
                                  color: Colors.black87,
                                  size: 17,
                                  weight: FontWeight.w500,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: CupertinoSwitch(
                                    // This bool value toggles the switch.
                                    value: isActive,
                                    thumbColor: isActive
                                        ? CupertinoColors.systemGreen
                                        : CupertinoColors.systemRed,
                                    trackColor: CupertinoColors.systemRed
                                        .withOpacity(0.34),
                                    activeColor: CupertinoColors.systemGreen
                                        .withOpacity(0.34),
                                    onChanged: (bool? value) async {
                                      UserServices().updateUserData({
                                        "id": userProvider.userModel!.id,
                                        "online": value
                                      });
                                      setState(() {
                                        isActive = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ))),
                  Visibility(
                    visible: appState.show == Show.trip,
                    child: Positioned(
                        top: 60,
                        left: MediaQuery.of(context).size.width / 7,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                color: primary,
                                child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: RichText(
                                        text: TextSpan(children: [
                                      const TextSpan(
                                          text:
                                              "You'll reach your destination in \n",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w300)),
                                      TextSpan(
                                          text: appState.show == Show.trip
                                              ? appState
                                                  .routeModel?.timeNeeded.text
                                              : "",
                                          style: const TextStyle(fontSize: 22)),
                                    ]))),
                              ),
                            ],
                          ),
                        )),
                  ),
                  //  ANCHOR Draggable DRIVER
                  Visibility(
                      visible: appState.show == Show.rider,
                      child: RiderWidget()),
                  Visibility(
                      visible: appState.show == Show.trip,
                      child: const TripWidget()),
                ],
              );
            }));

    switch (appState.hasNewRideRequest) {
      case false:
        return home;
      case true:
        return const RideRequestScreen();
      default:
        return home;
    }
  }
}

class MapScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldState;

  const MapScreen(this.scaffoldState, {super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  GoogleMapsPlaces? googlePlaces;

  Color darkBlue = Colors.black;
  Color grey = Colors.grey;
  GlobalKey<ScaffoldState> scaffoldSate = GlobalKey<ScaffoldState>();
  String position = "postion";

  @override
  void initState() {
    super.initState();
    scaffoldSate = widget.scaffoldState;
  }

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState = Provider.of<AppStateProvider>(context);
    return appState.center == null
        ? const Loading()
        : Stack(
            children: <Widget>[
              GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: appState.center!, zoom: 15),
                onMapCreated: appState.onCreate,
                myLocationEnabled: true,
                mapType: MapType.normal,
                myLocationButtonEnabled: false,
                compassEnabled: true,
                zoomControlsEnabled: false,
                rotateGesturesEnabled: true,
                padding: const EdgeInsets.symmetric(vertical: 30),
                markers: appState.markers,
                onCameraMove: appState.onCameraMove,
                polylines: appState.poly,
              ),
              Positioned(
                top: 40,
                left: 15,
                child: IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: primary,
                      size: 30,
                    ),
                    onPressed: () {
                      scaffoldSate.currentState!.openDrawer();
                    }),
              ),
              Positioned(
                  bottom: MediaQuery.of(context).size.height / 3,
                  right: 20,
                  child: SizedBox(
                    width: 46,
                    child: FloatingActionButton(
                      onPressed: () {
                        Geolocator.getCurrentPosition().then((value) => appState
                            .mapController
                            .animateCamera(CameraUpdate.newLatLng(
                                LatLng(value.latitude, value.longitude))));
                      },
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ))
            ],
          );
  }
}
