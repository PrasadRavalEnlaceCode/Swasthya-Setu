import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:silvertouch/api/api_helper.dart';
import 'package:silvertouch/controllers/doctor_profile_image_type_controller.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/doctor_profile_upload_model.dart';
import 'package:silvertouch/podo/model_profile_patient.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/podo/speciality_model.dart';
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
TextEditingController registrationNumberController = TextEditingController();
TextEditingController firstNameController = TextEditingController();
TextEditingController lastNameController = TextEditingController();
TextEditingController mobileNumberController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController dobController = TextEditingController();
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
TextEditingController genderController = TextEditingController();

TextEditingController degreeController = TextEditingController();
TextEditingController specialityController = TextEditingController();
TextEditingController practisingSinceController = TextEditingController();
TextEditingController residenceAddressController = TextEditingController();
TextEditingController residenceMobileNoController = TextEditingController();
TextEditingController whatsAppNoController = TextEditingController();
TextEditingController appointmentNoController = TextEditingController();
TextEditingController latitudeController = TextEditingController();
TextEditingController longitudeController = TextEditingController();
//TextEditingController residenceLandLineController = TextEditingController();
TextEditingController businessAddressController = TextEditingController();
TextEditingController businessMobileNoController = TextEditingController();
//TextEditingController businessLandLineNoController = TextEditingController();
TextEditingController businessCountryController = TextEditingController();
TextEditingController businessStateController = TextEditingController();
TextEditingController businessCityController = TextEditingController();

int _radioValueGender = -1;

var pickedDate = DateTime(
    DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);

DropDownItem selectedCountry = DropDownItem("", "");
DropDownItem selectedState = DropDownItem("", "");
DropDownItem selectedCity = DropDownItem("", "");

DropDownItem selectedBusinessCountry = DropDownItem("", "");
DropDownItem selectedBusinessState = DropDownItem("", "");
DropDownItem selectedBusinessCity = DropDownItem("", "");

List<DropDownItem> listCountries = [];
List<DropDownItem> listStates = [];
List<DropDownItem> listCities = [];

List<DropDownItem> listCountriesForBusiness = [];
List<DropDownItem> listStatesForBusiness = [];
List<DropDownItem> listCitiesForBusiness = [];

List<DropDownItem> listCountriesSearchResults = [];
List<DropDownItem> listStatesSearchResults = [];
List<DropDownItem> listCitiesSearchResults = [];

List<DropDownItem> listCountriesForBusinessSearchResults = [];
List<DropDownItem> listStatesForBusinessSearchResults = [];
List<DropDownItem> listCitiesForBusinessSearchResults = [];

List<SpecialityModel> listSpeciality = [];
SpecialityModel? selectedSpeciality;

class EditMyProfileDoctor extends StatefulWidget {
  String? imgUrlProfilePic = "";
  String? imgUrlLogo = "";
  String? imgUrlSignature = "";
  var imageProfilePic;
  var imageLogo;
  var imageSignature;
  PatientProfileModel? patientProfileModel;

  EditMyProfileDoctor(PatientProfileModel patientProfileModel,
      String imgUrlProfilePic, String imgUrlLogo, String imgUrlSignature) {
    this.patientProfileModel = patientProfileModel;
    this.imgUrlProfilePic = imgUrlProfilePic;
    this.imgUrlLogo = imgUrlLogo;
    this.imgUrlSignature = imgUrlSignature;
  }

  @override
  State<StatefulWidget> createState() {
    return EditMyProfileDoctorState();
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

class EditMyProfileDoctorState extends State<EditMyProfileDoctor> {
  GlobalKey<ProgressDialogWithPercentageState> progressKey = GlobalKey();
  DoctorProfileImageTypeController doctorProfileImageTypeController =
      Get.put(DoctorProfileImageTypeController());
  ApiHelper apiHelper = ApiHelper();
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    listSpeciality = [];
    getCountriesList();
    getSpecialityList();
    fillAllValues();
    // setState(() {});
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
      listCountries = [];
      listCountriesSearchResults = [];
      listCountriesForBusiness = [];
      listCountriesForBusinessSearchResults = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listCountries.add(DropDownItem(jo['CountryIDP'], jo['CountryName']));
        listCountriesSearchResults
            .add(DropDownItem(jo['CountryIDP'], jo['CountryName']));
      }
      listCountriesForBusiness = listCountries;
      listCountriesForBusinessSearchResults = listCountriesSearchResults;
      setState(() {});
    }
  }

  void getSpecialityList() async {
    String loginUrl = "${baseURL}doctorSpeciality.php";
    //listIcon = new [];
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "";

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
      final jsonData = json.decode(strData);
      listSpeciality = specialityModelFromJson(strData);
      setState(() {});
    }
  }

  void getStatesList(String idp, String from) async {
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
        idp +
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
      if (from == "personal") {
        listStates = [];
        listStatesSearchResults = [];
      } else if (from == "business") {
        listStatesForBusiness = [];
        listStatesForBusinessSearchResults = [];
      }
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        if (from == "personal") {
          listStates.add(DropDownItem(jo['StateIDP'], jo['StateName']));
          listStatesSearchResults
              .add(DropDownItem(jo['StateIDP'], jo['StateName']));
        } else if (from == "business") {
          listStatesForBusiness
              .add(DropDownItem(jo['StateIDP'], jo['StateName']));
          listStatesForBusinessSearchResults
              .add(DropDownItem(jo['StateIDP'], jo['StateName']));
        }
      }
      setState(() {});
    }
  }

  Future<void> submitImageForUpdate(BuildContext context,
      [File? image, File? imageLogo, File? imageSignature]) async {
    print('image $image');
    print('imageLogo $imageLogo');
    print('imageSignature $imageSignature');
    ProgressDialog pr = ProgressDialog(context);
    pr.show();
    //var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
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
      Uri.parse("${baseURL}doctorProfileSubmit.php"),
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
    String gender = "";
    if (_radioValueGender == 0)
      gender = "M";
    else if (_radioValueGender == 1)
      gender = "F";
    else
      gender = "";
    String mobNoToValidate = mobileNumberController.text;
    if (mobileNumberController.text.length >= 12) {
      if (mobileNumberController.text.startsWith("+91")) {
        mobNoToValidate = mobileNumberController.text.replaceFirst("+91", "");
      } else if (mobileNumberController.text.startsWith("91")) {
        mobNoToValidate = mobileNumberController.text.replaceFirst("91", "");
      }
    }
    String businessMobileNoToValidate = businessMobileNoController.text;
    if (businessMobileNoController.text.length >= 12) {
      if (businessMobileNoController.text.startsWith("+91")) {
        businessMobileNoToValidate =
            businessMobileNoController.text.replaceFirst("+91", "");
      } else if (businessMobileNoController.text.startsWith("91")) {
        businessMobileNoToValidate =
            businessMobileNoController.text.replaceFirst("91", "");
      }
    }
    String residenceMobileNoToValidate = residenceMobileNoController.text;
    if (residenceMobileNoController.text.length >= 12) {
      if (residenceMobileNoController.text.startsWith("+91")) {
        residenceMobileNoToValidate =
            residenceMobileNoController.text.replaceFirst("+91", "");
      } else if (residenceMobileNoController.text.startsWith("91")) {
        residenceMobileNoToValidate =
            residenceMobileNoController.text.replaceFirst("91", "");
      }
    }
    String emergencyNoToValidate = emergencyNumberController.text;
    if (emergencyNumberController.text.length >= 12) {
      if (emergencyNumberController.text.startsWith("+91")) {
        emergencyNoToValidate =
            emergencyNumberController.text.replaceFirst("+91", "");
      } else if (emergencyNumberController.text.startsWith("91")) {
        emergencyNoToValidate =
            emergencyNumberController.text.replaceFirst("91", "");
      }
    }
    DoctorProfileUploadModel modelPatientProfileUpload =
        DoctorProfileUploadModel(
      patientIDP,
      firstNameController.text.trim(),
      lastNameController.text.trim(),
      mobNoToValidate.trim(),
      emailController.text.trim(),
      dobController.text.trim(),
      addressController.text.trim(),
      "423",
      selectedState.idp,
      selectedCountry.idp,
      marriedController.text.trim(),
      noOfFamilyMembersController.text.trim(),
      yourPositionInFamilyController.text.trim(),
      middleNameController.text.trim(),
      /*weightValue.toString(),
            heightValue.toString(),*/
      "",
      "",
      bloodGroupController.text.trim(),
      emergencyNoToValidate.trim(),
      gender,
      speciality: selectedSpeciality != null
          ? selectedSpeciality!.specialityIdp.toString()
          : "",
      practisingSince: practisingSinceController.text.trim(),
      residenceAddress: residenceAddressController.text.trim(),
      residenceMobileNo: residenceMobileNoToValidate.trim(),
      residenceLandLineNo: "" /*residenceLandLineController.text.trim()*/,
      businessAddress: businessAddressController.text.trim(),
      businessMobileNo: businessMobileNoToValidate.trim(),
      businessLandLineNo: "" /*businessLandLineNoController.text.trim()*/,
      businessCityIDF: selectedBusinessCity.idp,
      businessStateIDF: selectedBusinessState.idp,
      businessCountryIDF: selectedBusinessCountry.idp,
      degree: degreeController.text.trim(),
      registrationNumber: registrationNumberController.text.trim(),
      whatsAppNo: whatsAppNoController.text.trim(),
      appointmentNo: appointmentNoController.text.trim(),
      latitude: latitudeController.text.trim(),
      longitude: longitudeController.text.trim(),
    );
    String jsonStr;
    jsonStr = modelPatientProfileUpload.toJson();

    debugPrint("Jsonstr - $jsonStr");
    String encodedJSONStr = encodeBase64(jsonStr);
    multipartRequest.fields['getjson'] = encodedJSONStr;
    Map<String, String> headers = Map();
    headers['u'] = patientUniqueKey;
    headers['type'] = userType;
    multipartRequest.headers.addAll(headers);
    if (image != null) {
      var imgLength = await image!.length();
      multipartRequest.files.add(new http.MultipartFile(
          'image', image!.openRead(), imgLength,
          filename: image.path));
    }

    if (imageLogo != null) {
      var imgLength2 = await imageLogo!.length();
      multipartRequest.files.add(new http.MultipartFile(
          'doctorlogo', imageLogo.openRead(), imgLength2,
          filename: imageLogo.path));
    }
    if (imageSignature != null) {
      var imgLength1 = await imageSignature!.length();
      multipartRequest.files.add(new http.MultipartFile(
          'signature', imageSignature.openRead(), imgLength1,
          filename: imageSignature.path));
    }
    var response = await apiHelper.callMultipartApi(multipartRequest);
    pr.hide();
    debugPrint("Status code -" + response.statusCode.toString());
    if (response.statusCode == 200) {
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text("Edit profile is updated!"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    response.stream.transform(utf8.decoder).listen((value) async {
      debugPrint("Response of image upload " + value);
      final jsonResponse = json.decode(value);

      ResponseModel model = ResponseModel.fromJSON(jsonResponse);
      String jArrayStr = decodeBase64(jsonResponse['Data']);
      debugPrint("Resonse Upload image ...");
      debugPrint(jArrayStr);
      // pr.hide();
      Navigator.of(context).pop();

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
    widget.imgUrlProfilePic = imgUrl;
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text("Img url - " + imgUrl),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    setState(() {});
  }

  dialogContent(BuildContext context, String title) {
    SizeConfig().init(context);

    Future getImageFromCamera() async {
      File imgSelected =
          await chooseImageWithExIfRotate(picker, ImageSource.camera);
      CroppedFile? croppedimage = await ImageCropper()
          .cropImage(sourcePath: imgSelected.path, uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
      ], aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ]);
      if (doctorProfileImageTypeController.imageType.value == "profile_pic") {
        final path = croppedimage!.path;
        widget.imageProfilePic = File(path);
      } else if (doctorProfileImageTypeController.imageType.value == "logo") {
        final path = croppedimage!.path;
        widget.imageProfilePic = File(path);
        widget.imageLogo = File(path);
      } else if (doctorProfileImageTypeController.imageType.value ==
          "signature") {
        final path = croppedimage!.path;
        widget.imageSignature = File(path);
      }
      Navigator.of(context).pop();
      setState(() {});
    }

    Future removeImage() async {
      if (doctorProfileImageTypeController.imageType.value == "profile_pic") {
        widget.imageProfilePic = null;
      } else if (doctorProfileImageTypeController.imageType.value == "logo") {
        widget.imageLogo = null;
      } else if (doctorProfileImageTypeController.imageType.value ==
          "signature") {
        widget.imageSignature = null;
      }
      /*widget.imageProfilePic = null;*/
      Navigator.of(context).pop();
      setState(() {});
    }

    Future getImageFromGallery() async {
      File imgSelected =
          await chooseImageWithExIfRotate(picker, ImageSource.gallery);
      CroppedFile? croppedImage = await ImageCropper()
          .cropImage(sourcePath: imgSelected.path, uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
      ], aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ]);
      if (doctorProfileImageTypeController.imageType.value == "profile_pic") {
        final path = croppedImage!.path;
        widget.imageProfilePic = File(path);
      } else if (doctorProfileImageTypeController.imageType.value == "logo") {
        final path = croppedImage!.path;
        widget.imageProfilePic = File(path);
        widget.imageLogo = File(path);
      } else if (doctorProfileImageTypeController.imageType.value ==
          "signature") {
        final path = croppedImage!.path;
        widget.imageSignature = File(path);
      }
      Navigator.of(context).pop();
      setState(() {});
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

  showImageTypeSelectionDialog(BuildContext context, String imageType) {
    doctorProfileImageTypeController.setImageType(imageType);
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
          title: Text("Edit Profile"),
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
        body: Builder(
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
                    Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            showImageTypeSelectionDialog(
                                context, "profile_pic");
                          },
                          child: (widget.imageProfilePic != null)
                              ? CircleAvatar(
                                  backgroundImage:
                                      FileImage(widget.imageProfilePic),
                                  radius: 60.0,
                                )
                              : (widget.imgUrlProfilePic != ""
                                  ? CircleAvatar(
                                      radius: 60.0,
                                      backgroundImage: NetworkImage(
                                          "$doctorImgUrl${widget.imgUrlProfilePic}"),
                                    )
                                  : CircleAvatar(
                                      radius: 60.0,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: AssetImage(
                                          "images/ic_user_placeholder.png") /*),*/
                                      )),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 80,
                            ),
                            GestureDetector(
                              onTap: () {
                                showImageTypeSelectionDialog(
                                    context, "profile_pic");
                              },
                              child: CircleAvatar(
                                radius: 25.0,
                                child: Image(
                                  width: 30,
                                  height: 30,
                                  color: Colors.white,
                                  //height: 80,
                                  image: AssetImage("images/ic_edit_black.png"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: registrationNumberController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Registration Number",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: firstNameController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
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
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: middleNameController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
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
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: lastNameController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Last Name",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: IgnorePointer(
                          child: TextField(
                            controller: mobileNumberController,
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      SizeConfig.blockSizeVertical! * 2.3),
                              labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      SizeConfig.blockSizeVertical! * 2.3),
                              labelText: "Mobile Number",
                              hintText: "",
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: whatsAppNoController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            counterText: "",
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Whatsapp Number",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: appointmentNoController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            counterText: "",
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Appointment Number",
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
                                      SizeConfig.blockSizeHorizontal! * 4))),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockSizeHorizontal! * 3),
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
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal! *
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
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal! *
                                                  4)),
                                  dense: true,
                                ),
                              )
                            ],
                          )),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: degreeController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Degree",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          showSpecialitySelectionDialog();
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal! * 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal! * 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: specialityController,
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
                                labelText: "Speciality",
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
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: practisingSinceController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Practising Since (Years)",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: emailController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
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
                                        SizeConfig.blockSizeVertical! * 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
                                labelText: "Date Of Birth",
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 2,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          showCountrySelectionDialog(
                              listCountriesSearchResults, "Country");
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal! * 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal! * 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: countryController,
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
                            width: SizeConfig.blockSizeHorizontal! * 90,
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 1),
                            child: IgnorePointer(
                              child: TextField(
                                controller: stateController,
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
                                  labelText: "State",
                                  hintText: "",
                                ),
                              ),
                            )),
                      ),
                    ),
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
                                        SizeConfig.blockSizeVertical! * 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.3),
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
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: residenceAddressController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Residence Address",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: residenceMobileNoController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Residence Mobile Numer",
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
                          controller: residenceLandLineController,
                          keyboardType: TextInputType.phone,
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
                            labelText: "Residence Landline",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),*/
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: businessAddressController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Hosp./Clinic Address",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: businessMobileNoController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Hosp./Clinic Mobile Numer",
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
                          controller: businessLandLineNoController,
                          keyboardType: TextInputType.phone,
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
                            labelText: "Business Landline",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),*/
                    /*Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal * 1),
                        child: TextField(
                          controller: businessCityController,
                          keyboardType: TextInputType.phone,
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
                            labelText: "Business City",
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
                          controller: businessStateController,
                          keyboardType: TextInputType.phone,
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
                            labelText: "Business State",
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
                          controller: businessCityController,
                          keyboardType: TextInputType.phone,
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
                            labelText: "Business City",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),*/

                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          showCountrySelectionDialogForBusiness(
                              listCountriesForBusinessSearchResults, "Country");
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal! * 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal! * 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: businessCountryController,
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
                                labelText: "Hosp./Clinic Country",
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
                          showCountrySelectionDialogForBusiness(
                              listStatesForBusinessSearchResults, "State");
                        },
                        child: Container(
                            width: SizeConfig.blockSizeHorizontal! * 90,
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 1),
                            child: IgnorePointer(
                              child: TextField(
                                controller: businessStateController,
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
                                  labelText: "Hosp./Clinic State",
                                  hintText: "",
                                ),
                              ),
                            )),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          showCountrySelectionDialogForBusiness(
                              listCitiesForBusinessSearchResults, "City");
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal! * 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal! * 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: businessCityController,
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
                                labelText: "Hosp./Clinic City",
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
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: latitudeController,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: SizeConfig.blockSizeVertical! * 2.3,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Latitude",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: longitudeController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            counterText: "",
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Longitude",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 2.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockSizeHorizontal! * 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                showImageTypeSelectionDialog(context, "logo");
                              },
                              child: (widget.imageLogo != null)
                                  ? Stack(
                                      children: [
                                        Column(
                                          children: [
                                            Image(
                                              image:
                                                  FileImage(widget.imageLogo),
                                              width: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  35,
                                              height: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  35,
                                              fit: BoxFit.fill,
                                            ),
                                            SizedBox(
                                              height: SizeConfig
                                                      .blockSizeVertical! *
                                                  0.5,
                                            ),
                                            Text(
                                              "Logo",
                                              style: TextStyle(
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    3.8,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          right:
                                              SizeConfig.blockSizeHorizontal! *
                                                  3.0,
                                          top: SizeConfig.blockSizeHorizontal! *
                                              3.0,
                                          child: CircleAvatar(
                                            radius: SizeConfig
                                                    .blockSizeHorizontal! *
                                                5,
                                            child: Image(
                                              width: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  5,
                                              height: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  5,
                                              color: Colors.white,
                                              //height: 80,
                                              image: AssetImage(
                                                  "images/ic_edit_black.png"),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : (widget.imgUrlLogo != ""
                                      ? Stack(
                                          children: [
                                            Column(
                                              children: [
                                                Image(
                                                  image: NetworkImage(
                                                      "$doctorLogoUrl${widget.imgUrlLogo}"),
                                                  width: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      35,
                                                  height: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      35,
                                                  fit: BoxFit.fill,
                                                ),
                                                SizedBox(
                                                  height: SizeConfig
                                                          .blockSizeVertical! *
                                                      0.5,
                                                ),
                                                Text(
                                                  "Logo",
                                                  style: TextStyle(
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        3.8,
                                                    color: Colors.blueGrey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Positioned(
                                              right: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  3.0,
                                              top: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  3.0,
                                              child: CircleAvatar(
                                                radius: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    5,
                                                child: Image(
                                                  width: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      5,
                                                  height: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      5,
                                                  color: Colors.white,
                                                  //height: 80,
                                                  image: AssetImage(
                                                      "images/ic_edit_black.png"),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Container(
                                                width: double.infinity,
                                                color: Colors.grey,
                                                height: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    35.0,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: SizeConfig
                                                            .blockSizeVertical! *
                                                        2.0,
                                                  ),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image(
                                                          image: AssetImage(
                                                              "images/ic_file_upload.png"),
                                                          width: SizeConfig
                                                                  .blockSizeHorizontal! *
                                                              10,
                                                          height: SizeConfig
                                                                  .blockSizeHorizontal! *
                                                              10,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(
                                                          height: SizeConfig
                                                                  .blockSizeVertical! *
                                                              1.8,
                                                        ),
                                                        Text(
                                                          "Click to upload Logo",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: SizeConfig
                                                                      .blockSizeHorizontal! *
                                                                  3.4),
                                                        ),
                                                      ]),
                                                )),
                                            SizedBox(
                                              height: SizeConfig
                                                      .blockSizeVertical! *
                                                  0.5,
                                            ),
                                            Text(
                                              "",
                                              style: TextStyle(
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    3.8,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ],
                                        )),
                            ),
                          ),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal! * 2.0,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                showImageTypeSelectionDialog(
                                    context, "signature");
                              },
                              child: (widget.imageSignature != null)
                                  ? Stack(
                                      children: [
                                        Column(
                                          children: [
                                            Image(
                                              image: FileImage(
                                                  widget.imageSignature),
                                              width: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  35,
                                              height: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  35,
                                              fit: BoxFit.fill,
                                            ),
                                            SizedBox(
                                              height: SizeConfig
                                                      .blockSizeVertical! *
                                                  0.5,
                                            ),
                                            Text(
                                              "Signature",
                                              style: TextStyle(
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    3.8,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          right:
                                              SizeConfig.blockSizeHorizontal! *
                                                  3.0,
                                          top: SizeConfig.blockSizeHorizontal! *
                                              3.0,
                                          child: CircleAvatar(
                                            radius: SizeConfig
                                                    .blockSizeHorizontal! *
                                                5,
                                            child: Image(
                                              width: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  5,
                                              height: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  5,
                                              color: Colors.white,
                                              //height: 80,
                                              image: AssetImage(
                                                  "images/ic_edit_black.png"),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : (widget.imgUrlSignature != ""
                                      ? Stack(
                                          children: [
                                            Column(
                                              children: [
                                                Image(
                                                  image: NetworkImage(
                                                      "$doctorSignatureUrl${widget.imgUrlSignature}"),
                                                  width: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      35,
                                                  height: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      35,
                                                  fit: BoxFit.fill,
                                                ),
                                                SizedBox(
                                                  height: SizeConfig
                                                          .blockSizeVertical! *
                                                      0.5,
                                                ),
                                                Text(
                                                  "Signature",
                                                  style: TextStyle(
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        3.8,
                                                    color: Colors.blueGrey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Positioned(
                                              right: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  3.0,
                                              top: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  3.0,
                                              child: CircleAvatar(
                                                radius: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    5,
                                                child: Image(
                                                  width: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      5,
                                                  height: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      5,
                                                  color: Colors.white,
                                                  //height: 80,
                                                  image: AssetImage(
                                                      "images/ic_edit_black.png"),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Container(
                                                width: double.infinity,
                                                color: Colors.blueGrey,
                                                height: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    35.0,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: SizeConfig
                                                            .blockSizeVertical! *
                                                        2.0,
                                                  ),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image(
                                                          image: AssetImage(
                                                              "images/ic_file_upload.png"),
                                                          width: SizeConfig
                                                                  .blockSizeHorizontal! *
                                                              10,
                                                          height: SizeConfig
                                                                  .blockSizeHorizontal! *
                                                              10,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(
                                                          height: SizeConfig
                                                                  .blockSizeVertical! *
                                                              1.8,
                                                        ),
                                                        Text(
                                                          "Click to upload Signature",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: SizeConfig
                                                                      .blockSizeHorizontal! *
                                                                  3.4),
                                                        ),
                                                      ]),
                                                )),
                                            SizedBox(
                                              height: SizeConfig
                                                      .blockSizeVertical! *
                                                  0.5,
                                            ),
                                            Text(
                                              "",
                                              style: TextStyle(
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    3.8,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ],
                                        )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
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
                          submitImageForUpdate(context, widget.imageProfilePic,
                              widget.imageLogo, widget.imageSignature);
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
        getStatesList(selectedCountry.idp, "personal");
      }
      if (type == "State") {
        getCitiesList(selectedState.idp, "personal");
      }
      if (type == "City") {}
    });
  }

  void callbackFromCountryDialogForBusiness(String type) {
    setState(() {
      if (type == "Country") {
        getStatesList(selectedBusinessCountry.idp, "business");
      }
      if (type == "State") {
        getCitiesList(selectedBusinessState.idp, "business");
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

  void showCountrySelectionDialogForBusiness(
      List<DropDownItem> list, String type) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CountryDialogForBusiness(
            list, type, callbackFromCountryDialogForBusiness));
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

  void showSpecialitySelectionDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => SpecialityDialog(listSpeciality, () {
              setState(() {});
            }) /*Column(
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
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 6,
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal * 50,
                          height: SizeConfig.blockSizeVertical * 8,
                          child: Center(
                            child: Text(
                              "Select Speciality",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 4.8,
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
                      itemCount: listSpeciality.length,
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () {
                              specialityController = TextEditingController(
                                  text: listSpeciality[index].specialityName);
                              selectedSpeciality = listSpeciality[index];
                              setState(() {});
                              Navigator.of(context).pop();
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
                                        listSpeciality[index].specialityName,
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
            )*/
        );
  }

  void getStatesListNoProgressDialog(String countryIDF, String from) async {
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
        countryIDF +
        "\"" +
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
    /*pr.hide();*/
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      if (from == "personal") {
        listStates = [];
        listStatesSearchResults = [];
      } else if (from == "business") {
        listStatesForBusiness = [];
        listStatesForBusinessSearchResults = [];
      }
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        if (from == "personal") {
          listStates.add(DropDownItem(jo['StateIDP'], jo['StateName']));
          listStatesSearchResults
              .add(DropDownItem(jo['StateIDP'], jo['StateName']));
        } else if (from == "business") {
          listStatesForBusiness
              .add(DropDownItem(jo['StateIDP'], jo['StateName']));
          listStatesForBusinessSearchResults
              .add(DropDownItem(jo['StateIDP'], jo['StateName']));
        }
      }
      setState(() {});
    }
  }

  void getCitiesList(String idp, String from) async {
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
        idp +
        "\"" +
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
    pr?.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      if (from == "personal") {
        listCities = [];
        listCitiesSearchResults = [];
      } else if (from == "business") {
        listCitiesForBusiness = [];
        listCitiesForBusinessSearchResults = [];
      }
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        if (from == "personal") {
          listCities.add(DropDownItem(jo['CityIDP'], jo['CityName']));
          listCitiesSearchResults
              .add(DropDownItem(jo['CityIDP'], jo['CityName']));
        } else if (from == "business") {
          listCitiesForBusiness
              .add(DropDownItem(jo['CityIDP'], jo['CityName']));
          listCitiesForBusinessSearchResults
              .add(DropDownItem(jo['CityIDP'], jo['CityName']));
        }
      }
      setState(() {});
    }
  }

  void getCitiesListNoProgressDialog(String stateIDF, String from) async {
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
        stateIDF +
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
      if (from == "personal") {
        listCities = [];
        listCitiesSearchResults = [];
      } else if (from == "business") {
        listCitiesForBusiness = [];
        listCitiesForBusinessSearchResults = [];
      }
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        if (from == "personal") {
          listCities.add(DropDownItem(jo['CityIDP'], jo['CityName']));
          listCitiesSearchResults
              .add(DropDownItem(jo['CityIDP'], jo['CityName']));
        } else if (from == "business") {
          listCitiesForBusiness
              .add(DropDownItem(jo['CityIDP'], jo['CityName']));
          listCitiesForBusinessSearchResults
              .add(DropDownItem(jo['CityIDP'], jo['CityName']));
        }
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

  void fillAllValues() async {
    // ProgressDialog pr = ProgressDialog(context);
    // Future.delayed(Duration.zero, () {
    //   pr.show();
    // });
    if (widget.patientProfileModel!.countryIDF != null &&
        widget.patientProfileModel!.countryIDF != "null" &&
        widget.patientProfileModel!.countryIDF != "") {
      selectedCountry = DropDownItem(widget.patientProfileModel!.countryIDF!,
          widget.patientProfileModel!.country!);
      getStatesListNoProgressDialog(
          widget.patientProfileModel!.countryIDF!, "personal");
    }

    if (widget.patientProfileModel!.specialityIDP != "") {
      selectedSpeciality = SpecialityModel(
          specialityIdp: int.parse(widget.patientProfileModel!.specialityIDP!),
          specialityName: widget.patientProfileModel!.speciality);
    }

    if (widget.patientProfileModel!.stateIDF != null &&
        widget.patientProfileModel!.stateIDF != "null" &&
        widget.patientProfileModel!.stateIDF != "") {
      selectedState = DropDownItem(widget.patientProfileModel!.stateIDF!,
          widget.patientProfileModel!.state!);
      getCitiesListNoProgressDialog(
          widget.patientProfileModel!.stateIDF!, "personal");
    }

    if (widget.patientProfileModel!.businessCountryIDP != null &&
        widget.patientProfileModel!.businessCountryIDP != "null" &&
        widget.patientProfileModel!.businessCountryIDP != "") {
      /*selectedBusinessCountry = DropDownItem(
          widget.patientProfileModel.businessCountryIDP,
          widget.patientProfileModel.businessCountry);
      getStatesListNoProgressDialog(
          widget.patientProfileModel.businessCountryIDP);*/
      selectedBusinessCountry = DropDownItem(
          widget.patientProfileModel!.countryIDF!,
          widget.patientProfileModel!.country!);
      getStatesListNoProgressDialog(
          widget.patientProfileModel!.countryIDF!, "business");
    }

    if (widget.patientProfileModel!.businessStateIDP != null &&
        widget.patientProfileModel!.businessStateIDP != "null" &&
        widget.patientProfileModel!.businessStateIDP != "") {
      /*selectedBusinessState = DropDownItem(
          widget.patientProfileModel.businessStateIDP,
          widget.patientProfileModel.businessState);
      getCitiesListNoProgressDialog(
          widget.patientProfileModel.businessStateIDP);*/
      selectedBusinessState = DropDownItem(
          widget.patientProfileModel!.stateIDF!,
          widget.patientProfileModel!.state!);
      getCitiesListNoProgressDialog(
          widget.patientProfileModel!.stateIDF!, "business");
    }

    if (widget.patientProfileModel!.businessCityIDP != null &&
        widget.patientProfileModel!.businessCityIDP != "null" &&
        widget.patientProfileModel!.businessCityIDP != "") {
      selectedBusinessCity = DropDownItem(widget.patientProfileModel!.cityIDF!,
          widget.patientProfileModel!.city!);
    }

    registrationNumberController = TextEditingController(
        text: widget.patientProfileModel!.registrationNumber != "-"
            ? widget.patientProfileModel!.registrationNumber
            : "");
    firstNameController = TextEditingController(
        text: widget.patientProfileModel!.firstName != "-"
            ? widget.patientProfileModel!.firstName
            : "");
    middleNameController = TextEditingController(
        text: widget.patientProfileModel!.middleName != "-"
            ? widget.patientProfileModel!.middleName
            : "");
    lastNameController = TextEditingController(
        text: widget.patientProfileModel!.lastName != "-"
            ? widget.patientProfileModel!.lastName
            : "");
    mobileNumberController = TextEditingController(
        text: widget.patientProfileModel!.mobNo != "-"
            ? widget.patientProfileModel!.mobNo
            : "");
    emailController = TextEditingController(
        text: widget.patientProfileModel!.emailId != "-"
            ? widget.patientProfileModel!.emailId
            : "");
    dobController = TextEditingController(
        text: widget.patientProfileModel!.dob != "-"
            ? widget.patientProfileModel!.dob
            : "");
    // ageController = TextEditingController(
    // text: widget.patientProfileModel!.age != "-"
    //     ? widget.patientProfileModel!.age
    //     : "");
    addressController = TextEditingController(
        text: widget.patientProfileModel!.address != "-"
            ? widget.patientProfileModel!.address
            : "");
    cityController = TextEditingController(
        text: widget.patientProfileModel!.city != "-"
            ? widget.patientProfileModel!.city
            : "");
    stateController = TextEditingController(
        text: widget.patientProfileModel!.state != "-"
            ? widget.patientProfileModel!.state
            : "");
    countryController = TextEditingController(
        text: widget.patientProfileModel!.country != "-"
            ? widget.patientProfileModel!.country
            : "");
    marriedController = TextEditingController(
        text: widget.patientProfileModel!.married != "-"
            ? widget.patientProfileModel!.married
            : "");
    noOfFamilyMembersController = TextEditingController(
        text: widget.patientProfileModel!.noOfFamilyMembers != "-"
            ? widget.patientProfileModel!.noOfFamilyMembers
            : "");
    yourPositionInFamilyController = TextEditingController(
        text: widget.patientProfileModel!.yourPositionInFamily != "-"
            ? widget.patientProfileModel!.yourPositionInFamily
            : "");
    // middleNameController = TextEditingController(
    //     text: widget.patientProfileModel!.middleName != "-"
    //         ? widget.patientProfileModel!.middleName
    //         : "");
    // weightController = TextEditingController(
    //     text: widget.patientProfileModel!.weight != "-"
    //         ? widget.patientProfileModel!.weight
    //         : "");
    // heightController = TextEditingController(
    //     text: widget.patientProfileModel!.height != "-"
    //         ? widget.patientProfileModel!.height
    //         : "");
    // bloodGroupController = TextEditingController(
    //     text: widget.patientProfileModel!.bloodGroup != "-"
    //         ? widget.patientProfileModel!.bloodGroup
    //         : "");
    // emergencyNumberController = TextEditingController(
    //     text: widget.patientProfileModel!.emergencyNumber != "-"
    //         ? widget.patientProfileModel!.emergencyNumber
    //         : "");
    if (widget.patientProfileModel!.gender == "M")
      _radioValueGender = 0;
    else if (widget.patientProfileModel!.gender == "F") _radioValueGender = 1;

    // selectedCountry = DropDownItem(widget.patientProfileModel!.countryIDF!,
    //     widget.patientProfileModel!.country!);
    // selectedState = DropDownItem(
    //     widget.patientProfileModel!.stateIDF!, widget.patientProfileModel!.state!);
    // selectedCity = DropDownItem(
    //     widget.patientProfileModel!.cityIDF!, widget.patientProfileModel!.city!);

    degreeController = TextEditingController(
        text: widget.patientProfileModel!.degree != "-"
            ? widget.patientProfileModel!.degree
            : "");
    specialityController = TextEditingController(
        text: widget.patientProfileModel!.speciality != "-"
            ? widget.patientProfileModel!.speciality
            : "");
    practisingSinceController = TextEditingController(
        text: widget.patientProfileModel!.practisingSince != "-"
            ? widget.patientProfileModel!.practisingSince
            : "");
    residenceAddressController = TextEditingController(
        text: widget.patientProfileModel!.residenceAddress != "-"
            ? widget.patientProfileModel!.residenceAddress
            : "");
    residenceMobileNoController = TextEditingController(
        text: widget.patientProfileModel!.residenceMobileNo != "-"
            ? widget.patientProfileModel!.residenceMobileNo
            : "");
    // /*residenceLandLineController = TextEditingController(
    //     text: widget.patientProfileModel.residenceLandLineNo != "-"
    //         ? widget.patientProfileModel.residenceLandLineNo
    //         : "");*/
    businessAddressController = TextEditingController(
        text: widget.patientProfileModel!.businessAddress != "-"
            ? widget.patientProfileModel!.businessAddress
            : "");
    businessMobileNoController = TextEditingController(
        text: widget.patientProfileModel!.businessMobileNo != "-"
            ? widget.patientProfileModel!.businessMobileNo
            : "");
    // /*businessLandLineNoController = TextEditingController(
    //     text: widget.patientProfileModel.businessLandLineNo != "-"
    //         ? widget.patientProfileModel.businessLandLineNo
    //         : "");*/
    //
    businessCountryController = TextEditingController(
        text: widget.patientProfileModel!.businessCountry != "-"
            ? widget.patientProfileModel!.businessCountry
            : "");

    businessStateController = TextEditingController(
        text: widget.patientProfileModel!.businessState != "-"
            ? widget.patientProfileModel!.businessState
            : "");

    businessCityController = TextEditingController(
        text: widget.patientProfileModel!.businessCity != "-"
            ? widget.patientProfileModel!.businessCity
            : "");

    whatsAppNoController = TextEditingController(
        text: widget.patientProfileModel!.whatsAppNumber != "-"
            ? widget.patientProfileModel!.whatsAppNumber
            : "");

    appointmentNoController = TextEditingController(
        text: widget.patientProfileModel!.appointmentNumber != "-"
            ? widget.patientProfileModel!.appointmentNumber
            : "");

    latitudeController = TextEditingController(
        text: widget.patientProfileModel!.latitude != "-"
            ? widget.patientProfileModel!.latitude
            : "");

    longitudeController = TextEditingController(
        text: widget.patientProfileModel!.longitude != "-"
            ? widget.patientProfileModel!.longitude
            : "");
    // setState(() {
    //   pr.hide();
    // });
  }
}

class SpecialityDialog extends StatefulWidget {
  List<SpecialityModel> listSpeciality;
  Function callbackFromSpecialityDialog;

  SpecialityDialog(this.listSpeciality, this.callbackFromSpecialityDialog);

  @override
  State<StatefulWidget> createState() {
    return SpecialityDialogState();
  }
}

class SpecialityDialogState extends State<SpecialityDialog> {
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
      "Select Speciality",
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
                                          widget.listSpeciality = listSpeciality
                                              .where((dropDownObj) =>
                                                  dropDownObj.specialityName!
                                                      .toLowerCase()
                                                      .contains(
                                                          text.toLowerCase()))
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
                                        hintText: "Search Speciality",
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
                                      "Select Speciality",
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
            Expanded(
              child: ListView.builder(
                  itemCount: widget.listSpeciality.length,
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          selectedSpeciality = widget.listSpeciality[index];
                          specialityController = TextEditingController(
                              text: selectedSpeciality!.specialityName);
                          setState(() {});
                          debugPrint(
                              "Selcted speciality : ${selectedSpeciality!.specialityIdp} ${selectedSpeciality!.specialityName}");
                          Navigator.of(context).pop();
                          widget.callbackFromSpecialityDialog();
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
                                    widget
                                        .listSpeciality[index].specialityName!,
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
        ));
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
                                            widget.list = listCities
                                                .where((dropDownObj) =>
                                                    dropDownObj.value
                                                        .toLowerCase()
                                                        .contains(
                                                            text.toLowerCase()))
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
          ],
        ));
  }
}

class CountryDialogForBusiness extends StatefulWidget {
  List<DropDownItem> list;
  String type;
  Function callbackFromCountryDialog;

  CountryDialogForBusiness(
      this.list, this.type, this.callbackFromCountryDialog);

  @override
  State<StatefulWidget> createState() {
    return CountryDialogStateForBusiness();
  }
}

class CountryDialogStateForBusiness extends State<CountryDialogForBusiness> {
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
                                            widget.list =
                                                listCountriesForBusiness
                                                    .where((dropDownObj) =>
                                                        dropDownObj.value
                                                            .toLowerCase()
                                                            .contains(text
                                                                .toLowerCase()))
                                                    .toList();
                                          else if (widget.type == "State")
                                            widget.list = listStatesForBusiness
                                                .where((dropDownObj) =>
                                                    dropDownObj.value
                                                        .toLowerCase()
                                                        .contains(
                                                            text.toLowerCase()))
                                                .toList();
                                          else if (widget.type == "City")
                                            widget.list = listCitiesForBusiness
                                                .where((dropDownObj) =>
                                                    dropDownObj.value
                                                        .toLowerCase()
                                                        .contains(
                                                            text.toLowerCase()))
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
                                      widget.list = listCountriesForBusiness;
                                    else if (widget.type == "State")
                                      widget.list = listStatesForBusiness;
                                    else if (widget.type == "City")
                                      widget.list = listCitiesForBusiness;
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
                            selectedBusinessCountry = widget.list[index];
                            businessCountryController = TextEditingController(
                                text: selectedBusinessCountry.value);
                            Navigator.of(context).pop();
                            //setState(() {});
                            //getStatesList();
                            widget.callbackFromCountryDialog(widget.type);
                          }
                          if (widget.type == "State") {
                            selectedBusinessState = widget.list[index];
                            businessStateController = TextEditingController(
                                text: selectedBusinessState.value);
                            Navigator.of(context).pop();
                            //setState(() {});
                            //getCitiesList();
                            widget.callbackFromCountryDialog(widget.type);
                          }
                          if (widget.type == "City") {
                            selectedBusinessCity = widget.list[index];
                            businessCityController = TextEditingController(
                                text: selectedBusinessCity.value);
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
}

/*class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  int min;

  int max;
  String title = "";
  double value;
  final fullWidth;
  String unit;
  Function callbackFromBMI;

  SliderWidget(
      {this.sliderHeight = 50,
      this.max = 1000,
      this.min = 0,
      this.value,
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
                      )
                    ],
                  )),
              Row(
                children: <Widget>[
                  Text(
                    '${this.widget.min}',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal * 1.5,
                  ),
                  Expanded(
                    child: Center(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.teal.withOpacity(1),
                          inactiveTrackColor: Colors.teal.withOpacity(.5),
                          trackHeight: 2.0,
                          */ /*thumbShape: CustomSliderThumbCircle(
                            thumbRadius: this.widget.sliderHeight * .3,
                            min: 0,
                            max: this.widget.max,
                          ),*/ /*
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
                            */ /*value: widget.title == "Pulse"
                                ? pulseValue
                                : (widget.title == "Systolic"
                                    ? bpSystolicValue
                                    : (widget.title == "Diastolic"
                                        ? bpDiastolicValue
                                        : (widget.title == "Temperature"
                                            ? tempValue
                                            : spo2Value))),*/ /*
                            onChanged: (val) {
                              setState(() {
                                _value = val;
                                widget.value = val;
                                if (widget.title == "Weight") {
                                  weightValue = widget.value.round();
                                  widget.callbackFromBMI();
                                } else if (widget.title == "Height") {
                                  heightValue = widget.value.round();
                                  cmToFeet();
                                  widget.callbackFromBMI();
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
                      fontSize: SizeConfig.blockSizeHorizontal * 3.5,
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
}*/
