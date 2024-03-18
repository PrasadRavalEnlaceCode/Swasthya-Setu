import 'package:flutter/material.dart';

class MedicineFormData {
  String pmr;
  String? pmrIDP;
  String quantity;
  String remarks;

  MedicineFormData({
    required this.pmr,
    this.pmrIDP,
    required this.quantity,
    required this.remarks,
  });

  factory MedicineFormData.fromControllers(
      TextEditingController pmrController,
      TextEditingController pmrIDPController,
      TextEditingController quantityController,
      TextEditingController remarksController) {
    return MedicineFormData(
      pmr: pmrController.text,
      pmrIDP: pmrIDPController.text,
      quantity: quantityController.text,
      remarks: remarksController.text,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pmr': pmr,
      'pmrIDP': pmrIDP,
      'quantity': quantity,
      'remarks': remarks,
    };
  }
}