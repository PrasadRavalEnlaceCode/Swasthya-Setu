// To parse this JSON data, do
//
//     final prescriptionTemplateModel = prescriptionTemplateModelFromJson(jsonString);

import 'dart:convert';

List<PrescriptionTemplateModel> prescriptionTemplateModelFromJson(String str) =>
    List<PrescriptionTemplateModel>.from(
        json.decode(str).map((x) => PrescriptionTemplateModel.fromJson(x)));

String prescriptionTemplateModelToJson(List<PrescriptionTemplateModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PrescriptionTemplateModel {
  PrescriptionTemplateModel({
    this.templateIdp,
    this.templateName,
  });

  int? templateIdp;
  String? templateName;

  factory PrescriptionTemplateModel.fromJson(Map<String, dynamic> json) =>
      PrescriptionTemplateModel(
        templateIdp: json["TemplateIDP"],
        templateName: json["TemplateName"],
      );

  Map<String, dynamic> toJson() => {
        "TemplateIDP": templateIdp,
        "TemplateName": templateName,
      };
}
