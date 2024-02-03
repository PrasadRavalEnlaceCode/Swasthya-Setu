import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:swasthyasetu/controllers/slider_controller.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/dropdown_item.dart';
import 'package:swasthyasetu/podo/model_profile_patient.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/ultimate_slider.dart';

import '../utils/color.dart';
import '../utils/progress_dialog.dart';

FocusNode focus = FocusNode();
TextEditingController bpSystolicController = new TextEditingController();
TextEditingController bpDiastolicController = new TextEditingController();
TextEditingController fbsController = new TextEditingController();
TextEditingController rbsController = new TextEditingController();
TextEditingController ppbsController = new TextEditingController();
TextEditingController temperatureController = new TextEditingController();
TextEditingController pulseController = new TextEditingController();
TextEditingController spo2Controller = new TextEditingController();

TextEditingController tshController = new TextEditingController();
TextEditingController t3Controller = new TextEditingController();
TextEditingController t4Controller = new TextEditingController();
TextEditingController freeT3Controller = new TextEditingController();
TextEditingController freeT4Controller = new TextEditingController();

TextEditingController entryDateController = new TextEditingController();
TextEditingController entryTimeController = new TextEditingController();

var pickedDate = DateTime.now();
var pickedTime = TimeOfDay.now();

double pulseValue = 80,
    bpSystolicValue = 100,
    bpDiastolicValue = 70,
    spo2Value = 97,
    fbsValue = 90,
    ppbsValue = 150,
    rbsValue = 100,
    hba1cValue = 7,
    rrValue = 14,
    weightValue = 0,
    heightValue = 0,
    exerciseValue = 0,
    sleepValue = 0,
    waistValue = 0,
    hipValue = 0;

int walkingValue = 0, walkingStepsValue = 0;

double tshValue = 0,
    t3Value = 20,
    t4Value = 0,
    freeT3Value = 0,
    freeT4Value = 0;

double tempValue = 98;

double bmi = 0;

double defaultTemperatureValue = 98,
    defaultPulseValue = 80,
    defaultSPO2Value = 97,
    defaultRRValue = 14,
    defaultSystolicValue = 100,
    defaultDiastolicValue = 70,
    defaultFBSValue = 90,
    defaultPPBSValue = 150,
    defaultRBSValue = 100,
    defaultHb1Value = 7;

bool isCheckedPulse = false,
    isCheckedBpSystolic = false,
    isCheckedBpDiastolic = false,
    isCheckedSpo2 = false,
    isCheckedFbs = false,
    isCheckedPpbs = false,
    isCheckedRbs = false,
    isCheckedHba1c = false,
    isCheckedRr = false,
    isCheckedWeight = false,
    isCheckedHeight = false,
    isCheckedExercise = false,
    isCheckedWalking = false,
    isCheckedWaist = false,
    isCheckedHip = false,
    isCheckedTemp = false,
    isCheckedBmi = false,
    isCheckedTSH = false,
    isCheckedT3 = false,
    isCheckedT4 = false,
    isCheckedFreeT3 = false,
    isCheckedFreeT4 = false,
    isCheckedSleep = true;

String heightInFeet = "0 Foot 0 Inches";

String previousTextTSH = "",
    previousTextT3 = "",
    previousTextT4 = "",
    previousTextFreeT3 = "",
    previousTextFreeT4 = "";

//RulerPickerController _rulerPickerController = RulerPickerController();

class AddVitalsScreen extends StatefulWidget {
  String imgUrl = "";
  var image;
  String? patientIDP;
  String? vitalIDP, vitalIDP2, vitalIDP3, vitalIDP4, vitalIDP5;
  PatientProfileModel? patientProfileModel;
  List<DropDownItem> listCountries = [];
  List<DropDownItem> listStates = [];
  List<DropDownItem> listCities = [];

  DropDownItem selectedCountry = DropDownItem("", "");
  DropDownItem selectedState = DropDownItem("", "");
  DropDownItem selectedCity = DropDownItem("", "");
  String vitalGroupIDP = "";

  AddVitalsScreen(String patientIDP, String vitalIDP) {
    this.patientIDP = patientIDP;
    this.vitalIDP = vitalIDP;
    this.vitalGroupIDP = vitalIDP;
    print('vitalGroupIDP $vitalGroupIDP');
  }

  @override
  State<StatefulWidget> createState() {
    return AddVitalsScreenState();
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

class AddVitalsScreenState extends State<AddVitalsScreen> {
  String title = "";
  ProgressDialog? pr;
  List<String> listVitalIDPs = [];
  int vitalsAPICount = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    bpSystolicController.clear();
    bpDiastolicController.clear();
    fbsController.clear();
    rbsController.clear();
    ppbsController.clear();
    temperatureController.clear();
    pulseController.clear();
    spo2Controller.clear();
    entryDateController.clear();
    entryTimeController.clear();

    //focus = FocusNode();

    // tshController = new TextEditingController();
    // t3Controller = new TextEditingController();
    // t4Controller = new TextEditingController();
    // freeT3Controller = new TextEditingController();
    // freeT4Controller = new TextEditingController();
    //
    // entryDateController = new TextEditingController();
    // entryTimeController = new TextEditingController();

    pickedDate = DateTime.now();
    pickedTime = TimeOfDay.now();

    // pulseValue = 80;
    // bpSystolicValue = 100;
    // bpDiastolicValue = 70;
    // tempValue = 98;
    // spo2Value = 97;
    // fbsValue = 90;
    // ppbsValue = 150;
    // rbsValue = 100;
    // hba1cValue = 7;
    // rrValue = 14;
    // weightValue = 0;
    // heightValue = 0;
    // exerciseValue = 0;
    // walkingValue = 0;
    // walkingStepsValue = 0;
    // sleepValue = 0;
    // tshValue = 0;
    // t3Value = 20;
    // t4Value = 0;
    // freeT3Value = 0;
    // freeT4Value = 0;
    // waistValue = 0;
    // hipValue = 0;
    //
    // isCheckedPulse = false;
    // isCheckedBpSystolic = false;
    // isCheckedBpDiastolic = false;
    // isCheckedSpo2 = false;
    // isCheckedFbs = false;
    // isCheckedPpbs = false;
    // isCheckedRbs = false;
    // isCheckedHba1c = false;
    // isCheckedRr = false;
    // isCheckedWeight = false;
    // isCheckedHeight = false;
    // isCheckedExercise = false;
    // isCheckedWalking = false;
    // isCheckedWaist = false;
    // isCheckedHip = false;
    // isCheckedTemp = false;
    // isCheckedBmi = false;
    // isCheckedTSH = false;
    // isCheckedT3 = false;
    // isCheckedT4 = false;
    // isCheckedFreeT3 = false;
    // isCheckedFreeT4 = false;
    // isCheckedSleep = true;

    // bmi = 0;
    // heightInFeet = "0 Foot 0 Inches";
    // previousTextTSH = "";
    // previousTextT3 = "";
    // previousTextT4 = "";
    // previousTextFreeT3 = "";
    // previousTextFreeT4 = "";
    //
    // tshController = new TextEditingController();
    // t3Controller = new TextEditingController();
    // t4Controller = new TextEditingController();
    // freeT3Controller = new TextEditingController();
    // freeT4Controller = new TextEditingController();
    switch (widget.vitalGroupIDP) {
      case "1":
        listVitalIDPs.add("1");
        listVitalIDPs.add("2");
        title = "Blood Pressure";
        break;
      case "2":
        listVitalIDPs.add("3");
        listVitalIDPs.add("4");
        listVitalIDPs.add("5");
        listVitalIDPs.add("10");
        title = "Vitals";
        break;
      case "3":
        listVitalIDPs.add("6");
        listVitalIDPs.add("7");
        listVitalIDPs.add("8");
        listVitalIDPs.add("9");
        title = "Sugar";
        break;
      case "4":
        listVitalIDPs.add("11");
        listVitalIDPs.add("21");
        listVitalIDPs.add("12");
        title = "Weight Measurement";
        getPatientProfileDetails();
        break;
      case "5":
        listVitalIDPs.add("13");
        listVitalIDPs.add("14");
        listVitalIDPs.add("23");
        listVitalIDPs.add("24");
        title = "Health Meter";
        break;
      case "6":
        listVitalIDPs.add("15");
        listVitalIDPs.add("16");
        listVitalIDPs.add("17");
        listVitalIDPs.add("18");
        listVitalIDPs.add("19");
        title = "Thyroid";
        break;
      case "7":
        listVitalIDPs.add("20");
        title = "Water Intake";
        break;
      case "8":
        listVitalIDPs.add("22");
        title = "Sleep";
        break;
    }

    pickedDate = DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(pickedDate);
    entryDateController = TextEditingController(text: formatted);

    final now = new DateTime.now();
    var dateOfTime =
    DateTime(now.year, now.month, now.day, now.hour, now.minute);

    pickedTime = TimeOfDay.now();

    var formatterTime = new DateFormat('HH:mm');
    String formattedTime = formatterTime.format(dateOfTime);
    debugPrint("formatted time");
    debugPrint(formattedTime);
    entryTimeController = TextEditingController(text: formattedTime);
    setState(() {});
  }

  Future<void> submitVitalDetails(BuildContext context, String vitalIDP,
      int vitalSerialNo, int noOfCheckedVitalsInGroup) async {
    if (entryDateController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Entry Date"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (entryTimeController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Temperature is compulsory"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    /*if (widget.vitalGroupIDP == "6") {
      if (tshController.text == "") {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please enter TSH"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } else if (t3Controller.text == "") {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please enter T3"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } else if (double.parse(t3Controller.text) < 20 ||
          double.parse(t3Controller.text) > 500) {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("T3 must be between 20 to 500"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } else if (t4Controller.text == "") {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please enter T4"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } else if (double.parse(t4Controller.text) < 0 ||
          double.parse(t4Controller.text) > 25) {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("T4 must be between 0 to 25"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } else if (freeT3Controller.text == "") {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please enter Free T3"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } else if (double.parse(freeT3Controller.text) < 0 ||
          double.parse(freeT3Controller.text) > 25) {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("Free T3 must be between 0 to 25"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } else if (freeT4Controller.text == "") {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please enter Free T4"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } else if (double.parse(freeT4Controller.text) < 0 ||
          double.parse(freeT4Controller.text) > 25) {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("Free T4 must be between 0 to 25"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }*/

    String loginUrl = "${baseURL}patientVitalSubmit.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);

    double vitalValue = getVitalValue(vitalIDP);
    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP! +
        "\"" +
        "," +
        "\"" +
        "VitalEntryDate" +
        "\"" +
        ":" +
        "\"" +
        entryDateController.text +
        "\"" +
        "," +
        "\"" +
        "VitalEntryTime" +
        "\"" +
        ":" +
        "\"" +
        entryTimeController.text +
        "\"" +
        "," +
        "\"" +
        "VitalIDP" +
        "\"" +
        ":" +
        "\"" +
        vitalIDP +
        "\"" +
        "," +
        "\"" +
        "VitalValue" +
        "\"" +
        ":" +
        "\"" +
        vitalValue.toString() +
        "\"" +
        "}";

    debugPrint("Vital value");

    debugPrint(vitalValue.toString());

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

    vitalsAPICount++;

    //var resBody = json.decode(response.body);
    debugPrint(response.body.toString());

    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);

    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      if (vitalsAPICount == noOfCheckedVitalsInGroup &&
          listVitalIDPs.length > 0) {
        pr?.hide();
        final snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text(messageAccordingToScreen()!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.of(context).pop();
        });
      }
      /*if (widget.vitalIDP != "1" &&
          widget.vitalIDP != "3" &&
          widget.vitalIDP != "11" &&
          widget.vitalIDP != "13" &&
          widget.vitalIDP != "15") {
        pr.hide();
        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.of(context).pop();
        });
      } else
        submitVitalDetails2(context);
      setState(() {});*/
    }
    if (widget.vitalIDP != "1" && widget.vitalIDP != "3") pr?.hide();
  }

  Future<String> getPatientProfileDetails() async {
    final String urlFetchPatientProfileDetails =
        "${baseURL}patientProfileData.php";
    ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr.show();
    });

    try {
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String jsonStr = "{" +
          "\"" +
          "PatientIDP" +
          "\"" +
          ":" +
          "\"" +
          widget.patientIDP! +
          "\"" +
          "}";

      debugPrint(jsonStr);

      String encodedJSONStr = encodeBase64(jsonStr);
      //listIcon = new List();
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: urlFetchPatientProfileDetails,
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
      pr.hide();
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array : " + strData);
        final jsonData = json.decode(strData);
        heightValue = double.parse(jsonData[0]['Height']);
        weightValue = double.parse(jsonData[0]['Wieght']);
        bmi = weightValue / (pow((heightValue / 100), 2));
        debugPrint("Got height value - $heightValue");
        debugPrint("Got weight value - $weightValue");
        cmToFeet();
        if (heightValue != 0) isCheckedHeight = true;
        if (weightValue != 0) isCheckedWeight = true;
        setState(() {});
      } else {
        /*final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(model.message),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
      }
    } catch (exception) {}
    return 'success';
  }

  void cmToFeet() {
    double heightInFeetWithDecimal = heightValue * 0.0328084;
    int intHeightInFeet = heightInFeetWithDecimal.toInt();
    double remainingDecimals = heightInFeetWithDecimal - intHeightInFeet;
    int intHeightInInches = (remainingDecimals * 12).round().toInt();
    if (intHeightInInches == 12) {
      intHeightInFeet++;
      intHeightInInches = 0;
    }
    heightInFeet = "$intHeightInFeet Foot $intHeightInInches Inches";
  }

  Future<void> submitVitalDetails4(BuildContext context) async {
    if (entryDateController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Entry Date"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (entryTimeController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Entry Time"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    String loginUrl = "${baseURL}patientVitalSubmit.php";

    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);

    double vitalValue = getVitalValue(widget.vitalIDP4!);

    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP! +
        "\"" +
        "," +
        "\"" +
        "VitalEntryDate" +
        "\"" +
        ":" +
        "\"" +
        entryDateController.text +
        "\"" +
        "," +
        "\"" +
        "VitalEntryTime" +
        "\"" +
        ":" +
        "\"" +
        entryTimeController.text +
        "\"" +
        "," +
        "\"" +
        "VitalIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.vitalIDP4! +
        "\"" +
        "," +
        "\"" +
        "VitalValue" +
        "\"" +
        ":" +
        "\"" +
        vitalValue.toString() +
        "\"" +
        "}";

    debugPrint("Vital value");
    debugPrint(vitalValue.toString());
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
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr?.hide();
      if (widget.vitalGroupIDP == "6") {
        submitVitalDetails5(context);
      } else {
        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.of(context).pop();
        });
      }
      setState(() {});
    }
  }

  Future<void> submitVitalDetails5(BuildContext context) async {
    if (entryDateController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Entry Date"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (entryTimeController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Entry Time"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    String loginUrl = "${baseURL}patientVitalSubmit.php";

    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);

    double vitalValue = getVitalValue(widget.vitalIDP5!);

    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP! +
        "\"" +
        "," +
        "\"" +
        "VitalEntryDate" +
        "\"" +
        ":" +
        "\"" +
        entryDateController.text +
        "\"" +
        "," +
        "\"" +
        "VitalEntryTime" +
        "\"" +
        ":" +
        "\"" +
        entryTimeController.text +
        "\"" +
        "," +
        "\"" +
        "VitalIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.vitalIDP5! +
        "\"" +
        "," +
        "\"" +
        "VitalValue" +
        "\"" +
        ":" +
        "\"" +
        vitalValue.toString() +
        "\"" +
        "}";

    debugPrint("Vital value");
    debugPrint(vitalValue.toString());
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
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr!.hide();
      Future.delayed(Duration(milliseconds: 300), () {
        Navigator.of(context).pop();
      });
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      /*key: navigatorKey,*/
        appBar: AppBar(
          title: Text("Add $title"),
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(
              color: Colorsblack, size: SizeConfig.blockSizeVertical !* 2.5), toolbarTextStyle: TextTheme(
            subtitle1: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5,
            )).bodyText2, titleTextStyle: TextTheme(
            subtitle1: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5,
            )).headline6,
        ),
        body:
        Builder(
          builder: (context) => Center(
            child: Builder(
              builder: (context) {
                return ColoredBox(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 5,
                      ),
                      Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: MaterialButton(
                                        onPressed: () {
                                          showDateSelectionDialog();
                                        },
                                        child: Container(
                                          child: IgnorePointer(
                                            child: TextField(
                                              controller: entryDateController,
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize:
                                                  SizeConfig.blockSizeVertical !*
                                                      2.1),
                                              decoration: InputDecoration(
                                                hintStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: SizeConfig
                                                        .blockSizeVertical !*
                                                        2.1),
                                                labelStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: SizeConfig
                                                        .blockSizeVertical !*
                                                        2.1),
                                                labelText: "Entry Date",
                                                hintText: "",
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: widget.vitalGroupIDP != "8"
                                          ? MaterialButton(
                                        onPressed: () {
                                          showTimeSelectionDialog();
                                        },
                                        child: Container(
                                          child: IgnorePointer(
                                            child: TextField(
                                              controller: entryTimeController,
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                      .blockSizeVertical !*
                                                      2.1),
                                              decoration: InputDecoration(
                                                hintStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: SizeConfig
                                                        .blockSizeVertical !*
                                                        2.1),
                                                labelStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: SizeConfig
                                                        .blockSizeVertical !*
                                                        2.1),
                                                labelText: "Entry Time",
                                                hintText: "",
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                          : Container(),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 18.0,
                              ),
                              /*Visibility(
                          visible: widget.vitalGroupIDP == "2",
                          child: SliderWidgetDecimal(
                            min: 94,
                            max: 105,
                            value: tempValue,
                            title: "Temperature",
                            unit: "\u2109",
                            isChecked: isCheckedTemp,
                          ),
                        ),*/
                              Visibility(
                                visible: widget.vitalGroupIDP == "1",
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: SizeConfig.blockSizeHorizontal !* 5,
                                      bottom: SizeConfig.blockSizeHorizontal !* 5),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Blood Pressure",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize:
                                        SizeConfig.blockSizeHorizontal !* 4,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "1",
                                child: SliderWidget(
                                  min: 30,
                                  max: 300,
                                  value: bpSystolicValue.toDouble(),
                                  title: "Systolic",
                                  unit: "mm of hg",
                                  isChecked: isCheckedBpSystolic,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "1",
                                child: SliderWidget(
                                  min: 10,
                                  max: 200,
                                  value: bpDiastolicValue.toDouble(),
                                  title: "Diastolic",
                                  unit: "mm of hg",
                                  isChecked: isCheckedBpDiastolic,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "2",
                                child: SliderWidget(
                                  min: 94,
                                  max: 105,
                                  value: tempValue,
                                  title: "Temperature",
                                  unit: "\u2109",
                                  isDecimal: true,
                                  isChecked: isCheckedTemp,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "2",
                                child: SliderWidget(
                                  min: 20,
                                  max: 250,
                                  value: pulseValue.toDouble(),
                                  title: "Pulse",
                                  unit: "per min.",
                                  isChecked: isCheckedPulse,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "2",
                                child: SliderWidget(
                                  min: 0,
                                  max: 100,
                                  value: spo2Value.toDouble(),
                                  title: "SPO2",
                                  unit: "%",
                                  isChecked: isCheckedSpo2,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "2",
                                child: SliderWidget(
                                  min: 0,
                                  max: 70,
                                  value: rrValue.toDouble(),
                                  title: "Respiratory Rate",
                                  unit: "per min.",
                                  isChecked: isCheckedRr,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "3",
                                child: SliderWidget(
                                  min: 0,
                                  max: 500,
                                  value: fbsValue.toDouble(),
                                  title: "FBS",
                                  unit: "mg/dl",
                                  isChecked: isCheckedFbs,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "3",
                                child: SliderWidget(
                                  min: 0,
                                  max: 500,
                                  value: ppbsValue.toDouble(),
                                  title: "PPBS",
                                  unit: "mg/dl",
                                  isChecked: isCheckedPpbs,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "3",
                                child: SliderWidget(
                                  min: 0,
                                  max: 500,
                                  value: rbsValue.toDouble(),
                                  title: "RBS",
                                  unit: "mg/dl",
                                  isChecked: isCheckedRbs,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "3",
                                child: SliderWidget(
                                  min: 2,
                                  max: 12,
                                  value: hba1cValue.toDouble(),
                                  title: "HbA1C",
                                  unit: "mg/dl",
                                  isChecked: isCheckedHba1c,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "4",
                                child: SliderWidget(
                                  min: 0,
                                  max: 200,
                                  value: heightValue.toDouble(),
                                  title: "Height",
                                  unit: "Centimeter",
                                  callbackFromBMI: callbackFromBMI,
                                  isChecked: isCheckedHeight,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "4",
                                child: SliderWidget(
                                  min: 0,
                                  max: 120,
                                  value: weightValue.toDouble(),
                                  title: "Weight",
                                  unit: "Kg",
                                  callbackFromBMI: callbackFromBMI,
                                  isChecked: isCheckedWeight,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "5",
                                child: SliderWidget(
                                  min: 0,
                                  max: 300,
                                  value: exerciseValue.toDouble(),
                                  title: "Exercise",
                                  unit: "Minutes",
                                  callbackFromBMI: callbackFromBMI,
                                  isChecked: isCheckedExercise,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "5",
                                child: SliderWidget(
                                  min: 0,
                                  max: 180,
                                  value: walkingValue.toDouble(),
                                  title: "Walking",
                                  unit: "Minutes",
                                  callbackFromBMI: callbackFromBMI,
                                  isChecked: isCheckedWalking,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "5",
                                child: SliderWidget(
                                  min: 0,
                                  max: 200,
                                  value: waistValue.toDouble(),
                                  title: "Waist",
                                  unit: "cm",
                                  callbackFromBMI: callbackFromBMI,
                                  isChecked: isCheckedWaist,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "5",
                                child: SliderWidget(
                                  min: 0,
                                  max: 200,
                                  value: hipValue.toDouble(),
                                  title: "Hip",
                                  unit: "cm",
                                  callbackFromBMI: callbackFromBMI,
                                  isChecked: isCheckedHip,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "6",
                                child: SliderWidget(
                                  min: 0,
                                  max: 100,
                                  value: tshValue,
                                  title: "TSH",
                                  unit: "uIU/mL",
                                  isChecked: isCheckedTSH,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "6",
                                child: SliderWidget(
                                  min: 20,
                                  max: 500,
                                  value: t3Value,
                                  title: "T3",
                                  unit: "ng/dL",
                                  isChecked: isCheckedT3,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "6",
                                child: SliderWidget(
                                  min: 0,
                                  max: 25,
                                  value: t4Value,
                                  title: "T4",
                                  unit: "ug/dL",
                                  isChecked: isCheckedT4,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "6",
                                child: SliderWidget(
                                  min: 0,
                                  max: 25,
                                  value: freeT3Value,
                                  title: "Free T3",
                                  unit: "pg/mL",
                                  isChecked: isCheckedFreeT3,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "6",
                                child: SliderWidget(
                                  min: 0,
                                  max: 25,
                                  value: freeT4Value,
                                  title: "Free T4",
                                  unit: "ng/dL",
                                  isChecked: isCheckedFreeT4,
                                ),
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "8",
                                child: SliderWidget(
                                  min: 0,
                                  max: 12,
                                  value: sleepValue.toDouble(),
                                  title: "Sleep",
                                  unit: "Hours",
                                  isChecked: isCheckedSleep,
                                ),
                              ),
                              /*Visibility(
                          visible: widget.vitalIDP == "3",
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: SizeConfig.blockSizeHorizontal * 90,
                              padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal * 1),
                              child: TextField(
                                controller: temperatureController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize:
                                        SizeConfig.blockSizeVertical * 2.3),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2.3),
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical * 2.3),
                                  labelText: "Temperature \u2109",
                                  hintText: "",
                                ),
                              ),
                            ),
                          ),
                        ),*/
                              Visibility(
                                visible: false /*widget.vitalGroupIDP == "6"*/,
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: SizeConfig.blockSizeHorizontal !* 40,
                                      padding: EdgeInsets.all(
                                          SizeConfig.blockSizeHorizontal !* 3),
                                      child: TextField(
                                        controller: tshController,
                                        onChanged: (text) {
                                          if (text.length >= 3 &&
                                              (double.parse(text) < 0 ||
                                                  double.parse(text) > 100)) {
                                            final snackBar = SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                  "TSH must be between 0 to 100"),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                            setState(() {
                                              tshController = TextEditingController(
                                                  text: previousTextTSH);
                                              tshController.selection =
                                                  TextSelection.fromPosition(
                                                      TextPosition(
                                                          offset: tshController
                                                              .text.length));
                                            });
                                          } else {
                                            previousTextTSH = text;
                                          }
                                        },
                                        keyboardType: TextInputType.number,
                                        maxLength: 6,
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize:
                                            SizeConfig.blockSizeVertical !* 2.3),
                                        decoration: InputDecoration(
                                          counterText: "",
                                          hintStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.3),
                                          labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.3),
                                          labelText: "TSH",
                                          hintText: "",
                                        ),
                                      ),
                                    ),
                                    /*SizedBox(
                                width: SizeConfig.blockSizeHorizontal * 0.5,
                              ),*/
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        "uIU/mL",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                            SizeConfig.blockSizeHorizontal !*
                                                3.8,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              /*SizedBox(
                          height: 5.0,
                        ),*/
                              Visibility(
                                  visible: false /*widget.vitalGroupIDP == "6"*/,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          width:
                                          SizeConfig.blockSizeHorizontal !* 40,
                                          padding: EdgeInsets.all(
                                              SizeConfig.blockSizeHorizontal !* 3),
                                          child: TextField(
                                            onChanged: (text) {
                                              if (text.length >= 3 &&
                                                  (double.parse(text) < 20 ||
                                                      double.parse(text) > 500)) {
                                                final snackBar = SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                      "T3 must be between 20 to 500"),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                                setState(() {
                                                  t3Controller =
                                                      TextEditingController(
                                                          text: previousTextT3);
                                                  t3Controller.selection =
                                                      TextSelection.fromPosition(
                                                          TextPosition(
                                                              offset: t3Controller
                                                                  .text.length));
                                                });
                                              } else {
                                                previousTextT3 = text;
                                              }
                                            },
                                            controller: t3Controller,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            maxLength: 6,
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.3),
                                            decoration: InputDecoration(
                                              counterText: "",
                                              hintStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                  SizeConfig.blockSizeVertical !*
                                                      2.3),
                                              labelStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                  SizeConfig.blockSizeVertical !*
                                                      2.3),
                                              labelText: "T3",
                                              hintText: "",
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          "ng/dL",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                              SizeConfig.blockSizeHorizontal !*
                                                  3.8,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      SizedBox(
                                        width: SizeConfig.blockSizeHorizontal !* 3,
                                      ),
                                      Expanded(
                                        child: Container(
                                          width:
                                          SizeConfig.blockSizeHorizontal !* 40,
                                          padding: EdgeInsets.all(
                                              SizeConfig.blockSizeHorizontal !* 3),
                                          child: TextField(
                                            controller: t4Controller,
                                            onChanged: (text) {
                                              if (text.length >= 2 &&
                                                  (double.parse(text) < 0 ||
                                                      double.parse(text) > 25)) {
                                                final snackBar = SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                      "T4 must be between 0 to 25"),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                                setState(() {
                                                  t4Controller =
                                                      TextEditingController(
                                                          text: previousTextT4);
                                                  t4Controller.selection =
                                                      TextSelection.fromPosition(
                                                          TextPosition(
                                                              offset: t4Controller
                                                                  .text.length));
                                                });
                                              } else {
                                                previousTextT4 = text;
                                              }
                                            },
                                            keyboardType: TextInputType.number,
                                            maxLength: 6,
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.3),
                                            decoration: InputDecoration(
                                              counterText: "",
                                              hintStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                  SizeConfig.blockSizeVertical !*
                                                      2.3),
                                              labelStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                  SizeConfig.blockSizeVertical !*
                                                      2.3),
                                              labelText: "T4",
                                              hintText: "",
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          "ug/dL",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                              SizeConfig.blockSizeHorizontal !*
                                                  3.8,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      SizedBox(
                                        width: SizeConfig.blockSizeHorizontal !* 2,
                                      ),
                                    ],
                                  )),
                              SizedBox(
                                height: 10.0,
                              ),
                              Visibility(
                                  visible: false /*widget.vitalGroupIDP == "6"*/,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          width:
                                          SizeConfig.blockSizeHorizontal !* 40,
                                          padding: EdgeInsets.all(
                                              SizeConfig.blockSizeHorizontal !* 3),
                                          child: TextField(
                                            controller: freeT3Controller,
                                            onChanged: (text) {
                                              if (text.length >= 2 &&
                                                  (double.parse(text) < 0 ||
                                                      double.parse(text) > 25)) {
                                                final snackBar = SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                      "Free T3 must be between 0 to 25"),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                                setState(() {
                                                  freeT3Controller =
                                                      TextEditingController(
                                                          text: previousTextFreeT3);
                                                  freeT3Controller.selection =
                                                      TextSelection.fromPosition(
                                                          TextPosition(
                                                              offset:
                                                              freeT3Controller
                                                                  .text
                                                                  .length));
                                                });
                                              } else {
                                                previousTextFreeT3 = text;
                                              }
                                            },
                                            keyboardType: TextInputType.number,
                                            maxLength: 6,
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.3),
                                            decoration: InputDecoration(
                                              counterText: "",
                                              hintStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                  SizeConfig.blockSizeVertical !*
                                                      2.3),
                                              labelStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                  SizeConfig.blockSizeVertical !*
                                                      2.3),
                                              labelText: "FreeT3",
                                              hintText: "",
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          "pg/mL",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                              SizeConfig.blockSizeHorizontal !*
                                                  3.8,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      SizedBox(
                                        width: SizeConfig.blockSizeHorizontal !* 3,
                                      ),
                                      Expanded(
                                        child: Container(
                                          width:
                                          SizeConfig.blockSizeHorizontal !* 40,
                                          padding: EdgeInsets.all(
                                              SizeConfig.blockSizeHorizontal !* 3),
                                          child: TextField(
                                            controller: freeT4Controller,
                                            onChanged: (text) {
                                              if (text.length >= 2 &&
                                                  (double.parse(text) < 0 ||
                                                      double.parse(text) > 25)) {
                                                final snackBar = SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                      "Free T4 must be between 0 to 25"),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                                setState(() {
                                                  freeT4Controller =
                                                      TextEditingController(
                                                          text: previousTextFreeT4);
                                                  freeT4Controller.selection =
                                                      TextSelection.fromPosition(
                                                          TextPosition(
                                                              offset:
                                                              freeT4Controller
                                                                  .text
                                                                  .length));
                                                });
                                              } else {
                                                previousTextFreeT4 = text;
                                              }
                                            },
                                            keyboardType: TextInputType.number,
                                            maxLength: 6,
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.3),
                                            decoration: InputDecoration(
                                              counterText: "",
                                              hintStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                  SizeConfig.blockSizeVertical !*
                                                      2.3),
                                              labelStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                  SizeConfig.blockSizeVertical !*
                                                      2.3),
                                              labelText: "FreeT4",
                                              hintText: "",
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          "ng/dL",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                              SizeConfig.blockSizeHorizontal !*
                                                  3.8,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      SizedBox(
                                        width: SizeConfig.blockSizeHorizontal !* 2,
                                      ),
                                    ],
                                  )),
                              /*Visibility(
                          visible: widget.vitalIDP == "3",
                          child: SliderWidget(
                            min: 80,
                            max: 120,
                            value: tempValue.toDouble(),
                            title: "Temperature",
                            unit: "\u2109",
                          ),
                        ),*/
                              SizedBox(
                                height: SizeConfig.blockSizeVertical !* 2,
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "4",
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'BMI - ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize:
                                        SizeConfig.blockSizeHorizontal !* 4.3,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      ' ${bmi.toStringAsFixed(2)} ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize:
                                        SizeConfig.blockSizeHorizontal !* 7,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      ' Kg/m\u00B2',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize:
                                        SizeConfig.blockSizeHorizontal !* 4.3,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical !* 1,
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "4",
                                child: Container(
                                  width: SizeConfig.blockSizeHorizontal !* 40,
                                  height: SizeConfig.blockSizeVertical !* 0.3,
                                  color: Colors.white,
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: SizeConfig.blockSizeHorizontal !* 40,
                                    height: SizeConfig.blockSizeVertical !* 0.3,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical !* 1,
                              ),
                              Visibility(
                                  visible: widget.vitalGroupIDP == "4",
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "You're   ",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize:
                                            SizeConfig.blockSizeHorizontal !*
                                                6.5,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey),
                                      ),
                                      Text(
                                        bmi < 18.5
                                            ? "Under-weight"
                                            : (bmi < 25
                                            ? "Normal"
                                            : (bmi < 30
                                            ? "Over-weight"
                                            : "Obese")),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize:
                                          SizeConfig.blockSizeHorizontal !* 8,
                                          fontWeight: FontWeight.w500,
                                          color: bmi < 18.5
                                              ? Colors.orange
                                              : (bmi < 25
                                              ? Colors.green
                                              : (bmi < 30
                                              ? Colors.orange
                                              : Colors.red)),
                                        ),
                                      ),
                                    ],
                                  )),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical !* 1,
                              ),
                              Visibility(
                                visible: widget.vitalGroupIDP == "4",
                                child: Image(
                                  image: bmi < 18.5
                                      ? AssetImage("images/ic_shocked.png")
                                      : (bmi < 25
                                      ? AssetImage("images/ic_happy.png")
                                      : (bmi < 30
                                      ? AssetImage(
                                      "images/ic_little_sad.png")
                                      : AssetImage("images/ic_sad.png"))),
                                  width: SizeConfig.blockSizeHorizontal !* 20,
                                  height: SizeConfig.blockSizeHorizontal !* 20,
                                ),
                              ),
                            ],
                          )),
                      Container(
                        height: SizeConfig.blockSizeVertical !* 12,
                        padding: EdgeInsets.only(
                            right: SizeConfig.blockSizeHorizontal !* 1.5,
                            top: SizeConfig.blockSizeVertical !* 3.5),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            width: SizeConfig.blockSizeHorizontal !* 12,
                            height: SizeConfig.blockSizeHorizontal !* 12,
                            child: RawMaterialButton(
                              onPressed: () {
                                if (widget.vitalGroupIDP == "3" ||
                                    widget.vitalGroupIDP == "6") {
                                  validateAndSubmitInvestigations(context);
                                } else {
                                  pr = ProgressDialog(context);
                                  pr?.show();
                                  int noOfCheckedVitalsInGroup = 0;
                                  for (int i = 0;
                                  i < listVitalIDPs.length;
                                  i++) {
                                    if (getVitalIsChecked(listVitalIDPs[i]))
                                      noOfCheckedVitalsInGroup++;
                                  }
                                  debugPrint(
                                      "no of checked thyroid - $noOfCheckedVitalsInGroup");
                                  for (int i = 0;
                                  i < listVitalIDPs.length;
                                  i++) {
                                    if (getVitalIsChecked(listVitalIDPs[i]))
                                      submitVitalDetails(
                                          context,
                                          listVitalIDPs[i],
                                          i + 1,
                                          noOfCheckedVitalsInGroup);
                                  }
                                }
                              },
                              elevation: 2.0,
                              fillColor: Color(0xFF06A759),
                              child: Image(
                                width: SizeConfig.blockSizeHorizontal !* 5.5,
                                height: SizeConfig.blockSizeHorizontal !* 5.5,
                                //height: 80,
                                image: AssetImage(
                                    "images/ic_right_arrow_triangular.png"),
                              ),
                              shape: CircleBorder(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ));
  }

  void validateAndSubmitInvestigations(BuildContext context) async {
    if (entryDateController.text == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Entry Date"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    if (entryTimeController.text == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Entry Time"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    ProgressDialog pr = ProgressDialog(context);
    pr.show();

    var jArrayInvestigationMaster = "[";

    if (widget.vitalGroupIDP == "3") {
      String fbsParams = "";
      if (isCheckedFbs) {
        fbsParams =
        "{\"PreInvestTypeIDP\":\"92\",\"InvestigationValue\":\"$fbsValue\"},";
      }
      String ppbsParams = "";
      if (isCheckedPpbs) {
        ppbsParams =
        "{\"PreInvestTypeIDP\":\"91\",\"InvestigationValue\":\"$ppbsValue\"},";
      }
      String rbsParams = "";
      if (isCheckedRbs) {
        rbsParams =
        "{\"PreInvestTypeIDP\":\"93\",\"InvestigationValue\":\"$rbsValue\"},";
      }
      String hba1cParams = "";
      if (isCheckedHba1c) {
        hba1cParams =
        "{\"PreInvestTypeIDP\":\"94\",\"InvestigationValue\":\"$hba1cValue\"}";
      }
      jArrayInvestigationMaster =
      "[$fbsParams$ppbsParams$rbsParams$hba1cParams]";
    } else if (widget.vitalGroupIDP == "6") {
      String tshParams = "";
      if (isCheckedTSH) {
        tshParams =
        "{\"PreInvestTypeIDP\":\"146\",\"InvestigationValue\":\"$tshValue\"},";
      }
      String t3Params = "";
      if (isCheckedT3) {
        t3Params =
        "{\"PreInvestTypeIDP\":\"147\",\"InvestigationValue\":\"$t3Value\"},";
      }
      String t4Params = "";
      if (isCheckedT4) {
        t4Params =
        "{\"PreInvestTypeIDP\":\"148\",\"InvestigationValue\":\"$t4Value\"},";
      }
      String freeT3Params = "";
      if (isCheckedFreeT3) {
        freeT3Params =
        "{\"PreInvestTypeIDP\":\"149\",\"InvestigationValue\":\"$freeT3Value\"}";
      }
      String freeT4Params = "";
      if (isCheckedFreeT4) {
        freeT4Params =
        "{\"PreInvestTypeIDP\":\"150\",\"InvestigationValue\":\"$freeT4Value\"}";
      }
      jArrayInvestigationMaster =
      "[$tshParams$t3Params$t4Params$freeT3Params$freeT4Params]";
    }

    debugPrint("Final Array");
    debugPrint(jArrayInvestigationMaster);

    String loginUrl = "${baseURL}patientInvestSave.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP! +
        "\"" +
        "," +
        "\"" +
        "EntryDate" +
        "\"" +
        ":" +
        "\"" +
        entryDateController.text +
        "\"" +
        "," +
        "\"" +
        "EntryTime" +
        "\"" +
        ":" +
        "\"" +
        entryTimeController.text +
        "\"" +
        "," +
        "\"InvestgationData" +
        "\"" +
        ":" +
        jArrayInvestigationMaster +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: loginUrl,
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
    if (model.status == "OK") {
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text("Investigation successfully Added"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(milliseconds: 300), () {
        Navigator.of(context).pop();
      });
    }
    pr.hide();
  }

  void getCountriesList() async {
    String loginUrl = "${baseURL}country_list.php";
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
    String jsonStr =
        "{" + "\"" + "PatientIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

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
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      widget.listCountries = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        widget.listCountries
            .add(DropDownItem(jo['CountryIDP'], jo['CountryName']));
      }
      setState(() {});
    }
  }

  void showDateSelectionDialog() async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    DateTime firstDate = DateTime.now().subtract(Duration(days: 365 * 100));
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: pickedDate,
        firstDate: firstDate,
        lastDate: DateTime.now());

    if (date != null) {
      pickedDate = date;
      var formatter = new DateFormat('dd-MM-yyyy');
      String formatted = formatter.format(pickedDate);
      entryDateController = TextEditingController(text: formatted);
      setState(() {});
    }
  }

  void showTimeSelectionDialog() async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
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
      entryTimeController = TextEditingController(text: formatted);

      setState(() {});
    }
  }

  double getVitalValue(String vitalIDPLocal) {
    var vitalValue = 0.0;
    if (vitalIDPLocal == "1")
      vitalValue = bpSystolicValue.toDouble();
    else if (vitalIDPLocal == "2")
      vitalValue = bpDiastolicValue.toDouble();
    else if (vitalIDPLocal == "3")
      vitalValue = pulseValue.toDouble();
    else if (vitalIDPLocal == "4")
      vitalValue = tempValue;
    else if (vitalIDPLocal == "5")
      vitalValue = spo2Value.toDouble();
    else if (vitalIDPLocal == "6")
      vitalValue = fbsValue.toDouble();
    else if (vitalIDPLocal == "7")
      vitalValue = ppbsValue.toDouble();
    else if (vitalIDPLocal == "8")
      vitalValue = rbsValue.toDouble();
    else if (vitalIDPLocal == "9")
      vitalValue = hba1cValue.toDouble();
    else if (vitalIDPLocal == "10")
      vitalValue = rrValue.toDouble();
    else if (vitalIDPLocal == "11")
      vitalValue = weightValue.toDouble();
    else if (vitalIDPLocal == "21")
      vitalValue = double.parse(heightValue.toStringAsFixed(2));
    else if (vitalIDPLocal == "12")
      vitalValue = double.parse(bmi.toStringAsFixed(2));
    else if (vitalIDPLocal == "13")
      vitalValue = exerciseValue.toDouble();
    else if (vitalIDPLocal == "14")
      vitalValue = walkingStepsValue.toDouble();
    else if (vitalIDPLocal == "15")
      vitalValue = tshValue /*double.parse(tshController.text)*/;
    else if (vitalIDPLocal == "16")
      vitalValue = t3Value /*double.parse(t3Controller.text)*/;
    else if (vitalIDPLocal == "17")
      vitalValue = t4Value /*double.parse(t4Controller.text)*/;
    else if (vitalIDPLocal == "18")
      vitalValue = freeT3Value /*double.parse(freeT3Controller.text)*/;
    else if (vitalIDPLocal == "19")
      vitalValue = freeT4Value;
    else if (vitalIDPLocal == "22")
      vitalValue = sleepValue.toDouble();
    else if (vitalIDPLocal == "23")
      vitalValue = waistValue.toDouble();
    else if (vitalIDPLocal == "24") vitalValue = hipValue.toDouble();
    return vitalValue;
  }

  bool getVitalIsChecked(String vitalIDPLocal) {
    bool isVitalChecked = false;
    debugPrint("Thyroid");
    if (vitalIDPLocal == "1")
      isVitalChecked = true;
    else if (vitalIDPLocal == "2")
      isVitalChecked = true;
    else if (vitalIDPLocal == "3")
      isVitalChecked = isCheckedPulse;
    else if (vitalIDPLocal == "4")
      isVitalChecked = isCheckedTemp;
    else if (vitalIDPLocal == "5")
      isVitalChecked = isCheckedSpo2;
    else if (vitalIDPLocal == "6")
      isVitalChecked = isCheckedFbs;
    else if (vitalIDPLocal == "7")
      isVitalChecked = isCheckedPpbs;
    else if (vitalIDPLocal == "8")
      isVitalChecked = isCheckedRbs;
    else if (vitalIDPLocal == "9")
      isVitalChecked = isCheckedHba1c;
    else if (vitalIDPLocal == "10")
      isVitalChecked = isCheckedRr;
    else if (vitalIDPLocal == "11")
      isVitalChecked = isCheckedWeight;
    else if (vitalIDPLocal == "21")
      isVitalChecked = isCheckedHeight;
    else if (vitalIDPLocal == "12")
      isVitalChecked = isCheckedWeight && isCheckedHeight;
    else if (vitalIDPLocal == "13")
      isVitalChecked = isCheckedExercise;
    else if (vitalIDPLocal == "14")
      isVitalChecked = isCheckedWalking;
    else if (vitalIDPLocal == "15")
      isVitalChecked = isCheckedTSH;
    else if (vitalIDPLocal == "16")
      isVitalChecked = isCheckedT3;
    else if (vitalIDPLocal == "17")
      isVitalChecked = isCheckedT4;
    else if (vitalIDPLocal == "18")
      isVitalChecked = isCheckedFreeT3;
    else if (vitalIDPLocal == "19")
      isVitalChecked = isCheckedFreeT4;
    else if (vitalIDPLocal == "22")
      isVitalChecked = true;
    else if (vitalIDPLocal == "23")
      isVitalChecked = isCheckedWaist;
    else if (vitalIDPLocal == "24") isVitalChecked = isCheckedHip;
    debugPrint(isVitalChecked.toString());
    return isVitalChecked;
  }

  void callbackFromBMI() {
    setState(() {});
  }

  String? messageAccordingToScreen() {
    switch (widget.vitalGroupIDP) {
      case "1":
        return "Blood Pressure records added successfully.";
      case "2":
        return "Vitals records added successfully.";
      case "3":
        return "Sugar records added successfully.";
      case "4":
        return "Weight Measurement records added successfully.";
      case "5":
        return "Health Meter records added successfully.";
      case "6":
        return "Thyroid records added successfully.";
      case "7":
        return "Water Intake records added successfully.";
      case "8":
        return "Sleep hours added successfully.";
    }
  }
}

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  double min;
  double max;
  String title = "";
  double value = 0;
  final fullWidth;
  String unit;
  final Function? callbackFromBMI;
  bool? isChecked = false;
  bool isDecimal = false;

  SliderWidget({
    this.sliderHeight = 50,
    this.max = 1000,
    this.min = 0,
    this.value = 0,
    this.title = "",
    this.fullWidth = true,
    this.unit = "",
    this.callbackFromBMI,
    this.isChecked,
    this.isDecimal = false,
  });

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  //double _value = 0;
  SliderController sliderController = Get.put(SliderController());

  @override
  void initState() {
    debugPrint("Slider value - ${widget.value}");
    sliderController.value.value = widget.value!;
    /*
    _value = widget.value;
    if (widget.title == "Pulse")
      pulseValue = _value;
    else if (widget.title == "Systolic")
      bpSystolicValue = _value;
    else if (widget.title == "Diastolic")
      bpDiastolicValue = _value;
    else if (widget.title == "Temperature")
      tempValue = _value;
    else if (widget.title == "SPO2")
      spo2Value = _value;
    else if (widget.title == "FBS")
      fbsValue = _value;
    else if (widget.title == "PPBS")
      ppbsValue = _value;
    else if (widget.title == "RBS")
      rbsValue = _value;
    else if (widget.title == "HbA1C")
      hba1cValue = _value;
    else if (widget.title == "Respiratory Rate")
      rrValue = _value;
    else if (widget.title == "Weight") {
      weightValue = _value;
      bmi = weightValue / (pow((heightValue / 100), 2));
      //widget.callbackFromBMI();
    } else if (widget.title == "Height") {
      heightValue = _value;
      bmi = weightValue / (pow((heightValue / 100), 2));
      //widget.callbackFromBMI();
    } else if (widget.title == "Exercise")
      exerciseValue = _value;
    else if (widget.title == "Walking")
      walkingValue = _value.toInt();
    else if (widget.title == "Sleep")
      sleepValue = _value;
    else if (widget.title == "Waist")
      waistValue = _value;
    else if (widget.title == "Hip")
      hipValue = _value;
    else if (widget.title == "Temperature")
      tempValue = _value;
    else if (widget.title == "TSH")
      tshValue = _value;
    else if (widget.title == "T3")
      t3Value = _value;
    else if (widget.title == "T4")
      t4Value = _value;
    else if (widget.title == "Free T3")
      freeT3Value = _value;
    else if (widget.title == "Free T4") freeT4Value = _value;*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double paddingFactor = .2;

    if (this.widget.fullWidth) paddingFactor = .3;

    return
      Container(
      /*padding: widget.title == "Systolic" || widget.title == "Diastolic"
          ? EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal * 8,
              right: SizeConfig.blockSizeHorizontal * 3,
            )
          : EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal * 3,
              right: SizeConfig.blockSizeHorizontal * 3,
            ),
      width: this.widget.fullWidth
          ? double.infinity
          : (this.widget.sliderHeight) * 5.5,
      height: SizeConfig.blockSizeVertical * 13,
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.all(
          Radius.circular((this.widget.sliderHeight * .3)),
        ),
      ),*/
        color: Colors.white,
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal !* 6),
        child: Column(
          children: [
            Visibility(
              visible: widget.title == "Height",
              child: Text(
                '$heightInFeet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Visibility(
              visible: widget.title == "Walking",
              child: Text(
                '$walkingStepsValue steps',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal !* 3.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Visibility(
                  visible: widget.title != "Systolic" &&
                      widget.title != "Diastolic" &&
                      widget.title != "Sleep",
                  child: Checkbox(
                    value: widget.isChecked,
                    onChanged: (isChecked) {
                      widget.isChecked = isChecked;
                      if (widget.title == "Pulse") {
                        if(isChecked!=null)
                          isCheckedPulse = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        //pulseValue = widget.min.round();
                        // }
                      } else if (widget.title == "Systolic") {
                        if(isChecked!=null)
                          isCheckedBpSystolic = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        //bpSystolicValue = widget.min;
                        // }
                      } else if (widget.title == "Diastolic") {
                        if(isChecked!=null)
                          isCheckedBpDiastolic = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        //bpDiastolicValue = widget.min;
                        // }
                      } else if (widget.title == "Temperature") {
                        if(isChecked!=null)
                          isCheckedTemp = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        //tempValue = widget.min.toDouble();
                        // }
                      } else if (widget.title == "SPO2") {
                        if(isChecked!=null)
                          isCheckedSpo2 = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        //spo2Value = widget.min;
                        // }
                      } else if (widget.title == "FBS") {
                        if(isChecked!=null)
                          isCheckedFbs = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        //fbsValue = widget.min;
                        // }
                      } else if (widget.title == "PPBS") {
                        if(isChecked!=null)
                          isCheckedPpbs = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        //ppbsValue = widget.min;
                        // }
                      } else if (widget.title == "RBS") {
                        if(isChecked!=null)
                          isCheckedRbs = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        //rbsValue = widget.min;
                        // }
                      } else if (widget.title == "HbA1C") {
                        if(isChecked!=null)
                          isCheckedHba1c = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        //hba1cValue = widget.min;
                        // }
                      } else if (widget.title == "Respiratory Rate") {
                        if(isChecked!=null)
                          isCheckedRr = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        //rrValue = widget.min;
                        // }
                      } else if (widget.title == "Sleep") {
                        if(isChecked!=null)
                          isCheckedSleep = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        //sleepValue = widget.min;
                        // }
                      } else if (widget.title == "Weight") {
                        if(isChecked!=null)
                          isCheckedWeight = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        /*weightValue = widget.min;
                            bmi = weightValue / (pow((heightValue / 100), 2));
                            widget.callbackFromBMI();*/
                        // }
                      } else if (widget.title == "Height") {
                        if(isChecked!=null)
                          isCheckedHeight = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        /*heightValue = widget.min;
                            cmToFeet();
                            bmi = weightValue / (pow((heightValue / 100), 2));
                            widget.callbackFromBMI();*/
                        // }
                      } else if (widget.title == "Exercise") {
                        if(isChecked!=null)
                          isCheckedExercise = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        //exerciseValue = widget.min;
                        // }
                      } else if (widget.title == "Walking") {
                        if(isChecked!=null)
                          isCheckedWalking = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        /*walkingValue = widget.min;
                            minutesToStep();
                            widget.callbackFromBMI();*/
                        // }
                      } else if (widget.title == "Waist") {
                        if(isChecked!=null)
                          isCheckedWaist = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        /*waistValue = widget.min;
                            widget.callbackFromBMI();*/
                        // }
                      } else if (widget.title == "Hip") {
                        if(isChecked!=null)
                          isCheckedHip = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min.toDouble();
                        /*hipValue = widget.min;
                            widget.callbackFromBMI();*/
                        // }
                      } else if (widget.title == "Temperature") {
                        if(isChecked!=null)
                          isCheckedPulse = isChecked;
                        // if (!isChecked) {
                        //widget.value = widget.min;
                        //tempValue = widget.min;
                        // }
                      } else if (widget.title == "TSH") {
                        if(isChecked!=null)
                          isCheckedTSH = isChecked;
                        // if (!isChecked) {
                        /*widget.value = widget.min;
                            tshValue = widget.min;*/
                        // }
                      } else if (widget.title == "T3") {
                        if(isChecked!=null)
                          isCheckedT3 = isChecked;
                        // if (!isChecked) {
                        /* widget.value = widget.min;
                            t3Value = widget.min;*/
                        // }
                      } else if (widget.title == "T4") {
                        if(isChecked!=null)
                          isCheckedT4 = isChecked;
                        // if (!isChecked) {
                        /* widget.value = widget.min;
                            t4Value = widget.min;*/
                        // }
                      } else if (widget.title == "Free T3") {
                        if(isChecked!=null)
                          isCheckedFreeT3 = isChecked;
                        // if (!isChecked) {
                        /*widget.value = widget.min;
                            freeT3Value = widget.min;*/
                        // }
                      } else if (widget.title == "Free T4") {
                        if(isChecked!=null)
                          isCheckedFreeT4 = isChecked;
                        // if (!isChecked) {
                        /*widget.value = widget.min;
                            freeT4Value = widget.min;*/
                        // }
                      }
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child:
                  UltimateSlider(
                    minValue: widget.min,
                    maxValue: widget.max,
                    value: widget.value,
                    showDecimals: widget.isDecimal,
                    decimalInterval: 0.05,
                    titleText: widget.title,
                    unitText: widget.unit,
                    indicatorColor: getColorFromTitle(widget.title),
                    bubbleColor: getColorFromTitle(widget.title),
                    onValueChange: (value) {
                      widget.isChecked = true;
                      widget.value = value;
                      sliderController.value.value = value;
                      if (widget.title == "Pulse") {
                        isCheckedPulse = true;
                        pulseValue = value;
                      } else if (widget.title == "Systolic") {
                        isCheckedBpSystolic = true;
                        widget.value = value;
                        bpSystolicValue = value;
                      } else if (widget.title == "Diastolic") {
                        isCheckedBpDiastolic = true;
                        bpDiastolicValue = value;
                      } else if (widget.title == "Temperature") {
                        isCheckedTemp = true;
                        tempValue = value;
                      } else if (widget.title == "SPO2") {
                        isCheckedSpo2 = true;
                        spo2Value = value;
                      } else if (widget.title == "FBS") {
                        isCheckedFbs = true;
                        fbsValue = value;
                      } else if (widget.title == "PPBS") {
                        isCheckedPpbs = true;
                        ppbsValue = value;
                      } else if (widget.title == "RBS") {
                        isCheckedRbs = true;
                        rbsValue = value;
                      } else if (widget.title == "HbA1C") {
                        isCheckedHba1c = true;
                        hba1cValue = value;
                      } else if (widget.title == "Respiratory Rate") {
                        isCheckedRr = true;
                        rrValue = value;
                      } else if (widget.title == "Sleep") {
                        isCheckedSleep = true;
                        sleepValue = value;
                      } else if (widget.title == "Weight") {
                        isCheckedWeight = true;
                        weightValue = value;
                        bmi = weightValue / (pow((heightValue / 100), 2));
                        widget.callbackFromBMI!();
                      } else if (widget.title == "Height") {
                        isCheckedHeight = true;
                        heightValue = value;
                        cmToFeet();
                        bmi = weightValue / (pow((heightValue / 100), 2));
                        widget.callbackFromBMI!();
                      } else if (widget.title == "Exercise") {
                        isCheckedExercise = true;
                        exerciseValue = value;
                      } else if (widget.title == "Walking") {
                        isCheckedWalking = true;
                        walkingValue = value.toInt();
                        minutesToStep();
                        widget.callbackFromBMI!();
                      } else if (widget.title == "Waist") {
                        isCheckedWaist = true;
                        waistValue = value;
                        widget.callbackFromBMI!();
                      } else if (widget.title == "Hip") {
                        isCheckedHip = true;
                        hipValue = value;
                        widget.callbackFromBMI!();
                      } else if (widget.title == "Temperature") {
                        if(widget.value!=null)
                          tempValue = double.parse(widget.value!.toStringAsFixed(2));
                        isCheckedTemp = true;
                      } else if (widget.title == "TSH") {
                        if(widget.value!=null)
                          tshValue =
                              double.parse(widget.value!.toStringAsFixed(2));
                        isCheckedTSH = true;
                      } else if (widget.title == "T3") {
                        if(widget.value!=null)
                          t3Value = double.parse(widget.value!.toStringAsFixed(2));
                        isCheckedT3 = true;
                      } else if (widget.title == "T4") {
                        if(widget.value!=null)
                          t4Value = double.parse(widget.value!.toStringAsFixed(2));
                        isCheckedT4 = true;
                      } else if (widget.title == "Free T3") {
                        if(widget.value!=null)
                          freeT3Value =
                              double.parse(widget.value!.toStringAsFixed(2));
                        isCheckedFreeT3 = true;
                      } else if (widget.title == "Free T4") {
                        if(widget.value!=null)
                          freeT4Value =
                              double.parse(widget.value!.toStringAsFixed(2));
                        isCheckedFreeT4 = true;
                      }
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical !* 5.0,
            ),
            /*Text(
                      '${this.widget.title} - ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      ' ${widget.value.round()} ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 5.3,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      ' (${widget.unit})',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Visibility(
                      visible: widget.title == "Height",
                      child: Text(
                        ' - $heightInFeet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: widget.title == "Walking",
                      child: Text(
                        '$walkingStepsValue steps',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    )*/
          ],
        )
      /*],
          )*/

    );
  }

  void cmToFeet() {
    double heightInFeetWithDecimal = heightValue * 0.0328084;
    int intHeightInFeet = heightInFeetWithDecimal.toInt();
    double remainingDecimals = heightInFeetWithDecimal - intHeightInFeet;
    int intHeightInInches = (remainingDecimals * 12).round().toInt();
    if (intHeightInInches == 12) {
      intHeightInFeet++;
      intHeightInInches = 0;
    }
    heightInFeet = "$intHeightInFeet Foot $intHeightInInches Inches";
  }

  void minutesToStep() {
    debugPrint("Walking value - $walkingValue");
    walkingStepsValue = (walkingValue * 80).round();
  }

  Color getColorFromTitle(String title) {
    if (title == "Systolic" ||
        title == "Temperature" ||
        title == "FBS" ||
        title == "Height" ||
        title == "Exercise" ||
        title == "TSH" ||
        title == "Sleep")
      return Colors.amber;
    else if (title == "Diastolic" ||
        title == "Pulse" ||
        title == "FBS" ||
        title == "Weight" ||
        title == "Walking" ||
        title == "T3")
      return Colors.blue;
    else if (title == "SPO2" ||
        title == "RBS" ||
        title == "Waist" ||
        title == "T4")
      return Colors.green;
    else if (title == "Respiratory Rate" ||
        title == "HbA1C" ||
        title == "Hip" ||
        title == "Free T3")
      return Colors.deepOrangeAccent;
    else if (title == "Free T4") return Colors.teal;
    return Colors.amber;
  }
}

//JSON Parsing
//https://medium.com/flutter-community/parsing-complex-json-in-flutter-747c46655f51

