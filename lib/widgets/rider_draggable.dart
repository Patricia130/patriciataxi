import 'package:taxitaxi_driver/locators/service_locator.dart';
import 'package:taxitaxi_driver/providers/app_provider.dart';
import 'package:taxitaxi_driver/services/call_sms.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:taxitaxi_driver/widgets/cab_button.dart';
import 'package:taxitaxi_driver/widgets/cab_text.dart';

import '../helpers/custom_dialog.dart';
import '../helpers/style.dart';
import 'custom_text.dart';

class RiderWidget extends StatelessWidget {
  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();

  RiderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState = Provider.of<AppStateProvider>(context);

    return DraggableScrollableSheet(
        initialChildSize: 0.2,
        minChildSize: 0.2,
        maxChildSize: 0.6,
        builder: (BuildContext context, myscrollController) {
          return Container(
            decoration: BoxDecoration(
                color: white,
//                        borderRadius: BorderRadius.only(
//                            topLeft: Radius.circular(20),
//                            topRight: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: grey.withOpacity(.8),
                      offset: const Offset(3, 2),
                      blurRadius: 7)
                ]),
            child: ListView(
              padding: const EdgeInsets.all(10),
              controller: myscrollController,
              children: [
                const SizedBox(
                  height: 12,
                ),
                if (appState.rideRequestModel.status == "arrived")
                  CabButton(
                    text: "Start Ride",
                    func: () {
                      appState.clearMarkers();

                      appState.startRequest(
                          requestId: appState.rideRequestModel.id,
                          title: "Ride Started",
                          body: "Enjoy your Ride! Woohoo .",
                          deviceToken: appState.riderModel!.token);
                      appState.changeWidgetShowed(showWidget: Show.trip);
                      appState.sendRequest(
                          coordinates: appState.rideRequestModel
                              .getDestinationCoordinates());
                    },
                    isLoading: false,
                    textColor: Colors.white,
                    color: Colors.greenAccent[700],
                  ),
                const SizedBox(
                  height: 12,
                ),
                ListTile(
                  leading: const CircleAvatar(
                    radius: 30,
                    child: Icon(
                      Icons.person_outline,
                      size: 25,
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: "${appState.riderModel!.name}\n",
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: appState.rideRequestModel.destination,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w300)),
                      ], style: const TextStyle(color: black))),
                    ],
                  ),
                  trailing: Container(
                      decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20)),
                      child: IconButton(
                        onPressed: () {
                          _service.call(appState.riderModel!.phone);
                        },
                        icon: const Icon(Icons.call),
                      )),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: CustomText(
                    text: "Ride details",
                    size: 18,
                    weight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      //  height: 130,
                      width: 10,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: grey,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 9),
                            child: Container(
                              height: 65,
                              width: 2,
                              color: primary,
                            ),
                          ),
                          const Icon(Icons.flag),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Flexible(
                        child: RichText(
                            //maxLines: 10,
                            text: TextSpan(children: [
                      const TextSpan(
                          text: "\nPick up location \n",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      TextSpan(
                          text:
                              "${appState.rideRequestModel.pickupAddress} \n\n\n",
                          style: const TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 16)),
                      const TextSpan(
                          text: "Destination \n",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      TextSpan(
                          text: "${appState.rideRequestModel.destination} \n",
                          style: const TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 16)),
                    ], style: const TextStyle(color: black)))),
                  ],
                ),
                const Divider(),
                CabButton(
                  text: "Cancel Ride",
                  func: () {
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
                                "You have cancelled the Booking.",
                                color: black,
                                align: TextAlign.center,
                              ),
                              CabButton(
                                  height: 40,
                                  width: 180,
                                  text: "Back to Home",
                                  func: () async {
                                    appState.cancelRequest(
                                        requestId:
                                            appState.rideRequestModel.id);
                                    Navigator.of(context).pop();
                                  },
                                  isLoading: false)
                            ],
                          ),
                        ));
                  },
                  isLoading: false,
                  textColor: Colors.white,
                  color: Colors.red[700],
                ),
              ],
            ),
          );
        });
  }
}
