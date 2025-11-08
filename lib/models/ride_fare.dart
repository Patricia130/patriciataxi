class RideFare {
  String name;
  String desc;
  dynamic image;
  num farePerKm;
  num fixedRate;
  String? id;
  bool isActive;

  RideFare({
    required this.name,
    required this.farePerKm,
    required this.image,
    required this.desc,
    required this.fixedRate,
    this.id,
    required this.isActive,
  });
  factory RideFare.fromJson(Map<String, dynamic> json) => RideFare(
      name: json["name"],
      id: json["id"],
      image: json["imageUrl"],
      isActive: json["isActive"],
      farePerKm: json["farePerKm"],
      desc: json["desc"],
      fixedRate: json["fixedFare"]);
}
