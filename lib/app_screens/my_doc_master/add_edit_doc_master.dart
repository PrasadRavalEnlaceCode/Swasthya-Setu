import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/progress_dialog.dart';

import '../../global/SizeConfig.dart';

TextEditingController DropDownNameController = TextEditingController();

class AddEditDropdownMastersScreen extends StatefulWidget {
  String? idp, action, serviceName;

  AddEditDropdownMastersScreen(this.idp, this.action, {this.serviceName});

  @override
  State<AddEditDropdownMastersScreen> createState() =>
      _AddEditDropdownMastersScreenState();
}

class _AddEditDropdownMastersScreenState
    extends State<AddEditDropdownMastersScreen> {
  @override
  void initState() {
    DropDownNameController = TextEditingController(text: widget.serviceName);
    super.initState();
  }

  @override
  void dispose() {
    DropDownNameController = TextEditingController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.action} Document Category"),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(
            color: Colorsblack, size: SizeConfig.blockSizeVertical! * 2.2),
        toolbarTextStyle: TextTheme(
                titleMedium: TextStyle(
                    color: Colorsblack,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5))
            .bodyMedium,
        titleTextStyle: TextTheme(
                titleMedium: TextStyle(
                    color: Colorsblack,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5))
            .titleLarge,
      ),
      body: Builder(builder: (context) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 3),
              child: TextField(
                controller: DropDownNameController,
                style: TextStyle(color: Colors.green),
                keyboardType: TextInputType.text,
                maxLength: 50,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  labelText: "Drop-Down Name",
                  hintText: "",
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(
                      right: SizeConfig.blockSizeHorizontal! * 3,
                      bottom: SizeConfig.blockSizeHorizontal! * 3),
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal! * 12,
                    height: SizeConfig.blockSizeHorizontal! * 12,
                    child: RawMaterialButton(
                      onPressed: () {
                        submitAddEditDiagnosisMasters(context);
                      },
                      elevation: 2.0,
                      fillColor: Color(0xFF06A759),
                      child: Image(
                        width: SizeConfig.blockSizeHorizontal! * 5.5,
                        height: SizeConfig.blockSizeHorizontal! * 5.5,
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

  void submitAddEditDiagnosisMasters(BuildContext context) async {
    String loginUrl = "${baseURL}doctor_add_category_submit.php";
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
    debugPrint("---------------------");

    String DocumentCategoryIDP = widget.action == "Edit"
        ? "\"DocumentCategoryIDP\":\"${widget.idp}\""
        : "\"DocumentCategoryIDP\":\"\"";

    String jsonStr = "{" +
        "\"DoctorIDP\":\"${patientIDP}\"," +
        "$DocumentCategoryIDP," +
        "\"documentcatname\":\"${DropDownNameController.text.trim()}\"," +
        "\"DeleteFlag\":\"0\"" +
        "}";

    // {"DoctorIDP":"1","DocumentCategoryIDP":"",
    // "documentcatname":"admin data","DeleteFlag":"0"}

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
