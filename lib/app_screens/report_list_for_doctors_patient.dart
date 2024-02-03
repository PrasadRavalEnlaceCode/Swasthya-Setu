import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swasthyasetu/utils/common_methods.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:swasthyasetu/app_screens/add_patient_report.dart';
import 'package:swasthyasetu/app_screens/fullscreen_image.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_report.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/widgets/date_range_picker_custom.dart'
    as DateRagePicker;
//import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';

class ReportListForDoctorsPatientScreen extends StatefulWidget {
  String? patientIDP;
  String? from;
  var fromDate = DateTime.now().subtract(Duration(days: 7));
  var toDate = DateTime.now();

  var fromDateString = "";
  var toDateString = "";
  var dateString = "Select Date Range";

  String emptyTextReport1 = "No Document Records found.";

  /*String emptyTextReport2 =
      "Upload a scan copy or take a Photo of your Medical Reports based on different categories and keep them in your records.";
  String emptyTextReport3 =
      "Add a TagName / Document Name to your report and add them in respective category.";*/

  String emptyMessage = "";

  Widget? emptyMessageWidget;
  late DateTimeRange dateRange;

  ReportListForDoctorsPatientScreen(String? patientIDP, String from) {
    this.patientIDP = patientIDP;
    this.from = from;
  }

  @override
  State<StatefulWidget> createState() {
    return ReportListForDoctorsPatientScreenState();
  }
}

class ReportListForDoctorsPatientScreenState
    extends State<ReportListForDoctorsPatientScreen> {
  bool apiCalled = false;
  List<ModelReport> listPatientReport = [];
  List<Map<String, String>> listCategories = [];
  ScrollController? hideFABController;
  var isFABVisible = true;
  var selectedCategoryIDP = "-";
  var selectedCategoryName = "All";
  var taskId;
  ProgressDialog? pr;

  //List<TableRow> tableRows = [];
  late DateTimeRange dateRange;
  var fromDate = DateTime.now().subtract(Duration(days: 7));
  var toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
  //  FlutterDownloader.registerCallback(downloadCallback);
    dateRange = DateTimeRange(
        start: fromDate,
        end: toDate
    );
    widget.emptyMessage =
        "${widget.emptyTextReport1}"; //\n\n${widget.emptyTextReport2}\n\n${widget.emptyTextReport3}
    var formatter = DateFormat('dd-MM-yyyy');
    if (widget.from == "prescription")
      selectedCategoryIDP = "1";
    else
      selectedCategoryIDP = "-";
    widget.fromDateString = formatter.format(widget.fromDate);
    widget.toDateString = formatter.format(widget.toDate);
    widget.dateString = "Select Date Range";

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
              "${widget.emptyMessage}",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
    getPatientReport(context);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @override
  Widget build(BuildContext context) {
    final start = dateRange.start;
    final end = dateRange.end;
    SizeConfig().init(context);
    /*if (!apiCalled) */
    return /*SafeArea(
        child:*/
        Scaffold(
            body: RefreshIndicator(
      child: Stack(
        children: [
          ListView(
            shrinkWrap: true,
            children: <Widget>[
              Container(
                height: SizeConfig.blockSizeVertical !* 100,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: SizeConfig.blockSizeVertical !* 10,
                      width: SizeConfig.blockSizeHorizontal !* 100,
                      color: Color(0xFFF0F0F0),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: SizeConfig.blockSizeHorizontal !* 2,
                            right: SizeConfig.blockSizeHorizontal !* 2),
                        child: Container(
                          height: SizeConfig.blockSizeVertical !* 10,
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
                                        listCategories[index]["categoryIDP"]!;
                                    selectedCategoryName =
                                        listCategories[index]["categoryName"]!;
                                    getPatientReport(context);
                                  });
                                },
                                child: Chip(
                                  padding: EdgeInsets.all(
                                      SizeConfig.blockSizeHorizontal !* 3),
                                  label: Text(
                                    listCategories[index]["categoryName"]!,
                                    style: TextStyle(
                                      color: listCategories[index]
                                                  ["categoryIDP"] ==
                                              selectedCategoryIDP
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                  shape: StadiumBorder(
                                      side: BorderSide(
                                          color: Colors.grey, width: 1.0)),
                                  backgroundColor: listCategories[index]
                                              ["categoryIDP"] ==
                                          selectedCategoryIDP
                                      ? Color(0xFF06A759)
                                      : Color(0xFFF0F0F0),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(
                                width: SizeConfig.blockSizeHorizontal !* 5,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        height: SizeConfig.blockSizeVertical !* 8,
                        color: Color(0xFFF0F0F0),
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Container(
                            child: InkWell(
                                onTap: () {
                                  // showDateRangePickerDialog();
                                },
                                child: Row(
                                  children: <Widget>[
                                    // Expanded(
                                    //   child: Text(
                                    //     "${widget.dateString}",
                                    //     textAlign: TextAlign.left,
                                    //     style: TextStyle(
                                    //         fontSize:
                                    //             SizeConfig.blockSizeVertical !*
                                    //                 2.6,
                                    //         fontWeight: FontWeight.w500,
                                    //         color: Colors.black),
                                    //   ),
                                    // ),
                                    // Container(
                                    //   width:
                                    //       SizeConfig.blockSizeHorizontal !* 15,
                                    //   child: Icon(
                                    //     Icons.arrow_drop_down,
                                    //     size:
                                    //         SizeConfig.blockSizeHorizontal !* 8,
                                    //   ),
                                    // ),
                                    Expanded(
                                        child: ElevatedButton(
                                          child: Text('${start.day}/${start.month}/${start.year}'),
                                          onPressed: pickDateRange,
                                        )
                                    ),
                                    const SizedBox(width: 10,),
                                    Expanded(
                                        child: ElevatedButton(
                                          child: Text('${end.day}/${end.month}/${end.year}'),
                                          onPressed: pickDateRange,
                                        )
                                    ),
                                  ],
                                )),
                            padding: EdgeInsets.all(5.0),
                            /*decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),*/
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: listPatientReport.length > 0
                          ? ListView.builder(
                              itemCount: listPatientReport.length,
                              controller: hideFABController,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    if (isADocument(index)) {
                                      downloadAndOpenTheFile(
                                          "${baseURL}images/patientreport/${listPatientReport[index].reportImage}",
                                          listPatientReport[index].reportImage);
                                    } else {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return FullScreenImage(
                                          "${baseURL}images/patientreport/${listPatientReport[index].reportImage}",
                                        );
                                      }));
                                    }
                                  },
                                  child: Card(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal !* 2),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
                                                children: <Widget>[
                                                  Text(
                                                    listPatientReport[index]
                                                        .reportTagName,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal !*
                                                            4.5),
                                                  ),
                                                  SizedBox(
                                                    height: SizeConfig
                                                            .blockSizeVertical !*
                                                        2,
                                                  ),
                                                  Text(
                                                    listPatientReport[index]
                                                        .categoryName,
                                                    style: TextStyle(
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal !*
                                                            3.5),
                                                  ),
                                                  SizedBox(
                                                    height: SizeConfig
                                                            .blockSizeVertical !*
                                                        1,
                                                  ),
                                                  Text(
                                                    "${listPatientReport[index].reportDate} , ${listPatientReport[index].reportTime}",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal !*
                                                            3.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                                width: SizeConfig
                                                        .blockSizeHorizontal !*
                                                    26,
                                                height: SizeConfig
                                                        .blockSizeHorizontal !*
                                                    33,
                                                child: isADocument(index)
                                                    ? InkWell(
                                                        onTap: () {
                                                          debugPrint(
                                                              "download file location");
                                                          debugPrint(
                                                            "${baseURL}images/patientreport/${listPatientReport[index].reportImage}",
                                                          );
                                                          downloadAndOpenTheFile(
                                                              "${baseURL}images/patientreport/${listPatientReport[index].reportImage}",
                                                              listPatientReport[
                                                                      index]
                                                                  .reportImage);
                                                        },
                                                        child: Container(
                                                          child: Image(
                                                            image: AssetImage(
                                                                "images/ic_doc.png"),
                                                            fit: BoxFit.fill,
                                                            width: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                26,
                                                            height: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                33,
                                                          ),
                                                        ),
                                                      )
                                                    : InkWell(
                                                        onTap: () {
                                                          /*downloadAndOpenTheFile(
                                                                "${baseURL}images/patientreport/${listPatientReport[index].reportImage}",
                                                                listPatientReport[
                                                                        index]
                                                                    .reportImage);*/
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) {
                                                            return FullScreenImage(
                                                                "${baseURL}images/patientreport/${listPatientReport[index].reportImage}");
                                                          }));
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                            color: Colors.green,
                                                            width: 1,
                                                          )),
                                                          child:
                                                              CachedNetworkImage(
                                                                  placeholder:
                                                                      (context,
                                                                              url) =>
                                                                          Image(
                                                                            width:
                                                                                SizeConfig.blockSizeHorizontal !* 35,
                                                                            height:
                                                                                SizeConfig.blockSizeHorizontal !* 35,
                                                                            image:
                                                                                AssetImage('images/shimmer_effect.png'),
                                                                            fit:
                                                                                BoxFit.fitWidth,
                                                                          ),
                                                                  imageUrl:
                                                                      "${baseURL}images/patientreport/${listPatientReport[index].reportImage}",
                                                                  fit: BoxFit
                                                                      .fitWidth,
                                                                  width: SizeConfig
                                                                          .blockSizeHorizontal !*
                                                                      35,
                                                                  height: SizeConfig
                                                                          .blockSizeHorizontal !*
                                                                      35),
                                                        ),
                                                      )),
                                            /*Container(
                                          width:
                                              SizeConfig.blockSizeHorizontal *
                                                  12,
                                          child: InkWell(
                                            onTap: () {
                                              deleteReportFromTheList(
                                                  listOfColumns[index]
                                                      .patientReportIDP,
                                                  listOfColumns[index]
                                                      .reportImage);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: SizeConfig
                                                      .blockSizeHorizontal *
                                                  8,
                                            ),
                                          ),
                                        ),*/
                                          ],
                                        ),
                                      )),
                                );
                              })
                          : SizedBox(
                              height: SizeConfig.blockSizeVertical !* 80,
                              child: Container(
                                padding: EdgeInsets.all(
                                    SizeConfig.blockSizeHorizontal !* 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Image(
                                      image:
                                          AssetImage("images/ic_idea_new.png"),
                                      width: 100,
                                      height: 100,
                                    ),
                                    SizedBox(
                                      height: 30.0,
                                    ),
                                    Text(
                                      "No Document Records found for $selectedCategoryName.",
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
              )
            ],
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(
                  SizeConfig.blockSizeHorizontal !* 3,
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return AddPatientReportScreen(
                          widget.patientIDP!, selectedCategoryIDP);
                    })).then((value) {
                      getPatientReport(context);
                    });
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Colors.black,
                ),
              )),
        ],
      ),
      onRefresh: () {
        return getPatientReport(context);
      },
    ));
  }

  Future<void> showDateRangePickerDialog() async {
    // final List<DateTime?>? listPicked = await DateRagePicker.showDatePicker(
    //     context: context,
    //     initialFirstDate: widget.fromDate,
    //     initialLastDate: widget.toDate,
    //     firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
    //     lastDate: DateTime.now(),
    //     handleOk: () {},
    //     handleCancel: () {});
    // if (listPicked!.length == 2) {
    //   widget.fromDate = listPicked[0]!;
    //   widget.toDate = listPicked[1]!;
    //   var formatter = new DateFormat('dd-MM-yyyy');
    //   widget.fromDateString = formatter.format(widget.fromDate);
    //   widget.toDateString = formatter.format(widget.toDate);
    //   widget.dateString =
    //       "${widget.fromDateString}  to  ${widget.toDateString}";
    //   setState(() {
    //     getPatientReport(context);
    //   });
      //print(picked);
    // }
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
    String loginUrl = "${baseURL}patientReportDataDoctor.php";
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
    String fromDate = "";
    String toDate = "";
    if (widget.dateString != "Select Date Range") {
      fromDate = widget.fromDateString;
      toDate = widget.toDateString;
    }
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
        fromDate +
        "\"" +
        "," +
        "\"" +
        "ToDate" +
        "\"" +
        ":" +
        "\"" +
        toDate +
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
      listCategories.add({"categoryName": "All", "categoryIDP": "-"});
      for (int i = 0; i < jsonData.length; i++) {
        final jo = jsonData[i];
        listCategories.add({
          "categoryName": jo['CategoryName'],
          "categoryIDP": jo['CategoryIDP']
        });
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

  Future pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if(newDateRange == null) return;

    setState(() {
      dateRange = newDateRange;
      fromDate = dateRange.start;
      toDate = dateRange.end;
    });
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
      DownloadTaskStatus status = data[1];
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
    });
  }

  // void downloadAndOpenTheFile(String url, String fileName) async {
  //   // var tempDir = Platform.isAndroid
  //   //     ? await getExternalStorageDirectory()
  //   //     : await getApplicationDocumentsDirectory();
  //   //await tempDir.create(recursive: true);
  //   // String fullPath = tempDir!.path + "/$fileName";
  //   var fullPath = '/storage/emulated/0/Download/$fileName';
  //   debugPrint("full path");
  //   debugPrint(fullPath);
  //   Dio dio = Dio();
  //   downloadFileAndOpenActually(dio, url, fullPath);
  // }

  // Future downloadFileAndOpenActually(Dio dio, String url,String savePath) async {
  //   print('downloadFileAndOpenActually $savePath');
  //   try {
  //     Response response = await dio.get(
  //       url,
  //       onReceiveProgress: showDownloadProgress,
  //       //Received data with List<int>
  //       options: Options(
  //           responseType: ResponseType.bytes,
  //           followRedirects: false,
  //           validateStatus: (status) {
  //             return status! < 500;
  //           }),
  //     );
  //     print(response.headers);
  //     File file = File(savePath);
  //     var raf = file.openSync(mode: FileMode.write);
  //     // response.data is List<int> type
  //     raf.writeFromSync(response.data);
  //     await raf.close();
  //     await openFile(savePath);
  //   } catch (e) {
  //     print('Error downloading');
  //     print(e);
  //   }
  // }

  // void showDownloadProgress(received, total) {
  //   if (total != -1) {
  //     print((received / total * 100).toStringAsFixed(0) + "%");
  //   }
  // }
  //
  // static void downloadCallback(
  //     String id, int status, int progress) {
  //   final SendPort? send =
  //   IsolateNameServer.lookupPortByName('downloader_send_port');
  //   send!.send([id, status, progress]);
  // }

  // var _openResult = 'Unknown';
  // Future<void> openFile(filePath) async
  // {
  //   print('filePath $filePath');
  //   final result = await OpenFilex.open(filePath);
  //   setState(() {
  //     _openResult = "type=${result.type}  message=${result.message}";
  //   });
  // }

  bool isADocument(int index) {
    return listPatientReport[index].reportImage.contains(".pdf") ||
        listPatientReport[index].reportImage.contains(".doc") ||
        listPatientReport[index].reportImage.contains(".docx") ||
        listPatientReport[index].reportImage.contains(".txt");
  }
}
