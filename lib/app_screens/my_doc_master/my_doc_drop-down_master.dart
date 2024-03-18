import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:silvertouch/app_screens/my_doc_master/add_edit_doc_master.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/progress_dialog.dart';

import '../investigations_list_for_doctors_patient.dart';

List<Map<String, dynamic>> listDropDownDetails = <Map<String, dynamic>>[];

class MyDocumentDropDownMasterListScreen extends StatefulWidget {
  String masterName;
  int masterId;

  MyDocumentDropDownMasterListScreen(this.masterName, this.masterId);
  @override
  State<StatefulWidget> createState() {
    return MyDocumentDropDownMasterListScreenState();
  }
}

class MyDocumentDropDownMasterListScreenState
    extends State<MyDocumentDropDownMasterListScreen> {
  ScrollController? hideFABController;
  var isFABVisible = true;

  @override
  void initState() {
    super.initState();
    getDropDownMasterList(context);
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
  }

  @override
  void dispose() {
    // listDiagnosisDetails = [];
    isFABVisible = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Document Category"),
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
              return AddEditDropdownMastersScreen(
                "",
                "Add",
              );
            })).then((value) {
              //Navigator.of(context).pop();
              getDropDownMasterList(context);
            });
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.black,
        ),
      ),
      // body: Container(),
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
                  child: listDropDownDetails.length > 0
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: listDropDownDetails.length,
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
                                                listDropDownDetails[index]
                                                    ["Category"],
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        4,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                    ),
                                    SizedBox(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 2,
                                    ),
                                    Visibility(
                                      visible: listDropDownDetails[index]
                                              ["SystemData"] !=
                                          "System Provided",
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return AddEditDropdownMastersScreen(
                                              listDropDownDetails[index]
                                                  ["DocumentCategoryIDP"],
                                              "Edit",
                                              serviceName:
                                                  listDropDownDetails[index]
                                                      ['Category'],
                                            );
                                          })).then((value) {
                                            //Navigator.of(context).pop();
                                            getDropDownMasterList(context);
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
                                            size: SizeConfig
                                                    .blockSizeHorizontal! *
                                                6,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 2,
                                    ),
                                    Visibility(
                                      visible: listDropDownDetails[index]
                                              ["SystemData"] !=
                                          "System Provided",
                                      child: InkWell(
                                        onTap: () {
                                          showConfirmationDialogForDeleteDiagnosisMaster(
                                              listDropDownDetails[index]
                                                  ["DocumentCategoryIDP"],
                                              listDropDownDetails[index]
                                                  ['Category'],
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
                                            size: SizeConfig
                                                    .blockSizeHorizontal! *
                                                6,
                                          ),
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
                                  "No Diagnosis Masters Found.",
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

  showConfirmationDialogForDeleteDiagnosisMaster(
      String idp, documentcatname, BuildContext contextMain) {
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
                    deleteDropDownMaster(contextMain, idp, documentcatname);
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

  void getDropDownMasterList(BuildContext context) async {
    listDropDownDetails = [];
    String loginUrl = "${baseURL}doctor_category_document_list.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("#####################------");
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

    debugPrint(jsonStr);
    debugPrint("#####################---------------");
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

    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr?.hide();
    if (response.statusCode == 200)
      try {
        if (model.status == "OK") {
          var data = jsonResponse['Data'];
          var strData = decodeBase64(data);
          debugPrint("Decoded Diagnosis List: " + strData);
          final jsonData = json.decode(strData);
          for (var i = 0; i < jsonData.length; i++) {
            final jo = jsonData[i];
            String Category = jo['Category'].toString();
            String DocumentCategoryIDP = jo['DocumentCategoryIDP'].toString();
            String SystemData = jo['SystemData'].toString();

            // Create a Map with "ComplainName" and "ComplainIDP" pairs
            Map<String, dynamic> diagnosisMap = {
              "Category": Category,
              "DocumentCategoryIDP": DocumentCategoryIDP,
              "SystemData": SystemData,
            };

            listDropDownDetails.add(diagnosisMap);
            // {"DocumentCategoryIDP":4,"Category":"10th MarkSheet",
            // "DoctorIDF":null,"OrganizationIDF":null,
            // "SystemData":"System Provided"}
          }
          setState(() {});
        }
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void deleteDropDownMaster(
      BuildContext context, String documentCategoryIDP, documentcatname) async {
    String loginUrl = "${baseURL}doctor_add_category_submit.php";
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
    // String hospitalOPDServiceIDPJson = "";
    // {"DoctorIDP":"1","DocumentCategoryIDP":"",
    // "documentcatname":"admin data","DeleteFlag":"0"}

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
        "DocumentCategoryIDP" +
        "\"" +
        ":" +
        "\"" +
        documentCategoryIDP +
        "\"" +
        "," +
        "\"" +
        "documentcatname" +
        "\"" +
        ":" +
        "\"" +
        documentcatname +
        "\"" +
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
      getDropDownMasterList(context);
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
