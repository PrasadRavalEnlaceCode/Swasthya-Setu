import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';

import '../utils/color.dart';
import '../utils/progress_dialog.dart';

TextEditingController serviceNameController = TextEditingController();
TextEditingController serviceAmountController = TextEditingController();

class AddEditOPDServiceScreen extends StatefulWidget {
  String? idp, action, serviceName, serviceAmount;

  AddEditOPDServiceScreen(this.idp, this.action,
      {this.serviceName,this.serviceAmount});

  @override
  State<StatefulWidget> createState() {
    return AddEditOPDServiceScreenState();
  }
}

class AddEditOPDServiceScreenState extends State<AddEditOPDServiceScreen> {
  @override
  void initState() {
    super.initState();
    serviceNameController = TextEditingController(text: widget.serviceName);
    serviceAmountController = TextEditingController(text: widget.serviceAmount);
  }

  @override
  void dispose() {
    serviceNameController = TextEditingController();
    serviceAmountController = TextEditingController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.action} Service"),
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
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
              child: TextField(
                controller: serviceNameController,
                style: TextStyle(color: Colors.green),
                keyboardType: TextInputType.text,
                maxLength: 50,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  labelText: "Service Name",
                  hintText: "",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
              child: TextField(
                controller: serviceAmountController,
                style: TextStyle(color: Colors.green),
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  labelText: "Price",
                  hintText: "",
                ),
              ),
            ),
            Expanded(
              child: Align(
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
                        submitAddEditOPDService(context);
                        /*mobNo = mobileNoController.text;
                    doLogin(mContext);*/
                        /*Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => doLogin(mContext)));*/
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
                  ),
                ),
              ),
            )
          ],
        );
      }),
    );
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

  void submitAddEditOPDService(BuildContext context) async {
    String loginUrl = "${baseURL}doctorOpdServiceUpdate.php";
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
    String hospitalOPDServiceIDPJson = "";
    if (widget.action == "Edit") {
      hospitalOPDServiceIDPJson = "," +
          "\"" +
          "HospitalOPDServcesIDP" +
          "\"" +
          ":" +
          "\"" +
          widget.idp! +
          "\"";
    } else {
      hospitalOPDServiceIDPJson =
          "," + "\"" + "HospitalOPDServcesIDP" + "\"" + ":" + "\"" + "\"";
    }
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
        "ServiceName" +
        "\"" +
        ":" +
        "\"" +
        serviceNameController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "ServicePrice" +
        "\"" +
        ":" +
        "\"" +
        serviceAmountController.text.trim() +
        "\"" +
        hospitalOPDServiceIDPJson +
        "," +
        "\"" +
        "DeleteFlag" +
        "\"" +
        ":" +
        "\"" +
        "0" +
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
}
