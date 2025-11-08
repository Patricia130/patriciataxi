import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxitaxi_driver/helpers/custom_dialog.dart';
import 'package:taxitaxi_driver/services/map_requests.dart';
import 'package:taxitaxi_driver/widgets/cab_button.dart';
import 'package:taxitaxi_driver/widgets/cab_text.dart';

import '../helpers/style.dart';
import '../providers/app_provider.dart';
import 'custom_text.dart';

class TripWidget extends StatelessWidget {
  const TripWidget({super.key});

  // final CallsAndMessagesService _service = locator<CallsAndMessagesService>();

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState = Provider.of<AppStateProvider>(context);

    return DraggableScrollableSheet(
        initialChildSize: 0.2,
        minChildSize: 0.2,
        maxChildSize: 0.8,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CustomText(
                      text: 'ON trip',
                      weight: FontWeight.bold,
                      color: green,
                    ),
                  ],
                ),
                const Divider(),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            TextSpan(
                                text: "${appState.riderModel!.name}\n",
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: appState.riderModel!.phone,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w300)),
                          ], style: const TextStyle(color: black))),
                      IconButton(
                          iconSize: 40,
                          onPressed: () {
                            GoogleMapsServices.navigateTo(
                                appState.rideRequestModel.dLatitude,
                                appState.rideRequestModel.dLongitude);
                          },
                          icon: const Icon(
                            Icons.assistant_navigation,
                            color: primaryColor,
                          ))
                    ],
                  ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: CustomText(
                        text: "Ride price",
                        size: 18,
                        weight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: CustomText(
                        text:
                            "₹${appState.rideRequestModel.price.toStringAsFixed(2)}",
                        size: 18,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: CabButton(
                    text: "Complete Ride",
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
                                const Icon(Icons.done_outline_rounded,
                                    color: Colors.green, size: 60),
                                const CabText(
                                  "Booking completed successfully.",
                                  color: black,
                                  align: TextAlign.center,
                                ),
                                CabButton(
                                    height: 40,
                                    width: 180,
                                    text: "Back to Home",
                                    func: () async {
                                      appState.completeRequest(
                                          title: "Ride Completed",
                                          body:
                                              "Please pay ${appState.rideRequestModel.price} & Share your feedback.",
                                          deviceToken:
                                              appState.riderModel!.token,
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
                    color: Colors.greenAccent[700],
                  ),
                )
              ],
            ),
          );
        });
  }
}
