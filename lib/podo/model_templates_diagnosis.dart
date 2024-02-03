// To parse this JSON data, do
//
//     final diagnosisTemplateModel = diagnosisTemplateModelFromJson(jsonString);

import 'dart:convert';

List<DiagnosisTemplateModel> diagnosisTemplateModelFromJson(String str) =>
    List<DiagnosisTemplateModel>.from(
        json.decode(str).map((x) => DiagnosisTemplateModel.fromJson(x)));

String diagnosisTemplateModelToJson(List<DiagnosisTemplateModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DiagnosisTemplateModel {
  DiagnosisTemplateModel({
    this.dignosisTemplateIdp,
    this.diagnosisTemplateName,
    this.diagnosisTemplateDetails,
  });

  int? dignosisTemplateIdp;
  String? diagnosisTemplateName;
  String? diagnosisTemplateDetails;

  factory DiagnosisTemplateModel.fromJson(Map<String, dynamic> json) =>
      DiagnosisTemplateModel(
        dignosisTemplateIdp: json["DignosisTemplateIDP"],
        diagnosisTemplateName: json["DiagnosisTemplateName"],
        diagnosisTemplateDetails: json["DiagnosisTemplateDetails"],
      );

  Map<String, dynamic> toJson() => {
        "DignosisTemplateIDP": dignosisTemplateIdp,
        "DiagnosisTemplateName": diagnosisTemplateName,
        "DiagnosisTemplateDetails": diagnosisTemplateDetails,
      };
}
