import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_sms/background_sms.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:page_indicator/page_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silvertouch/api/api_helper.dart';
import 'package:silvertouch/app_screens/VitalsCombineListScreen.dart';
import 'package:silvertouch/app_screens/all_consultation.dart';
import 'package:silvertouch/app_screens/all_videos_screen.dart';
import 'package:silvertouch/app_screens/doctors_list_screen.dart';
import 'package:silvertouch/app_screens/edit_my_profile_patient.dart';
import 'package:silvertouch/app_screens/help_screen.dart';
import 'package:silvertouch/app_screens/investigations_list_with_graph.dart';
import 'package:silvertouch/app_screens/my_appointments_patient.dart';
import 'package:silvertouch/app_screens/my_qr_code_screen.dart';
import 'package:silvertouch/app_screens/order_blood_screen.dart';
import 'package:silvertouch/app_screens/order_medicine_screen.dart';
import 'package:silvertouch/app_screens/play_video_screen.dart';
import 'package:silvertouch/app_screens/report_patient_screen.dart';
import 'package:silvertouch/app_screens/select_profile_screen.dart';
import 'package:silvertouch/app_screens/view_profile_details_patient.dart';
import 'package:silvertouch/app_screens/vitals_list.dart';
import 'package:silvertouch/app_screens/your_account_validity_expired_screen.dart';
import 'package:silvertouch/enums/expiry_state.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_icon.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/model_investigation_master_list.dart';
import 'package:silvertouch/podo/model_profile_patient.dart';
import 'package:silvertouch/podo/response_login_icons_model.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/services/navigation_service.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';
import 'package:silvertouch/widgets/webview_container.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../podo/model_drawer.dart';
import '../utils/color.dart';
import 'all_modules.dart';
import 'check_expiry_blank_screen.dart';
import 'custom_dialog.dart';
import 'doctor_dashboard_screen.dart';
import 'fill_profile_details.dart';
import 'landing_screen.dart';
import 'my_payments_patient.dart';

List<String> listSliderImagesWebViewTitleOuter = [];
List<ModelInvestigationMaster> listInvestigationMaster = [];

List<IconModel> listHealthVideos = [];

String mainSliderTimeGlobal = "", subSliderTimeGlobal = "";

int bottomNavBarIndex = 0;

String imgUrl = "",
    firstName = "",
    lastName = "",
    middleName = "",
    userNameGlobal = "",
    patientID = "",
    expiryDate = "";
String userName = "",
    mobNo = "",
    emailId = "",
    dob = "",
    age = "-",
    address = "",
    city = "",
    state = "",
    country = "",
    married = "",
    noOfFamilyMembers = "",
    yourPositionInFamily = "";
String countryIDF = "", stateIDF = "", cityIDF = "";
String weight = "", height = "", bloodGroup = "", emergencyNumber = "";
String gender = "";

String? patientIDP;

bool shouldExit = false;
/*
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
*/
/*FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();*/

// ignore: must_be_immutable
class PatientDashboardScreen extends StatefulWidget {
  String doctorIDP;

  PatientDashboardScreen(this.doctorIDP);

  logOut(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (mContext) => PreLoginScreen("")),
    );
    Navigator.pop(context);*/
  }

  @override
  State<StatefulWidget> createState() {
    return PatientDashboardState();
  }
}

class PatientDashboardState extends State<PatientDashboardScreen>
    with WidgetsBindingObserver {
  final String urlFetchPatientProfileDetails =
      "${baseURL}patientProfileData.php";

  String mainSliderStatus = "1",
      subSliderStatus = "1",
      dashboardCounterStatus = "0",
      aboutIconStatus = "1";
  bool notificationCounterApiCalled = false;
  String notificationCount = "0";
  Timer? _timer;
  var userData = [];

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
  List<ModelIcon> listIcons = [];

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
  dynamic jsonObj;
  ApiHelper apiHelper = ApiHelper();
  bool showEnglish = true;

  void bindUnbindDoctor(String bindFlag, BuildContext context) async {
    debugPrint("Bind doctor : " + widget.doctorIDP);
    String loginUrl = "${baseURL}patientBindDoctor.php";
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
        patientIDP! +
        "\"" +
        "," +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.doctorIDP +
        "\"" +
        "," +
        "\"" +
        "FirstName" +
        "\"" +
        ":" +
        "\"" +
        "\"" +
        "," +
        "\"" +
        "LastName" +
        "\"" +
        ":" +
        "\"" +
        "\"" +
        "," +
        "\"" +
        "BindFlag" +
        "\"" +
        ":" +
        "\"" +
        bindFlag +
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
    bindedAlready = true;
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    //pr.hide();

    if (model.status == "OK") {
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      /*ScaffoldMessenger.of(navigationService.navigatorKey.currentState)
          .showSnackBar(snackBar);*/
      //_scaffoldKey.currentState.showSnackBar(snackBar);
      showDialog(
          context: navigationService.navigatorKey.currentState.overlay.context,
          // Using overlay's context
          builder: (context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text(model.message!),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Ok"))
              ],
            );
          });
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      showDialog(
          context: navigationService.navigatorKey.currentState.overlay.context,
          // Using overlay's context
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(model.message!),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Ok",
                  ),
                )
              ],
            );
          });
      //_scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  void generateSelectedProfile(mContext, jsonData) {
    var patientIDP = jsonData['PatientIDP'];
    var patientUniqueKey = decodeBase64(jsonData['PatientUniqueKey']);
    var middleName = jsonData['MiddleName'].toString();
    var isPayment =
        jsonData['RequiredPayment'].toString() == "1" ? true : false;
    if (jsonData["FirtLoginStatus"] == "0") {
      setUserName(jsonData['FirstName'].toString().trim() +
          " " +
          middleName.trim() +
          " " +
          jsonData['LastName'].toString().trim());
      setEmail(jsonData['EmailID']);
      setPatientID(jsonData['PatientID']);
      setMobNo(mobNo);
      setPatientIDP(patientIDP);
      setPatientUniqueKey(patientUniqueKey);
      setUserType("patient");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (mContext) =>
              CheckExpiryBlankScreen(widget.doctorIDP, "main", false, null),
        ),
        (Route<dynamic> route) => false,
      );
      Navigator.pushReplacement(
          mContext,
          MaterialPageRoute(
              builder: (context) => CheckExpiryBlankScreen(
                  widget.doctorIDP, "main", false, null)));
    } else {
      setPatientID(jsonData['PatientID']);
      setPatientIDP(patientIDP);
      setPatientUniqueKey(patientUniqueKey);
      setMobNo(mobNo);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (mContext) =>
              FillProfileDetails(widget.doctorIDP, isPayment),
        ),
        (Route<dynamic> route) => false,
      );
      /*Navigator.pushReplacement(
          mContext,
          MaterialPageRoute(
              builder: (context) =>
                  FillProfileDetails(widget.doctorIDP, isPayment)));*/
    }
  }

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
        "{" + "\"" + "PatientIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: urlFetchPatientProfileDetails,
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
      jsonObj = jsonData[0];
      imgUrl = jsonData[0]['Image'];
      firstName = jsonData[0]['FirstName'];
      lastName = jsonData[0]['LastName'];
      middleName = jsonData[0]['MiddleName'];
      patientID = jsonData[0]['PatientID'];
      mobNo = jsonData[0]['MobileNo'] != "" ? jsonData[0]['MobileNo'] : "-";
      emailId = jsonData[0]['EmailID'] != "" ? jsonData[0]['EmailID'] : "-";
      imgUrl = jsonData[0]['Image'];

      dob = jsonData[0]['DOB'] != "" ? jsonData[0]['DOB'] : "-";
      address = jsonData[0]['Address'] != "" ? jsonData[0]['Address'] : "-";
      city = jsonData[0]['CityName'] != "" ? jsonData[0]['CityName'] : "-";
      state = jsonData[0]['StateName'] != "" ? jsonData[0]['StateName'] : "-";
      country =
          jsonData[0]['CountryName'] != "" ? jsonData[0]['CountryName'] : "-";

      married = jsonData[0]['Married'] != "" ? jsonData[0]['Married'] : "-";
      noOfFamilyMembers = jsonData[0]['NoOfFamilyMember'] != ""
          ? jsonData[0]['NoOfFamilyMember']
          : "-";
      yourPositionInFamily = jsonData[0]['YourPostionInFamily'] != ""
          ? jsonData[0]['YourPostionInFamily']
          : "-";
      age = jsonData[0]['Age'] != "" ? jsonData[0]['Age'] : "-";
      countryIDF = jsonData[0]['CountryIDF'];
      stateIDF = jsonData[0]['StateIDF'];
      cityIDF = jsonData[0]['CityIDF'];

      weight = jsonData[0]['Wieght'] != ""
          ? double.parse(jsonData[0]['Wieght']).round().toString()
          : "0";
      height = jsonData[0]['Height'] != ""
          ? double.parse(jsonData[0]['Height']).round().toString()
          : "0";
      bloodGroup = jsonData[0]['BloodGroup'];
      //emergencyNumber = jsonData[0]['EmergencyNumber'];
      emergencyNumber = "";
      gender = jsonData[0]['Gender'];
      expiryDate = jsonData[0]['ExpiryDate'];
      userNameGlobal = (firstName.trim() +
                      " " +
                      middleName.trim() +
                      " " +
                      lastName.trim())
                  .trim() !=
              ""
          ? firstName.trim() + " " + middleName.trim() + " " + lastName.trim()
          : "Complete your profile";
      mobNo = jsonData[0]['MobileNo'] != "" ? jsonData[0]['MobileNo'] : "-";
      setUserName(userNameGlobal);
      setEmergencyNumber(jsonData[0]['EmergencyNumber']);
      debugPrint("Img url - $imgUrl");
      setState(() {});
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(navigationService.navigatorKey.currentState)
          .showSnackBar(snackBar);
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
    jsonObj = {};
    listHealthVideos = [];
    navigationService = getItLocator<NavigationService>();
    bottomNavBarIndex = 0;
    Future.delayed(Duration.zero, () {
      getPatientOrDoctorIDP().then((pIdp) {
        patientIDP = pIdp;
        if (widget.doctorIDP != "") bindUnbindDoctor("1", context);
      });
      getPatientID().then((pID) {
        patientID = pID;
      });
      submitTokenToService(context);
      getDashboardData();
      getExpiryDetails();

      getUserDetails().then((value) {
        var strData = decodeBase64(value);
        debugPrint("Decoded Data Array : " + strData);
        userData = json.decode(strData);
        setState(() {});
      });
      getPatientProfileDetails();
    });
    notificationCounterApiCalled = false;
    notificationCount = "0";
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Consultation",
        iconImg: "v-2-icn-briefcase.png",
        iconColor: Color(0xFF615E3F),
        iconBgColor: Color(0xFFF2EEBF),
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Order\nMedicine",
        iconImg: "v-2-icn-order-medicine.png",
        iconColor: Color(0xFFFF6347),
        iconBgColor: Colors.orange,
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Order\nBlood Test",
        iconImg: "v-2-icn-blood-test.png",
        iconColor: Colors.pink,
        iconBgColor: Colors.red,
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Blood\nPressure",
        iconImg: "v-2-icn-blood-pressure.png",
        iconColor: Colors.red,
        iconBgColor: Colors.red,
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Blood\nSugar",
        iconImg: "v-2-icn-blood-sugar.png",
        iconColor: Colors.lightBlue,
        iconBgColor: Colors.lightBlue,
        iconData: null));
    listIcons.add(ModelIcon(
        iconType: "image",
        iconName: "Vitals",
        iconImg: "v-2-icn-pulse.png",
        iconData: null));
    //listIconName.add("Appointment");
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      setState(() {
        showEnglish = !showEnglish;
      });
    });
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _handlePermission(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    userNameGlobal = "";
    bottomNavBarIndex = 0;
    _timer!.cancel();
    super.dispose();
  }

  AppLifecycleState? lifeCycleState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("Last notification - $state");
    if (state == AppLifecycleState.resumed) {
      if (widget.doctorIDP != "") bindUnbindDoctor("1", context);
    }
    setState(() {
      lifeCycleState = state;
    });
  }

  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  int tappedIndex = -1;
  final List<DrawerModel> liste = [
    DrawerModel(title: "Home", image: "images/v-2-icn-categories-nav.png"),
    DrawerModel(
        title: "My Appointment", image: "images/v-2-icn-calender-gray.png"),
    DrawerModel(title: "My Doctors", image: "images/v-2-icn-doctor-nav.png"),
    // DrawerModel(
    //     title: "Update Profile", image: "images/v-2-icn-profile-nav.png"),
    DrawerModel(
        title: "My Prescription", image: "images/v-2-icn-prescription-nav.png"),
    DrawerModel(title: "Share this app", image: "images/ic_website.png"),
    DrawerModel(title: "Help", image: "images/ic_whatsapp.png"),
    DrawerModel(title: "Log out", image: "images/v-2-icn-logout-nav.png"),
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    var size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: blueThemeColor,
    ));

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 0,
              backgroundColor: blueThemeColor,
            ),
            primary: true,
            key: globalKey,
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    color: Color(0xfff0f1f5),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: Row(
                      children: [
                        (imgUrl != null)
                            ? InkWell(
                                onTap: () {},
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.transparent,
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage("$userImgUrl$imgUrl"),
                                    radius: 28,
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: () {},
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: colorBlueDark,
                                  child: CircleAvatar(
                                    backgroundImage: AssetImage(
                                        "images/ic_user_placeholder.png"),
                                    radius: 28,
                                  ),
                                ),
                              ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$userNameGlobal",
                              style: TextStyle(
                                  color: colorBlueDark,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal! * 3.3,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              "ID - $patientID",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: SizeConfig.blockSizeHorizontal! * 3.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: liste.length,
                    itemBuilder: (_, i) {
                      return Column(
                        children: [
                          i == 7
                              ? Divider(
                                  color: colorgreyText,
                                  height: 0,
                                )
                              : Container(),
                          ListTile(
                            // tileColor: tappedIndex == i ? Colors.blue : null,
                            tileColor: null,
                            // If current item is selected show blue color
                            // leading: Image.asset(liste[i].image,
                            //     width: SizeConfig.blockSizeHorizontal * 4.0,
                            //     color: tappedIndex == i
                            //         ? Colors.white
                            //         : Colors.black),
                            leading: Image.asset(liste[i].image!,
                                width: SizeConfig.blockSizeHorizontal! * 4.0,
                                color: Colors.black),
                            trailing: i == 1 || i == 5
                                ? null
                                //  buildNotificationCount(i)
                                : null,
                            minLeadingWidth: 10,
                            // title: Text(liste[i].title,
                            //     style: TextStyle(
                            //         color: tappedIndex == i
                            //             ? Colors.white
                            //             : Colors.black)),
                            title: Text(liste[i].title!,
                                style: TextStyle(color: Colors.black)),
                            onTap: () {
                              // setState(() {
                              //   tappedIndex = i;
                              //echart });
                              if (i == 0) {
                                Navigator.pop(context);
                              } else if (i == 1) {
                                Navigator.pop(context);
                                Get.to(() => MyAppointmentsPatientScreen());
                              } else if (i == 2) {
                                Navigator.pop(context);
                                Get.to(() =>
                                    DoctorsListScreen(patientIDP!, true, "1"));
                                // Get.to(() => MyChats(patientIDP));
                              } else if (i == 3) {
                                Navigator.pop(context);
                                Get.to(() => PatientReportScreen(
                                    patientIDP!, "prescription_fixed", false));
                              } else if (i == 4) {
                                Navigator.pop(context);
                                Share.share(
                                    'https://play.google.com/store/apps/details?id=com.swasthyasetu.swasthyasetu&pli=1',
                                    subject: '');
                              } else if (i == 5) {
                                Navigator.pop(context);
                                Get.to(() => HelpScreen(patientIDP!));
                              } else if (i == 6) {
                                Navigator.pop(context);
                                //     Get.to(() => VitalsListScreen(patientIDP));
                                showConfirmationDialogLogout(
                                  context,
                                );
                              }
                              // else if (i == 7) {
                              // Navigator.pop(context);
                              // showConfirmationDialogLogout(
                              //   context,
                              // );
                              // }
                            }, // Reverse bool value
                          ),
                          i == 7
                              ? Divider(
                                  color: colorgreyText,
                                  height: 0,
                                )
                              : Container(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              elevation: 0,
              selectedItemColor: colorBlueApp,
              unselectedItemColor: Colors.black,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              currentIndex: bottomNavBarIndex,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                if (index == 3) {
                  openDrawer();
                } else {
                  onTabTapped(index, context);
                }
              },
              items: [
                BottomNavigationBarItem(
                    activeIcon: Image(
                      image: AssetImage(
                        "images/v-2-icn-categories-nav.png",
                      ),
                      color: colorBlueApp,
                      width: SizeConfig.blockSizeHorizontal! * 6,
                    ),
                    icon: Image(
                      image: AssetImage(
                        "images/v-2-icn-categories-nav.png",
                      ),
                      color: darkgrey,
                      width: SizeConfig.blockSizeHorizontal! * 6,
                    ),
                    label: 'Home'),
                BottomNavigationBarItem(
                    activeIcon: Image(
                      image: AssetImage(
                        "images/icn-receipt-rupee.png",
                      ),
                      color: colorBlueApp,
                      width: SizeConfig.blockSizeHorizontal! * 6,
                    ),
                    icon: Image(
                      image: AssetImage(
                        "images/icn-receipt-rupee.png",
                      ),
                      color: darkgrey,
                      width: SizeConfig.blockSizeHorizontal! * 6,
                    ),
                    label: 'Payment'),
                BottomNavigationBarItem(
                    activeIcon: Image(
                      image: AssetImage(
                        "images/v-2-icn-profile-nav.png",
                      ),
                      color: colorBlueApp,
                      width: SizeConfig.blockSizeHorizontal! * 6,
                    ),
                    icon: Image(
                      image: AssetImage(
                        "images/v-2-icn-profile-nav.png",
                      ),
                      color: darkgrey,
                      width: SizeConfig.blockSizeHorizontal! * 6,
                    ),
                    label: 'Profile'),
                /*BottomNavigationBarItem(
                  activeIcon: FaIcon(
                    FontAwesomeIcons.stethoscope,
                    color: Color(0xFF06A759),
                    size: SizeConfig.blockSizeHorizontal * 6,
                  ),
                  icon: FaIcon(
                    FontAwesomeIcons.stethoscope,
                    color: Colors.grey,
                    size: SizeConfig.blockSizeHorizontal * 6,
                  ),
                  label: "My\nAppointments",
                ),*/
                /*BottomNavigationBarItem(
                    activeIcon: Icon(
                      Icons.person,
                      color: colorBlueApp,
                      size: SizeConfig.blockSizeHorizontal * 6,
                    ),
                    icon: Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: SizeConfig.blockSizeHorizontal * 6,
                    ),
                    label: "My Profile"),*/
                BottomNavigationBarItem(
                    activeIcon: Icon(
                      Icons.menu,
                      color: colorBlueApp,
                      size: SizeConfig.blockSizeHorizontal! * 6,
                    ),
                    icon: Icon(
                      Icons.menu,
                      color: Colors.grey,
                      size: SizeConfig.blockSizeHorizontal! * 6,
                    ),
                    label: "Menu"),
              ],
            ),
            body: Builder(
              builder: (mContext) {
                return WillPopScope(
                    onWillPop: () => onBackPressed(mContext),
                    child: bottomNavBarIndex == 0 || bottomNavBarIndex == 1
                        ? _createListView(mContext)
                        : /*(bottomNavBarIndex == 2
                            ? MyAppointmentsPatientScreen()*/
                        (bottomNavBarIndex == 2
                            ? generalProfileWidget(mContext, context)
                            : Container()));
              },
            )));
  }

  Container buildNotificationCount(int i) {
    return Container(
        child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        //set border radius more than 50% of height and width to make circle
      ),
      color: tappedIndex == i ? colorWhite : colorBlueDark,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "2",
          style:
              TextStyle(color: tappedIndex == i ? colorBlueDark : colorWhite),
          textAlign: TextAlign.center,
        ),
      ),
    ));
  }

  openDrawer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (globalKey.currentState!.isDrawerOpen) {
        globalKey.currentState!.openEndDrawer();
      } else {
        globalKey.currentState!.openDrawer();
      }
    });
  }

  Widget generalProfileWidget(BuildContext mContext, BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          height: SizeConfig.blockSizeVertical! * 90,
          width: SizeConfig.blockSizeHorizontal! * 100,
          child: ListView(
            children: [
              Container(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 1,
                        ),
                        ColoredBox(
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    SizeConfig.blockSizeHorizontal! * 2.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: SizeConfig.blockSizeHorizontal! *
                                            8.0),
                                    child: Text(
                                      "General Profile",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! *
                                                5.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditMyProfilePatient(
                                                  PatientProfileModel(
                                                      firstName,
                                                      lastName,
                                                      mobNo,
                                                      emailId,
                                                      imgUrl,
                                                      dob,
                                                      age,
                                                      address,
                                                      city,
                                                      state,
                                                      country,
                                                      married,
                                                      noOfFamilyMembers,
                                                      yourPositionInFamily,
                                                      countryIDF,
                                                      stateIDF,
                                                      cityIDF,
                                                      middleName,
                                                      weight,
                                                      height,
                                                      bloodGroup,
                                                      emergencyNumber,
                                                      gender,
                                                      patientID: patientID),
                                                  imgUrl,
                                                  patientIDP!,
                                                ))).then(
                                        (value) => getPatientProfileDetails())
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                    size: 25,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () => {
                                    if (userData.length > 0)
                                      {switchProfile(context)}
                                  },
                                  child: Icon(
                                    Icons.people,
                                    color: Colors.black,
                                    size: 25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        (imgUrl != null)
                            ? InkWell(
                                onTap: () {
                                  Get.to(() => ViewProfileDetails(
                                            from: "patientViewMedicalProfile",
                                          ))!
                                      .then((value) {
                                    getPatientProfileDetails();
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.transparent,
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage("$userImgUrl$imgUrl"),
                                    radius: 48,
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  Get.to(() => ViewProfileDetails(
                                            from: "patientViewMedicalProfile",
                                          ))!
                                      .then((value) {
                                    getPatientProfileDetails();
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: colorBlueDark,
                                  child: CircleAvatar(
                                    backgroundImage: AssetImage(
                                        "images/ic_user_placeholder.png"),
                                    radius: 48,
                                  ),
                                ),
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            "$userNameGlobal",
                            style: TextStyle(
                                color: colorBlueDark,
                                fontSize: SizeConfig.blockSizeHorizontal! * 3.3,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "ID - $patientID",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              width: 20,
                              height: 20,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Divider(
                            color: Colors.grey.withOpacity(0.2),
                            thickness: 2,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Mobile",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "$mobNo",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal! *
                                                  3.3,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Subscription Validity",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "$expiryDate",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal! *
                                                  3.3,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                InkWell(
                                  onTap: () => Get.to(() => MyQRCodeScreen("")),
                                  child: Image(
                                    image: AssetImage(
                                        "images/ic_scan_and_pay_footer.png"),
                                    width: SizeConfig.blockSizeHorizontal! * 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: EdgeInsets.all(20),
                            color: Colors.grey.withOpacity(0.1),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () =>
                                      Get.to(() => HelpScreen(patientIDP!)),
                                  child: Image.asset(
                                    "images/v-2-icn-medical-profile.png",
                                    width:
                                        SizeConfig.blockSizeHorizontal! * 6.0,
                                  ),
                                ),
                                SizedBox(
                                  width: SizeConfig.blockSizeHorizontal! * 2.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height:
                                              SizeConfig.blockSizeHorizontal! *
                                                  1.0,
                                        ),
                                        Text(
                                          "Medical Profile",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                5.0,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              SizeConfig.blockSizeHorizontal! *
                                                  4.0,
                                        ),
                                        Text(
                                          "Medical History",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.0,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              SizeConfig.blockSizeHorizontal! *
                                                  1.0,
                                        ),
                                        Text(
                                          "Diabetes -${jsonObj['DiabetesVal']}",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.3,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              SizeConfig.blockSizeHorizontal! *
                                                  4.0,
                                        ),
                                        Text(
                                          "Surgical History",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.0,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              SizeConfig.blockSizeHorizontal! *
                                                  1.0,
                                        ),
                                        Text(
                                          jsonObj['SurgicalHistory'],
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.3,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              SizeConfig.blockSizeHorizontal! *
                                                  4.0,
                                        ),
                                        Text(
                                          "Drug Allergy",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.0,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              SizeConfig.blockSizeHorizontal! *
                                                  1.0,
                                        ),
                                        Text(
                                          jsonObj['DrugAllergy'],
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.3,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              SizeConfig.blockSizeHorizontal! *
                                                  4.0,
                                        ),
                                        Text(
                                          "Blood Group",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.0,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              SizeConfig.blockSizeHorizontal! *
                                                  1.0,
                                        ),
                                        Text(
                                          jsonObj['BloodGroup'],
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Get.to(() => ViewProfileDetails(
                                                  from:
                                                      "patientViewMedicalProfile",
                                                ))!
                                            .then((value) {
                                          getPatientProfileDetails();
                                        });
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            "Full View",
                                            style: TextStyle(
                                                color: colorBlueDark,
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    4.0),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Image.asset(
                                            "images/v-2-icn-fullscreen.png",
                                            width: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 1.0,
                    ),
                    InkWell(
                      onTap: () {
                        showConfirmationDialogLogout(
                          context,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("images/v-2-icn-logout-nav.png",
                              width: SizeConfig.blockSizeHorizontal! * 6.0,
                              color: Colors.black),
                          SizedBox(
                            width: SizeConfig.blockSizeVertical! * 1.0,
                          ),
                          Text(
                            "Sign Out",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 4.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      })
    ]));
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
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LandingScreen()),
                        (Route<dynamic> route) => false);
                  },
                  child: Text("Yes"))
            ],
          );
        });
  }

  logOut(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (mContext) => LandingScreen(),
      ),
      (Route<dynamic> route) => false,
    );
    //Navigator.pop(context);
  }

  Future<void> onTabTapped(int index, BuildContext context) async {
    if (index == 1) {
      //scanTheQRCodeNow(context);
      showPaymentTypeSelectionDialog(context);
      index = 0;
    }
    setState(() {
      bottomNavBarIndex = index;
    });
  }

  showPaymentTypeSelectionDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: dialogContent(context, "Payments"),
            ));
  }

  dialogContent(BuildContext context, String title) {
    return Stack(
      children: <Widget>[
        Container(
          width: SizeConfig.blockSizeHorizontal! * 90,
          height: SizeConfig.blockSizeVertical! * 25,
          padding: EdgeInsets.only(
            top: SizeConfig.blockSizeHorizontal! * 1,
            bottom: SizeConfig.blockSizeHorizontal! * 1,
            left: SizeConfig.blockSizeHorizontal! * 1,
            right: SizeConfig.blockSizeHorizontal! * 1,
          ),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  MaterialButton(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.red,
                      size: SizeConfig.blockSizeVertical! * 4.0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal! * 4.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 0.5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        scanTheQRCodeNow(context);
                      },
                      child: Column(
                        children: [
                          Image(
                            fit: BoxFit.contain,
                            width: SizeConfig.blockSizeHorizontal! * 10,
                            height: SizeConfig.blockSizeVertical! * 10,
                            //height: 80,
                            image: AssetImage(
                                "images/ic_scan_and_pay_to_doctor.png"),
                          ),
                          Text(
                            "Scan & Pay to Doctor",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal! * 1,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        Get.to(() => MyPaymentsPatient(patientIDP!));
                      },
                      child: Column(
                        children: [
                          Image(
                            fit: BoxFit.contain,
                            width: SizeConfig.blockSizeHorizontal! * 10,
                            height: SizeConfig.blockSizeVertical! * 10,
                            //height: 80,
                            image: AssetImage("images/ic_my_payments.png"),
                          ),
                          Text(
                            "My Payments",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        //...top circlular image part,
        /*Positioned(
        left: Consts.padding,
        right: Consts.padding,
        child: CircleAvatar(
          backgroundColor: Colors.deepOrangeAccent,
          radius: Consts.avatarRadius,
          child: image,
        ),
      ),*/
      ],
    );
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
    if (bottomNavBarIndex == 0) {
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
    } else
      setState(() {
        bottomNavBarIndex = 0;
      });
    //}
  }

  // showImagePopUp(BuildContext context, String imgUrl) {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) => PopUpDialogWithImage(
  //       imgUrl: imgUrl,
  //     ),
  //   );
  // }

  void getDashboardData() async {
    mobNo = await getMobNo();
    setState(() {
      isLoading = true;
    });
    String loginUrl = "${baseURL}patientDasboard.php";
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
      String imgUrl = "${baseImagePath}images/popupimage/" + jsonData['PopupImage'];
      final jsonVideos = jsonData['Videos'];
      //final jsonVideos = json.decode(videos);

      for (var i = 0; i < jsonVideos.length; i++) {
        var jsonVideoObj = jsonVideos[i];
        listHealthVideos.add(IconModel(
            jsonVideoObj["VideoTitle"],
            "https://img.youtube.com/vi/${jsonVideoObj["VideoID"].toString()}/hqdefault.jpg",
            jsonVideoObj["VideoURL"],
            jsonVideoObj["VideoDescription"]));
      }

      listPhotos = [];
      listSliderImagesWebViewOuter = [];
      listSliderImagesWebViewTitleOuter = [];
      final jsonArrayMainSlider = jsonData['MainSlider'];
      for (var i = 0; i < jsonArrayMainSlider.length; i++) {
        var jsonIconObj = jsonArrayMainSlider[i];
        listPhotos.add("${baseImagePath}" + jsonIconObj['Path']);
        listSliderImagesWebViewOuter.add(jsonIconObj['Webview']);
        listSliderImagesWebViewTitleOuter.add(jsonIconObj["Title"]);
      }
      // String oldPopUpIDP = await getPopUpIDP();
      // String newPopUpIDP = jsonData['PopupIDP'];
      // if (oldPopUpIDP != newPopUpIDP) {
      //   Future.delayed(Duration.zero, () {
      //     showImagePopUp(context, imgUrl);
      //   });
      // }
      fullName = await getUserName();
      email = await getEmail();
      setPopUpIDP(jsonData['PopupIDP']);
      isLoading = false;
      setState(() {});
      /* var patientIDP = jsonData[0]['PatientIDP'];
      var patientUniqueKey = decodeBase64(jsonData[0]['PatientUniqueKey']);
      setMobNo(mobNo);
      setPatientIDP(patientIDP);
      setPatientUniqueKey(patientUniqueKey);
      setUserType("patient");
      Navigator.push(mContext,
          MaterialPageRoute(builder: (context) => PatientDashboardScreen()));*/
    } else if ((model.status == "LOGOUT")) {
      logOut(context);
      Navigator.pop(context);
      Get.to(() => LandingScreen());
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
                      SizeConfig.blockSizeHorizontal! * 3,
                    ),
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal! * 6.2,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 6,
                        ),
                        Text(
                          "Choose Action",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal! * 4.8,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                      onTap: () async {
                        Navigator.of(context).pop();
                        await FlutterPhoneDirectCaller.callNumber(
                            emergencyNumber);
                      },
                      child: Container(
                          width: SizeConfig.blockSizeHorizontal! * 90,
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
                          width: SizeConfig.blockSizeHorizontal! * 90,
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
        "patient" +
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
      headers: {
        "u": patientUniqueKey,
        "type": userType,
      },
      body: {"getjson": encodedJSONStr},
    );
    debugPrint(response.body.toString());
    //final jsonResponse = json.decode(response.body.toString());
    //ResponseModel model = ResponseModel.fromJSON(jsonResponse);
  }

  void _sendSMS(String message, List<String> recipents) async {
    /* String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    //launchURL("tel://918000083323");
    print(_result);*/
    print('_sendSMS');
    print(message);
    print(recipents);
    SmsStatus result = await BackgroundSms.sendMessage(
        phoneNumber: recipents[0], message: message);
    if (result == SmsStatus.sent) {
      print("Sent");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Message $message sent to $recipents"),
      ));
    } else {
      print("Failed");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Message failed.Try after some time."),
      ));
    }
  }

  Widget _createListView(BuildContext mContext) {
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
    return ColoredBox(
      color: Color(0xfff9faff),
      child: ListView(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Container(
              color: colorWhite,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
                  vertical: SizeConfig.blockSizeHorizontal! * 3.0,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text("Unique ID-$patientID",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: SizeConfig.blockSizeHorizontal! * 3.6,
                            letterSpacing: 1.2,
                          )),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: showEnglish
                            ? Text("Silver Touch",
                                key: UniqueKey(),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal! * 5.3,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w700,
                                ))
                            : Text("LokLF;lsrq",
                                key: UniqueKey(),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal! * 5.3,
                                  letterSpacing: 2.5,
                                  fontFamily: "KrutiDev",
                                  fontWeight: FontWeight.w500,
                                )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical! * 2,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
              ),
              child: new RichText(
                text: new TextSpan(
                    text: 'Welcome ',
                    style: TextStyle(
                        color: Colorsblack,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                    children: [
                      new TextSpan(
                          text: userNameGlobal,
                          style: TextStyle(
                              color: Colorsblack, fontWeight: FontWeight.bold))
                    ]),
              ),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical! * 2,
            ),
            // Padding(
            //   padding: EdgeInsets.symmetric(
            //     horizontal: SizeConfig.blockSizeHorizontal * 3.0,
            //   ),
            //   child: Container(
            //     alignment: Alignment.center,
            //     width: double.infinity,
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(10),
            //       //border corner radius
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.grey.withOpacity(0.2), //color of shadow
            //           spreadRadius: 3, //spread radius
            //           blurRadius: 7, // blur radius
            //           offset: Offset(0, 1), // changes position of shadow
            //         ),
            //         //you can set more BoxShadow() here
            //       ],
            //     ),
            // child: TextField(
            //   decoration: const InputDecoration(
            //       contentPadding: EdgeInsets.all(15),
            //       border: InputBorder.none,
            //       hintText: 'Search',
            //       hintStyle: TextStyle(fontSize: 20),
            //       suffixIcon: Icon(
            //         Icons.search,
            //         color: Color(0xFF70a5db),
            //       )),
            // ),
            //   ),
            // ),

            /* SizedBox(
              height: SizeConfig.blockSizeVertical * 2,
            ),
            InkWell(
              onTap: () {
                Get.to(() => DoctorsListScreen(patientIDP));
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 3.0,
                ),
                child: Card(
                  elevation: 0,
                  shadowColor: Colors.grey,
                  color: colorBlueDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(
                              10.0) //                 <--- border radius here
                          ),
                      side: BorderSide(color: colorBlueDark, width: 1.5)),
                  child: Padding(
                    padding: EdgeInsets.all(
                      SizeConfig.blockSizeHorizontal * 3.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "images/v-2-icn-doctor-nav-act.png",
                          width: SizeConfig.blockSizeHorizontal * 8.0,
                          color: colorWhite,
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 4.0,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Connect to",
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 4.2,
                                    fontWeight: FontWeight.w400,
                                    color: colorWhite),
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical * 0.4,
                              ),
                              Text(
                                "My Doctors",
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 4.2,
                                    fontWeight: FontWeight.w700,
                                    color: colorWhite),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(
              height: SizeConfig.blockSizeVertical * 1,
            ),
            InkWell(
              onTap: () async {
                String name = await getUserName();
                String emergencyNumber = await getEmergencyNumber();
                if (emergencyNumber != "") {
                  await _handlePermission(Permission.sms);
                  showCallOrSmsSelectionDialog(context, emergencyNumber, name);
                } else
                  showEmergencyNumberDialog();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 3.0,
                ),
                child: Card(
                  elevation: 0,
                  shadowColor: Colors.grey,
                  color: red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(
                              10.0) //                 <--- border radius here
                          ),
                      side: BorderSide(color: red, width: 1.5)),
                  child: Padding(
                    padding: EdgeInsets.all(
                      SizeConfig.blockSizeHorizontal * 3.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "images/v-2-icn-emergency.png",
                          width: SizeConfig.blockSizeHorizontal * 9.0,
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 4.0,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ask for ",
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 4.2,
                                    fontWeight: FontWeight.w400,
                                    color: colorWhite),
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical * 0.4,
                              ),
                              Text(
                                "Emergency",
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 4.2,
                                    fontWeight: FontWeight.w700,
                                    color: colorWhite),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),*/

            // SizedBox(
            //   height: SizeConfig.blockSizeVertical * 2,
            // ),
            // Padding(
            //   padding: EdgeInsets.symmetric(
            //     horizontal: SizeConfig.blockSizeHorizontal * 3.0,
            //   ),
            //   child: Row(
            //     children: [
            // Expanded(
            //   child: InkWell(
            //     onTap: () {
            //       Get.to(() => AppointmentDoctorsListScreen(patientIDP));
            //     },
            //     child: Card(
            //       elevation: 0,
            //       shadowColor: Colors.grey,
            //       color: colorBlueDark,
            //       shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(
            //                   10.0) //                 <--- border radius here
            //               ),
            //           side: BorderSide(color: colorBlueDark, width: 1.5)),
            //       child: Padding(
            //         padding: EdgeInsets.all(
            //           SizeConfig.blockSizeHorizontal * 3.0,
            //         ),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.start,
            //           children: [
            //             Image.asset(
            //               "images/ic_ask_for_appointment_filled.png",
            //               width: SizeConfig.blockSizeHorizontal * 9.0,
            //             ),
            //             SizedBox(
            //               width: SizeConfig.blockSizeHorizontal * 2.0,
            //             ),
            //             Expanded(
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Text(
            //                     "Ask for",
            //                     style: TextStyle(
            //                         fontSize:
            //                             SizeConfig.blockSizeHorizontal *
            //                                 4.2,
            //                         fontWeight: FontWeight.w400,
            //                         color: colorWhite),
            //                   ),
            //                   SizedBox(
            //                     height:
            //                         SizeConfig.blockSizeVertical * 0.4,
            //                   ),
            //                   Text(
            //                     "Appointment",
            //                     style: TextStyle(
            //                         fontSize:
            //                             SizeConfig.blockSizeHorizontal *
            //                                 4.2,
            //                         fontWeight: FontWeight.w700,
            //                         color: colorWhite),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // Expanded(
            //   child: InkWell(
            //     onTap: () {
            //       Get.to(() => MyChats(patientIDP));
            //     },
            //     child: Card(
            //       elevation: 0,
            //       shadowColor: Colors.grey,
            //       color: colorBlueDark,
            //       shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(
            //                   10.0) //                 <--- border radius here
            //               ),
            //           side: BorderSide(color: colorBlueDark, width: 1.5)),
            //       child: Padding(
            //         padding: EdgeInsets.all(
            //           SizeConfig.blockSizeHorizontal * 3.0,
            //         ),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.start,
            //           children: [
            //             Image(
            //               image: AssetImage(
            //                 "images/ic_ask_to_doctor_filled.png",
            //               ),
            //               height: SizeConfig.blockSizeHorizontal * 9,
            //               width: SizeConfig.blockSizeHorizontal * 9,
            //             ),
            //             SizedBox(
            //               width: SizeConfig.blockSizeHorizontal * 2.0,
            //             ),
            //             Expanded(
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Text(
            //                     "Ask to",
            //                     style: TextStyle(
            //                         fontSize:
            //                             SizeConfig.blockSizeHorizontal *
            //                                 4.2,
            //                         fontWeight: FontWeight.w400,
            //                         color: colorWhite),
            //                   ),
            //                   SizedBox(
            //                     height:
            //                         SizeConfig.blockSizeVertical * 0.4,
            //                   ),
            //                   Text(
            //                     "Doctor",
            //                     style: TextStyle(
            //                         fontSize:
            //                             SizeConfig.blockSizeHorizontal *
            //                                 4.2,
            //                         fontWeight: FontWeight.w700,
            //                         color: colorWhite),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            //     ],
            //   ),
            // ),
            SizedBox(
              height: SizeConfig.blockSizeVertical! * 1,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.to(
                              () => DoctorsListScreen(patientIDP!, false, "2"));
                        },
                        child: Card(
                          elevation: 0,
                          shadowColor: Colors.grey,
                          color: colorBlueDark,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(
                                      10.0) //                 <--- border radius here
                                  ),
                              side:
                                  BorderSide(color: colorBlueDark, width: 1.5)),
                          child: Padding(
                            padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal! * 3.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "images/v-2-icn-doctor-nav-act.png",
                                  width: SizeConfig.blockSizeHorizontal! * 6.0,
                                ),
                                SizedBox(
                                  width: SizeConfig.blockSizeHorizontal! * 2.0,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Connect",
                                        style: TextStyle(
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.2,
                                            fontWeight: FontWeight.w700,
                                            color: colorWhite),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeVertical! * 0.4,
                                      ),
                                      Text(
                                        "Doctors",
                                        style: TextStyle(
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.2,
                                            fontWeight: FontWeight.w700,
                                            color: colorWhite),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          String name = await getUserName();
                          String emergencyNumber = await getEmergencyNumber();
                          if (emergencyNumber != "") {
                            await _handlePermission(Permission.sms);
                            showCallOrSmsSelectionDialog(
                                context, emergencyNumber, name);
                          } else
                            showEmergencyNumberDialog();
                        },
                        child: Card(
                          elevation: 0,
                          shadowColor: Colors.grey,
                          color: red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(
                                      10.0) //                 <--- border radius here
                                  ),
                              side: BorderSide(color: red, width: 1.5)),
                          child: Padding(
                            padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal! * 3.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage(
                                    "images/v-2-icn-emergency.png",
                                  ),
                                  height: SizeConfig.blockSizeHorizontal! * 9,
                                  width: SizeConfig.blockSizeHorizontal! * 9,
                                ),
                                SizedBox(
                                  width: SizeConfig.blockSizeHorizontal! * 2.0,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text(
                                          "Emergency",
                                          style: TextStyle(
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  4.2,
                                              fontWeight: FontWeight.w700,
                                              color: colorWhite),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: SizeConfig.blockSizeVertical! * 2.0,
            ),
            Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
                  vertical: SizeConfig.blockSizeHorizontal! * 3.0,
                ),
                decoration: BoxDecoration(
                  color: Color(0xfff0f1f5),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(
                      30,
                    ),
                    topLeft: Radius.circular(
                      30,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    //Health Video
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockSizeHorizontal! * 3),
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "What do you need?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: SizeConfig.blockSizeHorizontal! * 5,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Get.to(() => AllModules());
                                    },
                                    child: Text(
                                      "See All",
                                      style: TextStyle(
                                          color: colorBlueDark,
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal! *
                                                  4.0,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        SizeConfig.blockSizeHorizontal! * 2.0,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 1.0,
                    ),
                    Center(
                      child: GridView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: listIcons.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 1.0, crossAxisCount: 3),
                          itemBuilder: (context, index) {
                            return IconCard(listIcons[
                                index]) /*IconModel(listIconName[index], listImage[index], "")*/;
                            /*);*/
                          }),
                    ),
                  ],
                )),

            SizedBox(
              height: SizeConfig.blockSizeVertical! * 1,
            ),
            // Padding(
            //   padding: EdgeInsets.symmetric(
            //     horizontal: SizeConfig.blockSizeHorizontal * 3.0,
            //   ),
            //   child: Text(
            //     "Poster",
            //     style: TextStyle(
            //       color: Colors.black,
            //       fontWeight: FontWeight.w700,
            //       fontSize: SizeConfig.blockSizeHorizontal * 5,
            //     ),
            //   ),
            // ),
            // SizedBox(
            //   height: SizeConfig.blockSizeVertical * 1,
            // ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
              ),
              child: Center(
                child: listPhotos.length > 0
                    ? Container(
                        height: SizeConfig.blockSizeVertical! * 25,
                        width: SizeConfig.blockSizeHorizontal! * 98.0,
                        child: AutomaticPageView2(
                            listPhotos,
                            listSliderImagesWebViewOuter,
                            listSliderImagesWebViewTitleOuter),
                      )
                    : Container(
                        height: SizeConfig.blockSizeVertical! * 25,
                        width: SizeConfig.blockSizeHorizontal! * 98.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/shimmer_effect.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
              ),
            ),

            SizedBox(
              height: SizeConfig.blockSizeVertical! * 1,
            ),

            //Health Video
            Padding(
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 3),
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Health Videos",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: SizeConfig.blockSizeHorizontal! * 5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              Get.to(() => AllVideosScreen());
                            },
                            child: Text(
                              "See All",
                              style: TextStyle(
                                color: colorBlueDark,
                                fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal! * 2.0,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
              ),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: listHealthVideos.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        debugPrint("vid play");
                        Get.to(
                          () => VideoPlayerScreen(
                              listHealthVideos[index].webView!,
                              listHealthVideos[index].iconName!,
                              listHealthVideos[index].description!),
                          transition: Transition.downToUp,
                        );
                      },
                      child: Column(
                        children: <Widget>[
                          Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              CachedNetworkImage(
                                placeholder: (context, url) => Image(
                                  width: SizeConfig.blockSizeHorizontal! * 92,
                                  height: SizeConfig.blockSizeVertical! * 32,
                                  image:
                                      AssetImage('images/shimmer_effect.png'),
                                  fit: BoxFit.contain,
                                ),
                                imageUrl: listHealthVideos[index].image!,
                                fit: BoxFit.fitWidth,
                                width: SizeConfig.blockSizeHorizontal! * 95,
                                height: SizeConfig.blockSizeVertical! * 33,
                              ),
                              /*Image(
                                        width:
                                            SizeConfig.blockSizeHorizontal * 90,
                                        height:
                                            SizeConfig.blockSizeVertical * 28,
                                        fit: BoxFit.fill,
                                        image: NetworkImage(
                                            listHealthVideos[index].image),
                                      ),*/
                              Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.green,
                                  size: SizeConfig.blockSizeHorizontal! * 30,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical! * 1,
                          ),
                          Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: SizeConfig.blockSizeHorizontal! * 2,
                                    right: SizeConfig.blockSizeHorizontal! * 2),
                                child: Text(
                                  listHealthVideos[index].iconName!,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 4.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )),
                          /*SizedBox(
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
                                                  )),*/
                          SizedBox(
                            height: SizeConfig.blockSizeVertical! * 3,
                          ),
                        ],
                      ),
                    );
                  }),
            ),
            Center(
              child: Visibility(
                visible: isLoading,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            ),
          ]),
    );
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
                  Get.to(() => ViewProfileDetails());
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
        print("MyAppdata:$updateInfo");
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

  void getExpiryDetails() async {
    String loginUrl = "${baseURL}patientExpiryCheck.php";
    /*ProgressDialog pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr.show();
    });*/
    //listIcon = new List();
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
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      /*final jsonData = json.decode(strData);*/
    } else if (model.status == "EXPIRE") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  YourAccountValidityExpiredScreen(ExpiryState.Expired)),
          (Route<dynamic> route) => false);
    } else if (model.status == "PAYMENT") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  YourAccountValidityExpiredScreen(ExpiryState.NotPaid)),
          (Route<dynamic> route) => false);
    }
  }

  void switchProfile(BuildContext mContext) async {
    await Get.to(SelectProfileScreen(json: userData))!.then((index) {
      generateSelectedProfile(mContext, userData[index]);
    });
  }

  getBackgroundImage() {
    (imgUrl != "" && imgUrl != "null")
        ? NetworkImage("$userImgUrl$imgUrl")
        : AssetImage("images/ic_user_placeholder.png");
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
      padding: EdgeInsets.all(10),
      indicatorColor: Colors.white,
      indicatorSelectorColor: colorBlueDark,
      shape: IndicatorShape.circle(size: 8),
    );
  }
}

// commented by ashwini for library issues - flutter_webview_plugin
goToWebview(BuildContext context, String iconName, String webView) {
  if (webView != "") {
    print('webView $webView');
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WebViewContainer(webView)));
    // final flutterWebViewPlugin = FlutterWebviewPlugin();
    // flutterWebViewPlugin.onDestroy.listen((_) {
    //   if (Navigator.canPop(context)) {
    //     Navigator.of(context).pop();
    //   }
    // });
    // Navigator.push(context, MaterialPageRoute(builder: (mContext) {
    //   return new MaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     theme: ThemeData(fontFamily: "Ubuntu", primaryColor: Color(0xFF06A759)),
    //     routes: {
    //       "/": (_) => new WebviewScaffold(
    //             withLocalStorage: true,
    //             withJavascript: true,
    //             url: webView,
    //             appBar: new AppBar(
    //               backgroundColor: Color(0xFFFFFFFF),
    //               title: new Text(iconName),
    //               leading: new IconButton(
    //                   icon: new Icon(Icons.arrow_back_ios, color: colorBlack),
    //                   onPressed: () => {
    //                         Navigator.of(context).pop(),
    //                       }),
    //               iconTheme: IconThemeData(
    //                   color: colorBlack,
    //                   size: SizeConfig.blockSizeVertical * 2.2), toolbarTextStyle: TextTheme(
    //                   subtitle1: TextStyle(
    //                       color: colorBlack,
    //                       fontFamily: "Ubuntu",
    //                       fontSize: SizeConfig.blockSizeVertical * 2.3)).bodyText2, titleTextStyle: TextTheme(
    //                   subtitle1: TextStyle(
    //                       color: colorBlack,
    //                       fontFamily: "Ubuntu",
    //                       fontSize: SizeConfig.blockSizeVertical * 2.3)).headline6,
    //             ),
    //           ),
    //     },
    //   );
    // }));
  }
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
              height: SizeConfig.blockSizeVertical! * 28,
            ),
            height: SizeConfig.blockSizeVertical! * 28,
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
  ModelIcon? model;

  IconCard(ModelIcon model) {
    this.model = model;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return InkWell(
      highlightColor: Colors.green[200],
      customBorder: CircleBorder(),
      onTap: () async {
        String patientIDP = await getPatientOrDoctorIDP();
        if (model!.iconName == "Consultation") {
          Get.to(() => AllConsultation());
        } else if (model!.iconName == "Order\nMedicine") {
          Get.to(() => OrderMedicineListScreen(patientIDP));
        } else if (model!.iconName == "Order\nBlood Test") {
          Get.to(() => OrderBloodListScreen(patientIDP));
        } else if (model!.iconName == "Blood\nPressure") {
          Get.to(() => VitalsCombineListScreen(patientIDP, "1"));
        } else if (model!.iconName == "Blood\nSugar") {
          Get.to(() => InvestigationsListWithGraph(
                patientIDP,
                from: "sugar",
              ));
        } else if (model!.iconName == "Vitals") {
          Get.to(() => VitalsListScreen(patientIDP, "2"));
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal! * 0.0),
        child: Card(
          color: colorWhite,
          elevation: 2.0,
          //shadowColor: model.iconColor,
          margin: EdgeInsets.all(
            SizeConfig.blockSizeHorizontal! * 2.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              SizeConfig.blockSizeHorizontal! * 2.0,
            ),
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: SizeConfig.blockSizeHorizontal! * 15,
                  height: SizeConfig.blockSizeHorizontal! * 15,
                  child: Padding(
                    padding: EdgeInsets.all(
                      SizeConfig.blockSizeHorizontal! * 3.0,
                    ),
                    child: model!.iconType == "image"
                        ? Image(
                            width: SizeConfig.blockSizeHorizontal! * 5,
                            height: SizeConfig.blockSizeHorizontal! * 5,
                            image: AssetImage(
                              'images/${model!.iconImg}',
                            ),
                          )
                        : model!.iconType == "faIcon"
                            ? FaIcon(
                                model!.iconData,
                                size: SizeConfig.blockSizeHorizontal! * 5,
                                color: Color(0xFF06A759),
                              )
                            : Container(
                                width: SizeConfig.blockSizeHorizontal! * 5,
                                height: SizeConfig.blockSizeHorizontal! * 5,
                              ),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical! * 0,
                ),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(model!.iconName!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: SizeConfig.blockSizeHorizontal! * 3.2,
                        letterSpacing: 1.2,
                      )),
                ),
              ]),
        ),
      ),
    ) /*)*/;
  }

  // void showLanguageSelectionDialog(BuildContext context, String patientIDP) {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => Dialog(
  //             /*shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(16),
  //             ),*/
  //             backgroundColor: Colors.white,
  //             child: ListView(
  //               shrinkWrap: true,
  //               children: <Widget>[
  //                 Padding(
  //                   padding: EdgeInsets.all(
  //                     SizeConfig.blockSizeHorizontal * 3,
  //                   ),
  //                   child: Row(
  //                     children: <Widget>[
  //                       InkWell(
  //                         child: Icon(
  //                           Icons.arrow_back,
  //                           color: Colors.red,
  //                           size: SizeConfig.blockSizeHorizontal * 6.2,
  //                         ),
  //                         onTap: () {
  //                           Navigator.of(context).pop();
  //                         },
  //                       ),
  //                       SizedBox(
  //                         width: SizeConfig.blockSizeHorizontal * 6,
  //                       ),
  //                       Text(
  //                         "Choose Language",
  //                         textAlign: TextAlign.center,
  //                         style: TextStyle(
  //                           fontSize: SizeConfig.blockSizeHorizontal * 4.8,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.green,
  //                           decoration: TextDecoration.none,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 InkWell(
  //                     onTap: () {
  //                       Navigator.of(context).pop();
  //                       Get.to(
  //                           () => CoronaQuestionnaireScreen(patientIDP, "eng"));
  //                     },
  //                     child: Container(
  //                         width: SizeConfig.blockSizeHorizontal * 90,
  //                         padding: EdgeInsets.only(
  //                           top: 5,
  //                           bottom: 5,
  //                           left: 5,
  //                           right: 5,
  //                         ),
  //                         decoration: new BoxDecoration(
  //                           color: Colors.white,
  //                           shape: BoxShape.rectangle,
  //                           border: Border(
  //                             bottom:
  //                                 BorderSide(width: 2.0, color: Colors.grey),
  //                           ),
  //                           boxShadow: [
  //                             BoxShadow(
  //                               color: Colors.black26,
  //                               blurRadius: 10.0,
  //                               offset: const Offset(0.0, 10.0),
  //                             ),
  //                           ],
  //                         ),
  //                         child: Padding(
  //                           padding: EdgeInsets.all(8.0),
  //                           child: Text(
  //                             "English",
  //                             textAlign: TextAlign.left,
  //                             style: TextStyle(
  //                               fontSize: 15,
  //                               color: Colors.black,
  //                               decoration: TextDecoration.none,
  //                             ),
  //                           ),
  //                         ))),
  //                 InkWell(
  //                     onTap: () {
  //                       Navigator.of(context).pop();
  //                       Get.to(
  //                           () => CoronaQuestionnaireScreen(patientIDP, "guj"));
  //                     },
  //                     child: Container(
  //                         width: SizeConfig.blockSizeHorizontal * 90,
  //                         padding: EdgeInsets.only(
  //                           top: 5,
  //                           bottom: 5,
  //                           left: 5,
  //                           right: 5,
  //                         ),
  //                         decoration: new BoxDecoration(
  //                           color: Colors.white,
  //                           shape: BoxShape.rectangle,
  //                           border: Border(
  //                             bottom:
  //                                 BorderSide(width: 2.0, color: Colors.grey),
  //                           ),
  //                           boxShadow: [
  //                             BoxShadow(
  //                               color: Colors.black26,
  //                               blurRadius: 10.0,
  //                               offset: const Offset(0.0, 10.0),
  //                             ),
  //                           ],
  //                         ),
  //                         child: Padding(
  //                           padding: EdgeInsets.all(8.0),
  //                           child: Text(
  //                             "Gujarati",
  //                             textAlign: TextAlign.left,
  //                             style: TextStyle(
  //                               fontSize: 15,
  //                               color: Colors.black,
  //                               decoration: TextDecoration.none,
  //                             ),
  //                           ),
  //                         ))),
  //               ],
  //             ),
  //           ));
  // }
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
        imageUrl: getShimmerEffect(widget.photos, _pos),
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

getShimmerEffect(List<String> photos, int _pos) {
  photos.length > 0
      ? "${photos[_pos]}"
      : AssetImage('images/shimmer_effect.png');
}
