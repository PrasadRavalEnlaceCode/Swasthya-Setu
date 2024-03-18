import 'package:flutter/material.dart';

class ServicesFormData {
  String services;
  String servicesIDP;
  String servicecharge;

  ServicesFormData({
    required this.services,
    required this.servicesIDP,
    required this.servicecharge,
  });

  factory ServicesFormData.fromControllers(
      TextEditingController services,
      TextEditingController servicesIDP,
      TextEditingController servicecharge,
    ) {
    return ServicesFormData(
      services: services.text,
      servicesIDP: servicesIDP.text,
      servicecharge: servicecharge.text,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'services': services,
      'servicesIDP': servicesIDP,
      'servicecharge': servicecharge,
    };
  }
}