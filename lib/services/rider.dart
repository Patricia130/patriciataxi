import 'package:taxitaxi_driver/helpers/constants.dart';
import 'package:taxitaxi_driver/models/rider.dart';

class RiderServices {
  String collection = "users";

  Future<RiderModel> getRiderById(String id) =>
      firebaseFiretore.collection(collection).doc(id).get().then((doc) {
        return RiderModel.fromSnapshot(doc);
      });
}
