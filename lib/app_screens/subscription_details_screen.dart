import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/podo/subscription_history_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:dio/dio.dart';
import 'package:swasthyasetu/widgets/extensions.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  final String expiryDate;

  SubscriptionDetailsScreen(this.expiryDate);

  @override
  State<StatefulWidget> createState() {
    return SubscriptionDetailsScreenState();
  }
}

class SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  List<SubscriptionHistoryModel> listSubscriptionHistory = [];
  bool isLoading = true;
  ProgressDialog? pr;
  var taskId;

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    getSubscriptionHistory();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Subscription Details"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
            color: Colors.black, size: SizeConfig.blockSizeVertical !* 2.5),
        elevation: 0, toolbarTextStyle: TextTheme(
            titleLarge: TextStyle(
                color: Colors.white,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical !* 2.5)).bodyMedium, titleTextStyle: TextTheme(
            titleLarge: TextStyle(
                color: Colors.white,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical !* 2.5)).titleLarge,
      ),
      body: Container(
        padding: EdgeInsets.all(
          SizeConfig.blockSizeHorizontal !* 4.0,
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image(
              width: SizeConfig.blockSizeHorizontal !* 25,
              height: SizeConfig.blockSizeHorizontal !* 25,
              //height: 80,
              image: AssetImage("images/swasthya_setu_logo.jpeg"),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical !* 1.0,
            ),
            Text(
              "Subscription Status",
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                color: Colors.red,
                fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                letterSpacing: 1.0,
                height: 1.4,
              ),
            ),
            Text(
              "Valid till",
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                color: Colors.red,
                fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                letterSpacing: 1.0,
                height: 1.4,
              ),
            ),
            Text(
              widget.expiryDate,
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                color: Colors.green,
                fontSize: SizeConfig.blockSizeHorizontal !* 6.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
                height: 1.2,
              ),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical !* 2.0,
            ),
            Text(
              "Subscription History",
              textAlign: TextAlign.start,
              softWrap: true,
              style: TextStyle(
                color: Colors.grey,
                fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
                height: 1.6,
              ),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical !* 2.0,
            ),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: listSubscriptionHistory.length,
                      itemBuilder: (context, index) {
                        SubscriptionHistoryModel model =
                            listSubscriptionHistory[index];
                        return Row(
                          children: [
                            Container(
                              margin: EdgeInsets.all(5.0),
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white,
                                        Color(0xFF636F7B),
                                        Colors.black,
                                      ]),
                                  color: Color(0xFF636F7B)),
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          SizeConfig.blockSizeHorizontal !* 3.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  )),
                                  /*padding: EdgeInsets.all(
                                      SizeConfig.blockSizeHorizontal * 3.0),*/
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Activation",
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: SizeConfig
                                                                  .blockSizeHorizontal !*
                                                              3.0,
                                                          letterSpacing: 2.5,
                                                        ),
                                                      ).pO(
                                                          bottom: SizeConfig
                                                                  .blockSizeVertical !*
                                                              0.3),
                                                      Text(
                                                        model.activationDate!,
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: SizeConfig
                                                                  .blockSizeHorizontal !*
                                                              4.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: 2.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Expiry",
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: SizeConfig
                                                                  .blockSizeHorizontal !*
                                                              3.0,
                                                          letterSpacing: 1.5,
                                                        ),
                                                      ).pO(
                                                          bottom: SizeConfig
                                                                  .blockSizeVertical !*
                                                              0.3),
                                                      Text(
                                                        model.expiryDate!,
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: SizeConfig
                                                                  .blockSizeHorizontal !*
                                                              4.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: 1.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: SizeConfig
                                                          .blockSizeHorizontal !*
                                                      1.0,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height:
                                                  SizeConfig.blockSizeVertical !*
                                                      1.0,
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Via " + model.mode!,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: SizeConfig
                                                          .blockSizeHorizontal !*
                                                      3.0,
                                                  letterSpacing: 2.5,
                                                ),
                                              ),
                                            ).pO(
                                                bottom: SizeConfig
                                                        .blockSizeVertical !*
                                                    0.3),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                model.details == ""
                                                    ? "-"
                                                    : model.details!,
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: SizeConfig
                                                          .blockSizeHorizontal !*
                                                      4.0,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ),
                                            /*Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Mode",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal *
                                                        3.0,
                                                    letterSpacing: 2.5,
                                                  ),
                                                ),
                                                Text(
                                                  model.mode,
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal *
                                                        4.0,
                                                    letterSpacing: 2.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Details",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal *
                                                        3.0,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                                Text(
                                                  model.details == ""
                                                      ? "-"
                                                      : model.details,
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal *
                                                        4.0,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width:
                                                SizeConfig.blockSizeHorizontal *
                                                    5.0,
                                            height:
                                                SizeConfig.blockSizeHorizontal *
                                                    5.0,
                                          ),
                                        ],
                                      ),*/
                                            /*Row(
                                        children: [
                                          Text(
                                            "Expiry Date",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal *
                                                  4.0,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              model.activationDate,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal *
                                                    4.0,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),*/
                                            /*Row(
                                        children: [
                                          Text(
                                            "Mode",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal *
                                                  4.0,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              model.mode,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal *
                                                    4.0,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Details",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal *
                                                  4.0,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              model.details == ""
                                                  ? "-"
                                                  : model.details,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal *
                                                    4.0,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),*/
                                          ],
                                        ).pS(
                                          horizontal:
                                              SizeConfig.blockSizeHorizontal !*
                                                  3.0,
                                          vertical:
                                              SizeConfig.blockSizeVertical !*
                                                  0.5,
                                        ),
                                      ),
                                      Container(
                                        color: Colors.grey[300],
                                        width: SizeConfig.blockSizeHorizontal !*
                                            10.0,
                                        height:
                                            SizeConfig.blockSizeVertical !* 13,
                                        padding: EdgeInsets.all(
                                          SizeConfig.blockSizeHorizontal !* 1.5,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            getPdfDownloadPath(
                                              context,
                                              model,
                                            );
                                          },
                                          child: Image(
                                            image: AssetImage(
                                              "images/ic_download.png",
                                            ),
                                            color: Colors.blue,
                                            width:
                                                SizeConfig.blockSizeHorizontal !*
                                                    3.0,
                                            height:
                                                SizeConfig.blockSizeHorizontal !*
                                                    3.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            )
                          ],
                        );
                      }),
            )
          ],
        ),
      ),
    );
  }

  void getSubscriptionHistory() async {
    /*ProgressDialog pr = ProgressDialog(context);
    pr.show();*/
    isLoading = true;
    String loginUrl = "${baseURL}patientSubscriptionData.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "PatientIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

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
    isLoading = false;
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Subs Array : " + strData);
      //final jsonData = json.decode(strData);
      listSubscriptionHistory = subscriptionHistoryModelFromJson(strData);
      setState(() {});
    } else {}
  }

  void getPdfDownloadPath(BuildContext context,
      SubscriptionHistoryModel subscriptionHistoryModel) async {
    String loginUrl = "${baseURL}subscriptiondocpdf.php";

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
        "PatientActivationReceiptIDP" +
        "\"" +
        ":" +
        "\"" +
        subscriptionHistoryModel.patientActivationReceiptIdf! +
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    if (model.status == "OK") {
      String encodedFileName = model.data!;
      String strData = decodeBase64(encodedFileName);
      final jsonData = json.decode(strData);
      String fileName = jsonData[0]['FileName'].toString();
      String downloadPdfUrl = "${baseURL}images/subscriptionReceipt/$fileName";
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

  void downloadAndOpenTheFile(String url, String fileName) async {
    var tempDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    //await tempDir.create(recursive: true);
    String fullPath = tempDir!.path + "/$fileName";
    debugPrint("full path");
    debugPrint(fullPath);
    Dio dio = Dio();
    downloadFileAndOpenActually(dio, url, fullPath);
  }

  Future downloadFileAndOpenActually(
      Dio dio, String url, String savePath) async {
    try {
      pr = ProgressDialog(context);
      pr!.show();

      final savedDir = Directory(savePath);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        await savedDir.create();
      }
      taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: savePath,
        showNotification: false,
        // show download progress in status bar (for Android)
        openFileFromNotification:
            false, // click on notification to open downloaded file (for Android)
      ) /*.then((value) {
        taskId = value;
      })*/
          ;
      var tasks = await FlutterDownloader.loadTasks();
      debugPrint("File path");
    } catch (e) {
      print("Error downloading");
      print(e.toString());
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

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
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
}
