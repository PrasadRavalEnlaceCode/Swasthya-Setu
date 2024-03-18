import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import '../utils/color.dart';

class MyQRCodeScreen extends StatefulWidget {
  String imgUrl;

  MyQRCodeScreen(this.imgUrl);

  @override
  State<StatefulWidget> createState() {
    return MyQRCodeScreenState();
  }
}

class MyQRCodeScreenState extends State<MyQRCodeScreen> {
  @override
  void initState() {
    super.initState();
    getQRCodeForDoctor();
    widget.imgUrl = "";
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("My QR"),
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Visibility(
            visible: widget.imgUrl != "",
            child: Align(
              alignment: Alignment.center,
              child: Image.network(
                widget.imgUrl,
                width: SizeConfig.blockSizeHorizontal! * 80,
                height: SizeConfig.blockSizeHorizontal! * 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            "QR code contains patient-id\nShow this QR code to doctor to access your records.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey,
                fontSize: SizeConfig.blockSizeHorizontal! * 3.5),
          ),
          /*Visibility(
            visible: widget.imgUrl == "",
            child: Container(
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                    "Loading...",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  void getQRCodeForDoctor() async {
    String loginUrl = "${baseURL}patientQR.php";
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
      /*var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      final jsonData = json.decode(strData);*/
      widget.imgUrl = "${baseImagePath}images/patientQR/$patientIDP.png";
      setState(() {});
    } else {
      widget.imgUrl = "";
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
}
