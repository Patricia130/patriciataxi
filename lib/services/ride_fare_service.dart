import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ride_fare.dart';

class RideFareService {
  Future<List<RideFare>> fetchRideFare() async {
    List<RideFare> rideFares = [];
    QuerySnapshot snaps = await FirebaseFirestore.instance
        .collection("rides")
        .where("isActive", isEqualTo: true)
        .get();
    for (var element in snaps.docs) {
      rideFares.add(RideFare.fromJson(element.data() as Map<String, dynamic>));
    }
    return rideFares;
  }
}
