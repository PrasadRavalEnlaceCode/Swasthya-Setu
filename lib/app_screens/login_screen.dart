import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:silvertouch/api/api_helper.dart';
import 'package:silvertouch/app_screens/verify_otp_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';
import 'package:silvertouch/utils/string_resource.dart';

class LoginScreen extends StatefulWidget {
  String doctorIDP;

  LoginScreen(this.doctorIDP);

  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  final focus = FocusNode();
  TextEditingController mobileNoController = TextEditingController();
  final String loginUrl = "${baseURL}login.php";
  ApiHelper apiHelper = ApiHelper();

  void doLogin(BuildContext context) async {
    String mobNoToValidate = mobileNoController.text;
    if (mobileNoController.text.length >= 12) {
      if (mobileNoController.text.startsWith("+91")) {
        mobNoToValidate = mobileNoController.text.replaceFirst("+91", "");
      } else if (mobileNoController.text.startsWith("91")) {
        mobNoToValidate = mobileNoController.text.replaceFirst("91", "");
      }
    }
    if (mobNoToValidate == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please enter Mobile number"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (mobNoToValidate.length != 10) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Mobile number length must be 10"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      ProgressDialog pr = ProgressDialog(context);
      pr.show();

      var response = await apiHelper.callApiWithHeadersAndBody(
        url: loginUrl,
        headers: {
          "u": mobNoToValidate,
          "p": "",
          "type": "patient",
        },
      );

      debugPrint("headers in login");
      debugPrint("u : $mobNoToValidate");

      debugPrint(response.body.toString());
      final jsonResponse = json.decode(response.body.toString());
      ResponseModel model = ResponseModel.fromJSON(jsonResponse);
      pr.hide();
      if (model.status == "OK") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    VerifyOTPScreen(mobNoToValidate, widget.doctorIDP)));
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    //   mobileNoController.text = '8000083323';
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/v-2-login-mobile-1.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: blueThemeColor,
        ),
        body: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(0),
                height: MediaQuery.of(context).size.height / 2,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/v-2-login-mobile-1.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: const Text('')),
            Container(
              color: blueThemeColor,
              height: MediaQuery.of(context).size.height / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          str_login,
                          style: TextStyle(fontSize: 26, color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: TextField(
                          controller: mobileNoController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: str_mobile_number,
                            hintStyle: TextStyle(fontSize: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            filled: true,
                            contentPadding: EdgeInsets.all(16),
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: SizedBox(
                          width: SizeConfig.screenWidth,
                          child: TextButton(
                              child: Text(str_login.toUpperCase(),
                                  style: TextStyle(fontSize: 18)),
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all<EdgeInsets>(
                                      EdgeInsets.all(15)),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          colorWhite),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          colorBlueDark),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0)))),
                              onPressed: () => doLogin(context)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    color: blueThemeColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                ImageIcon(
                                  AssetImage("images/v-2-arrow-back.png"),
                                  color: colorWhite,
                                  size: 24,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  str_back,
                                  style: TextStyle(
                                      color: colorWhite, fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }
}
