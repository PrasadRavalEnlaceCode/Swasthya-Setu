import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:silvertouch/app_screens/apply_couponcode_or_pay_screen.dart';
import 'package:silvertouch/app_screens/my_patients_screen.dart';
import 'package:silvertouch/app_screens/select_opd_procedures_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_profile_patient.dart';
import 'package:silvertouch/podo/patient_profile_upload_model.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';
import 'package:silvertouch/widgets/extensions.dart';
import '../podo/dropdown_item.dart';
import '../utils/color.dart';
import '../utils/progress_dialog.dart';

import '../utils/color.dart';
import '../utils/progress_dialog.dart';
import 'custom_dialog_select_image_from.dart';

final focus = FocusNode();
TextEditingController firstNameController = TextEditingController();
TextEditingController lastNameController = TextEditingController();
TextEditingController mobileNumberController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController dobController = TextEditingController();
TextEditingController ageController = TextEditingController();
TextEditingController cityController = TextEditingController();
TextEditingController stateController = TextEditingController();
TextEditingController countryController = TextEditingController();
TextEditingController marriedController = TextEditingController();
TextEditingController noOfFamilyMembersController = TextEditingController();
TextEditingController yourPositionInFamilyController = TextEditingController();
TextEditingController middleNameController = TextEditingController();
TextEditingController weightController = TextEditingController();
TextEditingController heightController = TextEditingController();
TextEditingController bloodGroupController = TextEditingController();
TextEditingController emergencyNumberController = TextEditingController();
TextEditingController genderController = TextEditingController();

TextEditingController sinceYearsDiabetesController = TextEditingController();
TextEditingController sinceMonthsDiabetesController = TextEditingController();
TextEditingController sinceYearsHyperTensionController =
    TextEditingController();
TextEditingController sinceMonthsHyperTensionController =
    TextEditingController();
TextEditingController sinceYearsHeartDiseaseController =
    TextEditingController();
TextEditingController sinceMonthsHeartDiseaseController =
    TextEditingController();
TextEditingController sinceYearsThyroidController = TextEditingController();
TextEditingController sinceMonthsThyroidController = TextEditingController();
TextEditingController otherMedicalHistoryController = TextEditingController();
TextEditingController surgicalHistoryController = TextEditingController();
TextEditingController drugAllergyThyroidController = TextEditingController();

int _radioValueGender = -1;

var pickedDate = DateTime(
    DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);

DropDownItem selectedCountry = DropDownItem("", "");
DropDownItem selectedState = DropDownItem("", "");
DropDownItem selectedCity = DropDownItem("", "");

List<DropDownItem> listCountries = [];
List<DropDownItem> listStates = [];
List<DropDownItem> listCities = [];

List<DropDownItem> listCountriesSearchResults = [];
List<DropDownItem> listStatesSearchResults = [];
List<DropDownItem> listCitiesSearchResults = [];

List<String> listBloodGroup = [];

String heightInFeet = "0 Foot 0 Inches";

int weightValue = 0, heightValue = 0;

class EditMyProfileMedicalPatient extends StatefulWidget {
  String imgUrl = "";
  var image;
  String? patientIDP = "", doctorIDP;
  PatientProfileModel? patientProfileModel;
  dynamic jsonPatient;
  String? from = "";

  EditMyProfileMedicalPatient(dynamic jsonPatient, patientIDP,
      {this.doctorIDP, this.from = ""}) {
    this.imgUrl = imgUrl;
    this.jsonPatient = jsonPatient;
    this.patientIDP = patientIDP;
  }

  @override
  State<StatefulWidget> createState() {
    return EditMyProfileMedicalPatientState();
  }
}

String encodeBase64(String text) {
  var bytes = utf8.encode(text);
  return base64.encode(bytes);
}

String decodeBase64(String text) {
  var bytes = base64.decode(text);
  return String.fromCharCodes(bytes);
}

class EditMyProfileMedicalPatientState
    extends State<EditMyProfileMedicalPatient> {
  String type = "";
  List<String> listSinceYears = [];
  List<String> listSinceMonths = [];
  bool isCheckedDiabetes = false;
  bool isCheckedHypertension = false;
  bool isCheckedHeartDisease = false;
  bool isCheckedThyroid = false;

  int selectedStep = 0;
  int lastStep = 3;

  final keyWidget1 = new GlobalKey();
  final keyWidget2 = new GlobalKey();
  final keyWidget3 = new GlobalKey();
  final keyWidget4 = new GlobalKey();

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    print('EditProfile');
    listBloodGroup = [];
    listBloodGroup.add("A+");
    listBloodGroup.add("A-");
    listBloodGroup.add("AB+");
    listBloodGroup.add("AB-");
    listBloodGroup.add("B+");
    listBloodGroup.add("B-");
    listBloodGroup.add("O+");
    listBloodGroup.add("O-");

    for (int i = 0; i < 26; i++) {
      if (i == 0 || i == 1)
        listSinceYears.add(i.toString() + " year");
      else
        listSinceYears.add(i.toString() + " years");
    }

    for (int i = 0; i < 12; i++) {
      if (i == 0 || i == 1)
        listSinceMonths.add(i.toString() + " month");
      else
        listSinceMonths.add(i.toString() + " months");
    }

    getCountriesList();
    if (widget.jsonPatient != null && widget.jsonPatient != "") {
      sinceYearsDiabetesController = TextEditingController(
          text: getStringWithYearAdded(widget.jsonPatient['DiabetesYear']));
      sinceMonthsDiabetesController = TextEditingController(
          text: getStringWithMonthAdded(widget.jsonPatient['DiabetesMonth']));
      sinceYearsHyperTensionController = TextEditingController(
          text: getStringWithYearAdded(widget.jsonPatient['HypertensionYear']));
      sinceMonthsHyperTensionController = TextEditingController(
          text:
              getStringWithMonthAdded(widget.jsonPatient['HypertensionMonth']));
      sinceYearsHeartDiseaseController = TextEditingController(
          text: getStringWithYearAdded(widget.jsonPatient['HeartDiseaseYear']));
      sinceMonthsHeartDiseaseController = TextEditingController(
          text:
              getStringWithMonthAdded(widget.jsonPatient['HeartDiseaseMonth']));
      sinceYearsThyroidController = TextEditingController(
          text: getStringWithYearAdded(widget.jsonPatient['ThyroidYear']));
      sinceMonthsThyroidController = TextEditingController(
          text: getStringWithMonthAdded(widget.jsonPatient['ThyroidMonth']));
      otherMedicalHistoryController =
          TextEditingController(text: widget.jsonPatient['Other']);
      surgicalHistoryController =
          TextEditingController(text: widget.jsonPatient['SurgicalHistory']);
      drugAllergyThyroidController =
          TextEditingController(text: widget.jsonPatient['DrugAllergy']);
      bloodGroupController =
          TextEditingController(text: widget.jsonPatient['BloodGroup']);

      if (widget.jsonPatient['Diabetes'] == "1") isCheckedDiabetes = true;
      if (widget.jsonPatient['Hypertension'] == "1")
        isCheckedHypertension = true;
      if (widget.jsonPatient['HeartDisease'] == "1")
        isCheckedHeartDisease = true;
      if (widget.jsonPatient['Thyroid'] == "1") isCheckedThyroid = true;
    }
    /*if (widget.patientProfileModel.countryIDF != null &&
        widget.patientProfileModel.countryIDF != "null" &&
        widget.patientProfileModel.countryIDF != "") {
      selectedCountry = DropDownItem(widget.patientProfileModel.countryIDF,
          widget.patientProfileModel.country);
      getStatesListNoProgressDialog();
    }

    if (widget.patientProfileModel.stateIDF != null &&
        widget.patientProfileModel.stateIDF != "null" &&
        widget.patientProfileModel.stateIDF != "") {
      selectedState = DropDownItem(widget.patientProfileModel.stateIDF,
          widget.patientProfileModel.state);
      getCitiesListNoProgressDialog();
    }

    firstNameController = TextEditingController(
        text: widget.patientProfileModel.firstName != "-"
            ? widget.patientProfileModel.firstName
            : "");
    lastNameController = TextEditingController(
        text: widget.patientProfileModel.lastName != "-"
            ? widget.patientProfileModel.lastName
            : "");
    mobileNumberController = TextEditingController(
        text: widget.patientProfileModel.mobNo != "-"
            ? widget.patientProfileModel.mobNo
            : "");
    emailController = TextEditingController(
        text: widget.patientProfileModel.emailId != "-"
            ? widget.patientProfileModel.emailId
            : "");
    dobController = TextEditingController(
        text: widget.patientProfileModel.dob != "-"
            ? widget.patientProfileModel.dob
            : "");
    ageController = TextEditingController(
        text: widget.patientProfileModel.age != "-"
            ? widget.patientProfileModel.age
            : "");
    otherMedicalHistoryController = TextEditingController(
        text: widget.patientProfileModel.address != "-"
            ? widget.patientProfileModel.address
            : "");
    cityController = TextEditingController(
        text: widget.patientProfileModel.city != "-"
            ? widget.patientProfileModel.city
            : "");
    stateController = TextEditingController(
        text: widget.patientProfileModel.state != "-"
            ? widget.patientProfileModel.state
            : "");
    countryController = TextEditingController(
        text: widget.patientProfileModel.country != "-"
            ? widget.patientProfileModel.country
            : "");
    marriedController = TextEditingController(
        text: widget.patientProfileModel.married != "-"
            ? widget.patientProfileModel.married
            : "");
    noOfFamilyMembersController = TextEditingController(
        text: widget.patientProfileModel.noOfFamilyMembers != "-"
            ? widget.patientProfileModel.noOfFamilyMembers
            : "");
    yourPositionInFamilyController = TextEditingController(
        text: widget.patientProfileModel.yourPositionInFamily != "-"
            ? widget.patientProfileModel.yourPositionInFamily
            : "");
    middleNameController = TextEditingController(
        text: widget.patientProfileModel.middleName != "-"
            ? widget.patientProfileModel.middleName
            : "");
    weightController = TextEditingController(
        text: widget.patientProfileModel.weight != "-"
            ? widget.patientProfileModel.weight
            : "");
    heightController = TextEditingController(
        text: widget.patientProfileModel.height != "-"
            ? widget.patientProfileModel.height
            : "");
    bloodGroupController = TextEditingController(
        text: widget.patientProfileModel.bloodGroup != "-"
            ? widget.patientProfileModel.bloodGroup
            : "");
    emergencyNumberController = TextEditingController(
        text: widget.patientProfileModel.emergencyNumber != "-"
            ? widget.patientProfileModel.emergencyNumber
            : "");
    if (widget.patientProfileModel.gender == "M")
      _radioValueGender = 0;
    else if (widget.patientProfileModel.gender == "F") _radioValueGender = 1;

    heightValue = int.parse(widget.patientProfileModel.height);
    weightValue = int.parse(widget.patientProfileModel.weight);
    cmToFeet();

    selectedCountry = DropDownItem(widget.patientProfileModel.countryIDF,
        widget.patientProfileModel.country);
    selectedState = DropDownItem(
        widget.patientProfileModel.stateIDF, widget.patientProfileModel.state);
    selectedCity = DropDownItem(
        widget.patientProfileModel.cityIDF, widget.patientProfileModel.city);*/

    getUserType().then((value) {
      type = value;
      setState(() {});
    });
  }

  String getStringWithYearAdded(String yearText) {
    if (yearText != "") {
      int intYear = int.parse(yearText);
      if (intYear == 0 || intYear == 1)
        return intYear.toString() + " year";
      else
        return intYear.toString() + " years";
    }
    return "";
  }

  String getStringWithMonthAdded(String monthText) {
    if (monthText != "") {
      int intMonth = int.parse(monthText);
      if (intMonth == 0 || intMonth == 1)
        return intMonth.toString() + " month";
      else
        return intMonth.toString() + " months";
    }
    return "";
  }

  @override
  void dispose() {
    sinceYearsDiabetesController = TextEditingController();
    sinceMonthsDiabetesController = TextEditingController();
    sinceYearsHyperTensionController = TextEditingController();
    sinceMonthsHyperTensionController = TextEditingController();
    sinceYearsHeartDiseaseController = TextEditingController();
    sinceMonthsHeartDiseaseController = TextEditingController();
    sinceYearsThyroidController = TextEditingController();
    sinceMonthsThyroidController = TextEditingController();
    otherMedicalHistoryController = TextEditingController();
    surgicalHistoryController = TextEditingController();
    drugAllergyThyroidController = TextEditingController();
    bloodGroupController = TextEditingController();
    super.dispose();
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
      listCountries = [];
      listCountriesSearchResults = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listCountries.add(DropDownItem(jo['CountryIDP'], jo['CountryName']));
        listCountriesSearchResults
            .add(DropDownItem(jo['CountryIDP'], jo['CountryName']));
      }
      setState(() {});
    }
  }

  void getStatesList() async {
    String loginUrl = "${baseURL}state_list.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
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
        "CountryIDP" +
        "\"" +
        ":" +
        "\"" +
        selectedCountry.idp +
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
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      listStates = [];
      listStatesSearchResults = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listStates.add(DropDownItem(jo['StateIDP'], jo['StateName']));
        listStatesSearchResults
            .add(DropDownItem(jo['StateIDP'], jo['StateName']));
      }
      setState(() {});
    }
  }

  Future<void> submitMedicalProfile(BuildContext context) async {
    /*if (entryDateController.text.trim() == "") {
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
    } else if (waterTaken == 0) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Water Intake"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }*/

    String getMedicalProfileUrl = "${baseURL}patientmedicalProfileSubmit.php";

    ProgressDialog pr = ProgressDialog(context);

    pr.show();

    String patientUniqueKey = await getPatientUniqueKey();

    String userType = await getUserType();

    debugPrint("Key and type");

    debugPrint(patientUniqueKey);

    debugPrint(userType);

    String diabetes = "0",
        hypertension = "0",
        heartDisease = "0",
        thyroid = "0";
    /*String sinceYearsDiabetes = "",
        sinceYearsHypertension = "",
        sinceYearsHeartDisease = "",
        sinceYearsThyroid = "";
    String sinceMonthsDiabetes = "",
        sinceMonthsHypertension = "",
        sinceMonthsHeartDisease = "",
        sinceMonthsThyroid = "";*/
    if (isCheckedDiabetes) diabetes = "1";
    if (isCheckedHypertension) hypertension = "1";
    if (isCheckedHeartDisease) heartDisease = "1";
    if (isCheckedThyroid) thyroid = "1";

    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP! +
        "\"" +
        "," +
        "\"Diabetes\":\"$diabetes\"," +
        "\"DiabetesYear\":\"${getReplacedTrimmedStringForYearAndMonth(sinceYearsDiabetesController.text.toString())}\"," +
        "\"DiabetesMonth\":\"${getReplacedTrimmedStringForYearAndMonth(sinceMonthsDiabetesController.text.toString())}\"," +
        "\"Hypertension\":\"$hypertension\"," +
        "\"HypertensionYear\":\"${getReplacedTrimmedStringForYearAndMonth(sinceYearsHyperTensionController.text.toString())}\"," +
        "\"HypertensionMonth\":\"${getReplacedTrimmedStringForYearAndMonth(sinceMonthsHyperTensionController.text.toString())}\"," +
        "\"HeartDisease\":\"$heartDisease\"," +
        "\"HeartDiseaseYear\":\"${getReplacedTrimmedStringForYearAndMonth(sinceYearsHeartDiseaseController.text.toString())}\"," +
        "\"HeartDiseaseMonth\":\"${getReplacedTrimmedStringForYearAndMonth(sinceMonthsHeartDiseaseController.text.toString())}\"," +
        "\"Thyroid\":\"$thyroid\"," +
        "\"ThyroidYear\":\"${getReplacedTrimmedStringForYearAndMonth(sinceYearsThyroidController.text.toString())}\"," +
        "\"ThyroidMonth\":\"${getReplacedTrimmedStringForYearAndMonth(sinceMonthsThyroidController.text.toString())}\"," +
        "\"BloodGroup\":\"${bloodGroupController.text.toString()}\"," +
        "\"DrugAllergy\":\"${replaceNewLineBySlashN(drugAllergyThyroidController.text.toString())}\"," +
        "\"SurgicalHistory\":\"${replaceNewLineBySlashN(surgicalHistoryController.text.toString())}\"," +
        "\"Other\":\"${replaceNewLineBySlashN(otherMedicalHistoryController.text.toString())}\"" +
        "}";

    debugPrint("Vital value");
    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: getMedicalProfileUrl,
      //Uri.parse(loginUrl),
      headers: {
        "u": patientUniqueKey,
        "type": userType,
      },

      body: {"getjson": encodedJSONStr},
    );

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
      pr.hide();
      if (widget.from == "onlyAddPatient") {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return MyPatientsScreen();
        })).then((value) {
          Navigator.of(context).pop();
        });
        return;
      } else if (widget.from == "goToOPD") {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SelectOPDProceduresScreen(
              widget.jsonPatient['PatientIDP'].toString(), "", "new");
        })).then((value) {
          Navigator.of(context).pop();
        });
        return;
      }
      if (widget.doctorIDP == null) {
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.of(context).pop();
        });
      } else {
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => ApplyCouponCodeOrPayScreen(
                      widget.doctorIDP!,
                    )),
            (Route<dynamic> route) => false,
          ).then((value) {
            Navigator.of(context).pop();
          });
        });
      }
    }
  }

  String getReplacedTrimmedStringForYearAndMonth(String text) {
    return text
        .replaceFirst(" year", "")
        .replaceFirst(" month", "")
        .replaceFirst("s", "")
        .trim();
  }

  Future<void> submitImageForUpdate(BuildContext context, File image) async {
    ProgressDialog pr = ProgressDialog(context);
    pr.show();

    final multipartRequest = new http.MultipartRequest(
        'POST', Uri.parse("${baseURL}patientProfileSubmit.php"));
    //multipartRequest.headers.addAll(headers);
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    debugPrint("City, State, Country");
    debugPrint(selectedCity.idp);
    debugPrint(selectedState.idp);
    debugPrint(selectedCountry.idp);
    String gender = "";
    String mobNoToValidate = mobileNumberController.text;
    if (mobileNumberController.text.length >= 12) {
      if (mobileNumberController.text.startsWith("+91")) {
        mobNoToValidate = mobileNumberController.text.replaceFirst("+91", "");
      } else if (mobileNumberController.text.startsWith("91")) {
        mobNoToValidate = mobileNumberController.text.replaceFirst("91", "");
      }
    }
    if (_radioValueGender == 0)
      gender = "M";
    else if (_radioValueGender == 1) gender = "F";
    PatientProfileUploadModel modelPatientProfileUpload =
        PatientProfileUploadModel(
            widget.patientIDP!,
            firstNameController.text.trim(),
            lastNameController.text.trim(),
            mobNoToValidate.trim(),
            emailController.text.trim(),
            dobController.text.trim(),
            otherMedicalHistoryController.text.trim(),
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
            emergencyNumberController.text
                .trim()
                .replaceFirst("+", "")
                .replaceFirst("91", ""),
            gender);
    String jsonStr;
    jsonStr = modelPatientProfileUpload.toJson();

    debugPrint("Jsonstr - $jsonStr");

    String encodedJSONStr = encodeBase64(jsonStr);
    multipartRequest.fields['getjson'] = encodedJSONStr;
    Map<String, String> headers = Map();
    headers['u'] = patientUniqueKey;
    headers['type'] = userType;
    multipartRequest.headers.addAll(headers);
    var imgLength = await image.length();
    multipartRequest.files.add(new http.MultipartFile(
        'image', image.openRead(), imgLength,
        filename: image.path));
    var response = await apiHelper.callMultipartApi(multipartRequest);
    //pr.hide();
    debugPrint("Status code - " + response.statusCode.toString());
    response.stream.transform(utf8.decoder).listen((value) async {
      debugPrint("Response of image upload " + value);
      final jsonResponse = json.decode(value);

      ResponseModel model = ResponseModel.fromJSON(jsonResponse);
      String jArrayStr = decodeBase64(jsonResponse['Data']);
      debugPrint("Resonse Upload image ...");
      debugPrint(jArrayStr);
      pr.hide();

      if (model.status == "OK") {
        final snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.of(context).pop();
        });
        /*var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);
      var mobNo = jsonData[0]['MobileNo'];
      Navigator.push(mContext,
          MaterialPageRoute(builder: (context) => VerifyOTPScreen(mobNo)));*/
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      /*final jArray = json.decode(jArrayStr);*/
      /*final jo = jArrayStr[0];*/
      /*var userDetailsStr = await getUserDetails();
        final Map<String, dynamic> jo1 = jsonDecode(userDetailsStr);
        ModelUserDetails modelUserDetails = ModelUserDetails.modelFromJson(jo1);
        modelUserDetails.userPhoto = jo['UserPhoto'].toString();
        callback(modelUserDetails.userPhoto);
        var userDetailsJsonString =
            json.encode(ModelUserDetails.toJson(modelUserDetails));
        setUserDetails(userDetailsJsonString);*/
      //Navigator.pop(context);
      //Navigator.of(context).pop();
      debugPrint("response :" + value.toString());
    });
    /*debugPrint(response.toString());
    final jsonResponse = json.decode(response.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);

    debugPrint("Image upload response : " + response.toString());
    if (model.status == "OK") {
      debugPrint("Image upload response message : " + model.message);
    } else {
      debugPrint("Image upload response error : " + response.toString());
    }*/
  }

  void callback(imgUrl) {
    widget.imgUrl = imgUrl;
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text("Img url - " + imgUrl),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    setState(() {});
  }

  dialogContent(BuildContext context, String title) {
    SizeConfig().init(context);

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

    Future getImageFromCamera() async {
      /*ViewProfileDetailsState.image =
        await ImagePicker.pickImage(source: ImageSource.camera);*/
      //widget.image = await ImagePicker.pickImage(source: ImageSource.camera);
      File imgSelected =
          await chooseImageWithExIfRotate(picker, ImageSource.camera);
      widget.image = imgSelected;
      Navigator.of(context).pop();
      setState(() {});
      //if (image != null) submitImageForUpdate(context, image);
      //_controller.add(image);
    }

    Future removeImage() async {
      /*ViewProfileDetailsState.image =
        await ImagePicker.pickImage(source: ImageSource.camera);*/
      widget.image = null;
      Navigator.of(context).pop();
      setState(() {});
      //if (image != null) submitImageForUpdate(context, image);
      //_controller.add(image);
    }

    Future getImageFromGallery() async {
      /*ViewProfileDetailsState.image =
        await ImagePicker.pickImage(source: ImageSource.gallery);*/
      //widget.image = await ImagePicker.pickImage(source: ImageSource.gallery);
      File imgSelected =
          await chooseImageWithExIfRotate(picker, ImageSource.gallery);
      widget.image = imgSelected;
      Navigator.of(context).pop();
      setState(() {});
      //if (image != null) submitImageForUpdate(context, image);
      //_controller.add(image);
    }

    return Stack(
      children: <Widget>[
        //...bottom card part,
        Container(
          width: SizeConfig.blockSizeHorizontal! * 90,
          height: SizeConfig.blockSizeVertical! * 25,
          padding: EdgeInsets.only(
            top: SizeConfig.blockSizeVertical! * 1,
            bottom: SizeConfig.blockSizeVertical! * 1,
            left: SizeConfig.blockSizeHorizontal! * 1,
            right: SizeConfig.blockSizeHorizontal! * 1,
          ),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  MaterialButton(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.red,
                      size: SizeConfig.blockSizeVertical! * 2.8,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeVertical! * 2.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 0.5,
              ),
              /*MaterialButton(
              onPressed: () {},
              child: Image(
                width: 60,
                height: 60,
                //height: 80,
                image: AssetImage("images/ic_camera.png"),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            MaterialButton(
              onPressed: () {},
              child: Image(
                width: 60,
                height: 60,
                //height: 80,
                image: AssetImage("images/ic_gallery.png"),
              ),
            ),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      getImageFromCamera();
                    },
                    child: Image(
                      fit: BoxFit.contain,
                      width: SizeConfig.blockSizeHorizontal! * 10,
                      height: SizeConfig.blockSizeVertical! * 10,
                      //height: 80,
                      image: AssetImage("images/ic_camera.png"),
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal! * 1,
                  ),
                  MaterialButton(
                    onPressed: () {
                      getImageFromGallery();
                    },
                    child: Image(
                      fit: BoxFit.contain,
                      width: SizeConfig.blockSizeHorizontal! * 10,
                      height: SizeConfig.blockSizeVertical! * 10,
                      //height: 80,
                      image: AssetImage("images/ic_gallery.png"),
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal! * 1,
                  ),
                  MaterialButton(
                    onPressed: () {
                      removeImage();
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: SizeConfig.blockSizeHorizontal! * 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        //...top circlular image part,
        /*Positioned(
        left: Consts.padding,
        right: Consts.padding,
        child: CircleAvatar(
          backgroundColor: Colors.deepOrangeAccent,
          radius: Consts.avatarRadius,
          child: image,
        ),
      ),*/
      ],
    );
  }

  showImageTypeSelectionDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: dialogContent(context, "Select Image from"),
            )
        /* builder: (BuildContext context) =>
          CustomDialogSelectImage(
            title: "Select Image from",
            callback: this.callback,
          ),*/
        );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        /*key: navigatorKey,*/
        appBar: AppBar(
          title: Text("Edit Medical Profile"),
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(
              color: Colorsblack, size: SizeConfig.blockSizeVertical! * 2.2),
          actions: [
            widget.from == "onlyAddPatient" ||
                    widget.doctorIDP != null ||
                    widget.from == "goToOPD"
                ? Center(
                    child: InkWell(
                    onTap: () {
                      if (widget.from == "onlyAddPatient") {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return MyPatientsScreen();
                        })).then((value) {
                          Navigator.of(context).pop();
                        });
                      } else if (widget.from == "goToOPD") {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return SelectOPDProceduresScreen(
                              widget.jsonPatient['PatientIDP'].toString(),
                              "",
                              "new");
                        })).then((value) {
                          Navigator.of(context).pop();
                        });
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ApplyCouponCodeOrPayScreen(
                                      widget.doctorIDP!,
                                    ) /*PatientDashboardScreen(
                                    widget.doctorIDP)*/
                                )).then((value) {
                          Navigator.of(context).pop();
                        });
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: SizeConfig.blockSizeHorizontal! * 3.0,
                      ),
                      child: Text(
                        "Skip & Continue",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeConfig.blockSizeHorizontal! * 3.3),
                      ),
                    ),
                  ))
                : Container(),
          ],
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
        ),
        body: Builder(
          builder: (context) {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                /*StepsIndicator(
                  selectedStep: selectedStep,
                  nbSteps: nbSteps,
                  doneLineColor: Colors.green,
                  doneStepColor: Colors.green,
                  undoneLineColor: Colors.red,
                  lineLength: 20,
                  lineLengthCustomStep: [
                    StepsIndicatorCustomLine(nbStep: 4, lenght: 105)
                  ],
                ),*/
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    /*MaterialButton(
                      color: Colors.red,
                      onPressed: () {
                        if (selectedStep > 0) {
                          setState(() {
                            selectedStep--;
                          });
                        }
                      },
                      child:*/
                    /*),*/

                    /*MaterialButton(
                      color: Colors.green,
                      onPressed: () {
                        if (selectedStep < nbSteps) {
                          setState(() {
                            selectedStep++;
                          });
                        }
                      },
                      child: Icon(
                        Icons.navigate_next,
                        color: Colors.blueGrey,
                        size: SizeConfig.blockSizeHorizontal * 4.5,
                      ),
                    )*/
                  ],
                ),
                /*StepsIndicator(
                    selectedStep: 1,
                    nbSteps: 4,
                    selectedStepColorOut: Colors.blue,
                    selectedStepColorIn: Colors.white,
                    doneStepColor: Colors.blue,
                    unselectedStepColorIn: Colors.red,
                    unselectedStepColorOut: Colors.red,
                    doneLineColor: Colors.blue,
                    undoneLineColor: Colors.red,
                    isHorizontal: true,
                    lineLength: 40,
                    doneLineThickness: 1,
                    undoneLineThickness: 1,
                    doneStepSize: 10,
                    unselectedStepSize: 10,
                    selectedStepSize: 14,
                    selectedStepBorderSize: 1,
                    doneStepWidget: Container(), // Custom Widget
                    unselectedStepWidget: Container(), // Custom Widget
                    selectedStepWidget: Container(), // Custom Widget
                    lineLengthCustomStep: [
                      StepsIndicatorCustomLine(nbStep: 3, lenght: 80)
                    ]
                ),*/
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: SizeConfig.blockSizeHorizontal! * 5),
                              child: Text(
                                "Medical History",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 4.2),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                customBorder: CircleBorder(),
                                onTap: () {
                                  setState(() {
                                    if (selectedStep == 0)
                                      selectedStep = 1;
                                    else
                                      selectedStep = 0;
                                  });
                                },
                                child: Icon(
                                  selectedStep == 0
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.blueGrey,
                                  size: SizeConfig.blockSizeHorizontal! * 6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          key: keyWidget1,
                          visible: selectedStep == 0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: SizeConfig.blockSizeHorizontal! * 3,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: isCheckedDiabetes,
                                          onChanged: (isChecked) {
                                            setState(() {
                                              isCheckedDiabetes = isChecked!;
                                            });
                                          },
                                        ),
                                        Text(
                                          "Diabetes",
                                          style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.w500,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  3.6),
                                        ),
                                      ],
                                    ),
                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 300),
                                      child: isCheckedDiabetes
                                          ? Row(
                                              children: [
                                                SizedBox(
                                                  width: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      5,
                                                ),
                                                Text(
                                                  "Since",
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: SizeConfig
                                                              .blockSizeHorizontal! *
                                                          3.3),
                                                ),
                                                SizedBox(
                                                  width: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      2,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      showSinceYearsSelectionDialog(
                                                          "dia");
                                                    },
                                                    child: IgnorePointer(
                                                      child: TextField(
                                                        controller:
                                                            sinceYearsDiabetesController,
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: SizeConfig
                                                                    .blockSizeVertical! *
                                                                2.3),
                                                        decoration:
                                                            InputDecoration(
                                                          hintStyle: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: SizeConfig
                                                                      .blockSizeVertical! *
                                                                  2.3),
                                                          labelStyle: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: SizeConfig
                                                                      .blockSizeVertical! *
                                                                  2.3),
                                                          labelText: "Years",
                                                          hintText: "",
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      5,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      showSinceMonthsSelectionDialog(
                                                          "dia");
                                                    },
                                                    child: IgnorePointer(
                                                      child: TextField(
                                                        controller:
                                                            sinceMonthsDiabetesController,
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: SizeConfig
                                                                    .blockSizeVertical! *
                                                                2.3),
                                                        decoration:
                                                            InputDecoration(
                                                          hintStyle: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: SizeConfig
                                                                      .blockSizeVertical! *
                                                                  2.3),
                                                          labelStyle: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: SizeConfig
                                                                      .blockSizeVertical! *
                                                                  2.3),
                                                          labelText: "Months",
                                                          hintText: "",
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          : Container(),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: SizeConfig.blockSizeHorizontal! * 3,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: isCheckedHypertension,
                                          onChanged: (isChecked) {
                                            setState(() {
                                              isCheckedHypertension =
                                                  isChecked!;
                                            });
                                          },
                                        ),
                                        Text(
                                          "Hypertension",
                                          style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.w500,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  3.6),
                                        ),
                                      ],
                                    ),
                                    AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        child: isCheckedHypertension
                                            ? Row(
                                                children: [
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        5,
                                                  ),
                                                  Text(
                                                    "Since",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            3.3),
                                                  ),
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        2,
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        showSinceYearsSelectionDialog(
                                                            "hyper");
                                                      },
                                                      child: IgnorePointer(
                                                        child: TextField(
                                                          controller:
                                                              sinceYearsHyperTensionController,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontSize: SizeConfig
                                                                      .blockSizeVertical! *
                                                                  2.3),
                                                          decoration:
                                                              InputDecoration(
                                                            hintStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            labelStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            labelText: "Years",
                                                            hintText: "",
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        5,
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        showSinceMonthsSelectionDialog(
                                                            "hyper");
                                                      },
                                                      child: IgnorePointer(
                                                        child: TextField(
                                                          controller:
                                                              sinceMonthsHyperTensionController,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontSize: SizeConfig
                                                                      .blockSizeVertical! *
                                                                  2.3),
                                                          decoration:
                                                              InputDecoration(
                                                            hintStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            labelStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            labelText: "Months",
                                                            hintText: "",
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )
                                            : Container())
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: SizeConfig.blockSizeHorizontal! * 3,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: isCheckedHeartDisease,
                                          onChanged: (isChecked) {
                                            setState(() {
                                              isCheckedHeartDisease =
                                                  isChecked!;
                                            });
                                          },
                                        ),
                                        Text(
                                          "Heart Disease",
                                          style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.w500,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  3.6),
                                        ),
                                      ],
                                    ),
                                    AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        child: isCheckedHeartDisease
                                            ? Row(
                                                children: [
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        5,
                                                  ),
                                                  Text(
                                                    "Since",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            3.3),
                                                  ),
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        2,
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        showSinceYearsSelectionDialog(
                                                            "heart");
                                                      },
                                                      child: IgnorePointer(
                                                        child: TextField(
                                                          controller:
                                                              sinceYearsHeartDiseaseController,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontSize: SizeConfig
                                                                      .blockSizeVertical! *
                                                                  2.3),
                                                          decoration:
                                                              InputDecoration(
                                                            hintStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            labelStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            labelText: "Years",
                                                            hintText: "",
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        5,
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        showSinceMonthsSelectionDialog(
                                                            "heart");
                                                      },
                                                      child: IgnorePointer(
                                                        child: TextField(
                                                          controller:
                                                              sinceMonthsHeartDiseaseController,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontSize: SizeConfig
                                                                      .blockSizeVertical! *
                                                                  2.3),
                                                          decoration:
                                                              InputDecoration(
                                                            hintStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            labelStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            labelText: "Months",
                                                            hintText: "",
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )
                                            : Container())
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: SizeConfig.blockSizeHorizontal! * 3,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: isCheckedThyroid,
                                          onChanged: (isChecked) {
                                            setState(() {
                                              isCheckedThyroid = isChecked!;
                                            });
                                          },
                                        ),
                                        Text(
                                          "Thyroid",
                                          style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.w500,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  3.6),
                                        ),
                                      ],
                                    ),
                                    AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        child: isCheckedThyroid
                                            ? Row(
                                                children: [
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        5,
                                                  ),
                                                  Text(
                                                    "Since",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            3.3),
                                                  ),
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        2,
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        showSinceYearsSelectionDialog(
                                                            "thyroid");
                                                      },
                                                      child: IgnorePointer(
                                                        child: TextField(
                                                          controller:
                                                              sinceYearsThyroidController,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontSize: SizeConfig
                                                                      .blockSizeVertical! *
                                                                  2.3),
                                                          decoration:
                                                              InputDecoration(
                                                            hintStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            labelStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            labelText: "Years",
                                                            hintText: "",
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        5,
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        showSinceMonthsSelectionDialog(
                                                            "thyroid");
                                                      },
                                                      child: IgnorePointer(
                                                        child: TextField(
                                                          controller:
                                                              sinceMonthsThyroidController,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontSize: SizeConfig
                                                                      .blockSizeVertical! *
                                                                  2.3),
                                                          decoration:
                                                              InputDecoration(
                                                            hintStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            labelStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            labelText: "Months",
                                                            hintText: "",
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )
                                            : Container()),
                                    /*SizedBox(
                            height: SizeConfig.blockSizeHorizontal * 3,
                          ),
                          Text(
                            "Other",
                            style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                                fontSize: SizeConfig.blockSizeHorizontal * 3.6),
                          ),*/
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: SizeConfig.blockSizeHorizontal! *
                                            90,
                                        padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal! *
                                                1),
                                        child: TextField(
                                          controller:
                                              otherMedicalHistoryController,
                                          textAlign: TextAlign.left,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: 5,
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: SizeConfig
                                                      .blockSizeVertical! *
                                                  2.3),
                                          decoration: InputDecoration(
                                            hintStyle: TextStyle(
                                                color: Colors.black,
                                                fontSize: SizeConfig
                                                        .blockSizeVertical! *
                                                    2.3),
                                            labelStyle: TextStyle(
                                                color: Colors.black,
                                                fontSize: SizeConfig
                                                        .blockSizeVertical! *
                                                    2.3),
                                            labelText: "Other",
                                            hintText: "",
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          key: keyWidget2,
                          visible: true /*selectedStep == 1*/,
                          child: Container(
                            width: SizeConfig.blockSizeHorizontal! * 90,
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 1),
                            child: TextField(
                              controller: surgicalHistoryController,
                              textAlign: TextAlign.left,
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize:
                                      SizeConfig.blockSizeVertical! * 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                labelText: "Surgical History",
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          key: keyWidget3,
                          visible: true /*selectedStep == 2*/,
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 90,
                              padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal! * 1),
                              child: TextField(
                                controller: drugAllergyThyroidController,
                                textAlign: TextAlign.start,
                                keyboardType: TextInputType.multiline,
                                maxLines: 5,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.3),
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.3),
                                  labelText: "Drug Allergy",
                                  hintText: "",
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          key: keyWidget4,
                          visible: true /*selectedStep == 3*/,
                          child: InkWell(
                            onTap: () {
                              showBloodGroupSelectionDialog(listBloodGroup);
                            },
                            child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 90,
                              padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal! * 1),
                              child: IgnorePointer(
                                child: TextField(
                                  controller: bloodGroupController,
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.3),
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            SizeConfig.blockSizeVertical! *
                                                2.3),
                                    labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            SizeConfig.blockSizeVertical! *
                                                2.3),
                                    labelText: "Blood Group",
                                    hintText: "",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: SizeConfig.blockSizeVertical! * 12,
                  padding: EdgeInsets.only(
                      right: SizeConfig.blockSizeHorizontal! * 3.5,
                      top: SizeConfig.blockSizeVertical! * 3.5),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: SizeConfig.blockSizeHorizontal! * 12,
                      height: SizeConfig.blockSizeHorizontal! * 12,
                      child: RawMaterialButton(
                        onPressed: () {
                          //if (selectedStep == lastStep)
                          submitMedicalProfile(context);
                        },
                        elevation: 2.0,
                        fillColor: Color(
                            0xFF06A759) /*selectedStep == lastStep?Color(0xFF06A759):Colors.grey[400]*/,
                        child: Image(
                          width: SizeConfig.blockSizeHorizontal! * 5.5,
                          height: SizeConfig.blockSizeHorizontal! * 5.5,
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
            );
          },
        ));
  }

  void _handleRadioValueChange(value) {
    setState(() {
      _radioValueGender = value;
    });
  }

  void callbackFromBMI() {
    setState(() {});
  }

  void callbackFromCountryDialog(String type) {
    setState(() {
      if (type == "Country") {
        getStatesList();
      }
      if (type == "State") {
        getCitiesList();
      }
      if (type == "City") {}
    });
  }

  void showCountrySelectionDialog(List<DropDownItem> list, String type) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            CountryDialog(list, type, callbackFromCountryDialog));
  }

  void showBloodGroupSelectionDialog(List<String> list) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  height: SizeConfig.blockSizeVertical! * 8,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal! * 6.2,
                          ),
                          onTap: () {
                            /*setState(() {
                          widget.type = "My type";
                        });*/
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 6,
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal! * 50,
                          height: SizeConfig.blockSizeVertical! * 8,
                          child: Center(
                            child: Text(
                              "Select Blood Group",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4.8,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: list.length,
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () {
                              bloodGroupController =
                                  TextEditingController(text: list[index]);
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Container(
                                    width: SizeConfig.blockSizeHorizontal! * 90,
                                    padding: EdgeInsets.only(
                                      top: 5,
                                      bottom: 5,
                                      left: 5,
                                      right: 5,
                                    ),
                                    decoration: new BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.rectangle,
                                      border: Border(
                                        bottom: BorderSide(
                                            width: 2.0, color: Colors.grey),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10.0,
                                          offset: const Offset(0.0, 10.0),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        list[index],
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ))));
                      }),
                ),
                /*Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: MaterialButton(
                        color: Colors.red,
                        onPressed: () {
                          Navigator.of(context).pop(); // To close the dialog
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ))*/
              ],
            )));
  }

  void showSinceYearsSelectionDialog(String identifier) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  height: SizeConfig.blockSizeVertical! * 8,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal! * 6.2,
                          ),
                          onTap: () {
                            /*setState(() {
                          widget.type = "My type";
                        });*/
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 6,
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal! * 50,
                          height: SizeConfig.blockSizeVertical! * 8,
                          child: Center(
                            child: Text(
                              "Select Number of Years",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4.2,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: listSinceYears.length,
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () {
                              if (identifier == "dia") {
                                sinceYearsDiabetesController =
                                    TextEditingController(
                                        text: listSinceYears[index]);
                              } else if (identifier == "hyper") {
                                sinceYearsHyperTensionController =
                                    TextEditingController(
                                        text: listSinceYears[index]);
                              } else if (identifier == "heart") {
                                sinceYearsHeartDiseaseController =
                                    TextEditingController(
                                        text: listSinceYears[index]);
                              } else if (identifier == "thyroid") {
                                sinceYearsThyroidController =
                                    TextEditingController(
                                        text: listSinceYears[index]);
                              }
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Container(
                                    width: SizeConfig.blockSizeHorizontal! * 90,
                                    padding: EdgeInsets.only(
                                      top: 5,
                                      bottom: 5,
                                      left: 5,
                                      right: 5,
                                    ),
                                    decoration: new BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.rectangle,
                                      border: Border(
                                        bottom: BorderSide(
                                            width: 2.0, color: Colors.grey),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10.0,
                                          offset: const Offset(0.0, 10.0),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        listSinceYears[index],
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ))));
                      }),
                ),
              ],
            )));
  }

  void showSinceMonthsSelectionDialog(String identifier) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  height: SizeConfig.blockSizeVertical! * 8,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal! * 6.2,
                          ),
                          onTap: () {
                            /*setState(() {
                          widget.type = "My type";
                        });*/
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 6,
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal! * 50,
                          height: SizeConfig.blockSizeVertical! * 8,
                          child: Center(
                            child: Text(
                              "Select Number of Months",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4.2,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: listSinceMonths.length,
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () {
                              if (identifier == "dia") {
                                sinceMonthsDiabetesController =
                                    TextEditingController(
                                        text: listSinceMonths[index]);
                              } else if (identifier == "hyper") {
                                sinceMonthsHyperTensionController =
                                    TextEditingController(
                                        text: listSinceMonths[index]);
                              } else if (identifier == "heart") {
                                sinceMonthsHeartDiseaseController =
                                    TextEditingController(
                                        text: listSinceMonths[index]);
                              } else if (identifier == "thyroid") {
                                sinceMonthsThyroidController =
                                    TextEditingController(
                                        text: listSinceMonths[index]);
                              }
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Container(
                                    width: SizeConfig.blockSizeHorizontal! * 90,
                                    padding: EdgeInsets.only(
                                      top: 5,
                                      bottom: 5,
                                      left: 5,
                                      right: 5,
                                    ),
                                    decoration: new BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.rectangle,
                                      border: Border(
                                        bottom: BorderSide(
                                            width: 2.0, color: Colors.grey),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10.0,
                                          offset: const Offset(0.0, 10.0),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        listSinceMonths[index],
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ))));
                      }),
                ),
              ],
            )));
  }

  void getStatesListNoProgressDialog() async {
    String loginUrl = "${baseURL}state_list.php";
    ProgressDialog pr;
    /*Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr.show();
    });*/
    //listIcon = new List();
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
        "CountryIDP" +
        "\"" +
        ":" +
        "\"" +
        selectedCountry.idp +
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
    /*pr.hide();*/
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      listStates = [];
      listStatesSearchResults = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listStates.add(DropDownItem(jo['StateIDP'], jo['StateName']));
        listStatesSearchResults
            .add(DropDownItem(jo['StateIDP'], jo['StateName']));
      }
      setState(() {});
    }
  }

  void getCitiesList() async {
    String loginUrl = "${baseURL}city_list.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
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
        "StateIDP" +
        "\"" +
        ":" +
        "\"" +
        selectedState.idp +
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
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      listCities = [];
      listCitiesSearchResults = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listCities.add(DropDownItem(jo['CityIDP'], jo['CityName']));
        listCitiesSearchResults
            .add(DropDownItem(jo['CityIDP'], jo['CityName']));
      }
      setState(() {});
    }
  }

  void getCitiesListNoProgressDialog() async {
    String loginUrl = "${baseURL}city_list.php";
    ProgressDialog? pr;
    /*Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr.show();
    });*/
    //listIcon = new List();
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
        "StateIDP" +
        "\"" +
        ":" +
        "\"" +
        selectedState.idp +
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
    /*pr.hide();*/
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      listCities = [];
      listCitiesSearchResults = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listCities.add(DropDownItem(jo['CityIDP'], jo['CityName']));
        listCitiesSearchResults
            .add(DropDownItem(jo['CityIDP'], jo['CityName']));
      }
      setState(() {});
    }
  }

  void showDateSelectionDialog() async {
    DateTime firstDate = DateTime.now().subtract(Duration(days: 365 * 100));
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: pickedDate,
        firstDate: firstDate,
        lastDate: DateTime(DateTime.now().year - 18, DateTime.now().month,
            DateTime.now().day));

    if (date != null) {
      pickedDate = date;
      var formatter = new DateFormat('dd-MM-yyyy');
      String formatted = formatter.format(pickedDate);
      dobController = TextEditingController(text: formatted);
      setState(() {});
    }
  }
}

class CountryDialog extends StatefulWidget {
  List<DropDownItem> list;
  String type;
  Function callbackFromCountryDialog;

  CountryDialog(this.list, this.type, this.callbackFromCountryDialog);

  @override
  State<StatefulWidget> createState() {
    return CountryDialogState();
  }
}

class CountryDialogState extends State<CountryDialog> {
  Icon? icon;

  Widget? titleWidget;

  @override
  void initState() {
    super.initState();
    icon = Icon(
      Icons.search,
      color: Colors.blue,
      size: SizeConfig.blockSizeHorizontal! * 6.2,
    );

    titleWidget = Text(
      "Select ${widget.type}",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: SizeConfig.blockSizeHorizontal! * 4.8,
        fontWeight: FontWeight.bold,
        color: Colors.green,
        decoration: TextDecoration.none,
      ),
    );
  }

  var searchController = TextEditingController();
  var focusNode = new FocusNode();

  void getCitiesList() async {
    String loginUrl = "${baseURL}city_list.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
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
        "" +
        "\"" +
        "," +
        "\"" +
        "StateIDP" +
        "\"" +
        ":" +
        "\"" +
        selectedState.idp +
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
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      listCities = [];
      listCitiesSearchResults = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listCities.add(DropDownItem(jo['CityIDP'], jo['CityName']));
        listCitiesSearchResults
            .add(DropDownItem(jo['CityIDP'], jo['CityName']));
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              height: SizeConfig.blockSizeVertical! * 8,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.red,
                        size: SizeConfig.blockSizeHorizontal! * 6.2,
                      ),
                      onTap: () {
                        /*setState(() {
                          widget.type = "My type";
                        });*/
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! * 6,
                    ),
                    Container(
                      width: SizeConfig.blockSizeHorizontal! * 50,
                      height: SizeConfig.blockSizeVertical! * 8,
                      child: Center(
                        child: titleWidget,
                      ),
                    ),
                    Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 1),
                            child: InkWell(
                              child: icon,
                              onTap: () {
                                setState(() {
                                  if (icon!.icon == Icons.search) {
                                    searchController =
                                        TextEditingController(text: "");
                                    focusNode.requestFocus();
                                    this.icon = Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                      size:
                                          SizeConfig.blockSizeHorizontal! * 6.2,
                                    );
                                    this.titleWidget = TextField(
                                      controller: searchController,
                                      focusNode: focusNode,
                                      cursorColor: Colors.black,
                                      onChanged: (text) {
                                        setState(() {
                                          if (widget.type == "Country")
                                            widget.list = listCountries
                                                .where((dropDownObj) =>
                                                    dropDownObj.value
                                                        .toLowerCase()
                                                        .contains(
                                                            text.toLowerCase()))
                                                .toList();
                                          else if (widget.type == "State")
                                            widget.list = listStates
                                                .where((dropDownObj) =>
                                                    dropDownObj.value
                                                        .toLowerCase()
                                                        .contains(
                                                            text.toLowerCase()))
                                                .toList();
                                          else if (widget.type == "City")
                                            widget.list =
                                                listCitiesSearchResults
                                                    .where((dropDownObj) =>
                                                        dropDownObj.value
                                                            .toLowerCase()
                                                            .contains(text
                                                                .toLowerCase()))
                                                    .toList();
                                        });
                                      },
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! *
                                                4.0,
                                      ),
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical! *
                                                    2.1),
                                        labelStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical! *
                                                    2.1),
                                        //hintStyle: TextStyle(color: Colors.grey),
                                        hintText: "Search ${widget.type}",
                                      ),
                                    );
                                  } else {
                                    this.icon = Icon(
                                      Icons.search,
                                      color: Colors.blue,
                                      size:
                                          SizeConfig.blockSizeHorizontal! * 6.2,
                                    );
                                    this.titleWidget = Text(
                                      "Select ${widget.type}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! *
                                                4.8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        decoration: TextDecoration.none,
                                      ),
                                    );
                                    if (widget.type == "Country")
                                      widget.list = listCountries;
                                    else if (widget.type == "State")
                                      widget.list = listStates;
                                    else if (widget.type == "City")
                                      widget.list = listCities;
                                  }
                                });
                                //Navigator.of(context).pop();
                              },
                            ),
                          )),
                    )
                  ],
                ),
              ),
            ),
            /*Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "Select $type :-",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),*/
            Expanded(
              child: ListView.builder(
                  itemCount: widget.list.length,
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          if (widget.type == "Country") {
                            selectedCountry = widget.list[index];
                            countryController = TextEditingController(
                                text: selectedCountry.value);
                            Navigator.of(context).pop();
                            //setState(() {});
                            //getStatesList();
                            widget.callbackFromCountryDialog(widget.type);
                          }
                          if (widget.type == "State") {
                            selectedState = widget.list[index];
                            stateController = TextEditingController(
                                text: selectedState.value);
                            Navigator.of(context).pop();
                            //setState(() {});
                            //getCitiesList();
                            widget.callbackFromCountryDialog(widget.type);
                          }
                          if (widget.type == "City") {
                            selectedCity = widget.list[index];
                            cityController =
                                TextEditingController(text: selectedCity.value);
                            Navigator.of(context).pop();
                            //setState(() {});
                            widget.callbackFromCountryDialog(widget.type);
                          }
                        },
                        child: Padding(
                            padding: EdgeInsets.all(0.0),
                            child: Container(
                                width: SizeConfig.blockSizeHorizontal! * 90,
                                padding: EdgeInsets.only(
                                  top: 5,
                                  bottom: 5,
                                  left: 5,
                                  right: 5,
                                ),
                                decoration: new BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 2.0, color: Colors.grey),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10.0,
                                      offset: const Offset(0.0, 10.0),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    widget.list[index].value,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ))));
                  }),
            ),
            /*Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: MaterialButton(
                        color: Colors.red,
                        onPressed: () {
                          Navigator.of(context).pop(); // To close the dialog
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ))*/
          ],
        ));
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
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "PatientIDP" + "\"" + ":" + "\"" + "" + "\"" + "}";

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
      listCountries = [];
      listCountriesSearchResults = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listCountries.add(DropDownItem(jo['CountryIDP'], jo['CountryName']));
        listCountriesSearchResults
            .add(DropDownItem(jo['CountryIDP'], jo['CountryName']));
      }
      setState(() {});
    }
  }

  void getStatesList() async {
    String loginUrl = "${baseURL}state_list.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
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
        "" +
        "\"" +
        "," +
        "\"" +
        "CountryIDP" +
        "\"" +
        ":" +
        "\"" +
        selectedCountry.idp +
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
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      listStates = [];
      listCitiesSearchResults = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listStates.add(DropDownItem(jo['StateIDP'], jo['StateName']));
        listCitiesSearchResults
            .add(DropDownItem(jo['StateIDP'], jo['StateName']));
      }
      setState(() {});
    }
  }
}

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  int min;

  int max;
  String title = "";
  double value;
  final fullWidth;
  String unit;
  Function? callbackFromBMI;

  SliderWidget(
      {this.sliderHeight = 50,
      this.max = 1000,
      this.min = 0,
      this.value = 0,
      this.title = "",
      this.fullWidth = true,
      this.unit = "",
      this.callbackFromBMI});

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  double _value = 0;

  @override
  void initState() {
    //_value = widget.value / (widget.max - widget.min);
    _value = widget.value;
    if (widget.title == "Weight") {
      weightValue = _value.round();
      //widget.callbackFromBMI();
    } else if (widget.title == "Height") {
      heightValue = _value.round();
      //widget.callbackFromBMI();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double paddingFactor = .2;

    if (this.widget.fullWidth) paddingFactor = .3;

    return Container(
      padding: widget.title == "Systolic" || widget.title == "Diastolic"
          ? EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal! * 8,
              right: SizeConfig.blockSizeHorizontal! * 3,
            )
          : EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal! * 3,
              right: SizeConfig.blockSizeHorizontal! * 3,
            ),
      width: this.widget.fullWidth
          ? double.infinity
          : (this.widget.sliderHeight) * 5.5,
      height: SizeConfig.blockSizeVertical! * 13,
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.all(
          Radius.circular((this.widget.sliderHeight * .3)),
        ),
      ),
      child: Padding(
          padding: EdgeInsets.fromLTRB(this.widget.sliderHeight * paddingFactor,
              2, this.widget.sliderHeight * paddingFactor, 2),
          child: Column(
            children: <Widget>[
              Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: <Widget>[
                      Text(
                        '${this.widget.title} - ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        ' ${widget.value.round()} ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 5.3,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        ' (${widget.unit})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
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
                            fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  )),
              Row(
                children: <Widget>[
                  Text(
                    '${this.widget.min}',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal! * 1.5,
                  ),
                  Expanded(
                    child: Center(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.teal.withOpacity(1),
                          inactiveTrackColor: Colors.teal.withOpacity(.5),
                          trackHeight: 2.0,
                          /*thumbShape: CustomSliderThumbCircle(
                            thumbRadius: this.widget.sliderHeight * .3,
                            min: 0,
                            max: this.widget.max,
                          ),*/
                          overlayColor: Colors.teal.withOpacity(.4),
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 5.0),
                          thumbColor: Colors.blueGrey,
                          //valueIndicatorColor: Colors.white,
                          activeTickMarkColor: Colors.teal,
                          inactiveTickMarkColor: Colors.teal.withOpacity(.7),
                        ),
                        child: Slider(
                            min: this.widget.min.toDouble(),
                            max: this.widget.max.toDouble(),
                            value: widget.value,
                            /*value: widget.title == "Pulse"
                                ? pulseValue
                                : (widget.title == "Systolic"
                                    ? bpSystolicValue
                                    : (widget.title == "Diastolic"
                                        ? bpDiastolicValue
                                        : (widget.title == "Temperature"
                                            ? tempValue
                                            : spo2Value))),*/
                            onChanged: (val) {
                              setState(() {
                                _value = val;
                                widget.value = val;
                                if (widget.title == "Weight") {
                                  weightValue = widget.value.round();
                                  widget.callbackFromBMI!();
                                } else if (widget.title == "Height") {
                                  heightValue = widget.value.round();
                                  cmToFeet();
                                  widget.callbackFromBMI!();
                                }
                                debugPrint(widget.value.round().toString());
                              });
                            }),
                      ),
                    ),
                  ),
                  Text(
                    '${this.widget.max}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ],
          )),
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
}
