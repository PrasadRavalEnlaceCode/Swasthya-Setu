// To parse this JSON data, do
//
//     final remarksTemplateModel = remarksTemplateModelFromJson(jsonString);

import 'dart:convert';

List<RemarksTemplateModel> remarksTemplateModelFromJson(String str) =>
    List<RemarksTemplateModel>.from(
        json.decode(str).map((x) => RemarksTemplateModel.fromJson(x)));

String remarksTemplateModelToJson(List<RemarksTemplateModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RemarksTemplateModel {
  RemarksTemplateModel({
    this.remarkTemplateIdp,
    this.remarkTemplateName,
    this.remarksTemplateDetails,
  });

  int? remarkTemplateIdp;
  String? remarkTemplateName;
  String? remarksTemplateDetails;

  factory RemarksTemplateModel.fromJson(Map<String, dynamic> json) =>
      RemarksTemplateModel(
        remarkTemplateIdp: json["RemarkTemplateIDP"],
        remarkTemplateName: json["RemarkTemplateName"],
        remarksTemplateDetails: json["RemarksTemplateDetails"] == null
            ? null
            : json["RemarksTemplateDetails"],
      );

  Map<String, dynamic> toJson() => {
        "RemarkTemplateIDP": remarkTemplateIdp,
        "RemarkTemplateName": remarkTemplateName,
        "RemarksTemplateDetails":
            remarksTemplateDetails == null ? null : remarksTemplateDetails,
      };
}
