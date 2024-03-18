import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:silvertouch/app_screens/add_edit_opd_service_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/model_opd_reg.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import '../utils/color.dart';

List<ModelOPDRegistration> listOPDRegistration = [];

class OPDServiceListScreen extends StatefulWidget {
  /*String patientIDP;

  OPDServiceListScreen(this.patientIDP);*/

  @override
  State<StatefulWidget> createState() {
    return OPDServiceListScreenState();
  }
}

class OPDServiceListScreenState extends State<OPDServiceListScreen> {
  ScrollController? hideFABController;
  var isFABVisible = true;

  @override
  void initState() {
    super.initState();
    listOPDRegistration = [];
    hideFABController = ScrollController();
    hideFABController!.addListener(() {
      if (hideFABController!.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (isFABVisible == true) {
          /* only set when the previous state is false
             * Less widget rebuilds
             */
          print("**** $isFABVisible up"); //Move IO away from setState
          setState(() {
            isFABVisible = false;
          });
        }
      } else {
        if (hideFABController!.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (isFABVisible == false) {
            print("**** ${isFABVisible} down"); //Move IO away from setState
            setState(() {
              isFABVisible = true;
            });
          }
        }
      }
    });
    getOPDRegistrationDetails();
  }

  @override
  void dispose() {
    listOPDRegistration = [];
    isFABVisible = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("OPD Services"),
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
      floatingActionButton: Visibility(
        visible: isFABVisible,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AddEditOPDServiceScreen(
                "",
                "Add",
              );
            })).then((value) {
              //Navigator.of(context).pop();
              getOPDRegistrationDetails();
            });
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.black,
        ),
      ),
      body: Container(
        height: SizeConfig.blockSizeVertical! * 100,
        color: Color(0xFFDCDCDC),
        child: ListView(
          shrinkWrap: true,
          controller: hideFABController,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  fit: FlexFit.loose,
                  child: listOPDRegistration.length > 0
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: listOPDRegistration.length,
                          itemBuilder: (context, index) {
                            return Padding(
                                padding: EdgeInsets.only(
                                    left: SizeConfig.blockSizeHorizontal! * 2,
                                    right: SizeConfig.blockSizeHorizontal! * 2,
                                    top: SizeConfig.blockSizeHorizontal! * 2),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Card(
                                          child: Padding(
                                        padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal! *
                                                3),
                                        child: Row(
                                          children: <Widget>[
                                            Image(
                                              image: AssetImage(
                                                  "images/ic_opd_services_dashboard.png"),
                                              width: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  4.5,
                                              height: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  4.5,
                                            ),
                                            /*Icon(
                                              Icons.settings,
                                              color: Colors.grey,
                                              size: SizeConfig
                                                      .blockSizeHorizontal *
                                                  4.5,
                                            ),*/
                                            SizedBox(
                                              width: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  2,
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                listOPDRegistration[index]
                                                    .name!,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        4,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 1,
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text(
                                                    "${listOPDRegistration[index].amount}/-",
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            3.5,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                )),
                                            /*SizedBox(
                                    width: SizeConfig.blockSizeHorizontal * 3,
                                  ),
                                  InkWell(
                                    child: Image(
                                      image:
                                      AssetImage("images/ic_pdf_opd_reg.png"),
                                      width: SizeConfig.blockSizeHorizontal * 8,
                                    ),
                                  )*/
                                          ],
                                        ),
                                      )),
                                    ),
                                    SizedBox(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 2,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return AddEditOPDServiceScreen(
                                            listOPDRegistration[index].idp,
                                            "Edit",
                                            serviceName:
                                                listOPDRegistration[index].name,
                                            serviceAmount:
                                                listOPDRegistration[index]
                                                    .amount,
                                          );
                                        })).then((value) {
                                          //Navigator.of(context).pop();
                                          getOPDRegistrationDetails();
                                        });
                                        /*editTheProcedure(
                                        listOPDRegistration[index].idp,
                                        context);*/
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal! *
                                                1),
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size:
                                              SizeConfig.blockSizeHorizontal! *
                                                  6,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 2,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        showConfirmationDialogForDeleteOPDReg(
                                            listOPDRegistration[index].idp!,
                                            context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.redAccent,
                                        ),
                                        padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal! *
                                                1),
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size:
                                              SizeConfig.blockSizeHorizontal! *
                                                  6,
                                        ),
                                      ),
                                    )
                                  ],
                                ));
                          })
                      : SizedBox(
                          height: SizeConfig.blockSizeVertical! * 80,
                          width: SizeConfig.blockSizeHorizontal! * 100,
                          child: Container(
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 5),
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
                                  "No OPD Procedures Found.",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  showConfirmationDialogForDeleteOPDReg(String idp, BuildContext contextMain) {
    var title = "Are you sure to delete this OPD Service?";
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    deleteOPDService(contextMain, idp);
                  },
                  child: Text("Yes"))
            ],
          );
        });
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

  void getOPDRegistrationDetails() async {
    listOPDRegistration = [];
    String loginUrl = "${baseURL}doctorOpdServiceList.php";
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
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
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
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listOPDRegistration.add(ModelOPDRegistration(
            jo['HospitalOPDServcesIDP'].toString(),
            jo['OPDService'],
            jo['Price'].toString(),
            "",
            amountBeforeDiscount: jo['Price'].toString(),
            discount: "0"));
      }
      setState(() {});
    }
  }

  void deleteOPDService(BuildContext context, String idp) async {
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
    hospitalOPDServiceIDPJson =
        "," + "\"" + "HospitalOPDServcesIDP" + "\"" + ":" + "\"" + idp + "\"";
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
        "1" +
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
      /*final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
      getOPDRegistrationDetails();
      /*Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });*/
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
