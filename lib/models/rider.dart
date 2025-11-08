import 'package:cloud_firestore/cloud_firestore.dart';

class RiderModel {
  static const idConst = "id";
  static const nameConst = "name";
  static const emailConst = "email";
  static const phoneConst = "phone";
  static const votesConst = "votes";
  static const tripsConst = "trips";
  static const ratingConst = "rating";
  static const tokenConst = "token";
  static const photoConst = "photo";

//  getters
  final String name;
  final String email;
  final String id;
  final String phone;
  final int votes;
  final int trips;
  final double rating;
  final String token;
  final String? photo;

  RiderModel({
    required this.name,
    required this.email,
    required this.id,
    required this.phone,
    required this.votes,
    required this.trips,
    required this.rating,
    required this.token,
    required this.photo,
  });

  static RiderModel fromSnapshot(DocumentSnapshot snapshot) {
    Map data = snapshot.data() as Map;

    return RiderModel(
        name: data[nameConst],
        email: data[emailConst],
        id: data[idConst],
        phone: data[phoneConst],
        votes: data[votesConst],
        trips: data[tripsConst],
        rating: data[ratingConst],
        token: data[tokenConst],
        photo: data[photoConst]);
  }
}
