// To parse this JSON data, do
//
//     final specialityModel = specialityModelFromJson(jsonString);

import 'dart:convert';

List<SpecialityModel> specialityModelFromJson(String str) =>
    List<SpecialityModel>.from(
        json.decode(str).map((x) => SpecialityModel.fromJson(x)));

String specialityModelToJson(List<SpecialityModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SpecialityModel {
  SpecialityModel({
    this.specialityIdp,
    this.specialityName,
  });

  int? specialityIdp;
  String? specialityName;

  factory SpecialityModel.fromJson(Map<String, dynamic> json) =>
      SpecialityModel(
        specialityIdp: json["SpecialityIDP"],
        specialityName: json["SpecialityName"],
      );

  Map<String, dynamic> toJson() => {
        "SpecialityIDP": specialityIdp,
        "SpecialityName": specialityName,
      };
}
