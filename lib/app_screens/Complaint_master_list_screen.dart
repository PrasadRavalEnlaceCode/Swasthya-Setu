import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:swasthyasetu/app_screens/add_edit_opd_service_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_opd_reg.dart';
import 'package:swasthyasetu/podo/model_templates_complaint.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

import '../utils/color.dart';
import 'add_consultation_screen.dart';
import 'add_edit_complaints_masters.dart';

List<Map<String, dynamic>> listComplaintDetails = <Map<String, dynamic>>[];

class ComplaintsMasterListScreen extends StatefulWidget {
  String masterName;
  int masterId;

  ComplaintsMasterListScreen(this.masterName, this.masterId);
  @override
  State<StatefulWidget> createState() {
    return ComplaintsMasterListScreenState();
  }
}

class ComplaintsMasterListScreenState extends State<ComplaintsMasterListScreen> {
  ScrollController? hideFABController;
  var isFABVisible = true;

  @override
  void initState() {
    super.initState();
    getComplaintList(context);
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
    listComplaintDetails = [];
    isFABVisible = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Complain Masters"),
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
      floatingActionButton: Visibility(
        visible: isFABVisible,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AddEditComplaintMastersScreen(
                "",
                "Add",
              );
            })).then((value) {
              //Navigator.of(context).pop();
              getComplaintList(context);
            });
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.black,
        ),
      ),
      body: Container(
        height: SizeConfig.blockSizeVertical !* 100,
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
                  child: listComplaintDetails.length > 0
                      ? ListView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: listComplaintDetails.length,
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: EdgeInsets.only(
                                left: SizeConfig.blockSizeHorizontal !* 2,
                                right: SizeConfig.blockSizeHorizontal !* 2,
                                top: SizeConfig.blockSizeHorizontal !* 2),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal !* 3),
                                        child: Row(
                                          children: <Widget>[
                                            Image(
                                              image: AssetImage(
                                                  "images/ic_opd_services_dashboard.png"),
                                              width: SizeConfig
                                                  .blockSizeHorizontal !*
                                                  4.5,
                                              height: SizeConfig
                                                  .blockSizeHorizontal !*
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
                                                  .blockSizeHorizontal !*
                                                  2,
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                listComplaintDetails[index]["ComplainName"],
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: SizeConfig
                                                        .blockSizeHorizontal !*
                                                        4,
                                                    fontWeight:
                                                    FontWeight.w500),
                                              ),
                                            ),
                                            // Expanded(
                                            //     flex: 1,
                                            //     child: Align(
                                            //       alignment: Alignment.topRight,
                                            //       child: Text(
                                            //         "${listComplaintDetails[index].amount}/-",
                                            //         style: TextStyle(
                                            //             color: Colors.green,
                                            //             fontSize: SizeConfig
                                            //                 .blockSizeHorizontal !*
                                            //                 3.5,
                                            //             fontWeight:
                                            //             FontWeight.w500),
                                            //       ),
                                            //     )),
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
                                  width: SizeConfig.blockSizeHorizontal !* 2,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(
                                            builder: (context) {
                                              return AddEditComplaintMastersScreen(
                                                listComplaintDetails[index]["ComplainMasterIDP"],
                                                "Edit",
                                                serviceName:
                                                listComplaintDetails[index]['ComplainName'],
                                              );
                                            })).then((value) {
                                      //Navigator.of(context).pop();
                                      getComplaintList(context);
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
                                        SizeConfig.blockSizeHorizontal !* 1),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: SizeConfig.blockSizeHorizontal !*
                                          6,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: SizeConfig.blockSizeHorizontal !* 2,
                                ),
                                InkWell(
                                  onTap: () {
                                    showConfirmationDialogForDeleteOPDReg(
                                        listComplaintDetails[index]["ComplainMasterIDP"],
                                        context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.redAccent,
                                    ),
                                    padding: EdgeInsets.all(
                                        SizeConfig.blockSizeHorizontal !* 1),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: SizeConfig.blockSizeHorizontal !*
                                          6,
                                    ),
                                  ),
                                )
                              ],
                            ));
                      })
                      : SizedBox(
                    height: SizeConfig.blockSizeVertical !* 80,
                    width: SizeConfig.blockSizeHorizontal !* 100,
                    child: Container(
                      padding: EdgeInsets.all(
                          SizeConfig.blockSizeHorizontal !* 5),
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
                            "No Complain Masters Found.",
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
                    deleteComplaintMaster(contextMain, idp);
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

  void getComplaintList(BuildContext context) async{
    listComplaintDetails = [];
    String loginUrl = "${baseURL}doctor_complain_list.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("#####################--------------------------------------------------------");
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
        "}";

    debugPrint(jsonStr);
    debugPrint("#####################--------------------------------------------------------");
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
      try{
        if (model.status == "OK") {
          var data = jsonResponse['Data'];
          var strData = decodeBase64(data);
          debugPrint("Decoded Complaint List: " + strData);
          final jsonData = json.decode(strData);
          for (var i = 0; i < jsonData.length; i++)
          {
            final jo = jsonData[i];
            String complainName = jo['ComplainName'].toString();
            String complainMasterIDP = jo['ComplainMasterIDP'].toString();

            // Create a Map with "ComplainName" and "ComplainIDP" pairs
            Map<String, dynamic> complaintMap = {
              "ComplainName": complainName,
              "ComplainMasterIDP": complainMasterIDP,
            };

            listComplaintDetails.add(complaintMap);
            // debugPrint("Added to list: $complainName");
          }
          setState(() {});
        }
      }catch(e){
        print("Error decoding JSON: $e");
      }else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void deleteComplaintMaster(BuildContext context, String complainMasterIDP) async {
    String loginUrl = "${baseURL}doctor_complain_submit.php";
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
    // hospitalOPDServiceIDPJson =
    //     "," + "\"" + "HospitalOPDServcesIDP" + "\"" + ":" + "\"" + idp + "\"";

    String jsonStr = "{" +
        "\"" +
        "ComplainName" +
        "\"" +
        ":" +
        "\"" +
        complaintsNameController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "ComplainMasterIDP" +
        "\"" +
        ":" +
        "\"" +
        complainMasterIDP +
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
      getComplaintList(context);
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
