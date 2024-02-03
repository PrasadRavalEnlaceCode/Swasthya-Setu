import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:swasthyasetu/api/api_helper.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/dropdown_item.dart';
import 'package:swasthyasetu/podo/model_profile_patient.dart';
import 'package:swasthyasetu/podo/patient_profile_upload_model.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/multipart_request_with_progress.dart';
import 'package:swasthyasetu/utils/progress_dialog_with_percentage.dart';
import 'package:swasthyasetu/utils/ultimate_slider.dart';

import '../utils/color.dart';
import '../utils/progress_dialog.dart';
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
TextEditingController genderController = TextEditingController();

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

double weightValue = 0, heightValue = 0;

class EditMyProfilePatient extends StatefulWidget {
  String? imgUrl = "";
  var image;
  PatientProfileModel? patientProfileModel;
  String? patientIDP = "";

  EditMyProfilePatient(PatientProfileModel patientProfileModel, String imgUrl,
      String patientIDP) {
    this.patientProfileModel = patientProfileModel;
    this.imgUrl = imgUrl;
    this.patientIDP = patientIDP;
  }

  @override
  State<StatefulWidget> createState() {
    return EditMyProfilePatientState();
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

class EditMyProfilePatientState extends State<EditMyProfilePatient> {
  String type = "";
  GlobalKey<ProgressDialogWithPercentageState> progressKey = GlobalKey();
  ApiHelper apiHelper = ApiHelper();
  final picker = ImagePicker();

  var isDoctor = true;

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
    getCountriesList();
    if (widget.patientProfileModel!.countryIDF != null &&
        widget.patientProfileModel!.countryIDF != "null" &&
        widget.patientProfileModel!.countryIDF != "") {
      selectedCountry = DropDownItem(widget.patientProfileModel!.countryIDF!,
          widget.patientProfileModel!.country!);
      getStatesListNoProgressDialog();
    }

    if (widget.patientProfileModel!.stateIDF != null &&
        widget.patientProfileModel!.stateIDF != "null" &&
        widget.patientProfileModel!.stateIDF != "") {
      selectedState = DropDownItem(widget.patientProfileModel!.stateIDF!,
          widget.patientProfileModel!.state!);
      getCitiesListNoProgressDialog();
    }

    patientIDController = TextEditingController(
        text: widget.patientProfileModel!.patientID != "-"
            ? widget.patientProfileModel!.patientID
            : "");
    firstNameController = TextEditingController(
        text: widget.patientProfileModel!.firstName != "-"
            ? widget.patientProfileModel!.firstName
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
    ageController = TextEditingController(
        text: widget.patientProfileModel!.age != "-"
            ? widget.patientProfileModel!.age
            : "");
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
    middleNameController = TextEditingController(
        text: widget.patientProfileModel!.middleName != "-"
            ? widget.patientProfileModel!.middleName
            : "");
    weightController = TextEditingController(
        text: widget.patientProfileModel!.weight != "-"
            ? widget.patientProfileModel!.weight
            : "");
    heightValue = double.parse(widget.patientProfileModel!.height != "-"
        ? widget.patientProfileModel!.height.toString()
        : "0");
    weightValue = double.parse(widget.patientProfileModel!.weight != "-"
        ? widget.patientProfileModel!.weight.toString()
        : "0");
    print('heightValue $heightValue $weightValue');
    heightController = TextEditingController(
        text: widget.patientProfileModel!.height != "-"
            ? widget.patientProfileModel!.height
            : "");
    bloodGroupController = TextEditingController(
        text: widget.patientProfileModel!.bloodGroup != "-"
            ? widget.patientProfileModel!.bloodGroup
            : "");
    emergencyNumberController = TextEditingController(
        text: widget.patientProfileModel!.emergencyNumber != "-"
            ? widget.patientProfileModel!.emergencyNumber
            : "");
    /*genderController = TextEditingController(
        text: widget.patientProfileModel.gender != "-"
            ? widget.patientProfileModel.gender
            : "");*/
    if (widget.patientProfileModel!.gender == "M")
      _radioValueGender = 0;
    else if (widget.patientProfileModel!.gender == "F") _radioValueGender = 1;

    heightValue = double.parse(widget.patientProfileModel!.height!);
    weightValue = double.parse(widget.patientProfileModel!.weight!);
    cmToFeet();

    selectedCountry = DropDownItem(widget.patientProfileModel!.countryIDF!,
        widget.patientProfileModel!.country!);
    selectedState = DropDownItem(
        widget.patientProfileModel!.stateIDF!, widget.patientProfileModel!.state!);
    selectedCity = DropDownItem(
        widget.patientProfileModel!.cityIDF!, widget.patientProfileModel!.city!);

    getUserType().then((value) {
      type = value;
      isDoctor = value == 'doctor' ? true : false;
      setState(() {});
    });
    print('widget.patientProfileModel!.weight ${widget.patientProfileModel!.weight}');
    print('widget.patientProfileModel!.height ${widget.patientProfileModel!.height}');
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

  Future<void> submitImageForUpdate(BuildContext context,[File? image]) async {
    /*ProgressDialog pr = ProgressDialog(context);
    pr.show();*/
    //var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));

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
    print('weightValue $weightValue $heightValue');
    PatientProfileUploadModel modelPatientProfileUpload =
        PatientProfileUploadModel(
            widget.patientIDP,
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
            weightValue.toStringAsFixed(2),
            heightValue.toStringAsFixed(2),
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
    if(image!=null)
      {
        var imgLength = await image!.length();
        multipartRequest.files.add(new http.MultipartFile(
            'image', image.openRead(), imgLength,
            filename: image.path));
      }
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

    Future getImageFromCamera() async {
      /*ViewProfileDetailsState.image =
        await ImagePicker.pickImage(source: ImageSource.camera);*/
      //widget.image = await ImagePicker.pickImage(source: ImageSource.camera);
      File imgSelected =
          await chooseImageWithExIfRotate(picker, ImageSource.camera);
      CroppedFile? croppedimage = await ImageCropper().cropImage(
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
          ]);
      final path = croppedimage!.path;
      widget.image = File(path);
      // widget.image = imgSelected;
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

      CroppedFile? croppedImage = await ImageCropper().cropImage(
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
          ]);
      final path = croppedImage!.path;
      widget.image = File(path);
      //widget.image = imgSelected;
      Navigator.of(context).pop();
      setState(() {});
      //if (image != null) submitImageForUpdate(context, image);
      //_controller.add(image);
    }

    return Stack(
      children: <Widget>[
        //...bottom card part,
        Container(
          width: SizeConfig.blockSizeHorizontal !* 90,
          height: SizeConfig.blockSizeVertical !* 25,
          padding: EdgeInsets.only(
            top: SizeConfig.blockSizeVertical !* 1,
            bottom: SizeConfig.blockSizeVertical !* 1,
            left: SizeConfig.blockSizeHorizontal !* 1,
            right: SizeConfig.blockSizeHorizontal !* 1,
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
                      size: SizeConfig.blockSizeVertical !* 2.8,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeVertical !* 2.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 0.5,
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
                      width: SizeConfig.blockSizeHorizontal !* 10,
                      height: SizeConfig.blockSizeVertical !* 10,
                      //height: 80,
                      image: AssetImage("images/ic_camera.png"),
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal !* 0.5,
                  ),
                  MaterialButton(
                    onPressed: () {
                      getImageFromGallery();
                    },
                    child: Image(
                      fit: BoxFit.contain,
                      width: SizeConfig.blockSizeHorizontal !* 10,
                      height: SizeConfig.blockSizeVertical !* 10,
                      //height: 80,
                      image: AssetImage("images/ic_gallery.png"),
                    ),
                  ),
                  SizedBox
                  (
                    width: SizeConfig.blockSizeHorizontal !* 0.5,
                  ),
                  MaterialButton(
                    onPressed: ()
                    {
                      removeImage();
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: SizeConfig.blockSizeHorizontal !* 10,
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
              child: dialogContent(context, "Select Image"),
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
              color: Colorsblack, size: SizeConfig.blockSizeVertical !* 2.2), toolbarTextStyle: TextTheme(
              titleMedium: TextStyle(
                  color: Colorsblack,
                  fontFamily: "Ubuntu",
                  fontSize: SizeConfig.blockSizeVertical !* 2.5)).bodyMedium, titleTextStyle: TextTheme(
              titleMedium: TextStyle(
                  color: Colorsblack,
                  fontFamily: "Ubuntu",
                  fontSize: SizeConfig.blockSizeVertical !* 2.5)).titleLarge,
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
                            showImageTypeSelectionDialog(context);
                          },
                          child: (widget.image != null)
                              ? CircleAvatar(
                                  backgroundImage: FileImage(widget.image),
                                  radius: 60.0,
                                )
                              : (widget.imgUrl != ""
                                  ? CircleAvatar(
                                      radius: 60.0,
                                      backgroundImage: NetworkImage(
                                          "$userImgUrl${widget.imgUrl}"),
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
                                showImageTypeSelectionDialog(context);
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
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: IgnorePointer(
                          child: TextField(
                            controller: patientIDController,
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              labelText: "Patient ID",
                              hintText: "",
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                enabled: isDoctor,
                                controller: firstNameController,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.3),
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.3),
                                  labelText: "First Name",
                                  hintText: "",
                                ),
                              ),
                            ),
                            isDoctor
                                ? Container()
                                : IconButton(
                                    onPressed: () => showInfo(),
                                    icon: Icon(Icons.info, color: Colors.green),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                enabled: isDoctor,
                                controller: middleNameController,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.3),
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.3),
                                  labelText: "Middle Name",
                                  hintText: "",
                                ),
                              ),
                            ),
                            isDoctor
                                ? Container()
                                : IconButton(
                                    onPressed: () => showInfo(),
                                    icon: Icon(Icons.info, color: Colors.green),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: lastNameController,
                                enabled: isDoctor,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.3),
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.3),
                                  labelText: "Last Name",
                                  hintText: "",
                                ),
                              ),
                            ),
                            isDoctor
                                ? Container()
                                : IconButton(
                                    onPressed: () => showInfo(),
                                    icon: Icon(Icons.info, color: Colors.green),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: mobileNumberController,
                                enabled: isDoctor,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.3),
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.3),
                                  labelText: "Mobile Number",
                                  hintText: "",
                                ),
                              ),
                            ),
                            isDoctor
                                ? Container()
                                : IconButton(
                                    onPressed: () => showInfo(),
                                    icon: Icon(Icons.info, color: Colors.green),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical !* 1,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal !* 5),
                          child: Text("Gender",
                              style: TextStyle(
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal !* 4))),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockSizeHorizontal !* 3),
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
                                              SizeConfig.blockSizeHorizontal !*
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
                                              SizeConfig.blockSizeHorizontal !*
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
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: type == "patient"
                            ? TextField(
                                controller: emergencyNumberController,
                                keyboardType: TextInputType.phone,
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3,
                                ),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.3),
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.3),
                                  labelText: "Emergency Number",
                                  hintText: "",
                                ),
                              )
                            : IgnorePointer(
                                child: TextField(
                                  controller: emergencyNumberController,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3,
                                  ),
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            SizeConfig.blockSizeVertical !* 2.3),
                                    labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            SizeConfig.blockSizeVertical !* 2.3),
                                    labelText: "Emergency Number",
                                    hintText: "",
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: type == "doctor"
                            ? IgnorePointer(
                                child: TextField(
                                  controller: emailController,
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.3),
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            SizeConfig.blockSizeVertical !* 2.3),
                                    labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            SizeConfig.blockSizeVertical !* 2.3),
                                    labelText: "Email",
                                    hintText: "",
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: emailController,
                                      enabled: isDoctor,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.3),
                                      decoration: InputDecoration(
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
                                        labelText: "Email",
                                        hintText: "",
                                      ),
                                    ),
                                  ),
                                  isDoctor
                                      ? Container()
                                      : IconButton(
                                          onPressed: () => showInfo(),
                                          icon: Icon(Icons.info,
                                              color: Colors.green),
                                        ),
                                ],
                              ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          isDoctor ? showDateSelectionDialog() : Container();
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 1),
                          child: IgnorePointer(
                            child: TextField(
                              enabled: isDoctor,
                              controller: dobController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelText: "Date Of Birth",
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical !* 2,
                    ),
                    SliderWidget(
                        min: 0,
                        max: 200,
                        value: heightValue.toDouble(),
                        title: "Height",
                        unit: "Centimeter",
                        callbackFromBMI: callbackFromBMI),
                    SliderWidget(
                        min: 0,
                        max: 120,
                        value: weightValue.toDouble(),
                        title: "Weight",
                        unit: "Kg",
                        callbackFromBMI: callbackFromBMI),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          showBloodGroupSelectionDialog(listBloodGroup);
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: bloodGroupController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelText: "Blood Group",
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
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: addressController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: "Address",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          showCountrySelectionDialog(
                              listCountriesSearchResults, "Country");
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: countryController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
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
                            width: SizeConfig.blockSizeHorizontal !* 90,
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal !* 1),
                            child: IgnorePointer(
                              child: TextField(
                                controller: stateController,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.3),
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.3),
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
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: cityController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
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
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: marriedController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: "Married",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: noOfFamilyMembersController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: "No. of Family Members",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: yourPositionInFamilyController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: "Your position in family",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
                Container(
                  height: SizeConfig.blockSizeVertical !* 12,
                  padding: EdgeInsets.only(
                      right: SizeConfig.blockSizeHorizontal !* 3.5,
                      top: SizeConfig.blockSizeVertical !* 3.5),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: SizeConfig.blockSizeHorizontal !* 12,
                      height: SizeConfig.blockSizeHorizontal !* 12,
                      child: RawMaterialButton(
                        onPressed: () {
                          if(widget.image==null)
                            submitImageForUpdate(context);
                          else
                            submitImageForUpdate(context, widget.image);
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

  void showInfo() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Patient Alert!'),
            content: Text(
                'If you with to change the details send us a query from help section or contact doctor.'),
          );
        });
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
                  height: SizeConfig.blockSizeVertical !* 8,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal !* 6.2,
                          ),
                          onTap: () {
                            /*setState(() {
                          widget.type = "My type";
                        });*/
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal !* 6,
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal !* 50,
                          height: SizeConfig.blockSizeVertical !* 8,
                          child: Center(
                            child: Text(
                              "Select Blood Group",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal !* 4.8,
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
                                    width: SizeConfig.blockSizeHorizontal !* 90,
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
      size: SizeConfig.blockSizeHorizontal !* 6.2,
    );

    titleWidget = Text(
      "Select ${widget.type}",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: SizeConfig.blockSizeHorizontal !* 4.8,
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
              height: SizeConfig.blockSizeVertical !* 8,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.red,
                        size: SizeConfig.blockSizeHorizontal !* 6.2,
                      ),
                      onTap: () {
                        /*setState(() {
                          widget.type = "My type";
                        });*/
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal !* 6,
                    ),
                    Container(
                      width: SizeConfig.blockSizeHorizontal !* 50,
                      height: SizeConfig.blockSizeVertical !* 8,
                      child: Center(
                        child: titleWidget,
                      ),
                    ),
                    Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal !* 1),
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
                                          SizeConfig.blockSizeHorizontal !* 6.2,
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
                                            SizeConfig.blockSizeHorizontal !*
                                                4.0,
                                      ),
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.1),
                                        labelStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
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
                                          SizeConfig.blockSizeHorizontal !* 6.2,
                                    );
                                    this.titleWidget = Text(
                                      "Select ${widget.type}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal !*
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
                                width: SizeConfig.blockSizeHorizontal !* 90,
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
}*/

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  double min;
  double max;
  String title = "";
  double value;
  final fullWidth;
  String unit;
  Function? callbackFromBMI;
  bool isChecked;
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
    this.isChecked = false,
    this.isDecimal = false,
  });

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  double _value = 0;

  @override
  void initState() {
    _value = widget.value;
    print('_value ${_value}');
    if (widget.title == "Weight") {
      weightValue = _value;
      // widget.callbackFromBMI();
    } else if (widget.title == "Height") {
      heightValue = _value;
      // widget.callbackFromBMI();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double paddingFactor = .2;

    if (this.widget.fullWidth) paddingFactor = .3;

    return Container(
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
            Row(
              children: <Widget>[
                Expanded(
                  child: UltimateSlider(
                    minValue: widget.min.toDouble(),
                    maxValue: widget.max.toDouble(),
                    value: widget.value,
                    showDecimals: widget.isDecimal,
                    decimalInterval: 0.05,
                    titleText: widget.title,
                    unitText: widget.unit,
                    indicatorColor: getColorFromTitle(widget.title),
                    bubbleColor: getColorFromTitle(widget.title),
                    onValueChange: (value) {
                      widget.isChecked = true;
                      print('value $value');
                      widget.value = value.toDouble();
                      print('widget.value ${widget.value}');
                      if (widget.title == "Weight") {
                        weightValue = value.toDouble();
                        widget.callbackFromBMI!();
                      } else if (widget.title == "Height") {
                        heightValue = value.toDouble();
                        cmToFeet();
                        widget.callbackFromBMI!();
                      }
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical !* 5.0,
            )
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

  getColorFromTitle(String title) {
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
