import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:taxitaxi_driver/services/history_service.dart';

import '../helpers/style.dart';
import '../providers/user.dart';

import '../widgets/cab_text.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  List rideHistory = [];
  double walletTotal = 0;
  double avgRating = 0;
  @override
  void initState() {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    HistoryService.fetchDriverHistory(userProvider.userModel!.id)
        .then((value) => setState(() {
              rideHistory = value;
              walletTotal =
                  value.map((m) => m['amount']).reduce((a, b) => a + b);
              List dummy =
                  value.where((element) => element['rating'] != null).toList();

              avgRating = dummy
                  .map((m) => m['rating'])
                  .reduce((a, b) => (a + b) / dummy.length);
            }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 220,
            color: primaryColor,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 50, bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 24,
                          //color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const CabText(
                        "Ride History",
                        size: 20,
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: CabText("₹ ${walletTotal.toStringAsFixed(2)}",
                        size: 40),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star),
                        const SizedBox(width: 5),
                        CabText(avgRating.toStringAsFixed(2), size: 24),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 220,
            child: ListView.builder(
              itemCount: rideHistory.length,
              shrinkWrap: true,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, i) {
                return Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CabText("Id: ${rideHistory[i]["id"]}",
                                size: 14,
                                color: primaryColor,
                                weight: FontWeight.bold),
                            Row(
                              children: [
                                GestureDetector(
                                    // onTap: () => downloadPdf(),
                                    child: const Icon(Icons.done_all,
                                        color: green, size: 28)),
                                const SizedBox(width: 4),
                                // Text(
                                //     "${durationToString(rideHistor[i].bookingDuration)} Hr."),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: CabText(
                              "Date: ${DateFormat("MMM dd,yy hh:mm a").format(DateTime.parse(rideHistory[i]["time"]))}",
                              size: 12,
                              color: Colors.grey),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.4,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 20),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: CabText(
                                            rideHistory[i]["address"]
                                                .toString()
                                                .split(" - ")[0],
                                            align: TextAlign.center,
                                            size: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                const RotatedBox(
                                    quarterTurns: 1,
                                    child: Icon(Icons.double_arrow_sharp)),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.4,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 20),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: CabText(
                                            rideHistory[i]["address"]
                                                .toString()
                                                .split(" - ")[1],
                                            align: TextAlign.center,
                                            size: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: CabText(
                                "Total: ₹${rideHistory[i]["amount"]}",
                                size: 16,
                                weight: FontWeight.bold,
                              ),
                            ),
                            rideHistory[i]["rating"] != null
                                ? Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: RatingBar.builder(
                                      initialRating:
                                          rideHistory[i]["rating"].toDouble(),
                                      minRating: 1,
                                      itemSize: 20,
                                      ignoreGestures: true,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 1),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {},
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
