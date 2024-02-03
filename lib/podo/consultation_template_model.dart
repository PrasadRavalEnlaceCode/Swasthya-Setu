// To parse this JSON data, do
//
//     final consultationTemplateModel = consultationTemplateModelFromJson(jsonString);

import 'dart:convert';

List<ConsultationTemplateModel> consultationTemplateModelFromJson(String str) =>
    List<ConsultationTemplateModel>.from(
        json.decode(str).map((x) => ConsultationTemplateModel.fromJson(x)));

String consultationTemplateModelToJson(List<ConsultationTemplateModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConsultationTemplateModel {
  ConsultationTemplateModel({
    this.consultationTemplateIdp,
    this.consultationTemplateName,
  });

  int? consultationTemplateIdp;
  String? consultationTemplateName;

  factory ConsultationTemplateModel.fromJson(Map<String, dynamic> json) =>
      ConsultationTemplateModel(
        consultationTemplateIdp: json["ConsultationTemplateIDP"],
        consultationTemplateName: json["ConsultationTemplateName"],
      );

  Map<String, dynamic> toJson() => {
        "ConsultationTemplateIDP": consultationTemplateIdp,
        "ConsultationTemplateName": consultationTemplateName,
      };
}
