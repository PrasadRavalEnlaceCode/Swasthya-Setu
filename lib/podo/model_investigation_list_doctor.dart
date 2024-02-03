class InvestigationItem {
  String? type, id, hospitalConsultationIDP, sDate, patient, doctor, labStatus, rDate, opdService, patID, createdBy;
  String?source;
  String?INID;

  InvestigationItem({
    this.type,
    this.id,
    this.hospitalConsultationIDP,
    this.sDate,
    this.patient,
    this.doctor,
    this.labStatus,
    this.rDate,
    this.opdService,
    this.patID,
    this.createdBy,
    this.source,
    this.INID
  });

  factory InvestigationItem.fromJson(Map<String, dynamic> json, [investigationType]) {
    return InvestigationItem(
      type: json['TYPE'],
      id: json['id'],
      hospitalConsultationIDP: json['HospitalConsultationIDP'],
      sDate: json['S_date'],
      patient: json['Patient'],
      doctor: json['Doctor'],
      labStatus: json['labstatus'],
      rDate: json['R_date'],
      opdService: json['OPDService'],
      patID: json['PATID'],
      createdBy: json['CreatedBy'],
      source: investigationType,
      INID: json['INID'],
    );
  }
}

class InvestigationList {
  List<InvestigationItem>? opdInvestigationList;
  List<InvestigationItem>? ipdInvestigationList;

  InvestigationList({
    this.opdInvestigationList,
    this.ipdInvestigationList,
  });

  factory InvestigationList.fromJson(List<dynamic> json) {
    final opdList = (json.first['OPD Investigation List'] as List<dynamic>?)
        ?.map((item) => InvestigationItem.fromJson(item, 'OPD'))
        .toList();
    final ipdList = (json.first['IPD Investigation List'] as List<dynamic>?)
        ?.map((item) => InvestigationItem.fromJson(item, 'IPD'))
        .toList();

    return InvestigationList(
      opdInvestigationList: opdList,
      ipdInvestigationList: ipdList,
    );
  }
}
