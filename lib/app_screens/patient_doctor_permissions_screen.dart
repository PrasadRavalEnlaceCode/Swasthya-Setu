import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silvertouch/controllers/patient_doctor_permissions_controller.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import '../utils/color.dart';

class PatientDoctorPermissionScreen extends StatelessWidget {
  final String? doctorIDP,
      healthRecordsDisplayStatus,
      consultationDisplayStatus;

  String? defaultHealthRecordsDisplayStatus, defaultConsultationDisplayStatus;

  PatientDoctorPermissionScreen(this.doctorIDP, this.healthRecordsDisplayStatus,
      this.consultationDisplayStatus);

  bool firstTime = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    PatientDoctorPermissionsController patientDoctorPermissionController;
    patientDoctorPermissionController =
        Get.put(PatientDoctorPermissionsController());
    if (!firstTime) {
      debugPrint("records and consultation");
      debugPrint("records $healthRecordsDisplayStatus");
      debugPrint("consultation $consultationDisplayStatus");
      patientDoctorPermissionController.shareMyRecords.value =
          getBoolValueFromString(healthRecordsDisplayStatus!);
      patientDoctorPermissionController.shareMyConsultationHistory.value =
          getBoolValueFromString(consultationDisplayStatus!);
      defaultHealthRecordsDisplayStatus = healthRecordsDisplayStatus;
      defaultConsultationDisplayStatus = consultationDisplayStatus;
      firstTime = true;
    }

    return Builder(
      builder: (BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Permissions"),
              backgroundColor: Color(0xFFFFFFFF),
              iconTheme: IconThemeData(
                  color: Colorsblack,
                  size: SizeConfig.blockSizeVertical! * 2.2),
              toolbarTextStyle: TextTheme(
                      titleMedium: TextStyle(
                          color: Colorsblack,
                          fontFamily: "Ubuntu",
                          fontSize: SizeConfig.blockSizeVertical! * 2.5))
                  .bodyMedium,
              titleTextStyle: TextTheme(
                      titleMedium: TextStyle(
                          color: Colorsblack,
                          fontFamily: "Ubuntu",
                          fontSize: SizeConfig.blockSizeVertical! * 2.5))
                  .titleLarge,
              /*actions: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal * 3.0),
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        submitPermissions(
                            context, patientDoctorPermissionController);
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                        ),
                      ),
                    ),
                  ),
                )
              ],*/
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
                vertical: SizeConfig.blockSizeHorizontal! * 1.0,
              ),
              child: Obx(() => ListView(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            "Share My Records",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Switch(
                                  value: patientDoctorPermissionController
                                      .shareMyRecords.value,
                                  onChanged: (isChecked) {
                                    patientDoctorPermissionController
                                        .shareMyRecords.value = isChecked;
                                  }),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical! * 0.5,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            "Share My Consultation History",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Switch(
                                  value: patientDoctorPermissionController
                                      .shareMyConsultationHistory.value,
                                  onChanged: (isChecked) {
                                    patientDoctorPermissionController
                                        .shareMyConsultationHistory
                                        .value = isChecked;
                                  }),
                            ),
                          ),
                        ],
                      ),
                      patientDoctorPermissionController.shareMyRecords.value !=
                                  getBoolValueFromString(
                                      healthRecordsDisplayStatus!) ||
                              patientDoctorPermissionController
                                      .shareMyConsultationHistory.value !=
                                  getBoolValueFromString(
                                      consultationDisplayStatus!)
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    SizeConfig.blockSizeHorizontal! * 3.0,
                              ),
                              child: MaterialButton(
                                onPressed: () {
                                  submitPermissions(context,
                                      patientDoctorPermissionController);
                                },
                                minWidth: double.maxFinite,
                                color: Colors.green,
                                child: Text(
                                  "Save",
                                  style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  )),
            ));
      },
    );
  }

  void submitPermissions(
      BuildContext context,
      PatientDoctorPermissionsController
          patientDoctorPermissionController) async {
    String loginUrl = "${baseURL}patientRecordsPermission.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        doctorIDP! +
        "\"" +
        "," +
        "\"" +
        "HealthRecordsDisplayStatus" +
        "\"" +
        ":" +
        "\"" +
        getStrValueFromBool(patientDoctorPermissionController.shareMyRecords) +
        "\"" +
        "," +
        "\"" +
        "ConsultationDisplayStatus" +
        "\"" +
        ":" +
        "\"" +
        getStrValueFromBool(
            patientDoctorPermissionController.shareMyConsultationHistory) +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: loginUrl,
      //Uri.parse(loginUrl),
      headers: {
        "u": patientUniqueKey,
        "type": userType,
      },
      body: {"getjson": encodedJSONStr},
    );
    //var resBody = json.decode(response.body);
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();

    if (model.status == "OK") {
      /*final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
      Get.snackbar(
        "Success",
        model.message!,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Future.delayed(Duration(seconds: 1), () {
        Get.back();
        Navigator.of(context).pop(1);
      });
    } else {
      Get.snackbar(
        "Error",
        model.message!,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    //var base64str =
    return base64.encode(bytes);
    //= Base64Encoder().convert()
  }

  String decodeBase64(String text) {
    //var bytes = utf8.encode(text);
    //var base64str =
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
    //= Base64Encoder().convert()
  }

  String getStrValueFromBool(RxBool val) {
    if (val.value) return "1";
    return "0";
  }

  bool getBoolValueFromString(String val) {
    if (val == "1") return true;
    return false;
  }
}
