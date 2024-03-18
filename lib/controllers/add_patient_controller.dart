import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/doctor_patient_profile_upload_model.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';
import 'package:http/http.dart' as http;
import '../app_screens/add_patient_screen_doctor.dart';

class PatientController extends GetxController {
  // Observable variables to hold state
  dynamic jsonObj;
  RxString patientID = "".obs;
  RxBool isLoading = false.obs;
  int _radioValueGender = -1;

  // Update patient ID
  void updatePatientID(String newPatientID) {
    patientID.value = newPatientID;
  }

  // Method to submit data for update
  Future<void> submitDataForUpdate(BuildContext context, File? image) async {
    if (firstNameController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please type First Name"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (lastNameController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please type Last Name"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (_radioValueGender != 0 && _radioValueGender != 1) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Gender"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (dobController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select D.O.B"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    ProgressDialog pr = ProgressDialog(context);
    pr.show();

    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (context) {
    //       return ProgressDialogWithPercentage(
    //         key: progressKey,
    //       );
    //     });

    final multipartRequest = MultipartRequest(
      'POST',
      Uri.parse("${baseURL}doctorAddPatient.php"),
      // onProgress: (int bytes, int total) {
      //   final progress = bytes / total;
      //   progressKey.currentState!.setProgress(progress);
      // },
    );
    //multipartRequest.headers.addAll(headers);
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    debugPrint("City, State, Country");
    debugPrint(selectedCity.idp);
    debugPrint(selectedState.idp);
    debugPrint(selectedCountry.idp);
    String mobNoToValidate = mobileNumberController.text;
    if (mobileNumberController.text.length >= 12) {
      if (mobileNumberController.text.startsWith("+91")) {
        mobNoToValidate = mobileNumberController.text.replaceFirst("+91", "");
      } else if (mobileNumberController.text.startsWith("91")) {
        mobNoToValidate = mobileNumberController.text.replaceFirst("91", "");
      }
    }
    DoctorPatientProfileUploadModel modelPatientProfileUpload =
        DoctorPatientProfileUploadModel(
      patientIDP,
      firstNameController.text.trim(),
      lastNameController.text.trim(),
      mobNoToValidate.trim(),
      emailController.text.trim(),
      dobController.text.trim(),
      addressController.text.trim(),
      selectedCity.idp,
      selectedState.idp,
      selectedCountry.idp,
      marriedController.text.trim(),
      noOfFamilyMembersController.text.trim(),
      yourPositionInFamilyController.text.trim(),
      middleNameController.text.trim(),
      weightValue.toString(),
      heightValue.toString(),
      bloodGroupController.text.trim(),
      "null",
      _radioValueGender == 0
          ? "M"
          : "F", /*emergencyNumberController.text.trim()*/
    );
    String jsonStr;
    jsonStr = modelPatientProfileUpload.toJson();

    debugPrint("Jsonstr - $jsonStr");

    String encodedJSONStr = encodeBase64(jsonStr);
    var response;
    if (image != null && image.lengthSync() > 0) {
      multipartRequest.fields['getjson'] = encodedJSONStr;
      Map<String, String> headers = Map();
      headers['u'] = patientUniqueKey;
      headers['type'] = userType;
      multipartRequest.headers.addAll(headers);
      var imgLength = await image.length();
      multipartRequest.files.add(new http.MultipartFile(
          'image', image.openRead(), imgLength,
          filename: image.path));
      response = await apiHelper.callMultipartApi(multipartRequest);
      print('response $response');
    } else {
      String loginUrl = "${baseURL}doctorAddPatient.php";
      response = await apiHelper.callApiWithHeadersAndBody(
        url: loginUrl,
        //Uri.parse(loginUrl),
        headers: {
          "u": patientUniqueKey,
          "type": userType,
        },
        body: {"getjson": encodedJSONStr},
      );
      print('response $response');
    }
    pr.hide();
    debugPrint("Status code - " + response.statusCode.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    // if (model.status == "OK") {
    //
    // }
    // response.stream.transform(utf8.decoder).listen((value) async {
    //   debugPrint("Response of image upload " + value);
    //   final jsonResponse = json.decode(value);
    //   ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    //   String jArrayStr = decodeBase64(jsonResponse['Data']);
    //   debugPrint("Resonse Upload image ...");
    //   debugPrint(jArrayStr);
    //pr.hide();
    // Navigator.of(context).pop();
    if (model.status == "OK") {
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);
      String patientIDP = jsonData[0]['PatientIDP'].toString();
      jsonObj = jsonData[0];

      return Future.value(patientIDP);
      // if (widget.from == "onlyAddPatient") {
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => EditMyProfileMedicalPatient(
      //                 jsonObj,
      //                 patientIDP,
      //                 from: widget.from,
      //               ))).then((value) {
      //     Navigator.of(context).pop();
      //   });
      // } else {
      //   if (patientIDPSelected == "") {
      //     Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) => EditMyProfileMedicalPatient(
      //                   jsonObj,
      //                   patientIDP,
      //                   from: "goToOPD",
      //                 ))).then((value) {
      //       Navigator.of(context).pop();
      //     });
      //   } else {
      //     Navigator.push(context, MaterialPageRoute(builder: (context) {
      //       return SelectOPDProceduresScreen(patientIDP, "", "new",
      //           campID: widget.campID ?? '');
      //     })).then((value) {
      //       Navigator.of(context).pop();
      //     });
      //   }
      /*Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return MyPatientsScreen();
          })).then((value) {
            Navigator.of(context).pop();
          });*/
      // }
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    ;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
