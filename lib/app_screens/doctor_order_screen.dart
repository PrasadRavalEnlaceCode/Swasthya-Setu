import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';
import '../podo/dropdown_item.dart';
import '../utils/color.dart';
import '../utils/progress_dialog.dart';

class DoctorOrderScreen extends StatefulWidget {
  String? patientIDP = "";
  final String urlFetchPatientProfileDetails =
      "${baseURL}patientProfileData.php";

  String emptyTextMyDoctors1 = "Please wait";

  String emptyMessage = "";

  Widget? emptyMessageWidget;

  DoctorOrderScreen(String patientIDP) {
    this.patientIDP = patientIDP;
  }

  @override
  State<StatefulWidget> createState() {
    return DoctorOrderScreenState();
  }
}

class DoctorOrderScreenState extends State<DoctorOrderScreen> {
  List<Map<String, String>> listDoctorsSearchResults = [];
  var focusNode = new FocusNode();
  // var isFABVisible = true;
  bool doctorApiCalled = false;
  bool apiCalled = false;

  Widget titleWidget = Text("My Orders");
  // ScrollController hideFABController;

  @override
  void initState() {
    super.initState();
    widget.emptyMessage = "${widget.emptyTextMyDoctors1}";
    widget.emptyMessageWidget = SizedBox(
      height: SizeConfig.blockSizeVertical! * 80,
      child: Container(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 5),
        child: Center(
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
      ),
    );
    // hideFABController = ScrollController();
    // hideFABController.addListener(() {
    //   if (hideFABController.position.userScrollDirection ==
    //       ScrollDirection.reverse) {
    //     if (isFABVisible == true) {
    //       /* only set when the previous state is false
    //          * Less widget rebuilds
    //          */
    //       print("**** $isFABVisible up"); //Move IO away from setState
    //       setState(() {
    //         isFABVisible = false;
    //       });
    //     }
    //   } else {
    //     if (hideFABController.position.userScrollDirection ==
    //         ScrollDirection.forward) {
    //       if (isFABVisible == false) {
    //         print("**** ${isFABVisible} down"); //Move IO away from setState
    //         setState(() {
    //           isFABVisible = true;
    //         });
    //       }
    //     }
    //   }
    // });
    getPatientProfileDetails("");
  }

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
                titleLarge: TextStyle(
                    color: Colorsblack,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5))
            .bodyMedium,
        titleTextStyle: TextTheme(
                titleLarge: TextStyle(
                    color: Colorsblack,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5))
            .titleLarge,
      ),
      body: Builder(
        builder: (context) {
          return RefreshIndicator(
            child: listDoctorsSearchResults.length > 0
                ? Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                            itemCount: listDoctorsSearchResults.length,
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {},
                                child: Container(
                                    child: Padding(
                                        padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal! *
                                                2),
                                        child: Column(
                                          children: [
                                            Row(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  (listDoctorsSearchResults[
                                                                      index][
                                                                  'ProviderLogo']
                                                              .toString()
                                                              .length) >
                                                          0
                                                      ? InkWell(
                                                          child:
                                                              CachedNetworkImage(
                                                            fadeInDuration:
                                                                Duration.zero,
                                                            placeholder:
                                                                (context,
                                                                        url) =>
                                                                    Image(
                                                              image: AssetImage(
                                                                  'images/shimmer_effect.png'),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            imageUrl: listDoctorsSearchResults[
                                                                        index][
                                                                    'ProviderLogo']
                                                                .toString(),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {},
                                                          child: CircleAvatar(
                                                            radius: 20,
                                                            child: Icon(
                                                              Icons
                                                                  .storefront_sharp,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        5,
                                                  ),
                                                  Container(
                                                    width: 200,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          (listDoctorsSearchResults[
                                                                      index][
                                                                  "ProductName"]!
                                                              .trim()),
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: SizeConfig
                                                                    .blockSizeHorizontal! *
                                                                4.2,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                            letterSpacing: 1.3,
                                                          ),
                                                        ),
                                                        Text(
                                                          "Company - " +
                                                              listDoctorsSearchResults[
                                                                          index]
                                                                      [
                                                                      "ProviderCompanyName"]!
                                                                  .trim(),
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: SizeConfig
                                                                    .blockSizeHorizontal! *
                                                                3.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.black54,
                                                            letterSpacing: 1.3,
                                                          ),
                                                        ),
                                                        Text(
                                                          "Area - " +
                                                              listDoctorsSearchResults[
                                                                          index]
                                                                      [
                                                                      "ProviderArea"]!
                                                                  .trim(),
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: SizeConfig
                                                                    .blockSizeHorizontal! *
                                                                3.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                            letterSpacing: 1.3,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: <Widget>[
                                                      Text(
                                                        (listDoctorsSearchResults[
                                                                    index]
                                                                ["OrderDate"]!
                                                            .trim()),
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        listDoctorsSearchResults[
                                                                    index]
                                                                ["OrderTime"]!
                                                            .trim(),
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ]),
                                            SizedBox(
                                              height: SizeConfig
                                                      .blockSizeVertical! *
                                                  0.5,
                                            ),
                                            Container(
                                              color: Colors.grey,
                                              height: 0.5,
                                            )
                                                .paddingSymmetric(
                                                    horizontal: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        2)
                                                .paddingOnly(
                                                  top: SizeConfig
                                                          .blockSizeVertical! *
                                                      1.8,
                                                )
                                          ],
                                        ))),
                              );
                            }),
                      ),
                    ],
                  )
                : widget.emptyMessageWidget!,
            onRefresh: () {
              return getPatientProfileDetails("");
            },
          );
        },
      ),
    );
  }

  isImageNotNullAndBlank(int index) {
    return (listDoctorsSearchResults[index]["ProviderLogo"] != "" &&
        listDoctorsSearchResults[index]["ProviderLogo"] != null &&
        listDoctorsSearchResults[index]["ProviderLogo"] != "null");
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

  Future<String> getPatientProfileDetails(String productIDP) async {
    /*List<IconModel> listIcon;*/
    var doctorApiCalled = false;
    ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr.show();
    });

    try {
      listDoctorsSearchResults = [];
      //listIcon = new List();
      String jsonStr = "{" +
          "\"" +
          "DoctorIDP" +
          "\"" +
          ":" +
          "\"" +
          widget.patientIDP! +
          "\"" +
          "}";

      debugPrint("ProviderList API request object");
      debugPrint(jsonStr);
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String encodedJSONStr = encodeBase64(jsonStr);
      String loginUrl = "${baseURL}doctor_orderlist.php";
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
      final jsonResponse1 = json.decode(response.body.toString());
      ResponseModel model = ResponseModel.fromJSON(jsonResponse1);
      pr.hide();
      if (model.status == "OK") {
        var data = jsonResponse1['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array Dashboard : " + strData);
        final jsonData = json.decode(strData);
        if (jsonData.length > 0)
          doctorApiCalled = true;
        else
          doctorApiCalled = false;
        for (var i = 0; i < jsonData.length; i++) {
          var jo = jsonData[i];
          listDoctorsSearchResults.add({
            "HealthCareProviderIDP": jo['HealthCareProviderIDP'].toString(),
            "ProviderCompanyName": jo['ProviderCompanyName'].toString(),
            "DisplayName": jo['DisplayName'].toString(),
            "ProviderArea": jo['ProviderArea'].toString(),
            "ProviderLogo": jo['ProviderLogo'].toString(),
            "ProductName": jo['ProductName'].toString(),
            "IsFavourite": jo['IsFavourite'].toString(),
            "ProductDetails": jo['ProductDetails'].toString(),
            "HealthCareProviderProductIDP":
                jo['HealthCareProviderProductIDP'].toString(),
            "OrderDate": jo['OrderDate'].toString(),
            "OrderTime": jo['OrderTime'].toString(),
          });
        }
        setState(() {});
      }
    } catch (exception) {
      pr.hide();
    }
    return 'success';
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
      ProgressDialog pr = ProgressDialog(context);
      pr.show();
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
      var taskId = await FlutterDownloader.enqueue(
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

  // bool isADocument(int index) {
  //   return listPatientReport[index].reportImage.contains(".pdf") ||
  //       listPatientReport[index].reportImage.contains(".doc") ||
  //       listPatientReport[index].reportImage.contains(".docx") ||
  //       listPatientReport[index].reportImage.contains(".txt");
  // }
}
