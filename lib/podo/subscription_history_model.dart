// To parse this JSON data, do
//
//     final subscriptionHistoryModel = subscriptionHistoryModelFromJson(jsonString);

import 'dart:convert';

List<SubscriptionHistoryModel> subscriptionHistoryModelFromJson(String str) =>
    List<SubscriptionHistoryModel>.from(
        json.decode(str).map((x) => SubscriptionHistoryModel.fromJson(x)));

String subscriptionHistoryModelToJson(List<SubscriptionHistoryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SubscriptionHistoryModel {
  SubscriptionHistoryModel({
    this.patientActivationIdp,
    this.couponCode,
    this.activationDate,
    this.expiryDate,
    this.transactionId,
    this.patientActivationReceiptIdf,
    this.mode,
    this.details,
  });

  String? patientActivationIdp;
  String? couponCode;
  String? activationDate;
  String? expiryDate;
  String? transactionId;
  String? patientActivationReceiptIdf;
  String? mode;
  String? details;

  factory SubscriptionHistoryModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionHistoryModel(
        patientActivationIdp: json["PatientActivationIDP"],
        couponCode: json["CouponCode"],
        activationDate: json["ActivationDate"],
        expiryDate: json["ExpiryDate"],
        transactionId: json["TransactionID"],
        patientActivationReceiptIdf: json["PatientActivationReceiptIDF"],
        mode: json["Mode"],
        details: json["Details"],
      );

  Map<String, dynamic> toJson() => {
        "PatientActivationIDP": patientActivationIdp,
        "CouponCode": couponCode,
        "ActivationDate": activationDate,
        "ExpiryDate": expiryDate,
        "TransactionID": transactionId,
        "PatientActivationReceiptIDF": patientActivationReceiptIdf,
        "Mode": mode,
        "Details": details,
      };
}
