import 'dart:convert';
import 'dart:io';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:silvertouch/app_screens/doctor_dashboard_screen.dart';
import 'package:silvertouch/app_screens/edit_my_profile_medical_patient.dart';
import 'package:silvertouch/app_screens/select_opd_procedures_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/doctor_patient_profile_upload_model.dart';
import 'package:silvertouch/podo/dropdown_item.dart';
import 'package:silvertouch/podo/model_profile_patient.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';
import 'package:silvertouch/widgets/autocomplete_custom.dart';
import '../utils/color.dart';
import 'custom_dialog_select_image_from.dart';

final focus = FocusNode();
TextEditingController patientIDController = TextEditingController();
TextEditingController firstNameController = TextEditingController();
TextEditingController lastNameController = TextEditingController();
TextEditingController mobileNumberController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController dobController = TextEditingController();
TextEditingController ageController = TextEditingController();
TextEditingController addressController = TextEditingController();
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

var pickedDate =
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

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

List<String> listPatientIDP = [];
List<String> listPatientID = [];
List<String> listFirstName = [];
List<String> listMiddleName = [];
List<String> listLastName = [];
List<String> listMobileNo = [];
List<String> listEmail = [];

List<String> listFullNameDetails = [];

List<String> listAge = [];
List<String> listGender = [];

ScrollController _scrollController = new ScrollController();

String patientIDPSelected = "";
String patientDetailsSelected = "";
bool initialState = true;

int _radioValueGender = -1;

String onTapStatus = "";
int weightValue = 0, heightValue = 0;
String heightInFeet = "0 Foot 0 Inches";

class AddPatientScreenDoctor extends StatefulWidget {
  String imgUrl = "";
  var image;
  PatientProfileModel? patientProfileModel;
  String from = '';
  var campID;

  AddPatientScreenDoctor({from = '', campID}) {
    this.from = from;
    this.campID = campID;
  }

  @override
  State<StatefulWidget> createState() {
    return AddPatientScreenDoctorState();
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

class AddPatientScreenDoctorState extends State<AddPatientScreenDoctor> {
  dynamic jsonObj;
  TextEditingController sinceYearsThyroidController = TextEditingController();
  TextEditingController sinceMonthsThyroidController = TextEditingController();
  TextEditingController otherMedicalHistoryController = TextEditingController();
  TextEditingController surgicalHistoryController = TextEditingController();
  TextEditingController drugAllergyThyroidController = TextEditingController();
  bool isCheckedDiabetes = false;
  bool isCheckedHypertension = false;
  bool isCheckedHeartDisease = false;
  bool isCheckedThyroid = false;

  GlobalKey<ProgressDialogWithPercentageState> progressKey = GlobalKey();
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    onTapStatus = "";
    listBloodGroup = [];
    listBloodGroup.add("A+");
    listBloodGroup.add("A-");
    listBloodGroup.add("AB+");
    listBloodGroup.add("AB-");
    listBloodGroup.add("B+");
    listBloodGroup.add("B-");
    listBloodGroup.add("O-");
    listBloodGroup.add("O+");
    /*if (widget.from != "onlyAddPatient")*/
    getPatientsList(context);

    widget.patientProfileModel = PatientProfileModel("", "", "", "", "", "", "",
        "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
    //getCountriesList();
    if (widget.patientProfileModel!.countryIDF != null &&
        widget.patientProfileModel!.countryIDF != "null" &&
        widget.patientProfileModel!.countryIDF != "") {
      selectedCountry = DropDownItem(widget.patientProfileModel!.countryIDF!,
          widget.patientProfileModel!.country!);
      /*if (widget.from != "onlyAddPatient")*/
      getStatesListNoProgressDialog();
    }

    getCityIDF().then((value) => selectedCity.idp = value);
    getStateIDF().then((value) => selectedState.idp = value);
    getCityName().then((value) {
      selectedCity.value = value;
      cityController = TextEditingController(text: value);
    });

    /*if (widget.from != "onlyAddPatient")*/
    getCitiesList();

    if (widget.patientProfileModel!.stateIDF != null &&
        widget.patientProfileModel!.stateIDF != "null" &&
        widget.patientProfileModel!.stateIDF != "") {
      selectedState = DropDownItem(widget.patientProfileModel!.stateIDF!,
          widget.patientProfileModel!.state!);
      /*if (widget.from != "onlyAddPatient")*/
      getCitiesListNoProgressDialog();
    }
  }

  @override
  void dispose() {
    onTapStatus = "";
    initialState = true;
    patientIDController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    mobileNumberController = TextEditingController();
    emailController = TextEditingController();
    dobController = TextEditingController();
    ageController = TextEditingController();
    addressController = TextEditingController();
    cityController = TextEditingController();
    stateController = TextEditingController();
    countryController = TextEditingController();
    marriedController = TextEditingController();
    noOfFamilyMembersController = TextEditingController();
    yourPositionInFamilyController = TextEditingController();
    middleNameController = TextEditingController();
    weightController = TextEditingController();
    heightController = TextEditingController();
    bloodGroupController = TextEditingController();
    emergencyNumberController = TextEditingController();
    patientIDController = TextEditingController();
    _radioValueGender = -1;

    patientIDPSelected = "";
    patientDetailsSelected = "";

    pickedDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    selectedCountry = DropDownItem("", "");
    selectedState = DropDownItem("", "");
    selectedCity = DropDownItem("", "");

    listCountries = [];
    listStates = [];
    listCities = [];

    listCountriesSearchResults = [];
    listStatesSearchResults = [];
    listCitiesSearchResults = [];

    listBloodGroup = [];

    listPatientIDP = [];
    listPatientID = [];
    listFirstName = [];
    listMiddleName = [];
    listLastName = [];
    listMobileNo = [];
    listEmail = [];
    listFullNameDetails = [];
    listAge = [];
    listGender = [];
    patientIDPSelected = "";
    patientDetailsSelected = "";

    weightValue = 0;
    heightValue = 0;
    super.dispose();
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
    pr?.hide();
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
      widget.image = await ImageCropper().cropImage(
        sourcePath: imgSelected.path,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
          )
        ],
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
      );
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
  void didUpdateWidget(AddPatientScreenDoctor oldWidget) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    /*_scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOut);*/
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        /*key: navigatorKey,*/
        backgroundColor: colorGrayApp,
        appBar: AppBar(
          title: Text(
              widget.from != "onlyAddPatient"
                  ? "Select or Add Patient"
                  : "Add New Patient",
              style: TextStyle(color: black)),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
              color: black, size: SizeConfig.blockSizeVertical! * 3),
          actions: [
            widget.from != "onlyAddPatient"
                ? Padding(
                    padding:
                        EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 2),
                    child: InkWell(
                      onTap: () async {
                        var result = await BarcodeScanner.scan();
                        if (result.type.toString() != "Cancelled" &&
                            result.rawContent != "") {
                          String decodedContent =
                              decodeBase64(result.rawContent);
                          patientIDPSelected =
                              decodedContent.replaceAll("patient-", "");
                          patientDetailsSelected = listFullNameDetails[
                              listPatientIDP.indexOf(patientIDPSelected)];
                          initialState = false;
                          getAllPatientFields(patientIDPSelected, context);

                          /*patientIDPSelected = listPatientIDP[listCommon.indexOf(text)];
                          patientDetailsSelected = listCommon[listCommon.indexOf(text)];
                          getAllPatientFields(listPatientIDP[listCommon.indexOf(text)], context);
                          anyController = TextEditingController(text: text);
                          initialState = false;*/
                        }
                      },
                      child: Image(
                        image: AssetImage("images/ic_qr_code_scan.png"),
                        width: SizeConfig.blockSizeHorizontal! * 5.0,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(),
          ],
          toolbarTextStyle: TextTheme(
                  titleMedium: TextStyle(
                      color: black,
                      fontFamily: "Ubuntu",
                      fontSize: SizeConfig.blockSizeVertical! * 2.5))
              .bodyMedium,
          titleTextStyle: TextTheme(
                  titleMedium: TextStyle(
                      color: black,
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
                Expanded(
                    child: ListView(
                  controller: _scrollController,
                  shrinkWrap: true,
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            if (patientIDPSelected == "")
                              showImageTypeSelectionDialog(context);
                          },
                          child: (widget.image != null)
                              ? /*Container(
                            height: 200,
                            decoration: BoxDecoration(
                                color: Colors.green,
                                image: DecorationImage(
                                    image: MemoryImage(widget.bytes))))*/
                              CircleAvatar(
                                  radius: 65,
                                  backgroundColor: white,
                                  child: CircleAvatar(
                                    backgroundImage: FileImage(widget.image),
                                    radius: 60.0,
                                  ),
                                )
                              : (widget.imgUrl != ""
                                  ? CircleAvatar(
                                      radius: 65,
                                      backgroundColor: white,
                                      child: CircleAvatar(
                                        radius: 60.0,
                                        backgroundImage: NetworkImage(
                                            "$userImgUrl${widget.imgUrl}"),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 65,
                                      backgroundColor: white,
                                      child: CircleAvatar(
                                        child: Image.asset(
                                            "images/ic_user_placeholder_new.png",
                                            scale: 3),
                                        radius: 60.0,
                                        backgroundColor: Colors.white,
                                        /*),*/
                                      ),
                                    )),
                        ),
                        Visibility(
                          visible: /*patientIDPSelected == "" ? true : */ false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 80,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (patientIDPSelected == "")
                                    showImageTypeSelectionDialog(context);
                                },
                                child: CircleAvatar(
                                  radius: 25.0,
                                  child: Image(
                                    width: 30,
                                    height: 30,
                                    color: Colors.white,
                                    //height: 80,
                                    image:
                                        AssetImage("images/ic_edit_black.png"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal! * 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal! * 1),
                          child: widget.from == "onlyAddPatient"
                              ? Container()
                              /*: patientIDPSelected == ""
                                  ? TextField(
                                      controller: patientIDController,
                                      readOnly: true,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize:
                                              SizeConfig.blockSizeVertical *
                                                  2.3),
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical *
                                                    2.3),
                                        labelStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical *
                                                    2.3),
                                        labelText: "Patient ID",
                                        hintText: "",
                                      ),
                                    )*/
                              : patientIDPSelected == ""
                                  ? TextField(
                                      controller: patientIDController,
                                      readOnly: true,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize:
                                              SizeConfig.blockSizeVertical! *
                                                  2.3),
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
                                        labelText: "Patient ID",
                                        hintText: "",
                                      ),
                                    )
                                  : CustomAutocompleteSearch(
                                      suggestions: listFullNameDetails,
                                      hint: "Patient ID",
                                      controller: patientIDController,
                                      hideSuggestionsOnCreate: true,
                                      onSelected: (text) => selectedField(
                                          context, patientIDController, text),
                                      onTap: () {
                                        if (onTapStatus != "Tapped") {
                                          _scrollController.animateTo(
                                              _scrollController
                                                  .position.maxScrollExtent,
                                              duration:
                                                  Duration(milliseconds: 500),
                                              curve: Curves.easeOut);
                                          onTapStatus = "Tapped";
                                        }
                                      }),
                        )),
                    Align(
                        alignment: Alignment.center,
                        child: Container(
                            width: SizeConfig.blockSizeHorizontal! * 90,
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 1),
                            child:
                                /*patientIDPSelected == "" &&
                                  widget.from != "onlyAddPatient"
                              ?*/
                                CustomAutocompleteSearch(
                                    suggestions: listFullNameDetails,
                                    hint: "First Name",
                                    controller: firstNameController,
                                    hideSuggestionsOnCreate: true,
                                    onSelected: (text) => selectedField(
                                        context, firstNameController, text),
                                    onTap: () {
                                      if (onTapStatus != "Tapped") {
                                        _scrollController.animateTo(
                                            _scrollController
                                                .position.maxScrollExtent,
                                            duration:
                                                Duration(milliseconds: 500),
                                            curve: Curves.easeOut);
                                        onTapStatus = "Tapped";
                                      }
                                    })
                            /*: TextField(
                                  controller: firstNameController,
                                  readOnly: widget.from != "onlyAddPatient",
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
                                    labelText: "First Name",
                                    hintText: "",
                                  ),
                                ),*/
                            )),
                    Align(
                        alignment: Alignment.center,
                        child: Container(
                            width: SizeConfig.blockSizeHorizontal! * 90,
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 1),
                            child:
                                /*patientIDPSelected == "" &&
                                  widget.from != "onlyAddPatient"
                              ?*/
                                CustomAutocompleteSearch(
                                    suggestions: listFullNameDetails,
                                    hint: "Middle Name",
                                    controller: middleNameController,
                                    hideSuggestionsOnCreate: true,
                                    onSelected: (text) => selectedField(
                                        context, middleNameController, text),
                                    onTap: () {
                                      if (onTapStatus != "Tapped") {
                                        _scrollController.animateTo(
                                            _scrollController
                                                .position.maxScrollExtent,
                                            duration:
                                                Duration(milliseconds: 500),
                                            curve: Curves.easeOut);
                                        onTapStatus = "Tapped";
                                      }
                                    })
                            /*: TextField(
                                  controller: middleNameController,
                                  readOnly: widget.from != "onlyAddPatient",
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
                                    labelText: "Middle Name",
                                    hintText: "",
                                  ),
                                ),*/
                            )),
                    Align(
                        alignment: Alignment.center,
                        child: Container(
                            width: SizeConfig.blockSizeHorizontal! * 90,
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 1),
                            child:
                                /*patientIDPSelected == "" &&
                                  widget.from != "onlyAddPatient"
                              ?*/
                                CustomAutocompleteSearch(
                                    suggestions: listFullNameDetails,
                                    hint: "Last Name",
                                    controller: lastNameController,
                                    hideSuggestionsOnCreate: true,
                                    onSelected: (text) => selectedField(
                                        context, lastNameController, text),
                                    onTap: () {
                                      if (onTapStatus != "Tapped") {
                                        _scrollController.animateTo(
                                            _scrollController
                                                .position.maxScrollExtent,
                                            duration:
                                                Duration(milliseconds: 500),
                                            curve: Curves.easeOut);
                                        onTapStatus = "Tapped";
                                      }
                                    })
                            /*: TextField(
                                  controller: lastNameController,
                                  readOnly: widget.from != "onlyAddPatient",
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
                                    labelText: "Last Name",
                                    hintText: "",
                                  ),
                                ),*/
                            )),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                          width: SizeConfig.blockSizeHorizontal! * 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal! * 1),
                          child:
                              /*patientIDPSelected == "" &&
                                      widget.from != "onlyAddPatient"
                                  ?*/
                              CustomAutocompleteSearch(
                                  suggestions: listFullNameDetails,
                                  hint: "Mobile Number",
                                  controller: mobileNumberController,
                                  hideSuggestionsOnCreate: true,
                                  onSelected: (text) => selectedField(
                                      context, mobileNumberController, text),
                                  onTap: () {
                                    if (onTapStatus != "Tapped") {
                                      _scrollController.animateTo(
                                          _scrollController
                                              .position.maxScrollExtent,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.easeOut);
                                      onTapStatus = "Tapped";
                                    }
                                  })
                          /*: TextField(
                                      controller: mobileNumberController,
                                      readOnly: widget.from != "onlyAddPatient",
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize:
                                              SizeConfig.blockSizeVertical *
                                                  2.3),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical *
                                                    2.3),
                                        labelStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical *
                                                    2.3),
                                        labelText: "Mobile Number",
                                        hintText: "",
                                      ),
                                    ),*/
                          ),
                    ),
                    Visibility(
                      visible: initialState,
                      child: SizedBox(
                        height: SizeConfig.blockSizeVertical! * 2.0,
                      ),
                    ),
                    Visibility(
                      visible: initialState,
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                SizeConfig.blockSizeHorizontal! * 20.0),
                            color: colorBlueDark,
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
                              vertical: SizeConfig.blockSizeHorizontal! * 3.0),
                          child: InkWell(
                              onTap: () {
                                checkIfPatientExists(context);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Proceed",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! *
                                                4.0),
                                  ),
                                  /*SizedBox(
                                    width: SizeConfig.blockSizeHorizontal * 2.0,
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: SizeConfig.blockSizeHorizontal * 5.0,
                                  ),*/
                                ],
                              )),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: initialState,
                      child: SizedBox(
                        height: SizeConfig.blockSizeVertical! * 1.0,
                      ),
                    ),
                    Visibility(
                      visible: !initialState,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: MaterialButton(
                              onPressed: () {
                                if (patientIDPSelected == "" && !initialState)
                                  showDateSelectionDialog();
                              },
                              child: Container(
                                width: SizeConfig.blockSizeHorizontal! * 90,
                                padding: EdgeInsets.all(
                                    SizeConfig.blockSizeHorizontal! * 1),
                                child: IgnorePointer(
                                  child: TextField(
                                    controller: dobController,
                                    readOnly:
                                        patientIDPSelected == "" ? false : true,
                                    style: TextStyle(
                                        color: black,
                                        fontSize:
                                            SizeConfig.blockSizeVertical! *
                                                2.3),
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: darkgrey,
                                          fontSize:
                                              SizeConfig.blockSizeVertical! *
                                                  2.3),
                                      labelStyle: TextStyle(
                                          color: darkgrey,
                                          fontSize:
                                              SizeConfig.blockSizeVertical! *
                                                  2.3),
                                      labelText: "Date Of Birth",
                                      hintText: "",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 90,
                              padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal! * 1),
                              child: TextField(
                                controller: ageController,
                                maxLength: 3,
                                readOnly:
                                    /*widget.from != "onlyAddPatient"
                                    ? false
                                    :*/
                                    patientIDPSelected == "" && !initialState
                                        ? false
                                        : true,
                                style: TextStyle(
                                    color: black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: darkgrey,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.3),
                                  labelStyle: TextStyle(
                                      color: darkgrey,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.3),
                                  labelText: "Age",
                                  hintText: "",
                                ),
                                onChanged: (text) {
                                  calculateBirthDate(text);
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical! * 1,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: SizeConfig.blockSizeHorizontal! * 5),
                                child: Text("Gender",
                                    style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! *
                                                4))),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        SizeConfig.blockSizeHorizontal! * 3),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: RadioListTile(
                                        value: 0,
                                        groupValue: _radioValueGender,
                                        onChanged: _handleRadioValueChange,
                                        title: Text("Male",
                                            style: TextStyle(
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    4)),
                                        dense: true,
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile(
                                        value: 1,
                                        groupValue: _radioValueGender,
                                        onChanged: _handleRadioValueChange,
                                        title: Text("Female",
                                            style: TextStyle(
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    4)),
                                        dense: true,
                                      ),
                                    )
                                    /*Radio(
                                  value: 0,
                                  groupValue: _radioValueAge,
                                  onChanged: _handleRadioValueChange,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded),
                              Text('Male'),
                              Radio(
                                  value: 1,
                                  groupValue: _radioValueAge,
                                  onChanged: _handleRadioValueChange,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded),
                              Text('Female'),*/
                                  ],
                                )),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 90,
                              padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal! * 1),
                              child: patientIDPSelected == "" && !initialState
                                  ? CustomAutocompleteSearch(
                                      suggestions: listFullNameDetails,
                                      hint: "Email",
                                      controller: emailController,
                                      hideSuggestionsOnCreate: true,
                                      onSelected: (text) => selectedField(
                                          context, emailController, text),
                                      onTap: () {
                                        _scrollController.animateTo(
                                            _scrollController
                                                .position.maxScrollExtent,
                                            duration:
                                                Duration(milliseconds: 500),
                                            curve: Curves.easeOut);
                                      })
                                  : TextField(
                                      controller: emailController,
                                      readOnly: true,
                                      style: TextStyle(
                                          color: black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical! *
                                                  2.3),
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: darkgrey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical! *
                                                    2.3),
                                        labelStyle: TextStyle(
                                            color: darkgrey,
                                            fontSize:
                                                SizeConfig.blockSizeVertical! *
                                                    2.3),
                                        labelText: "Email",
                                        hintText: "",
                                      ),
                                    ),
                            ),
                          ),
                          /*Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal * 1),
                        child: TextField(
                          controller: emailController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical * 2.3),
                            labelText: "Email",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),*/
                          SizedBox(
                            height: SizeConfig.blockSizeVertical! * 2,
                          ),
                          SliderWidget(
                              min: 0,
                              max: 200,
                              value: heightValue.toDouble(),
                              title: "Height",
                              unit: "Cm",
                              callbackFromBMI: callbackFromBMI),
                          SliderWidget(
                              min: 0,
                              max: 120,
                              value: weightValue.toDouble(),
                              title: "Weight",
                              unit: "Kg",
                              callbackFromBMI: callbackFromBMI),
                          /*Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal * 1),
                        child: TextField(
                          controller: weightController,
                          readOnly: patientIDPSelected == "" ? false : true,
                          maxLength: 3,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical * 2.3),
                            labelText: "Weight (Kg)",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal * 1),
                        child: TextField(
                          controller: heightController,
                          readOnly: patientIDPSelected == "" ? false : true,
                          maxLength: 3,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical * 2.3),
                            labelText: "Height (Centimeters)",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),*/
                          /*Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          if (patientIDPSelected == "")
                            showBloodGroupSelectionDialog(listBloodGroup);
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal * 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal * 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: bloodGroupController,
                              readOnly: patientIDPSelected == "" ? false : true,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical * 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical * 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical * 2.3),
                                labelText: "Blood Group",
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),*/
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 90,
                              padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal! * 1),
                              child: TextField(
                                controller: addressController,
                                readOnly:
                                    patientIDPSelected == "" && !initialState
                                        ? false
                                        : true,
                                style: TextStyle(
                                    color: black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: darkgrey,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.3),
                                  labelStyle: TextStyle(
                                      color: darkgrey,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.3),
                                  labelText: "Address",
                                  hintText: "",
                                ),
                              ),
                            ),
                          ),
                          /*Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          if (patientIDPSelected == "")
                            showCountrySelectionDialog(
                                listCountriesSearchResults, "Country");
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal * 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal * 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: countryController,
                              readOnly: patientIDPSelected == "" ? false : true,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical * 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical * 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical * 2.3),
                                labelText: "Country",
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          if (patientIDPSelected == "")
                            showCountrySelectionDialog(
                                listStatesSearchResults, "State");
                        },
                        child: Container(
                            width: SizeConfig.blockSizeHorizontal * 90,
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal * 1),
                            child: IgnorePointer(
                              child: TextField(
                                controller: stateController,
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
                                  labelText: "State",
                                  hintText: "",
                                ),
                              ),
                            )),
                      ),
                    ),*/
                          Align(
                            alignment: Alignment.center,
                            child: MaterialButton(
                              onPressed: () {
                                if (patientIDPSelected == "" && !initialState)
                                  showCountrySelectionDialog(
                                      listCitiesSearchResults, "City");
                              },
                              child: Container(
                                width: SizeConfig.blockSizeHorizontal! * 90,
                                padding: EdgeInsets.all(
                                    SizeConfig.blockSizeHorizontal! * 1),
                                child: IgnorePointer(
                                  child: TextField(
                                    controller: cityController,
                                    style: TextStyle(
                                        color: black,
                                        fontSize:
                                            SizeConfig.blockSizeVertical! *
                                                2.3),
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: darkgrey,
                                          fontSize:
                                              SizeConfig.blockSizeVertical! *
                                                  2.3),
                                      labelStyle: TextStyle(
                                          color: darkgrey,
                                          fontSize:
                                              SizeConfig.blockSizeVertical! *
                                                  2.3),
                                      labelText: "City",
                                      hintText: "",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 90,
                              padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal! * 1),
                              child: TextField(
                                controller: marriedController,
                                readOnly:
                                    patientIDPSelected == "" && !initialState
                                        ? false
                                        : true,
                                style: TextStyle(
                                    color: black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: darkgrey,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.3),
                                  labelStyle: TextStyle(
                                      color: darkgrey,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.3),
                                  labelText: "Married",
                                  hintText: "",
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 90,
                              padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal! * 1),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                controller: noOfFamilyMembersController,
                                readOnly:
                                    patientIDPSelected == "" && !initialState
                                        ? false
                                        : true,
                                style: TextStyle(
                                    color: black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: darkgrey,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.3),
                                  labelStyle: TextStyle(
                                      color: darkgrey,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.3),
                                  labelText: "No. of Family Members",
                                  hintText: "",
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 90,
                              padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal! * 1),
                              child: TextField(
                                controller: yourPositionInFamilyController,
                                readOnly:
                                    patientIDPSelected == "" && !initialState
                                        ? false
                                        : true,
                                style: TextStyle(
                                    color: black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: darkgrey,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.3),
                                  labelStyle: TextStyle(
                                      color: darkgrey,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.3),
                                  labelText: "Your position in family",
                                  hintText: "",
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical! * 3.0,
                          ),
                          Visibility(
                              visible: patientIDPSelected != "" &&
                                  widget.from != "onlyAddPatient",
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        SizeConfig.blockSizeHorizontal! * 3.0),
                                child: Text(
                                  "Medical Profile",
                                  style: TextStyle(
                                    color: darkgrey,
                                    fontWeight: FontWeight.w500,
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 5.0,
                                  ),
                                ),
                              )),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical! * 1.0,
                          ),
                          Visibility(
                            visible: patientIDPSelected != "" &&
                                widget.from != "onlyAddPatient",
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: SizeConfig.blockSizeHorizontal! * 5.0),
                              child: Text(
                                "Medical History",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal! * 4.0,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: patientIDPSelected != "" &&
                                widget.from != "onlyAddPatient",
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: SizeConfig.blockSizeHorizontal! * 5.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: isCheckedDiabetes,
                                            onChanged: (isChecked) {
                                              /*setState(() {
                                          isCheckedDiabetes = isChecked;
                                        });*/
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
                                                      onTap: () {},
                                                      child: IgnorePointer(
                                                        child: TextField(
                                                          controller:
                                                              sinceYearsDiabetesController,
                                                          style: TextStyle(
                                                              color: black,
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
                                                      onTap: () {},
                                                      child: IgnorePointer(
                                                        child: TextField(
                                                          controller:
                                                              sinceMonthsDiabetesController,
                                                          style: TextStyle(
                                                              color: black,
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
                                            : Container(),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: SizeConfig.blockSizeHorizontal! * 5.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: isCheckedHypertension,
                                            onChanged: (isChecked) {
                                              /*setState(() {
                                          isCheckedHypertension = isChecked;
                                        });*/
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
                                                        onTap: () {},
                                                        child: IgnorePointer(
                                                          child: TextField(
                                                            controller:
                                                                sinceYearsHyperTensionController,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            decoration:
                                                                InputDecoration(
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeVertical! *
                                                                          2.3),
                                                              labelStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeVertical! *
                                                                          2.3),
                                                              labelText:
                                                                  "Years",
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
                                                        onTap: () {},
                                                        child: IgnorePointer(
                                                          child: TextField(
                                                            controller:
                                                                sinceMonthsHyperTensionController,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            decoration:
                                                                InputDecoration(
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeVertical! *
                                                                          2.3),
                                                              labelStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeVertical! *
                                                                          2.3),
                                                              labelText:
                                                                  "Months",
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
                                    left: SizeConfig.blockSizeHorizontal! * 5.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: isCheckedHeartDisease,
                                            onChanged: (isChecked) {
                                              /*setState(() {
                                          isCheckedHeartDisease = isChecked;
                                        });*/
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
                                                        onTap: () {},
                                                        child: IgnorePointer(
                                                          child: TextField(
                                                            controller:
                                                                sinceYearsHeartDiseaseController,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            decoration:
                                                                InputDecoration(
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeVertical! *
                                                                          2.3),
                                                              labelStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeVertical! *
                                                                          2.3),
                                                              labelText:
                                                                  "Years",
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
                                                        onTap: () {},
                                                        child: IgnorePointer(
                                                          child: TextField(
                                                            controller:
                                                                sinceMonthsHeartDiseaseController,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            decoration:
                                                                InputDecoration(
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeVertical! *
                                                                          2.3),
                                                              labelStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeVertical! *
                                                                          2.3),
                                                              labelText:
                                                                  "Months",
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
                                    left: SizeConfig.blockSizeHorizontal! * 5.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: isCheckedThyroid,
                                            onChanged: (isChecked) {
                                              /*setState(() {
                                          isCheckedThyroid = isChecked;
                                        });*/
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
                                                        onTap: () {},
                                                        child: IgnorePointer(
                                                          child: TextField(
                                                            controller:
                                                                sinceYearsThyroidController,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            decoration:
                                                                InputDecoration(
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeVertical! *
                                                                          2.3),
                                                              labelStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeVertical! *
                                                                          2.3),
                                                              labelText:
                                                                  "Years",
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
                                                        onTap: () {},
                                                        child: IgnorePointer(
                                                          child: TextField(
                                                            controller:
                                                                sinceMonthsThyroidController,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: SizeConfig
                                                                        .blockSizeVertical! *
                                                                    2.3),
                                                            decoration:
                                                                InputDecoration(
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeVertical! *
                                                                          2.3),
                                                              labelStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeVertical! *
                                                                          2.3),
                                                              labelText:
                                                                  "Months",
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
                                          width:
                                              SizeConfig.blockSizeHorizontal! *
                                                  90,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  5.0),
                                          child: IgnorePointer(
                                            child: TextField(
                                              controller:
                                                  otherMedicalHistoryController,
                                              textAlign: TextAlign.left,
                                              keyboardType:
                                                  TextInputType.multiline,
                                              maxLines: 5,
                                              style: TextStyle(
                                                  color: black,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3),
                                              decoration: InputDecoration(
                                                hintStyle: TextStyle(
                                                    color: darkgrey,
                                                    fontSize: SizeConfig
                                                            .blockSizeVertical! *
                                                        2.3),
                                                labelStyle: TextStyle(
                                                    color: darkgrey,
                                                    fontSize: SizeConfig
                                                            .blockSizeVertical! *
                                                        2.3),
                                                labelText: "Other",
                                                hintText: "",
                                              ),
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
                            visible: patientIDPSelected != "" &&
                                widget.from != "onlyAddPatient",
                            child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 90,
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      SizeConfig.blockSizeHorizontal! * 5.0),
                              child: IgnorePointer(
                                  child: TextField(
                                controller: surgicalHistoryController,
                                textAlign: TextAlign.left,
                                keyboardType: TextInputType.multiline,
                                maxLines: 5,
                                style: TextStyle(
                                    color: black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: darkgrey,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.3),
                                  labelStyle: TextStyle(
                                      color: darkgrey,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.3),
                                  labelText: "Surgical History",
                                  hintText: "",
                                ),
                              )),
                            ),
                          ),
                          Visibility(
                            visible: patientIDPSelected != "" &&
                                widget.from != "onlyAddPatient",
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        SizeConfig.blockSizeHorizontal! * 5.0),
                                child: IgnorePointer(
                                  child: TextField(
                                    controller: drugAllergyThyroidController,
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    style: TextStyle(
                                        color: black,
                                        fontSize:
                                            SizeConfig.blockSizeVertical! *
                                                2.3),
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: darkgrey,
                                          fontSize:
                                              SizeConfig.blockSizeVertical! *
                                                  2.3),
                                      labelStyle: TextStyle(
                                          color: darkgrey,
                                          fontSize:
                                              SizeConfig.blockSizeVertical! *
                                                  2.3),
                                      labelText: "Drug Allergy",
                                      hintText: "",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: patientIDPSelected != "" &&
                                widget.from != "onlyAddPatient",
                            child: InkWell(
                              onTap: () {
                                //showBloodGroupSelectionDialog(listBloodGroup);
                              },
                              child: Container(
                                width: SizeConfig.blockSizeHorizontal! * 90,
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        SizeConfig.blockSizeHorizontal! * 5.0),
                                child: IgnorePointer(
                                  child: TextField(
                                    controller: bloodGroupController,
                                    style: TextStyle(
                                        color: black,
                                        fontSize:
                                            SizeConfig.blockSizeVertical! *
                                                2.3),
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: darkgrey,
                                          fontSize:
                                              SizeConfig.blockSizeVertical! *
                                                  2.3),
                                      labelStyle: TextStyle(
                                          color: darkgrey,
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
                    )
                  ],
                )),
                initialState
                    ? Container()
                    : patientIDPSelected == ""
                        ?
                        // Container(
                        //       height: SizeConfig.blockSizeVertical !* 12,
                        //       padding: EdgeInsets.only(
                        //           right: SizeConfig.blockSizeHorizontal !* 3.5,
                        //           top: SizeConfig.blockSizeVertical * 3.5),
                        //       child: Align(
                        //         alignment: Alignment.topRight,
                        //         child: Container(
                        //           width: SizeConfig.blockSizeHorizontal * 12,
                        //           height: SizeConfig.blockSizeHorizontal * 12,
                        //           child: RawMaterialButton(
                        //             onPressed: () {
                        //               submitImageForUpdate(context, widget.image);
                        //             },
                        //             elevation: 2.0,
                        //             fillColor: Color(0xFF06A759),
                        //             child: Image(
                        //               width: SizeConfig.blockSizeHorizontal * 5.5,
                        //               height:
                        //                   SizeConfig.blockSizeHorizontal * 5.5,
                        //               //height: 80,
                        //               image: AssetImage(
                        //                   "images/ic_right_arrow_triangular.png"),
                        //             ),
                        //             shape: CircleBorder(),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        Align(
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.blockSizeHorizontal! * 20.0),
                                color: colorBlueDark,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      SizeConfig.blockSizeHorizontal! * 3.0,
                                  vertical:
                                      SizeConfig.blockSizeHorizontal! * 3.0),
                              child: InkWell(
                                  onTap: () {
                                    submitDataForUpdate(context, null)
                                        .then((_) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DoctorDashboardScreen(),
                                        ),
                                      );
                                    });
                                    // submitImageForUpdate(context,null);
                                    // Navigator.of(context).push(
                                    //     MaterialPageRoute(builder :
                                    //         (context) => DoctorDashboardScreen()));
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Proceed",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.0),
                                      ),
                                      /*SizedBox(
                                    width: SizeConfig.blockSizeHorizontal * 2.0,
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: SizeConfig.blockSizeHorizontal * 5.0,
                                  ),*/
                                    ],
                                  )),
                            ),
                          )
                        : Container(
                            height: SizeConfig.blockSizeVertical! * 15,
                            color: Color(0xFFCFFED4),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    color: Color(0xFFCFFED4),
                                    child: Padding(
                                        padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal! *
                                                3),
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(
                                              height: SizeConfig
                                                      .blockSizeVertical! *
                                                  1,
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    "You have selected Patient",
                                                    style: TextStyle(
                                                      fontSize: SizeConfig
                                                              .blockSizeHorizontal! *
                                                          4,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: SizeConfig
                                                            .blockSizeVertical! *
                                                        1,
                                                  ),
                                                  Text(
                                                    patientDetailsSelected,
                                                    style: TextStyle(
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            3),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                                onTap: () {
                                                  resetAllFields();
                                                },
                                                child: Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.red,
                                                  size: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      5,
                                                ))
                                          ],
                                        )),
                                  ),
                                ),
                                /*InkWell(
                              onTap: () {
                              },
                              child: Image(
                                width: SizeConfig.blockSizeHorizontal * 5.5,
                                height: SizeConfig.blockSizeHorizontal * 5.5,
                                //height: 80,
                                image: AssetImage(
                                    "images/ic_right_arrow_triangular.png"),
                              ),
                            ),*/
                                SizedBox(
                                  width: SizeConfig.blockSizeHorizontal! * 2,
                                ),
                                Container(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return DoctorDashboardScreen(
                                            // patientIDPSelected, "", "new",
                                            // campID: widget.campID ?? ''
                                        );
                                      })).then((value) {
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left:
                                              SizeConfig.blockSizeHorizontal! *
                                                  3),
                                      child: ClipOval(
                                        child: Container(
                                            color: Color(0xFF06A759),
                                            height: SizeConfig
                                                    .blockSizeHorizontal! *
                                                12,
                                            // height of the button
                                            width: SizeConfig
                                                    .blockSizeHorizontal! *
                                                12,
                                            // width of the button
                                            child: Padding(
                                              padding: EdgeInsets.all(SizeConfig
                                                      .blockSizeHorizontal! *
                                                  3),
                                              child: Image(
                                                width: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    7.5,
                                                height: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    7.5,
                                                //height: 80,
                                                image: AssetImage(
                                                    "images/ic_right_arrow_triangular.png"),
                                              ),
                                            )),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(
                                              color: Colors.grey, width: 1.0))),
                                ),
                                SizedBox(
                                  width: SizeConfig.blockSizeHorizontal! * 2,
                                ),
                              ],
                            ),
                          )
              ],
            );
          },
        ));
  }

  void callbackFromBMI() {
    setState(() {});
  }

  void _handleRadioValueChange(value) {
    if (patientIDPSelected == "" && !initialState) {
      setState(() {
        _radioValueGender = value;
      });
    }
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
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
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
    ProgressDialog pr;
    /*Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr.show();
    });*/
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
        lastDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day));

    if (date != null) {
      pickedDate = date;
      var formatter = new DateFormat('dd-MM-yyyy');
      String formatted = formatter.format(pickedDate);
      dobController = TextEditingController(text: formatted);
      setState(() {});
    }
    calculateAge(pickedDate);
  }

  calculateAge(DateTime birthDate) {
    DateTime birthday = DateTime(1990, 1, 20);
    DateTime today = DateTime.now(); //2020/1/24
    DateTime currentDate = DateTime.now();
    int ageLocal = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      ageLocal--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        ageLocal--;
      }
    }
    debugPrint("calculated age");
    debugPrint(ageLocal.toString());
    ageController = TextEditingController(text: ageLocal.toString());
    setState(() {});
    //return age;
  }

  selectedField(
      BuildContext context, TextEditingController anyController, text) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (widget.from != "onlyAddPatient") {
      List<String> listCommon = [];
      listCommon = listFullNameDetails;
      debugPrint(listPatientIDP[listCommon.indexOf(text)]);
      patientIDPSelected = listPatientIDP[listCommon.indexOf(text)];
      patientDetailsSelected = listCommon[listCommon.indexOf(text)];
      getAllPatientFields(listPatientIDP[listCommon.indexOf(text)], context);
      anyController = TextEditingController(text: text);
      initialState = false;
    } else {
      resetAllFields();
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("This Patient Already Exist. Please Enter new details."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setState(() {});
  }

  void getPatientsList(BuildContext context) async {
    listFullNameDetails = [];
    listPatientIDP = [];
    listFirstName = [];
    listMiddleName = [];
    listLastName = [];
    listMobileNo = [];
    listEmail = [];
    String loginUrl = "${baseURL}doctorPatientList.php";
    /*ProgressDialog pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr.show();
    });*/
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

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
    //pr.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listFullNameDetails.add(jo['FName'] +
            " " +
            jo['MiddleName'] +
            " " +
            jo['LName'] +
            " " +
            jo['PatientID'] +
            " " +
            jo['Gender'] +
            "/" +
            jo['Age'] +
            " " +
            jo['MobileNo']);
        listPatientIDP.add(jo['PatientIDP'].toString());
        listPatientID.add(jo['PatientID']);
        listFirstName.add(jo['FName']);
        listMiddleName.add(jo['MiddleName']);
        listLastName.add(jo['LName']);
        listMobileNo.add(jo['MobileNo'].toString());
        listEmail.add(jo['EmailID']);
      }
      setState(() {});
    }
  }

  void getAllPatientFields(String patientIDPOrg, BuildContext context) async {
    String loginUrl = "${baseURL}doctorPatientData.php";
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
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDPOrg +
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
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      firstNameController =
          TextEditingController(text: jsonData[0]['FirstName']);
      patientIDController =
          TextEditingController(text: jsonData[0]['PatientID']);
      /*middleNameController =
          TextEditingController(text: jsonData[0]['FirstName']);*/
      middleNameController =
          TextEditingController(text: jsonData[0]['MiddleName']);
      lastNameController = TextEditingController(text: jsonData[0]['LastName']);
      mobileNumberController =
          TextEditingController(text: jsonData[0]['MobileNo']);
      emailController = TextEditingController(text: jsonData[0]['EmailID']);
      dobController = TextEditingController(text: jsonData[0]['DOB']);
      addressController = TextEditingController(text: jsonData[0]['Address']);
      cityController = TextEditingController(text: jsonData[0]['CityName']);
      stateController = TextEditingController(text: jsonData[0]['StateName']);
      countryController =
          TextEditingController(text: jsonData[0]['CountryName']);
      marriedController = TextEditingController(text: jsonData[0]['Married']);
      noOfFamilyMembersController =
          TextEditingController(text: jsonData[0]['NoOfFamilyMember']);
      yourPositionInFamilyController =
          TextEditingController(text: jsonData[0]['YourPostionInFamily']);
      weightController = TextEditingController(text: jsonData[0]['Wieght']);
      heightController = TextEditingController(text: jsonData[0]['Height']);
      bloodGroupController =
          TextEditingController(text: jsonData[0]['BloodGroup']);
      ageController = TextEditingController(text: jsonData[0]['Age']);
      heightValue = double.parse(jsonData[0]['Height'].toString()).round();
      weightValue = double.parse(jsonData[0]['Wieght'].toString()).round();
      if (jsonData[0]['Gender'] == "M")
        _radioValueGender = 0;
      else if (jsonData[0]['Gender'] == "F") _radioValueGender = 1;
      cmToFeet();
      widget.imgUrl = jsonData[0]['Image'];
      var jsonPatient = jsonData[0];

      if (jsonPatient != null && jsonPatient != "") {
        sinceYearsDiabetesController = TextEditingController(
            text: getStringWithYearAdded(jsonPatient['DiabetesYear']));
        sinceMonthsDiabetesController = TextEditingController(
            text: getStringWithMonthAdded(jsonPatient['DiabetesMonth']));
        sinceYearsHyperTensionController = TextEditingController(
            text: getStringWithYearAdded(jsonPatient['HypertensionYear']));
        sinceMonthsHyperTensionController = TextEditingController(
            text: getStringWithMonthAdded(jsonPatient['HypertensionMonth']));
        sinceYearsHeartDiseaseController = TextEditingController(
            text: getStringWithYearAdded(jsonPatient['HeartDiseaseYear']));
        sinceMonthsHeartDiseaseController = TextEditingController(
            text: getStringWithMonthAdded(jsonPatient['HeartDiseaseMonth']));
        sinceYearsThyroidController = TextEditingController(
            text: getStringWithYearAdded(jsonPatient['ThyroidYear']));
        sinceMonthsThyroidController = TextEditingController(
            text: getStringWithMonthAdded(jsonPatient['ThyroidMonth']));
        otherMedicalHistoryController =
            TextEditingController(text: jsonPatient['Other']);
        surgicalHistoryController =
            TextEditingController(text: jsonPatient['SurgicalHistory']);
        drugAllergyThyroidController =
            TextEditingController(text: jsonPatient['DrugAllergy']);
        bloodGroupController =
            TextEditingController(text: jsonPatient['BloodGroup']);

        if (jsonPatient['Diabetes'] == "1") isCheckedDiabetes = true;
        if (jsonPatient['Hypertension'] == "1") isCheckedHypertension = true;
        if (jsonPatient['HeartDisease'] == "1") isCheckedHeartDisease = true;
        if (jsonPatient['Thyroid'] == "1") isCheckedThyroid = true;
      }
      initialState = false;
      setState(() {});
    }
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

  void calculateBirthDate(String age) {
    DateTime now = DateTime.now();
    /*debugPrint("birthday month");
    debugPrint(now.month.toString());*/
    DateTime estimatedDOB = DateTime(now.year - int.parse(age), 1, 1);
    var formatter = new DateFormat('dd-MM-yyyy');
    String formattedDate = formatter.format(estimatedDOB);
    dobController = TextEditingController(text: formattedDate);
    setState(() {});
    /*else
      DateTime(1, 1, now.year - int.parse(age) - 1);*/
  }

  void resetAllFields() {
    patientIDPSelected = "";
    patientDetailsSelected = "";
    patientIDController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    mobileNumberController = TextEditingController();
    emailController = TextEditingController();
    dobController = TextEditingController();
    ageController = TextEditingController();
    addressController = TextEditingController();
    cityController = TextEditingController();
    stateController = TextEditingController();
    countryController = TextEditingController();
    marriedController = TextEditingController();
    noOfFamilyMembersController = TextEditingController();
    yourPositionInFamilyController = TextEditingController();
    middleNameController = TextEditingController();
    weightController = TextEditingController();
    heightController = TextEditingController();
    bloodGroupController = TextEditingController();
    emergencyNumberController = TextEditingController();
    pickedDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    heightValue = 0;
    weightValue = 0;
    heightInFeet = "0 Foot 0 Inches";
    _radioValueGender = -1;
    sinceYearsThyroidController = TextEditingController();
    sinceMonthsThyroidController = TextEditingController();
    otherMedicalHistoryController = TextEditingController();
    surgicalHistoryController = TextEditingController();
    drugAllergyThyroidController = TextEditingController();
    isCheckedDiabetes = false;
    isCheckedHypertension = false;
    isCheckedHeartDisease = false;
    isCheckedThyroid = false;
    setState(() {});
  }

  void checkIfPatientExists(BuildContext context) async {
    print('checkIfPatientExists');
    String mobNoToValidate = mobileNumberController.text;
    if (mobileNumberController.text.length >= 12) {
      if (mobileNumberController.text.startsWith("+91")) {
        mobNoToValidate = mobNoToValidate.replaceFirst("+91", "");
      } else if (mobileNumberController.text.startsWith("91")) {
        mobNoToValidate = mobNoToValidate.replaceFirst("91", "");
      }
    }
    if (firstNameController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please type First Name"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (mobNoToValidate.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please type Mobile Number"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    String loginUrl = "${baseURL}doctorpatientexiistdetails.php";
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
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"" +
        "FirstName" +
        "\"" +
        ":" +
        "\"" +
        firstNameController.text +
        "\"" +
        "," +
        "\"" +
        "MobileNo" +
        "\"" +
        ":" +
        "\"" +
        mobNoToValidate.trim() +
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
    if (model.status == "EXIST") {
      resetAllFields();
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("This Patient Already Exist. Please Enter new details."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (model.status == "INSYSTEM") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      String firstName = jsonData[0]['FirstName'].toString().trim();
      String fullName = firstName.substring(0, 2);
      for (int i = 0; i < firstName.length - 2; i++) {
        fullName = fullName + " *";
      }
      fullName = fullName +
          " " +
          jsonData[0]['MiddleName'].toString().trim() +
          " " +
          jsonData[0]['LastName'].toString().trim();
      String patientIDP = jsonData[0]['PatientIDP'].toString().trim();
      debugPrint("Full name");
      debugPrint(fullName);
      showDoYouWantToBindDialog(context, fullName, patientIDP);
    } else if (model.status == "NEWNUMBER") {
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Navigator.of(context).push(MaterialPageRoute(builder: (context) => DoctorDashboardScreen()));
      setState(() {
        initialState = false;
        submitDataForUpdate(context, null);
      });
    }
  }

  void showDoYouWantToBindDialog(
      BuildContext mContext, String fullName, String patientIDP) {
    var title = "Bind Patient";
    var subTitle =
        "Patient with name\n$fullName\nalready exist in the system, do you wish to bind this patient? If not please use some other Mobile number to add this patient.";
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Patient with name"),
                  Text(
                    "\n$fullName\n",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.blockSizeHorizontal! * 4.5,
                    ),
                  ),
                  Text(
                      "already exist in the system, do you wish to bind this patient?"),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical! * 3.5,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      color: Colors.grey,
                      width: SizeConfig.blockSizeHorizontal! * 15.0,
                      height: 0.8,
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical! * 1.5,
                  ),
                  Text(
                    "If no, please use some other Mobile number to add this patient.",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey[600],
                      fontSize: SizeConfig.blockSizeHorizontal! * 3.8,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "No",
                    style: TextStyle(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    bindDoctor(mContext, patientIDP);
                  },
                  child: Text(
                    "Yes",
                    style: TextStyle(color: black),
                  )),
            ],
          );
        });
  }

  void bindDoctor(BuildContext context, String patientIDPValue) async {
    String loginUrl = "${baseURL}doctorpatientbind.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDPValue +
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
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(seconds: 2), () {
        if (widget.from != "onlyAddPatient") {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SelectOPDProceduresScreen(patientIDPValue, "", "new",
                campID: widget.campID ?? '');
          })).then((value) {
            Navigator.of(context).pop();
          });
        } else {
          Navigator.of(context).pop();
        }
      });
      /*resetAllFields();*/
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                                  if (icon?.icon == Icons.search) {
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
    super.initState();
    _value = widget.value;
    if (widget.title == "Weight") {
      weightValue = double.parse((_value).toStringAsFixed(2)).round();
      //widget.callbackFromBMI();
    } else if (widget.title == "Height") {
      heightValue = double.parse((_value).toStringAsFixed(2)).round();
      cmToFeet();
      //widget.callbackFromBMI();
    }
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
                          activeTrackColor: Colors.blue.withOpacity(1),
                          inactiveTrackColor: Colors.grey.withOpacity(.5),
                          trackHeight: 2.0,
                          /*thumbShape: CustomSliderThumbCircle(
                            thumbRadius: this.widget.sliderHeight * .3,
                            min: 0,
                            max: this.widget.max,
                          ),*/
                          overlayColor: Colors.teal.withOpacity(.4),
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 5.0),
                          thumbColor: Colors.blue,
                          //valueIndicatorColor: Colors.white,
                          activeTickMarkColor: Colors.blue,
                          inactiveTickMarkColor: Colors.blue.withOpacity(.7),
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
                              if (patientIDPSelected == "" && !initialState) {
                                setState(() {
                                  _value = val;
                                  widget.value = val;
                                  if (widget.title == "Weight") {
                                    weightValue = double.parse(
                                            (widget.value).toStringAsFixed(2))
                                        .round();
                                    widget.callbackFromBMI!();
                                  } else if (widget.title == "Height") {
                                    heightValue = double.parse(
                                            (widget.value).toStringAsFixed(2))
                                        .round();
                                    cmToFeet();
                                    widget.callbackFromBMI!();
                                  }
                                  debugPrint(widget.value.round().toString());
                                });
                              }
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
