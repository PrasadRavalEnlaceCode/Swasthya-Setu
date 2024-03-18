import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging_platform_interface/src/remote_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swasthyasetu/app_screens/apply_couponcode_or_pay_screen.dart';
import 'package:swasthyasetu/app_screens/patient_dashboard_screen.dart';
import 'package:swasthyasetu/enums/expiry_state.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/services/push_notification_service.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

import '../main.dart';

class CheckExpiryBlankScreen extends StatefulWidget {
  final String? doctorIDP, from;
  PushNotificationService? _pushNotificationService;
  bool? fromLaunch;
  RemoteMessage? messageData;

  CheckExpiryBlankScreen(
      this.doctorIDP, this.from, this.fromLaunch, this.messageData);

  @override
  State<StatefulWidget> createState() {
    return CheckExpiryBlankScreenState();
  }
}

class CheckExpiryBlankScreenState extends State<CheckExpiryBlankScreen> {
  ExpiryState expiryState = ExpiryState.Loading;

  @override
  void initState()
  {
    super.initState();
    widget._pushNotificationService = getItLocator<PushNotificationService>();
    widget._pushNotificationService!.fromLaunch = widget.fromLaunch!;
    widget._pushNotificationService!.messageData = widget.messageData;
    getExpiryDetails(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: new Icon(
                Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
                color: Colors.black),
            onPressed: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            }),
        iconTheme: IconThemeData(
          color: Colors.black,
          size: SizeConfig.blockSizeVertical !* 3.0,
        ),
        elevation: 0, toolbarTextStyle: TextTheme(
          titleMedium: TextStyle(
              color: Colors.white,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.3),
        ).bodyMedium, titleTextStyle: TextTheme(
          titleMedium: TextStyle(
              color: Colors.white,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.3),
        ).titleLarge,
      ),
      body: SafeArea(
          child: Center(
        child: Container(
          padding: EdgeInsets.all(
            SizeConfig.blockSizeHorizontal !* 5.0,
          ),
          color: Colors.white,
          child: getCorrespondingWidget(),
        ),
      )),
    );
  }

  void getExpiryDetails(BuildContext context) async {
    String loginUrl = "${baseURL}patientExpiryCheck.php";
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
    String jsonStr =
        "{" + "\"" + "PatientIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

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
      expiryState = ExpiryState.Valid;
      /*setState(() {});*/
      if (widget.from == "main") {
        if (!widget._pushNotificationService!.fromLaunch)
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => PatientDashboardScreen(widget.doctorIDP!)),
              (Route<dynamic> route) => false);
        else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => PatientDashboardScreen(widget.doctorIDP!)),
              (Route<dynamic> route) => false);
          widget._pushNotificationService!.onMessageOpened(
            widget._pushNotificationService!.messageData!,
          );
          widget._pushNotificationService!.fromLaunch = false;
        }
      }
    } else if (model.status == "EXPIRE") {
      expiryState = ExpiryState.Expired;
      setState(() {});
    } else if (model.status == "PAYMENT") {
      expiryState = ExpiryState.NotPaid;
      setState(() {});
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

  Widget getCorrespondingWidget() {
    if (expiryState == ExpiryState.Loading) return Text("Loading...");
    if (expiryState == ExpiryState.Expired)
      return Column(
        children: [
          Image(
            width: SizeConfig.blockSizeHorizontal !* 20,
            height: SizeConfig.blockSizeHorizontal !* 20,
            //height: 80,
            image: AssetImage("images/swasthya_setu_logo.jpeg"),
          ),
          SizedBox(
            height: SizeConfig.blockSizeVertical !* 2.0,
          ),
          Text(
            "Your Swasthya Setu subscription is expired, kindly proceed for Renewal.",
            softWrap: true,
            style: TextStyle(
              color: Colors.red,
              fontSize: SizeConfig.blockSizeHorizontal !* 5.0,
              letterSpacing: 1.0,
              height: 1.6,
            ),
          ),
          SizedBox(
            height: SizeConfig.blockSizeVertical !* 2.0,
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ApplyCouponCodeOrPayScreen("")),
                  (Route<dynamic> route) => false);
            },
            color: Colors.blue,
            child: Text(
              "Proceed",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      );
    if (expiryState == ExpiryState.NotPaid)
      return Column(
        children: [
          Image(
            width: SizeConfig.blockSizeHorizontal !* 20,
            height: SizeConfig.blockSizeHorizontal !* 20,
            //height: 80,
            image: AssetImage("images/swasthya_setu_logo.jpeg"),
          ),
          SizedBox(
            height: SizeConfig.blockSizeVertical !* 2.0,
          ),
          /*Text(
            "Kindly proceed to pay \u20B9118 (including GST), to continue the subscription",
            softWrap: true,
            style: TextStyle(
              color: Colors.red,
              fontSize: SizeConfig.blockSizeHorizontal * 5.0,
              letterSpacing: 1.0,
              height: 1.6,
            ),
          ),*/
          Text(
            "Kindly proceed to pay",
            softWrap: true,
            style: TextStyle(
              color: Colors.red,
              fontSize: SizeConfig.blockSizeHorizontal !* 5.0,
              letterSpacing: 1.0,
              height: 1.6,
            ),
          ),
          Text(
            "\u20B9118 (including GST)",
            softWrap: true,
            style: TextStyle(
              color: Colors.red,
              fontSize: SizeConfig.blockSizeHorizontal !* 5.0,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
          Text(
            "to continue the subscription",
            softWrap: true,
            style: TextStyle(
              color: Colors.red,
              fontSize: SizeConfig.blockSizeHorizontal !* 5.0,
              letterSpacing: 1.0,
              height: 1.6,
            ),
          ),
          SizedBox(
            height: SizeConfig.blockSizeVertical !* 2.0,
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ApplyCouponCodeOrPayScreen("")),
                  (Route<dynamic> route) => false);
            },
            color: Colors.blue,
            child: Text(
              "Proceed",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      );
    if (expiryState == ExpiryState.Valid)
      return Column(
        children: [
          Image(
            width: SizeConfig.blockSizeHorizontal !* 20,
            height: SizeConfig.blockSizeHorizontal !* 20,
            //height: 80,
            image: AssetImage("images/swasthya_setu_logo.jpeg"),
          ),
          Text(
            "Welcome to Swasthya Setu",
            softWrap: true,
            style: TextStyle(
              color: Colors.green,
              fontSize: SizeConfig.blockSizeHorizontal !* 5.0,
              letterSpacing: 1.0,
              height: 1.6,
            ),
          ),
          SizedBox(
            height: SizeConfig.blockSizeVertical !* 2.0,
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PatientDashboardScreen(widget.doctorIDP!)),
                  (Route<dynamic> route) => false);
            },
            color: Colors.blue,
            child: Text(
              "Go to Dashboard",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      );
    return Container();
  }
}
