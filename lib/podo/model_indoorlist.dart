
class PatientDetails {
  String? firstName;
  String? lastName;
  String? doctorFirstName;
  String? doctorLastName;
  String? doctorMiddleName;
  String? patientIndoorIDP;
  String? patientIDF;
  String? patientCategoryName;
  String? doctorIDF;
  String? dischargeAllowStatus;
  String? admitDt;
  String? planOfManagement;
  String? summaryStatus;
  String? invoiceNumber;
  String? paymentMode;
  String? invoiceAmount;
  String? paymentNarration;
  String? generalDiscount;
  String? amount;
  String? reffDoctorName;
  String? allowFlag;
  String? refferPatient;
  String? roomBed;
  String? roomNumber;
  String? roomBedIDP;
  String? roomMasterIDP;

  PatientDetails({
    this.firstName,
    this.lastName,
    this.doctorFirstName,
    this.doctorLastName,
    this.doctorMiddleName,
    this.patientIndoorIDP,
    this.patientIDF,
    this.patientCategoryName,
    this.doctorIDF,
    this.dischargeAllowStatus,
    this.admitDt,
    this.planOfManagement,
    this.summaryStatus,
    this.invoiceNumber,
    this.paymentMode,
    this.invoiceAmount,
    this.paymentNarration,
    this.generalDiscount,
    this.amount,
    this.reffDoctorName,
    this.allowFlag,
    this.refferPatient,
    this.roomBed,
    this.roomNumber,
    this.roomBedIDP,
    this.roomMasterIDP,
  });

  factory PatientDetails.fromJson(Map<String, dynamic> json) {
    return PatientDetails(
      firstName: json['Firstname'],
      lastName: json['LastName'],
      doctorFirstName: json['doctorfirstname'],
      doctorLastName: json['doctorlastname'],
      doctorMiddleName: json['doctormiddlename'],
      patientIndoorIDP: json['PatientIndoorIDP'],
      patientIDF: json['PatientIDF'],
      patientCategoryName: json['PatientCategoryName'],
      doctorIDF: json['DoctorIDF'],
      dischargeAllowStatus: json['DischargeAllowStatus'],
      admitDt: json['AdmitDt'],
      planOfManagement: json['PlanofManagement'],
      summaryStatus: json['SummaryStatus'],
      invoiceNumber: json['InvoiceNumber'],
      paymentMode: json['PaymentMode'],
      invoiceAmount: json['InvoiceAmount'],
      paymentNarration: json['PaymentNarration'],
      generalDiscount: json['GeneralDiscount'],
      amount: json['amount'],
      reffDoctorName: json['ReffDoctorName'],
      allowFlag: json['allowflag'],
      refferPatient: json['RefferPatient'],
      roomBed: json['RoomBed'],
      roomNumber: json['RoomNumber'],
      roomBedIDP: json['RoomBedIDP'],
      roomMasterIDP: json['RoomMasterIDP'],
    );
  }
}

class RoomOccupied {
  List<PatientDetails>? nullList;
  List<PatientDetails>? occupiedList;

  RoomOccupied({this.nullList, this.occupiedList});

  factory RoomOccupied.fromJson(Map<String, dynamic> json) {
    final nullList = (json['Room Occupied NUll List'] as List<dynamic>?)
        ?.map((item) => PatientDetails.fromJson(item))
        .toList();
    final occupiedList = (json['Room Occupied List'] as List<dynamic>?)
        ?.map((item) => PatientDetails.fromJson(item))
        .toList();

    return RoomOccupied(
      nullList: nullList,
      occupiedList: occupiedList,
    );
  }
}