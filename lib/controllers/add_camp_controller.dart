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
class AddCampController extends GetxController {
  var isloading = true.obs;
  bool obscureText = true;
  TextEditingController? campNameController;
  TextEditingController? campDetailController;
  TextEditingController? campDateController;
  TextEditingController? campTimeController;
  var effectFromDate = "".obs;

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
    campNameController = TextEditingController();
    campDetailController = TextEditingController();
    campDateController = TextEditingController();
    campTimeController = TextEditingController();

    super.onInit();
  }
  void clear() {
    //clear controllers
    campNameController!.text = "";
    campDetailController!.text = "";
    campDateController!.text = "";
    campTimeController!.text = "";

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
      lastDate: DateTime(DateTime.now().year+5, DateTime.now().month, DateTime.now().day),
    );

    if (date != null) {
      // pickedDate = date;
      var formatter = new DateFormat(DDMMYYYY);
      //String formatted = formatter.format(pickedDate);
      String formatted = formatter.format(date);
      campDateController!.text = formatted;

      //effectFromDate.value = effectFromDateController.text;
      //setState(() {});
    }
  }

  void showTimeSelectionDialog(BuildContext context,String timeSelected) async {
    var pickedTime = TimeOfDay.now();
    if (timeSelected.isNotEmpty) {
      pickedTime = TimeOfDay.now();
    }
    TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: pickedTime,
        builder: (BuildContext? context, Widget? child) {
          return MediaQuery(
              child: child!,
              data:
              MediaQuery.of(context!).copyWith(alwaysUse24HourFormat: true));
        });

    if (time != null) {
      pickedTime = time;
      final now = new DateTime.now();
      var dateOfTime = DateTime(
          now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);

      var formatter = new DateFormat('HH:mm');
      String formatted = formatter.format(dateOfTime);
      campTimeController!.text = formatted;
    }
  }


  void webcallSubmitAddCamp(BuildContext context) async {
    String converDate = "";
    if (campNameController!.text.trim().isEmpty) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please Enter Camp Name"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (campDateController!.text.trim().isEmpty) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please Enter Camp date"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }else{
      var formatter = new DateFormat(YYYYMMDD);
      converDate = formatter.format(new DateFormat(DDMMYYYY).parse(campDateController!.text));
    }
    if (campTimeController!.text.trim().isEmpty) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please Enter Camp time"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    String loginUrl = "${baseURL}createcamp.php";
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
        "CampName" +
        "\"" +
        ":" +
        "\"" +
        campNameController!.text.trim() +
        "\"," +
        "\"" +
        "CampDetails" +
        "\"" +
        ":" +
        "\"" +
        campDetailController!.text +
        "\"," +
        "\"" +
        "CampDate" +
        "\"" +
        ":" +
        "\"" +
        converDate +
        "\"," +
        "\"" +
        "CampTime" +
        "\"" +
        ":" +
        "\"" +
        campTimeController!.text +
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
    pr?.hide();
    if (model.status == "OK") {
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      clear();
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

  void toggle() {
    obscureText = !obscureText;
  }
}
