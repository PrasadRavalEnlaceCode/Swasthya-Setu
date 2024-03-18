import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swasthyasetu/app_screens/add_material_screen.dart';
import 'package:swasthyasetu/app_screens/play_video_screen.dart';
import 'package:swasthyasetu/app_screens/select_patients_for_share_doc.dart';
import 'package:swasthyasetu/app_screens/select_patients_for_share_video.dart';
import 'package:swasthyasetu/controllers/certificate_controller.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_health_doc.dart';
import 'package:swasthyasetu/podo/response_login_icons_model.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/common_methods.dart';

import '../utils/color.dart';
import '../utils/progress_dialog.dart';
import 'doctor_dashboard_screen.dart';

class MaterialScreen extends StatefulWidget {

  final String? patientIDP;

  final String sourceScreen;

  String patientID = "";

  MaterialScreen({
    this.patientIDP
    ,required this.sourceScreen});

  @override
  State<StatefulWidget> createState() {
    return MaterialScreenState();
  }
}

class MaterialScreenState extends State<MaterialScreen> {
  final String urlFetchPatientProfileDetails =
      "${baseURL}patientProfileData.php";
  bool isLoading = false;
  String userName = "";
  List<ModelHealthDoc> healthDocList = [];
  ProgressDialog? pr;
  var certController = Get.put(CertificateController());

  @override
  void initState() {
    super.initState();
    getDoctorProfileDetails();
    // getPatientProfileDetails();
    getMaterials();
  }

  void getMaterials() async {
    print('getMaterials');
    String loginUrl = "${baseURL}doctorHealthInfoDocument.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();

    var response = await apiHelper.callApiWithHeadersAndBody(
      url: loginUrl,
      headers: {
        "u": patientUniqueKey,
        "type": userType,
      },
    );
    //var resBody = json.decode(response.body);
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    print("Certificate $jsonResponse");
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++)
      {
        healthDocList.add(ModelHealthDoc(
            healthInfoDocumentIDP: jsonData[i]['HealthInfoDocumentIDP'],
            fileName: jsonData[i]['FileName']));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return
      Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  !isLoading && healthDocList.length > 0
                    ?
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: healthDocList.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              print(healthDocList[index].fileName);
                            },
                            child: ListTile(
                              title: Column(
                                children: [
                                  Card(
                                      margin: EdgeInsets.all(
                                        SizeConfig.blockSizeHorizontal !* 1.0,
                                      ),
                                      shadowColor: Colors.black,
                                      elevation: 1,
                                      borderOnForeground: true,
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          SizeConfig.blockSizeHorizontal !* 3.0,
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    healthDocList[index].fileName!,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize:
                                                      SizeConfig.blockSizeHorizontal !*
                                                          3.8,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    pdfButtonClick(
                                                        context,
                                                        healthDocList[index]);
                                                  },
                                                  customBorder:
                                                  CircleBorder(),
                                                  child:
                                                  Container(
                                                    padding: EdgeInsets.all(
                                                        SizeConfig
                                                            .blockSizeHorizontal !*
                                                            2.0),
                                                    decoration:
                                                    BoxDecoration(
                                                      color: Colors
                                                          .blue[
                                                      800],
                                                      shape: BoxShape
                                                          .circle,
                                                    ),
                                                    child: FaIcon(
                                                      FontAwesomeIcons
                                                          .filePdf,
                                                      size: SizeConfig
                                                          .blockSizeHorizontal !*
                                                          5,
                                                      color: Colors
                                                          .white,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: SizeConfig.blockSizeVertical !* 1,
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: InkWell(
                                                    onTap: () {
                                                      onPressedFunction(index);
                                                    },
                                                    customBorder:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                        SizeConfig.blockSizeHorizontal !*
                                                            10.0,
                                                      ),
                                                    ),
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        SizeConfig.blockSizeHorizontal !*
                                                            2.0,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                          SizeConfig
                                                              .blockSizeHorizontal !*
                                                              10.0,
                                                        ),
                                                        border: Border.all(
                                                            color: Colors.black,
                                                            width: 0.8),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Image.asset(
                                                            "images/ic_notify_on_app.png",
                                                            width: SizeConfig
                                                                .blockSizeHorizontal !*
                                                                6.0,
                                                            height: SizeConfig
                                                                .blockSizeHorizontal !*
                                                                6.0,
                                                            color: Colors.blueGrey[600],
                                                          ),
                                                          SizedBox(
                                                            width: SizeConfig
                                                                .blockSizeHorizontal !*
                                                                1.0,
                                                          ),
                                                          Text(
                                                            "Notify on App",
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              color:
                                                              Colors.blueGrey[600],
                                                              fontSize: SizeConfig
                                                                  .blockSizeHorizontal !*
                                                                  3.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: InkWell(
                                                    customBorder:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                        SizeConfig.blockSizeHorizontal !*
                                                            10.0,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      // ${healthDocList[index].fileName}
                                                      String idp = healthDocList[index].healthInfoDocumentIDP.toString();
                                                      String imagePath = '${baseURL}images/educationMaterial/$idp.pdf';
                                                      if(File('${baseURL}images/educationMaterial/$idp.pdf').exists()==true)
                                                        {
                                                          // ${baseURL}images/educationMaterial/$idp.pdf
                                                          share(imagePath);
                                                        }
                                                        else{
                                                          share(imagePath);
                                                          // downloadAndShareFileActually(idp);
                                                        }
                                                      },
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        SizeConfig.blockSizeHorizontal !*
                                                            2.0,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(
                                                          SizeConfig
                                                              .blockSizeHorizontal !*
                                                              10.0,
                                                        ),
                                                        border: Border.all(
                                                          color: Colors.black,
                                                          width: 0.8,
                                                        ),
                                                      ),
                                                      child:
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Image.asset(
                                                            "images/ic_share_externally.png",
                                                            width: SizeConfig
                                                                .blockSizeHorizontal !*
                                                                6.0,
                                                            height: SizeConfig
                                                                .blockSizeHorizontal !*
                                                                5.0,
                                                            color: Colors.blueGrey[600],
                                                          ),
                                                          SizedBox(
                                                            width: SizeConfig
                                                                .blockSizeHorizontal !*
                                                                1.0,
                                                          ),
                                                          Text(
                                                            "Share Externally",
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              color:
                                                              Colors.blueGrey[600],
                                                              fontSize: SizeConfig
                                                                  .blockSizeHorizontal !*
                                                                  3.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal !* 30,
                    child: LinearProgressIndicator(),
                  ),
                      ),
                ],
              ),
            ),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddMaterialScreen()));
                  print('FloatingActionButton clicked');
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
  }

  void onPressedFunction(int index) {
    if (widget.sourceScreen == 'PatientResourcesScreen') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SelectPatientsForShareDocument(
                    healthDocList[
                    index] ,
                    userName
                )),
      );
      print('Button pressed from DoctorDashboardScreen');
    } else if (widget.sourceScreen == 'PatientResourcesFromProfileScreen') {
      certController.submitHealthDoc(
          widget.patientIDP, healthDocList[index], context)
          .then((value) {
        Navigator.of(context).pop();
      });
      print(healthDocList[index].fileName);
      print('Button pressed from AddConsultationScreen');
    }
  }

  // void getPatientProfileDetails() async {
  //   print('getPatientProfileDetails');
  //   /*List<IconModel> listIcon;*/
  //   ProgressDialog pr = ProgressDialog(context);
  //   Future.delayed(Duration.zero, () {
  //     pr.show();
  //   });
  //   String patientUniqueKey = await getPatientUniqueKey();
  //   String userType = await getUserType();
  //   String patientIDP = await getPatientOrDoctorIDP();
  //   debugPrint("Key and type");
  //   debugPrint(patientUniqueKey);
  //   debugPrint(userType);
  //   String jsonStr = "{" +
  //       "\"" +
  //       "PatientIDP" +
  //       "\"" +
  //       ":" +
  //       "\"" +
  //       patientIDP +
  //       "\"" +
  //       "}";
  //
  //   debugPrint("--------------------------------------------$jsonStr");
  //
  //   String encodedJSONStr = encodeBase64(jsonStr);
  //   //listIcon = new List();
  //   var response = await apiHelper.callApiWithHeadersAndBody(
  //     url: urlFetchPatientProfileDetails,
  //     //Uri.parse(loginUrl),
  //     headers: {
  //       "u": patientUniqueKey,
  //       "type": userType,
  //     },
  //     body: {"getjson": encodedJSONStr},
  //   );
  //   //var resBody = json.decode(response.body);
  //   debugPrint(response.body.toString());
  //   final jsonResponse = json.decode(response.body.toString());
  //   ResponseModel model = ResponseModel.fromJSON(jsonResponse);
  //   pr.hide();
  //   if (model.status == "OK") {
  //     var data = jsonResponse['Data'];
  //     var strData = decodeBase64(data);
  //     debugPrint("Decoded Data Array : " + strData);
  //     final jsonData = json.decode(strData);
  //     if (jsonData.length > 0) {
  //       widget.patientID = jsonData[0]['PatientID'];
  //     }
  //     print(widget.patientID);
  //     setState(() {});
  //   } else {
  //     final snackBar = SnackBar(
  //       backgroundColor: Colors.red,
  //       content: Text(model.message!),
  //     );
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }

  void getDoctorProfileDetails() async {
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: "${baseURL}doctorProfileData.php",
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
    /*pr.hide();*/
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);
      String firstName = jsonData[0]['FirstName'];
      String middleName = jsonData[0]['MiddleName'];
      String lastName = jsonData[0]['LastName'];
      userName =
          (firstName.trim() + " " + middleName.trim() + " " + lastName.trim())
              .trim();
      setState(() {});
    } else {
      /*final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message),
      );
      ScaffoldMessenger.of(navigationService.navigatorKey.currentState)
          .showSnackBar(snackBar);*/
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

  void pdfButtonClick(
      BuildContext context,
      ModelHealthDoc modelHealthDoc,
      ) {
    getPdfDownloadPath(
        context, modelHealthDoc.healthInfoDocumentIDP.toString());
  }

  void getPdfDownloadPath(BuildContext context, String idp) async
  {
    String fileName = "$idp.pdf";
    String url = "${baseURL}images/educationMaterial/$idp.pdf";
    print('url $url');
    downloadAndOpenTheFile(url,fileName);
  }

  var taskId;
  void downloadAndOpenTheFile(String url,String fileName) async
  {
    var fullPath = '/storage/emulated/0/Download/$fileName';
    debugPrint("full path");
    debugPrint(fullPath);
    Dio dio = Dio();
    downloadFileAndOpenActually(dio,url,fullPath);
  }

  Future downloadAndShareFileActually(String idp) async {
    print('downloadAndShareFileActually');
    try {
      String fileName = "$idp.pdf";
      String url = "${baseURL}images/educationMaterial/$idp.pdf";
      var fullPath = '/storage/emulated/0/Download/$fileName';
      debugPrint("full path");
      debugPrint(fullPath);
      Dio dio = Dio();
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      print(response.headers);
      File file = File(fullPath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
      await share(fullPath);
    } catch (e) {
      print('Error downloading');
      print(e);
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

  var _openResult = 'Unknown';
  Future<void> openFile(filePath) async
  {
    print('filePath $filePath');
    final result = await OpenFilex.open(filePath);
    setState(() {
      _openResult = "type=${result.type}  message=${result.message}";
    });
  }

  Future<void> share(String imagePath) async {
    // final box = context.findRenderObject() as RenderBox?;
    // final files = <XFile>[];
    // files.add(XFile(imagePath));
    // await Share.shareXFiles(
    //     subject: 'Hey',
    //     text: '$userName has referred you one health update material, '
    //         'that may be \nuseful to you.',
    //     [XFile(imagePath)],
    //     sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    // Share.share('$userName has referred you one health update material,that may be useful to you.',
    //     subject: 'imagePath');
    // await Share.shareXFiles([XFile(imagePath)], text:
    //     '$userName has referred you one health update material,that may be useful to you.');
    // XFile file = XFile(imagePath);
    // Share.shareXFiles(
    //   [file],
    //   text: '',
    //   subject: '$userName has referred you one health update material,that may be useful to you.',
    // );
    Share.share(
      '$userName has referred you one health update material,that may be useful to you.\n\n'
          'Follow this link \n\n$imagePath',
      subject: '',
    );
  }

  // Future<void> download(String imagePath,ModelHealthDoc healthDocList) async {
  //
  // }


}
