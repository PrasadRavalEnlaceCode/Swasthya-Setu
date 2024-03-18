import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swasthyasetu/api/api_helper.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/patient_payment.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:swasthyasetu/widgets/date_range_picker_custom.dart'
    as DateRagePicker;
import 'package:swasthyasetu/widgets/extensions.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../utils/color.dart';

class MyPaymentsPatient extends StatefulWidget {
  var fromDate = DateTime.now().subtract(Duration(days: 7));
  var toDate = DateTime.now();
  String? patientIDP;

  var fromDateString = "";
  var toDateString = "";

  String emptyTextReport1 =
      "Now you can add your Prescription, XRay, CT Scan, ECG and other medical documents.";
  String emptyTextReport2 =
      "Upload a scan copy or take a Photo of your Medical documents based on different categories and keep them in your records.";
  String emptyTextReport3 =
      "Add a TagName / Document Name to your report and add them in respective category.";

  String emptyMessage = "";

  Widget? emptyMessageWidget;

  MyPaymentsPatient(String patientIDP) {
    this.patientIDP = patientIDP;
  }

  @override
  State<StatefulWidget> createState() {
    return MyPaymentsPatientState();
  }
}

class MyPaymentsPatientState extends State<MyPaymentsPatient> {
  bool apiCalled = false;
  List<PatientPayment> listPatientPayment = [];
  ScrollController? hideFABController;
  var isFABVisible = true;
  var selectedCategoryIDP = "-";
  var taskId;
  ProgressDialog? pr;
  ApiHelper apiHelper = ApiHelper();
  String userType = "";

  //List<TableRow> tableRows = [];

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    widget.emptyMessage = "No Payments made on these dates";
    getUserType().then((value) {
      userType = value;
    });
    /*
    var formatter = DateFormat('dd-MM-yyyy');
    widget.fromDateString = formatter.format(widget.fromDate);
    widget.toDateString = formatter.format(widget.toDate);*/

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
    getPatientPayments(context);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
        child: Scaffold(
      appBar: userType == "patient"
          ? AppBar(
              title: Text("My Payments",
                  style:
                      TextStyle(fontSize: SizeConfig.blockSizeVertical !* 2.5)),
              backgroundColor: Color(0xFFFFFFFF),
              iconTheme: IconThemeData(color: Colorsblack), toolbarTextStyle: TextTheme(
                  titleMedium: TextStyle(
                color: Colorsblack,
                fontFamily: "Ubuntu",
              )).bodyMedium, titleTextStyle: TextTheme(
                  titleMedium: TextStyle(
                color: Colorsblack,
                fontFamily: "Ubuntu",
              )).titleLarge,
            )
          : PreferredSize(
              child: Container(),
              preferredSize: Size(SizeConfig.screenWidth!, 0),
            ),
      body: RefreshIndicator(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
                color: Colors.grey[100],
                height: SizeConfig.blockSizeVertical !* 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: SizeConfig.blockSizeVertical !* 1.0,
                    ),
                    Container(
                      height: SizeConfig.blockSizeVertical !* 8,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Container(
                          child: InkWell(
                              onTap: () {
                                showDateRangePickerDialog();
                              },
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      widget.fromDateString == "" &&
                                              widget.toDateString == ""
                                          ? "Select Date Range"
                                          : "${widget.fromDateString}  to  ${widget.toDateString}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.6,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                  ),
                                  Container(
                                    width: SizeConfig.blockSizeHorizontal !* 15,
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      size: SizeConfig.blockSizeHorizontal !* 8,
                                    ),
                                  ),
                                ],
                              )),
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                      height: SizeConfig.blockSizeVertical !* 1.0,
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: SizeConfig.blockSizeVertical !* 2.0),
                          child: !apiCalled
                              ? Container()
                              : listPatientPayment.length > 0
                                  ? ListView.builder(
                                      itemCount: listPatientPayment.length,
                                      padding: EdgeInsets.only(
                                        bottom:
                                            SizeConfig.blockSizeVertical !* 13.0,
                                      ),
                                      itemBuilder: (context, index) {
                                        PatientPayment model =
                                            listPatientPayment[index];
                                        String salutation = "";
                                        if (userType == "patient")
                                          salutation = "Dr. ";
                                        return _buildTimelineTile(
                                          indicator: _IconIndicator(
                                            iconData:
                                                model.paymentStatus == "success"
                                                    ? Icons.check_circle
                                                    : Icons.warning,
                                            color:
                                                model.paymentStatus == "success"
                                                    ? Colors.green
                                                    : Colors.red,
                                            size: 30,
                                          ),
                                          date: model.timeStamp,
                                          doctorName: salutation +
                                              model.firstName!.trim() +
                                              " " +
                                              model.lastName!.trim(),
                                          amount: "\u20B9 ${model.amount}",
                                          paymentStatus: model.paymentStatus
                                          !.substring(0, 1)
                                                  .toUpperCase() +
                                              model.paymentStatus!.substring(1,
                                                  model.paymentStatus!.length),
                                          model: model,
                                        );
                                      })
                                  : widget.emptyMessageWidget,
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        ),
        onRefresh: () {
          return getPatientPayments(context);
        },
      ),
      /*)*/
    ));
  }

  TimelineTile _buildTimelineTile({
    _IconIndicator? indicator,
    String? date,
    String? doctorName,
    String? amount,
    String? paymentStatus,
    bool isLast = false,
    PatientPayment? model,
  }) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.3,
      beforeLineStyle: LineStyle(color: Colors.white),
      indicatorStyle: IndicatorStyle(
        indicatorXY: 0.3,
        drawGap: true,
        width: 40,
        height: 40,
        indicator: indicator,
      ),
      isLast: isLast,
      startChild: Center(
        child: Container(
          alignment: const Alignment(0.0, -0.50),
          child: Text(
            date!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
      endChild: Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 10, top: 10, bottom: 10),
        child: InkWell(
            onTap: () {
              if (paymentStatus == "Success" && userType == "patient") {
                getPdfDownloadPath(context, model!.patientActivationReceiptIdf!);
              }
            },
            child: Card(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doctorName!,
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal !* 4.2,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        amount!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey[500],
                          fontWeight: FontWeight.normal,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "\u2022",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            paymentStatus!,
                            style: TextStyle(
                              fontSize: 13,
                              color: paymentStatus == "Success" ||
                                      paymentStatus == "success"
                                  ? Colors.green
                                  : Colors.red[700],
                              fontWeight: FontWeight.normal,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  paymentStatus == "Success" && userType == "patient"
                      ? InkWell(
                          child: InkWell(
                            onTap: () {
                              getPdfDownloadPath(
                                  context, model!.patientActivationReceiptIdf!);
                            },
                            child: Text(
                              "View Receipt",
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal !* 3.4,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.normal,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ).pS(
                vertical: SizeConfig.blockSizeVertical !* 1.5,
                horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
              ),
            )),
      ),
    );
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
    //   setState(() {
    //     getPatientPayments(context);
    //   });
    //   //print(picked);
    // }
    // showCustomDateRangePicker(
    //   context,
    //   dismissible: true,
    //   minimumDate: DateTime.now().subtract(Duration(days: 365 * 100)),
    //   maximumDate: DateTime.now(),
    //   endDate: widget.toDate,
    //   startDate: widget.fromDate,
    //   backgroundColor: Colors.white,
    //   primaryColor: Colors.blue,
    //   onApplyClick: (start, end) {
    //     setState(() {
    //       widget.fromDate = start;
    //       widget.toDate = end;
    //       var formatter = new DateFormat('dd-MM-yyyy');
    //       widget.fromDateString = formatter.format(widget.fromDate);
    //       widget.toDateString = formatter.format(widget.toDate);
    //       // widget.dateString =
    //       // "${widget.fromDateString}  to  ${widget.toDateString}";
    //       getPatientPayments(context);
    //       //print(picked);
    //     });
    //   },
    //   onCancelClick: () {
    //     setState(() {
    //       widget.fromDate = DateTime.now().subtract(Duration(days: 7));
    //       widget.toDate = DateTime.now();
    //       getPatientPayments(context);
    //     });
    //   },
    // );
  }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }

  Future<String> getPatientPayments(BuildContext context) async {
    String loginUrl = "${baseURL}patientMyPayments.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientOrDoctorIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "IDP" +
        "\"" +
        ":" +
        "\"" +
        patientOrDoctorIDP +
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
    listPatientPayment = [];
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      listPatientPayment = patientPaymentFromJson(strData);

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

  void getPdfDownloadPath(
    BuildContext context,
    String patientActivationReceiptIdf,
  ) async {
    String loginUrl = "${baseURL}paymentdocpdf.php";

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
        patientActivationReceiptIdf +
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
      String downloadPdfUrl = "${baseURL}images/paymentReceipt/$fileName";
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

  static void downloadCallback(
      String id, int status, int progress) {
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
}

class _IconIndicator extends StatelessWidget {
  _IconIndicator({
    Key? key,
    this.iconData,
    this.size,
    this.color,
  }) : super(key: key);

  final IconData? iconData;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 40,
              width: 40,
              child: Icon(
                iconData,
                size: size,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
