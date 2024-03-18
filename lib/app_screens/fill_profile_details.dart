import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChannels, rootBundle;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:silvertouch/app_screens/edit_my_profile_medical_patient.dart';
import 'package:silvertouch/app_screens/patient_dashboard_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/dropdown_item.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/patient_profile_upload_model.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import '../utils/color.dart';
import 'custom_dialog_select_image_from.dart';

final focus = FocusNode();
TextEditingController firstNameController = new TextEditingController();
TextEditingController lastNameController = new TextEditingController();
TextEditingController emailController = new TextEditingController();
TextEditingController dobController = new TextEditingController();
TextEditingController cityController = new TextEditingController();
TextEditingController stateController = new TextEditingController();
TextEditingController countryController = new TextEditingController();
TextEditingController middleNameController = TextEditingController();
TextEditingController emergencyNumberController = TextEditingController();

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

int _radioValueGender = -1;

class FillProfileDetails extends StatefulWidget {
  /*String imgUrl = "";*/
  var image;
  bool isPayment;
  String doctorIDP;

  FillProfileDetails(this.doctorIDP, this.isPayment);

  /*PatientProfileModel patientProfileModel;*/

  /*FillProfileDetails(PatientProfileModel patientProfileModel, String imgUrl) {
    this.patientProfileModel = patientProfileModel;
    this.imgUrl = imgUrl;
  }*/

  @override
  State<StatefulWidget> createState() {
    return FillProfileDetailsState();
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

class FillProfileDetailsState extends State<FillProfileDetails> {
  GlobalKey<ProgressDialogWithPercentageState> progressKey = GlobalKey();
  bool privacyPolicyAccepted = false;
  final picker = ImagePicker();
  final String urlFetchPatientProfileDetails =
      "${baseURL}patientProfileData.php";
  dynamic jsonPatient;

  @override
  void initState() {
    super.initState();
    firstNameController = new TextEditingController();
    lastNameController = new TextEditingController();
    emailController = new TextEditingController();
    dobController = new TextEditingController();
    cityController = new TextEditingController();
    stateController = new TextEditingController();
    countryController = new TextEditingController();
    middleNameController = TextEditingController();
    emergencyNumberController = TextEditingController();
    pickedDate = DateTime(
        DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);
    selectedCountry = DropDownItem("", "");
    selectedState = DropDownItem("", "");
    selectedCity = DropDownItem("", "");
    listCountries = [];
    listStates = [];
    listCities = [];
    listCountriesSearchResults = [];
    listStatesSearchResults = [];
    listCitiesSearchResults = [];
    _radioValueGender = -1;
    var byteData;
    var tempDir;
    var file;
    rootBundle.load('images/ic_user_placeholder.png').then((value) => {
          byteData = value,
          getTemporaryDirectory().then((value) => {
                tempDir = value,
                file = File('${tempDir.path}/ic_user_placeholder.png'),
                file.writeAsBytes(byteData.buffer.asUint8List(
                    byteData.offsetInBytes, byteData.lengthInBytes)),
                widget.image = file,
              })
        });
    /*getTemporaryDirectory().then((value) => tempDir = value);
    file = File('${tempDir.path}/ic_user_placeholder.png');
    file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    widget.image = file;*/

    //getCountriesList();
    getPatientProfileDetails();
    getCitiesList();
  }

  @override
  void dispose() {
    firstNameController = new TextEditingController();
    lastNameController = new TextEditingController();
    emailController = new TextEditingController();
    dobController = new TextEditingController();
    cityController = new TextEditingController();
    stateController = new TextEditingController();
    countryController = new TextEditingController();
    middleNameController = TextEditingController();
    emergencyNumberController = TextEditingController();
    pickedDate = DateTime(
        DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);
    selectedCountry = DropDownItem("", "");
    selectedState = DropDownItem("", "");
    selectedCity = DropDownItem("", "");
    listCountries = [];
    listStates = [];
    listCities = [];
    listCountriesSearchResults = [];
    listStatesSearchResults = [];
    listCitiesSearchResults = [];
    _radioValueGender = -1;

    super.dispose();
  }

  void getPatientProfileDetails() async {
    ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr.show();
    });
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
    //listIcon = new List();
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: urlFetchPatientProfileDetails,
      //Uri.parse(loginUrl),
      headers: {
        "u": patientUniqueKey,
        "type": "patient",
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
      jsonPatient = jsonData[0];
      firstNameController.text = jsonData[0]['FirstName'];
      lastNameController.text = jsonData[0]['LastName'];
      middleNameController.text = jsonData[0]['MiddleName'];
      emailController.text =
          jsonData[0]['EmailID'] != "" ? jsonData[0]['EmailID'] : "-";

      dobController.text = jsonData[0]['DOB'] != "" ? jsonData[0]['DOB'] : "-";
      cityController.text =
          jsonData[0]['CityName'] != "" ? jsonData[0]['CityName'] : "-";
      stateController.text =
          jsonData[0]['StateName'] != "" ? jsonData[0]['StateName'] : "-";
      countryController.text =
          jsonData[0]['CountryName'] != "" ? jsonData[0]['CountryName'] : "-";

      selectedCity =
          DropDownItem(jsonData[0]['CountryIDF'], jsonData[0]['CountryName']);
      selectedCity =
          DropDownItem(jsonData[0]['StateIDF'], jsonData[0]['StateName']);
      selectedCity =
          DropDownItem(jsonData[0]['CityIDF'], jsonData[0]['CityName']);

      emergencyNumberController.text = jsonData[0]['EmergencyNumber'];
      String gender = jsonData[0]['Gender'];
      if (gender == "M")
        _radioValueGender = 0;
      else if (gender == "F") _radioValueGender = 1;
      setEmergencyNumber(jsonData[0]['EmergencyNumber']);
      setState(() {});
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void getCountriesList() async {
    String loginUrl = "${baseURL}country_list.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new [];
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
        "type": "patient",
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
      /*for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listCountries.add(DropDownItem(jo['CountryIDP'], jo['CountryName']));
        listCountriesSearchResults
            .add(DropDownItem(jo['CountryIDP'], jo['CountryName']));
      }
      setState(() {});*/
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        if (jo['CountryName'] == "INDIA") {
          selectedCountry = DropDownItem(jo['CountryIDP'], jo['CountryName']);
          countryController = TextEditingController(text: "INDIA");
        }
        listCountries.add(DropDownItem(jo['CountryIDP'], jo['CountryName']));
        listCountriesSearchResults
            .add(DropDownItem(jo['CountryIDP'], jo['CountryName']));
      }
      getStatesListNoProgressDialog();
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
    //listIcon = new [];
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
        "type": "patient",
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

  Future<void> submitImageForUpdate(BuildContext context, File image) async {
    if (firstNameController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please type First Name"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (middleNameController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please type Middle Name"),
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
    } else if (_radioValueGender == -1) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Gender"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    /*else if (emergencyNumberController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please type emergency Number"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }*/
    else if (dobController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select D.O.B"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    /*else if (countryController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Country"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (stateController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select State"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }*/
    else if (cityController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select City"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (!privacyPolicyAccepted) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("You need to Agree to Disclaimer & Privacy Policy"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    /*ProgressDialog pr = ProgressDialog(context);
    pr.show();*/

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ProgressDialogWithPercentage(
            key: progressKey,
          );
        });

    final multipartRequest = MultipartRequest(
      'POST',
      Uri.parse("${baseURL}patientProfileSubmit.php"),
      onProgress: (int bytes, int total) {
        final progress = bytes / total;
        progressKey.currentState!.setProgress(progress);
      },
    );
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    String mobNo = await getMobNo();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    debugPrint("City, State, Country");
    debugPrint(selectedCity.idp);
    debugPrint(selectedState.idp);
    debugPrint(selectedCountry.idp);
    String gender = "";
    if (_radioValueGender == 0)
      gender = "M";
    else if (_radioValueGender == 1)
      gender = "F";
    else
      gender = "";
    PatientProfileUploadModel modelPatientProfileUpload =
        PatientProfileUploadModel(
      patientIDP,
      firstNameController.text,
      lastNameController.text,
      mobNo,
      emailController.text,
      dobController.text,
      "",
      selectedCity.idp,
      "",
      "",
      "",
      "0",
      "",
      middleNameController.text.trim(),
      "",
      "",
      "",
      emergencyNumberController.text
          .trim()
          .replaceFirst("+", "")
          .replaceFirst("91", ""),
      gender,
    );
    String jsonStr;
    jsonStr = modelPatientProfileUpload.toJson();

    debugPrint("Jsonstr - $jsonStr");

    String encodedJSONStr = encodeBase64(jsonStr);
    multipartRequest.fields['getjson'] = encodedJSONStr;
    Map<String, String> headers = Map();
    headers['u'] = patientUniqueKey;
    headers['type'] = "patient";
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
      //pr.hide();
      Navigator.of(context).pop();

      if (model.status == "OK") {
        final snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setUserType("patient");
        setEmergencyNumber(emergencyNumberController.text
            .trim()
            .replaceFirst("+", "")
            .replaceFirst("91", ""));

        if (widget.isPayment) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditMyProfileMedicalPatient(
                        jsonPatient,
                        patientIDP,
                        doctorIDP: widget.doctorIDP,
                      ))).then((value) {
            Navigator.of(context).pop();
          });
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
            return PatientDashboardScreen(widget.doctorIDP);
          }), (Route<dynamic> route) => false).then((value) {
            Navigator.of(context).pop();
          });
        }
        /*Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PatientDashboardScreen(widget.doctorIDP)));*/
        /*Future.delayed(Duration(milliseconds: 300), () {
          Navigator.of(context).pop();
        });*/
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

  /*void callback(imgUrl) {
    widget.imgUrl = imgUrl;
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text("Img url - " + imgUrl),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    setState(() {});
  }*/

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

  onBackPressed(BuildContext context) {
    showConfirmationDialog(context, "exit");
  }

  showConfirmationDialog(BuildContext context, String exitOrLogout) {
    var title = "";
    if (exitOrLogout == "exit") {
      title =
          "You will have to login back again, if you exit. \nDo you surely want to exit?";
    } else if (exitOrLogout == "logout") {
      title = "Do you really want to Logout?";
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No")),
              TextButton(
                  onPressed: () {
                    if (exitOrLogout == "exit") {
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    } else if (exitOrLogout == "logout") {
                      /*widget.logOut(context);
                      Navigator.pop(context);*/
                    }
                  },
                  child: Text("Yes"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        /*key: navigatorKey,*/
        appBar: AppBar(
          title: Text("Complete profile to continue"),
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(
              color: Colorsblack, size: SizeConfig.blockSizeVertical! * 2.2),
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
        body: WillPopScope(
            onWillPop: () =>
                //SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                onBackPressed(context),
            child: Builder(
              builder: (context) {
                return Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                        child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: SizeConfig.blockSizeHorizontal! * 90,
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 1),
                            child: TextField(
                              controller: firstNameController,
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
                                labelText: "First Name",
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
                              controller: middleNameController,
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
                                labelText: "Middle Name",
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
                              controller: lastNameController,
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
                                labelText: "Last Name",
                                hintText: "",
                              ),
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
                                ],
                              )),
                        ),
                        /*Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: SizeConfig.blockSizeHorizontal * 90,
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal * 1),
                            child: TextField(
                              controller: emergencyNumberController,
                              keyboardType: TextInputType.phone,
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
                                labelText: "Emergency Number",
                                hintText: "",
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
                              controller: emailController,
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
                                labelText: "Email",
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: MaterialButton(
                            onPressed: () {
                              showDateSelectionDialog();
                            },
                            child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 90,
                              padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal! * 1),
                              child: IgnorePointer(
                                child: TextField(
                                  controller: dobController,
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
                                    labelText: "Date Of Birth",
                                    hintText: "",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        /*Align(
                          alignment: Alignment.center,
                          child: MaterialButton(
                            onPressed: () {
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
                                              SizeConfig.blockSizeVertical *
                                                  2.3),
                                      labelStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical *
                                                  2.3),
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
                                    labelText: "City",
                                    hintText: "",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                    /*Container(
                      height: SizeConfig.blockSizeVertical * 12,
                      padding: EdgeInsets.only(
                          right: SizeConfig.blockSizeHorizontal * 3.5,
                          top: SizeConfig.blockSizeVertical * 3.5),
                      child:*/
                    Row(
                      children: [
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 3.0,
                        ),
                        Checkbox(
                          value: privacyPolicyAccepted,
                          onChanged: (isChecked) {
                            setState(() {
                              privacyPolicyAccepted = isChecked!;
                            });
                          },
                        ),
                        Text("I have read and I agree to "),
                        Expanded(
                            child: InkWell(
                          onTap: () {
                            Get.bottomSheet(Material(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      SizeConfig.blockSizeHorizontal! * 5.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    0.5,
                                          ),
                                          Text(
                                            "Disclaimer",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  6.0,
                                            ),
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    1.0,
                                          ),
                                          Text(
                                            "- Our Consultation through Telemedicine is in accordance with the Telemedicine Practice Guidelines 2020 (Appendix 5) Amendment in the Indian Medical Council (Professional Conduct, Etiquette and Ethics) Regulations, 2002 under the Indian Medical Council Act, 1956.\n\n- We, Registered Medical Practitioners, would exercise our professional judgment to decide whether a telemedicine consultation is appropriate in a given situation or an in-person consultation is needed in the interest of the patient.\n\n- Telemedicine consultation is not anonymous, the patient and the Registered Medical Practitioner know each other’s identity.\n\n- Patient consent is necessary for any telemedicine consultation. The consent can be Implied or Explicit.\n* If the patient initiates the telemedicine consultation, then the consent is implied\n* If the Registered Medical Practitioner initiates the telemedicine consultation, then an Explicit patient consent is needed\n\n- I consent to avail consultation via telemedicine in connection with my health condition; details of my current complaint(s), detailed medical history, current and past reports, current and past medications will be discussed; reasonable efforts have been made to eliminate any confidentiality risks associated with this telemedicine consultation and I agree to disseminate any anonymous information arising from this consultation to appropriate research purposes or relevant entities; I understand the potential benefits and risks of selecting telemedicine over a physical consultation.",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  4.0,
                                            ),
                                          ),
                                          Text(
                                            "\nPrivacy Policy",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  6.0,
                                            ),
                                          ),
                                          Text(
                                            "\nInformation Collection And Use\nWhile using our App, we do not ask you to provide any certain personally identifiable information\nthat can be used to contact or identify you. Personally identifiable information may include, your name, contact details and photographs from the phone.\n\nCommunication\nWe may use your Personal Information to contact you with newsletters, marketing or promotional materials\n\nSecurity\nThe security of your Personal Information is important to us, but remember that no method of transmission over the Internet, or method of electronic storage, is 100% secure. While we strive to use commercially acceptable means to protect your Personal Information, we cannot guarantee its absolute security.\n\nChanges To This Privacy Policy\nThis Privacy Policy is effective as of 01-03-2021 and will remain in effect except with respect to any changes in its provisions in the future, which will be in effect immediately after being posted on this page.\n\nWe reserve the right to update or change our Privacy Policy at any time and you should check this Privacy Policy periodically. Your continued use of the Service after we post any modifications to the Privacy Policy on this page will constitute your acknowledgment of the modifications and your consent to abide and be bound by the modified Privacy Policy.",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  4.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    MaterialButton(
                                      color: Colors.blue,
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: Text(
                                        "OK",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ));
                          },
                          child: Text(
                            "Disclaimer & Privacy Policy",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        )),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 12,
                        height: SizeConfig.blockSizeHorizontal! * 12,
                        child: RawMaterialButton(
                          onPressed: () {
                            submitImageForUpdate(context, widget.image);
                          },
                          elevation: 2.0,
                          fillColor: Color(0xFF06A759),
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
                    /*),*/
                  ],
                );
              },
            )));
  }

  void _handleRadioValueChange(value) {
    setState(() {
      _radioValueGender = value;
    });
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
            /*Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              height: SizeConfig.blockSizeVertical * 8,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.red,
                        size: SizeConfig.blockSizeHorizontal * 6.2,
                      ),
                      onTap: () {
                        */ /*setState(() {
                          widget.type = "My type";
                        });*/ /*
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 6,
                    ),
                    Text(
                      "Select ${type}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 4.8,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            */ /*Padding(
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
                ),*/ /*
            Expanded(
              child: ListView.builder(
                  itemCount: list.length,
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          if (type == "Country") {
                            selectedCountry = list[index];
                            countryController = TextEditingController(
                                text: selectedCountry.value);
                            Navigator.of(context).pop();
                            setState(() {});
                            getStatesList();
                          }
                          if (type == "State") {
                            selectedState = list[index];
                            stateController = TextEditingController(
                                text: selectedState.value);
                            Navigator.of(context).pop();
                            setState(() {});
                            getCitiesList();
                          }
                          if (type == "City") {
                            selectedCity = list[index];
                            cityController =
                                TextEditingController(text: selectedCity.value);
                            Navigator.of(context).pop();
                            setState(() {});
                          }
                        },
                        child: Padding(
                            padding: EdgeInsets.all(0.0),
                            child: Container(
                                width: SizeConfig.blockSizeHorizontal * 90,
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
                                    list[index].value,
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
            */ /*Align(
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
                    ))*/ /*
          ],
        )));*/
            CountryDialog(list, type, callbackFromCountryDialog));
  }

  void getStatesListNoProgressDialog() async {
    String loginUrl = "${baseURL}state_list.php";
    ProgressDialog pr;
    /*Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr.show();
    });*/
    //listIcon = new [];
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
        "type": "patient",
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
    String loginUrl = "${baseURL}city_listnew.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new [];
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
        "type": "patient",
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
    //listIcon = new [];
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
        "type": "patient",
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
    DateTime firstDate = DateTime.now().subtract(Duration(days: 365 * 150));
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
    //listIcon = new [];
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
        "type": "patient",
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
    //listIcon = new [];
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
        "type": "patient",
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
        if (jo['CountryName'] == "INDIA")
          selectedCountry = DropDownItem(jo['CountryIDP'], jo['CountryName']);
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
    //listIcon = new [];
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
        "type": "patient",
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

//JSON Parsing
//https://medium.com/flutter-community/parsing-complex-json-in-flutter-747c46655f51
