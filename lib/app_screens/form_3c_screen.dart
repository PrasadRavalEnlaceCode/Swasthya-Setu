import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:silvertouch/app_screens/PDFViewerCachedFromUrl.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import '../utils/color.dart';
import '../utils/common_methods.dart';

class Form3CScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Form3CScreenState();
  }
}

class Form3CScreenState extends State<Form3CScreen> {
  var fromDate = DateTime.now().subtract(Duration(days: 7));
  var toDate = DateTime.now();

  var fromDateString = "";
  var toDateString = "";
  var taskId;
  ProgressDialog? pr;
  late DateTimeRange dateRange;

  @override
  void initState() {
    super.initState();
    dateRange = DateTimeRange(start: fromDate, end: toDate);
    // _bindBackgroundIsolate();
    // FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    // _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = dateRange.start;
    final end = dateRange.end;
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Form 3C"),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(color: Colorsblack),
        toolbarTextStyle: TextTheme(
          titleLarge: TextStyle(
            color: Colorsblack,
            fontFamily: "Ubuntu",
            fontSize: SizeConfig.blockSizeVertical! * 2.5,
          ),
        ).bodyMedium,
        titleTextStyle: TextTheme(
          titleLarge: TextStyle(
            color: Colorsblack,
            fontFamily: "Ubuntu",
            fontSize: SizeConfig.blockSizeVertical! * 2.5,
          ),
        ).titleLarge,
      ),
      body: Builder(
        builder: (context) {
          return Column(
            children: [
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 2,
              ),
              Container(
                height: SizeConfig.blockSizeVertical! * 8,
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
                            //     fromDateString == ""
                            //         ? "Select Date Range"
                            //         : "$fromDateString  to  $toDateString",
                            //     textAlign: TextAlign.center,
                            //     style: TextStyle(
                            //         fontSize:
                            //             SizeConfig.blockSizeVertical !* 2.6,
                            //         fontWeight: FontWeight.w500,
                            //         color: Colors.black),
                            //   ),
                            // ),
                            // Container(
                            //   width: SizeConfig.blockSizeHorizontal !* 15,
                            //   child: Icon(
                            //     Icons.arrow_drop_down,
                            //     size: SizeConfig.blockSizeHorizontal !* 8,
                            //   ),
                            // ),
                            Expanded(
                                child: ElevatedButton(
                              child: Text(
                                  '${start.day}-${start.month}-${start.year}'),
                              onPressed: pickDateRange,
                            )),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: ElevatedButton(
                              child:
                                  Text('${end.day}-${end.month}-${end.year}'),
                              onPressed: pickDateRange,
                            )),
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
                height: SizeConfig.blockSizeVertical! * 2,
              ),
              MaterialButton(
                onPressed: () {
                  if (fromDate == "") {
                    final snackBar = SnackBar(
                      backgroundColor: Colors.red,
                      content: Text("Please select Date Range"),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    return;
                  }
                  getPdfDownloadPath(context);
                },
                color: Colors.blue,
                child: Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  // Future<void> showDateRangePickerDialog() async {
  //   // final List<DateTime?>? listPicked = await DateRagePicker.showDatePicker(
  //   //     context: context,
  //   //     initialFirstDate: fromDate,
  //   //     initialLastDate: toDate,
  //   //     firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
  //   //     lastDate: DateTime.now(),
  //   //     handleOk: () {},
  //   //     handleCancel: () {});
  //   // if (listPicked!.length == 2) {
  //   //   fromDate = listPicked[0]!;
  //   //   toDate = listPicked[1]!;
  //   //   var formatter = new DateFormat('dd-MM-yyyy');
  //   //   fromDateString = formatter.format(fromDate);
  //   //   toDateString = formatter.format(toDate);
  //   //   setState(() {});
  //   // }
  //   // showCustomDateRangePicker(
  //   //   context,
  //   //   dismissible: true,
  //   //   minimumDate: DateTime.now().subtract(Duration(days: 365 * 100)),
  //   //   maximumDate: DateTime.now(),
  //   //   endDate: toDate,
  //   //   startDate: fromDate,
  //   //   backgroundColor: Colors.white,
  //   //   primaryColor: Colors.blue,
  //   //   onApplyClick: (start, end) {
  //   //     setState(() {
  //   //       fromDate = start;
  //   //       toDate = end;
  //   //       var formatter = new DateFormat('dd-MM-yyyy');
  //   //       fromDateString = formatter.format(fromDate);
  //   //       toDateString = formatter.format(toDate);
  //   //       // dateString =
  //   //       // "${fromDateString}  to  ${toDateString}";
  //   //       // getCategoryList(context);
  //   //       //print(picked);
  //   //     });
  //   //   },
  //   //   onCancelClick: () {
  //   //     setState(() {
  //   //       fromDate = DateTime.now().subtract(Duration(days: 7));
  //   //       toDate = DateTime.now();
  //   //        getCategoryList(context);
  //   //     });
  //   //   },
  //   // );
  // }

  Future pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (newDateRange == null) return;

    setState(() {
      dateRange = newDateRange;
      fromDate = dateRange.start;
      toDate = dateRange.end;
      var formatter = new DateFormat('dd-MM-yyyy');
      fromDateString = formatter.format(fromDate);
      toDateString = formatter.format(toDate);
    });
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  // static void downloadCallback(
  //     String id, int status, int progress) {
  //   final SendPort? send =
  //       IsolateNameServer.lookupPortByName('downloader_send_port');
  //   send!.send([id, status, progress]);
  // }
  //
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
  //       FlutterDownloader.open(taskId: id);
  //     }
  //   });
  // }
  //
  // void _unbindBackgroundIsolate() {
  //   IsolateNameServer.removePortNameMapping('downloader_send_port');
  // }

  void getPdfDownloadPath(BuildContext context) async {
    if (fromDateString.isEmpty && toDateString.isEmpty) {
      fromDate = DateTime.now().subtract(Duration(days: 7));
      toDate = DateTime.now();
      fromDateString = DateFormat('yyyy-MM-dd').format(fromDate);
      toDateString = DateFormat('yyyy-MM-dd').format(toDate);
    }

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
    debugPrint(encodedJSONStr);
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
      String downloadPdfUrl = "${baseURL}images/form3cdoc/$fileName";
      Navigator.push(
          context,
          MaterialPageRoute<dynamic>(
            builder: (_) => PDFViewerCachedFromUrl(
              url: downloadPdfUrl,
            ),
          ));
      // downloadAndOpenTheFile(downloadPdfUrl, fileName);
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr!.hide();
    }
  }

  // void downloadAndOpenTheFile(String url,String fileName) async
  // {
  //   var fullPath = '/storage/emulated/0/Download/$fileName';
  //   debugPrint("full path");
  //   debugPrint(fullPath);
  //   Dio dio = Dio();
  //   downloadFileAndOpenActually(dio,url,fullPath);
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

  // var _openResult = 'Unknown';
  // Future<void> openFile(filePath) async
  // {
  //   print('filePath $filePath');
  //   final result = await OpenFilex.open(filePath);
  //   setState(() {
  //     _openResult = "type=${result.type}  message=${result.message}";
  //   });
  // }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }
}
