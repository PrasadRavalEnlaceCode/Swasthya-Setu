import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swasthyasetu/app_screens/PDFViewerCachedFromUrl.dart';
import 'package:swasthyasetu/app_screens/fullscreen_image.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import '../podo/dropdown_item.dart';
import '../utils/color.dart';
import '../utils/progress_dialog.dart';

List<DropDownItem> listCities = [];
List<DropDownItem> listCitiesSearchResults = [];

DropDownItem selectedState = DropDownItem("", "");
DropDownItem selectedCity = DropDownItem("", "");
String cityName = "";

TextEditingController cityController = new TextEditingController();

class ProviderOrderScreen extends StatefulWidget {
  String? patientIDP = "";
  final String urlFetchPatientProfileDetails =
      "${baseURL}patientProfileData.php";

  String emptyTextMyDoctors1 =
      "Please wait";

  String emptyMessage = "";

  Widget? emptyMessageWidget;

  ProviderOrderScreen(String patientIDP) {
    this.patientIDP = patientIDP;
  }

  @override
  State<StatefulWidget> createState() {
    return ProviderOrderScreenState();
  }
}

class ProviderOrderScreenState extends State<ProviderOrderScreen>
{
  List<Map<String, String>> listDoctors = [];
  List<Map<String, String>> listDoctorsSearchResults = [];
  var searchController = TextEditingController();
  var focusNode = new FocusNode();
  // var isFABVisible = true;
  bool doctorApiCalled = false;
  bool apiCalled = false;

  Icon icon = Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget titleWidget = Text("My Orders");
  // ScrollController hideFABController;

  @override
  void initState()
  {
    super.initState();
    widget.emptyMessage = "${widget.emptyTextMyDoctors1}";
    widget.emptyMessageWidget = SizedBox(
      height: SizeConfig.blockSizeVertical !* 80,
      child: Container(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
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
            color: Colorsblack, size: SizeConfig.blockSizeVertical !* 2.5),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                if (icon.icon == Icons.search) {
                  searchController = TextEditingController(text: "");
                  focusNode.requestFocus();
                  this.icon = Icon(
                    Icons.cancel,
                    color: Colors.black,
                  );
                  this.titleWidget = TextField(
                    controller: searchController,
                    focusNode: focusNode,
                    cursorColor: Colors.white,
                    onChanged: (text) {
                      setState(() {
                        if (listDoctors.length > 0)
                          listDoctorsSearchResults = listDoctors
                              .where((objDoctor) =>
                          objDoctor["FirstName"]
                              !.toLowerCase()
                              .contains(text.toLowerCase()) ||
                              objDoctor["LastName"]
                                  !.toLowerCase()
                                  .contains(text.toLowerCase()) ||
                              objDoctor["Specility"]
                                  !.toLowerCase()
                                  .contains(text.toLowerCase()) ||
                              objDoctor["CityName"]
                                  !.toLowerCase()
                                  .contains(text.toLowerCase()))
                              .toList();
                        else
                          listDoctorsSearchResults = [];
                      });
                    },
                    style: TextStyle(
                      color: Colorsblack,
                      fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                      letterSpacing: 1.5,
                    ),
                    decoration: InputDecoration(
                      /*hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize:
                          SizeConfig.blockSizeVertical * 2.1),
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize:
                          SizeConfig.blockSizeVertical * 2.1),*/
                      hintText: "Provider Name, Speciality or City",
                    ),
                  );
                } else {
                  this.icon = Icon(
                    Icons.search,
                    color: Colors.black,
                  );
                  this.titleWidget = titleWidget;
                  listDoctorsSearchResults = listDoctors;
                }
              });
            },
            icon: icon,
          ),
        ], toolbarTextStyle: TextTheme(
          titleLarge: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5)).bodyMedium,
        titleTextStyle: TextTheme(
            titleLarge: TextStyle(
                color: Colorsblack,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical !* 2.5)).titleLarge,
      ),
      body: Builder(
        builder: (context) {
          return RefreshIndicator(
            child:
            listDoctorsSearchResults.length > 0
                ?
            Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                      itemCount: listDoctorsSearchResults.length,
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            print('isADocument ${isADocument(index)}');
                            if (isADocument(index)) {
                              // downloadAndOpenTheFile(
                              //     "${baseURL}images/patientreport/${listDoctorsSearchResults[index]["ReportImage"]}",
                              //     listDoctorsSearchResults[index]["ReportImage"]!);
                              String downloadPdfUrl =  "${baseURL}images/patientreport/${listDoctorsSearchResults[index]["ReportImage"]}";
                              Navigator.push(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder: (_) => PDFViewerCachedFromUrl(
                                      url: downloadPdfUrl,
                                    ),
                                  ));
                            } else {
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) {
                                        return FullScreenImage(
                                            "${baseURL}images/patientreport/${listDoctorsSearchResults[index]["ReportImage"]}");
                                      }));
                            }
                          },
                          child: Container(
                              child: Padding(
                                  padding: EdgeInsets.all(
                                      SizeConfig.blockSizeHorizontal !* 2),
                                  child:
                                  Column(
                                    children: [
                                      Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            InkWell(
                                              onTap: ()
                                              {
                                                // view prescription
                                              },
                                              child: isImageNotNullAndBlank(
                                                  index) ?
                                                CircleAvatar(
                                                  radius: SizeConfig
                                                      .blockSizeHorizontal !*
                                                      6,
                                                  backgroundImage: NetworkImage(
                                                      "$doctorImgUrl${listDoctorsSearchResults[index]["ProviderLogo"]}")) :
                                                CircleAvatar(
                                                  radius: 20,
                                                  child: Icon(Icons.pending_actions_sharp,size: 20,),
                                                ),
                                            ),
                                            SizedBox(
                                              width: SizeConfig
                                                  .blockSizeHorizontal !*
                                                  5,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: <Widget>[
                                                Container(
                                                  width: SizeConfig
                                                      .blockSizeHorizontal !*
                                                      70,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child:
                                                        Text(
                                                          '${listDoctorsSearchResults[index]["OrderDate"]}',
                                                          textAlign:
                                                          TextAlign.left,
                                                          style:
                                                          TextStyle(
                                                            fontSize:
                                                            SizeConfig
                                                                .blockSizeHorizontal !*
                                                                4.2,
                                                            fontWeight:
                                                            FontWeight
                                                                .w500,
                                                            color: Colors
                                                                .black,
                                                            letterSpacing:
                                                            1.3,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: SizeConfig
                                                      .blockSizeVertical !*
                                                      0.5,
                                                ),
                                                Text(
                                                  listDoctorsSearchResults[
                                                  index]
                                                  ["ProviderCompanyName"]!,
                                                  textAlign:
                                                  TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: SizeConfig
                                                        .blockSizeHorizontal !*
                                                        3.3,
                                                    color: Colors.grey,
                                                    letterSpacing: 1.3,
                                                  ),
                                                ),
                                                Text(
                                                  listDoctorsSearchResults[
                                                  index]
                                                  ["ProviderArea"]! +
                                                      " - " +
                                                      listDoctorsSearchResults[
                                                      index]
                                                      ["CityName"]!,
                                                  textAlign:
                                                  TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: SizeConfig
                                                        .blockSizeHorizontal !*
                                                        3.3,
                                                    color: Colors.grey,
                                                    letterSpacing: 1.3,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: SizeConfig
                                                      .blockSizeVertical !*
                                                      0.5,
                                                ),
                                                Row(
                                                  children: [
                                                    Image(
                                                      image: AssetImage(
                                                          "images/ic_form_3c_dashboard.png"),
                                                      width: SizeConfig
                                                          .blockSizeHorizontal !*
                                                          4.5,
                                                      height: SizeConfig
                                                          .blockSizeHorizontal !*
                                                          4.5,
                                                    ),
                                                    SizedBox(
                                                      width: SizeConfig
                                                          .blockSizeHorizontal !*
                                                          1.0,
                                                    ),
                                                    Text(
                                                      "View Prescription",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .green[
                                                          700]),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ]),
                                      SizedBox(
                                        height:
                                        SizeConfig.blockSizeVertical !*
                                            0.5,
                                      ),
                                      Container(
                                        color: Colors.grey,
                                        height: 0.5,
                                      )
                                          .paddingSymmetric(
                                          horizontal: SizeConfig
                                              .blockSizeHorizontal !*
                                              2)
                                          .paddingOnly(
                                        top: SizeConfig
                                            .blockSizeVertical !*
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

  Future<String> getPatientProfileDetails(String cityidp) async {
    /*List<IconModel> listIcon;*/
    var doctorApiCalled = false;
    ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr.show();
    });

    try {
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
          "}";

      debugPrint(jsonStr);

      String encodedJSONStr = encodeBase64(jsonStr);
      //listIcon = new List();
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: widget.urlFetchPatientProfileDetails,
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
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array : " + strData);
        final jsonData = json.decode(strData);
        listDoctors = [];
        listDoctorsSearchResults = [];
        String loginUrl = "${baseURL}patient_order.php";
        String jsonStr = "{" +
            "\"" +
            "PatientIDP" +
            "\"" +
            ":" +
            "\"" +
            widget.patientIDP! +
            "\"" +
            "}";

        debugPrint("ProviderList API request object");
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
        final jsonResponse1 = json.decode(response.body.toString());
        ResponseModel model = ResponseModel.fromJSON(jsonResponse1);
        //  pr.hide();

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
            listDoctors.add({
              "HealthcareProviderOrderIDP": jo['HealthcareProviderOrderIDP'].toString(),
              "ProviderCompanyName": jo['ProviderCompanyName'].toString(),
              "DisplayName": jo['DisplayName'].toString(),
              "ProviderArea": jo['ProviderArea'].toString(),
              "ProviderLogo": jo['ProviderLogo'].toString(),
              "CityName": jo['CityName'].toString(),
              "OrderDate": jo['OrderDate'].toString(),
              "PatientReportIDF": jo['PatientReportIDF'].toString(),
              "ReportImage": jo['ReportImage'].toString()
            });
            listDoctorsSearchResults.add({
              "HealthcareProviderOrderIDP": jo['HealthcareProviderOrderIDP'].toString(),
              "ProviderCompanyName": jo['ProviderCompanyName'].toString(),
              "DisplayName": jo['DisplayName'].toString(),
              "ProviderArea": jo['ProviderArea'].toString(),
              "ProviderLogo": jo['ProviderLogo'].toString(),
              "CityName": jo['CityName'].toString(),
              "OrderDate": jo['OrderDate'].toString(),
              "PatientReportIDF": jo['PatientReportIDF'].toString(),
              "ReportImage": jo['ReportImage'].toString()
            });
          }
          pr.hide();
          setState(() {});
        }
        //setState(() {});
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(model.message!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (exception) {
      if (!doctorApiCalled) {
        try {
          listDoctors = [];
          listDoctorsSearchResults = [];
          String loginUrl = "${baseURL}patient_order.php";
          //listIcon = new List();
          String jsonStr = "{" +
              "\"" +
              "PatientIDP" +
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
          // pr.hide();
          if (model.status == "OK") {
            var data = jsonResponse1['Data'];
            var strData = decodeBase64(data);
            debugPrint("Decoded Data Array Dashboard : " + strData);
            final jsonData = json.decode(strData);
            if (jsonData.length > 0)
              doctorApiCalled = true;
            else
              doctorApiCalled = false;
            for (var i = 0; i < jsonData.length; i++)
            {
              var jo = jsonData[i];
              listDoctors.add({
                "HealthCareProviderIDP": jo['HealthCareProviderIDP'].toString(),
                "ProviderCompanyName": jo['ProviderCompanyName'].toString(),
                "DisplayName": jo['DisplayName'].toString(),
                "ProviderArea": jo['ProviderArea'].toString(),
                "ProviderLogo": jo['ProviderLogo'].toString(),
                "CityName": jo['CityName'].toString(),
              });
              listDoctorsSearchResults.add({
                "HealthCareProviderIDP": jo['HealthCareProviderIDP'].toString(),
                "ProviderCompanyName": jo['ProviderCompanyName'].toString(),
                "DisplayName": jo['DisplayName'].toString(),
                "ProviderArea": jo['ProviderArea'].toString(),
                "ProviderLogo": jo['ProviderLogo'].toString(),
                "CityName": jo['CityName'].toString(),
              });
            }
            setState(() {});
          }
        } catch (exception) {
          pr.hide();
        }
      } else {
        pr.hide();
      }
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
        saveInPublicStorage: true,
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

  bool isADocument(int index) {
    return listDoctorsSearchResults[index]["ReportImage"].toString().contains(".pdf") ||
        listDoctorsSearchResults[index]["ReportImage"].toString().contains(".doc") ||
        listDoctorsSearchResults[index]["ReportImage"].toString().contains(".docx") ||
        listDoctorsSearchResults[index]["ReportImage"].toString().contains(".txt");
  }
}