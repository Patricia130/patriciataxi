import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxitaxi_driver/helpers/constants.dart';

class HistoryService {
  static String collection = "history";
  static Future<List> fetchDriverHistory(String id) async {
    List rideHistory = [];
    QuerySnapshot historySnap = await firebaseFiretore
        .collection(collection)
        .where("driverId", isEqualTo: id)
        .get();
    for (var element in historySnap.docs) {
      rideHistory.add(element);
    }
    return rideHistory;
  }
}
