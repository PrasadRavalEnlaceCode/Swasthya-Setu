import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

import '../utils/color.dart';

TextEditingController mobileNoController = TextEditingController();

class InvitePatientScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return InvitePatientScreenState();
  }
}

class InvitePatientScreenState extends State<InvitePatientScreen> {
  @override
  void dispose() {
    mobileNoController = TextEditingController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Invite Patient"),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(color: Colorsblack), toolbarTextStyle: TextTheme(
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
      body: Builder(builder: (context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
                child: Container(
                    /*height: SizeConfig.blockSizeVertical * 15,
                    width: SizeConfig.blockSizeHorizontal * 100,*/
                    color: Colors.blueGrey,
                    child: Padding(
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            //SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                            Icon(
                              Icons.warning,
                              color: Colors.white,
                              size: SizeConfig.blockSizeHorizontal !* 8,
                            ),
                            SizedBox(width: SizeConfig.blockSizeHorizontal !* 3),
                            Expanded(
                                /*width: SizeConfig.blockSizeHorizontal * 82,*/
                                child: Text(
                              "Enter Mobile No. or Patient ID of the Patient you want to Invite, they will receive URL via SMS.",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal !* 3.6),
                            )),
                            //SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                          ],
                        ))),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
                  child: TextField(
                    controller: mobileNoController,
                    style: TextStyle(color: Colors.green),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black),
                        labelStyle: TextStyle(color: Colors.black),
                        labelText: "Mobile Number or Patient ID",
                        hintText: "",
                        counterText: ""),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(
                    right: SizeConfig.blockSizeHorizontal !* 3,
                    bottom: SizeConfig.blockSizeHorizontal !* 3),
                child: Container(
                  width: SizeConfig.blockSizeHorizontal !* 12,
                  height: SizeConfig.blockSizeHorizontal !* 12,
                  child: RawMaterialButton(
                    onPressed: () {
                      invitePatient(context);
                    },
                    elevation: 2.0,
                    fillColor: Color(0xFF06A759),
                    child: Image(
                      width: SizeConfig.blockSizeHorizontal !* 5.5,
                      height: SizeConfig.blockSizeHorizontal !* 5.5,
                      //height: 80,
                      image: AssetImage("images/ic_right_arrow_triangular.png"),
                    ),
                    shape: CircleBorder(),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void invitePatient(BuildContext context) async {
    String mobNoToValidate = mobileNoController.text;
    if (mobileNoController.text.length >= 12) {
      if (mobileNoController.text.startsWith("+91")) {
        mobNoToValidate = mobileNoController.text.replaceFirst("+91", "");
      } else if (mobileNoController.text.startsWith("91")) {
        mobNoToValidate = mobileNoController.text.replaceFirst("91", "");
      }
    }
    if (mobNoToValidate.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please enter Mobile number or Patient ID"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    String loginUrl = "${baseURL}doctorInvitePatient.php";
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
        "MobileNumber" +
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
    if (model.status == "OK") {
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(seconds: 1), () {
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
}
