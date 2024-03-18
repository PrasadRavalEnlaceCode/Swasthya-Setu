class PMRData {
  final String pmr;
  final String quantity;
  final String remarks;

  PMRData({
    required this.pmr,
    required this.quantity,
    required this.remarks,
  });

  factory PMRData.fromJson(Map<String, dynamic> json) {
    return PMRData(
      pmr: json['pmr'],
      quantity: json['quantity'],
      remarks: json['remarks'],
    );
  }
}