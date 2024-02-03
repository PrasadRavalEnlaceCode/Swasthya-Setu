import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swasthyasetu/app_screens/add_patient_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/podo/speciality_model.dart';
import 'package:swasthyasetu/utils/color.dart';
import 'package:swasthyasetu/utils/multipart_request_with_progress.dart';
import 'package:swasthyasetu/utils/progress_dialog_with_percentage.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
List<SpecialityModel> listSpeciality = [];
SpecialityModel? selectedSpeciality;
TextEditingController specialityController = TextEditingController();

class DoctorRegistrationScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DoctorRegistrationScreenState();
  }
}

class DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  bool registeredSuccessfully = false;
  final picker = ImagePicker();
  CroppedFile? selectedFile;
  String selectedFileType = "";
  GlobalKey<ProgressDialogWithPercentageState> progressKey = GlobalKey();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();

//TextEditingController degreeCertificateController = TextEditingController();
  TextEditingController registrationNumberController = TextEditingController();

  FocusNode firstNameNode = FocusNode();
  FocusNode middleNameNode = FocusNode();
  FocusNode lastNameNode = FocusNode();
  FocusNode mobileNumberNode = FocusNode();
  FocusNode emailNode = FocusNode();

  String path = "";

  @override
  void initState() {
    listSpeciality = [];
    specialityController = TextEditingController();
    selectedFile = null;
    getSpecialityList();
    if(selectedFile!.path.length>0)
      path = selectedFile!.path;
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
      //final jsonData = json.decode(strData);
      listSpeciality = specialityModelFromJson(strData);
      setState(() {});
    }
  }

  void showSpecialitySelectionDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => SpecialityDialog(listSpeciality, () {
              setState(() {});
            }));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: colorBlueApp,
          elevation: 5,
          title: Text(
            "Register as a Doctor",
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConfig.blockSizeHorizontal !* 4.5,
              letterSpacing: 1.5,
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        body: Builder(
          builder: (context) {
            return SafeArea(
              child: Container(
                color: colorBlueApp,
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal !* 4.0,
                  vertical: SizeConfig.blockSizeVertical !* 1.5,
                ),
                child: !registeredSuccessfully
                    ? Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: firstNameController,
                                        style: TextStyle(
                                            color: black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.3),
                                        decoration: InputDecoration(
                                          hintText: 'First Name',
                                          hintStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                                  SizeConfig.blockSizeVertical !*
                                                      2.3),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                              width: 0,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                          filled: true,
                                          contentPadding: EdgeInsets.all(12),
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeVertical !* 1.0,
                                      ),
                                      TextField(
                                        controller: middleNameController,
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.3),
                                        decoration: InputDecoration(
                                          hintText: 'Middle Name',
                                          hintStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                                  SizeConfig.blockSizeVertical !*
                                                      2.3),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                              width: 0,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                          filled: true,
                                          contentPadding: EdgeInsets.all(12),
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeVertical !* 1.0,
                                      ),
                                      TextField(
                                        controller: lastNameController,
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.3),
                                        decoration: InputDecoration(
                                          hintText: 'Last Name',
                                          hintStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                                  SizeConfig.blockSizeVertical !*
                                                      2.3),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                              width: 0,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                          filled: true,
                                          contentPadding: EdgeInsets.all(12),
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeVertical !* 1.0,
                                      ),
                                      TextField(
                                        controller: mobileNoController,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.3),
                                        decoration: InputDecoration(
                                          hintText: 'Mobile Number',
                                          hintStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                                  SizeConfig.blockSizeVertical !*
                                                      2.3),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                              width: 0,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                          filled: true,
                                          contentPadding: EdgeInsets.all(12),
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeVertical !* 1.0,
                                      ),
                                      TextField(
                                        controller: emailController,
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.3),
                                        decoration: InputDecoration(
                                          hintText: 'Email',
                                          hintStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                                  SizeConfig.blockSizeVertical  !*
                                                      2.3),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                              width: 0,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                          filled: true,
                                          contentPadding: EdgeInsets.all(12),
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeVertical !* 1.0,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          showSpecialitySelectionDialog();
                                        },
                                        child: IgnorePointer(
                                          child: TextField(
                                            controller: specialityController,
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: SizeConfig
                                                        .blockSizeVertical !*
                                                    2.3),
                                            decoration: InputDecoration(
                                              hintText: 'Speciality',
                                              hintStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical !*
                                                      2.3),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                borderSide: BorderSide(
                                                  width: 0,
                                                  style: BorderStyle.none,
                                                ),
                                              ),
                                              filled: true,
                                              contentPadding:
                                                  EdgeInsets.all(12),
                                              fillColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeVertical !* 1.0,
                                      ),
                                      /*TextField(
                            controller: degreeCertificateController,
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
                              labelText: "Degree Certificate",
                              hintText: "",
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 1.0,
                          ),*/
                                      TextField(
                                        controller:
                                            registrationNumberController,
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.3),
                                        decoration: InputDecoration(
                                          hintText: 'Registration Number',
                                          hintStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                                  SizeConfig.blockSizeVertical !*
                                                      2.3),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                              width: 0,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                          filled: true,
                                          contentPadding: EdgeInsets.all(12),
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeVertical !* 2.0,
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Your Degree certificate",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                SizeConfig.blockSizeHorizontal !*
                                                    4.2,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeVertical !* 0.6,
                                      ),
                                      selectedFile == null
                                          ? Align(
                                              alignment: Alignment.centerLeft,
                                              child: MaterialButton(
                                                color: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    SizeConfig
                                                            .blockSizeHorizontal !*
                                                        3.0,
                                                  ),
                                                  side: BorderSide(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  showDocumentTypeSelectionDialog(
                                                      context);
                                                },
                                                child: Text(
                                                  "Select",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal !*
                                                        4.0,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Stack(
                                                  /*mainAxisAlignment: MainAxisAlignment.center,*/
                                                  children: <Widget>[
                                                    Container(
                                                      child: selectedFileType ==
                                                              "image"
                                                          ? Image.file(File(path))
                                                          : Image(
                                                              fit: BoxFit.fill,
                                                              image: AssetImage(
                                                                  "images/ic_doc.png"),
                                                              height: SizeConfig
                                                                      .blockSizeVertical !*
                                                                  18,
                                                            ),
                                                    ),
                                                    Positioned(
                                                      right: 0,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          showDocumentTypeSelectionDialog(
                                                              context);
                                                          //showDocumentTypeSelectionDialog(context);
                                                        },
                                                        child: Opacity(
                                                          opacity: 0.6,
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                colorBlueApp,
                                                            radius: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                5,
                                                            child: Image(
                                                              width: SizeConfig
                                                                      .blockSizeHorizontal !*
                                                                  4,
                                                              height: SizeConfig
                                                                      .blockSizeHorizontal !*
                                                                  4,
                                                              color:
                                                                  Colors.white,
                                                              //height: 80,
                                                              image: AssetImage(
                                                                  "images/ic_edit_black.png"),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: SizeConfig
                                                          .blockSizeVertical !*
                                                      1.3,
                                                ),
                                                Text(
                                                  selectedFile!.path.split("/")[
                                                      selectedFile!.path
                                                              .split("/")
                                                              .length -
                                                          1],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: SizeConfig
                                                          .blockSizeVertical !*
                                                      1.3,
                                                ),
                                              ],
                                            ),
                                      /*TextFormField(
                            decoration: decorationWithLable("First Name"),
                            */ /*onChanged: (text) {
                              _formKey.currentState.validate();
                            },*/ /*
                            focusNode: firstNameNode,
                            controller: firstNameController,
                            validator: (String value) {
                              if (value.trim().isEmpty) {
                                middleNameNode.unfocus();
                                lastNameNode.unfocus();
                                emailNode.unfocus();
                                mobileNumberNode.unfocus();
                                firstNameNode.requestFocus();
                                return 'First Name is Required';
                              }
                            },
                          ),
                          SizedBox(height: SizeConfig.blockSizeVertical*1.0,),
                          TextFormField(
                            decoration: decorationWithLable("Middle Name"),
                            */ /*onChanged: (text) {
                              _formKey.currentState.validate();
                            },*/ /*
                            focusNode: middleNameNode,
                            controller: middleNameController,
                            validator: (String value) {
                              if (value.trim().isEmpty) {
                                middleNameNode.requestFocus();
                                return 'Middle Name is Required';
                              }
                            },
                          ),
                          SizedBox(height: SizeConfig.blockSizeVertical*1.0,),
                          TextFormField(
                            decoration: decorationWithLable("Last Name"),
                            */ /*onChanged: (text) {
                              _formKey.currentState.validate();
                            },*/ /*
                            focusNode: lastNameNode,
                            controller: lastNameController,
                            validator: (String value) {
                              if (value.trim().isEmpty) {
                                lastNameNode.requestFocus();
                                return 'Last Name is Required';
                              }
                            },
                          ),
                          SizedBox(height: SizeConfig.blockSizeVertical*1.0,),
                          TextFormField(
                            decoration: decorationWithLable("Mobile Number"),
                            */ /*onChanged: (text) {
                              _formKey.currentState.validate();
                            },*/ /*
                            focusNode: mobileNumberNode,
                            controller: mobileNoController,
                            validator: (String value) {
                              if (value.trim().isEmpty) {
                                mobileNumberNode.requestFocus();
                                return 'Mobile Number is Required';
                              }
                            },
                          ),
                          SizedBox(height: SizeConfig.blockSizeVertical*1.0,),
                          TextFormField(
                            decoration: decorationWithLable("Email"),
                            */ /*onChanged: (text) {
                              _formKey.currentState.validate();
                            },*/ /*
                            focusNode: emailNode,
                            controller: emailController,
                            validator: (String value) {
                              if (value.trim().isEmpty) {
                                emailNode.requestFocus();
                                return 'Email is Required';
                              }
                            },
                          ),
                          SizedBox(height: SizeConfig.blockSizeVertical*1.0,),
                          TextFormField(
                            decoration: decorationWithLable("Speciality"),
                            controller: specialityController,
                          ),
                          SizedBox(height: SizeConfig.blockSizeVertical*1.0,),
                          TextFormField(
                            decoration: decorationWithLable("Degree Certificate"),
                            controller: degreeCertificateController,
                          ),
                          SizedBox(height: SizeConfig.blockSizeVertical*1.0,),
                          TextFormField(
                            decoration: decorationWithLable("Registration Number"),
                            controller: registrationNumberController,
                          ),*/
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          /*Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: SizeConfig.blockSizeHorizontal * 3,
                                  bottom: SizeConfig.blockSizeHorizontal * 3),
                              child: Container(
                                width: SizeConfig.blockSizeHorizontal * 12,
                                height: SizeConfig.blockSizeHorizontal * 12,
                                child: RawMaterialButton(
                                  onPressed: () {
                                    submitDocRegistrationDetails(context);
                                  },
                                  elevation: 2.0,
                                  fillColor: Color(0xFFFFFFF),
                                  child: Image(
                                    width: SizeConfig.blockSizeHorizontal * 5.5,
                                    height:
                                        SizeConfig.blockSizeHorizontal * 5.5,
                                    //height: 80,
                                    image: AssetImage(
                                        "images/ic_right_arrow_triangular.png"),
                                  ),
                                  shape: CircleBorder(),
                                ),
                              ),
                            ),
                          ),*/
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: SizedBox(
                              width: SizeConfig.screenWidth,
                              child: TextButton(
                                  child: Text("Register".toUpperCase(),
                                      style: TextStyle(fontSize: 16)),
                                  style: ButtonStyle(
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                              EdgeInsets.all(15)),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              colorWhite),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              colorBlueDark),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0)))),
                                  onPressed: () => submitDocRegistrationDetails(context)),
                            ),
                          )
                        ],
                      )
                    : Center(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: SizeConfig.blockSizeVertical !* 3.0,
                              ),
                              Image(
                                image: AssetImage("images/ic_check_circle.png"),
                                width: SizeConfig.blockSizeHorizontal !* 20.0,
                                height: SizeConfig.blockSizeHorizontal !* 20.0,
                                color: Colors.green,
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical !* 3.0,
                              ),
                              Text(
                                "Registered Successfully!",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal !* 7.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical !* 1.5,
                              ),
                              Text(
                                "Your request is received. We will update you soon with your login details.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal !* 4.3,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical !* 3.0,
                              ),
                              /*MaterialButton(
                          onPressed: () {
                            logOut(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreenDoctor()),
                                  (Route<dynamic> route) => false,
                            );
                          },
                          color: Colors.green,
                          child: Text(
                            "Go to Login Screen",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeConfig.blockSizeHorizontal * 4.3,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1.0,
                            ),
                          ),
                        )*/
                            ],
                          ),
                        ),
                      ),
              ),
            );
          },
        ));
  }

  showDocumentTypeSelectionDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: dialogContent(context, "Select Document Type"),
            ));
  }

  dialogContent(BuildContext context, String title) {
    SizeConfig().init(context);

    Future getImageFromCamera() async {
      /*ViewProfileDetailsState.image =
        await ImagePicker.pickImage(source: ImageSource.camera);*/
      File imgSelected =
          await chooseImageWithExIfRotate(picker, ImageSource.camera);
      selectedFile = await ImageCropper().cropImage(
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
          ],);
      //selectedFile = imgSelected;
      selectedFileType = "image";
      Navigator.of(context).pop();
      hideKeyBoard(context);
      setState(() {});
      //if (image != null) submitImageForUpdate(context, image);
      //_controller.add(image);
    }

    Future removeImage() async {
      /*ViewProfileDetailsState.image =
        await ImagePicker.pickImage(source: ImageSource.camera);*/
      selectedFile = null;
      Navigator.of(context).pop();
      hideKeyBoard(context);
      setState(() {});
      //if (image != null) submitImageForUpdate(context, image);
      //_controller.add(image);
    }

    Future getImageFromGallery() async {
      /*ViewProfileDetailsState.image =
        await ImagePicker.pickImage(source: ImageSource.gallery);*/
      File imgSelected =
          await chooseImageWithExIfRotate(picker, ImageSource.gallery);
      selectedFile = await ImageCropper().cropImage(
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
          ],);
      //selectedFile = imgSelected;
      selectedFileType = "image";
      Navigator.of(context).pop();
      hideKeyBoard(context);
      setState(() {});
      //if (image != null) submitImageForUpdate(context, image);
      //_controller.add(image);
    }

    return Stack(
      children: <Widget>[
        //...bottom card part,
        Container(
          width: SizeConfig.blockSizeHorizontal !* 90,
          height: SizeConfig.blockSizeVertical !* 45,
          padding: EdgeInsets.only(
            top: SizeConfig.blockSizeHorizontal !* 1,
            bottom: SizeConfig.blockSizeHorizontal !* 1,
            left: SizeConfig.blockSizeHorizontal !* 1,
            right: SizeConfig.blockSizeHorizontal !* 1,
          ),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal !* 3.0,
                  ),
                  InkWell(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.red[800],
                      size: SizeConfig.blockSizeVertical !* 3.2,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      hideKeyBoard(context);
                    },
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal !* 5.0,
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal !* 4.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 1.5,
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
              Container(
                margin: EdgeInsets.only(
                  left: SizeConfig.blockSizeHorizontal !* 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.rectangle,
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    getImageFromCamera();
                  },
                  child: Row(
                    children: [
                      Image(
                        fit: BoxFit.contain,
                        width: SizeConfig.blockSizeHorizontal !* 8,
                        height: SizeConfig.blockSizeVertical !* 8,
                        //height: 80,
                        image: AssetImage("images/ic_camera.png"),
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal !* 3.0,
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: SizeConfig.blockSizeHorizontal !* 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.rectangle,
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    getImageFromGallery();
                  },
                  child: Row(
                    children: [
                      Image(
                        fit: BoxFit.contain,
                        width: SizeConfig.blockSizeHorizontal !* 8,
                        height: SizeConfig.blockSizeVertical !* 8,
                        //height: 80,
                        image: AssetImage("images/ic_gallery.png"),
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal !* 3.0,
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: SizeConfig.blockSizeHorizontal !* 10,
                ),
                padding: EdgeInsets.only(
                  top: SizeConfig.blockSizeVertical !* 1.3,
                  bottom: SizeConfig.blockSizeVertical !* 1.3,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.rectangle,
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    openDocumentPicker();
                  },
                  child: Row(
                    children: [
                      Image(
                        fit: BoxFit.contain,
                        width: SizeConfig.blockSizeHorizontal !* 8,
                        height: SizeConfig.blockSizeVertical !* 5,
                        //height: 80,
                        image: AssetImage("images/ic_doc.png"),
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal !* 3.0,
                      ),
                      Text(
                        "Document Files",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 1.5,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: SizeConfig.blockSizeHorizontal !* 10,
                ),
                child: InkWell(
                  onTap: () {
                    removeImage();
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.close,
                        color: Colors.red,
                        size: SizeConfig.blockSizeHorizontal !* 8,
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal !* 3.0,
                      ),
                      Text(
                        "No Document",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 1.0,
              ),
              /*Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      getImageFromCamera();
                    },
                    child: Image(
                      fit: BoxFit.contain,
                      width: SizeConfig.blockSizeHorizontal * 10,
                      height: SizeConfig.blockSizeVertical * 10,
                      //height: 80,
                      image: AssetImage("images/ic_camera.png"),
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal * 1,
                  ),
                  MaterialButton(
                    onPressed: () {
                      getImageFromGallery();
                    },
                    child: Image(
                      fit: BoxFit.contain,
                      width: SizeConfig.blockSizeHorizontal * 10,
                      height: SizeConfig.blockSizeVertical * 10,
                      //height: 80,
                      image: AssetImage("images/ic_gallery.png"),
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal * 1,
                  ),
                  MaterialButton(
                    onPressed: () {
                      removeImage();
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: SizeConfig.blockSizeHorizontal * 10,
                    ),
                  ),
                ],
              ),*/
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

    /*return Stack(
      children: <Widget>[
        //...bottom card part,
        Container(
          width: SizeConfig.blockSizeHorizontal * 90,
          padding: EdgeInsets.only(
            top: Consts.padding / 2,
            bottom: Consts.padding / 2,
            left: Consts.padding / 2,
            right: Consts.padding / 2,
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
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              */ /*MaterialButton(
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
            ),*/ /*
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      getImageFromCamera();
                    },
                    child: Image(
                      width: 35,
                      height: 35,
                      //height: 80,
                      image: AssetImage("images/ic_camera.png"),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  MaterialButton(
                    onPressed: () {
                      getImageFromGallery();
                    },
                    child: Image(
                      width: 35,
                      height: 35,
                      //height: 80,
                      image: AssetImage("images/ic_gallery.png"),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  MaterialButton(
                    onPressed: () {
                      removeImage();
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 35,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        //...top circlular image part,
        */ /*Positioned(
        left: Consts.padding,
        right: Consts.padding,
        child: CircleAvatar(
          backgroundColor: Colors.deepOrangeAccent,
          radius: Consts.avatarRadius,
          child: image,
        ),
      ),*/ /*
      ],
    );*/
  }

  void openDocumentPicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );
    if (result != null) {
      CroppedFile fileSelected = CroppedFile(result.files.single.path!);
 selectedFile = fileSelected;
      selectedFileType = "doc";
      Navigator.of(context).pop();
      hideKeyBoard(context);
      setState(() {});
    } else {}
  }

  void submitDocRegistrationDetails(BuildContext context) async {
    String mobNoToValidate = mobileNoController.text;
    if (mobileNoController.text.length >= 12) {
      if (mobileNoController.text.startsWith("+91")) {
        mobNoToValidate = mobileNoController.text.replaceFirst("+91", "");
      } else if (mobileNoController.text.startsWith("91")) {
        mobNoToValidate = mobileNoController.text.replaceFirst("91", "");
      }
    }
    if (firstNameController.text.trim().isEmpty) {
      showSnackBar("First Name is Compulsory");
      return;
    }
    if (middleNameController.text.trim().isEmpty) {
      showSnackBar("Middle Name is Compulsory");
      return;
    }
    if (lastNameController.text.trim().isEmpty) {
      showSnackBar("Last Name is Compulsory");
      return;
    }
    if (mobNoToValidate.trim().isEmpty) {
      showSnackBar("Mobile Number is Compulsory");
      return;
    }
    if (mobNoToValidate.length != 10) {
      showSnackBar("Mobile Number should be 10 digit");
      return;
    }
    if (emailController.text.trim().isEmpty) {
      showSnackBar("Email is Compulsory");
      return;
    }
    if (selectedSpeciality == null) {
      showSnackBar("Speciality is Compulsory");
      return;
    }

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
      Uri.parse("${baseURL}doctorRegister.php"),
      onProgress: (int bytes, int total) {
        final progress = bytes / total;
        progressKey.currentState!.setProgress(progress);
      },
    );

    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "firstname" +
        "\"" +
        ":" +
        "\"" +
        firstNameController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "middlename" +
        "\"" +
        ":" +
        "\"" +
        middleNameController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "lastname" +
        "\"" +
        ":" +
        "\"" +
        lastNameController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "mobile" +
        "\"" +
        ":" +
        "\"" +
        mobNoToValidate.trim() +
        "\"" +
        "," +
        "\"" +
        "email" +
        "\"" +
        ":" +
        "\"" +
        emailController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "specility" +
        "\"" +
        ":" +
        "\"" +
        selectedSpeciality!.specialityIdp.toString() +
        "\"" +
        "," +
        "\"" +
        "registrationno" +
        "\"" +
        ":" +
        "\"" +
        registrationNumberController.text.trim() +
        "\"" +
        "}";

    debugPrint("Jsonstr - $jsonStr");

    String encodedJSONStr = encodeBase64(jsonStr);
    multipartRequest.fields['getjson'] = encodedJSONStr;
    Map<String, String> headers = Map();
    headers['u'] = patientUniqueKey;
    headers['type'] = userType;
    multipartRequest.headers.addAll(headers);
    if (selectedFile != null) {
      var imgLength = await selectedFile!.path.length;
      multipartRequest.files.add(new http.MultipartFile(
          'DoctorDegreeCertificate', selectedFile!.openRead(), imgLength,
          filename: selectedFile!.path));
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
        setState(() {
          registeredSuccessfully = true;
        });
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });

    /*String loginUrl = "${baseURL}doctorRegister.php";

    ProgressDialog pr = ProgressDialog(context);
    pr.show();
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String mobNo = await getMobNo();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "firstname" +
        "\"" +
        ":" +
        "\"" +
        firstNameController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "middlename" +
        "\"" +
        ":" +
        "\"" +
        middleNameController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "lastname" +
        "\"" +
        ":" +
        "\"" +
        lastNameController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "mobile" +
        "\"" +
        ":" +
        "\"" +
        mobNoToValidate.trim() +
        "\"" +
        "," +
        "\"" +
        "email" +
        "\"" +
        ":" +
        "\"" +
        emailController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "specility" +
        "\"" +
        ":" +
        "\"" +
        selectedSpeciality.specialityIdp.toString() +
        "\"" +
        "," +
        "\"" +
        "registrationno" +
        "\"" +
        ":" +
        "\"" +
        registrationNumberController.text.trim() +
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
    pr.hide();
    if (model.status == "OK") {
      setState(() {
        registeredSuccessfully = true;
      });
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }*/
  }

  InputDecoration decorationWithLable(String title) {
    return InputDecoration(
      /*focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.0),
      ),*/
      labelText: title,
    );
  }

  void showSnackBar(String text) {
    /*Get.snackbar("", text,titleText: null,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        messageText: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        icon: Icon(
          Icons.warning,
          color: Colors.white,
        ));*/
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(text),
      ),
    );
  }

  void hideKeyBoard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    currentFocus.unfocus();
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
      size: SizeConfig.blockSizeHorizontal !* 6.2,
    );

    titleWidget = Text(
      "Select Speciality",
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

  void hideKeyBoard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    currentFocus.unfocus();
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
                        Navigator.of(context).pop();
                        hideKeyBoard(context);
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
                                        hintText: "Search Speciality",
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
                                      "Select Speciality",
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
                              "Selected speciality : ${selectedSpeciality!.specialityIdp} ${selectedSpeciality!.specialityName}");
                          Navigator.of(context).pop();
                          hideKeyBoard(context);
                          widget.callbackFromSpecialityDialog();
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
                                    widget.listSpeciality[index].specialityName!,
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
