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
import 'package:path_provider/path_provider.dart';
import 'package:silvertouch/api/api_helper.dart';
import 'package:silvertouch/app_screens/PDFViewerCachedFromUrl.dart';
import 'package:silvertouch/app_screens/add_patient_screen.dart';
import 'package:silvertouch/app_screens/fullscreen_image.dart';
import 'package:silvertouch/app_screens/my_document_doctor/add_my_doc_doctor.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_report.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
//import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';

class MyDocumentDoctorScreen extends StatefulWidget {
  String? patientIDP;
  String? documenttype;
  var fromDate = DateTime.now().subtract(Duration(days: 7));
  var toDate = DateTime.now();

  var fromDateString = "";
  var toDateString = "";

  String emptyTextMyDocuments1 =
      "Add your Medical documents like Mediclaim Policy, Medical Bills, Insurance Policy and other documents all at one place.";
  String emptyTextMyDocuments2 = "Share this documents when ever needed";

  String emptyMessage = "";

  Widget? emptyMessageWidget;

  MyDocumentDoctorScreen({String? patientIDP, String? documenttype}) {
    this.patientIDP = patientIDP;
    this.documenttype = documenttype;
  }

  @override
  State<StatefulWidget> createState() {
    return MyDocumentDoctorScreenState();
  }
}

class MyDocumentDoctorScreenState extends State<MyDocumentDoctorScreen> {
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

  @override
  void initState() {
    super.initState();
    print('Here DocumentsListScreenState');
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    widget.emptyMessage =
        "${widget.emptyTextMyDocuments1}\n\n${widget.emptyTextMyDocuments2}";
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
    getDocumentsDoctor(context);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  void didUpdateWidget(MyDocumentDoctorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.emptyMessage =
        "${widget.emptyTextMyDocuments1}\n\n${widget.emptyTextMyDocuments2}";
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
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    /*if (!apiCalled) */
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("My Documents",
            style: TextStyle(fontSize: SizeConfig.blockSizeVertical! * 2.5)),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(color: Colorsblack),
        toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(
          color: Colorsblack,
          fontFamily: "Ubuntu",
        )).bodyMedium,
        titleTextStyle: TextTheme(
            titleMedium: TextStyle(
          color: Colorsblack,
          fontFamily: "Ubuntu",
        )).titleLarge,
      ),
      floatingActionButton: Visibility(
          visible: isFABVisible,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DoctorAddMyDocumentScreen(patientIDP))).then((value) {
                getDocumentsDoctor(context);
              });
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.black,
          )),
      body: RefreshIndicator(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
                color: Color(0xFFEFEEF3),
                height: SizeConfig.blockSizeVertical! * 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 100),
                          child: listPatientReport.length > 0
                              ? ListView.builder(
                                  itemCount: listPatientReport.length,
                                  controller: hideFABController,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        if (isADocument(index)) {
                                          downloadAndOpenTheFile(
                                              "${baseURL}images/doctordocument/"
                                              "${listPatientReport[index].reportImage}",
                                              listPatientReport[index]
                                                  .reportImage);
                                        } else {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return FullScreenImage(
                                                "${baseURL}images/doctordocument/"
                                                "${listPatientReport[index].reportImage}");
                                          }));
                                        }
                                      },
                                      child: Card(
                                          color: Colors.white,
                                          child: Padding(
                                            padding: EdgeInsets.all(SizeConfig
                                                    .blockSizeHorizontal! *
                                                2),
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
                                                                    .blockSizeHorizontal! *
                                                                4.5),
                                                      ),
                                                      SizedBox(
                                                        height: SizeConfig
                                                                .blockSizeVertical! *
                                                            1,
                                                      ),
                                                      Text(
                                                        listPatientReport[index]
                                                            .categoryName,
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: SizeConfig
                                                                    .blockSizeHorizontal! *
                                                                3.0),
                                                      ),
                                                      SizedBox(
                                                        height: SizeConfig
                                                                .blockSizeVertical! *
                                                            1,
                                                      ),
                                                      Text(
                                                        listPatientReport[index]
                                                            .reportDate,
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: SizeConfig
                                                                    .blockSizeHorizontal! *
                                                                3.0),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        26,
                                                    height: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        33,
                                                    child: isADocument(index)
                                                        ? InkWell(
                                                            onTap: () {
                                                              debugPrint(
                                                                  "download file location");
                                                              debugPrint(
                                                                "${baseURL}images/doctordocument/${listPatientReport[index].reportImage}",
                                                              );
                                                              // downloadAndOpenTheFile(
                                                              //     "${baseURL}images/doctordocument/${listPatientReport[index].reportImage}",
                                                              //     listPatientReport[index]
                                                              //         .reportImage);
                                                              String
                                                                  downloadPdfUrl =
                                                                  "${baseURL}images/doctordocument/${listPatientReport[index].reportImage}";
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute<
                                                                      dynamic>(
                                                                    builder: (_) =>
                                                                        PDFViewerCachedFromUrl(
                                                                      url:
                                                                          downloadPdfUrl,
                                                                    ),
                                                                  ));

                                                              /*OpenFile.open(
                                                                "${baseURL}images/patientreport/${listPatientReport[index].reportImage}");*/
                                                            },
                                                            child: Container(
                                                              child: Image(
                                                                image: AssetImage(
                                                                    "images/ic_doc.png"),
                                                                fit:
                                                                    BoxFit.fill,
                                                                width: SizeConfig
                                                                        .blockSizeHorizontal! *
                                                                    26,
                                                                height: SizeConfig
                                                                        .blockSizeHorizontal! *
                                                                    33,
                                                              ),
                                                            ),
                                                          )
                                                        : InkWell(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(MaterialPageRoute(
                                                                      builder:
                                                                          (context) {
                                                                return FullScreenImage(
                                                                    "${baseURL}images/doctordocument/${listPatientReport[index].reportImage}");
                                                              }));
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                color: Colors
                                                                    .green,
                                                                width: 1,
                                                              )),
                                                              child:
                                                                  CachedNetworkImage(
                                                                      placeholder:
                                                                          (context, url) =>
                                                                              Image(
                                                                                width: SizeConfig.blockSizeHorizontal! * 35,
                                                                                height: SizeConfig.blockSizeHorizontal! * 35,
                                                                                image: AssetImage('images/shimmer_effect.png'),
                                                                                fit: BoxFit.fitWidth,
                                                                              ),
                                                                      imageUrl:
                                                                          "${baseURL}images/doctordocument/${listPatientReport[index].reportImage}",
                                                                      fit: BoxFit
                                                                          .fitWidth,
                                                                      width:
                                                                          SizeConfig.blockSizeHorizontal! *
                                                                              35,
                                                                      height:
                                                                          SizeConfig.blockSizeHorizontal! *
                                                                              35),
                                                            ),
                                                          )),
                                                Container(
                                                  width: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      12,
                                                  child: InkWell(
                                                    onTap: () {
                                                      deleteReportFromTheList(
                                                        listPatientReport[index]
                                                            .patientReportIDP,
                                                        listPatientReport[index]
                                                            .reportImage,
                                                        listPatientReport[index]
                                                            .reportTagName,
                                                        listPatientReport[index]
                                                            .reportTime,
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: SizeConfig
                                                              .blockSizeHorizontal! *
                                                          8,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                    );
                                  })
                              : widget.emptyMessageWidget),

                      /*],
                      )*/
                      /*),*/
                    ),
                  ],
                ))
          ],
        ),
        onRefresh: () {
          return getDocumentsDoctor(context);
        },
      ),
      /*)*/
    ));
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

  Future<String> getDocumentsDoctor(BuildContext context) async {
    //getCategoryList(context);
    String loginUrl = "${baseURL}doctor_wise_document_list.php";
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
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

    // {"DoctorIDP":"1","StaffIDF":"120"}

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
    debugPrint("response :" + response.body.toString());
    debugPrint("Data :" + model.data!);
    listPatientReport = [];
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);
      for (int i = 0; i < jsonData.length; i++) {
        final jo = jsonData[i];
        listPatientReport.add(ModelReport(
            jo['DisplayName'],
            jo['timestamp'],
            jo['DocumentType'].toString(),
            jo['DocumentName'],
            jo['DocumentIDP'].toString(),
            jo['Category']));
      }
      setState(() {
        apiCalled = true;
      });
    } else {
      setState(() {
        apiCalled = true;
      });
    }
    return 'success';
  }

  void deleteReportFromTheList(
      String patientReportIDP, reportImage, reportTagName, documenttype) async {
    try {
      String loginUrl = "${baseURL}doctor_wise_add_new_document_submit.php";

      ProgressDialog pr = ProgressDialog(context);
      pr.show();
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
          "DocumentIDP" +
          "\"" +
          ":" +
          "\"" +
          patientReportIDP +
          "\"" +
          "," +
          "\"" +
          "documenttype" +
          "\"" +
          ":" +
          "\"" +
          documenttype.toString() +
          "\"" +
          "," +
          "\"" +
          "documentname" +
          "\"" +
          ":" +
          "\"" +
          reportTagName +
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

      // {"DoctorIDP":"1","DocumentIDP":"721",
      // "documenttype":"7 ","documentname":"Pancard","DeleteFlag":"0"}

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
      pr.hide();
      if (model.status == "OK") {
        getDocumentsDoctor(context);
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print('Error deleting report: $e');
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('An error occurred while deleting the report.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

      /*Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status < 500;
            }),
      );*/
      //var response = await http.get(url);
      /*var bytes = response.data;
      File file = File(savePath);
      file.writeAsBytesSync(bytes);*/
      //bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
      //file.writeAsBytes(bytes);

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
      /*Future.delayed(Duration(milliseconds: 5000), () {

      });*/
      /*print(response.headers);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();*/
      /*if (await canLaunch(file.path)) {
        await launch(file.path);
      } else {
        throw 'Could not launch $url';
      }*/
      debugPrint("File path");
      /*debugPrint(file.path);
      OpenFile.open(file.path);*/
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
