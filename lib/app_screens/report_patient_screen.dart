import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:silvertouch/api/api_helper.dart';
import 'package:silvertouch/app_screens/PDFViewerCachedFromUrl.dart';
import 'package:silvertouch/app_screens/add_patient_report.dart';
import 'package:silvertouch/app_screens/fullscreen_image.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_profile_patient.dart';
import 'package:silvertouch/podo/model_report.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/progress_dialog.dart';

class PatientReportScreen extends StatefulWidget {
  String? patientIDP;
  String? from;
  bool? fetchPrescription = false;
  var fromDate = DateTime.now().subtract(Duration(days: 7));
  var toDate = DateTime.now();

  var fromDateString = "";
  var toDateString = "";
  var dateString = "Select Date Range";

  String emptyTextReport1 =
      "Now you can add your Prescription, XRay, CT Scan, ECG and other medical documents.";
  String emptyTextReport2 =
      "Upload a scan copy or take a Photo of your Medical documents based on different categories and keep them in your records.";
  String emptyTextReport3 =
      "Add a TagName / Document Name to your report and add them in respective category.";

  String emptyMessage = "";

  Widget? emptyMessageWidget;

  PatientReportScreen(String patientIDP, String from, bool fetchPrescription) {
    this.patientIDP = patientIDP;
    this.from = from;
    this.fetchPrescription = fetchPrescription;
  }

  @override
  State<StatefulWidget> createState() {
    return PatientReportScreenState();
  }
}

class PatientReportScreenState extends State<PatientReportScreen> {
  bool apiCalled = false;
  List<ModelReport> listPatientReport = [];
  List<Map<String, String>> listCategories = [];
  ScrollController? hideFABController;
  var isFABVisible = true;
  var selectedCategoryIDP = "-";
  var taskId;
  ProgressDialog? pr;
  ApiHelper apiHelper = ApiHelper();

  //List<TableRow> tableRows = [];
  late DateTimeRange dateRange;

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);

    widget.emptyMessage =
        "${widget.emptyTextReport1}\n\n${widget.emptyTextReport2}\n\n${widget.emptyTextReport3}";
    // var formatter = DateFormat('dd-MM-yyyy');
    selectedCategoryIDP = widget.from!;
    /*widget.fromDateString = formatter.format(widget.fromDate);
    widget.toDateString = formatter.format(widget.toDate);*/
    widget.dateString = "Select Date Range";
    var formatter = new DateFormat('dd-MM-yyyy');
    widget.fromDate = DateTime.now().subtract(const Duration(days: 30));
    widget.toDate = DateTime.now();
    widget.fromDateString = formatter.format(widget.fromDate!);
    widget.toDateString = formatter.format(widget.toDate!);
    dateRange = DateTimeRange(start: widget.fromDate!, end: widget.toDate!);
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
    widget.emptyMessageWidget = SizedBox(
      height: SizeConfig.blockSizeVertical! * 80,
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
              "${widget.emptyMessage}",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );

    if (widget.from == "Reports") {
      selectedCategoryIDP = "2";
      getPatientReport(context);
    } else if (widget.from == "prescription_fixed" ||
        widget.from == "dashboard") {
      selectedCategoryIDP = "-";
      getPatientReport(context);
    } else {
      getPatientReport(context);
    }
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    /*if (!apiCalled) */

    return SafeArea(
        child: Scaffold(
      backgroundColor: Color(0xFFf9faff),
      appBar: AppBar(
        title: Text(
            (widget.from == "1")
                ? (widget.fetchPrescription == true)
                    ? "Select Prescription"
                    : "Prescriptions"
                : "Documents",
            style: TextStyle(
                fontSize: SizeConfig.blockSizeVertical! * 2.5,
                color: Colorsblack)),
        iconTheme: IconThemeData(
            color: Colorsblack, size: SizeConfig.blockSizeVertical! * 2.5),
        backgroundColor: Color(0xFFf9faff),
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: (widget.from == "1" ||
              widget.from == "Reports" ||
              widget.from == "12" ||
              widget.from == "13")
          ? Visibility(
              visible: isFABVisible,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddPatientReportScreen(
                                widget.patientIDP!,
                                selectedCategoryIDP,
                                from: widget.from,
                              ))).then((value) {
                    getPatientReport(context);
                  });
                },
                child: Icon(Icons.add),
                backgroundColor: colorBlueDark,
              ))
          : Container(),
      body: RefreshIndicator(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
                height: SizeConfig.blockSizeVertical! * 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    (widget.from != "1") &&
                            (widget.from != "12") &&
                            (widget.from != "13")
                        ? Padding(
                            padding: EdgeInsets.only(
                                left: SizeConfig.blockSizeHorizontal! * 2,
                                right: SizeConfig.blockSizeHorizontal! * 2),
                            child: Container(
                              height: SizeConfig.blockSizeVertical! * 10,
                              child: ListView.separated(
                                itemCount: listCategories.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedCategoryIDP =
                                            listCategories[index]
                                                ["categoryIDP"]!;
                                        getPatientReport(context);
                                      });
                                    },
                                    child: Chip(
                                      padding: EdgeInsets.all(
                                          SizeConfig.blockSizeHorizontal! * 3),
                                      label: Text(
                                        listCategories[index]["categoryName"]!,
                                        style: TextStyle(
                                          color: listCategories[index]
                                                      ["categoryIDP"] ==
                                                  selectedCategoryIDP
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      backgroundColor: listCategories[index]
                                                  ["categoryIDP"] ==
                                              selectedCategoryIDP
                                          ? colorBlueDark
                                          : colorWhite,
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 5,
                                  );
                                },
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 5.0,
                    ),
                    Container(
                      height: SizeConfig.blockSizeVertical! * 6,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 1.0,
                                )
                              ]),
                          child: InkWell(
                              onTap: () {
                                showDateRangePickerDialog();
                              },
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      widget.dateString,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.blockSizeVertical! *
                                                  2.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                  ),
                                  Image.asset(
                                    "images/v-2-icn-date.png",
                                    width:
                                        SizeConfig.blockSizeHorizontal! * 5.0,
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: SizeConfig.blockSizeVertical! * 2.0,
                            bottom: SizeConfig.blockSizeVertical! * 8.0),
                        child: listPatientReport.length > 0
                            ? Container(
                                padding: EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: Color(0xfff0f1f5),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: listPatientReport.length,
                                    controller: hideFABController,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          if (widget.fetchPrescription ==
                                              false) {
                                            if (isADocument(index)) {
                                              // downloadAndOpenTheFile(
                                              //     "${baseURL}images/patientreport/${listPatientReport[index].reportImage}",
                                              //     listPatientReport[index]
                                              //         .reportImage);
                                              String downloadPdfUrl =
                                                  "${baseImagePath}images/patientreport/${listPatientReport[index].reportImage}";
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute<dynamic>(
                                                    builder: (_) =>
                                                        PDFViewerCachedFromUrl(
                                                      url: downloadPdfUrl,
                                                    ),
                                                  ));
                                            } else {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return FullScreenImage(
                                                    "${baseImagePath}images/patientreport/${listPatientReport[index].reportImage}");
                                              }));
                                            }
                                          } else {
                                            // reportName,reportDate,reportTime,reportImage
                                            Navigator.pop(context,
                                                listPatientReport[index]);
                                          }
                                        },
                                        child: index == 0
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, bottom: 10.0),
                                                child: Text(
                                                  getTitle(widget.from!),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: SizeConfig
                                                              .blockSizeHorizontal! *
                                                          4.5,
                                                      color: Colorsblack),
                                                ),
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    color: Colors.white,
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                          SizeConfig
                                                                  .blockSizeHorizontal! *
                                                              4),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Container(
                                                              child:
                                                                  isADocument(
                                                                          index)
                                                                      ? InkWell(
                                                                          onTap:
                                                                              () {
                                                                            debugPrint("download file location");
                                                                            debugPrint(
                                                                              "${baseImagePath}images/patientreport/${listPatientReport[index].reportImage}",
                                                                            );
                                                                            // downloadAndOpenTheFile(
                                                                            // "${baseURL}images/patientreport/${listPatientReport[index].reportImage}",
                                                                            // listPatientReport[index].reportImage);
                                                                            String
                                                                                downloadPdfUrl =
                                                                                "${baseImagePath}images/patientreport/${listPatientReport[index].reportImage}";
                                                                            Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute<dynamic>(
                                                                                  builder: (_) => PDFViewerCachedFromUrl(
                                                                                    url: downloadPdfUrl,
                                                                                  ),
                                                                                ));
                                                                            /*OpenFile.open(
                                                                    "${baseURL}images/patientreport/${listPatientReport[index].reportImage}");*/
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Image(
                                                                              image: AssetImage(selectedCategoryIDP == "1" ? "images/v-2-icn-prescription-lrg.png" : "images/ic_doc.png"),
                                                                              fit: BoxFit.fill,
                                                                              width: SizeConfig.blockSizeHorizontal! * 10,
                                                                              height: SizeConfig.blockSizeHorizontal! * 10,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.of(context).push(MaterialPageRoute(builder:
                                                                                (context) {
                                                                              return FullScreenImage("${baseImagePath}images/patientreport/${listPatientReport[index].reportImage}");
                                                                            }));
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              placeholder: (context, url) => Image(
                                                                                width: SizeConfig.blockSizeHorizontal! * 35,
                                                                                height: SizeConfig.blockSizeHorizontal! * 35,
                                                                                image: AssetImage('images/shimmer_effect.png'),
                                                                                fit: BoxFit.fitWidth,
                                                                              ),
                                                                              imageUrl: "${baseImagePath}images/patientreport/${listPatientReport[index].reportImage}",
                                                                              fit: BoxFit.fitWidth,
                                                                              width: SizeConfig.blockSizeHorizontal! * 10,
                                                                              height: SizeConfig.blockSizeHorizontal! * 10,
                                                                            ),
                                                                          ),
                                                                        )),
                                                          SizedBox(
                                                            width: SizeConfig
                                                                    .blockSizeVertical! *
                                                                1.0,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <Widget>[
                                                                Text(
                                                                  listPatientReport[
                                                                          index]
                                                                      .reportTagName,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          SizeConfig.blockSizeHorizontal! *
                                                                              4.5,
                                                                      color:
                                                                          colorBlueDark),
                                                                ),
                                                                SizedBox(
                                                                  height: SizeConfig
                                                                          .blockSizeVertical! *
                                                                      0.5,
                                                                ),
                                                                Text(
                                                                  "${listPatientReport[index].reportDate} , ${listPatientReport[index].reportTime}",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          SizeConfig.blockSizeHorizontal! *
                                                                              3.0),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          (widget.fetchPrescription ==
                                                                  true)
                                                              ? Container()
                                                              : InkWell(
                                                                  onTap: () {
                                                                    deleteReportFromTheList(
                                                                        listPatientReport[index]
                                                                            .patientReportIDP,
                                                                        listPatientReport[index]
                                                                            .reportImage);
                                                                  },
                                                                  child: Image
                                                                      .asset(
                                                                    "images/v-2-icn-delete.png",
                                                                    width: SizeConfig
                                                                            .blockSizeHorizontal! *
                                                                        5.0,
                                                                  ),
                                                                )
                                                        ],
                                                      ),
                                                    )),
                                              ),
                                      );
                                    }),
                              )
                            : widget.emptyMessageWidget,
                      ),

                      /*],
                      )*/
                      /*),*/
                    ),
                  ],
                ))
          ],
        ),
        onRefresh: () {
          return getPatientReport(context);
        },
      ),
      /*)*/
    ));
  }

  Future<void> showDateRangePickerDialog() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (newDateRange == null) return;
    if (newDateRange != null) {
      dateRange = newDateRange;
      widget.fromDate = dateRange.start;
      widget.toDate = dateRange.end;
      print(widget.fromDate);
      print(widget.toDate);
      var formatter = new DateFormat('dd-MM-yyyy');
      widget.fromDateString = formatter.format(widget.fromDate);
      widget.toDateString = formatter.format(widget.toDate);
      widget.dateString =
          "${widget.fromDateString}  to  ${widget.toDateString}";

      setState(() {
        getPatientReport(context);
      });
      //print(picked);
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

  Future<String> getPatientReport(BuildContext context) async {
    getCategoryList(context);
    String loginUrl = "${baseURL}patientReportData.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
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
        "FromDate" +
        "\"" +
        ":" +
        "\"" +
        widget.fromDateString +
        "\"" +
        "," +
        "\"" +
        "ToDate" +
        "\"" +
        ":" +
        "\"" +
        widget.toDateString +
        "\"" +
        "," +
        "\"" +
        "CategoryIDP" +
        "\"" +
        ":" +
        "\"" +
        selectedCategoryIDP +
        "\"" +
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
    //var resBody = json.decode(response.body);
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    debugPrint("response :" + response.body.toString());
    debugPrint("Data :" + model.data!);
    listPatientReport = [];
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);
      /*tableRows = [];
      tableRows.add(TableRow(children: [
        Text(
          "Date",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF06A759)),
        ),
        Text(
          "Type",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF06A759)),
        ),
        Text(
          "Points",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF06A759)),
        ),
        Text("Narration",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF06A759),
            ))
      ]));*/
      for (int i = 0; i < jsonData.length; i++) {
        final jo = jsonData[i];
        listPatientReport.add(ModelReport(
            jo['ReportTagName'],
            jo['ReportDate'],
            jo['ReportTime'],
            jo['ReportImage'],
            jo['PatientReportIDP'],
            jo['CategoryName']));
      }
      setState(() {
        apiCalled = true;
      });
    } else {
      setState(() {
        apiCalled = true;
        /*userName = un;
        rewardPoints = "0";
        apiCalled = true;*/
      });
    }
    return 'success';
  }

  void getCategoryList(BuildContext context) async {
    String loginUrl = "${baseURL}categorylist.php";
    ProgressDialog pr;
    /*Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr.show();
    });*/
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "";

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
    //pr.hide();
    debugPrint("response :" + response.body.toString());
    debugPrint("Data :" + model.data!);
    listCategories = [];
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);
      if (widget.from != "Reports")
        listCategories.add({"categoryName": "All", "categoryIDP": "-"});
      for (int i = 0; i < jsonData.length; i++) {
        final jo = jsonData[i];
        print(widget.from);
        listCategories.add({
          "categoryName": jo['CategoryName'],
          "categoryIDP": jo['CategoryIDP']
        });
        print(listCategories);
        setState(() {});
      }
      if (widget.from == "Reports") {
        // listCategories.remove({
        //   "categoryName": "Prescription'",
        //   "categoryIDP": "1"
        // });
        // listCategories.remove({
        //   "categoryName": 'Certificate',
        //   "categoryIDP": "12"
        // });
        // listCategories.remove({
        //   "categoryName": 'Receipts',
        //   "categoryIDP": "13"
        // });
        listCategories.removeWhere(
          (item) => mapEquals(
              item, ({'categoryName': 'Prescription', 'categoryIDP': '1'})),
        );
        listCategories.removeWhere(
          (item) => mapEquals(
              item, ({'categoryName': 'Certificate', 'categoryIDP': '12'})),
        );
        listCategories.removeWhere(
          (item) => mapEquals(
              item, ({'categoryName': 'Receipts', 'categoryIDP': '13'})),
        );
        setState(() {});
      }
      /*final List<Map<String, String>> listOfColumns = [
        {"Name": "AAAAAA", "Number": "1", "State": "Yes"},
        {"Name": "BBBBBB", "Number": "2", "State": "no"},
        {"Name": "CCCCCC", "Number": "3", "State": "Yes"}
      ];*/
      //String cp = jo['CreditPoints'];
    } else {
      setState(() {});
    }
  }

  void deleteReportFromTheList(
      String patientReportIDP, String reportImage) async {
    String loginUrl = "${baseURL}patientReportDelete.php";

    ProgressDialog pr = ProgressDialog(context);
    pr.show();
    //listIcon = new List();
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
        "PatientReportIDP" +
        "\"" +
        ":" +
        "\"" +
        patientReportIDP +
        "\"" +
        "," +
        "\"" +
        "PatientReportImage" +
        "\"" +
        ":" +
        "\"" +
        reportImage +
        "\"" +
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
    //var resBody = json.decode(response.body);
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr.hide();
    if (model.status == "OK") {
      getPatientReport(context);
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

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

  // Future downloadFileAndOpenActually(
  //     Dio dio, String url, String savePath) async {
  //   try {
  //     pr = ProgressDialog(context);
  //     pr!.show();
  //     /*Response response = await dio.get(
  //       url,
  //       onReceiveProgress: showDownloadProgress,
  //       //Received data with List<int>
  //       options: Options(
  //           responseType: ResponseType.bytes,
  //           followRedirects: false,
  //           validateStatus: (status) {
  //             return status < 500;
  //           }),
  //     );*/
  //     //var response = await http.get(url);
  //     /*var bytes = response.data;
  //     File file = File(savePath);
  //     file.writeAsBytesSync(bytes);*/
  //     //bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  //     //file.writeAsBytes(bytes);
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
  //       saveInPublicStorage:true,
  //       // show download progress in status bar (for Android)
  //       openFileFromNotification:
  //           false, // click on notification to open downloaded file (for Android)
  //     ) /*.then((value) {
  //       taskId = value;
  //     })*/
  //         ;
  //     var tasks = await FlutterDownloader.loadTasks();
  //     /*Future.delayed(Duration(milliseconds: 5000), () {
  //
  //     });*/
  //     /*print(response.headers);
  //     var raf = file.openSync(mode: FileMode.write);
  //     raf.writeFromSync(response.data);
  //     await raf.close();*/
  //     /*if (await canLaunch(file.path)) {
  //       await launch(file.path);
  //     } else {
  //       throw 'Could not launch $url';
  //     }*/
  //     debugPrint("File path");
  //     /*debugPrint(file.path);
  //     OpenFile.open(file.path);*/
  //   } catch (e) {
  //     print("Error downloading");
  //     print(e.toString());
  //   }
  // }

  void _bindBackgroundIsolate() {
    ReceivePort _port = ReceivePort();
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus(data[1]);
      int progress = data[2];
      if (/*status == DownloadTaskStatus.complete*/ status.toString() ==
              "DownloadTaskStatus(3)" &&
          progress == 100) {
        debugPrint("Successfully downloaded");
        pr!.hide();
        String query = "SELECT * FROM task WHERE task_id='" + id + "'";
        var tasks = FlutterDownloader.loadTasksWithRawQuery(query: query);
        FlutterDownloader.open(taskId: id);
      }
      /*if (_tasks != null && _tasks.isNotEmpty) {
        final task = _tasks.firstWhere((task) => task.taskId == id);
        if (task != null) {
          setState(() {
            task.status = status;
            task.progress = progress;
          });
        }
      }*/
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
    //IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  bool isADocument(int index) {
    return listPatientReport[index].reportImage.contains(".pdf") ||
        listPatientReport[index].reportImage.contains(".doc") ||
        listPatientReport[index].reportImage.contains(".docx") ||
        listPatientReport[index].reportImage.contains(".txt");
  }
}

String getTitle(String categoryIDP) {
  if (categoryIDP == "1")
    return "Prescriptions";
  else if (categoryIDP == "12")
    return "Certificates";
  else
    return "Documents";
}
