import 'package:taxitaxi_driver/helpers/constants.dart';
import 'package:taxitaxi_driver/models/route.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher_string.dart';

class GoogleMapsServices {
  Future<RouteModel> getRouteByCoordinates(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$googleMapsAPIKey";
    http.Response response = await http.get(Uri.parse(url));
    Map values = jsonDecode(response.body);

    Map routes = values["routes"][0];
    Map legs = values["routes"][0]["legs"][0];
    RouteModel route = RouteModel(
        points: routes["overview_polyline"]["points"],
        distance: Distance.fromMap(legs['distance']),
        timeNeeded: TimeNeeded.fromMap(legs['duration']),
        endAddress: legs['end_address'],
        startAddress: legs['end_address']);
    return route;
  }

  static void navigateTo(double lat, double lng) async {
    var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunchUrlString(uri.toString())) {
      await launchUrlString(uri.toString());
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  }
}
