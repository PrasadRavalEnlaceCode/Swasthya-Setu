/// CertificateTypeIDP : 2
/// CertificateTypeName : "FITNESS CERTIFICATE"

class ModelCertificate {
  ModelCertificate({
      int? certificateTypeIDP,
      String? certificateTypeName,}){
    _certificateTypeIDP = certificateTypeIDP;
    _certificateTypeName = certificateTypeName;
}

  ModelCertificate.fromJson(dynamic json) {
    _certificateTypeIDP = json['CertificateTypeIDP'];
    _certificateTypeName = json['CertificateTypeName'];
  }
  int? _certificateTypeIDP;
  String? _certificateTypeName;

  int? get certificateTypeIDP => _certificateTypeIDP;
  String? get certificateTypeName => _certificateTypeName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CertificateTypeIDP'] = _certificateTypeIDP;
    map['CertificateTypeName'] = _certificateTypeName;
    return map;
  }

}