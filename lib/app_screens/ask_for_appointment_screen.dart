import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:silvertouch/app_screens/add_patient_screen.dart';
import 'package:silvertouch/podo/slot_model.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/color.dart';
import '../utils/progress_dialog.dart';

class AskForAppointmentScreen extends StatefulWidget {
  String patientIDP, doctorIDP, appointmentStatus;

  AskForAppointmentScreen(
      this.patientIDP, this.doctorIDP, this.appointmentStatus);

  @override
  State<StatefulWidget> createState() {
    return AskForAppointmentScreenState();
  }
}

class AskForAppointmentScreenState extends State<AskForAppointmentScreen> {
  TextEditingController purposeController = TextEditingController();
  TextEditingController appointmentDateController = TextEditingController();
  TextEditingController slotController = TextEditingController();
  String selectedSlotIDF = "";
  List<SlotModel> listSlot = [];
  var pickedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    var pickedDate = DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(pickedDate);
    appointmentDateController = TextEditingController(text: formatted);
    if (widget.appointmentStatus == "1") getSlotList(context);
  }

  void getSlotList(BuildContext context) async {
    String loginUrl = "${baseURL}doctorAppointmentSlots.php";
    slotController.text = "";
    selectedSlotIDF = "";
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
        "\"DoctorIDP\":\"${widget.doctorIDP}\"," +
        "\"AppointmentDate\":\"${appointmentDateController.text.trim()}\"" +
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
    debugPrint("response :" + response.body.toString());
    debugPrint("Data :" + model.data!);
    listSlot = [];
    //listCategories = [];
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);
      for (int i = 0; i < jsonData.length; i++) {
        final jo = jsonData[i];
        listSlot.add(SlotModel(
          jo['ScheduleTimingIDP'].toString(),
          jo['StartTime'].toString() + " - " + jo['EndTime'].toString(),
          jo['BookedSlot'].toString(),
        ));
        setState(() {});
      }
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Ask for Appointment"),
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(color: Colorsblack),
          toolbarTextStyle: TextTheme(
              titleMedium: TextStyle(
            color: Colorsblack,
            fontFamily: "Ubuntu",
            fontSize: SizeConfig.blockSizeVertical! * 2.5,
          )).bodyMedium,
          titleTextStyle: TextTheme(
              titleMedium: TextStyle(
            color: Colorsblack,
            fontFamily: "Ubuntu",
            fontSize: SizeConfig.blockSizeVertical! * 2.5,
          )).titleLarge,
        ),
        body: Builder(
          builder: (context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Container(
                        height: SizeConfig.blockSizeVertical! * 12,
                        width: SizeConfig.blockSizeHorizontal! * 100,
                        color: Colors.blueGrey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 3),
                            Icon(
                              Icons.warning,
                              color: Colors.white,
                              size: SizeConfig.blockSizeHorizontal! * 8,
                            ),
                            SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 3),
                            SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 82,
                                child: Text(
                                  "Information here will be sent as appoinment request. Our customer support will contact you for further details.",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal! *
                                              3.6),
                                )),
                          ],
                        )),
                    Padding(
                      padding:
                          EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 3),
                      child: Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () {
                            showDateSelectionDialog();
                          },
                          child: Container(
                            child: IgnorePointer(
                              child: TextField(
                                controller: appointmentDateController,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize:
                                        SizeConfig.blockSizeVertical! * 2.1),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.1),
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical! * 2.1),
                                  labelText: "Appointment Date",
                                  hintText: "",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    widget.appointmentStatus == "1"
                        ? Padding(
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 3),
                            child: Align(
                              alignment: Alignment.center,
                              child: InkWell(
                                onTap: () {
                                  showSlotSelectionDialog(
                                      context, parentSetState);
                                },
                                child: Container(
                                  child: IgnorePointer(
                                    child: TextField(
                                      controller: slotController,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize:
                                              SizeConfig.blockSizeVertical! *
                                                  2.1),
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
                                        labelText: "Time Slot",
                                        hintText: "",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container()
                    /*Padding(
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal * 3),
                            child: Align(
                              alignment: Alignment.center,
                              child: InkWell(
                                onTap: () {
                                  showSlotSelectionDialog(
                                      context, parentSetState);
                                },
                                child: Container(
                                  child: IgnorePointer(
                                    child: TextField(
                                      controller: slotController,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize:
                                              SizeConfig.blockSizeVertical *
                                                  2.1),
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical *
                                                    2.1),
                                        labelStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical *
                                                    2.1),
                                        labelText: "Time Slot",
                                        hintText: "",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )*/
                    ,
                    Padding(
                      padding:
                          EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 3),
                      child: TextField(
                        controller: purposeController,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        decoration: new InputDecoration(
                          hintText: 'Purpose / Remarks',
                        ),
                      ),
                    ),
                  ],
                )),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: SizeConfig.blockSizeVertical! * 12,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 80,
                        child: MaterialButton(
                          onPressed: () {
                            submitAppointmentRequest(patientIDP!, context);
                          },
                          color: Colors.green,
                          child: Text(
                            "Request Appointment",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ));
  }

  parentSetState() {
    setState(() {});
  }

  void showDateSelectionDialog() async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    DateTime firstDate = DateTime.now();
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: pickedDate,
        firstDate: firstDate,
        lastDate: DateTime.now().add(Duration(days: 365)));

    if (date != null) {
      pickedDate = date;
      var formatter = new DateFormat('dd-MM-yyyy');
      String formatted = formatter.format(pickedDate);
      appointmentDateController = TextEditingController(text: formatted);
      setState(() {});
      if (widget.appointmentStatus == "1") getSlotList(context);
    }
  }

  void showSlotSelectionDialog(
      BuildContext context, Function() parentSetState) async {
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
                              "Select Time Slot",
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
                      itemCount: listSlot.length,
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      /*gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 0,
                              mainAxisSpacing: 0,
                              childAspectRatio: 5.0,
                            ),*/
                      itemBuilder: (context, index) {
                        SlotModel slot = listSlot[index];
                        return InkWell(
                            onTap: () {
                              /*debugPrint(
                                  "clicked - ${listSlot[index].slotIDP}");
                              debugPrint(slot.slotIDP);
                              debugPrint(slot.bookedSlot);*/

                              if (slot.bookedSlot == "0") {
                                slotController = TextEditingController(
                                    text: listSlot[index].slotTiming);
                                selectedSlotIDF = listSlot[index].slotIDP;
                                setState(() {});
                                parentSetState();
                                Navigator.of(context).pop();
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
                                            width: 1.0, color: Colors.grey),
                                      ),
                                      /* boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10.0,
                                          offset: const Offset(0.0, 10.0),
                                        ),
                                      ],*/
                                    ),
                                    child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              listSlot[index].slotTiming,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: slot.bookedSlot == "0"
                                                    ? Colors.black
                                                    : Colors.grey,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                            slot.bookedSlot == "0"
                                                ? Expanded(
                                                    child: Align(
                                                    child: Text(
                                                      "Available",
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    alignment:
                                                        Alignment.centerRight,
                                                  ))
                                                : Container()
                                          ],
                                        )))));
                      }),
                ),
              ],
            )));
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

  void submitAppointmentRequest(
      String patientReportIDP, BuildContext context) async {
    if (purposeController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please Type your Purpose first."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (widget.appointmentStatus == "1" && selectedSlotIDF == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please Select Time Slot."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    String loginUrl = "${baseURL}appoinmentRequest.php";

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
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP +
        "\"" +
        "," +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.doctorIDP +
        "\"" +
        "," +
        "\"" +
        "Purpose" +
        "\"" +
        ":" +
        "\"" +
        replaceNewLineBySlashN(purposeController.text.trim()) +
        "\"" +
        "," +
        "\"" +
        "AppoinmentDate" +
        "\"" +
        ":" +
        "\"" +
        appointmentDateController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "ScheduleTimingIDF" +
        "\"" +
        ":" +
        "\"" +
        selectedSlotIDF +
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
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(milliseconds: 1500), () {
        Navigator.of(context).pop();
      });
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
