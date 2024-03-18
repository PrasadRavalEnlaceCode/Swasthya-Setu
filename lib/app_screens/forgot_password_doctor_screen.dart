import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:swasthyasetu/app_screens/login_screen_doctor.dart';
import 'package:swasthyasetu/app_screens/login_screen_doctor_.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

import '../utils/color.dart';

class ForgotPasswordDoctorLogin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ForgotPasswordDoctorLoginState();
  }
}

class ForgotPasswordDoctorLoginState extends State<ForgotPasswordDoctorLogin> {
  TextEditingController mobileNoOrEmailController = TextEditingController();
  bool passwordSent = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Forgot Password"),
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(
              color: Colorsblack, size: SizeConfig.blockSizeVertical !* 2.2),
          leading: IconButton(
            icon: Icon(
              Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
          ), toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(
                color: Colorsblack,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical !* 2.5),
          ).bodyMedium, titleTextStyle: TextTheme(
            titleMedium: TextStyle(
                color: Colorsblack,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical !* 2.5),
          ).titleLarge,
        ),
        body: !passwordSent
            ? Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 4.0),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        TextField(
                          controller: mobileNoOrEmailController,
                          style: TextStyle(color: Colors.green),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.black),
                            labelStyle: TextStyle(color: Colors.black),
                            labelText: "Mobile No. / Email ID",
                            hintText: "",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: 0.0,
                            top: 0.0,
                          ),
                          child: RawMaterialButton(
                            onPressed: () {
                              sendPassword(context);
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
                          /*)*/
                        )),
                  ),
                ],
              )
            : Center(
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
                      "Password Sent",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.blockSizeHorizontal !* 7.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical !* 1.5,
                    ),
                    Text(
                      "Your current Password has been sent to your registered Email ID.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.blockSizeHorizontal !* 4.3,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical !* 2.0,
                    ),
                    MaterialButton(
                      onPressed: () {
                        //logOut(context);
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
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.3,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }

  void sendPassword(BuildContext context) async {
    if (mobileNoOrEmailController.text.trim() == "") {
      showSnackBarWithText("Please type Mobile Number or Email ID to proceed.");
      return;
    }
    String loginUrl = "${baseURL}doctorForgorPassword.php";

    ProgressDialog prDialog;
    prDialog = ProgressDialog(context);
    prDialog.show();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    //String patientIDP = await getPatientIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);

    String jsonStr = "{" +
        "\"" +
        "MobileNo" +
        "\"" +
        ":" +
        "\"" +
        mobileNoOrEmailController.text.trim() +
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    prDialog.hide();
    if (model.status == "OK") {
      setState(() {
        passwordSent = true;
      });
    } else if (model.status == "ERROR") {
      debugPrint("Error!!!!!!!!!!!!!");
      showSnackBarWithText(model.message!);
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

  void showSnackBarWithText(String text, {String type = "error"}) {
    Get.snackbar("", text,
        backgroundColor: type == "error" ? Colors.red : Colors.green,
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
        ));
  }
}
