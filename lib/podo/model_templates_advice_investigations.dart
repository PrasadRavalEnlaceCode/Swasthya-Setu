// To parse this JSON data, do
//
//     final adviceInvestigationTemplateModel = adviceInvestigationTemplateModelFromJson(jsonString);

import 'dart:convert';

List<AdviceInvestigationTemplateModel> adviceInvestigationTemplateModelFromJson(String str) => List<AdviceInvestigationTemplateModel>.from(json.decode(str).map((x) => AdviceInvestigationTemplateModel.fromJson(x)));

String adviceInvestigationTemplateModelToJson(List<AdviceInvestigationTemplateModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AdviceInvestigationTemplateModel {
  AdviceInvestigationTemplateModel({
    this.investTemplateIdp,
    this.investTemplateName,
    this.investTemplateDetails,
  });

  int? investTemplateIdp;
  String? investTemplateName;
  dynamic investTemplateDetails;

  factory AdviceInvestigationTemplateModel.fromJson(Map<String, dynamic> json) => AdviceInvestigationTemplateModel(
    investTemplateIdp: json["InvestTemplateIDP"],
    investTemplateName: json["InvestTemplateName"],
    investTemplateDetails: json["InvestTemplateDetails"],
  );

  Map<String, dynamic> toJson() => {
    "InvestTemplateIDP": investTemplateIdp,
    "InvestTemplateName": investTemplateName,
    "InvestTemplateDetails": investTemplateDetails,
  };
}
