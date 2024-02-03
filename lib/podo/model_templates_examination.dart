import 'dart:convert';

List<ExaminationTemplateModel> examinationTemplateModelFromJson(String str) =>
    List<ExaminationTemplateModel>.from(
        json.decode(str).map((x) => ExaminationTemplateModel.fromJson(x)));

String examinationTemplateModelToJson(List<ExaminationTemplateModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExaminationTemplateModel {
  ExaminationTemplateModel({
    this.examinationTemplateIdp,
    this.examinationTemplateName,
    this.examinationTemplateDetails,
  });

  int? examinationTemplateIdp;
  String? examinationTemplateName;
  String? examinationTemplateDetails;

  factory ExaminationTemplateModel.fromJson(Map<String, dynamic> json) =>
      ExaminationTemplateModel(
        examinationTemplateIdp: json["ExaminationTemplateIDP"],
        examinationTemplateName: json["ExaminationTemplateName"],
        examinationTemplateDetails: json["ExaminationTemplateDetails"],
      );

  Map<String, dynamic> toJson() => {
        "ExaminationTemplateIDP": examinationTemplateIdp,
        "ExaminationTemplateName": examinationTemplateName,
        "ExaminationTemplateDetails": examinationTemplateDetails,
      };
}
