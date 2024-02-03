import 'dart:convert';

List<PatientPayment> patientPaymentFromJson(String str) =>
    List<PatientPayment>.from(
        json.decode(str).map((x) => PatientPayment.fromJson(x)));

String patientPaymentToJson(List<PatientPayment> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PatientPayment {
  PatientPayment({
    this.doctorPaymentIdp,
    this.firstName,
    this.lastName,
    this.paymentDetails,
    this.paymentStatus,
    this.amount,
    this.patientActivationReceiptIdf,
    this.timeStamp,
  });

  String? doctorPaymentIdp;
  String? firstName;
  String? lastName;
  String? paymentDetails;
  String? paymentStatus;
  String? amount;
  String? patientActivationReceiptIdf;
  String? timeStamp;

  factory PatientPayment.fromJson(Map<String, dynamic> json) => PatientPayment(
        doctorPaymentIdp: json["DoctorPaymentIDP"],
        firstName: json["FirstName"],
        lastName: json["LastName"],
        paymentDetails: json["PaymentDetails"],
        paymentStatus: json["PaymentStatus"],
        amount: json["Amount"],
        patientActivationReceiptIdf: json["PatientActivationReceiptIDF"],
        timeStamp: json["TimeStamp"],
      );

  Map<String, dynamic> toJson() => {
        "DoctorPaymentIDP": doctorPaymentIdp,
        "FirstName": firstName,
        "LastName": lastName,
        "PaymentDetails": paymentDetails,
        "PaymentStatus": paymentStatus,
        "Amount": amount,
        "PatientActivationReceiptIDF": patientActivationReceiptIdf,
        "TimeStamp": timeStamp,
      };
}
