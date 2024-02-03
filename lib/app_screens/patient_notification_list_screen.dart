import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swasthyasetu/api/api_helper.dart';
import 'package:swasthyasetu/app_screens/opd_registration_screen.dart';
import 'package:swasthyasetu/app_screens/view_profile_details_patient_inside_doctor.dart';
import 'package:swasthyasetu/app_screens/vital_investigation_patient_wise_screen_from_notification.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_notification_patient_data.dart';
import 'package:swasthyasetu/podo/model_notiofication_list.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:swasthyasetu/widgets/extensions.dart';

import '../utils/color.dart';
import 'custom_dialog.dart';

class PatientNotificationList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PatientNotificationListState();
  }
}

class PatientNotificationListState extends State<PatientNotificationList> {
  List<ModelNotificationList>? listPatientNotification;
  bool notificationListApiCalled1 = false;
  ApiHelper apiHelper = ApiHelper();

  @override
  void initState() {
    super.initState();
    listPatientNotification = [];
    notificationListApiCalled1 = false;
    getNotificationList(context);
  }

  @override
  Widget build(BuildContext context) {

    clearNotification(ModelNotificationList model, bool clearAll) async {
      setState(() {
        listPatientNotification = [];
        notificationListApiCalled1 = false;
      });
      if (model.notificationType == "general" || clearAll)
        clearGeneralNotification(model.notificationIDP!, clearAll);
      else if (model.notificationType == "appointment")
        clearAppointmentNotification(model.notificationIDP!, clearAll);
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(color: Colorsblack),
          title: Row(
            children: <Widget>[
              Text(
                "Notifications",
                style:
                TextStyle(fontSize: SizeConfig.blockSizeHorizontal !* 4.2),
              ),
              Visibility(
                  visible: listPatientNotification!.length > 0 ? true : false,
                  child: Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () => clearNotification(
                              ModelNotificationList("", "", "", "", "", "", ""),
                              true),
                          child: Text(
                            "Clear All",
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal !* 3.5),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      )))
            ],
          ), toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5,
            )).bodyMedium, titleTextStyle: TextTheme(
            titleMedium: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5,
            )).titleLarge,
        ),
        body: ColoredBox(
          color: Color(0xFFF1EDEB),
          child: listPatientNotification!.length > 0
              ? ListView.builder(
              itemCount: listPatientNotification!.length,
              itemBuilder: (context, pos) => InkWell(
                onTap: () =>
                    onClickNotification(listPatientNotification![pos], context),
                child: Padding(
                  padding:
                  EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
                  child: listPatientNotification![pos].notificationType ==
                      "general"
                      ? Card(
                    child:
                    /*Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child:*/
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            child: Padding(
                              padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal !*
                                      2),
                              child: Image(
                                width: SizeConfig
                                    .blockSizeHorizontal !*
                                    30,
                                image: AssetImage(
                                  "images/ic_notification_bell.png",
                                  /*"$userImgUrl${listNotification[pos].imgUrl}"*/
                                ),
                              ),
                            )).pO(
                          left: SizeConfig.blockSizeHorizontal !*
                              3.0,
                        ),
                        SizedBox(
                          width: 15.0,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: SizeConfig
                                              .blockSizeVertical !*
                                              1.0,
                                        ),
                                        Text(
                                          listPatientNotification![pos]
                                              .title!,
                                          style: TextStyle(
                                            fontSize: SizeConfig
                                                .blockSizeHorizontal !*
                                                3.5,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                          height: SizeConfig
                                              .blockSizeVertical !*
                                              0.5,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              color: Colors
                                                  .grey[500],
                                              size: SizeConfig
                                                  .blockSizeHorizontal !*
                                                  5.0,
                                            ),
                                            SizedBox(
                                              width: SizeConfig
                                                  .blockSizeHorizontal !*
                                                  1.0,
                                            ),
                                            Text(
                                              listPatientNotification![
                                              pos]
                                                  .desc!,
                                              style: TextStyle(
                                                fontSize: SizeConfig
                                                    .blockSizeHorizontal !*
                                                    3.5,
                                                color: Colors
                                                    .grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: SizeConfig
                                              .blockSizeVertical !*
                                              1.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: SizeConfig
                                        .blockSizeHorizontal !*
                                        2,
                                  ),
                                  InkWell(
                                    customBorder: CircleBorder(),
                                    onTap: () =>
                                        clearNotification(
                                            listPatientNotification![pos],
                                            false),
                                    child: Container(
                                      height: SizeConfig
                                          .blockSizeVertical !*
                                          12.0,
                                      width: SizeConfig
                                          .blockSizeHorizontal !*
                                          8.0,
                                      color: Colors.red,
                                      child: Image(
                                        image: AssetImage(
                                            "images/ic_cancel.png"),
                                        color: Colors.white,
                                        width: SizeConfig
                                            .blockSizeHorizontal !*
                                            6,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    /*),*/
                  )
                      : listPatientNotification![pos].notificationType ==
                      "appointment"
                      ? Card(
                    color: Color(0xEEFEF1B5),
                    shadowColor: Colors.red,
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width:
                          SizeConfig.blockSizeHorizontal !*
                              3.0,
                        ),
                        CircleAvatar(
                            radius: SizeConfig
                                .blockSizeHorizontal !*
                                5,
                            backgroundColor: Colors.grey,
                            backgroundImage: getBackgroundImage(pos) /*),*/
                        ),
                        SizedBox(
                          width: 15.0,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: <Widget>[
                                    SizedBox(
                                      height: SizeConfig
                                          .blockSizeVertical !*
                                          1.0,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .subdirectory_arrow_right,
                                          color: Colors
                                              .grey[600],
                                          size: SizeConfig
                                              .blockSizeHorizontal !*
                                              4.8,
                                        ),
                                        Text(
                                          "Appointment requested",
                                          style: TextStyle(
                                            fontSize: SizeConfig
                                                .blockSizeHorizontal !*
                                                3.8,
                                            color: Colors
                                                .blue[600],
                                            fontStyle:
                                            FontStyle
                                                .italic,
                                            fontWeight:
                                            FontWeight
                                                .w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: SizeConfig
                                          .blockSizeVertical !*
                                          1.3,
                                    ),
                                    Text(
                                      listPatientNotification![pos]
                                          .modelNotificationPatientData
                                      !.patientName!,
                                      style: TextStyle(
                                        fontSize: SizeConfig
                                            .blockSizeHorizontal !*
                                            3.5,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                      height: SizeConfig
                                          .blockSizeVertical !*
                                          0.8,
                                    ),
                                    Row(children: <Widget>[
                                      Text(
                                        "${listPatientNotification![pos].modelNotificationPatientData!.gender}/${listPatientNotification![pos].modelNotificationPatientData!.age}",
                                        style: TextStyle(
                                          fontSize: SizeConfig
                                              .blockSizeHorizontal !*
                                              3.5,
                                          color: Colors
                                              .blue[900],
                                        ),
                                      ),
                                      SizedBox(
                                        width: SizeConfig
                                            .blockSizeHorizontal !*
                                            6,
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        color:
                                        Colors.grey[500],
                                        size: SizeConfig
                                            .blockSizeHorizontal !*
                                            5.0,
                                      ),
                                      SizedBox(
                                        width: SizeConfig
                                            .blockSizeHorizontal !*
                                            1.0,
                                      ),
                                      Text(
                                        listPatientNotification![pos]
                                            .modelNotificationPatientData
                                        !.date!,
                                        style: TextStyle(
                                          fontSize: SizeConfig
                                              .blockSizeHorizontal !*
                                              3.5,
                                          color: Colors
                                              .grey[800],
                                        ),
                                      ),
                                    ]),
                                    SizedBox(
                                      height: SizeConfig
                                          .blockSizeVertical !*
                                          1.0,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: SizeConfig
                                    .blockSizeHorizontal !*
                                    2,
                              ),
                              InkWell(
                                customBorder: CircleBorder(),
                                onTap: () =>
                                    clearNotification(
                                        listPatientNotification![pos],
                                        false),
                                child: Container(
                                  height: SizeConfig
                                      .blockSizeVertical !*
                                      12.0,
                                  width: SizeConfig
                                      .blockSizeHorizontal !*
                                      8.0,
                                  color: Colors.red,
                                  child: Image(
                                    image: AssetImage(
                                        "images/ic_cancel.png"),
                                    color: Colors.white,
                                    width: SizeConfig
                                        .blockSizeHorizontal !*
                                        6,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      : listPatientNotification![pos].notificationType ==
                      "bind"
                      ? Card(
                    color: Colors.teal[100],
                    shadowColor: Colors.red,
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                            radius: SizeConfig
                                .blockSizeHorizontal !*
                                5,
                            backgroundColor: Colors.grey,
                            backgroundImage: getBackgroundImage(pos)/*),*/
                        ),
                        SizedBox(
                          width: 15.0,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .subdirectory_arrow_right,
                                          color: Colors
                                              .grey[600],
                                          size: SizeConfig
                                              .blockSizeHorizontal !*
                                              4.8,
                                        ),
                                        Text(
                                          "Connect Request",
                                          style:
                                          TextStyle(
                                            fontSize:
                                            SizeConfig
                                                .blockSizeHorizontal !*
                                                3.8,
                                            color: Colors
                                                .blue[
                                            600],
                                            fontStyle:
                                            FontStyle
                                                .italic,
                                            fontWeight:
                                            FontWeight
                                                .w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: SizeConfig
                                          .blockSizeVertical !*
                                          1.3,
                                    ),
                                    Text(
                                      listPatientNotification![
                                      pos]
                                          .modelNotificationPatientData
                                      !.patientName!,
                                      style: TextStyle(
                                        fontSize: SizeConfig
                                            .blockSizeHorizontal !*
                                            3.5,
                                        color:
                                        Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                      height: SizeConfig
                                          .blockSizeVertical !*
                                          0.8,
                                    ),
                                    Row(children: <
                                        Widget>[
                                      Text(
                                        "${listPatientNotification![pos].modelNotificationPatientData!.gender}/${listPatientNotification![pos].modelNotificationPatientData!.age}",
                                        style: TextStyle(
                                          fontSize: SizeConfig
                                              .blockSizeHorizontal !*
                                              3.5,
                                          color: Colors
                                              .blue[900],
                                        ),
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: SizeConfig
                                    .blockSizeHorizontal !*
                                    2,
                              ),
                              InkWell(
                                customBorder:
                                CircleBorder(),
                                onTap: () =>
                                    clearNotification(
                                        listPatientNotification![
                                        pos],
                                        false),
                                child: Container(
                                  height: SizeConfig
                                      .blockSizeVertical !*
                                      12.0,
                                  width: SizeConfig
                                      .blockSizeHorizontal !*
                                      8.0,
                                  color: Colors.red,
                                  child: Image(
                                    image: AssetImage(
                                        "images/ic_cancel.png"),
                                    color: Colors.white,
                                    width: SizeConfig
                                        .blockSizeHorizontal !*
                                        6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      : Container(),
                ),
              ))
              : (notificationListApiCalled1
              ? Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[700],
                      shape: BoxShape.circle,
                    ),
                    /*backgroundColor: Colors.grey,
                              radius: SizeConfig.blockSizeHorizontal * 10,*/
                    child: Padding(
                      padding: EdgeInsets.all(
                          SizeConfig.blockSizeHorizontal !* 3),
                      child: Image(
                        width: SizeConfig.blockSizeHorizontal !* 12,
                        height: SizeConfig.blockSizeHorizontal !* 12,
                        image: AssetImage(
                          "images/ic_notification_bell.png",
                        ),
                      ),
                    )),
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 2,
                ),
                Text(
                  "No Notification(s) to show.",
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          )
              : Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )),
        ));
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

  Future getNotificationList(BuildContext context) async {
    setState(() {
      notificationListApiCalled1 = false;
    });
    String notificationCountUrl = "${baseURL}doctorNotificationList.php";

    String patientIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();

    String jsonStr;
    jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

    String encodedJSONStr = encodeBase64(jsonStr);
    //var jsonsdfs = json.decode();

    var response = await apiHelper
        .callApiWithHeadersAndBody(url: notificationCountUrl, headers: {
      "u": patientUniqueKey,
      "type": userType,
    }, body: {
      "getjson": encodedJSONStr
    });
    //var resBody = json.decode(response.body);
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    listPatientNotification = [];
    if (model.status == "OK") {
      var jsonData = null;
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("not list Decoded Data Array : " + strData);
      jsonData = json.decode(strData);
      for (int i = 0; i < jsonData[2]['BindPatientRequest'].length; i++) {
        final jo = jsonData[2]['BindPatientRequest'][i];
        listPatientNotification!.add(ModelNotificationList(
            jo["AppoinmentRequestIDP"], jo["PatientIDP"], "", "", "", "", "",
            notificationType: "bind",
            modelNotificationPatientData: ModelNotificationPatientData(
              patientIDP: jo["PatientIDP"],
              patientName: jo["FirstName"].toString().trim() +
                  " " +
                  jo["MiddleName"].toString().trim() +
                  " " +
                  jo["LastName"].toString().trim() +
                  " ",
              age: jo["years"],
              gender: jo["Gender"],
              photo: jo["Image"],
            )));
      }
      for (int i = 0; i < jsonData[1]['Appointement'].length; i++) {
        final jo = jsonData[1]['Appointement'][i];
        listPatientNotification!.add(ModelNotificationList(
            jo["AppoinmentRequestIDP"], jo["PatientIDP"], "", "", "", "", "",
            notificationType: "appointment",
            modelNotificationPatientData: ModelNotificationPatientData(
              patientIDP: jo["PatientIDP"],
              patientName: jo["FirstName"].toString().trim() +
                  " " +
                  jo["MiddleName"].toString().trim() +
                  " " +
                  jo["LastName"].toString().trim() +
                  " ",
              age: jo["years"],
              gender: jo["Gender"],
              photo: jo["Image"],
              date: jo["AppoinmentDate"],
              purpose: jo["PurposeOfAppoinment"],
            )));
      }
      for (int i = 0; i < jsonData[0]['General'].length; i++) {
        final jo = jsonData[0]['General'][i];
        listPatientNotification!.add(ModelNotificationList(
          jo['NotificationLogIDP'],
          jo['PatientIDF'],
          jo['GroupValue'],
          jo['Narration'],
          jo['EntryTime'] + ", " + jo['EntryDate'],
          jo['GroupIDF'],
          "",
          notificationType: "general",
        ));
      }
      setState(() {
        //listNotification = listNotificationNew;
        notificationListApiCalled1 = true;
      });
    } else {
      setState(() {
        notificationListApiCalled1 = true;
      });
      /*}*/
      //}
      /*setState(() {
        notificationListApiCalled = true;
      });*/
    }
  }

  clearNotification(ModelNotificationList model, bool clearAll) async {
    setState(() {
      listPatientNotification = [];
      notificationListApiCalled1 = false;
    });
    clearGeneralNotification(model.notificationIDP!, clearAll);
  }

  onClickNotification(
      ModelNotificationList modelNotification, BuildContext context) async {
    if (modelNotification.notificationType == "general") {
      await clearNotification(modelNotification, false);
      String categoryIDP = "";
      if (modelNotification.type == "Vitals") {
        categoryIDP = "1";
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ShowVitalsInvestigationPatientWiseFromNotifications(
              modelNotification.patientIDP!, categoryIDP, modelNotification.idf!);
        })).then((value) {
          getNotificationList(context);
        });
      } else if (modelNotification.type == "Reports") {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ShowVitalsInvestigationPatientWiseFromNotifications(
              modelNotification.patientIDP!, "3", "3");
        }));
      } else if (modelNotification.type == "Investigations") {
        categoryIDP = "2";
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ShowVitalsInvestigationPatientWiseFromNotifications(
              modelNotification.patientIDP!, categoryIDP, modelNotification.idf!);
        })).then((value) {
          getNotificationList(context);
        });
      }
    } else if (modelNotification.notificationType == "appointment") {
      showPopUpDialogForAppointmentType(modelNotification, context);
    } else if (modelNotification.notificationType == "bind") {
      showPopUpDialogForAppointmentType(modelNotification, context);
    }
    //modelNotification.
    /*if (modelNotification.type == "general")
      Navigator.pop(context);
    else if (modelNotification.type == "dailyquiz")
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DailyQuiz(modelNotification.idf)));*/
  }

  void showPopUpDialogForAppointmentType(
      ModelNotificationList modelNotification, BuildContext contextMain) {
    DateFormat dateFormat = DateFormat("dd-MM-yyyy");
    var dateFormatWithWeekDay = DateFormat('dd-MM-yyyy (EEEE)');
    DateTime selectedDate = dateFormat
        .parse(modelNotification.modelNotificationPatientData!.date!.trim());
    String selectedDateStr = dateFormatWithWeekDay.format(selectedDate);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Consts.padding),
              ),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: Stack(
                children: <Widget>[
                  //...bottom card part,
                  Container(
                    margin: EdgeInsets.only(top: Consts.avatarRadius),
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
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      // To make the card compact
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding:
                          EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
                          decoration: BoxDecoration(
                            color: Color(0xEEFEF1B5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  getBackIconCorrespondingToPlatform(),
                                  color: Colors.black,
                                  size: SizeConfig.blockSizeHorizontal !* 7.0,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              Center(
                                child: Text(
                                  modelNotification.notificationType ==
                                      "appointment"
                                      ? "Appointment requested"
                                      : "Connect Request",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: SizeConfig.blockSizeHorizontal !* 5.5,
                                    color: Colors.blue[600],
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ).expanded(),
                            ],
                          ),
                        ),
                        SizedBox(height: SizeConfig.blockSizeVertical !* 1),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal !* 3),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Patient Name",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                        SizeConfig.blockSizeHorizontal !* 5.0,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                        SizeConfig.blockSizeHorizontal !* 5,
                                        vertical:
                                        SizeConfig.blockSizeHorizontal !* 2,
                                      ),
                                      child: Text(
                                        modelNotification
                                            .modelNotificationPatientData
                                        !.patientName! +
                                            "(" +
                                            modelNotification
                                                .modelNotificationPatientData
                                            !.gender! +
                                            "/" +
                                            modelNotification
                                                .modelNotificationPatientData!.age! +
                                            ")",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize:
                                          SizeConfig.blockSizeHorizontal !* 4.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  modelNotification.notificationType ==
                                      "appointment"
                                      ? Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Purpose",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                        SizeConfig.blockSizeHorizontal !*
                                            5.0,
                                      ),
                                    ),
                                  )
                                      : Container(),
                                  modelNotification.notificationType ==
                                      "appointment"
                                      ? Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                        SizeConfig.blockSizeHorizontal !*
                                            5,
                                        vertical:
                                        SizeConfig.blockSizeHorizontal !*
                                            2,
                                      ),
                                      child: Text(
                                        modelNotification
                                            .modelNotificationPatientData
                                        !.purpose!,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize:
                                          SizeConfig.blockSizeHorizontal !*
                                              4.0,
                                        ),
                                      ),
                                    ),
                                  )
                                      : Container(),
                                  modelNotification.notificationType ==
                                      "appointment"
                                      ? Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Appointment Date",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                        SizeConfig.blockSizeHorizontal !*
                                            5.0,
                                      ),
                                    ),
                                  )
                                      : Container(),
                                  modelNotification.notificationType ==
                                      "appointment"
                                      ? Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                        SizeConfig.blockSizeHorizontal !*
                                            5,
                                        vertical:
                                        SizeConfig.blockSizeHorizontal !*
                                            2,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            selectedDateStr,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: SizeConfig
                                                  .blockSizeHorizontal !*
                                                  4.0,
                                            ),
                                          ),
                                          SizedBox(
                                            width: SizeConfig
                                                .blockSizeHorizontal !*
                                                3.0,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              DateTime now = DateTime.now();
                                              DateTime? date =
                                              await showDatePicker(
                                                  context: contextMain,
                                                  initialDate:
                                                  selectedDate
                                                      .isBefore(
                                                      now)
                                                      ? now
                                                      : selectedDate,
                                                  firstDate: now,
                                                  lastDate: now.add(
                                                      Duration(
                                                          days: 365)));

                                              if (date != null) {
                                                selectedDate = date;
                                                var formatter = DateFormat(
                                                    'dd-MM-yyyy (EE)');
                                                selectedDateStr = formatter
                                                    .format(selectedDate);
                                                setState(() {});
                                              }
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.blueGrey,
                                              size: SizeConfig
                                                  .blockSizeHorizontal !*
                                                  5.0,
                                            ),
                                            /*)*/
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                      : Container(),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: MaterialButton(
                                          color: Colors.blue,
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) {
                                                      return ViewProfileDetailsInsideDoctor(
                                                        modelNotification
                                                            .modelNotificationPatientData
                                                        !.patientIDP,
                                                        from: "notification",
                                                      );
                                                    })).then((value) {
                                              getNotificationList(context);
                                            });
                                          },
                                          child: Text(
                                            "View Profile",
                                            style: TextStyle(color: Colors.white),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ) /*)*/,
                                      SizedBox(
                                        width: SizeConfig.blockSizeHorizontal !* 3,
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: MaterialButton(
                                          color: Colors.green,
                                          onPressed: () {
                                            if (modelNotification
                                                .notificationType ==
                                                "appointment") {
                                              if (!checkIfDateIsLowerThanNow(
                                                  contextMain,
                                                  selectedDate,
                                                  modelNotification)) {
                                                Navigator.of(context).pop();
                                                submitAllTheData(
                                                    contextMain,
                                                    modelNotification,
                                                    dateFormat
                                                        .format(selectedDate));
                                              }
                                            } else if (modelNotification
                                                .notificationType ==
                                                "bind") {
                                              Navigator.of(context).pop();
                                              acceptBindRequest(modelNotification
                                                  .modelNotificationPatientData!);
                                            }
                                            /*Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return AddOPDProcedures(
                                          List(),
                                          modelNotification
                                              .modelNotificationPatientData
                                              .patientIDP,
                                          "",
                                          "notification",
                                          appointmentRequestIDP:
                                              modelNotification.notificationIDP,
                                        );
                                        */ /*SelectOPDProceduresScreen(
                                          modelNotification
                                              .modelNotificationPatientData
                                              .patientIDP,
                                          "",
                                          "notification",
                                          appointmentRequestIDP:
                                              modelNotification.notificationIDP,
                                        );*/ /*
                                      })).then((value) {
                                        getNotificationList(context);
                                      });*/
                                          },
                                          child: Text(
                                            modelNotification.type == "appointment"
                                                ? "Add to Appointment"
                                                : "Accept",
                                            style: TextStyle(color: Colors.white),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ) /*)*/,
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical !* 0.5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  void acceptBindRequest(
      ModelNotificationPatientData modelNotificationPatientData) async {
    String loginUrl = "${baseURL}doctorAcceptBindRequest.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String doctorIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        modelNotificationPatientData.patientIDP! +
        "\"" +
        "," +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        doctorIDP +
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
      /*final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
      showBindRequestAcceptedDialog(modelNotificationPatientData);
      getNotificationList(context);
    } else if (model.status == "Error") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void submitAllTheData(
      BuildContext context,
      ModelNotificationList modelNotification,
      String appointmentDateStr) async {
    String loginUrl = "${baseURL}appointmentacceptremove.php";

    ProgressDialog prDialog;
    prDialog = ProgressDialog(context);
    prDialog.show();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);

    String unCommonParameter = "";

    unCommonParameter = "," +
        "\"OPDDate\":\"$appointmentDateStr\"," +
        "\"AppoinmentRequestIDP\":\"${modelNotification.notificationIDP}\"," +
        "\"RemoveStatus\":\"0\"";

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
        modelNotification.patientIDP! +
        "\"" +
        "," +
        "\"" +
        "PaymentMode" +
        "\"" +
        ":" +
        "\"" +
        "" +
        "\"" +
        unCommonParameter +
        "," +
        "\"" +
        "PaymentDetails" +
        "\"" +
        ":" +
        "\"" +
        "" +
        "\"" +
        "," +
        "\"consultationdata" +
        "\"" +
        ":" +
        "[]" +
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
          Navigator.of(context).pop();
          /*getNotificationList(context);*/
        });
      });
    } else if (model.status == "Error") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void clearGeneralNotification(String notificationIDP, bool clearAll) async {
    String notificationCountUrl = "${baseURL}doctorNotificationClear.php";
    String patientIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();

    String jsonStr;
    jsonStr = "";
    String clearFlag;
    if (clearAll) {
      clearFlag = "0";
    } else {
      clearFlag = "1";
    }
    jsonStr = "{" +
        "\"DoctorIDP\":\"$patientIDP\"," +
        "\"ClearFlagSingle\":\"$clearFlag\"," +
        "\"NotificationLogIDP\":\"$notificationIDP\"" +
        "}";

    debugPrint("Jsonstr - $jsonStr");

    String encodedJSONStr = encodeBase64(jsonStr);

    var response = await apiHelper.callApiWithHeadersAndBody(
      url: notificationCountUrl,
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
      getNotificationList(context);
    }
  }

  void clearAppointmentNotification(
      String notificationIDP, bool clearAll) async {
    String notificationCountUrl = "${baseURL}appointmentacceptremove.php";
    String patientIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();

    String jsonStr;
    jsonStr = "";
    String clearFlag;
    if (clearAll) {
      clearFlag = "0";
    } else {
      clearFlag = "1";
    }
    jsonStr = "{" +
        "\"DoctorIDP\":\"$patientIDP\"," +
        "\"AppoinmentRequestIDP\":\"$notificationIDP\"," +
        "\"RemoveStatus\":\"1\"" +
        "}";

    debugPrint("Jsonstr - $jsonStr");

    String encodedJSONStr = encodeBase64(jsonStr);

    var response = await apiHelper.callApiWithHeadersAndBody(
      url: notificationCountUrl,
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
      getNotificationList(context);
    }
  }

  void showBindRequestAcceptedDialog(
      ModelNotificationPatientData modelNotificationPatientData) {
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "${modelNotificationPatientData.patientName} is now connected with you. You can go to My Patients and access health records.",
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Okay",
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  )),
            ],
          );
        });
  }

  bool checkIfDateIsLowerThanNow(BuildContext contextMain,
      DateTime selectedDate, ModelNotificationList modelNotification) {
    DateTime now = DateTime.now();
    if (selectedDate.isBefore(now)) {
      ScaffoldMessenger.of(contextMain).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
            "Appointment Request date is lower than current Date. Appointment cannot be Confirmed."),
      ));
      return true;
    }
    return false;
  }

  getBackgroundImage(int pos) {
    (listPatientNotification![pos]
        .modelNotificationPatientData
    !.photo !=
        null &&
        listPatientNotification![pos]
            .modelNotificationPatientData
        !.photo !=
            "")
        ? NetworkImage(
        "$userImgUrl${listPatientNotification![pos].modelNotificationPatientData!.photo}")
        : AssetImage(
        "images/ic_user_placeholder.png");
  }
}
