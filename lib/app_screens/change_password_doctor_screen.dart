import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swasthyasetu/app_screens/login_screen_doctor_.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

import '../utils/color.dart';
import 'login_screen_doctor.dart';

class ChangePasswordDoctorScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChangePasswordDoctorScreenState();
  }
}

class ChangePasswordDoctorScreenState
    extends State<ChangePasswordDoctorScreen> {
  TextEditingController oldPasswordController = new TextEditingController();
  TextEditingController newPasswordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  bool _passwordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  bool passwordChanged = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
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
      body: Builder(builder: (context) {
        return !passwordChanged
            ? Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 4.0),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        TextField(
                          controller: oldPasswordController,
                          obscureText: !_passwordVisible,
                          style: TextStyle(color: Colors.green),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.black),
                            labelStyle: TextStyle(color: Colors.black),
                            labelText: "Old Password",
                            hintText: "",
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              child: Icon(_passwordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                          ),
                        ),
                        /*TextField(
                    controller: oldPasswordController,
                    style: TextStyle(color: Colors.green),
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.black),
                      labelStyle: TextStyle(color: Colors.black),
                      labelText: "Old Password",
                      hintText: "",
                    ),
                  ),*/
                        SizedBox(
                          height: SizeConfig.blockSizeVertical !* 1.5,
                        ),
                        TextField(
                          controller: newPasswordController,
                          obscureText: !_newPasswordVisible,
                          style: TextStyle(color: Colors.green),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.black),
                            labelStyle: TextStyle(color: Colors.black),
                            labelText: "New Password",
                            hintText: "",
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _newPasswordVisible = !_newPasswordVisible;
                                });
                              },
                              child: Icon(_newPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                          ),
                        ),
                        /*TextField(
                    controller: newPasswordController,
                    style: TextStyle(color: Colors.green),
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.black),
                      labelStyle: TextStyle(color: Colors.black),
                      labelText: "New Password",
                      hintText: "",
                    ),
                  ),*/
                        SizedBox(
                          height: SizeConfig.blockSizeVertical !* 1.5,
                        ),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: !_confirmPasswordVisible,
                          style: TextStyle(color: Colors.green),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.black),
                            labelStyle: TextStyle(color: Colors.black),
                            labelText: "Confirm Password",
                            hintText: "",
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _confirmPasswordVisible =
                                      !_confirmPasswordVisible;
                                });
                              },
                              child: Icon(_confirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                          ),
                        ),
                        /*TextField(
                    controller: confirmPasswordController,
                    style: TextStyle(color: Colors.green),
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.black),
                      labelStyle: TextStyle(color: Colors.black),
                      labelText: "Confirm Password",
                      hintText: "",
                    ),
                  ),*/
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
                              changePassword(context);
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
                      "Password Changed",
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
                      "Your Password has been changed successfully.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.blockSizeHorizontal !* 4.3,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical !* 3.0,
                    ),
                    Text(
                      "Login with New Password",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical !* 0.5,
                    ),
                    MaterialButton(
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
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.3,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.0,
                        ),
                      ),
                    )
                  ],
                ),
              );
      }),
    );
  }

  void changePassword(BuildContext context) async {
    if (oldPasswordController.text.trim() == "") {
      showSnackBarWithText("Please type Old Password.");
      return;
    }
    if (newPasswordController.text.trim() == "") {
      showSnackBarWithText("Please type New Password.");
      return;
    }
    if (newPasswordController.text.trim().length < 6) {
      showSnackBarWithText("New Password should be atleast 6 characters long.");
      return;
    }
    if (confirmPasswordController.text.trim() == "") {
      showSnackBarWithText("Please type Confirm Password.");
      return;
    }
    if (newPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      showSnackBarWithText("New Password and Confirm Password not matching.");
      return;
    }
    String loginUrl = "${baseURL}doctorChangePassword.php";

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
        "oldpassword" +
        "\"" +
        ":" +
        "\"" +
        oldPasswordController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "newpassword" +
        "\"" +
        ":" +
        "\"" +
        newPasswordController.text.trim() +
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
    print("getjson");
    print(encodedJSONStr);
    //var resBody = json.decode(response.body);
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    prDialog.hide();
    if (model.status == "OK") {
      //showSnackBarWithText(model.message, type: "success");
      setState(() {
        passwordChanged = true;
      });
      /*Future.delayed(
          Duration(
            seconds: 2,
          ), () {
        Navigator.of(context).pop();
      });*/
    } else if (model.status == "ERROR") {
      debugPrint("Error!!!!!!!!!!!!!");
      showSnackBarWithText(model.message!);
    }
  }

  logOut(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
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
