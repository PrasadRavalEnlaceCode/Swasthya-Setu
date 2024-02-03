import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../app_screens/add_patient_screen.dart';
import '../global/utils.dart';
import '../podo/response_main_model.dart';
import '../utils/progress_dialog.dart';
import '../utils/string_resource.dart';

///
class MedicalCertificateController extends GetxController {
  var isloading = true.obs;
  bool obscureText = true;
  TextEditingController? sufferingFromController;
  TextEditingController? absenceDaysController;
  TextEditingController? effectFromDateController;
  TextEditingController? treatedFromDateController;
  TextEditingController? treatedToDateController;
  TextEditingController? joinDutyDateController;
  TextEditingController? identificationController;
  TextEditingController? remarksController;
  var effectFromDate = "".obs;
  var treatedFromDate = "".obs;

  //define the repository for prefrances
  var isvalid = false.obs;
  GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  void onClose() {
    // TODO: implement onClose
    clear();
    super.onClose();
  }

  @override
  void onInit() {
    //initalize controllers
    //sufferingFromController = TextEditingController().obs as TextEditingController;
    sufferingFromController = TextEditingController();
    absenceDaysController = TextEditingController();
    effectFromDateController = TextEditingController();
    treatedFromDateController = TextEditingController();
    treatedToDateController = TextEditingController();
    joinDutyDateController = TextEditingController();
    identificationController = TextEditingController();
    remarksController = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    key = null!;

    super.dispose();
  }

  void showDateSelectionDialog(BuildContext context, String dateSelected, String dateType) async {
    DateTime pickedDate;
    if (dateSelected.isNotEmpty) {
      pickedDate = new DateFormat(DDMMYYYY).parse(dateSelected);
    } else {
      pickedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    }
    DateTime firstDate = DateTime.now().subtract(Duration(days: 365 * 100));
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: pickedDate,
      firstDate: firstDate,
      lastDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );

    if (date != null) {
      // pickedDate = date;
      var formatter = new DateFormat(DDMMYYYY);
      //String formatted = formatter.format(pickedDate);
      String formatted = formatter.format(date);

      if (str_effect_fromDate == dateType) {
        effectFromDateController!.text = formatted;
      } else if (str_treated_fromDate == dateType) {
        treatedFromDateController!.text = formatted;
      } else if (str_treated_toDate == dateType) {
        treatedToDateController!.text = formatted;
      } else if (str_join_dutyDate == dateType) {
        joinDutyDateController!.text = formatted;
      }
      //effectFromDate.value = effectFromDateController.text;
      //setState(() {});
    }
  }

  void webcallSubmitMedicalCertificate(var idp, patientIDP, certId,BuildContext context) async {
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
        "sufferfrom" +
        "\"" +
        ":" +
        "\"" +
        sufferingFromController!.text +
        "\"," +
        "\"" +
        "absencedays" +
        "\"" +
        ":" +
        "\"" +
        absenceDaysController!.text +
        "\"," +
        "\"" +
        "effectdate" +
        "\"" +
        ":" +
        "\"" +
        effectFromDateController!.text +
        "\"," +
        "\"" +
        "treatedfromdate" +
        "\"" +
        ":" +
        "\"" +
        treatedFromDateController!.text +
        "\"," +
        "\"" +
        "treatedtodate" +
        "\"" +
        ":" +
        "\"" +
        treatedToDateController!.text +
        "\"," +
        "\"" +
        "joindutydate" +
        "\"" +
        ":" +
        "\"" +
        joinDutyDateController!.text +
        "\"," +
        "\"" +
        "identificationmark" +
        "\"" +
        ":" +
        "\"" +
        identificationController!.text +
        "\"," +
        "\"" +
        "Medicalremarks" +
        "\"" +
        ":" +
        "\"" +
        remarksController!.text +
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
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(seconds: 1), () {
        //Navigator.of(context).pop();
        Get.back();
      });
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void clear() {
    //clear controllers
    sufferingFromController!.text = "";
    absenceDaysController!.text = "";
    effectFromDateController!.text = "";
    treatedFromDateController!.text = "";
    treatedToDateController!.text = "";
    joinDutyDateController!.text = "";
    identificationController!.text = "";
    remarksController!.text = "";
  }

  void toggle() {
    obscureText = !obscureText;
  }

  ///API call to login user
}
