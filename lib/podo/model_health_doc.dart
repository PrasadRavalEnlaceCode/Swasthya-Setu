/// HealthInfoDocumentIDP : 2
/// FileName : "About Diabetes"

class ModelHealthDoc {
  ModelHealthDoc({
      int? healthInfoDocumentIDP,
      String? fileName,String? firstName,String? middleName,String? lastName}){
    _healthInfoDocumentIDP = healthInfoDocumentIDP!;
    _fileName = fileName!;
}

  ModelHealthDoc.fromJson(dynamic json) {
    _healthInfoDocumentIDP = json['HealthInfoDocumentIDP'];
    _fileName = json['FileName'];
  }
  int? _healthInfoDocumentIDP;
  String? _fileName;

  int? get healthInfoDocumentIDP => _healthInfoDocumentIDP;
  String? get fileName => _fileName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['HealthInfoDocumentIDP'] = _healthInfoDocumentIDP;
    map['FileName'] = _fileName;
    return map;
  }

}