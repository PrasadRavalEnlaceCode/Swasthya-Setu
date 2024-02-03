import 'package:sms_autofill/sms_autofill.dart';

class SMSListener implements CodeAutoFill {
  Function onCodeUpdated;

  SMSListener(this.onCodeUpdated);

  @override
  String? code;

  @override
  Future<void> cancel() {
    return null!;
    //throw UnimplementedError();
  }

  @override
  void codeUpdated() {
    this.onCodeUpdated();
  }

/*  @override
  void listenForCode() {}*/

  @override
  Future<void> unregisterListener() {
    return null!;
    //throw UnimplementedError();
  }

  @override
  void listenForCode({String? smsCodeRegexPattern}) {
    // TODO: implement listenForCode
  }
}
