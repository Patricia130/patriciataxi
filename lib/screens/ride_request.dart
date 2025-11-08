import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxitaxi_driver/helpers/constants.dart';
import 'package:taxitaxi_driver/helpers/style.dart';
import 'package:taxitaxi_driver/providers/app_provider.dart';
import 'package:taxitaxi_driver/providers/user.dart';
import 'package:taxitaxi_driver/widgets/cab_button.dart';
import 'package:taxitaxi_driver/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../widgets/cab_text.dart';

class RideRequestScreen extends StatefulWidget {
  const RideRequestScreen({super.key});

  @override
  RideRequestScreenState createState() => RideRequestScreenState();
}

class RideRequestScreenState extends State<RideRequestScreen> {
  @override
  void initState() {
    super.initState();

    AppStateProvider state =
        Provider.of<AppStateProvider>(context, listen: false);
    state.listenToRequest(id: state.rideRequestModel.id, context: context);
  }

  Padding dataDetailRow(String title, String subtitle, [double? height]) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CabText(title, weight: FontWeight.w500, size: 16, spacing: .5),
              const SizedBox(width: 30),
              Flexible(
                  child: CabText(
                subtitle,
                spacing: .5,
                size: 15,
                align: TextAlign.end,
              ))
            ],
          ),
          SizedBox(height: height ?? 8),
          // Divider(height: 2)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState = Provider.of<AppStateProvider>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        toolbarHeight: 60,
        centerTitle: true,
        title: const CabText(
          "New Ride Request",
          size: 19,
          weight: FontWeight.w500,
        ),
      ),
      backgroundColor: white,
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 4, right: 4),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 18, left: 20),
                child: CabText(
                  "Ride Details",
                  size: 18,
                  weight: FontWeight.bold,
                ),
              ),
              Card(
                elevation: 4,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      dataDetailRow("Status", "Pending"),
                      dataDetailRow(
                          "Requested By", appState.riderModel?.name ?? ""),
                      dataDetailRow("Ride Distance",
                          appState.rideRequestModel.distance.text),
                      dataDetailRow("Pickup ",
                          appState.rideRequestModel.pickupAddress, 2),
                      Align(
                          alignment: Alignment.centerRight,
                          child: CabButton(
                              func: () {
                                LatLng pickupCoordiates = LatLng(
                                    appState.rideRequestModel.uLatitude,
                                    appState.rideRequestModel.uLongitude);
                                appState.addLocationMarker(
                                    pickupCoordiates,
                                    appState.rideRequestModel.pickupAddress,
                                    "Pickup Location");
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext bc) {
                                      return SizedBox(
                                        height: 400,
                                        child: GoogleMap(
                                          initialCameraPosition: CameraPosition(
                                              target: pickupCoordiates,
                                              zoom: 13),
                                          onMapCreated: appState.onCreate,
                                          myLocationEnabled: true,
                                          mapType: MapType.normal,
                                          tiltGesturesEnabled: true,
                                          compassEnabled: false,
                                          markers: appState.markers,
                                          onCameraMove: appState.onCameraMove,
                                          polylines: appState.poly,
                                        ),
                                      );
                                    });
                              },
                              width: 100,
                              height: 30,
                              textSize: 12,
                              isLoading: false,
                              text: "View")),
                      const SizedBox(height: 6),
                      dataDetailRow("Destination ",
                          appState.rideRequestModel.destination, 2),
                      Align(
                          alignment: Alignment.centerRight,
                          child: CabButton(
                              func: () {
                                LatLng destinationCoordiates = LatLng(
                                    appState.rideRequestModel.dLatitude,
                                    appState.rideRequestModel.dLongitude);
                                appState.addLocationMarker(
                                    destinationCoordiates,
                                    appState.rideRequestModel.destination,
                                    "Destination Location");
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext bc) {
                                      return SizedBox(
                                        height: 400,
                                        child: GoogleMap(
                                          initialCameraPosition: CameraPosition(
                                              target: destinationCoordiates,
                                              zoom: 13),
                                          onMapCreated: appState.onCreate,
                                          myLocationEnabled: true,
                                          mapType: MapType.normal,
                                          tiltGesturesEnabled: true,
                                          compassEnabled: false,
                                          markers: appState.markers,
                                          onCameraMove: appState.onCameraMove,
                                          polylines: appState.poly,
                                        ),
                                      );
                                    });
                              },
                              width: 100,
                              height: 30,
                              textSize: 12,
                              isLoading: false,
                              text: "View")),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(bottom: 18, left: 20),
                child: CabText(
                  "Payment Details",
                  size: 18,
                  weight: FontWeight.bold,
                ),
              ),
              Card(
                elevation: 4,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      dataDetailRow("Your Payout",
                          "₹${(appState.rideRequestModel.price * .8).toStringAsFixed(2)}"),
                      dataDetailRow("App Fees",
                          "+  ₹${(appState.rideRequestModel.price * .2).toStringAsFixed(2)}"),
                      dataDetailRow("Ride Total",
                          "₹${(appState.rideRequestModel.price).toStringAsFixed(2)}"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CabButton(
                    isLoading: false,
                    text: "Accept",
                    func: () async {
                      if (appState.rideRequestModel.status != "pending") {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        20.0)), //this right here
                                child: SizedBox(
                                  height: 200,
                                  child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          CustomText(
                                              text: "Sorry! Request Expired")
                                        ],
                                      )),
                                ),
                              );
                            });
                      } else {
                        appState.clearMarkers();

                        appState.acceptRequest(
                            title: "Ride Accepted",
                            body:
                                "Rider ${userProvider.userModel!.name} is on his way.",
                            deviceToken: appState.riderModel?.token ?? "",
                            requestId: appState.rideRequestModel.id,
                            driverId: userProvider.userModel!.id);
                        appState.changeWidgetShowed(showWidget: Show.rider);
                        appState.sendRequest(
                            coordinates: appState.rideRequestModel
                                .getPickupCoordinates());
                      }
                    },
                    height: 46, width: MediaQuery.of(context).size.width / 2.5,
                    textColor: Colors.white,
                    color: Colors.green[500],
                    // shadowColor: Colors.greenAccent,
                  ),
                  CabButton(
                    height: 46, width: MediaQuery.of(context).size.width / 2.5,
                    text: "Reject",
                    isLoading: false,
                    func: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.remove(requestIdPref);
                      //               PushNotificationServices.sendNotification(
                      // deviceToken: appState.riderModel?.token ?? "", title: "Ride Rejected", body: "");
                      appState.cancelRequest(
                          requestId: appState.rideRequestModel.id,
                          isReject: true);
                    },
                    textColor: Colors.white,
                    color: Colors.red[700],
                    // shadowColor: Colors.redAccent,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
