import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silvertouch/podo/model_health_doc.dart';

import '../app_screens/add_patient_screen.dart';
import '../global/utils.dart';
import '../podo/response_main_model.dart';
import '../utils/progress_dialog.dart';

class CertificateController extends GetxController {
  TextEditingController? certFor, certRemarks;

  @override
  void onInit() {
    certFor = TextEditingController(text: '');
    certRemarks = TextEditingController(text: '');
    super.onInit();
  }

  submitCertificate(var idp, patientIDP, certId, BuildContext context) async {
    String loginUrl = "${baseURL}doctorAddCertificate.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String doctorIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();

    String jsonStr = "{" +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        doctorIDP +
        "\"," +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"," +
        "\"" +
        "certifcatefor" +
        "\"" +
        ":" +
        "\"" +
        certFor!.text +
        "\"," +
        "\"" +
        "Remarks" +
        "\"" +
        ":" +
        "\"" +
        certRemarks!.text +
        "\"," +
        "\"" +
        "HospitalConsultationIDP" +
        "\"" +
        ":" +
        "\"" +
        idp +
        "\"," +
        "\"" +
        "CertificateTypeIDP" +
        "\"" +
        ":" +
        "\"" +
        certId.toString() +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);

    var response =
        await apiHelper.callApiWithHeadersAndBody(url: loginUrl, headers: {
      "u": patientUniqueKey,
      "type": userType,
    }, body: {
      "getjson": encodedJSONStr
    });
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    print("Certificate $jsonResponse");
    if (model.status == "OK") {
      certFor!.clear();
      certRemarks!.clear();
      Get.back();
    }
  }

  Future<String> viewCertificate(
      patientIDP, certId, BuildContext context) async {
    String loginUrl = "${baseURL}certificatepdfdoc.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String doctorIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();

    String jsonStr = "{" +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        doctorIDP +
        "\"," +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"," +
        "\"" +
        "CertificateDetailsIDP" +
        "\"" +
        ":" +
        "\"" +
        certId +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);

    var response =
        await apiHelper.callApiWithHeadersAndBody(url: loginUrl, headers: {
      "u": patientUniqueKey,
      "type": userType,
    }, body: {
      "getjson": encodedJSONStr
    });
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    print("Certificate $jsonResponse");
    if (model.status == "OK") {
      String encodedFileName = model.data!;
      String strData = decodeBase64(encodedFileName);
      final jsonData = json.decode(strData);
      return jsonData[0]['FileName'].toString();
      // String downloadPdfUrl = "$certificateUrl$fileName";
      // downloadAndOpenTheFile(downloadPdfUrl, fileName);
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr!.hide();
      return '';
    }
  }

  Future submitHealthDoc(
      patientIDP, ModelHealthDoc certId, BuildContext context) async {
    String loginUrl = "${baseURL}doctortoPatientHealthInfoDocument.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String doctorIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();

    String jsonStr = "{" +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        doctorIDP +
        "\"," +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"," +
        "\"" +
        "HealthInfoDocumentIDP" +
        "\"" +
        ":" +
        "\"" +
        certId.healthInfoDocumentIDP.toString() +
        "\"," +
        "\"" +
        "FileName" +
        "\"" +
        ":" +
        "\"" +
        certId.fileName! +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);

    var response =
        await apiHelper.callApiWithHeadersAndBody(url: loginUrl, headers: {
      "u": patientUniqueKey,
      "type": userType,
    }, body: {
      "getjson": encodedJSONStr
    });
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    print("Certificate $jsonResponse");
    final snackBar = SnackBar(
      backgroundColor: Colors.green,
      content: Text(model.message!),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future submitHealthVideo(
      patientIDP, ModelHealthDoc certId, BuildContext context) async {
    String loginUrl = "${baseURL}doctorSentSingleVideoNotification.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String doctorIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();

    String jsonStr = "{" +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        doctorIDP +
        "\"," +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"," +
        "\"" +
        "SendType" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"," +
        "\"" +
        "VideoID" +
        "\"" +
        ":" +
        "\"" +
        certId.healthInfoDocumentIDP.toString() +
        "\"," +
        "\"" +
        "VideoTitle" +
        "\"" +
        ":" +
        "\"" +
        certId.fileName! +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);

    var response =
        await apiHelper.callApiWithHeadersAndBody(url: loginUrl, headers: {
      "u": patientUniqueKey,
      "type": userType,
    }, body: {
      "getjson": encodedJSONStr
    });
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    print("Certificate $jsonResponse");
    final snackBar = SnackBar(
      backgroundColor: Colors.green,
      content: Text(model.message!),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
