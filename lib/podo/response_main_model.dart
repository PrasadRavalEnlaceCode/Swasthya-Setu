class ResponseModel {
  String? status,
      message,
      serverDateTime,
      apiVersion,
      apiVersionIos,
      logoutVersion,
      data;

  ResponseModel(
      {
      /*this.studentId,
    this.studentName,
    this.studentScores*/
      this.status,
      this.message,
      this.serverDateTime,
      this.apiVersion,
      this.apiVersionIos,
      this.logoutVersion,
      this.data});

  factory ResponseModel.fromJSON(Map<String, dynamic> parsedJson) {
    return ResponseModel(
        status: parsedJson['Status'],
        message: parsedJson['Message'],
        serverDateTime: parsedJson['ServerDateTime'],
        apiVersion: parsedJson['apiversion'],
        apiVersionIos: parsedJson['apiversionios'],
        logoutVersion: parsedJson['logoutversion'],
        data: parsedJson['Data']);
  }
}
