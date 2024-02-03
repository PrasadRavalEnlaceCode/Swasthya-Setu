import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swasthyasetu/app_screens/doctor_health_videos.dart';
import 'package:swasthyasetu/app_screens/material_screen.dart';
import 'package:swasthyasetu/app_screens/select_patients_for_share_video.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_login_icons_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

import '../controllers/add_camp_controller.dart';
import '../main.dart';
import '../podo/model_health_doc.dart';
import '../podo/response_main_model.dart';
import '../utils/color.dart';
import '../utils/string_resource.dart';
import 'VitalsCombineListScreen.dart';
import 'play_video_screen.dart';

class PatientResourcesFromProfileScreen  extends StatefulWidget {

  final String patientIDP;

  String patientID = "";

  PatientResourcesFromProfileScreen({ required this.patientIDP});

  @override
  State<StatefulWidget> createState() {
    return PatientResourcesFromProfileScreenState();
  }
}

class PatientResourcesFromProfileScreenState extends State<PatientResourcesFromProfileScreen> with TickerProviderStateMixin {

  final String urlFetchPatientProfileDetails =
      "${baseURL}patientProfileData.php";
  List<IconModel> listHealthVideos = [];
  bool isLoading = false;
  String userName = "";
  int selectedTabIndex = 0;
  late TabController tabController;
  List<ModelHealthDoc> healthDocList = [];

  @override
  void initState() {
    getPatientProfileDetails();
    getDoctorProfileDetails();
    getHealthVideos();
    getMaterials();
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    var controller = Get.put(AddCampController(), permanent: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Resources'),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(
            color: Colorsblack, size: SizeConfig.blockSizeVertical ! * 2.2),
        toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(
                color: Colorsblack,
                fontFamily: FONT_NAME,
                fontSize: SizeConfig.blockSizeVertical ! * 2.5))
            .bodyMedium,
        titleTextStyle: TextTheme(
            titleMedium: TextStyle(
                color: Colorsblack,
                fontFamily: FONT_NAME,
                fontSize: SizeConfig.blockSizeVertical ! * 2.5))
            .titleLarge,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(maxHeight: 150.0),
              child: Material(
                color: Colors.indigo,
                child: TabBar(
                  labelColor: Colors.white,
                  indicatorColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  controller: tabController,
                  tabs: [
                    Tab(text: 'Health Videos'),
                    Tab(text: 'Materials')
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: BouncingScrollPhysics(),
                controller: tabController,
                children: <Widget>[
                  DoctorHealthVideos(sourceScreen: "PatientResourcesFromProfileScreen",),
                  MaterialScreen(sourceScreen: "PatientResourcesFromProfileScreen",patientIDP: widget.patientIDP,)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getPatientProfileDetails() async {
    print('getPatientProfileDetails');
    /*List<IconModel> listIcon;*/
    ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr.show();
    });
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    //listIcon = new List();
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: urlFetchPatientProfileDetails,
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
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);
      if (jsonData.length > 0) {
        widget.patientID = jsonData[0]['PatientID'];
      }
      setState(() {});
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

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
      userName = (firstName.trim() + " " + middleName.trim() + " " + lastName.trim()).trim();
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

  void getHealthVideos() async {
    setState(() {
      isLoading = true;
    });
    String loginUrl = "${baseURL}doctorVideosList.php";
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
    listHealthVideos = [];
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      final jsonVideos = jsonData['Videos'];
      //final jsonVideos = json.decode(videos);

      for (var i = 0; i < jsonVideos.length; i++) {
        var jsonVideoObj = jsonVideos[i];
        listHealthVideos.add(IconModel(
            jsonVideoObj["VideoTitle"],
            "${jsonVideoObj["VideoID"].toString()}",
            jsonVideoObj["VideoURL"],
            jsonVideoObj["VideoDescription"]));
      }
      setState(() {
        isLoading = false;
      });
    }
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
      for (var i = 0; i < jsonData.length; i++) {
        healthDocList.add(ModelHealthDoc(
            healthInfoDocumentIDP: jsonData[i]['HealthInfoDocumentIDP'],
            fileName: jsonData[i]['FileName']));
      }
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

//   void onPressedFunction() {
//     if (widget.sourceScreen == 'DoctorDashboardScreen') {
//       // Functionality for DoctorDashboardScreen
//       print('Button pressed from DoctorDashboardScreen');
//     } else if (widget.sourceScreen == 'AddConsultationScreen') {
//       // Functionality for AddConsultationScreen
//       print('Button pressed from AddConsultationScreen');
//     }
//   }
// }

}