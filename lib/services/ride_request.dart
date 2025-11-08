import 'package:taxitaxi_driver/helpers/constants.dart';
import 'package:taxitaxi_driver/models/ride_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequestServices {
  String collection = "requests";

  void updateRequest(Map<String, dynamic> values) {
    firebaseFiretore.collection(collection).doc(values['id']).update(values);
  }

  Stream<QuerySnapshot> requestStream() {
    CollectionReference reference = firebaseFiretore.collection(collection);
    return reference.snapshots();
  }

  Future<RideRequestModel> getRequestById(String id) =>
      firebaseFiretore.collection(collection).doc(id).get().then((doc) {
        return RideRequestModel.fromMap(doc.data() as Map);
      });
}
