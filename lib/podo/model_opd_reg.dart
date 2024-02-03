import 'package:equatable/equatable.dart';

class ModelOPDRegistration extends Equatable {
  String? idp, name, amount, pdfUrl;
  bool? isChecked;
  String? patientIDP,
      amountBeforeDiscount,
      discount,
      checkOutStatus,
      fromRequestStatus,
      vidCallDate,
      doctorName,
      paymentDueStatus,
      clearedFromDueStatus,
      reportUploadStatus,
      reportFileName,
      reportUploadedDate,
      healthCareProviderIDF,
      bindStatus,
      internalNotes,
      campID;

  ModelOPDRegistration(this.idp, this.name, this.amount, this.pdfUrl,
      {this.isChecked = false,
      this.patientIDP = "",
      this.amountBeforeDiscount = "",
      this.discount = "",
      this.checkOutStatus = "0",
      this.fromRequestStatus,
      this.vidCallDate,
      this.doctorName,
      this.paymentDueStatus,
      this.clearedFromDueStatus,
      this.reportUploadStatus,
      this.reportFileName,
      this.reportUploadedDate,
      this.healthCareProviderIDF,
      this.bindStatus,
        this.internalNotes,
      this.campID});

  @override
  List<Object> get props => [
        idp!,
        name!,
        amount!,
        pdfUrl!,
        isChecked!,
        patientIDP!,
        amountBeforeDiscount!,
        discount!,
        checkOutStatus!,
        doctorName!,
        paymentDueStatus!,
        clearedFromDueStatus!,
        reportUploadStatus!,
        reportFileName!,
        reportUploadedDate!,
        healthCareProviderIDF!,
        bindStatus!,
        internalNotes!,
        campID!
      ];
}
