import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideRequestModel {
  static const idConst = "id";
  static const usernameConst = "username";
  static const userIdConst = "userId";
  static const statusConst = "status";
  static const typeConst = "type";
  static const destinationConst = "destination";
  static const destinationLatitudeConst = "latitude";
  static const destinationLongitudeConst = "longitude";
  static const userLatitudeConst = "latitude";
  static const userLongitudeConst = "longitude";
  static const distanceText = "text";
  static const distanceValue = "value";

  // String _id;
  // String _username;
  // String _userId;
  // String _destination;
  // double _dLatitude;
  // double _dLongitude;
  // double _uLatitude;
  // double _uLongitude;
  // Distance _distance;
  RideRequestModel({
    required this.status,
    required this.type,
    required this.id,
    required this.price,
    required this.pickupAddress,
    required this.username,
    required this.userId,
    required this.destination,
    required this.dLatitude,
    required this.dLongitude,
    required this.uLatitude,
    required this.uLongitude,
    required this.distance,
  });
  final String id;
  final num price;
  final String username;

  final String status;

  final String type;

  final String userId;

  final String destination;

  final double dLatitude;

  final double dLongitude;

  final double uLatitude;
  final String pickupAddress;
  final double uLongitude;

  final Distance distance;

  static RideRequestModel fromMap(Map data) {
    Map d = data[destinationConst];
    return RideRequestModel(
        price: data["price"],
        pickupAddress: data["pickupAddress"],
        status: data[statusConst],
        type: data[typeConst],
        id: data[idConst],
        username: data[usernameConst],
        userId: data[userIdConst],
        destination: d["address"].substring(0, d["address"].indexOf(',')),
        dLatitude: d[destinationLatitudeConst],
        dLongitude: d[destinationLongitudeConst],
        uLatitude: data["position"][userLatitudeConst],
        uLongitude: data["position"][userLongitudeConst],
        distance: Distance.fromMap({
          "text": data["distance"][distanceText],
          "value": data["distance"][distanceValue]
        }));
  }

  LatLng getDestinationCoordinates() => LatLng(dLatitude, dLongitude);
  LatLng getPickupCoordinates() => LatLng(uLatitude, uLongitude);
}

class Distance {
  final String text;
  final int value;
  Distance({required this.text, required this.value});
  static Distance fromMap(Map data) {
    return Distance(text: data["text"], value: data["value"]);
  }

  Map toJson() => {"text": text, "value": value};
}
