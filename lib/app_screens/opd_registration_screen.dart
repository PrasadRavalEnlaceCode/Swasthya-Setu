import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:silvertouch/app_screens/add_consultation_screen.dart';
import 'package:silvertouch/app_screens/add_patient_screen.dart';
import 'package:silvertouch/app_screens/chat_screen.dart';
import 'package:silvertouch/app_screens/doctor_dashboard_screen.dart';
import 'package:silvertouch/app_screens/opd_reg_details_screen.dart';
import 'package:silvertouch/controllers/pdf_type_controller.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_opd_reg.dart';
import 'package:silvertouch/podo/pdf_type.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/widgets/blinking_text.dart';

import '../utils/color.dart';
import '../utils/common_methods.dart';

String dateText = "Today";
String dateTextAsDate = "";
DateTime date = DateTime.now();

String emptyTextOPDRegistration1 = "No OPD Registration Found.";
String emptyTextCampRegistration1 = "No Camp Registration Found.";

String emptyMessage = "";

Widget? emptyMessageWidget;
String patientIDP = "";
ProgressDialog? pr;

class OPDRegistrationScreen extends StatefulWidget {
  final campID;
  final name;
  final isCompleted;

  OPDRegistrationScreen({this.campID, this.name, this.isCompleted = false});

  @override
  State<StatefulWidget> createState() {
    return OPDRegistrationScreenState();
  }
}

class OPDRegistrationScreenState extends State<OPDRegistrationScreen> {
  var taskId;
  PdfTypeController pdfTypeController = Get.put(PdfTypeController());
  List<PdfType> listPdfType = [];
  List<ModelOPDRegistration> listOPDRegistration = [];

  String isReception = '';

  @override
  void initState() {
    getUserType().then((value) {
      isReception = value;
    });
    //  _bindBackgroundIsolate();
    //   FlutterDownloader.registerCallback(downloadCallback);
    getPatientOrDoctorIDP().then((value) => patientIDP = value);
    emptyMessage = widget.campID == null
        ? emptyTextOPDRegistration1
        : emptyTextCampRegistration1;
    emptyMessageWidget = SizedBox(
      height: SizeConfig.blockSizeVertical !* 80,
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
    DateFormat formatter = DateFormat('dd-MM-yyyy');
    dateTextAsDate = formatter.format(date);
    getOPDRegistrationDetails();
    super.initState();
  }

  @override
  void dispose() {
    listOPDRegistration = [];
    dateText = "Today";
    date = DateTime.now();
    _unbindBackgroundIsolate();
    super.dispose();
  }

  Future<String> getOPDRegistrationDetails() async {
    listOPDRegistration = [];
    String loginUrl = "${baseURL}doctorPatientOpdListDateWise.php";
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
    String jsonStr;
    if (widget.campID == null)
      jsonStr = "{" +
          "\"" +
          "DoctorIDP" +
          "\"" +
          ":" +
          "\"" +
          patientIDP +
          "\"" +
          "," +
          "\"" +
          "consultationdate" +
          "\"" +
          ":" +
          "\"" +
          dateTextAsDate +
          "\"" +
          "}";
    else
      jsonStr = "{" +
          "\"" +
          "DoctorIDP" +
          "\"" +
          ":" +
          "\"" +
          patientIDP +
          "\"" +
          "," +
          "\"" +
          "consultationdate" +
          "\"" +
          ":" +
          "\"" +
          '' +
          "\"," +
          "\"" +
          "DoctorCampIDF" +
          "\"" +
          ":" +
          "\"" +
          widget.campID.toString() +
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
            jo['HospitalConsultationIDP'].toString(),
            jo['PatientName'],
            jo['TotalPrice'].toString(),
            "blabalabal",
            patientIDP: jo['PatientIDP'],
            checkOutStatus: jo['CheckOutStatus'],
            fromRequestStatus: jo['FromRequestStatus'].toString(),
            vidCallDate: jo['TimeSlot'].toString(),
            paymentDueStatus: jo['PaymentDueStatus'].toString(),
            clearedFromDueStatus: jo['ClearedFromDueStatus'].toString(),
            internalNotes: jo['InternalNotes'].toString(),
            campID: widget.campID.toString() ?? ''));
      }
      setState(() {});
    }
    return 'Success';
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.campID == null ? "My Appointments" : widget.name,
          style: TextStyle(color: black),
        ),
        iconTheme: IconThemeData(color: black),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddPatientScreen(campID: widget.campID)))
                    .then((value) {
                  //Navigator.of(context).pop();
                  getOPDRegistrationDetails();
                });
              },
              child: widget.isCompleted
                  ? Container()
                  : Image(
                image: AssetImage("images/ic_add_opd.png"),
                color: black,
                width: SizeConfig.blockSizeHorizontal !* 7,
              ),
            ),
          )
        ], toolbarTextStyle: TextTheme(
        titleMedium: TextStyle(
          color: black,
          fontFamily: "Ubuntu",
          fontSize: SizeConfig.blockSizeVertical !* 2.5,
        ),
      ).bodyMedium, titleTextStyle: TextTheme(
        titleMedium: TextStyle(
          color: black,
          fontFamily: "Ubuntu",
          fontSize: SizeConfig.blockSizeVertical !* 2.5,
        ),
      ).titleLarge,
      ),
      body: Container(
        color: colorGrayApp,
        child: Column(
          children: <Widget>[
            widget.campID != null
                ? Container()
                : Container(
              color: grey,
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      previousClicked();
                    },
                    icon: Icon(
                      Icons.keyboard_arrow_left,
                      color: black,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      dateText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: black, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      nextClicked();
                    },
                    icon: Icon(
                      Icons.keyboard_arrow_right,
                      color: black,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: listOPDRegistration.length > 0
                  ?
              RefreshIndicator(
                  child: ListView.builder(
                      itemCount: listOPDRegistration.length,
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: EdgeInsets.only(
                                left: SizeConfig.blockSizeHorizontal !* 2,
                                right: SizeConfig.blockSizeHorizontal !* 2,
                                top: SizeConfig.blockSizeHorizontal !* 2),
                            child: InkWell(
                              onTap: () {
                                getUserType().then((value) {
                                  if (value != 'frontoffice' && value != 'nursing' &&
                                      !widget.isCompleted ) {
                                    var formatter =
                                    new DateFormat('dd/MM/yyyy');
                                    String strDate = formatter.format(date);
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) {
                                              return AddConsultationScreen(
                                                listOPDRegistration[index].idp!,
                                                listOPDRegistration[index]
                                                    .patientIDP!,
                                                listOPDRegistration[index],
                                                appointmentDate: strDate,
                                              );
                                            })).then((value) {
                                      getOPDRegistrationDetails();
                                    });
                                  }
                                });
                              },
                              child: Card(
                                color: listOPDRegistration[index]
                                    .checkOutStatus ==
                                    "1"
                                    ? Color(0xFFC3C3C3)
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(15.0),
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
                                    SizedBox(
                                      height: SizeConfig.blockSizeVertical !*
                                          0.5,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            listOPDRegistration[index].name!,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: SizeConfig
                                                    .blockSizeHorizontal !*
                                                    4,
                                                fontWeight:
                                                FontWeight.w600),
                                          ),
                                        ),
                                        SizedBox(
                                          width: SizeConfig
                                              .blockSizeHorizontal !*
                                              3,
                                        ),
                                        Padding(
                                            padding: EdgeInsets.all(SizeConfig
                                                .blockSizeHorizontal !*
                                                0),
                                            child: Row(
                                              children: [
                                                isReception == 'frontoffice'
                                                    ? InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                        context:
                                                        context,
                                                        builder:
                                                            (BuildContext
                                                        context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                'Internal Notes'),
                                                            content: Text(
                                                                listOPDRegistration[index]
                                                                    .internalNotes!),
                                                          );
                                                        });
                                                  },
                                                  customBorder:
                                                  CircleBorder(),
                                                  child: Container(
                                                    padding: EdgeInsets
                                                        .all(SizeConfig
                                                        .blockSizeHorizontal !*
                                                        2.0),
                                                    decoration:
                                                    BoxDecoration(
                                                      color: Colors
                                                          .blue[800],
                                                      shape: BoxShape
                                                          .circle,
                                                    ),
                                                    child: FaIcon(
                                                      FontAwesomeIcons
                                                          .stickyNote,
                                                      size: SizeConfig
                                                          .blockSizeHorizontal !*
                                                          4,
                                                      color: Colors
                                                          .white,
                                                    ),
                                                  ),
                                                )
                                                    : Container(),
                                                listOPDRegistration[index]
                                                    .fromRequestStatus ==
                                                    "1"
                                                    ? SizedBox(
                                                  width: SizeConfig
                                                      .blockSizeHorizontal !*
                                                      3.0,
                                                )
                                                    : Container(),
                                                listOPDRegistration[index]
                                                    .fromRequestStatus ==
                                                    "1"
                                                    ? InkWell(
                                                    onTap: () {
                                                      showVideoCallRequestDialog(
                                                          context,
                                                          listOPDRegistration[
                                                          index]
                                                              .patientIDP!,
                                                          listOPDRegistration[
                                                          index]
                                                              .name,
                                                          "");
                                                    },
                                                    customBorder:
                                                    CircleBorder(),
                                                    child: Container(
                                                      padding: EdgeInsets
                                                          .all(SizeConfig
                                                          .blockSizeHorizontal !*
                                                          2.0),
                                                      decoration:
                                                      BoxDecoration(
                                                        color:
                                                        Colors.red,
                                                        shape: BoxShape
                                                            .circle,
                                                      ),
                                                      child: Image(
                                                        width: SizeConfig
                                                            .blockSizeHorizontal !*
                                                            5,
                                                        color: Colors
                                                            .white,
                                                        //height: 80,
                                                        image: AssetImage(
                                                            "images/ic_video_consultation.png"),
                                                      ),
                                                    ))
                                                    : Container(),
                                                SizedBox(
                                                  width: SizeConfig
                                                      .blockSizeHorizontal !*
                                                      3.0,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    pdfButtonClick(
                                                        context,
                                                        listOPDRegistration[
                                                        index],
                                                        "full");
                                                  },
                                                  customBorder:
                                                  CircleBorder(),
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        SizeConfig
                                                            .blockSizeHorizontal !*
                                                            2.0),
                                                    child: Image(
                                                        width: SizeConfig
                                                            .blockSizeHorizontal !*
                                                            5,
                                                        height: SizeConfig
                                                            .blockSizeHorizontal !*
                                                            5,
                                                        image: AssetImage(
                                                          "images/icn-pdf-fees.png",
                                                        )),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: SizeConfig
                                                      .blockSizeHorizontal !*
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
                                                      padding: EdgeInsets
                                                          .all(SizeConfig
                                                          .blockSizeHorizontal !*
                                                          2.0),
                                                      child: Image(
                                                          width: SizeConfig
                                                              .blockSizeHorizontal !*
                                                              4,
                                                          height: SizeConfig
                                                              .blockSizeHorizontal !*
                                                              4,
                                                          image: AssetImage(
                                                            "images/icn-download-fees.png",
                                                          )),
                                                    )),
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
                                    SizedBox(
                                      height: SizeConfig.blockSizeVertical !*
                                          1.5,
                                    ),
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder:
                                                            (context) {
                                                          return OPDRegistrationDetailsScreen(
                                                              listOPDRegistration[
                                                              index]
                                                                  .idp!,
                                                              listOPDRegistration[
                                                              index]
                                                                  .patientIDP!);
                                                        })).then((value) {
                                                  //Navigator.of(context).pop();
                                                  getOPDRegistrationDetails();
                                                });
                                              },
                                              child: Row(
                                                mainAxisSize:
                                                MainAxisSize.min,
                                                children: <Widget>[
                                                  Image(
                                                    width: SizeConfig
                                                        .blockSizeHorizontal !*
                                                        6,
                                                    image: AssetImage(
                                                        'images/icn-my-consultation-nav-act.png'),
                                                  ),
                                                  SizedBox(
                                                    width: SizeConfig
                                                        .blockSizeHorizontal !*
                                                        2,
                                                  ),
                                                  Text(
                                                    "Add Service",
                                                    style: TextStyle(
                                                        color:
                                                        colorBlueApp,
                                                        fontSize: SizeConfig
                                                            .blockSizeHorizontal !*
                                                            4,
                                                        fontWeight:
                                                        FontWeight
                                                            .w500),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: SizeConfig
                                                  .blockSizeHorizontal !*
                                                  5.0,
                                            ),
                                            SizedBox(
                                              width: SizeConfig
                                                  .blockSizeHorizontal !*
                                                  10.0,
                                            ),
                                            Text(
                                              "${listOPDRegistration[index].amount}/-",
                                              style: TextStyle(
                                                  color: colorBlueApp,
                                                  fontSize: SizeConfig
                                                      .blockSizeHorizontal !*
                                                      3.5,
                                                  fontWeight:
                                                  FontWeight.w500),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Align(
                                                alignment: Alignment
                                                    .centerRight,
                                                child: Text(
                                                  "${listOPDRegistration[index].vidCallDate}",
                                                  style: TextStyle(
                                                      color:
                                                      Colors.green,
                                                      fontSize: SizeConfig
                                                          .blockSizeHorizontal !*
                                                          3.0,
                                                      fontWeight:
                                                      FontWeight
                                                          .w500),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                if (listOPDRegistration[
                                                index]
                                                    .checkOutStatus ==
                                                    "0") {
                                                  showConfirmationDialog(
                                                      context,
                                                      listOPDRegistration[
                                                      index]);
                                                }
                                              },
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                    color: listOPDRegistration[
                                                    index]
                                                        .checkOutStatus ==
                                                        "0"
                                                        ? Colors.red
                                                        : Colors
                                                        .transparent,
                                                    fontSize: SizeConfig
                                                        .blockSizeHorizontal !*
                                                        4,
                                                    fontWeight:
                                                    FontWeight
                                                        .w500),
                                              ) /*Image(
                                                  image: AssetImage(
                                                      "images/ic_pdf_opd_reg.png"),
                                                  width: SizeConfig
                                                      .blockSizeHorizontal *
                                                      8,
                                                )*/
                                              ,
                                            ),
                                          ],
                                        ))
                                        .paddingOnly(
                                        bottom: SizeConfig
                                            .blockSizeVertical !*
                                            1.5),
                                    listOPDRegistration[index]
                                        .paymentDueStatus ==
                                        "1"
                                        ? Align(
                                        alignment: Alignment.centerLeft,
                                        child: BlinkingText(
                                          "Payment Due",
                                          //textAlign: TextAlign.left,
                                          textStyle: TextStyle(
                                            color: Colors.red,
                                            fontSize: SizeConfig
                                                .blockSizeHorizontal !*
                                                3.6,
                                          ),
                                        ))
                                        : Container(),
                                  ],
                                ).paddingSymmetric(
                                  horizontal:
                                  SizeConfig.blockSizeHorizontal !* 4.0,
                                  vertical:
                                  SizeConfig.blockSizeVertical !* 1.3,
                                ),
                              ),
                            ));
                      }),
                  onRefresh: () {
                    return getOPDRegistrationDetails();
                  })
                  : emptyMessageWidget!,
            )
          ],
        ),
      ),
    );
  }

  showConfirmationDialog(
      BuildContext context, ModelOPDRegistration modelOPDRegistration) {
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Do you really want to Cancel this Appointment?"),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    cancelAppointment(modelOPDRegistration);
                  },
                  child: Text("Yes"))
            ],
          );
        });
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
    getOPDRegistrationDetails();
    setState(() {});
  }

  // Future downloadFileAndOpenActually(
  //     Dio dio, String url, String savePath) async {
  //   try {
  //     pr = ProgressDialog(context);
  //     pr!.show();
  //
  //     final savedDir = Directory(savePath);
  //     bool hasExisted = await savedDir.exists();
  //     if (!hasExisted) {
  //       await savedDir.create();
  //     }
  //     taskId = await FlutterDownloader.enqueue(
  //       url: url,
  //       savedDir: savePath,
  //       showNotification: false,
  //       // show download progress in status bar (for Android)
  //       openFileFromNotification:
  //           false, // click on notification to open downloaded file (for Android)
  //     ) /*.then((value) {
  //       taskId = value;
  //     })*/
  //         ;
  //     var tasks = await FlutterDownloader.loadTasks();
  //     debugPrint("File path");
  //   } catch (e) {
  //     print("Error downloading");
  //     print(e.toString());
  //   }
  // }

  // void downloadAndOpenTheFile(String url, String fileName) async {
  //   var tempDir = Platform.isAndroid
  //       ? await getExternalStorageDirectory()
  //       : await getApplicationDocumentsDirectory();
  //   //await tempDir.create(recursive: true);
  //   String fullPath = tempDir!.path + "/$fileName";
  //   debugPrint("full path");
  //   debugPrint(fullPath);
  //   Dio dio = Dio();
  //   downloadFileAndOpenActually(dio, url, fullPath);
  // }

  // void _bindBackgroundIsolate() {
  //   ReceivePort _port = ReceivePort();
  //   bool isSuccess = IsolateNameServer.registerPortWithName(
  //       _port.sendPort, 'downloader_send_port');
  //   if (!isSuccess) {
  //     _unbindBackgroundIsolate();
  //     _bindBackgroundIsolate();
  //     return;
  //   }
  //   _port.listen((dynamic data) {
  //     String id = data[0];
  //     DownloadTaskStatus status = data[1];
  //     int progress = data[2];
  //     if (/*status == DownloadTaskStatus.complete*/ status.toString() ==
  //             "DownloadTaskStatus(3)" &&
  //         progress == 100) {
  //       debugPrint("Successfully downloaded");
  //       pr!.hide();
  //       String query = "SELECT * FROM task WHERE task_id='" + id + "'";
  //       var tasks = FlutterDownloader.loadTasksWithRawQuery(query: query);
  //     FlutterDownloader.open(taskId: id);
  //     }
  //   });
  // }
  //
  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  // static void downloadCallback(
  //     String id, int status, int progress) {
  //   final SendPort? send =
  //       IsolateNameServer.lookupPortByName('downloader_send_port');
  //   send!.send([id, status, progress]);
  // }
  //
  // void showDownloadProgress(received, total) {
  //   if (total != -1) {
  //     print((received / total * 100).toStringAsFixed(0) + "%");
  //   }
  // }

  void getPdfDownloadPath(
      BuildContext context, String idp, String patientIDPLocal) async {
    String? loginUrl;
    if (pdfTypeController.pdfType.value == "prescription")
      loginUrl = "${baseURL}prescriptiondocpdf.php";
    else if (pdfTypeController.pdfType.value == "receipt")
      loginUrl = "${baseURL}receiptpdfdoc.php";
    else if (pdfTypeController.pdfType.value == "invoice")
      loginUrl = "${baseURL}invoicepdfdoc.php";
    else if (pdfTypeController.pdfType.value == "full")
      loginUrl = "${baseURL}consultationpdfdoc.php";
    //  debugPrint("pdf url -  $loginUrl!");

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
        "DoctorIDP" +
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
        ",\"PatientIDP\":\"$patientIDPLocal\"" +
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
      String downloadPdfUrl = "";
      if (pdfTypeController.pdfType.value == "prescription")
        downloadPdfUrl = "${baseImagePath}images/prescriptionDoc/$fileName";
      else if (pdfTypeController.pdfType.value == "receipt")
        downloadPdfUrl = "${baseImagePath}images/receiptDoc/$fileName";
      else if (pdfTypeController.pdfType.value == "invoice")
        downloadPdfUrl = "${baseImagePath}images/invoiceDoc/$fileName";
      else if (pdfTypeController.pdfType.value == "full")
        downloadPdfUrl = "${baseImagePath}images/consultationDoc/$fileName";
      downloadAndOpenTheFile(downloadPdfUrl, fileName);
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr!.hide();
    }
  }

  void pdfButtonClick(BuildContext context,
      ModelOPDRegistration modelOPDRegistration, String pdfType) {
    pdfTypeController.setPdfType(pdfType);
    if (modelOPDRegistration.checkOutStatus == "1") {
      getPdfDownloadPath(
          context, modelOPDRegistration.idp!, modelOPDRegistration.patientIDP!);
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please checkout this patient to view the document."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  showVideoCallRequestDialog(
      BuildContext context, String patientIDP, patientName, doctorImage) {
    var title = "Do you want to send Video call request?";
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
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    requestVideoCallFromDoctor(
                        patientIDP, patientName, doctorImage);
                  },
                  child: Text("Yes"))
            ],
          );
        });
  }

  void requestVideoCallFromDoctor(
      String patientIDP, String patientName, String doctorImage) async {
    final String urlGetChannelIDForVidCall = "${baseURL}videocallRequest.php";
    ProgressDialog pr = ProgressDialog(context);
    pr.show();

    try {
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      String doctorIDP = await getPatientOrDoctorIDP();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String fromType = "";
      if (userType == "patient") {
        fromType = "P";
      } else if (userType == "doctor") {
        fromType = "D";
      }
      String jsonStr = "{" +
          "\"PatientIDP\":\"$patientIDP\"" +
          ",\"DoctorIDP\":\"$doctorIDP\"" +
          ",\"messagefrom\":\"$fromType\"" +
          "}";

      debugPrint(jsonStr);

      String encodedJSONStr = encodeBase64(jsonStr);
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: urlGetChannelIDForVidCall,
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
      pr.hide();
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array : " + strData);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return ChatScreen(
              patientIDP: patientIDP,
              patientName: patientName,
              patientImage: doctorImage,
            );
          },
        ));
      } else {}
    } catch (exception) {}
  }

  void cancelAppointment(ModelOPDRegistration modelOPDRegistration) async {
    final String urlCancelAppointment = "${baseURL}doctorAppointmentCancel.php";
    ProgressDialog pr = ProgressDialog(context);
    pr.show();

    try {
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      String doctorIDP = await getPatientOrDoctorIDP();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String fromType = "";
      if (userType == "patient") {
        fromType = "P";
      } else if (userType == "doctor") {
        fromType = "D";
      }
      String jsonStr = "{" +
          "\"HospitalConsultationIDP\":\"${modelOPDRegistration.idp}\"" +
          "}";

      debugPrint(jsonStr);

      String encodedJSONStr = encodeBase64(jsonStr);
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: urlCancelAppointment,
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
      pr.hide();
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array : " + strData);
        getOPDRegistrationDetails();
        /*Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return ChatScreen(
              patientIDP: patientIDP,
              patientName: patientName,
              patientImage: doctorImage,
            );
          },
        ));*/
      } else {}
    } catch (exception) {}
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
                  height: SizeConfig.blockSizeVertical !* 8,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal !* 6.2,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal !* 6,
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal !* 50,
                          height: SizeConfig.blockSizeVertical !* 8,
                          child: Center(
                            child: Text(
                              "Select Pdf to download",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
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
                                  width: SizeConfig.blockSizeHorizontal !* 90,
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
                                            size:
                                            SizeConfig.blockSizeHorizontal !*
                                                5,
                                            color: Colors.green,
                                          ),
                                          SizedBox(
                                            width:
                                            SizeConfig.blockSizeHorizontal !*
                                                6.0,
                                          ),
                                          Text(
                                            list[index].typeName,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: SizeConfig
                                                  .blockSizeHorizontal !*
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
}
