import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:swasthyasetu/app_screens/add_patient_screen.dart';
import 'package:swasthyasetu/app_screens/select_opd_procedures_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_opd_reg.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

import '../utils/color.dart';

List<ModelOPDRegistration> listOPDRegistration = [];
String dateText = "Today";
DateTime date = DateTime.now();

String emptyTextOPDRegistration1 = "No OPD Registration Found.";

String emptyMessage = "";

Widget? emptyMessageWidget;

class OPDRegistrationDetailsScreen extends StatefulWidget {
  String idp, patientIDP;

  OPDRegistrationDetailsScreen(this.idp, this.patientIDP);

  @override
  State<StatefulWidget> createState() {
    return OPDRegistrationDetailsScreenState();
  }
}

class OPDRegistrationDetailsScreenState
    extends State<OPDRegistrationDetailsScreen> {
  List<ModelOPDRegistration> listOPDRegistration = [];
  String paymentStatus = "0";
  var scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    emptyMessage = "$emptyTextOPDRegistration1";
    emptyMessageWidget = SizedBox(
      height: SizeConfig.blockSizeVertical !* 80,
      width: SizeConfig.blockSizeHorizontal !* 100,
      child: Container(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
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
              "$emptyMessage",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
    getOPDRegistrationDetails();
  }

  @override
  void dispose() {
    listOPDRegistration = [];
    dateText = "Today";
    date = DateTime.now();
    super.dispose();
  }

  Future<String> getOPDRegistrationDetails() async {
    listOPDRegistration = [];
    String loginUrl = "${baseURL}doctorPatientWiseOpdList.php";
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
        "HospitalConsultationIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.idp +
        "\"" +
        "," +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP +
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
      listOPDRegistration = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listOPDRegistration.add(ModelOPDRegistration(
          jo['HospitalConsultationServiceIDP'].toString(),
          jo['OPDService'],
          jo['Total'].toString(),
          "blabalabal",
          checkOutStatus: jo['CheckoutStatus'].toString(),
        ));
      }
      for (var registration in listOPDRegistration) {
        print('HospitalConsultationServiceIDP: ${registration.idp}');
        print('OPDService: ${registration.name}');
        print('Total: ${registration.amount}');
        print('PDF URL: ${registration.pdfUrl}');
        print('Check Out Status: ${registration.checkOutStatus}');
        // Add more fields as needed
        print('---'); // Separator between entries
      }

      if (listOPDRegistration.isNotEmpty && listOPDRegistration[0].paymentDueStatus != null) {
        paymentStatus = listOPDRegistration[0].paymentDueStatus!;
      }
      setState(() {});
    }
    return 'Success';
  }

  void deleteTheProcedure(
      String hospitalConsultationServiceIDP, BuildContext context) async {
    String loginUrl = "${baseURL}doctorPatientOpdListDelete.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(scaffoldKey.currentContext!);
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
        "HospitalConsultationIDF" +
        "\"" +
        ":" +
        "\"" +
        widget.idp +
        "\"" +
        "," +
        "\"" +
        "HospitalConsultationServiceIDP" +
        "\"" +
        ":" +
        "\"" +
        hospitalConsultationServiceIDP +
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
    Future.delayed(
        Duration(
          milliseconds: 500,
        ), () {
      getOPDRegistrationDetails();
    });
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      listOPDRegistration = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listOPDRegistration.add(ModelOPDRegistration(
            jo['HospitalConsultationServiceIDP'].toString(),
            jo['OPDService'],
            jo['Total'].toString(),
            "blabalabal",
          checkOutStatus: jo['CheckoutStatus'].toString(),
        ));
    }
      setState(() {});
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("OPD Procedures"),
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
      floatingActionButton: paymentStatus == "0"
          ?ListView.builder(
          itemCount: 1,
          shrinkWrap: true,
          // physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context,index) {
            return
              // Padding(
              // padding: const EdgeInsets.only(left: 300.0,right: 40.0,top: 100.0 ,bottom: 20.0),
              // child:
              Align(
                alignment: Alignment(0.7, 0.2),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => SelectOPDProceduresScreen(
                            widget.patientIDP, widget.idp, "existing")
                    )).then((value) {
                      getOPDRegistrationDetails();
                    });

                    // Navigator.of(context).pop();
                    // if(listOPDRegistration.isNotEmpty)
                    // {listOPDRegistration[index]
                    //     .checkOutStatus ==
                    //     "1"
                    //     ? showAlreadyCheckedOutDialog(
                    //     listOPDRegistration[index].idp!, context)
                    //     :
                    // Navigator.push(context, MaterialPageRoute(
                    //     builder: (context) => SelectOPDProceduresScreen(
                    //         widget.patientIDP, widget.idp, "existing")
                    // )).then((value) {
                    //   getOPDRegistrationDetails();
                    // });
                    // }
                    // else{
                    //   listOPDRegistration[index]
                    //     .checkOutStatus ==
                    //     "1"
                    //     ? showAlreadyCheckedOutDialog(
                    //     listOPDRegistration[index].idp!, context)
                    //     :
                    // Navigator.push(context, MaterialPageRoute(
                    //     builder: (context) => SelectOPDProceduresScreen(
                    //         widget.patientIDP, widget.idp, "new")
                    // )).then((value) {
                    //   getOPDRegistrationDetails();
                    // });
                    // }
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Colors.black,
                ),
              );
            // );
          }
      )
          : Container(),
      body: Container(
        color: Color(0xFFDCDCDC),
        child: Column(
          children: <Widget>[
            Expanded(
              child: listOPDRegistration.length > 0
                  ?
              ListView.builder(
                      itemCount: listOPDRegistration.length,
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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          SizeConfig.blockSizeHorizontal !* 3),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              listOPDRegistration[index].name!,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: SizeConfig
                                                          .blockSizeHorizontal !*
                                                      4,
                                                  fontWeight: FontWeight.w500),
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
                                                              .blockSizeHorizontal !*
                                                          3.5,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                )),
                                          ),
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
                              // Text(listOPDRegistration[index]
                              //     .checkOutStatus! ),
                              InkWell(
                                onTap: () {
                                  listOPDRegistration[index].amount == "0"
                                  ?
                                  listOPDRegistration[index]
                                      .checkOutStatus ==
                                      "0"
                                  ?
                                  showConfirmationDialogForDeleteOPDReg(
                                      listOPDRegistration[index].idp!, context)
                                      :showAlreadyCheckedOutDialog(
                                  listOPDRegistration[index].idp!, context)
                                  :listOPDRegistration[index]
                                      .checkOutStatus ==
                                      "0"
                                      ?
                                  showConfirmationDialogForDeleteOPDReg(
                                      listOPDRegistration[index].idp!, context)
                                      :showAlreadyCheckedOutDialog(
                                      listOPDRegistration[index].idp!, context);
                                },
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: SizeConfig.blockSizeHorizontal !* 8,
                                ),
                              )
                            ],
                          ),
                        );
                      })
                  : emptyMessageWidget!,
            ),
            // ListView.builder(
            //     itemCount: 1,
            //     shrinkWrap: true,
            //     // physics: NeverScrollableScrollPhysics(),
            //     itemBuilder: (context,index) {
            //       return
            //         // Padding(
            //         // padding: const EdgeInsets.only(left: 300.0,right: 40.0,top: 100.0 ,bottom: 20.0),
            //         // child:
            //         Align(
            //           alignment: Alignment(0.7, 0.2),
            //           child: FloatingActionButton(
            //             onPressed: () {
            //               Navigator.push(context, MaterialPageRoute(
            //                       builder: (context) => SelectOPDProceduresScreen(
            //                           widget.patientIDP, widget.idp, "existing")
            //                   )).then((value) {
            //                     getOPDRegistrationDetails();
            //                   });
            //
            //               // Navigator.of(context).pop();
            //               // if(listOPDRegistration.isNotEmpty)
            //               // {listOPDRegistration[index]
            //               //     .checkOutStatus ==
            //               //     "1"
            //               //     ? showAlreadyCheckedOutDialog(
            //               //     listOPDRegistration[index].idp!, context)
            //               //     :
            //               // Navigator.push(context, MaterialPageRoute(
            //               //     builder: (context) => SelectOPDProceduresScreen(
            //               //         widget.patientIDP, widget.idp, "existing")
            //               // )).then((value) {
            //               //   getOPDRegistrationDetails();
            //               // });
            //               // }
            //               // else{
            //               //   listOPDRegistration[index]
            //               //     .checkOutStatus ==
            //               //     "1"
            //               //     ? showAlreadyCheckedOutDialog(
            //               //     listOPDRegistration[index].idp!, context)
            //               //     :
            //               // Navigator.push(context, MaterialPageRoute(
            //               //     builder: (context) => SelectOPDProceduresScreen(
            //               //         widget.patientIDP, widget.idp, "new")
            //               // )).then((value) {
            //               //   getOPDRegistrationDetails();
            //               // });
            //               // }
            //             },
            //             child: Icon(Icons.add),
            //             backgroundColor: Colors.black,
            //           ),
            //         );
            //         // );
            //     }
            // )
          ],
        ),
      ),
    );
  }

  showConfirmationDialogForDeleteOPDReg(String idp, BuildContext context) {
    var title = "Are you sure to delete this OPD Procedure?";
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
                    deleteTheProcedure(idp, context);
                  },
                  child: Text("Yes"))
            ],
          );
        });
  }

  showAlreadyCheckedOutDialog(String idp, BuildContext context) {
    var title = "This Patient Was Checkedout. Update Not Allowed";
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
                  child: Text("OK")),
              // TextButton(
              //     onPressed: () {
              //       Navigator.pop(context);
              //     },
              //     child: Text("Yes"))
            ],
          );
        });
  }
}
