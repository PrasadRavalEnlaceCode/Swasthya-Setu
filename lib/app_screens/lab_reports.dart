import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:dio/dio.dart' as DIO;
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:swasthyasetu/app_screens/PDFViewerCachedFromUrl.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_opd_reg.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import '../utils/color.dart';
import '../utils/common_methods.dart';

class LabReportsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LabReportsScreenState();
  }
}

class LabReportsScreenState extends State<LabReportsScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  late DateTimeRange dateRange;
  var fromDateString = "";
  var toDateString = "";
  var taskId;
  ProgressDialog? pr;
  List<ModelOPDRegistration> listOPDRegistration = [];
  Widget? emptyMessageWidget;
  String emptyMessage = "No Lab Reports found.";

  @override
  void initState() {
    super.initState();
    // _bindBackgroundIsolate();
    // FlutterDownloader.registerCallback(downloadCallback);
    var formatter = new DateFormat('dd-MM-yyyy');
    fromDate = DateTime.now().subtract(const Duration(days: 30));
    toDate = DateTime.now();
    fromDateString = formatter.format(fromDate!);
    toDateString = formatter.format(toDate!);
    dateRange = DateTimeRange(
        start: fromDate!,
        end: toDate!
    );
    emptyMessageWidget = Center(
      child: SizedBox(
        height: SizeConfig.blockSizeVertical !* 80,
        width: SizeConfig.blockSizeHorizontal !* 100,
        child: Container(
          padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
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
                "${emptyMessage}",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
    getLabReports();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = dateRange.start;
    final end = dateRange.end;
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Lab Reports"),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(color: Colorsblack), toolbarTextStyle: TextTheme(
          titleLarge: TextStyle(
            color: Colorsblack,
            fontFamily: "Ubuntu",
            fontSize: SizeConfig.blockSizeVertical !* 2.5,
          ),
        ).bodyMedium, titleTextStyle: TextTheme(
          titleLarge: TextStyle(
            color: Colorsblack,
            fontFamily: "Ubuntu",
            fontSize: SizeConfig.blockSizeVertical !* 2.5,
          ),
        ).titleLarge,
      ),
      body: Builder(
        builder: (context) {
          return ColoredBox(
            color: Colors.grey,
            child: Column(
              children: [
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 2,
                ),
                Container(
                  height: SizeConfig.blockSizeVertical !* 8,
                  child: Padding(
                    padding: EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Container(
                      child:
                      InkWell(
                          onTap: () async {
                            // showDateRangePickerDialog();
                          },
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: ElevatedButton(
                                  child: Text('${start.day}-${start.month}-${start.year}'),
                                  onPressed: pickDateRange,
                                )
                              ),
                              const SizedBox(width: 10,),
                              Expanded(
                                  child: ElevatedButton(
                                    child: Text('${end.day}-${end.month}-${end.year}'),
                                    onPressed: pickDateRange,
                                  )
                              ),
                            ],
                          )),
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 2,
                ),
                Expanded(
                  child:
                  listOPDRegistration.length > 0
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: listOPDRegistration.length,
                          itemBuilder: (context, index) {
                            return Padding(
                                padding: EdgeInsets.only(
                                    left: SizeConfig.blockSizeHorizontal !* 2,
                                    right: SizeConfig.blockSizeHorizontal !* 2,
                                    bottom: SizeConfig.blockSizeHorizontal !* 3),
                                child: InkWell(
                                  onTap: () {
                                    if (listOPDRegistration[index]
                                            .reportUploadStatus ==
                                        "1") {
                                      // downloadAndOpenTheFile(
                                      //     "${baseURL}images/labreports/${listOPDRegistration[index].reportFileName}",
                                      //     listOPDRegistration[index]
                                      //         .reportFileName!);
                                      String downloadPdfUrl = "${baseURL}images/labreports/${listOPDRegistration[index].reportFileName}";
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute<dynamic>(
                                            builder: (_) => PDFViewerCachedFromUrl(
                                              url: downloadPdfUrl,
                                            ),
                                          ));
                                    }
                                  },
                                  child: Card(
                                      color: listOPDRegistration[index]
                                                  .reportUploadStatus ==
                                              "1"
                                          ? Colors.blueGrey[100]
                                          : Colors.white,
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal !* 3),
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                listOPDRegistration[index]
                                                            .reportUploadStatus ==
                                                        "1"
                                                    ? FaIcon(
                                                        FontAwesomeIcons
                                                            .checkCircle,
                                                        color: Colors.black,
                                                        size: 30.0,
                                                      )
                                                    /*Image(
                                                      image: AssetImage(
                                                          "images/ic_report_dashbaord.png"),
                                                      color: Colors.white,
                                                      width: 30.0,
                                                      height: 30.0,
                                                    )*/
                                                    // : Lottie.asset(
                                                    //     'assets/json/lottie_timer.json',
                                                    //     width: 30.0,
                                                    //     height: 30.0,
                                                    //   ),
                                              : Container(),
                                                SizedBox(
                                                  width: SizeConfig
                                                          .blockSizeHorizontal !*
                                                      3,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          FaIcon(
                                                            FontAwesomeIcons
                                                                .calendarAlt,
                                                            size: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                3.6,
                                                            color: listOPDRegistration[
                                                                            index]
                                                                        .reportUploadStatus ==
                                                                    "1"
                                                                ? Colors.black
                                                                : Colors
                                                                    .blueGrey,
                                                          ),
                                                          SizedBox(
                                                            width: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                2.0,
                                                          ),
                                                          Text(
                                                            listOPDRegistration[
                                                                    index]
                                                                .vidCallDate!,
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: listOPDRegistration[
                                                                              index]
                                                                          .reportUploadStatus ==
                                                                      "1"
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .blueGrey,
                                                              fontSize: SizeConfig
                                                                      .blockSizeHorizontal !*
                                                                  3.6,
                                                              letterSpacing:
                                                                  1.4,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: SizeConfig
                                                                .blockSizeVertical !*
                                                            1.3,
                                                      ),
                                                      Text(
                                                        listOPDRegistration[
                                                                index]
                                                            .doctorName!,
                                                        style: TextStyle(
                                                            color: listOPDRegistration[
                                                                            index]
                                                                        .reportUploadStatus ==
                                                                    "1"
                                                                ? Colors.black
                                                                : Colors.black,
                                                            fontSize: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                4.3,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            letterSpacing: 1.8,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(
                                                        height: SizeConfig
                                                                .blockSizeVertical !*
                                                            1.0,
                                                      ),
                                                      Text(
                                                        listOPDRegistration[
                                                                index]
                                                            .name!,
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: listOPDRegistration[
                                                                          index]
                                                                      .reportUploadStatus ==
                                                                  "1"
                                                              ? Colors.black
                                                              : Colors.blueGrey,
                                                          fontSize: SizeConfig
                                                                  .blockSizeHorizontal !*
                                                              3,
                                                          letterSpacing: 1.4,
                                                        ),
                                                      ),
                                                      listOPDRegistration[index]
                                                                  .reportUploadStatus ==
                                                              "1"
                                                          ? SizedBox(
                                                              height: SizeConfig
                                                                      .blockSizeVertical !*
                                                                  2.0,
                                                            )
                                                          : Container(),
                                                      listOPDRegistration[index]
                                                                  .reportUploadStatus ==
                                                              "1"
                                                          ? InkWell(
                                                              onTap: () {
                                                                showSendMessageBottomSheet(
                                                                    listOPDRegistration[
                                                                        index]);
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50.0),
                                                                ),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Text(
                                                                      "Send Message",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            SizeConfig.blockSizeHorizontal !*
                                                                                3.6,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: SizeConfig
                                                                              .blockSizeHorizontal !*
                                                                          1.0,
                                                                    ),
                                                                    FaIcon(
                                                                      Icons
                                                                          .send,
                                                                      color: Colors
                                                                          .black,
                                                                      size: SizeConfig
                                                                              .blockSizeHorizontal !*
                                                                          4.4,
                                                                    ),
                                                                  ],
                                                                ).paddingSymmetric(
                                                                  horizontal:
                                                                      SizeConfig
                                                                              .blockSizeHorizontal !*
                                                                          3.0,
                                                                  vertical:
                                                                      SizeConfig
                                                                              .blockSizeVertical !*
                                                                          0.5,
                                                                ),
                                                              ),
                                                            )
                                                          : Container(),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: SizeConfig
                                                          .blockSizeHorizontal !*
                                                      6.0,
                                                ),
                                                Column(
                                                  children: [
                                                    listOPDRegistration[index]
                                                                .reportUploadStatus ==
                                                            "1"
                                                        ? InkWell(
                                                            onTap: () {
                                                              // downloadAndOpenTheFile(
                                                              //     "${baseURL}images/labreports/${listOPDRegistration[index].reportFileName}",
                                                              //     listOPDRegistration[
                                                              //             index]
                                                              //         .reportFileName!);
                                                              String downloadPdfUrl = "${baseURL}images/labreports/${listOPDRegistration[index].reportFileName}";
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute<dynamic>(
                                                                    builder: (_) => PDFViewerCachedFromUrl(
                                                                      url: downloadPdfUrl,
                                                                    ),
                                                                  ));
                                                            },
                                                            child: FaIcon(
                                                              FontAwesomeIcons
                                                                  .solidFilePdf,
                                                              size: SizeConfig
                                                                      .blockSizeHorizontal !*
                                                                  7,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          )
                                                        : Container(),
                                                    SizedBox(
                                                      height: SizeConfig
                                                              .blockSizeVertical !*
                                                          1.0,
                                                    ),
                                                    listOPDRegistration[index]
                                                                .reportUploadStatus ==
                                                            "1"
                                                        ? Text(
                                                            "[${listOPDRegistration[index].reportUploadedDate}]",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: SizeConfig
                                                                        .blockSizeHorizontal !*
                                                                    3.0,
                                                                letterSpacing:
                                                                    1.8,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        : Container(),
                                                  ],
                                                )
                                                /*InkWell(
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
                                          ],
                                        ),
                                      )),
                                ));
                          })
                      : emptyMessageWidget!,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // Future<void> showDateRangePickerDialog() async {
  //
  //   // showCustomDateRangePicker(
  //   //   context,
  //   //   dismissible: true,
  //   //   minimumDate: DateTime.now().subtract(const Duration(days: 30)),
  //   //   maximumDate: DateTime.now(),
  //   //   endDate: toDate,
  //   //   startDate: fromDate,
  //   //   backgroundColor: Colors.white,
  //   //   primaryColor: Colors.blue,
  //   //   onApplyClick: (start, end) {
  //   //     setState(() {
  //   //       toDate = end;
  //   //       fromDate = start;
  //   //       var formatter = new DateFormat('dd-MM-yyyy');
  //   //       fromDateString = formatter.format(fromDate!);
  //   //       toDateString = formatter.format(toDate!);
  //   //       //dateString = "${fromDateString}  to  ${toDateString}";
  //   //       getLabReports();
  //   //     });
  //   //   },
  //   //   onCancelClick: () {
  //   //     setState(()
  //   //     {
  //   //       fromDate = DateTime.now().subtract(Duration(days: 7));
  //   //       toDate = DateTime.now();
  //   //       getLabReports();
  //   //       // toDate = null;
  //   //       // fromDate = null;
  //   //     });
  //   //   },
  //   // );
  // }

  Future pickDateRange() async
  {
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
      var formatter = new DateFormat('dd-MM-yyyy');
      fromDateString = formatter.format(fromDate!);
      toDateString = formatter.format(toDate!);
      getLabReports();
    });
  }
  
  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  static void downloadCallback(
      String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
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

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  void getLabReports() async {
    listOPDRegistration = [];
    String loginUrl = "${baseURL}doctorPatientLabReports.php";
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
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"" +
        "FromDate" +
        "\"" +
        ":" +
        "\"" +
        fromDateString +
        "\"" +
        "," +
        "\"" +
        "ToDate" +
        "\"" +
        ":" +
        "\"" +
        toDateString +
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
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listOPDRegistration.add(ModelOPDRegistration(
          jo['DoctorPatientProviderIDP'].toString(),
          jo['ProviderCompanyName'],
          jo['TotalAmount'].toString(),
          "",
          patientIDP: jo['PatientIDF'].toString(),
          doctorName: jo['FirstName'].trim() +
              " " +
              jo['LastName'].trim() +
              "(" +
              jo['Gender'] +
              "/" +
              jo['years'] +
              ")",
          reportUploadStatus: jo['ReportUploadStatus'],
          reportFileName: jo['ReportFileName'],
          vidCallDate: jo['labdate'],
          reportUploadedDate: jo['reportdate'],
          healthCareProviderIDF: jo['HealthCareProviderIDF'],
        ));
      }
      setState(() {});
    }
  }

  void getPdfDownloadPath(BuildContext context) async {
    String loginUrl = "${baseURL}formpdfdoc.php";

    pr = ProgressDialog(context);
    pr!.show();
    String doctorIDP = await getPatientOrDoctorIDP();
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
        doctorIDP +
        "\"," +
        "\"" +
        "fromdate" +
        "\"" +
        ":" +
        "\"" +
        fromDateString +
        "\"" +
        ",\"todate\":\"$toDateString\"" +
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
      // String downloadPdfUrl = "${baseURL}images/form3cdoc/$fileName";
      // downloadAndOpenTheFile(downloadPdfUrl, fileName);
      // downloadAndOpenTheFile(downloadPdfUrl,fileName);
      String downloadPdfUrl = "${baseURL}images/form3cdoc/$fileName";
      Navigator.push(
          context,
          MaterialPageRoute<dynamic>(
            builder: (_) => PDFViewerCachedFromUrl(
              url: downloadPdfUrl,
            ),
          ));
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr!.hide();
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

  // void downloadAndOpenTheFile(String url,String fileName) async
  // {
  //   var fullPath = '/storage/emulated/0/Download/$fileName';
  //   debugPrint("full path");
  //   debugPrint(fullPath);
  //   DIO.Dio dio = DIO.Dio();
  //   downloadFileAndOpenActually(dio,url,fullPath);
  // }

  // Future<void> openFile(filePath) async
  // {
  //   print('filePath $filePath');
  //   final result = await OpenFilex.open(filePath);
  //   // setState(() {
  //   //   _openResult = "type=${result.type}  message=${result.message}";
  //   // });
  // }

  // Future downloadFileAndOpenActually(DIO.Dio dio, String url,String savePath) async {
  //   print('downloadFileAndOpenActually $savePath');
  //   try {
  //     DIO.Response response = await dio.get(
  //       url,
  //       onReceiveProgress: showDownloadProgress,
  //       //Received data with List<int>
  //       options: DIO.Options(
  //           responseType: DIO.ResponseType.bytes,
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

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }

  void showSendMessageBottomSheet(ModelOPDRegistration model) {
    TextEditingController messageController = TextEditingController();
    Get.bottomSheet(
      Material(
        child: Container(
          height: SizeConfig.blockSizeVertical !* 33,
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal !* 5.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 1.5,
              ),
              Text(
                "Send message to ${model.name}",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: SizeConfig.blockSizeHorizontal !* 4.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 1.5,
              ),
              Container(
                color: Colors.blueGrey,
                width: SizeConfig.blockSizeHorizontal !* 10.0,
                height: 2.0,
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 1.5,
              ),
              Expanded(
                child: TextField(
                  controller: messageController,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  minLines: 5,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: "Your Message here.",
                    counterText: "",
                  ),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  sendMessage(model, messageController.text);
                },
                color: Colors.green,
                child: Text(
                  "Send",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 1.5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendMessage(ModelOPDRegistration modelOPD, String message) async {
    if (message.trim().isEmpty) {
      /*Get.back();
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please Enter Message to send."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(milliseconds: 1500), () {
        showSendMessageBottomSheet(modelOPD);
      });*/
      return;
    }
    final String urlGetChannelIDForVidCall =
        "${baseURL}doctorLabAcknowledge.php";
    ProgressDialog pr = ProgressDialog(context);
    pr.show();

    try {
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      String doctorIDP = await getPatientOrDoctorIDP();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String jsonStr = "{" +
          "\"PatientIDF\":\"${modelOPD.patientIDP}\"" +
          ",\"DoctorIDP\":\"$doctorIDP\"" +
          ",\"DoctorPatientProviderIDP\":\"${modelOPD.idp}\"" +
          ",\"HealthCareProviderIDF\":\"${modelOPD.healthCareProviderIDF}\"" +
          ",\"Message\":\"$message\"" +
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
        final snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Future.delayed(Duration(milliseconds: 1500), () {
          Get.back();
        });
      } else {}
    } catch (exception) {}
  }
}
