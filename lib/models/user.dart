import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  static const idConst = "id";
  static const nameConst = "name";
  static const emailConst = "email";
  static const phoneConst = "phone";
  static const tripsConst = "trips";
  static const tokenConst = "token";
  static const photoConst = "photo";
  static const onlineConst = "online";
  static const typeConst = "type";
  static const carConst = "car";
  static const plateConst = "plate";
  static const isActiveConst = "isActive";
  static const vehicleIdProofConst = "vehicleProof";
  static const idProofConst = "idProof";

  final String name;
  final String email;
  final String id;
  final String token;
  final String photo;
  final String phone;

  final String type;
  final String car;
  final String plate;
  final bool online;
  final bool isActive;
  final String? vehicleIdProof;
  final String? idProof;

  UserModel({
    required this.photo,
    required this.isActive,
    required this.vehicleIdProof,
    required this.idProof,
    required this.online,
    required this.name,
    required this.email,
    required this.type,
    required this.car,
    required this.plate,
    required this.id,
    required this.token,
    required this.phone,
  });

  static UserModel fromSnapshot(DocumentSnapshot snapshot) {
    Map data = snapshot.data() as Map;
    return UserModel(
        online: data[onlineConst],
        car: data[carConst],
        type: data[typeConst],
        plate: data[plateConst],
        photo: data[photoConst] ?? "",
        name: data[nameConst],
        email: data[emailConst],
        id: data[idConst],
        token: data[tokenConst],
        phone: data[phoneConst],
        isActive: data[isActiveConst],
        idProof: data[idConst],
        vehicleIdProof: data[vehicleIdProofConst]);
  }
}
