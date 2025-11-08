class RouteModel {
  final String points;
  final Distance distance;
  final TimeNeeded timeNeeded;
  final String startAddress;
  final String endAddress;

  RouteModel(
      {required this.points,
      required this.distance,
      required this.timeNeeded,
      required this.startAddress,
      required this.endAddress});
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

class TimeNeeded {
  final String text;
  final int value;
  TimeNeeded({required this.text, required this.value});
  static TimeNeeded fromMap(Map data) {
    return TimeNeeded(text: data["text"], value: data["value"]);
  }
}
