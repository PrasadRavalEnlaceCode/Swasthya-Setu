import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swasthyasetu/api/api_helper.dart';
import 'package:swasthyasetu/app_screens/check_expiry_blank_screen.dart';
import 'package:swasthyasetu/app_screens/select_profile_screen.dart';
import 'package:swasthyasetu/utils/color.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:swasthyasetu/app_screens/fill_profile_details.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/sms_listener.dart';

final focus = FocusNode();

class VerifyOTPScreen extends StatefulWidget {
  var mobNo;
  String doctorIDP;

  VerifyOTPScreen(mobNo, this.doctorIDP) {
    this.mobNo = mobNo;
  }

  @override
  State<StatefulWidget> createState() {
    return VerifyOTPScreenState();
  }

//}

/*String encodeBase64(String text) {
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
  }*/
}

class VerifyOTPScreenState extends State<VerifyOTPScreen> {
  TextEditingController mobileNoController = new TextEditingController();
  String _code = "";
  SMSListener? smsListener;
  ApiHelper apiHelper = ApiHelper();

  @override
  void initState() {
    super.initState();
    /*smsListener = SMSListener(onCodeUpdated);
    smsListener.listenForCode();*/
    //await SmsAutoFill().listenForCode();
    listenToTheOTPCode();
  }

  onCodeUpdated() {
    _code = smsListener!.code!;
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("OTP is : $_code"),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Yes"))
            ],
          );
        });
    setState(() {});
  }

  @override
  void dispose() {
    /*smsListener.cancel();
    smsListener.unregisterListener();*/
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: blueThemeColor,
      ),
      /*key: navigatorKey,*/
      body: Center(child: Builder(builder: (BuildContext mContext) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              width: SizeConfig.blockSizeHorizontal !* 30,
              //height: 80,
              image: AssetImage("images/swasthya_setu_logo.jpeg"),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical !* 3,
            ),
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: SizeConfig.blockSizeHorizontal !* 10),
                  child: Text("Enter OTP received on your Mobile No.",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.green,
                      )),
                )),
            Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: SizeConfig.blockSizeHorizontal !* 75,
                    height: SizeConfig.blockSizeHorizontal !* 20,
                    padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
                    child: PinFieldAutoFill(
                      decoration: UnderlineDecoration(
                          colorBuilder: FixedColorBuilder(Colors.black),
                          textStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          )),
                      currentCode: _code,
                      codeLength: 4,
                      onCodeSubmitted: (code) {
                        print("Code submitted - $code");
                        verifyOTP(mContext);
                      },
                      onCodeChanged: (code) {
                        setState(() {
                          _code = code!;
                        });
                        print("Code got - $code");
                        if (code!.length == 4) {
                          verifyOTP(mContext);
                        } else if (code.length == 5) {
                          FocusScope.of(context).requestFocus(FocusNode());
                        }
                      },
                    ),
                    /*TextField(
                      controller: mobileNoController,
                      style: TextStyle(color: Colors.green),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black),
                        labelStyle: TextStyle(color: Colors.black),
                        labelText: "OTP",
                        hintText: "",
                      ),
                    ),*/
                  ),
                  Container(
                    width: SizeConfig.blockSizeHorizontal !* 12,
                    height: SizeConfig.blockSizeHorizontal !* 12,
                    child: RawMaterialButton(
                      onPressed: () {
                        verifyOTP(mContext);
                        /*Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PatientDashboardScreen()));*/
                      },
                      elevation: 2.0,
                      fillColor: Color(0xFF06A759),
                      child: Image(
                        width: SizeConfig.blockSizeHorizontal !* 5.5,
                        height: SizeConfig.blockSizeHorizontal !* 5.5,
                        //height: 80,
                        image:
                            AssetImage("images/ic_right_arrow_triangular.png"),
                      ),
                      shape: CircleBorder(),
                    ),
                  )
                ]),
            SizedBox(
              height: 15,
            ),
            InkWell(
              onTap: () => resendOTP(mContext),
              child: Text(
                "Click here to resend OTP",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff058a8f),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      })),
    );
  }

  //void doLogin() {
  /*Future<Post> fetchPost() async {
      final response = await http.get(
        'https://jsonplaceholder.typicode.com/posts/1',
        headers: {HttpHeaders.authorizationHeader: "Basic your_api_token_here"},
      );
      final responseJson = json.decode(response.body);

      return Post.fromJson(responseJson);
    }*/

  //List listData;

  void verifyOTP(BuildContext mContext) async {
    String loginUrl = "${baseURL}login.php";
    if (_code.length < 0) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please enter OTP"),
      );
      ScaffoldMessenger.of(mContext).showSnackBar(snackBar);
    } else {
      ProgressDialog pr = ProgressDialog(mContext);
      pr.show();
      //listIcon = new List();
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: loginUrl,
        headers:
        {
          "u": widget.mobNo,
          "p": _code,
          "type": "patient",
        },
      );
      debugPrint("headers in verify otp");
      debugPrint("u : ${widget.mobNo}");
      debugPrint("p : $_code");

      /*http.post(
        Uri.encodeFull(loginUrl),
        //Uri.parse(loginUrl),
        headers: {
          "u": widget.mobNo,
          "p": _code,
          "type": "patient",
        },
      );*/
      //var resBody = json.decode(response.body);
      debugPrint(response.body.toString());
      final jsonResponse = json.decode(response.body.toString());
      ResponseModel model = ResponseModel.fromJSON(jsonResponse);
      pr.hide();
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array : " + strData);
        final jsonData = json.decode(strData);
        if (jsonData.length > 1) {
          await Get.to(SelectProfileScreen(json: jsonData))!.then((index) {
            setUserDetails(data);
            generateSelectedProfile(mContext, jsonData[index]);
          });
          //
        } else {
          generateSelectedProfile(mContext, jsonData[0]);
        }
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(mContext).showSnackBar(snackBar);
      }
    }
  }

  void resendOTP(BuildContext mContext) async {
    String loginUrl = "${baseURL}login.php";
    ProgressDialog pr = ProgressDialog(mContext);
    pr.show();
    //listIcon = new List();
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: loginUrl,
      headers: {
        "u": widget.mobNo,
        "p": "",
        "type": "patient",
      },
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
      ScaffoldMessenger.of(mContext).showSnackBar(snackBar);
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
      ScaffoldMessenger.of(mContext).showSnackBar(snackBar);
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

  void listenToTheOTPCode() async {
    await SmsAutoFill().listenForCode;
    /*var sign = await SmsAutoFill().getAppSignature;
    print("Signature :-");
    print(sign);*/
    /*String loginUrl = "${baseURL}keyvalueupdate.php";

    String jsonStr = "{" +
        "\"" +
        "keyvalue" +
        "\"" +
        ":" +
        "\"" +
        sign +
        "\"" +
        "}";

    String encodedJSONStr = encodeBase64(jsonStr);

    var response = await http.post(
      Uri.encodeFull(loginUrl),
      //Uri.parse(loginUrl),
      headers: {
        "u": widget.mobNo,
        "p": _code,
        "type": "patient",
      },
      body: {"getjson": encodedJSONStr},
    );
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());*/
  }

  void generateSelectedProfile(mContext, jsonData) {
    var patientIDP = jsonData['PatientIDP'];
    var patientUniqueKey = decodeBase64(jsonData['PatientUniqueKey']);
    var middleName = jsonData['MiddleName'].toString();
    var isPayment =
        jsonData['RequiredPayment'].toString() == "1" ? true : false;
    if (jsonData["FirtLoginStatus"] == "0") {
      setUserName(jsonData['FirstName'].toString().trim() +
          " " +
          middleName.trim() +
          " " +
          jsonData['LastName'].toString().trim());
      setEmail(jsonData['EmailID']);
      setPatientID(jsonData['PatientID']);
      setMobNo(widget.mobNo);
      setPatientIDP(patientIDP);
      setPatientUniqueKey(patientUniqueKey);
      setUserType("patient");
      Navigator.pushReplacement(
          mContext,
          MaterialPageRoute(
              builder: (context) => CheckExpiryBlankScreen(
                  widget.doctorIDP, "main", false, null)));
    } else {
      setPatientID(jsonData['PatientID']);
      setPatientIDP(patientIDP);
      setPatientUniqueKey(patientUniqueKey);
      setMobNo(widget.mobNo);
      Navigator.pushReplacement(
          mContext,
          MaterialPageRoute(
              builder: (context) =>
                  FillProfileDetails(widget.doctorIDP, isPayment)));
    }
  }
}
