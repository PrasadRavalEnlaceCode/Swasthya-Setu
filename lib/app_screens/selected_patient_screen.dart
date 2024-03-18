import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:silvertouch/app_screens/add_consultation_screen.dart';
import 'package:silvertouch/app_screens/add_new_lab_screen.dart';
import 'package:silvertouch/app_screens/fullscreen_image.dart';
import 'package:silvertouch/app_screens/opd_registration_screen.dart';
import 'package:silvertouch/app_screens/view_profile_details_patient_inside_doctor.dart';
import 'package:silvertouch/app_screens/vital_investigation_patient_wise_screen_from_notification.dart';
import 'package:silvertouch/controllers/pdf_type_controller.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_opd_reg.dart';
import 'package:silvertouch/podo/model_profile_patient.dart';
import 'package:silvertouch/podo/pdf_type.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/progress_dialog.dart';

import '../utils/common_methods.dart';

Widget? emptyMessageWidget;
String emptyMessage = "No Previous Visits found.";

List<ModelOPDRegistration> listOPDRegistration = [];
ProgressDialog? pr;

class SelectedPatientScreen extends StatefulWidget {
  final String patientIDP,
      /*fullName,
      gender,
      age,
      cityName,
      imgUrl,
      patientID,*/
      heroTag,
      healthRecordsDisplayStatus,
      notificationDisplayStatus;

  SelectedPatientScreen(
      this.patientIDP,
      this.healthRecordsDisplayStatus,
      /* this.fullName, this.gender, this.age,
      this.cityName, this.imgUrl, this.patientID,*/
      this.heroTag,
      {this.notificationDisplayStatus = ""});

  @override
  State<StatefulWidget> createState() {
    return SelectedPatientScreenState();
  }
}

class SelectedPatientScreenState extends State<SelectedPatientScreen> {
  String fullName = "",
      gender = "",
      age = "",
      cityName = "",
      imgUrl = "",
      patientID = "";

  String doctorIDP = "";

  bool notify = false;
  PdfTypeController pdfTypeController = Get.put(PdfTypeController());
  List<PdfType> listPdfType = [
    PdfType(
      "Prescription",
      "prescription",
      FontAwesomeIcons.prescription,
    ),
    PdfType(
      "Receipt",
      "receipt",
      FontAwesomeIcons.rupeeSign,
    ),
    PdfType(
      "Invoice",
      "invoice",
      FontAwesomeIcons.fileInvoice,
    ),
  ];
  var taskId;

  @override
  void initState() {
    super.initState();
    // _bindBackgroundIsolate();
    // FlutterDownloader.registerCallback(downloadCallback);
    if (widget.notificationDisplayStatus == "1")
      notify = true;
    else
      notify = false;
    emptyMessageWidget = Center(
      child: SizedBox(
        height: SizeConfig.blockSizeVertical! * 80,
        width: SizeConfig.blockSizeHorizontal! * 100,
        child: Container(
          padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage("images/ic_idea_new.png"),
                width: 100,
                height: 100,
              ),
              SizedBox(
                height: 30.0,
              ),
              Text(
                "${emptyMessage}",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );

    // getPatientOrDoctorIDP().then((value) {
    //   doctorIDP = value;
    //   setState(() {});
    // });
    getPatientProfileDetails();
    getOPDProcedures();
  }

  @override
  void dispose() {
    // _unbindBackgroundIsolate();
    super.dispose();
  }

  void getPatientProfileDetails() async {
    /*ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr.show();
    });*/
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
        widget.patientIDP +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);

    debugPrint(encodedJSONStr);

    var response = await apiHelper.callApiWithHeadersAndBody(
      url: "${baseURL}patientProfileData.php",
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

      debugPrint("Decoded Data Array : " + strData);
      debugPrint("Decoded Data Array : " + strData);

      final jsonData = json.decode(strData);

      imgUrl = jsonData[0]['Image'];
      String firstName = jsonData[0]['FirstName'];
      String lastName = jsonData[0]['LastName'];
      String middleName = jsonData[0]['MiddleName'];
      gender = jsonData[0]['Gender'];
      age = jsonData[0]['Age'];
      patientID = jsonData[0]['PatientID'];
      cityName = jsonData[0]['CityName'];
      fullName =
          firstName.trim() + " " + middleName.trim() + " " + lastName.trim();
      //setEmergencyNumber(jsonData[0]['EmergencyNumber']);
      debugPrint("Img url - $imgUrl");
      setState(() {});
    } else {
      /*final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message),
      );
      ScaffoldMessenger.of(navigationService.navigatorKey.currentState)
          .showSnackBar(snackBar);*/
    }
  }

  // void getPatientData(BuildContext context) async {
  //   String loginUrl = "${baseURL}patientProfileData.php";
  //   ProgressDialog? pr;
  //   Future.delayed(Duration.zero, () {
  //     pr = ProgressDialog(context);
  //     pr!.show();
  //   });
  //   //listIcon = new List();
  //   String patientUniqueKey = await getPatientUniqueKey();
  //   String userType = await getUserType();
  //   debugPrint("Key and type");
  //   debugPrint(patientUniqueKey);
  //   debugPrint("-----2222222222222222222222222222222222");
  //   String jsonStr =
  //       "{" + "\"" + "PatientIDP" + "\"" + ":" + "\"" + widget.patientIDP + "\"" + "}";
  //
  //   debugPrint(jsonStr);
  //   debugPrint("---------------------------------------------");
  //
  //   String encodedJSONStr = encodeBase64(jsonStr);
  //
  //   var response = await apiHelper.callApiWithHeadersAndBody(
  //     url: loginUrl,
  //     //Uri.parse(loginUrl),
  //     headers: {
  //       "u": patientUniqueKey,
  //       "type": userType,
  //     },
  //     body: {"getjson": encodedJSONStr},
  //   );
  //   debugPrint(response.body.toString());
  //   final jsonResponse = json.decode(response.body.toString());
  //   ResponseModel model = ResponseModel.fromJSON(jsonResponse);
  //   pr!.hide();
  //
  //   if(model.status == "OK"){
  //
  //     var data = jsonResponse['Data'];
  //
  //     var strData = decodeBase64(data);
  //
  //     debugPrint("Decoded Data Array : " + strData);
  //     final jsonData = json.decode(strData);
  //
  //     imgUrl = jsonData[0]['Image'];
  //     String firstName = jsonData[0]['FirstName'];
  //     String lastName = jsonData[0]['LastName'];
  //     String middleName = jsonData[0]['MiddleName'];
  //     gender = jsonData[0]['Gender'];
  //     age = jsonData[0]['Age'];
  //     patientID = jsonData[0]['PatientID'];
  //     cityName = jsonData[0]['CityName'];
  //     fullName =
  //         firstName.trim() + " " + middleName.trim() + " " + lastName.trim();
  //     //setEmergencyNumber(jsonData[0]['EmergencyNumber']);
  //     debugPrint("Img url - $imgUrl");
  //     setState(() {});
  //   } else {
  //     /*final snackBar = SnackBar(
  //       backgroundColor: Colors.red,
  //       content: Text(model.message),
  //     );
  //     ScaffoldMessenger.of(navigationService.navigatorKey.currentState)
  //         .showSnackBar(snackBar);*/
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      /*appBar: AppBar(
        title: Text("My Profile"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
            color: Color(0xFF06A759), size: SizeConfig.blockSizeVertical * 2.5),
        textTheme: TextTheme(
            subtitle1: TextStyle(
                color: Colors.white,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical * 2.5)),
      ),*/
      body: Builder(builder: (context) {
        return SafeArea(
          child: Container(
            width: SizeConfig.blockSizeHorizontal! * 100,
            height: SizeConfig.blockSizeVertical! * 100,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: SizeConfig.blockSizeHorizontal! * 1,
                                right: SizeConfig.blockSizeHorizontal! * 1),
                            child: InkWell(
                              focusColor: Colors.white,
                              highlightColor: Colors.white,
                              hoverColor: Colors.white,
                              splashColor: Colors.white,
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Icon(Icons.arrow_back),
                            ),
                          )),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ViewProfileDetailsInsideDoctor(
                                  widget.patientIDP);
                            }));
                            //ViewProfileDetailsInsideDoctor
                          },
                          child: Hero(
                            tag: widget.heroTag,
                            child: Card(
                              elevation: 0,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      /*VerticalDivider(
                                width: SizeConfig.blockSizeHorizontal * 2,
                                thickness: SizeConfig.blockSizeHorizontal * 2,
                                color: Colors.green,
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal * 3,
                              ),*/
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return FullScreenImage(
                                                "$userImgUrl$imgUrl");
                                          }));
                                        },
                                        child: (imgUrl != "")
                                            ? CircleAvatar(
                                                radius: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    6,
                                                backgroundColor: Colors.grey,
                                                backgroundImage: NetworkImage(
                                                    "$userImgUrl${imgUrl}"))
                                            : CircleAvatar(
                                                radius: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    6,
                                                backgroundColor: Colors.grey,
                                                backgroundImage: AssetImage(
                                                    "images/ic_user_placeholder.png")),
                                      ),
                                      SizedBox(
                                        width:
                                            SizeConfig.blockSizeHorizontal! * 5,
                                      ),
                                      Expanded(
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    1.5),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  fullName,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: SizeConfig
                                                              .blockSizeHorizontal! *
                                                          4),
                                                ),
                                                SizedBox(
                                                  height: SizeConfig
                                                          .blockSizeVertical! *
                                                      1,
                                                ),
                                                Row(children: <Widget>[
                                                  Text(
                                                    "ID - ${patientID}",
                                                    style: TextStyle(
                                                      fontSize: SizeConfig
                                                              .blockSizeHorizontal! *
                                                          3.5,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        5,
                                                  ),
                                                  Text(
                                                    "$gender/$age",
                                                    style: TextStyle(
                                                      fontSize: SizeConfig
                                                              .blockSizeHorizontal! *
                                                          3.5,
                                                      color: Colors.blue[900],
                                                    ),
                                                  ),
                                                  /*VerticalDivider(
                                  color: Colors.grey,
                                ),*/
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        5,
                                                  ),
                                                  Text(
                                                    cityName,
                                                    style: TextStyle(
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            3.5,
                                                        color: Colors
                                                            .limeAccent[500]),
                                                  ),
                                                ]),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                  Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: SizeConfig
                                                    .blockSizeHorizontal! *
                                                3),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return ViewProfileDetailsInsideDoctor(
                                                  widget.patientIDP);
                                            }));
                                            //ViewProfileDetailsInsideDoctor
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "View Profile",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              SizedBox(
                                                width: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    1,
                                              ),
                                              Image(
                                                image: AssetImage(
                                                    "images/ic_right_arrow_double.png"),
                                                width: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    2.0,
                                                color: Colors.blue,
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical! * 1,
                ),
                widget.healthRecordsDisplayStatus == "1"
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return ShowVitalsInvestigationPatientWiseFromNotifications(
                                        widget.patientIDP, "1", "1");
                                  }));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    /*Image(
                              width: SizeConfig.blockSizeHorizontal * 5,
                              image: AssetImage('images/ic_vitals_filled.png'),
                            ),*/
                                    FaIcon(
                                      FontAwesomeIcons.chartLine,
                                      size: SizeConfig.blockSizeHorizontal! * 5,
                                      color: Colors.green,
                                    ),
                                    SizedBox(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 2,
                                    ),
                                    Text(
                                      "Vitals",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! *
                                                3.4,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          /*Container(height: SizeConfig.blockSizeVertical*3, width: 2,color: Colors.grey,),*/
                          Expanded(
                            flex: 1,
                            child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return ShowVitalsInvestigationPatientWiseFromNotifications(
                                        widget.patientIDP, "2", "");
                                  }));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    FaIcon(
                                      FontAwesomeIcons.briefcase,
                                      size: SizeConfig.blockSizeHorizontal! * 5,
                                      color: Colors.green,
                                    ),
                                    SizedBox(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 2,
                                    ),
                                    Text(
                                      "Investigations",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! *
                                                3.4,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          /*Container(height: SizeConfig.blockSizeVertical*3, width: 2,color: Colors.grey,),*/
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return ShowVitalsInvestigationPatientWiseFromNotifications(
                                          widget.patientIDP, "3", "3");
                                    }));
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      /*Image(
                                width: SizeConfig.blockSizeHorizontal * 4.5,
                                image: AssetImage('images/ic_report_filled.png'),
                              ),*/
                                      FaIcon(
                                        FontAwesomeIcons.fileAlt,
                                        size:
                                            SizeConfig.blockSizeHorizontal! * 5,
                                        color: Colors.green,
                                      ),
                                      SizedBox(
                                        width:
                                            SizeConfig.blockSizeHorizontal! * 2,
                                      ),
                                      Text(
                                        "Documents",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal! *
                                                  3.4,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                        ],
                      )
                    : Container(),
                widget.healthRecordsDisplayStatus == "1"
                    ? SizedBox(
                        height: SizeConfig.blockSizeVertical! * 1,
                      )
                    : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Notify me upon entry of health records",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                        letterSpacing: 1.3,
                      ),
                    ),
                    Switch(
                      activeColor: Colors.green,
                      value: notify,
                      onChanged: (isOn) {
                        setState(() {
                          notify = isOn;
                          submitNotifyUpdate(context, widget.patientIDP, isOn);
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    /*Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.blockSizeHorizontal * 3,
                          right: SizeConfig.blockSizeHorizontal * 3,
                          top: SizeConfig.blockSizeHorizontal * 3,
                          bottom: SizeConfig.blockSizeHorizontal * 3),
                      child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image(
                                image: AssetImage("images/ic_records.png"),
                                width: SizeConfig.blockSizeHorizontal * 4,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal * 4,
                              ),
                              Text(
                                "Records",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 3.5),
                              ),
                            ],
                          ),
                          minWidth: double.maxFinite,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal * 3),
                          color: Color(0xFF06A759),
                          onPressed: () async {
                            print("");
                            Navigator.of(context).push(PageRouteBuilder(
                                transitionDuration: Duration(milliseconds: 500),
                                pageBuilder: (context, _, __) {
                                  return ShowVitalsInvestigationPatientWise(
                                    widget.patientIDP,
                                    widget.fullName,
                                    widget.gender,
                                    widget.age,
                                    widget.cityName,
                                    widget.imgUrl,
                                    widget.patientID,
                                    widget.heroTag,
                                  );
                                }));
                          }),
                    ),
                  ),*/
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(
                          SizeConfig.blockSizeHorizontal! * 3,
                        ),
                        child: MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.grey, width: 0.1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image(
                                  image: AssetImage("images/ic_add_opd.png"),
                                  width: SizeConfig.blockSizeHorizontal! * 4,
                                  color: Colors.green,
                                ),
                                SizedBox(
                                  width: SizeConfig.blockSizeHorizontal! * 4,
                                ),
                                Text(
                                  "Add Appointment",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal! *
                                              3.5),
                                ),
                              ],
                            ),
                            minWidth: double.maxFinite,
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 3),
                            color: Colors.white,
                            onPressed: () async {
                              submitAllTheData(context, widget.patientIDP);
                              /*Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return
                                AddOPDProcedures(
                                  [],
                                  widget.patientIDP,
                                  "",
                                  "selectedPatient",
                                  */ /*widget.notificationIDP,*/ /*
                                );
                                SelectOPDProceduresScreen(
                                  widget.patientIDP, "", "selectedPatient");
                            })).then((value) {
                              getOPDProcedures();
                            });*/
                            }),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: Container(
                      color: Colors.grey[300],
                      child: Column(
                        children: [
                          SizedBox(
                            height: SizeConfig.blockSizeVertical! * 2,
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: SizeConfig.blockSizeHorizontal! * 3),
                                child: Text(
                                  "Previous Visits",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 4.5,
                                  ),
                                ),
                              )),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical! * 1,
                          ),
                          Expanded(
                            child: listOPDRegistration.length > 0
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount: listOPDRegistration.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                          padding: EdgeInsets.only(
                                              left: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  2,
                                              right: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  2,
                                              bottom: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  3),
                                          child: InkWell(
                                            onTap: () {
                                              getUserType().then((value) {
                                                if (value != 'frontoffice') if (doctorIDP ==
                                                    listOPDRegistration[index]
                                                        .patientIDP) {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return AddConsultationScreen(
                                                      listOPDRegistration[index]
                                                          .idp!,
                                                      widget.patientIDP,
                                                      listOPDRegistration[
                                                          index],
                                                      from: "selectedPatient",
                                                      appointmentDate:
                                                          listOPDRegistration[
                                                                  index]
                                                              .vidCallDate,
                                                    );
                                                  })).then((value) {
                                                    getOPDProcedures();
                                                  });
                                                }
                                              });
                                            },
                                            child: Card(
                                                color: doctorIDP ==
                                                        listOPDRegistration[
                                                                index]
                                                            .patientIDP
                                                    ? Colors.white
                                                    : Colors.blueGrey[200],
                                                child: Padding(
                                                  padding: EdgeInsets.all(SizeConfig
                                                          .blockSizeHorizontal! *
                                                      3),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          Image(
                                                            image: AssetImage(
                                                                "images/ic_calendar.png"),
                                                            color:
                                                                /*widget.patientIDP ==
                                                                        doctorIDP
                                                                    ? */
                                                                Colors.blueGrey
                                                            /*: Colors
                                                                        .white*/
                                                            ,
                                                            width: 20.0,
                                                            height: 20.0,
                                                          ),
                                                          SizedBox(
                                                            width: SizeConfig
                                                                    .blockSizeHorizontal! *
                                                                3,
                                                          ),
                                                          /*Expanded(
                                                            flex: 2,
                                                            child:*/
                                                          Text(
                                                            listOPDRegistration[
                                                                    index]
                                                                .vidCallDate!,
                                                            style: TextStyle(
                                                                color:
                                                                    /*widget
                                                                              .patientIDP ==
                                                                          doctorIDP
                                                                      ?*/
                                                                    Colors.black
                                                                /*: Colors
                                                                          .white*/
                                                                ,
                                                                fontSize: SizeConfig
                                                                        .blockSizeHorizontal! *
                                                                    4,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          /*),*/
                                                          SizedBox(
                                                            width: SizeConfig
                                                                    .blockSizeHorizontal! *
                                                                6.0,
                                                          ),
                                                          doctorIDP ==
                                                                  listOPDRegistration[
                                                                          index]
                                                                      .patientIDP
                                                              ? Text(
                                                                  "${listOPDRegistration[index].amount}/-",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .green,
                                                                    fontSize:
                                                                        SizeConfig.blockSizeHorizontal! *
                                                                            3.5,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                )
                                                              : Container(),
                                                          Spacer(),
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  pdfButtonClick(
                                                                      context,
                                                                      listOPDRegistration[
                                                                          index],
                                                                      "full");
                                                                },
                                                                customBorder:
                                                                    CircleBorder(),
                                                                child:
                                                                    Container(
                                                                  padding: EdgeInsets.all(
                                                                      SizeConfig
                                                                              .blockSizeHorizontal! *
                                                                          2.0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                            .blue[
                                                                        800],
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child: FaIcon(
                                                                    FontAwesomeIcons
                                                                        .print,
                                                                    size: SizeConfig
                                                                            .blockSizeHorizontal! *
                                                                        5,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                              doctorIDP ==
                                                                      listOPDRegistration[
                                                                              index]
                                                                          .patientIDP
                                                                  ? SizedBox(
                                                                      width: SizeConfig
                                                                              .blockSizeHorizontal! *
                                                                          2.0,
                                                                    )
                                                                  : Container(),
                                                              doctorIDP ==
                                                                      listOPDRegistration[
                                                                              index]
                                                                          .patientIDP
                                                                  ? InkWell(
                                                                      onTap:
                                                                          () {
                                                                        showPdfTypeSelectionDialog(
                                                                          listPdfType,
                                                                          listOPDRegistration[
                                                                              index],
                                                                          context,
                                                                        );
                                                                      },
                                                                      customBorder:
                                                                          CircleBorder(),
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! *
                                                                                2.0),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.blue,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        child:
                                                                            Image(
                                                                          width:
                                                                              SizeConfig.blockSizeHorizontal! * 5,
                                                                          color:
                                                                              Colors.white,
                                                                          //height: 80,
                                                                          image:
                                                                              AssetImage("images/ic_download.png"),
                                                                        ),
                                                                      ))
                                                                  : Container(),
                                                            ],
                                                          )
                                                          /*InkWell(
                                            child: Image(
                                              image: AssetImage(
                                                  "images/ic_pdf_opd_reg.png"),
                                              width: SizeConfig
                                                      .blockSizeHorizontal *
                                                  8,
                                            ),
                                          )*/
                                                        ],
                                                      ),
                                                      doctorIDP !=
                                                              listOPDRegistration[
                                                                      index]
                                                                  .patientIDP
                                                          ? Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                "Consultation of - Dr. " +
                                                                    listOPDRegistration[
                                                                            index]
                                                                        .doctorName!,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeHorizontal! *
                                                                          3.3,
                                                                ),
                                                              ),
                                                            )
                                                          : Container(),
                                                    ],
                                                  ),
                                                )),
                                          ));
                                    })
                                : emptyMessageWidget!,
                          )
                        ],
                      )),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  void submitAllTheData(BuildContext context, String patientIDPValue) async {
    String loginUrl = "${baseURL}appoinmentAddProfile.php";

    ProgressDialog prDialog;
    prDialog = ProgressDialog(context);
    prDialog.show();
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
    prDialog.hide();
    if (model.status == "OK") {
      /*var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      listInvestigationMaster = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listInvestigationMaster.add(ModelInvestigationMaster(
          jo['PreInvestTypeIDP'].toString(),
          jo['GroupType'],
          jo['GroupName'],
          jo['InvestigationType'],
          jo['RangeValue'],
          false,
        ));
      }*/
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(
          Duration(
            seconds: 1,
          ), () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return OPDRegistrationScreen();
        })).then((value) {
          /*Navigator.of(context).pop();*/
          /*getNotificationList(context);*/
        });
      });
      /*Future.delayed(
          Duration(
            seconds: 1,
          ), () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return OPDRegistrationScreen();
        })).then((value) {
          Navigator.of(context).pop();
          */ /*getNotificationList(context);*/ /*
        });
      });*/
    } else if (model.status == "Error") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void getOPDProcedures() async {
    listOPDRegistration = [];
    listOPDRegistrationSearchResults = [];
    String loginUrl = "${baseURL}doctorPatientVisitHostory.php";
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
        widget.patientIDP +
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
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listOPDRegistration.add(ModelOPDRegistration(
          jo['HospitalConsultationIDP'].toString(),
          fullName,
          /*jo['ConsultationDate']*/
          jo['TotalAmount'].toString(),
          "",
          amountBeforeDiscount: jo['TotalAmount'].toString(),
          patientIDP: jo['DoctorIDF'].toString(),
          discount: "0",
          vidCallDate: jo['ConsultationDate'],
          doctorName: /*"Dr. " +*/
              jo['FirstName'].trim() + " " + jo['LastName'].trim(),
        ));
      }
      listOPDRegistrationSearchResults = listOPDRegistration;
      setState(() {});
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

  void submitNotifyUpdate(
      BuildContext context, String patientIDPValue, bool isOn) async {
    String loginUrl = "${baseURL}doctorPatientNotifyUpdate.php";

    ProgressDialog prDialog;
    prDialog = ProgressDialog(context);
    prDialog.show();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);

    String notifyUpdate = "0";
    if (isOn) notifyUpdate = "1";

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
        "," +
        "\"" +
        "NotifyValue" +
        "\"" +
        ":" +
        "\"" +
        notifyUpdate +
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
    prDialog.hide();
    if (model.status == "OK") {
      /*var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      listInvestigationMaster = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listInvestigationMaster.add(ModelInvestigationMaster(
          jo['PreInvestTypeIDP'].toString(),
          jo['GroupType'],
          jo['GroupName'],
          jo['InvestigationType'],
          jo['RangeValue'],
          false,
        ));
      }*/
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      /*Future.delayed(
          Duration(
            seconds: 1,
          ), () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return OPDRegistrationScreen();
        })).then((value) {

        });
      });*/
    } else if (model.status == "Error") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void showPdfTypeSelectionDialog(List<PdfType> list,
      ModelOPDRegistration modelOPDRegistration, BuildContext mContext) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                              "Select Pdf to download",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                                color: Colors.blue,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                /*Expanded(
                  child:*/
                ListView.builder(
                    itemCount: list.length,
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            pdfButtonClick(
                              mContext,
                              modelOPDRegistration,
                              listPdfType[index].typeKeyword,
                            );
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
                                          width: 2.0, color: Colors.white),
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
                                      child: Row(
                                        children: [
                                          FaIcon(
                                            list[index].iconData,
                                            size: SizeConfig
                                                    .blockSizeHorizontal! *
                                                5,
                                            color: Colors.green,
                                          ),
                                          SizedBox(
                                            width: SizeConfig
                                                    .blockSizeHorizontal! *
                                                6.0,
                                          ),
                                          Text(
                                            list[index].typeName,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  4.3,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      )))));
                    }),
                /*),*/
              ],
            )));
  }

  void pdfButtonClick(
    BuildContext context,
    ModelOPDRegistration modelOPDRegistration,
    String pdfType,
  ) {
    pdfTypeController.setPdfType(pdfType);
    getPdfDownloadPath(
        context, modelOPDRegistration.idp!, modelOPDRegistration.patientIDP!);
  }

  void getPdfDownloadPath(
      BuildContext context, String idp, String patientIDPLocal) async {
    String? loginUrl;
    /*if (pdfTypeController.pdfType.value == "full")
      loginUrl = "${baseURL}consultationpdfdoc.php";
    else*/
    if (pdfTypeController.pdfType.value == "prescription")
      loginUrl = "${baseURL}prescriptiondocpdf.php";
    else if (pdfTypeController.pdfType.value == "receipt")
      loginUrl = "${baseURL}receiptpdfdoc.php";
    else if (pdfTypeController.pdfType.value == "invoice")
      loginUrl = "${baseURL}invoicepdfdoc.php";
    else if (pdfTypeController.pdfType.value == "full")
      loginUrl = "${baseURL}consultationpdfdoc.php";
    //  debugPrint("pdf url -  $loginUrl");

    pr = ProgressDialog(context);
    pr!.show();
    String patientIDP = await getPatientOrDoctorIDP();
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
        widget.patientIDP +
        "\"," +
        "\"" +
        "HospitalConsultationIDF" +
        "\"" +
        ":" +
        "\"" +
        idp +
        "\"" +
        ",\"DoctorIDP\":\"$patientIDPLocal\"" +
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    if (model.status == "OK") {
      String encodedFileName = model.data!;
      String strData = decodeBase64(encodedFileName);
      final jsonData = json.decode(strData);
      String fileName = jsonData[0]['FileName'].toString();
      String downloadPdfUrl = "";
      /*if (pdfTypeController.pdfType.value == "full")
        downloadPdfUrl = "${baseURL}images/consultationDoc/$fileName";
      else*/
      if (pdfTypeController.pdfType.value == "prescription")
        downloadPdfUrl = "${baseImagePath}images/prescriptionDoc/$fileName";
      else if (pdfTypeController.pdfType.value == "receipt")
        downloadPdfUrl = "${baseImagePath}images/receiptDoc/$fileName";
      else if (pdfTypeController.pdfType.value == "invoice")
        downloadPdfUrl = "${baseImagePath}images/invoiceDoc/$fileName";
      else if (pdfTypeController.pdfType.value == "full")
        downloadPdfUrl = "${baseImagePath}images/consultationDoc/$fileName";
      downloadAndOpenTheFile(downloadPdfUrl, fileName);
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr!.hide();
    }
  }
}
