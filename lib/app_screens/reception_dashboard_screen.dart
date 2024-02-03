import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_sms/background_sms.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:page_indicator/page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swasthyasetu/api/api_helper.dart';
import 'package:swasthyasetu/app_screens/add_patient_screen.dart';
import 'package:swasthyasetu/app_screens/doctor_health_videos.dart';
import 'package:swasthyasetu/app_screens/drugs_list_screen.dart';
import 'package:swasthyasetu/app_screens/form_3c_screen.dart';
import 'package:swasthyasetu/app_screens/invite_patient_screen.dart';
import 'package:swasthyasetu/app_screens/login_screen_doctor.dart';
import 'package:swasthyasetu/app_screens/login_screen_doctor_.dart';
import 'package:swasthyasetu/app_screens/masters_list_screen.dart';
import 'package:swasthyasetu/app_screens/my_patients_screen.dart';
import 'package:swasthyasetu/app_screens/opd_registration_screen.dart';
import 'package:swasthyasetu/app_screens/opd_services_list_screen.dart';
import 'package:swasthyasetu/app_screens/popup_dialog_image.dart';
import 'package:swasthyasetu/app_screens/view_profile_details_patient.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_investigation_master_list.dart';
import 'package:swasthyasetu/podo/response_login_icons_model.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/services/navigation_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'camp_screen.dart';
import 'corona_questionnaire.dart';
import 'custom_dialog.dart';
import 'lab_reports.dart';
import 'landing_screen.dart';
import 'select_patients_for_share_video.dart';

List<String> listSliderImagesWebViewOuter = [];
List<String> listSliderImagesWebViewTitleOuter = [];
List<ModelInvestigationMaster> listInvestigationMaster = [];

List<IconModel> listHealthVideos = [];

String mainSliderTimeGlobal = "", subSliderTimeGlobal = "";

String imgUrl = "",
    firstName = "",
    lastName = "",
    middleName = "",
    userNameGlobal = "",
    patientID = "";
String? patientIDP;

bool shouldExit = false;
String mobNo = "";

String payGatewayURL = "";

List<String> listMasters = [];

/*
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
*/
/*FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();*/

// ignore: must_be_immutable
class ReceptionDashboardScreen extends StatefulWidget {
  logOut(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }

  @override
  State<StatefulWidget> createState() {
    return PatientDashboardState();
  }
}

class PatientDashboardState extends State<ReceptionDashboardScreen>
    with WidgetsBindingObserver {
  final String urlFetchPatientProfileDetails =
      "${baseURL}doctorProfileData.php";
  String doctorSuffix = "", couponCode = "", downloadURL = "";

  String mainSliderStatus = "1",
      subSliderStatus = "1",
      dashboardCounterStatus = "0",
      aboutIconStatus = "1";
  bool notificationCounterApiCalled = false;
  String notificationCount = "0";
  String messageCount = "0";

  var username = "", password = "", type = "", fullName = "", email = "";
  List<String> listPhotos = [];

  /*AboutIconModel aboutIconModel = AboutIconModel("", "", "", ""),
      aboutVenueModel = AboutIconModel("", "", "", "");*/

  List<String> listIconName = [];
  List<String> listImage = [];
  List<String> listSliderImagesWebView = [];
  List<String> listSliderImagesWebViewTitle = [];
  List<String> listWebViewUrl = [];
  List<String> listViewPagerImages = [];
  List<String> listViewPagerWebViewUrl = [];
  List<String> listViewPagerWebViewTitle = [];
  List<String> listProgressTitle = [];
  List<String> listProgressValue = [];

  //List<ModelProgress> listProgress = [];
  String userDetailsJsonString = "";
  final PageController controller = new PageController();

  //var inviteCodeController = TextEditingController();

  var isNotValidated = false;
  String errorMsgForTextField = "";
  var invitationCode = "", referredStatus = "", referredCode = "";
  var bindedAlready = false;

  var isLoading = false;
  final getItLocator = GetIt.instance;
  var navigationService;
  ApiHelper apiHelper = ApiHelper();

  void getPatientProfileDetails() async {
    patientID = await getPatientID();
    /*ProgressDialog pr = ProgressDialog(context);
    Future.delayed(Duration.zero, () {
      pr.show();
    });*/
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
    /*pr.hide();*/
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);
      imgUrl = jsonData[0]['DoctorImage'];
      firstName = jsonData[0]['FirstName'];
      lastName = jsonData[0]['LastName'];
      middleName = jsonData[0]['MiddleName'];
      userNameGlobal = (firstName.trim() + " " + lastName.trim()).trim() != ""
          ? firstName.trim() + " " + lastName.trim()
          : "Complete your profile";
      mobNo = jsonData[0]['MobileNo'] != "" ? jsonData[0]['MobileNo'] : "-";
      doctorSuffix = jsonData[0]['DoctorSuffix'];
      couponCode = jsonData[0]['CouponCode'];
      downloadURL = jsonData[0]['DownloadURL'];
      setUserName(userNameGlobal);
      //setEmergencyNumber(jsonData[0]['EmergencyNumber']);
      debugPrint("Img url - $imgUrl");
      setState(() {});
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      /*ScaffoldMessenger.of(navigationService.navigatorKey.currentState)
          .showSnackBar(snackBar);*/
    }
  }

  showUpdateDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: "Please Update",
        description:
            "An updated version of this app is available. would you like to update?",
        buttonText: "Update",
        image: Image(
          width: 80,
          color: Colors.white,
          //height: 80,
          image: AssetImage("images/ic_download.png"),
        ),
      ),
    );
  }

  @override
  void initState() {
    /*mainSliderStatus = widget.mainSliderStatus;
    subSliderStatus = widget.subSliderStatus;
    dashboardCounterStatus = widget.dashboardCounterStatus;*/
    super.initState();
    listMasters = [];
    listMasters.add("Drug Frequency Master");
    listMasters.add("Drug Timing Master");
    listMasters.add("Drug Master");
    navigationService = getItLocator<NavigationService>();
    Future.delayed(Duration.zero, () {
      getPatientOrDoctorIDP().then((pIdp) {
        patientIDP = pIdp;
      });
      getPatientID().then((pID) {
        patientID = pID;
      });
      submitTokenToService(context);
      getDashboardData();
      getPatientProfileDetails();
    });
    notificationCounterApiCalled = false;
    notificationCount = "0";
    listIconName.add("Invite Patient");
    listIconName.add("Add Patient");
    listIconName.add("My Patients");
    //listIconName.add("Masters");
    // listIconName.add("Drugs");
    // listIconName.add("Services");
    listIconName.add("Appointment List");
    // listIconName.add("Form 3C");
    // listIconName.add("Health Videos");
    // listIconName.add("Lab Reports");
    listIconName.add("Camp");
    listIconName.add("Notifications");

    listImage.add("ic_invite_patient_dashboard.png");
    listImage.add("ic_add_patient.png");
    listImage.add("ic_patients_dashboard.png");
    //listImage.add("ic_master_dashboard.png");
    // listImage.add("ic_drugs_dashbord.png");
    // listImage.add("ic_opd_services_dashboard.png");
    listImage.add("ic_opd_registration_dashboard.png");
    // listImage.add("ic_form_3c_dashboard.png");
    // listImage.add("ic_education_videos_dashboard.png");
    // listImage.add("ic_report_dashbaord.png");
    listImage.add('ic_camp.png');
    listImage.add('ic_notification_bell.png');

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    userNameGlobal = "";
    /*payGatewayURL = "";*/
    super.dispose();
  }

  AppLifecycleState? lifeCycleState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("Last notification - $state");
    if (state == AppLifecycleState.resumed) {
      //if (widget.doctorIDP != "") bindUnbindDoctor("1", context);
    }
    setState(() {
      lifeCycleState = state;
    });
  }

  GlobalKey<ScaffoldState> globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF06A759),
    ));
    //notificationCounterApiCalled = false;
    /*void openWhatsapp() async {
      //await FlutterLaunch.launchWathsApp(phone: "918000083323", message: "");
      var whatsappUrl = "whatsapp://send?phone=919512682020&text=";
      await canLaunch(whatsappUrl)
          ? launch(whatsappUrl)
          : print(
          "open whatsapp app link or do a snackbar with notification that there is no whatsapp installed");
    }*/

    showConfirmationDialog(BuildContext context, String exitOrLogout) {
      var title = "";
      if (exitOrLogout == "exit") {
        title = "Do you really want to exit?";
      } else if (exitOrLogout == "logout") {
        title = "Do you really want to Logout?";
      }
      showDialog(
          context: context,
          barrierDismissible: false,
          // user must tap button for close dialog!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("No")),
                TextButton(
                    onPressed: () {
                      if (exitOrLogout == "exit") {
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      } else if (exitOrLogout == "logout") {
                        widget.logOut(context);
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreenDoctor()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                    child: Text("Yes"))
              ],
            );
          });
    }

    return SafeArea(
        child: Scaffold(
            primary: true,
            resizeToAvoidBottomInset: false,
            body: Builder(
              builder: (mContext) {
                return WillPopScope(
                    onWillPop: () => onBackPressed(mContext),
                    child: _createListView(mContext));
              },
            )));
  }

  showConfirmationDialogLogout(BuildContext context) {
    var title = "Do you really want to Logout?";
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No")),
              TextButton(
                  onPressed: () {
                    logOut(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LandingScreen()));
                  },
                  child: Text("Yes"))
            ],
          );
        });
  }

  logOut(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (mContext) => LandingScreen()),
    );
    Navigator.pop(context);
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

  showConfirmationDialog(BuildContext context, String exitOrLogout) {
    var title = "";
    if (exitOrLogout == "exit") {
      title = "Do you really want to exit?";
    } else if (exitOrLogout == "logout") {
      title = "Do you really want to Logout?";
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No")),
              TextButton(
                  onPressed: () {
                    if (exitOrLogout == "exit") {
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    } else if (exitOrLogout == "logout") {
                      widget.logOut(context);
                      Navigator.pop(context);
                      /*Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PreLoginScreen("")));*/
                    }
                  },
                  child: Text("Yes"))
            ],
          );
        });
  }

  onBackPressed(BuildContext context) {
    /*if (globalKey.currentState.isDrawerOpen) {
      Navigator.pop(globalKey.currentContext);
    } else {*/
    if (!shouldExit) {
      shouldExit = true;
      final snackBar = SnackBar(
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        content: Text("Press back button again to exit."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(seconds: 3), () {
        shouldExit = false;
      });
    } else {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
    //showConfirmationDialog(context, "exit");
    //}
  }

  showImagePopUp(BuildContext context, String imgUrl) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => PopUpDialogWithImage(
        imgUrl: imgUrl,
      ),
    );
  }

  void getDashboardData() async {
    String loginUrl = "${baseURL}doctorDashboard.php";
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
    var androidVersion = jsonResponse['apiversion'];
    var iosVersion = jsonResponse['apiversionios'];
    if (model.status == "OK") {
      if (Platform.isAndroid) {
        checkForUpdate();
        //if (androidVersion != "1") showUpdateDialog(context);
      } else if (Platform.isIOS) {
        if (iosVersion != "1") showUpdateDialog(context);
      }
      //showUpdateDialog(context);
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      String imgUrl = "${baseURL}images/popupimage/" + jsonData['PopupImage'];
      final jsonArrayMainSlider = jsonData['MainSlider'];
      listPhotos = [];
      for (var i = 0; i < jsonArrayMainSlider.length; i++) {
        var jsonIconObj = jsonArrayMainSlider[i];
        listPhotos.add("${baseURL}" + jsonIconObj['Path']);
        listSliderImagesWebViewOuter.add(jsonIconObj['Webview']);
        listSliderImagesWebViewTitleOuter.add(jsonIconObj["Title"]);
      }
      /*String oldPopUpIDP = await getPopUpIDP();
      String newPopUpIDP = jsonData['PopupIDP'];
      if (oldPopUpIDP != newPopUpIDP) {
        Future.delayed(Duration.zero, () {
          showImagePopUp(context, imgUrl);
        });
      }*/
      fullName = await getUserName();
      email = await getEmail();
      setPopUpIDP(jsonData['PopupIDP']);
      payGatewayURL = jsonData['PayGatewayURL'];
      setState(() {
        notificationCount = jsonData['NotificationCount'];
        messageCount =
            jsonData['ChatCount'] != null ? jsonData['ChatCount'] : "0";
      });
      /*var patientIDP = jsonData[0]['PatientIDP'];
      var patientUniqueKey = decodeBase64(jsonData[0]['PatientUniqueKey']);
      setMobNo(mobNo);
      setPatientIDP(patientIDP);
      setPatientUniqueKey(patientUniqueKey);
      setUserType("patient");
      Navigator.push(mContext,
          MaterialPageRoute(builder: (context) => PatientDashboardScreen()));*/
    }
    /*else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message),
      );
      ScaffoldMessenger.of(mContext).showSnackBar(snackBar);
    }*/
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void showCallOrSmsSelectionDialog(
      BuildContext context, String emergencyNumber, String name) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
              /*shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),*/
              backgroundColor: Colors.white,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(
                      SizeConfig.blockSizeHorizontal !* 3,
                    ),
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal !* 6.2,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal !* 6,
                        ),
                        Text(
                          "Choose Action",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal !* 4.8,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        launchURL("tel:$emergencyNumber");
                      },
                      child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.only(
                            top: 5,
                            bottom: 5,
                            left: 5,
                            right: 5,
                          ),
                          decoration: new BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            border: Border(
                              bottom:
                                  BorderSide(width: 2.0, color: Colors.grey),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                offset: const Offset(0.0, 10.0),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Call",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ))),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        _sendSMS(
                            "Hi, this is $name, I am in emergency! Need your help.",
                            ["$emergencyNumber"]);
                      },
                      child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.only(
                            top: 5,
                            bottom: 5,
                            left: 5,
                            right: 5,
                          ),
                          decoration: new BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            border: Border(
                              bottom:
                                  BorderSide(width: 2.0, color: Colors.grey),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                offset: const Offset(0.0, 10.0),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Sms",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ))),
                ],
              ),
            ));
  }

  Future<void> scanTheQRCodeNow(BuildContext context) async {
    var result = await BarcodeScanner.scan();

    print(result.type); // The result type (barcode, cancelled, failed)
    print(result.rawContent); // The barcode content
    if (result.type.toString() != "Cancelled" && result.rawContent != "")
      launchURL(decodeBase64(result.rawContent));
    /*final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text("QR Code content - " + result.rawContent),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    print(result.format); // The barcode format (as enum)
    print(result.formatNote);*/
  }

  void submitTokenToService(BuildContext context) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String loginUrl = "${baseURL}update_patient_token.php";
    String udid = await FlutterUdid.consistentUdid;
    var patientIDP = await getPatientOrDoctorIDP();
    var token = await getToken();
    if (token == "") {
      token = (await _firebaseMessaging.getToken())!;
      await setToken(token);
    }
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String ttype = "";
    if (Platform.isAndroid) {
      ttype = "android";
    } else if (Platform.isIOS) {
      ttype = "ios";
    }
    String jsonStr = "{" +
        "\"" +
        "PatientTypeIDF" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"" +
        "TypeOfPatient" +
        "\"" +
        ":" +
        "\"" +
        "doctor" +
        "\"" +
        "," +
        "\"" +
        "MACID" +
        "\"" +
        ":" +
        "\"" +
        udid +
        "\"" +
        "," +
        "\"" +
        "Token" +
        "\"" +
        ":" +
        "\"" +
        token +
        "\"" +
        "," +
        "\"" +
        "TokenType" +
        "\"" +
        ":" +
        "\"" +
        ttype +
        "\"" +
        "}";

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
  }

  void _sendSMS(String message, List<String> recipents) async {
    /* String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    //launchURL("tel://918000083323");
    print(_result);*/
    SmsStatus result = await BackgroundSms.sendMessage(
        phoneNumber: recipents[0], message: message);
    if (result == SmsStatus.sent) {
      print("Sent");
    } else {
      print("Failed");
    }
  }

  Widget _createListView(BuildContext mContext) {
    //if (widget.doctorIDP != "") bindUnbindDoctor("1", mContext);
    ScrollController _scrollController = ScrollController();
    debugPrint("before listener");
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        debugPrint("scrolled to end...");
        if (!isLoading) {
          getDashboardData();
        }
      }
    });
    return ListView(shrinkWrap: true, physics: ClampingScrollPhysics(),
        //uncommment for paging
        //controller: _scrollController,
        children: <Widget>[
          Container(
              height: SizeConfig.blockSizeVertical !* 10,
              color: Color(0xFF06A759),
              child: Padding(
                  padding: EdgeInsets.only(
                    left: SizeConfig.blockSizeHorizontal !* 5,
                    right: SizeConfig.blockSizeHorizontal !* 2,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: SizeConfig.blockSizeVertical !* 1,
                      ),
                      Align(
                          alignment: Alignment.topLeft,
                          child:
                              /*Row(
                            children: <Widget>[*/
                              /*Expanded(
                                child: Text("Unique ID - $patientID",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 3.6,
                                    )),
                              ),*/
                              Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Text("SWASTHYA SETU",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal !* 5,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  Expanded(
                                    child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                showConfirmationDialogLogout(
                                                    context);
                                              },
                                              child: Icon(
                                                Icons.logout,
                                                size: 32.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          )
                          /*],
                          )*/
                          ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical !* 0.5,
                      ),
                    ],
                  ))),
          listPhotos.length > 0
              ? Container(
                  height: SizeConfig.blockSizeVertical !* 25,
                  child: AutomaticPageView2(
                      listPhotos,
                      listSliderImagesWebViewOuter,
                      listSliderImagesWebViewTitleOuter),
                )
              : Container(
                  width: SizeConfig.blockSizeVertical !* 25,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/shimmer_effect.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
          Container(
              child: Center(
            child: GridView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: listIconName.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1.3, crossAxisCount: 3),
                itemBuilder: (context, index) {
                  return /*Center(
                      child: */
                      IconCard(
                    IconModel(listIconName[index], listImage[index], ""),
                    getDashboardData,
                  );
                  //: Container(),
                  /*);*/
                }),
          )),
          SizedBox(
            height: SizeConfig.blockSizeVertical !* 1,
          ),
          /*Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
                    child: MaterialButton(
                        height: SizeConfig.blockSizeVertical * 8,
                        shape: Border.all(width: 0.5, color: Color(0xFF06A759)),
                        */ /*color: Color(0xFFD3D3D3),*/ /*
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return DoctorsListScreen(patientIDP);
                          }));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image(
                              width: SizeConfig.blockSizeHorizontal * 6,
                              image: AssetImage('images/ic_doctors.png'),
                            ),
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal * 2,
                            ),
                            Text(
                              "My Doctors",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: SizeConfig.blockSizeHorizontal * 3.2,
                              ),
                            ),
                          ],
                        )),
                  )),
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
                    child: MaterialButton(
                        height: SizeConfig.blockSizeVertical * 8,
                        shape: Border.all(width: 0.5, color: Color(0xFF06A759)),
                        */ /*color: Color(0xFFD3D3D3),*/ /*
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: ((context) {
                            return HealthTipsScreen(patientIDP);
                          })));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image(
                              width: SizeConfig.blockSizeHorizontal * 6,
                              image: AssetImage('images/ic_health_tips.png'),
                            ),
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal * 2,
                            ),
                            Text(
                              "Health Tips",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: SizeConfig.blockSizeHorizontal * 3.2,
                              ),
                            ),
                          ],
                        )),
                  )),
            ],
          ),
          SizedBox(
            height: SizeConfig.blockSizeVertical * 1,
          ),*/
          /*Padding(
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Health Videos",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: SizeConfig.blockSizeHorizontal * 3.8,
                ),
              ),
            ),
          ),*/
          /*ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: listHealthVideos.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    debugPrint("vid play");
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                            listHealthVideos[index].webView,
                            listHealthVideos[index].iconName,
                            listHealthVideos[index].description)));
                  },
                  child: Padding(
                    padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
                    child: Column(
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            CachedNetworkImage(
                              placeholder: (context, url) => Image(
                                width: SizeConfig.blockSizeHorizontal * 92,
                                height: SizeConfig.blockSizeVertical * 32,
                                image: AssetImage('images/shimmer_effect.png'),
                                fit: BoxFit.contain,
                              ),
                              imageUrl: listHealthVideos[index].image,
                              fit: BoxFit.fitWidth,
                              width: SizeConfig.blockSizeHorizontal * 95,
                              height: SizeConfig.blockSizeVertical * 33,
                            ),
                            */ /*Image(
                                        width:
                                            SizeConfig.blockSizeHorizontal * 90,
                                        height:
                                            SizeConfig.blockSizeVertical * 28,
                                        fit: BoxFit.fill,
                                        image: NetworkImage(
                                            listHealthVideos[index].image),
                                      ),*/ /*
                            Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.green,
                                size: SizeConfig.blockSizeHorizontal * 30,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical * 1,
                        ),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: SizeConfig.blockSizeHorizontal * 2,
                                  right: SizeConfig.blockSizeHorizontal * 2),
                              child: Text(
                                listHealthVideos[index].iconName,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal * 4.2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )),
                        */ /*SizedBox(
                                                height: SizeConfig
                                                        .blockSizeVertical *
                                                    1,
                                              ),
                                              Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: SizeConfig
                                                                .blockSizeHorizontal *
                                                            2,
                                                        right: SizeConfig
                                                                .blockSizeHorizontal *
                                                            2),
                                                    child: Text(
                                                      listHealthVideos[index]
                                                          .description,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal *
                                                            3.5,
                                                      ),
                                                    ),
                                                  )),*/ /*
                        SizedBox(
                          height: SizeConfig.blockSizeVertical * 3,
                        ),
                      ],
                    ),
                  ),
                );
              }),*/
          /*Center(
            child: Visibility(
              visible: isLoading,
              child: CircularProgressIndicator(
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
          ),*/
        ]);
  }

  Future<void> showEmergencyNumberDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Emergency Number found'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You Need to enter Emergency Number first.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Go'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ViewProfileDetails();
                  })).then((value) {
                    getDashboardData();
                  });
                });
              },
            ),
          ],
        );
      },
    );
  }

  void checkForUpdate() {
    InAppUpdate.checkForUpdate().then((updateInfo) {
      setState(() {
        //_updateInfo = info;
        if (updateInfo.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          InAppUpdate.performImmediateUpdate().catchError((e) {
            debugPrint("Problem performing immediate update");
            debugPrint(e.toString());
          });
        }
      });
    }).catchError((e) {
      debugPrint("Problem checking for update (In-App Update)");
      debugPrint(e.toString());
    });
  }
}

class AutomaticPageView extends StatefulWidget {
  List<String> listViewPagerImages,
      listViewPagerWebUrl,
      listViewPagerWebViewTitle;

  AutomaticPageView(this.listViewPagerImages, this.listViewPagerWebUrl,
      this.listViewPagerWebViewTitle);

  @override
  State<StatefulWidget> createState() {
    return AutomaticPageViewState();
  }
}

class AutomaticPageViewState extends State<AutomaticPageView> {
  int _currentPage = 0;
  PageController _pageController = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    super.initState();
    if (subSliderTimeGlobal != "") {
      Timer.periodic(Duration(seconds: int.parse(subSliderTimeGlobal)),
          (Timer timer) {
        if (_currentPage < widget.listViewPagerImages.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        if (mounted)
          _pageController.animateToPage(
            _currentPage,
            duration: Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageIndicatorContainer(
      child: PageView(
        pageSnapping: true,
        onPageChanged: (page) => _currentPage = page,
        controller: _pageController,
        children: getAllChildrenForViewPager(
            context,
            widget.listViewPagerImages,
            widget.listViewPagerWebUrl,
            widget.listViewPagerWebViewTitle),
      ),
      align: IndicatorAlign.bottom,
      length: widget.listViewPagerImages.length,
      indicatorSpace: 5.0,
      padding: EdgeInsets.all(10),
      indicatorColor: Colors.white,
      indicatorSelectorColor: Color(0xFF06A759),
      shape: IndicatorShape.circle(size: 4),
    );
    /*return PageView(
      onPageChanged: (page) => _currentPage = page,
      controller: _pageController,
      children: getAllChildrenForViewPager(context, widget.listViewPagerImages, widget.listViewPagerWebUrl,widget.listViewPagerWebViewTitle),
    );*/
  }
}

class AutomaticPageView2 extends StatefulWidget {
  List<String> listViewPagerImages,
      listViewPagerWebUrl,
      listViewPagerWebViewTitle;

  AutomaticPageView2(this.listViewPagerImages, this.listViewPagerWebUrl,
      this.listViewPagerWebViewTitle);

  @override
  State<StatefulWidget> createState() {
    return AutomaticPageViewState2();
  }
}

class AutomaticPageViewState2 extends State<AutomaticPageView2> {
  int _currentPage = 0;
  PageController _pageController = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    super.initState();
    subSliderTimeGlobal = '3';
    if (subSliderTimeGlobal != "") {
      Timer.periodic(Duration(seconds: int.parse(subSliderTimeGlobal)),
          (Timer timer) {
        if (_currentPage < widget.listViewPagerImages.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        if (mounted)
          _pageController.animateToPage(
            _currentPage,
            duration: Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageIndicatorContainer(
      child: PageView(
        pageSnapping: true,
        onPageChanged: (page) => _currentPage = page,
        controller: _pageController,
        children: getAllChildrenForViewPager(
            context,
            widget.listViewPagerImages,
            widget.listViewPagerWebUrl,
            widget.listViewPagerWebViewTitle),
      ),
      align: IndicatorAlign.bottom,
      length: widget.listViewPagerImages.length,
      indicatorSpace: 5.0,
      /*padding: EdgeInsets.all(10),*/
      indicatorColor: Colors.white,
      indicatorSelectorColor: Color(0xFF06A759),
      shape: IndicatorShape.circle(size: 4),
    );
    /*return PageView(
      onPageChanged: (page) => _currentPage = page,
      controller: _pageController,
      children: getAllChildrenForViewPager(context, widget.listViewPagerImages, widget.listViewPagerWebUrl,widget.listViewPagerWebViewTitle),
    );*/
  }
}

goToWebview(BuildContext context, String iconName, String webView) {
  // if (webView != "") {
  //   final flutterWebViewPlugin = FlutterWebviewPlugin();
  //   flutterWebViewPlugin.onDestroy.listen((_) {
  //     if (Navigator.canPop(context)) {
  //       Navigator.of(context).pop();
  //     }
  //   });
  //   Navigator.push(context, MaterialPageRoute(builder: (mContext) {
  //     return new MaterialApp(
  //       debugShowCheckedModeBanner: false,
  //       theme: ThemeData(fontFamily: "Ubuntu", primaryColor: Color(0xFF06A759)),
  //       routes: {
  //         "/": (_) => new WebviewScaffold(
  //               withLocalStorage: true,
  //               withJavascript: true,
  //               url: webView,
  //               appBar: new AppBar(
  //                 backgroundColor: Color(0xFFFFFFFF),
  //                 title: new Text(iconName),
  //                 leading: new IconButton(
  //                     icon: new Icon(Icons.arrow_back_ios, color: colorBlack),
  //                     onPressed: () => {
  //                           Navigator.of(context).pop(),
  //                         }),
  //                 iconTheme: IconThemeData(
  //                     color: colorBlack,
  //                     size: SizeConfig.blockSizeVertical * 2.2),
  //                 textTheme: TextTheme(
  //                     subtitle1: TextStyle(
  //                         color: colorBlack,
  //                         fontFamily: "Ubuntu",
  //                         fontSize: SizeConfig.blockSizeVertical * 2.3)),
  //               ),
  //             ),
  //       },
  //     );
  //   }));
  // }
}

getAllChildrenForViewPager(
    BuildContext context,
    List<String> listViewPagerImages,
    List<String> listViewPagerWebViewUrl,
    List<String> listViewPagerWebViewTitle) {
  List<Widget> listWidgets = [];
  for (var i = 0; i < listViewPagerImages.length; i++) {
    listWidgets.add(InkWell(
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: CachedNetworkImage(
            placeholder: (context, url) => Image(
              image: AssetImage('images/shimmer_effect.png'),
              fit: BoxFit.cover,
              height: SizeConfig.blockSizeVertical !* 28,
            ),
            height: SizeConfig.blockSizeVertical !* 28,
            /*imageUrl: "$baseURL${listViewPagerImages[i]}",*/
            imageUrl: "${listViewPagerImages[i]}",
            fit: BoxFit.cover,
          ),
        ),
        onTap: () => goToWebview(context, listViewPagerWebViewTitle[i],
            listViewPagerWebViewUrl[i])));
  }
  return listWidgets;
}

// ignore: must_be_immutable
class IconCard extends StatelessWidget {
  IconModel? model;
  Function? getDashBoardData;

  IconCard(IconModel model, Function getDashBoardDataFn) {
    this.model = model;
    this.getDashBoardData = getDashBoardDataFn;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return InkWell(
        highlightColor: Colors.green[200],
        customBorder: CircleBorder(),
        onTap: () async {
          //String patientIDP = await getPatientIDP();
          if (model!.iconName == "Invite Patient") {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return InvitePatientScreen();
            })).then((value) {
              getDashBoardData!();
            });
          } else if (model!.iconName == "Appointment List") {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return OPDRegistrationScreen();
            })).then((value) {
              getDashBoardData!();
            });
          } else if (model!.iconName == "Health Videos") {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return DoctorHealthVideos(sourceScreen: "ReceptionDashboardScreen",);
            })).then((value) {
              getDashBoardData!();
            });
          } else if (model!.iconName == "Camp") {
            var name = await getUserName();
            Get.to(() => CampScreen())!.then((value) {
              //getDashBoardData();
            });
          } else if (model!.iconName == "Notifications") {
            var name = await getUserName();
            Get.to(() => SelectPatientsForShareVideo(null, name))!.then((value) {
              getDashBoardData!();
            });
          } else if (model!.iconName == "Lab Reports") {
            Get.to(() => LabReportsScreen())!.then((value) {
              getDashBoardData!();
            });
/*            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return LabReportsScreen();
            })).then((value) {
              getDashBoardData();
            });*/
          } else if (model!.iconName == "Services") {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return OPDServiceListScreen();
            })).then((value) {
              getDashBoardData!();
            });
          } else if (model!.iconName == "Add Patient") {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return AddPatientScreen(
                from: "onlyAddPatient",
              );
            })).then((value) {
              getDashBoardData!();
            });
          } else if (model!.iconName == "My Patients") {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return MyPatientsScreen();
            })).then((value) {
              getDashBoardData!();
            });
          } else if (model!.iconName == "Drugs") {
            showMasterSelectionDialog(listMasters, context);
            /*Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return ComingSoonScreen();
            }));*/
          } else if (model!.iconName == "Drugs") {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return DrugsListScreen();
            })).then((value) {
              getDashBoardData!();
            });
          } else if (model!.iconName == "Form 3C") {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Form3CScreen();
            })).then((value) {
              getDashBoardData!();
            });
          }
        },
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: Center(
            child: Container(
              child: Column(
                  /*mainAxisSize: MainAxisSize.values[200],*/
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    //Icon(choice.icon, size:80.0, color: textStyle.color),
                    /*SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),*/
                    Image(
                      /*'$baseURL${model.image}',*/
                      width: SizeConfig.blockSizeHorizontal !* 9,
                      height: SizeConfig.blockSizeHorizontal !* 9,
                      color: Color(0xFF06A759),
                      image: AssetImage(
                        'images/${model!.image}',
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical !* 2,
                    ),
                    Flexible(
                      child: Text(model!.iconName!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: SizeConfig.blockSizeHorizontal !* 2.8,
                          )),
                    ),
                  ]),
            ),
          ),
        )) /*)*/;
  }

  void showMasterSelectionDialog(List<String> list, BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: SizeConfig.blockSizeVertical !* 8,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal !* 6.2,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal !* 6,
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal !* 50,
                          height: SizeConfig.blockSizeVertical !* 8,
                          child: Center(
                            child: Text(
                              "Select Master",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal !* 4.8,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListView.builder(
                    itemCount: list.length,
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            /*bloodGroupController =
                                  TextEditingController(text: list[index]);
                              setState(() {});*/
                            Navigator.of(context).pop();
                            if (index == 2) {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return DrugsListScreen();
                              })).then((value) {
                                getDashBoardData!();
                              });
                            } else {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return MastersListScreen(
                                    listMasters[index], index);
                              })).then((value) {
                                getDashBoardData!();
                              });
                            }
                          },
                          child: Padding(
                              padding: EdgeInsets.all(0.0),
                              child: Container(
                                  width: SizeConfig.blockSizeHorizontal !* 90,
                                  padding: EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                    left: 5,
                                    right: 5,
                                  ),
                                  decoration: new BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 2.0, color: Colors.grey),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10.0,
                                        offset: const Offset(0.0, 10.0),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      list[index],
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ))));
                    }),
                /*Expanded(
                    child: Container(
                  color: Colors.transparent,
                )),*/
              ],
            )));
  }

  void showLanguageSelectionDialog(BuildContext context, String patientIDP) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
              /*shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),*/
              backgroundColor: Colors.white,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(
                      SizeConfig.blockSizeHorizontal !* 3,
                    ),
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal !* 6.2,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal !* 6,
                        ),
                        Text(
                          "Choose Language",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal !* 4.8,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => CoronaQuestionnaireScreen(
                                    patientIDP, "eng")))
                            .then((value) {
                          getDashBoardData!();
                        });
                      },
                      child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.only(
                            top: 5,
                            bottom: 5,
                            left: 5,
                            right: 5,
                          ),
                          decoration: new BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            border: Border(
                              bottom:
                                  BorderSide(width: 2.0, color: Colors.grey),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                offset: const Offset(0.0, 10.0),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "English",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ))),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => CoronaQuestionnaireScreen(
                                    patientIDP, "guj")))
                            .then((value) {
                          getDashBoardData!();
                        });
                      },
                      child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.only(
                            top: 5,
                            bottom: 5,
                            left: 5,
                            right: 5,
                          ),
                          decoration: new BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            border: Border(
                              bottom:
                                  BorderSide(width: 2.0, color: Colors.grey),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                offset: const Offset(0.0, 10.0),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Gujarati",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ))),
                ],
              ),
            ));
  }
}

class ImageRotater extends StatefulWidget {
  List<String> photos;

  ImageRotater(this.photos);

  @override
  State<StatefulWidget> createState() => new ImageRotaterState();
}

class ImageRotaterState extends State<ImageRotater> {
  int _pos = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (mainSliderTimeGlobal != "")
      _timer = Timer.periodic(
          Duration(seconds: int.parse(mainSliderTimeGlobal)), (timer) {
        setState(() {
          if (_pos == widget.photos.length - 1)
            _pos = 0;
          else
            _pos = (_pos + 1) % widget.photos.length;
        });
      });
    /*_timer = Timer(new Duration(seconds: 5), () {
      setState(() {
        */ /*if (_pos == widget.photos.length - 1)
          _pos = 0;
        else*/ /*
          _pos = (_pos + 1) % widget.photos.length;
      });
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => goToWebview(context, listSliderImagesWebViewTitleOuter[_pos],
          listSliderImagesWebViewOuter[_pos]),
      child: CachedNetworkImage(
        fadeInDuration: Duration.zero,
        placeholder: (context, url) => Image(
          image: AssetImage('images/shimmer_effect.png'),
          fit: BoxFit.cover,
        ),
        /*imageUrl: widget.photos.length > 0
            ? "$baseURL${widget.photos[_pos]}"
            : AssetImage('images/shimmer_effect.png'),*/
        imageUrl: getImageUrl(widget.photos,_pos),
        fit: BoxFit.cover,
      ),
      /*FadeInImage(
          fadeInDuration: Duration(milliseconds: 10),
          placeholder: AssetImage('images/shimmer_effect.png'),
          image: NetworkImage("$baseURL${widget.photos[_pos]}"),
          fit: BoxFit.cover),*/
    );

    /*return new Image.network(
      widget.photos[_pos],
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );*/
  }

  @override
  void dispose() {
    if (mainSliderTimeGlobal != "") {
      _timer!.cancel();
      _timer = null;
    }
    super.dispose();
  }
}

getImageUrl(List<String> photos,int _pos) {
  photos.length > 0
      ? "${photos[_pos]}"
      : AssetImage('images/shimmer_effect.png');
}
