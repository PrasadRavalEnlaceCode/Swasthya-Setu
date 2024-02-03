import 'dart:convert';

List<ComplaintTemplateModel> complaintTemplateModelFromJson(String str) =>
    List<ComplaintTemplateModel>.from(
        json.decode(str).map((x) => ComplaintTemplateModel.fromJson(x)));

String complaintTemplateModelToJson(List<ComplaintTemplateModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ComplaintTemplateModel {
  ComplaintTemplateModel({
    this.complainTemplateIdp,
    this.complainTemplateName,
    this.complainTemplateDetails,
  });

  int? complainTemplateIdp;
  String? complainTemplateName;
  String? complainTemplateDetails;

  factory ComplaintTemplateModel.fromJson(Map<String, dynamic> json) =>
      ComplaintTemplateModel(
        complainTemplateIdp: json["ComplainTemplateIDP"],
        complainTemplateName: json["ComplainTemplateName"] ?? json["ComplainTemplateDetails"],
        complainTemplateDetails: json["ComplainTemplateDetails"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "ComplainTemplateIDP": complainTemplateIdp,
        "ComplainTemplateName": complainTemplateName,
        "ComplainTemplateDetails": complainTemplateDetails,
      };
}
