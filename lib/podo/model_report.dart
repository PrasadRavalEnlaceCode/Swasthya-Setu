/*
"ReportTagName": jo['ReportTagName'],
"ReportDate": jo['ReportDate'],
"ReportTime": jo['ReportTime'],
"ReportImage": jo['ReportImage'],
"PatientReportIDP": jo["PatientReportIDP"]*/

class ModelReport {
  String reportTagName,
      reportDate,
      reportTime,
      reportImage,
      patientReportIDP,
      categoryName;

  ModelReport(this.reportTagName, this.reportDate, this.reportTime,
      this.reportImage, this.patientReportIDP, this.categoryName);
}
