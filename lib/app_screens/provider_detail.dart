import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:swasthyasetu/app_screens/provider_order_screen.dart';
import 'package:swasthyasetu/app_screens/report_patient_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_report.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/color.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:swasthyasetu/widgets/extensions.dart';
import 'package:url_launcher/url_launcher.dart';


class ProviderDetailsScreen extends StatefulWidget {
  Map<String, String>? doctorData;
  String? patientIDP, from;

  ProviderDetailsScreen(this.doctorData, this.patientIDP);

  @override
  State<StatefulWidget> createState() {
    return ProviderDetailsScreenState();
  }
}

class ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  final String urlFetchDoctorProfileDetails = "${baseURL}providerIDP.php";
  String clinicName = "",
      clinicAddress = "",
      clinicPincode = "",
      clinicArea = "",
      clinicContactNumber = "",
      contactPersonName = "",
      emailID = "";

  @override
  void initState() {
    super.initState();
    print('doctorData ${widget.doctorData}');
    getDoctorProfileDetails(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Color(0xFFf9faff),
      appBar: AppBar(
        title: Text("Detail", style: TextStyle(color: Colorsblack)),
        iconTheme: IconThemeData(
            color: Colorsblack, size: SizeConfig.blockSizeVertical !* 2.5),
        backgroundColor: Color(0xFFf9faff),
        elevation: 0,
        centerTitle: true,
      ),
      body: Builder(builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 1.0,
                  ),
                ],
                color: colorWhite,
                borderRadius: BorderRadius.all(Radius.circular(
                    20.0) //                 <--- border radius here
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      isImageNotNullAndBlank() ?
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                              "$doctorImgUrl${widget.doctorData!["ProviderLogo"]}"),
                          radius: 50,
                        ) :
                      CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.storefront_sharp,size: 60,),
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal !* 3,
                      ),
                      Expanded(
                        child: Text(
                          (widget.doctorData!["DisplayName"]!.trim()),
                          maxLines: 3,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal !* 4.2,
                            fontWeight: FontWeight.w500,
                            color: colorBlueDark,
                          ),
                        ),
                      ),
                    ],
                  ).expanded(),
                ],
              ),
            ).pS(
              horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
              vertical: SizeConfig.blockSizeHorizontal !* 4.0,
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius: BorderRadius.all(Radius.circular(
                    10.0) //                 <--- border radius here
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Provider Details",
                    style: TextStyle(
                      color: Colorsblack,
                      fontSize: SizeConfig.blockSizeHorizontal !* 5.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    (widget.doctorData!["ProviderCompanyName"]!.trim()),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal !* 4.2,
                      fontWeight: FontWeight.w400,
                      color: Colorsblack,
                    ),
                  ),
                  new Divider(
                    thickness: 2,
                    color: Color(0xfff0f0f0),
                  ),
                  Text(
                    "Area",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    clinicArea,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
                    ),
                  ),
                  new Divider(
                    thickness: 2,
                    color: Color(0xfff0f0f0),
                  ),
                  Text(
                    "Address",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    clinicAddress,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
                    ),
                  ),
                  new Divider(
                    thickness: 2,
                    color: Color(0xfff0f0f0),
                  ),
                  Text(
                    "Phone",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  InkWell(
                      onTap: () {
                        launchURL('tel:91$clinicContactNumber');
                      },
                      child: Text(
                        clinicContactNumber,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
                        ),
                      )),
                  new Divider(
                    thickness: 2,
                    color: Color(0xfff0f0f0),
                  ),
                  contactPersonName != ""
                      ? Text(
                    "Contact Person Name",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                    ),
                  )
                      : Container(),
                  contactPersonName != ""
                      ? SizedBox(
                    height: 5,
                  )
                      : Container(),
                  contactPersonName != ""
                      ? InkWell(
                      onTap: () async {
                        if (await canLaunch(
                            "whatsapp://send?phone=91$contactPersonName&text=")) {
                          launchURL(
                              "whatsapp://send?phone=91$contactPersonName&text=");
                        } else {
                          Fluttertoast.showToast(
                              msg: "You need to Install Whatsapp!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 3,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            contactPersonName,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize:
                              SizeConfig.blockSizeHorizontal !* 3.8,
                            ),
                          ),
                        ],
                      ))
                      : Container(),
                  contactPersonName != ""
                      ? new Divider(
                    thickness: 2,
                    color: Color(0xfff0f0f0),
                  )
                      : Container(),
                  Text(
                    "Email",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  InkWell(
                      onTap: () {
                        launchURL('mailto:$emailID?subject=&body=');
                      },
                      child: Text(
                        emailID,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
                        ),
                      )),
                ],
              ),
            ).pS(
              horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
              vertical: SizeConfig.blockSizeHorizontal !* 4.0,
            ),
            Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // String patientIDP =
                          // widget.doctorData['DoctorIDP'];
                          // String patientName =
                          //     widget.doctorData['FirstName'].trim() +
                          //         " " +
                          //         widget.doctorData['LastName'].trim();
                          // String doctorImage =
                          //     "$doctorImgUrl${widget.doctorData["DoctorImage"]}";
                          // Get.to(() => ChatScreen(
                          //   patientIDP: patientIDP,
                          //   patientName: patientName,
                          //   patientImage: doctorImage,
                          //   heroTag:
                          //   "selectedDoctor_${widget.doctorData['DoctorIDP']}",
                          // ));
                        },
                        child: Card(
                          elevation: 0,
                          shadowColor: Colors.grey,
                          color: colorBlueDark,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      10.0) //                 <--- border radius here
                              ),
                              side: BorderSide(
                                  color: colorBlueDark, width: 1.5)),
                          margin: EdgeInsets.only(
                            left: SizeConfig.blockSizeHorizontal !* 3.0,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 3.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.messenger_outline,size: 25,color: white,),
                                SizedBox(
                                  width: SizeConfig.blockSizeHorizontal !*
                                      4.0,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Chat with",
                                        style: TextStyle(
                                            fontSize: SizeConfig
                                                .blockSizeHorizontal !*
                                                4.2,
                                            fontWeight: FontWeight.w400,
                                            color: colorWhite),
                                      ),
                                      SizedBox(
                                        height:
                                        SizeConfig.blockSizeVertical !*
                                            0.4,
                                      ),
                                      Text(
                                        "Provider",
                                        style: TextStyle(
                                            fontSize: SizeConfig
                                                .blockSizeHorizontal !*
                                                4.2,
                                            fontWeight: FontWeight.w700,
                                            color: colorWhite),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal !* 2.0,
                    ),
                    // Expanded(
                    //   child: InkWell(
                    //     onTap: () async {
                    //       Get.to(() => PatientReportScreen(
                    //         widget.patientIDP!,"prescription_fixed",true
                    //       ))!.then((modelReport)
                    //       {
                    //         print('fetchPrescriptionId $modelReport');
                    //         ModelReport modelReport1 = modelReport;
                    //         print('modelReport1 '
                    //             '${modelReport1.patientReportIDP},'
                    //             '${modelReport1.reportTagName},'
                    //             '${modelReport1.reportDate},'
                    //             '${modelReport1.reportTime},'
                    //             '${modelReport1.reportImage},');
                    //         confirmPrescription(modelReport1.patientReportIDP,modelReport1.reportTagName,
                    //             modelReport1.reportDate,modelReport1.reportTime,modelReport1.reportImage);
                    //       });
                    //     },
                    //     child:
                    //     Card(
                    //       elevation: 0,
                    //       shadowColor: Colors.grey,
                    //       color: colorBlueDark,
                    //       shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.all(
                    //               Radius.circular(
                    //                   10.0) //                 <--- border radius here
                    //           ),
                    //           side: BorderSide(
                    //               color: colorBlueDark, width: 1.5)),
                    //       margin: EdgeInsets.only(
                    //         left: SizeConfig.blockSizeHorizontal !* 3.0,
                    //         right:  SizeConfig.blockSizeHorizontal !* 3.0
                    //       ),
                    //       child: Padding(
                    //         padding: EdgeInsets.all(
                    //           SizeConfig.blockSizeHorizontal !* 3.0,
                    //         ),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             Icon(Icons.file_upload_outlined,size: 25,color: white,),
                    //             SizedBox(
                    //               width: SizeConfig.blockSizeHorizontal !*
                    //                   4.0,
                    //             ),
                    //             Expanded(
                    //               child: Column(
                    //                 crossAxisAlignment:
                    //                 CrossAxisAlignment.start,
                    //                 children: [
                    //                   Text(
                    //                     "Upload",
                    //                     style: TextStyle(
                    //                         fontSize: SizeConfig
                    //                             .blockSizeHorizontal !*
                    //                             4.2,
                    //                         fontWeight: FontWeight.w400,
                    //                         color: colorWhite),
                    //                   ),
                    //                   SizedBox(
                    //                     height:
                    //                     SizeConfig.blockSizeVertical !*
                    //                         0.4,
                    //                   ),
                    //                   Text(
                    //                     "Prescription",
                    //                     style: TextStyle(
                    //                         fontSize: SizeConfig
                    //                             .blockSizeHorizontal !*
                    //                             4.0,
                    //                         fontWeight: FontWeight.w700,
                    //                         color: colorWhite),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ).pO(
                  top: SizeConfig.blockSizeVertical !* 1.5,
                  bottom: SizeConfig.blockSizeVertical !* 1.0,
                ),
          ],
        );
      }),
    );
  }

  void bindRequestToDoctor(
      /*String bindFlag,*/
      Map<String, String> doctorData) async {
    //String loginUrl = "${baseURL}patientBindDoctor.php";
    String loginUrl = "${baseURL}patientBindRequesttoDoctor.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new [];
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP! +
        "\"" +
        "," +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        doctorData["DoctorIDP"]! +
        "\"" +
        /*"," +
        "\"" +
        "FirstName" +
        "\"" +
        ":" +
        "\"" +
        firstName +
        "\"" +
        "," +
        "\"" +
        "LastName" +
        "\"" +
        ":" +
        "\"" +
        lastName +
        "\"" +
        "," +
        "\"" +
        "BindFlag" +
        "\"" +
        ":" +
        "\"" +
        bindFlag +
        "\"" +*/
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
      // showBindRequestSentDialog(
      //   (doctorData["FirstName"].trim() + " " + doctorData["LastName"].trim())
      //       .trim(),
      // );
      getDoctorProfileDetails(context);
    } else if (model.status == "ERROR")
    {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void showBindRequestSentDialog(String patientName) {
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Request has been sent to $patientName to connect with you. You will be connected once doctor accepts your request.",
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Okay",
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  )),
            ],
          );
        });
  }

  isImageNotNullAndBlank() {
    return (widget.doctorData!["ProviderLogo"] != "" &&
        widget.doctorData!["ProviderLogo"] != null &&
        widget.doctorData!["ProviderLogo"] != "null");
  }

  void bindUnbindDoctor(BuildContext mContext, String bindFlag,
      Map<String, String> doctorData) async {
    String loginUrl = "${baseURL}patientBindDoctor.php";
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
    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        doctorData["DoctorIDP"]! +
        "\"" +
        "," +
        "\"" +
        "FirstName" +
        "\"" +
        ":" +
        "\"" +
        "" +
        "\"" +
        "," +
        "\"" +
        "LastName" +
        "\"" +
        ":" +
        "\"" +
        "" +
        "\"" +
        "," +
        "\"" +
        "BindFlag" +
        "\"" +
        ":" +
        "\"" +
        bindFlag +
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
        content: Text("Doctor Removed Successfully."),
      );
      ScaffoldMessenger.of(mContext).showSnackBar(snackBar);
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(mContext).pop(1);
      });
      //getPatientProfileDetails();
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(mContext).showSnackBar(snackBar);
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(mContext).pop(0);
      });
    }
  }

  void getDoctorProfileDetails(BuildContext context) async {
    ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr.show();
    });
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "HealthCareProviderIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.doctorData!["HealthCareProviderIDP"]! +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    //listIcon = new List();
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: urlFetchDoctorProfileDetails,
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
    pr.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);
      clinicAddress = jsonData[0]['ProviderAddress'];
      clinicArea = jsonData[0]['ProviderArea'];
      clinicPincode = jsonData[0]['ProviderPincode'];
      clinicContactNumber = jsonData[0]['ContactPersonMobileNo'];
      contactPersonName = jsonData[0]['ContactPersonName'];
      emailID = jsonData[0]['ProviderEmailId'];
      setState(() {});
    } else {
      /*final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
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

  void confirmPrescription(String value,String reportName,String reportDate,String reportTime,String reportImage) {
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title:
            Column(
              children: [
                Text(
                  "$reportName has been selected.Do you want to upload it?",
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    // webservice to send id
                    sendPrescriptionDetails(value);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Yes",
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  )),
            ],
          );
        });
  }

  Future<String> sendPrescriptionDetails(String patientReportIDP) async {
    final String urlFetchPatientOrder =
        "${baseURL}patient_order_submit.php";
    ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr.show();
    });

    try {
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String jsonStr = "{" +
          "\"" +
          "PatientIDP" +
          "\"" +
          ":" +
          "\"" +
          widget.patientIDP! +
          "\"" +
          "," +
          "\"" +
          "HealthcareProviderIDP" +
          "\"" +
          ":" +
          "\"" +
          widget.doctorData!["HealthCareProviderIDP"]! +
          "\"" +
          "," +
          "\"" +
          "PatientReportIDP" +
          "\"" +
          ":" +
          "\"" +
          patientReportIDP +
          "\"" +
          "," +
          "\"" +
          "OrderDetails" +
          "\"" +
          ":" +
          "\"" +
          "" +
          "\"" +
          "," +
          "\"" +
          "OrderType" +
          "\"" +
          ":" +
          "\"" +
          "medicine" +
          "\""
          "}";

      debugPrint(jsonStr);

      String encodedJSONStr = encodeBase64(jsonStr);
      //listIcon = new List();
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: urlFetchPatientOrder,
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
      pr.hide();
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array : " + strData);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Prescription Uploaded",
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0, fontWeight:
              FontWeight.bold),), duration: Duration(seconds: 2), backgroundColor: Colors.blue,)
        );
       // setState(() {});
        Navigator.of(context).push(
            MaterialPageRoute(
                builder:
                    (context) {
                  return ProviderOrderScreen(
                      widget.patientIDP!
                  );
                }));
      } else {
        /*final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(model.message),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
      }
    } catch (exception) {}
    return 'success';
  }
}
