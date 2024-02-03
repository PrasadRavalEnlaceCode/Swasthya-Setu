class DropDownItemConsultation {
  String idp, value;

  DropDownItemConsultation({required this.idp, required this.value});

  factory DropDownItemConsultation.fromJson(Map<String, dynamic> json) {
    return DropDownItemConsultation(
      idp: json['DoctorIDP'] as String,
      value: json['FirstName'] as String,
    );
  }
}
