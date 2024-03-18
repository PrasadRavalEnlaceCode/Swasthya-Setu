import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:silvertouch/app_screens/add_patient_screen.dart';
import 'package:silvertouch/app_screens/chat_screen.dart';
import 'package:silvertouch/controllers/pdf_type_controller.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/model_opd_reg.dart';
import 'package:silvertouch/podo/pdf_type.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';
import 'package:silvertouch/widgets/blinking_text.dart';
import 'package:silvertouch/widgets/extensions.dart';

import 'PDFViewerCachedFromUrl.dart';

List<ModelOPDRegistration> listOPDRegistration = [];
String dateText = "Today";
String dateTextAsDate = "";
DateTime date = DateTime.now();

String emptyTextOPDRegistration1 = "No Appointments found.";

String emptyMessage = "";

Widget? emptyMessageWidget;
String patientIDP = "";
ProgressDialog? pr;

class MyAppointmentsPatientScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppointmentsPatientScreenState();
  }
}

class MyAppointmentsPatientScreenState
    extends State<MyAppointmentsPatientScreen> {
  PdfTypeController pdfTypeController = Get.put(PdfTypeController());
  List<PdfType> listPdfType = [];

  @override
  void initState() {
    super.initState();
    getPatientOrDoctorIDP().then((value) => patientIDP = value);
    emptyMessage = emptyTextOPDRegistration1;
    emptyMessageWidget = Center(
      child: Container(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 5),
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
              emptyMessage,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
    DateFormat formatter = DateFormat('dd-MM-yyyy');
    dateTextAsDate = formatter.format(date);
    getMyAppointments();
  }

  @override
  void dispose() {
    listOPDRegistration = [];
    dateText = "Today";
    date = DateTime.now();
    super.dispose();
  }

  void getMyAppointments() async {
    listOPDRegistration = [];
    String loginUrl = "${baseURL}patient_myappointments.php";
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
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        /*"," +
        "\"" +
        "consultationdate" +
        "\"" +
        ":" +
        "\"" +
        dateTextAsDate +
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
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      listOPDRegistration = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listOPDRegistration.add(ModelOPDRegistration(
          jo['HospitalConsultationIDP'].toString(),
          jo['DoctorName'].toString().trim(),
          jo['ConsultationDate'],
          "blabalabal",
          patientIDP: jo['DoctorIDP'].toString(),
          fromRequestStatus: jo['FromRequestStatus'].toString(),
          paymentDueStatus: jo['PaymentDueStatus'].toString(),
          clearedFromDueStatus: jo['ClearedFromDueStatus'].toString(),
        ));
      }
      setState(() {});
    }
  }

  Widget titleWidget = Text("My Appointments");

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: titleWidget,
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(
            color: Colorsblack, size: SizeConfig.blockSizeVertical! * 2.5),
        toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(
          color: Colors.white,
          fontFamily: "Ubuntu",
          fontSize: SizeConfig.blockSizeVertical! * 2.5,
        )).bodyMedium,
        titleTextStyle: TextTheme(
            titleMedium: TextStyle(
          color: Colors.white,
          fontFamily: "Ubuntu",
          fontSize: SizeConfig.blockSizeVertical! * 2.5,
        )).titleLarge,
      ),
      body: Container(
        color: Color(0xFFDCDCDC),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            /*Container(
              color: mainColor,
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      previousClicked();
                    },
                    icon: Icon(
                      Icons.arrow_left,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      dateText,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      nextClicked();
                    },
                    icon: Icon(
                      Icons.arrow_right,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),*/
            Expanded(
              child: listOPDRegistration.length > 0
                  ? ListView.builder(
                      itemCount: listOPDRegistration.length,
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: EdgeInsets.only(
                                left: SizeConfig.blockSizeHorizontal! * 2,
                                right: SizeConfig.blockSizeHorizontal! * 2,
                                top: SizeConfig.blockSizeHorizontal! * 2),
                            child: InkWell(
                              onTap: () {
                                if (listOPDRegistration[index]
                                        .paymentDueStatus ==
                                    "1") {
                                  getDuePayment(
                                      context, listOPDRegistration[index]);
                                }
                                /*Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return AddConsultationScreen(
                                    listOPDRegistration[index].idp,
                                    listOPDRegistration[index].patientIDP,
                                    listOPDRegistration[index],
                                  );
                                })).then((value) {
                                  getOPDRegistrationDetails();
                                });*/
                              },
                              child: Card(
                                color:
                                    listOPDRegistration[index].checkOutStatus ==
                                            "1"
                                        ? Color(0xFFC3C3C3)
                                        : Colors.white,
                                elevation: listOPDRegistration[index]
                                            .paymentDueStatus ==
                                        "1"
                                    ? 3.0
                                    : 1.0,
                                shadowColor: listOPDRegistration[index]
                                            .paymentDueStatus ==
                                        "1"
                                    ? Colors.red
                                    : Colors.grey,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                  color: listOPDRegistration[index]
                                              .paymentDueStatus ==
                                          "1"
                                      ? Colors.red
                                      : Colors.white,
                                  width: listOPDRegistration[index]
                                              .paymentDueStatus ==
                                          "1"
                                      ? 1.3
                                      : 0,
                                )),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            listOPDRegistration[index].name!,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    4,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              SizeConfig.blockSizeHorizontal! *
                                                  3,
                                        ),
                                        Padding(
                                            padding: EdgeInsets.all(SizeConfig
                                                    .blockSizeHorizontal! *
                                                0),
                                            child: Row(
                                              children: [
                                                listOPDRegistration[index]
                                                            .fromRequestStatus ==
                                                        "1"
                                                    ? InkWell(
                                                        onTap: () {
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) {
                                                            return ChatScreen(
                                                              patientIDP:
                                                                  listOPDRegistration[
                                                                          index]
                                                                      .patientIDP,
                                                              patientName:
                                                                  listOPDRegistration[
                                                                          index]
                                                                      .name,
                                                              patientImage:
                                                                  "" /*listDoctorsSearchResults[index]
                                                                  ["DoctorImage"]*/
                                                              ,
                                                            );
                                                          })).then((value) {
                                                            getMyAppointments();
                                                          });
                                                        },
                                                        customBorder:
                                                            CircleBorder(),
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .all(SizeConfig
                                                                      .blockSizeHorizontal! *
                                                                  2.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.red,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Image(
                                                            width: SizeConfig
                                                                    .blockSizeHorizontal! *
                                                                5,
                                                            color: Colors.white,
                                                            //height: 80,
                                                            image: AssetImage(
                                                                "images/ic_video_consultation.png"),
                                                          ),
                                                        ))
                                                    : Container(),
                                                SizedBox(
                                                  width: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      3.0,
                                                ),
                                                InkWell(
                                                    onTap: () {
                                                      preparePdfList(
                                                          listOPDRegistration[
                                                              index]);
                                                      showPdfTypeSelectionDialog(
                                                        listPdfType,
                                                        listOPDRegistration[
                                                            index],
                                                        context,
                                                      );
                                                    },
                                                    customBorder:
                                                        CircleBorder(),
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                          SizeConfig
                                                                  .blockSizeHorizontal! *
                                                              2.0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Image(
                                                        width: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            5,
                                                        color: Colors.white,
                                                        //height: 80,
                                                        image: AssetImage(
                                                            "images/ic_download.png"),
                                                      ),
                                                    )),
                                                /*InkWell(
                                                      onTap: () {
                                                        pdfButtonClick(
                                                            context,
                                                            listOPDRegistration[
                                                                index],
                                                            "receipt");
                                                      },
                                                      customBorder:
                                                          CircleBorder(),
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            SizeConfig
                                                                    .blockSizeHorizontal *
                                                                2.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.blue[800],
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: FaIcon(
                                                          FontAwesomeIcons
                                                              .rupeeSign,
                                                          size: SizeConfig
                                                                  .blockSizeHorizontal *
                                                              4,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: SizeConfig
                                                              .blockSizeHorizontal *
                                                          3.0,
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        pdfButtonClick(
                                                            context,
                                                            listOPDRegistration[
                                                                index],
                                                            "invoice");
                                                      },
                                                      customBorder:
                                                          CircleBorder(),
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            SizeConfig
                                                                    .blockSizeHorizontal *
                                                                2.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.blue[800],
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: FaIcon(
                                                          FontAwesomeIcons
                                                              .fileInvoice,
                                                          size: SizeConfig
                                                                  .blockSizeHorizontal *
                                                              4,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),*/
                                              ],
                                            )),
                                        /*InkWell(
                                              onTap: () {
                                                if (listOPDRegistration[index]
                                                        .checkOutStatus ==
                                                    "1") {
                                                  getPdfDownloadPath(
                                                      context,
                                                      listOPDRegistration[index]
                                                          .idp,
                                                      listOPDRegistration[index]
                                                          .patientIDP);
                                                } else {
                                                  final snackBar = SnackBar(
                                                    backgroundColor: Colors.red,
                                                    content: Text(
                                                        "Please checkout this patient to view the document."),
                                                  );
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                }
                                              },
                                              child: Image(
                                                image: AssetImage(
                                                    "images/ic_pdf_opd_reg.png"),
                                                width: SizeConfig
                                                        .blockSizeHorizontal *
                                                    8,
                                              ),
                                            )*/
                                      ],
                                    ),
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            /*Expanded(
                                              flex: 1,
                                              child:*/
                                            Text(
                                              "${listOPDRegistration[index].amount}",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      3.5,
                                                  fontWeight: FontWeight.w500),
                                            ).paddingOnly(
                                              right: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  5.0,
                                            ),
                                            /*),*/
                                            listOPDRegistration[index]
                                                        .paymentDueStatus ==
                                                    "1"
                                                ? Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: BlinkingText(
                                                      "Payment Due",
                                                      //textAlign: TextAlign.left,
                                                      textStyle: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            3.6,
                                                      ),
                                                    ))
                                                : Container(),
                                          ],
                                        )),
                                  ],
                                ).paddingAll(
                                  SizeConfig.blockSizeHorizontal! * 3,
                                ),
                              ),
                            ));
                      })
                  : emptyMessageWidget!,
            )
          ],
        ),
      ),
    );
  }

  void preparePdfList(ModelOPDRegistration model) {
    if (model.clearedFromDueStatus == "1" || model.paymentDueStatus == "1") {
      listPdfType = [
        PdfType(
          "Prescription",
          "prescription",
          FontAwesomeIcons.prescription,
        ),
        PdfType(
          "Invoice",
          "invoice",
          FontAwesomeIcons.fileInvoice,
        ),
      ];
    } else {
      listPdfType = [
        PdfType(
          "Prescription",
          "prescription",
          FontAwesomeIcons.prescription,
        ),
        PdfType(
          "Receipt",
          "receipt",
          FontAwesomeIcons.rupeeSign,
        ),
        PdfType(
          "Invoice",
          "invoice",
          FontAwesomeIcons.fileInvoice,
        ),
      ];
    }
  }

  void nextClicked() {
    date = date.add(Duration(days: 1));
    setDateAndFetchData();
  }

  void previousClicked() {
    date = date.subtract(Duration(days: 1));
    setDateAndFetchData();
  }

  void setDateAndFetchData() {
    DateFormat formatter = DateFormat('dd MMM yyyy');
    if (date.day - DateTime.now().day == 0)
      dateText = "Today";
    else if (date.day - DateTime.now().day == 1)
      dateText = "Tommorrow";
    else if (date.day - DateTime.now().day == -1)
      dateText = "Yesterday";
    else
      dateText = formatter.format(date);
    DateFormat formatter1 = DateFormat('dd-MM-yyyy');
    dateTextAsDate = formatter1.format(date);
    getMyAppointments();
    setState(() {});
  }

  void getPdfDownloadPath(
      BuildContext context, String idp, String patientIDPLocal) async {
    String? loginUrl;
    /*if (pdfTypeController.pdfType.value == "full")
      loginUrl = "${baseURL}consultationpdfdoc.php";
    else*/
    if (pdfTypeController.pdfType.value == "prescription")
      loginUrl = "${baseURL}consultationpdfdoc.php";
    else if (pdfTypeController.pdfType.value == "receipt")
      loginUrl = "${baseURL}receiptpdfdoc.php";
    else if (pdfTypeController.pdfType.value == "invoice")
      loginUrl = "${baseURL}invoicepdfdoc.php";
    //  debugPrint("pdf url -  $loginUrl");

    pr = ProgressDialog(context);
    pr!.show();
    String patientIDP = await getPatientOrDoctorIDP();
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
        patientIDP +
        "\"," +
        "\"" +
        "HospitalConsultationIDF" +
        "\"" +
        ":" +
        "\"" +
        idp +
        "\"" +
        ",\"DoctorIDP\":\"$patientIDPLocal\"" +
        "}";

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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    if (model.status == "OK") {
      String encodedFileName = model.data!;
      String strData = decodeBase64(encodedFileName);
      final jsonData = json.decode(strData);
      String fileName = jsonData[0]['FileName'].toString();
      print('fileName $fileName');
      String downloadPdfUrl = "";
      if (pdfTypeController.pdfType.value == "prescription")
        downloadPdfUrl = "${baseImagePath}images/consultationDoc/$fileName";
      else if (pdfTypeController.pdfType.value == "receipt")
        downloadPdfUrl = "${baseImagePath}images/receiptDoc/$fileName";
      else if (pdfTypeController.pdfType.value == "invoice")
        downloadPdfUrl = "${baseImagePath}images/invoiceDoc/$fileName";
      // downloadAndOpenTheFile(downloadPdfUrl, fileName);
      if (downloadPdfUrl != null) {
        Navigator.push(
            context,
            MaterialPageRoute<dynamic>(
              builder: (_) => PDFViewerCachedFromUrl(
                url: downloadPdfUrl,
              ),
            ));
      } else {
        print('No URL found');
      }
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr!.hide();
    }
  }

  void pdfButtonClick(
    BuildContext context,
    ModelOPDRegistration modelOPDRegistration,
    String pdfType,
  ) {
    pdfTypeController.setPdfType(pdfType);
    /*if (modelOPDRegistration.checkOutStatus == "1") {*/
    getPdfDownloadPath(
        context, modelOPDRegistration.idp!, modelOPDRegistration.patientIDP!);
    /*} else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please checkout this patient to view the document."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }*/
  }

  void showPdfTypeSelectionDialog(List<PdfType> list,
      ModelOPDRegistration modelOPDRegistration, BuildContext mContext) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: SizeConfig.blockSizeVertical! * 8,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal! * 6.2,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 6,
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal! * 50,
                          height: SizeConfig.blockSizeVertical! * 8,
                          child: Center(
                            child: Text(
                              "Select Pdf to download",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                                color: Colors.blue,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                /*Expanded(
                  child:*/
                ListView.builder(
                    itemCount: list.length,
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            pdfButtonClick(
                              mContext,
                              modelOPDRegistration,
                              listPdfType[index].typeKeyword,
                            );
                          },
                          child: Padding(
                              padding: EdgeInsets.all(0.0),
                              child: Container(
                                  width: SizeConfig.blockSizeHorizontal! * 90,
                                  padding: EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                    left: 5,
                                    right: 5,
                                  ),
                                  decoration: new BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 2.0, color: Colors.white),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10.0,
                                        offset: const Offset(0.0, 10.0),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          FaIcon(
                                            list[index].iconData,
                                            size: SizeConfig
                                                    .blockSizeHorizontal! *
                                                5,
                                            color: Colors.green,
                                          ),
                                          SizedBox(
                                            width: SizeConfig
                                                    .blockSizeHorizontal! *
                                                6.0,
                                          ),
                                          Text(
                                            list[index].typeName,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  4.3,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      )))));
                    }),
                /*),*/
              ],
            )));
  }

  void getDuePayment(
      BuildContext context, ModelOPDRegistration doctorData) async {
    String loginUrl = "${baseURL}patientDuePayment.php";
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
        doctorData.patientIDP! +
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
      String dueAmount = jsonData[0]['DueAmount'];
      showPayNowBottomSheet(dueAmount, doctorData);
    }
  }

  void showPayNowBottomSheet(
      String dueAmount, ModelOPDRegistration doctorData) {
    Get.bottomSheet(
      Material(
        child: Container(
          height: SizeConfig.blockSizeVertical! * 38,
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal! * 5.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 1.5,
              ),
              Card(
                color: doctorData.checkOutStatus == "1"
                    ? Color(0xFFC3C3C3)
                    : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                  color: doctorData.paymentDueStatus == "1"
                      ? Colors.red
                      : Colors.white,
                  width: doctorData.paymentDueStatus == "1" ? 1.3 : 0,
                )),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Text(
                            doctorData.name!,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 0.5,
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            /*Expanded(
                                              flex: 1,
                                              child:*/
                            Text(
                              "${doctorData.amount}",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal! * 3.5,
                                  fontWeight: FontWeight.w500),
                            ).paddingOnly(
                              right: SizeConfig.blockSizeHorizontal! * 5.0,
                            ),
                          ],
                        )),
                  ],
                ).paddingAll(
                  SizeConfig.blockSizeHorizontal! * 4,
                ),
              ).paddingOnly(
                bottom: SizeConfig.blockSizeVertical! * 1.0,
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "images/ic_payment_due.png",
                          width: SizeConfig.blockSizeHorizontal! * 12.0,
                          fit: BoxFit.fill,
                        ).paddingOnly(
                          right: SizeConfig.blockSizeHorizontal! * 5.0,
                        ),
                        Text(
                          "Payment Due",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: SizeConfig.blockSizeHorizontal! * 4.5,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ).pO(
                      bottom: SizeConfig.blockSizeVertical! * 1.0,
                    ),
                    Text(
                      "\u20B9$dueAmount",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.blockSizeHorizontal! * 6.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.8,
                      ),
                    ).pO(
                      bottom: SizeConfig.blockSizeVertical! * 1.5,
                    ),
                    MaterialButton(
                      onPressed: () {
                        startPayment(0, doctorData, dueAmount);
                      },
                      color: Colors.green,
                      child: Text(
                        "Pay Now",
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 1.3,
                          fontSize: SizeConfig.blockSizeHorizontal! * 4.2,
                        ),
                      ),
                    ).pO(
                      bottom: SizeConfig.blockSizeVertical! * 1.5,
                    ),
                  ],
                ),
              ).expanded(),
            ],
          ),
        ),
      ),
    );
  }

  void startPayment(
      int type, ModelOPDRegistration doctorData, String dueAmount) async {
    String patientIDP = await getPatientOrDoctorIDP();
    goToWebview(context, "",
        "${baseImagePath}paymentgatewayPayDuetoDoctor.php?appointid=${doctorData.idp}&amount=$dueAmount&idp=${doctorData.patientIDP}&idppt=$patientIDP");
  }

  goToWebview(BuildContext context, String iconName, String webView) {
    // PaymentWebViewController paymentWebViewController =
    //     Get.put(PaymentWebViewController());
    // String webViewUrl = Uri.encodeFull(webView);
    // paymentWebViewController.url.value = webViewUrl;
    // debugPrint("encoded url :- $webViewUrl");
    //
    // if (webView != "") {
    //   final flutterWebViewPlugin = FlutterWebviewPlugin();
    //   flutterWebViewPlugin.onUrlChanged.listen((url) {
    //     debugPrint(url);
    //     paymentWebViewController.url.value = url;
    //   });
    //   flutterWebViewPlugin.onDestroy.listen((_) {
    //     if (Navigator.canPop(context)) {
    //       Navigator.of(context).pop();
    //     }
    //   });
    //   Navigator.push(context, MaterialPageRoute(builder: (mContext) {
    //     return new MaterialApp(
    //       debugShowCheckedModeBanner: false,
    //       theme:
    //           ThemeData(fontFamily: "Ubuntu", primaryColor: Color(0xFF06A759)),
    //       routes: {
    //         "/": (_) => Obx(() => WebviewScaffold(
    //               withLocalStorage: true,
    //               withJavascript: true,
    //               url: webViewUrl,
    //               appBar:
    //                   paymentWebViewController.url.value.contains(
    //                               "swasthyasetu.com/ws/failurePayDuetoDoctor.php") ||
    //                           paymentWebViewController.url.value.contains(
    //                               "swasthyasetu.com/ws/successPayDuetoDoctor.php") ||
    //                           paymentWebViewController.url.value.contains(
    //                               "swasthyasetu.com/ws/paymentgatewayPaytoDoctorDirect.php")
    //                       ? AppBar(
    //                           backgroundColor: Colors.white,
    //                           title: Text(iconName),
    //                           leading: IconButton(
    //                               icon: Icon(
    //                                 Platform.isAndroid
    //                                     ? Icons.arrow_back
    //                                     : Icons.arrow_back_ios,
    //                                 color: Colors.black,
    //                                 size: SizeConfig.blockSizeHorizontal * 8.0,
    //                               ),
    //                               onPressed: () {
    //                                 if (paymentWebViewController.url.value.contains(
    //                                     "swasthyasetu.com/ws/failurePayDuetoDoctor.php"))
    //                                   Navigator.of(context).pop();
    //                                 else if (paymentWebViewController.url.value
    //                                     .contains(
    //                                         "swasthyasetu.com/ws/successPayDuetoDoctor.php")) {
    //                                   Navigator.of(context).pop(1);
    //                                   Navigator.of(context).pop(1);
    //                                   //Navigator.of(context).pop();
    //                                 } else if (paymentWebViewController
    //                                     .url.value
    //                                     .contains(
    //                                         "swasthyasetu.com/ws/paymentgatewayPaytoDoctorDirect.php")) {
    //                                   Navigator.of(context).pop();
    //                                   //Navigator.of(context).pop();
    //                                 }
    //                                 /*Navigator.pushAndRemoveUntil(
    //                               context,
    //                               MaterialPageRoute(
    //                                   builder: (context) =>
    //                                       CheckExpiryBlankScreen(
    //                                           "", "coupon", false, null)),
    //                               (Route<dynamic> route) => false);*/
    //                               }),
    //                           iconTheme: IconThemeData(
    //                               color: Colors.white,
    //                               size: SizeConfig.blockSizeVertical * 2.2),
    //                           textTheme: TextTheme(
    //                               subtitle1: TextStyle(
    //                                   color: Colors.white,
    //                                   fontFamily: "Ubuntu",
    //                                   fontSize:
    //                                       SizeConfig.blockSizeVertical * 2.3)),
    //                         )
    //                       : PreferredSize(
    //                           child: Container(),
    //                           preferredSize: Size(SizeConfig.screenWidth, 0),
    //                         ),
    //             )),
    //       },
    //     );
    //   })).then((value) {
    //     if (value != null && value == 1) {
    //       getMyAppointments();
    //     }
    //   });
    // }
  }

  bool downloading = false;

  String progress = '0';

  bool isDownloaded = false;

  void downloadAndOpenTheFile(String downloadPdfUrl, String fileName) async {
    print('downloadAndOpenTheFile $downloadPdfUrl $fileName');
    //Url url = Uri.parse(downloadPdfUrl);

    // setState(() {
    //   downloading = true;
    // });
    //
    // String savePath = await getFilePath(fileName);
    //
    // Dio dio = Dio();
    //
    // dio.download(
    //   downloadPdfUrl,
    //   savePath,
    //   onReceiveProgress: (rcv, total) async {
    //     print('received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');
    //
    //     setState(() {
    //       progress = ((rcv / total) * 100).toStringAsFixed(0);
    //     });
    //
    //     if (progress == '100')
    //     {
    //       //final file = File(savePath);
    //       // bool fileSaved = await file.exists();
    //       print('fileSaved $savePath');
    //       isDownloaded = true;
    //       await OpenFile.open(savePath);
    //       // setState(() async {
    //       //   isDownloaded = true;
    //       // });
    //     } else if (double.parse(progress) < 100) {}
    //   },
    //   deleteOnError: true,
    // ).then((_) {
    //   setState(() {
    //     if (progress == '100') {
    //       isDownloaded = true;
    //
    //     }
    //     downloading = false;
    //   });
    // });
  }
}

Future<String> getFilePath(uniqueFileName) async {
  String path = '';

  Directory dir = await getApplicationDocumentsDirectory();

  path = '${dir.path}/$uniqueFileName';

  return path;
}
