class DoctorInvoice {
  int? serialNumber; // New field for serial number
  String? doctorPayoutInvoiceIDP;
  String? invoiceNumber;
  String? payoutAmount;
  String? invoiceDate;
  String? doctorIDF;
  String? doctorName;
  String? categoryName;
  String? directInvoiceStatus;
  String? invoiceStatus;
  String? type;
  String? source; // New field to store the source

  DoctorInvoice({
    this.serialNumber, // Include serial number in the constructor
    required this.doctorPayoutInvoiceIDP,
    required this.invoiceNumber,
    required this.payoutAmount,
    required this.invoiceDate,
    required this.doctorIDF,
    required this.doctorName,
    required this.categoryName,
    required this.directInvoiceStatus,
    required this.invoiceStatus,
    required this.type,
    required this.source,
  });

  factory DoctorInvoice.fromJson(Map<String, dynamic> json, {required String source}) {
    return DoctorInvoice(
      doctorPayoutInvoiceIDP: json['DoctorPayoutInvoiceIDP'],
      invoiceNumber: json['InvoiceNumber'],
      payoutAmount: json['PayoutAmount'],
      invoiceDate: json['invoicedt'],
      doctorIDF: json['DoctorIDF'],
      doctorName: json['DoctorName'],
      categoryName: json['CategoryName'],
      directInvoiceStatus: json['DirectInvoiceStatus'],
      invoiceStatus: json['InvoiceStatus'],
      type: json['Type'],
      source: source,
    );
  }
}

class InvoiceList {
  List<DoctorInvoice>? pendingInvoices;
  List<DoctorInvoice>? paidInvoices;

  InvoiceList({
    this.pendingInvoices,
    this.paidInvoices,
  });

  factory InvoiceList.fromJson(List<dynamic> json) {
    final pendingList = (json.first['Pending Invoice'] as List<dynamic>?)
        ?.map((item) => DoctorInvoice.fromJson(item, source: 'Pending Invoice'))
        .toList();
    final paidList = (json.first['Paid Invoice'] as List<dynamic>?)
        ?.map((item) => DoctorInvoice.fromJson(item, source: 'Paid Invoice'))
        .toList();

    return InvoiceList(
      pendingInvoices: pendingList,
      paidInvoices: paidList,
    );
  }
}