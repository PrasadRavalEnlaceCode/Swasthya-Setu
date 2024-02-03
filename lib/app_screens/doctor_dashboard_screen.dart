import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:background_sms/background_sms.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:page_indicator/page_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swasthyasetu/api/api_helper.dart';
import 'package:swasthyasetu/app_screens/Complaint_master_list_screen.dart';
import 'package:swasthyasetu/app_screens/add_edit_complaints_masters.dart';
import 'package:swasthyasetu/app_screens/add_patient_screen.dart';
import 'package:swasthyasetu/app_screens/change_password_doctor_screen.dart';
import 'package:swasthyasetu/app_screens/dashboard_doctor.dart';
import 'package:swasthyasetu/app_screens/diagnosis_master_list_screen.dart';
import 'package:swasthyasetu/app_screens/doctor_health_videos.dart';
import 'package:swasthyasetu/app_screens/doctor_investigation_list.dart';
import 'package:swasthyasetu/app_screens/drugs_list_screen.dart';
import 'package:swasthyasetu/app_screens/examination_masters_list_screen.dart';
import 'package:swasthyasetu/app_screens/form_3c_screen.dart';
import 'package:swasthyasetu/app_screens/help_screen.dart';
import 'package:swasthyasetu/app_screens/invite_patient_screen.dart';
import 'package:swasthyasetu/app_screens/ipd/indoor_list.dart';
import 'package:swasthyasetu/app_screens/ipd/pmr_screen.dart';
import 'package:swasthyasetu/app_screens/ipd/vital_chart_add_screen.dart';
import 'package:swasthyasetu/app_screens/market_place_screen.dart';
import 'package:swasthyasetu/app_screens/masters_list_screen.dart';
import 'package:swasthyasetu/app_screens/my_chats_patient.dart';
import 'package:swasthyasetu/app_screens/my_invoices.dart';
import 'package:swasthyasetu/app_screens/my_patients_screen.dart';
import 'package:swasthyasetu/app_screens/my_payment_code_screen.dart';
import 'package:swasthyasetu/app_screens/notification_list_screen.dart';
import 'package:swasthyasetu/app_screens/nurse_doc_screen.dart';
import 'package:swasthyasetu/app_screens/opd_registration_screen.dart';
import 'package:swasthyasetu/app_screens/opd_services_list_screen.dart';
import 'package:swasthyasetu/app_screens/patient_resources_screen.dart';
import 'package:swasthyasetu/app_screens/popup_dialog_image.dart';
import 'package:swasthyasetu/app_screens/switch_organization.dart';
import 'package:swasthyasetu/app_screens/switch_role_screen.dart';
import 'package:swasthyasetu/app_screens/view_profile_details_doctor.dart';
import 'package:swasthyasetu/app_screens/view_profile_details_patient.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/main.dart';
import 'package:swasthyasetu/podo/model_investigation_master_list.dart';
import 'package:swasthyasetu/podo/response_login_icons_model.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/services/navigation_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../podo/model_drawer.dart';
import '../utils/color.dart';
import 'add_patient_screen_doctor.dart';
import 'camp_screen.dart';
import 'corona_questionnaire.dart';
import 'custom_dialog.dart';
import 'doctor_library_screen.dart';
import 'lab_reports.dart';
import 'landing_screen.dart';
import 'market_place_dashboard.dart';
import 'select_patients_for_share_video.dart';

var usernameHome, passwordHome, typeHome;
List<String> listSliderImagesWebViewOuter = [];
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
    organizationNameGlobal = "",
    patientID = "",
    businessName = "";
String? patientIDP;

bool shouldExit = false;
String mobNo = "" ;
String roleName = "";
String OPDRoleStatus ="" ,
    IPDRoleStatus = "",
    AccountsRoleStatus= "",
    ReportsRoleStatus= "",
    DashboardRoleStatus= "";

String payGatewayURL = "";

List<String> listMasters = [];
List<String> listAddMasters = [];

/*
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
*/
/*FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();*/

// ignore: must_be_immutable
class DoctorDashboardScreen extends StatefulWidget {

  final String? selectedOrganizationName;
  final String? selectedOrganizationIDF;

  DoctorDashboardScreen({this.selectedOrganizationName,
    this.selectedOrganizationIDF});

  logOut(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }

  @override
  State<StatefulWidget> createState() {
    return PatientDashboardState();
  }
}

class PatientDashboardState extends State<DoctorDashboardScreen>
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
  List<String> listOfRoles = [];

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
  late String selectedOrganizationName;
  late String selectedOrganizationIDF;
  // String? organizationName;
  // String? organizationIDF;
  //
  // @override
  // void didUpdateWidget(covariant DoctorDashboardScreen oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //
  //   // Check if the data has changed before updating the state
  //   if (widget.selectedOrganizationName != organizationName ||
  //       widget.selectedOrganizationIDF != organizationIDF) {
  //     setState(() {
  //       organizationName = widget.selectedOrganizationName;
  //       organizationIDF = widget.selectedOrganizationIDF;
  //     });
  //   }
  // }

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
      businessName = jsonData[0]['BusinessName'];
      userNameGlobal =
          businessName != "" ? businessName.trim() : "Complete your profile";
      mobNo = jsonData[0]['MobileNo'] != "" ? jsonData[0]['MobileNo'] : "-";
      roleName = jsonData[0]['RoleName'] != "" ? jsonData[0]['RoleName']: "-";
      doctorSuffix = jsonData[0]['DoctorSuffix'];
      couponCode = jsonData[0]['CouponCode'];
      downloadURL = jsonData[0]['DownloadURL'];
      OPDRoleStatus = jsonData[0]['OPDRoleStatus'] != "" ? jsonData[0]['OPDRoleStatus']: "-";
      IPDRoleStatus = jsonData[0]['IPDRoleStatus'] != "" ? jsonData[0]['IPDRoleStatus']: "-";
      AccountsRoleStatus = jsonData[0]['AccountsRoleStatus'] != "" ? jsonData[0]['AccountsRoleStatus']: "-";
      ReportsRoleStatus = jsonData[0]['ReportsRoleStatus'] != "" ? jsonData[0]['ReportsRoleStatus']: "-";
      DashboardRoleStatus = jsonData[0]['DashboardRoleStatus'] != "" ? jsonData[0]['DashboardRoleStatus']: "-";

      setUserName(userNameGlobal);
      //setEmergencyNumber(jsonData[0]['EmergencyNumber']);
      debugPrint("Img url - $imgUrl");
      debugPrint("IPD Role -------------------------------------------------------- $IPDRoleStatus");

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
    super.initState();

    selectedOrganizationName = widget.selectedOrganizationName ?? "Swashtya Setu";
    selectedOrganizationIDF = widget.selectedOrganizationIDF ?? "1";

    listMasters = [];
    listMasters.add("Drug Frequency Master");
    listMasters.add("Drug Timing Master");
    listMasters.add("Drug Master");
    listAddMasters = [];
    listAddMasters.add("Add Complaint Masters");
    listAddMasters.add("Add Examination Masters");
    listAddMasters.add("Add Diagnosis Masters");
    navigationService = getItLocator<NavigationService>();
    bottomNavBarIndex = 0;
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

    // if (roleName == "frontoffice") {

      listIconName.add("Add\nNew Patient");
      listIconName.add("My\nPatients");
      listIconName.add("My\nAppointments");
      listIconName.add("Send\nNotifications");
      listIconName.add("My\nLibrary");
      listIconName.add("Market\nPlace");
      listIconName.add("Patient\nResources");
      listIconName.add("Event\nfor Drs");
      listIconName.add("Investigatin\nList");

      // if(DashboardRoleStatus == "0"){
        listIconName.add("Doctor\nDashboard");
    //   }
    // if(IPDRoleStatus == "0"){
      listIconName.add("IPD");
    // }


      listImage.add("v-2-icn-add-patient.png");
      listImage.add("v-2-icn-my-patient.png");
      listImage.add("v-2-icn-my-appointment.png");
      listImage.add("v-2-icn-sent-notification.png");
      listImage.add("v-2-icn-my-library.png");
      listImage.add("v-2-icn-market-place.png");
      listImage.add("v-2-icn-patient-resourece.png");
      listImage.add("v-2-icn-event-drs.png");
      listImage.add("v-2-icn-investigation.png");
    // if(DashboardRoleStatus == "0"){
      listImage.add("v-2-icn-dashboard.png");
    // }
    // if(IPDRoleStatus == "0"){
      listImage.add("v-2-icn-investigation.png");
    // }


    // }else{
    //   listIconName.add("Add\nNew Patient");
    //   listIconName.add("My\nPatients");
    //   listIconName.add("My\nAppointments");
    //   listIconName.add("Send\nNotifications");
    //   // listIconName.add("My\nLibrary");
    //   // listIconName.add("Market\nPlace");
    //   // listIconName.add("Patient\nResources");
    //   // listIconName.add("Event\nfor Drs");
    //   // listIconName.add("Doctor\nDashboard");
    //   // listIconName.add("Investigatin\nList");
    //   // listIconName.add("IPD");
    //
    //   listImage.add("v-2-icn-add-patient.png");
    //   listImage.add("v-2-icn-my-patient.png");
    //   listImage.add("v-2-icn-my-appointment.png");
    //   listImage.add("v-2-icn-sent-notification.png");
    //   // listImage.add("v-2-icn-my-library.png");
    //   // listImage.add("v-2-icn-market-place.png");
    //   // listImage.add("v-2-icn-patient-resourece.png");
    //   // listImage.add("v-2-icn-event-drs.png");
    //   // listImage.add("v-2-icn-dashboard.png");
    //   // listImage.add("v-2-icn-investigation.png");
    //   // listImage.add("v-2-icn-investigation.png");
    // }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    userNameGlobal = "";
    bottomNavBarIndex = 0;
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

  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  int tappedIndex = -1;
  final List<DrawerModel> liste = [
    DrawerModel(title: "Home", image: "images/v-2-icn-categories-nav.png"),
    // DrawerModel(
    //     title: "Appointment", image: "images/v-2-icn-calender-gray.png"),
    // DrawerModel(
    //     title: "My Patients", image: "images/v-2-icn-my-patient-nav.png"),
    // DrawerModel(
    //     title: "My Consultation",
    //     image: "images/v-2-icn-my-consultation-nav.png"),
    DrawerModel(title: "OPD Registration", image: "images/v-2-icn-opd-nav.png"),
    DrawerModel(title: "Drugs", image: "images/ic_drugs_dashbord.png"),
    DrawerModel(title: "Add Masters", image: "images/v-2-icn-plush.png"),
    DrawerModel(
        title: "Services", image: "images/ic_opd_services_dashboard.png"),
    DrawerModel(title: "Form3c", image: "images/ic_form_3c_dashboard.png"),
    DrawerModel(
        title: "Lab Reports", image: "images/v-2-icn-medical-profile.png"),
    DrawerModel(title: "Camp", image: "images/ic_camp.png"),

    DrawerModel(title: "Help", image: "images/v-2-icn-help.png"),
    DrawerModel(title: "Log Out", image: "images/v-2-icn-logout-nav.png"),
  ];

  openDrawer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (globalKey.currentState!.isDrawerOpen) {
        globalKey.currentState!.openEndDrawer();
      } else {
        globalKey.currentState!.openDrawer();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    var size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: blueThemeColor,
    ));
    return SafeArea(
        child: Scaffold(
            primary: true,
            resizeToAvoidBottomInset: false,
            key: globalKey,
            drawer: Drawer(
              child: Column(
                children: <Widget>[
                  DrawerHeader(
                    child: Container(
                      color: Color(0xfff0f1f5),
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.transparent,
                            child: (imgUrl != "" && imgUrl != "null")
                                ? CircleAvatar(
                                    radius: 28,
                                    backgroundImage:
                                        NetworkImage("$doctorImgUrl$imgUrl"))
                                : CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.grey,
                                    backgroundImage: AssetImage(
                                        "images/ic_user_placeholder.png")),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                "Mobile No - $mobNo",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal! * 3.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xfff0f1f5),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: liste.length,
                      itemBuilder: (_, i) {
                        return Column(
                          children: [
                            i == 11
                                ? Divider(
                                    color: colorgreyText,
                                    height: 0,
                                  )
                                : Container(),
                            ListTile(
                              tileColor: tappedIndex == i ? Colors.blue : null,
                              // If current item is selected show blue color
                              leading: Image.asset(liste[i].image!,
                                  width: SizeConfig.blockSizeHorizontal! * 4.0,
                                  color: tappedIndex == i
                                      ? Colors.white
                                      : Colors.black),
                              // trailing: i == 1 || i == 3
                              //     ? buildNotificationCount(i)
                              //     : null,
                              minLeadingWidth: 10,
                              title: Text(liste[i].title!,
                                  style: TextStyle(
                                      color: tappedIndex == i
                                          ? Colors.white
                                          : Colors.black)),
                              onTap: () {
                                print("Tapped index: $i, Role name: $roleName");
                                setState(() {
                                  tappedIndex = i;
                                });
                                if(i == 0){
                                if (i == 0) {
                                  Navigator.pop(context);
                                  tappedIndex = 0;
                                  getDashboardData();
                                }}
                                // else if (i == 1) {
                                //   Navigator.pop(context);
                                //   Navigator.of(context)
                                //       .push(MaterialPageRoute(builder: (context) {
                                //     return OPDRegistrationScreen();
                                //   })).then((value) {
                                //     getDashboardData();
                                //     tappedIndex = -1;
                                //   });
                                // }
                                // else if (i == 1)
                                // {
                                //   Navigator.pop(context);
                                //   Navigator.of(context)
                                //       .push(MaterialPageRoute(builder: (context) {
                                //     return MyPatientsScreen();
                                //   })).then((value) {
                                //     getDashboardData();
                                //     tappedIndex = -1;
                                //   });
                                // }
                                else if (i == 1) {
                                  if (roleName == "frontoffice") {
                                  Navigator.pop(context);
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return OPDRegistrationScreen();
                                  })).then((value) {
                                    getDashboardData();
                                    tappedIndex = -1;
                                  });
                                }else{
                                    print("Condition not met for index $i and roleName $roleName");
                                    // Add default or alternative behavior here
                                  }
                                }
                                // else if (i == 4)
                                // {
                                //   Navigator.pop(context);
                                //   tappedIndex = -1;
                                // }
                                else if (i == 2) {
                                  Navigator.pop(context);
                                  tappedIndex = -1;
                                  // Navigator.of(context)
                                  //     .push(MaterialPageRoute(builder: (context) {
                                  //   return MarketPlaceScreen(patientIDP: patientIDP);
                                  // })).then((value) {
                                  //   getDashboardData();
                                  // });
                                  // drops
                                  showMasterSelectionDialog(
                                      listMasters, context);
                                } else if (i == 3) {
                                  Navigator.pop(context);
                                  tappedIndex = -1;
                                  showAddMasterSelectionDialog(
                                      listAddMasters, context);
                                  // Navigator.of(context).push(
                                  //     MaterialPageRoute(builder: (context) {
                                  //   return AddMastersScreen();
                                  // })).then((value) {
                                  //   getDashboardData();
                                  //
                                  // });
                                }
                                else if (i == 4) {
                                  Navigator.pop(context);
                                  // services
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return OPDServiceListScreen();
                                  })).then((value) {
                                    getDashboardData();
                                    tappedIndex = -1;
                                  });
                                }
                                else if (i == 5) {
                                  Navigator.pop(context);
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return Form3CScreen();
                                  })).then((value) {
                                    getDashboardData();
                                    tappedIndex = -1;
                                  });
                                  // form3c
                                } else if (i == 6) {
                                  Navigator.pop(context);
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return LabReportsScreen();
                                  })).then((value) {
                                    getDashboardData();
                                    tappedIndex = -1;
                                  });
                                } else if (i == 7) {
                                  Navigator.pop(context);
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return CampScreen();
                                  })).then((value) {
                                    getDashboardData();
                                    tappedIndex = -1;
                                  });
                                } else if (i == 8) {
                                  Navigator.pop(context);
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return HelpScreen(patientIDP!);
                                  })).then((value) {
                                    getDashboardData();
                                    tappedIndex = -1;
                                  });
                                } else if (i == 9) {
                                  Navigator.pop(context);
                                  showConfirmationDialogLogout(
                                    context,
                                  );
                                }
                              }, // Reverse bool value
                            ),
                            i == 8
                                ? Divider(
                                    color: colorgreyText,
                                    height: 0,
                                  )
                                : Container(),
                          ],
                        );
                      },
                    ),
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
                    label: 'My Profile'),
                BottomNavigationBarItem(
                    activeIcon: Image(
                      image: AssetImage(
                        "images/icn-qr-code.png",
                      ),
                      color: colorBlueApp,
                      width: SizeConfig.blockSizeHorizontal! * 6,
                    ),
                    icon: Image(
                      image: AssetImage(
                        "images/icn-qr-code.png",
                      ),
                      color: darkgrey,
                      width: SizeConfig.blockSizeHorizontal! * 6,
                    ),
                    label: 'Payment Code'),
                BottomNavigationBarItem(
                    activeIcon: Image(
                      image: AssetImage(
                        "images/v-2-icn-menu.png",
                      ),
                      width: SizeConfig.blockSizeHorizontal! * 6,
                      color: colorBlueApp,
                    ),
                    icon: Image(
                      image: AssetImage(
                        "images/v-2-icn-menu.png",
                      ),
                      color: darkgrey,
                      width: SizeConfig.blockSizeHorizontal! * 6,
                    ),
                    label: 'Menu'),
              ],
            ),
            body: Builder(
              builder: (mContext) {
                return WillPopScope(
                    onWillPop: () => onBackPressed(mContext),
                    child: bottomNavBarIndex == 0
                        ? _createListView(mContext)
                        : (bottomNavBarIndex == 1
                            ?generalProfileWidget(context)
                    // roleName == "frontoffice"
                    // ?
                        // :nurseGeneralProfileWidget(context)
                            : (bottomNavBarIndex == 2
                                ? selectedOrganizationIDF == "1"
                    ?MyPaymentCodeScreen(
                                    payGatewayURL)
                       : Container(

                    )
                                : Container())));
              },
            )));
  }

  // bool shouldShowExpanded(String roleName) {
  //   // Add your conditions based on roleName for the visibility of Expanded
  //   return roleName != "someCondition";
  // }

  SizedBox generalProfileWidget(BuildContext mContext) {
    return SizedBox(
      height: SizeConfig.blockSizeVertical! * 90,
      width: SizeConfig.blockSizeHorizontal! * 100,
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
            color: Colors.white,
            child: SizedBox(
              height: SizeConfig.blockSizeVertical! * 90,
              width: SizeConfig.blockSizeHorizontal! * 100,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        SizeConfig.blockSizeHorizontal! * 28.0),
                                child: Text(
                                  "Doctor Profile",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 5.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: SizeConfig.blockSizeHorizontal! * 15.0,
                                ),
                                child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return HelpScreen(patientIDP!);
                                      })).then((value) {
                                        getDashboardData();
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          "help",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Image.asset(
                                          "images/v-2-icn-help.png",
                                          // alignment: Alignment.centerRight,
                                          width:
                                              SizeConfig.blockSizeHorizontal! *
                                                  8.0,
                                        ),
                                      ],
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ViewProfileDetailsDoctor();
                          })).then((value) {
                            getDashboardData();
                            getPatientProfileDetails();
                          });
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          child: (imgUrl != "" && imgUrl != "null")
                              ? CircleAvatar(
                                  radius: 48,
                                  backgroundImage: NetworkImage(
                                      "$doctorImgUrl$imgUrl") /*),*/
                                  )
                              : CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: AssetImage(
                                      "images/ic_user_placeholder.png")),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ViewProfileDetailsDoctor();
                          })).then((value) {
                            getDashboardData();
                          });
                        },
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
                      Text(
                        "Mobile No - $mobNo",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: SizeConfig.blockSizeHorizontal! * 3.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.2),
                          thickness: 2,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ChangePasswordDoctorScreen();
                          }));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10),
                          child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      "Change Password",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.chevron_right,
                                                    color: Colors.grey,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ])),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.2),
                          thickness: 2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        child: Container(
                            width: SizeConfig.blockSizeHorizontal! * 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(
                                    "Referral code",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "$patientID",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  3.3,
                                            ),
                                          ),
                                          /*Icon(
                                                            Icons.chevron_right,
                                                            color: Colors.grey,
                                                          )*/
                                        ],
                                      ),
                                    ),
                                  )
                                ])),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.2),
                          thickness: 2,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return SwitchOrganizationScreen();
                          }));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10),
                          child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      "Switch OrganizationScreen",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.chevron_right,
                                                    color: Colors.grey,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ])),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.2),
                          thickness: 2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        child: InkWell(
                          onTap: (){
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return SwitchRoleScreen();
                            }));
                          },
                          child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      "Switch Role",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: <Widget>[
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.topRight,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    Align(
                                                      alignment: Alignment.topRight,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.chevron_right,
                                                            color: Colors.grey,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ])),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.2),
                          thickness: 2,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return MyInvoiceListScreen();
                          }));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10),
                          child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      "My Invoices",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.chevron_right,
                                                    color: Colors.grey,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ])),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      //   child: Divider(
                      //     color: Colors.grey.withOpacity(0.2),
                      //     thickness: 2,
                      //   ),
                      // ),
                      // InkWell(
                      //   onTap: () {
                      //     if (couponCode != "")
                      //       Share.share(
                      //         'Dr $userNameGlobal has invited you to download swasthyasetu application and apply $couponCode as coupon code on installation.\n\n$downloadURL',
                      //       );
                      //   },
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 20.0, vertical: 10),
                      //     child: Container(
                      //         width: SizeConfig.blockSizeHorizontal! * 100,
                      //         decoration: BoxDecoration(color: Colors.white),
                      //         child: Row(
                      //             mainAxisSize: MainAxisSize.max,
                      //             children: <Widget>[
                      //               Text(
                      //                 "Share My Coupon Code",
                      //                 style: TextStyle(
                      //                   color: Colors.black,
                      //                 ),
                      //               ),
                      //               Expanded(
                      //                 child: Align(
                      //                   alignment: Alignment.topRight,
                      //                   child: Row(
                      //                     mainAxisSize: MainAxisSize.max,
                      //                     mainAxisAlignment:
                      //                         MainAxisAlignment.end,
                      //                     children: <Widget>[
                      //                       Text(
                      //                         "$couponCode",
                      //                         style: TextStyle(
                      //                           color: Colors.grey,
                      //                           fontSize: SizeConfig
                      //                                   .blockSizeHorizontal! *
                      //                               3.3,
                      //                         ),
                      //                       ),
                      //                       SizedBox(
                      //                         width: SizeConfig
                      //                                 .blockSizeHorizontal! *
                      //                             2.0,
                      //                       ),
                      //                       Align(
                      //                         alignment: Alignment.topRight,
                      //                         child: Row(
                      //                           children: <Widget>[
                      //                             Icon(
                      //                               Icons.chevron_right,
                      //                               color: Colors.grey,
                      //                             )
                      //                           ],
                      //                         ),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ),
                      //               )
                      //             ])),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.2),
                          thickness: 2,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Share.share(
                              'View details of Dr $fullName from below link\n\nhttps://swasthyasetu.com/doctor/profile/$doctorSuffix');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10),
                          child: Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text("Share My Profile"),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                    ),
                                  ])),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.2),
                          thickness: 2,
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
          ),
        ],
      ),
    );
  }

  SizedBox nurseGeneralProfileWidget(BuildContext mContext) {
    return SizedBox(
      height: SizeConfig.blockSizeVertical! * 90,
      width: SizeConfig.blockSizeHorizontal! * 100,
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
            color: Colors.white,
            child: SizedBox(
              height: SizeConfig.blockSizeVertical! * 90,
              width: SizeConfig.blockSizeHorizontal! * 100,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                    SizeConfig.blockSizeHorizontal! * 28.0),
                                child: Text(
                                  "Nurse Profile",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize:
                                    SizeConfig.blockSizeHorizontal! * 5.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: SizeConfig.blockSizeHorizontal! * 15.0,
                                ),
                                child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                            return HelpScreen(patientIDP!);
                                          })).then((value) {
                                        getDashboardData();
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          "help",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: SizeConfig
                                                .blockSizeHorizontal! *
                                                4.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Image.asset(
                                          "images/v-2-icn-help.png",
                                          // alignment: Alignment.centerRight,
                                          width:
                                          SizeConfig.blockSizeHorizontal! *
                                              8.0,
                                        ),
                                      ],
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ViewProfileDetailsDoctor();
                          })).then((value) {
                            getDashboardData();
                            getPatientProfileDetails();
                          });
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          child: (imgUrl != "" && imgUrl != "null")
                              ? CircleAvatar(
                              radius: 48,
                              backgroundImage: NetworkImage(
                                  "$doctorImgUrl$imgUrl") /*),*/
                          )
                              : CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.grey,
                              backgroundImage: AssetImage(
                                  "images/ic_user_placeholder.png")),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ViewProfileDetailsDoctor();
                          })).then((value) {
                            getDashboardData();
                          });
                        },
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
                      Text(
                        "Mobile No - $mobNo",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: SizeConfig.blockSizeHorizontal! * 3.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.2),
                          thickness: 2,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ChangePasswordDoctorScreen();
                          }));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10),
                          child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      "Change Password",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.chevron_right,
                                                    color: Colors.grey,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ])),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.2),
                          thickness: 2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        child: InkWell(
                          onTap: (){},
                          child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      "Switch Role",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: <Widget>[
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.topRight,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    Align(
                                                      alignment: Alignment.topRight,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.chevron_right,
                                                            color: Colors.grey,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ])),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.2),
                          thickness: 2,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return SwitchOrganizationScreen();
                          }));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10),
                          child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      "Switch OrganizationScreen",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.chevron_right,
                                                    color: Colors.grey,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ])),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.2),
                          thickness: 2,
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return NurseDocumentScreen();
                          }));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10),
                          child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      "My Documents",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.chevron_right,
                                                    color: Colors.grey,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ])),
                        ),
                      ),

                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      //   child: Divider(
                      //     color: Colors.grey.withOpacity(0.2),
                      //     thickness: 2,
                      //   ),
                      // ),
                      // InkWell(
                      //   onTap: () {
                      //     Share.share(
                      //         'View details of Dr $fullName from below link\n\nhttps://swasthyasetu.com/doctor/profile/$doctorSuffix');
                      //   },
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 20.0, vertical: 10),
                      //     child: Container(
                      //         decoration: BoxDecoration(color: Colors.white),
                      //         child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             children: <Widget>[
                      //               Expanded(
                      //                 child: Text("Share My Profile"),
                      //               ),
                      //               Align(
                      //                 alignment: Alignment.topRight,
                      //                 child: Row(
                      //                   children: <Widget>[
                      //                     Icon(
                      //                       Icons.chevron_right,
                      //                       color: Colors.grey,
                      //                     )
                      //                   ],
                      //                 ),
                      //               ),
                      //             ])),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.2),
                          thickness: 2,
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
          ),
        ],
      ),
    );
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

  Future<void> onTabTapped(int index, BuildContext context) async {
    /*if (index == 1) {
      scanTheQRCodeNow(context);
      index = 0;
    }*/
    setState(() {
      bottomNavBarIndex = index;
    });
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
      fullName = await getUserName();
      email = await getEmail();
      setPopUpIDP(jsonData['PopupIDP']);
      payGatewayURL = jsonData['PayGatewayURL'];
      setState(() {
        notificationCount = jsonData['NotificationCount'];
        messageCount =
        jsonData['ChatCount'] != null ? jsonData['ChatCount'] : "0";
      });
    }
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static const MethodChannel _channel =
      MethodChannel('flutter_phone_direct_caller');

  static Future<bool> callNumber(String number) async {
    return await _channel.invokeMethod(
      'callNumber',
      <String, Object>{
        'number': number,
      },
    );
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
    SmsStatus result = await BackgroundSms.sendMessage(
        phoneNumber: recipents[0], message: message);
    if (result == SmsStatus.sent) {
      print("Sent");
    } else {
      print("Failed");
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
                    Text("SWASTHYA SETU",
                        key: UniqueKey(),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal! * 5.0,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        )),
                    Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  if(selectedOrganizationIDF == "1"){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MyChats(""))).then((value) {
                                    getDashboardData();
                                  });
                                  }else{
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Feature Not Available"),
                                          content: Text("This feature is not available for the selected organization."),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                              child: Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Stack(
                                  children: <Widget>[
                                    Icon(
                                      Icons.chat_bubble,
                                      size: 30.0,
                                      color: Colors.black,
                                    ),
                                    Visibility(
                                        visible:
                                            messageCount != "0" ? true : false,
                                        child: Positioned(
                                          right: 2,
                                          child: new Container(
                                            padding: EdgeInsets.all(1),
                                            decoration: new BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            constraints: BoxConstraints(
                                              minWidth: 15,
                                              minHeight: 15,
                                            ),
                                            child: new Text(
                                              messageCount,
                                              style: new TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 2.5,
                              ),
                              InkWell(
                                onTap: () {
                                  if(selectedOrganizationIDF == "1") {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NotificationList()))
                                        .then((value) {
                                      getDashboardData();
                                    });
                                  }else{
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Feature Not Available"),
                                          content: Text("This feature is not available for the selected organization."),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                              child: Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Stack(
                                  children: <Widget>[
                                    Icon(
                                      Icons.notifications,
                                      size: 32.0,
                                      color: Colors.black,
                                    ),
                                    Visibility(
                                        visible: notificationCount != "0"
                                            ? true
                                            : false,
                                        child: Positioned(
                                          right: 2,
                                          child: new Container(
                                            padding: EdgeInsets.all(1),
                                            decoration: new BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            constraints: BoxConstraints(
                                              minWidth: 15,
                                              minHeight: 15,
                                            ),
                                            child: new Text(
                                              '$notificationCount',
                                              style: new TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          )),
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
              ),
              child: new RichText(
                text: new TextSpan(
                    text: 'Working as ',
                    style: TextStyle(
                        color: Colorsblack,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                    children: [
                      new TextSpan(
                          text: ("${selectedOrganizationName}"),
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
            //     horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
            //   ),
            //   child:
            //   Container(
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
            //     child: TextField(
            //       decoration: const InputDecoration(
            //           contentPadding: EdgeInsets.all(15),
            //           border: InputBorder.none,
            //           hintText: 'Search',
            //           hintStyle: TextStyle(fontSize: 20),
            //           suffixIcon: Icon(
            //             Icons.search,
            //             color: Color(0xFF70a5db),
            //           )),
            //     ),
            //   ),
            // ),
            SizedBox(
              height: SizeConfig.blockSizeVertical! * 4.0,
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
                      20,
                    ),
                    topLeft: Radius.circular(
                      20,
                    ),
                  ),
                ),
                child: Center(
                  child: GridView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: listIconName.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 1.3, crossAxisCount: 3),
                      itemBuilder: (context, index) {
                        return IconCard(
                          IconModel(listIconName[index],
                              listImage[index],"",
                          ),
                          getDashboardData,
                          selectedOrganizationIDF, // Pass selectedOrganizationIDF
                        );
                        //: Container(),
                        /*);*/
                      }),
                )),
            SizedBox(
              height: SizeConfig.blockSizeVertical! * 1,
            ),
            // Padding(
            //   padding: EdgeInsets.symmetric(
            //     horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
            //   ),
            //   child: Text(
            //     "Poster",
            //     style: TextStyle(
            //       color: Colors.black,
            //       fontWeight: FontWeight.w700,
            //       fontSize: SizeConfig.blockSizeHorizontal !* 5,
            //     ),
            //   ),
            // ),
            SizedBox(
              height: SizeConfig.blockSizeVertical! * 1,
            ),
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
                        // height: SizeConfig.blockSizeVertical! * 25,
                        // width: SizeConfig.blockSizeHorizontal! * 98.0,
                        // decoration: BoxDecoration(
                        //   image: DecorationImage(
                        //     image: AssetImage('images/shimmer_effect.png'),
                        //     fit: BoxFit.fill,
                        //   ),
                        // ),
                      ),
              ),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical! * 1,
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
                  height: SizeConfig.blockSizeVertical! * 8,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                        Container(
                          width: SizeConfig.blockSizeHorizontal! * 50,
                          height: SizeConfig.blockSizeVertical! * 8,
                          child: Center(
                            child: Text(
                              "Select Master",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4.8,
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
                              })).then((value) {});
                            } else {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return MastersListScreen(
                                    listMasters[index], index);
                              })).then((value) {});
                            }
                          },
                          child: Padding(
                              padding: EdgeInsets.all(0.0),
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

  void showAddMasterSelectionDialog(List<String> list, BuildContext context) {
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
                  height: SizeConfig.blockSizeVertical! * 8,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                        Container(
                          width: SizeConfig.blockSizeHorizontal! * 50,
                          height: SizeConfig.blockSizeVertical! * 8,
                          child: Center(
                            child: Text(
                              "Add Masters",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4.8,
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
                            if (index == 0) {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return ComplaintsMasterListScreen(
                                    listMasters[index], index);
                              })).then((value) {});
                            }
                            else if(index == 1){
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return ExaminationsMasterListScreen(
                                    listMasters[index], index);
                              })).then((value) {});
                            }
                            else if (index == 2){
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return DiagnosisMasterListScreen(
                                    listMasters[index], index);
                              })).then((value) {});
                            }
                          },
                          child: Padding(
                              padding: EdgeInsets.all(0.0),
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
  //                   size: SizeConfig.blockSizeVertical * 2.2),
  //               textTheme: TextTheme(
  //                   subtitle1: TextStyle(
  //                       color: colorBlack,
  //                       fontFamily: "Ubuntu",
  //                       fontSize: SizeConfig.blockSizeVertical * 2.3)),
  //             ),
  //           ),
  //     },
  //   );
  // }));
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

_launchURL() async {
  const url = 'https://eventprime.in/';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_launchThisURL() async {
  const url = "https://swasthyasetu.com/doctor/dashboard.php";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class IconCard extends StatelessWidget {
  IconModel? model;
  Function? getDashBoardData;
  String? selectedOrganizationIDF;
  // String? roleName;
  // String? OPDRoleStatus;
  // String? IPDRoleStatus;
  // String? AccountsRoleStatus;
  // String? ReportsRoleStatus;
  // String? DashboardRoleStatus;

  IconCard(IconModel model,
      Function getDashBoardDataFn,
      String? selectedOrganizationIDF,
      // String? roleName,
      // organizationIDF,
      // OPDRoleStatus,
      // IPDRoleStatus,AccountsRoleStatus,
      // ReportsRoleStatus,DashboardRoleStatus
      ) {
    this.model = model;
    this.getDashBoardData = getDashBoardDataFn;
    this.selectedOrganizationIDF = selectedOrganizationIDF;
    // this.roleName = roleName;
    // this.OPDRoleStatus = OPDRoleStatus;
    // this.IPDRoleStatus = IPDRoleStatus;
    // this.AccountsRoleStatus = AccountsRoleStatus;
    // this.ReportsRoleStatus = ReportsRoleStatus;
    // this.DashboardRoleStatus = DashboardRoleStatus;
  }

  // async {
  //
  // if (model!.iconName == "Invite Patient") {
  // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  // return InvitePatientScreen();
  // })).then((value) {
  // getDashBoardData!();
  // });
  // }
  // else if (model!.iconName == "Event\nfor Drs") {
  // _launchURL(); // Call the function directly
  // getDashBoardData!();
  // }
  // else if (model!.iconName == "IPD") {
  // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  // return IndoorListScreen();
  // })).then((value) {
  // getDashBoardData!();
  // });
  // }
  // else if (model!.iconName == "Patient\nResources") {
  // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  // return PatientResourcesScreen();
  // })).then((value) {
  // getDashBoardData!();
  // });
  // }
  // else if (model!.iconName == "Market\nPlace") {
  // if(roleName == ""){Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  // return MarketPlaceDashboardScreen(patientIDP!);
  // })).then((value) {
  // getDashBoardData!();
  // });}
  // }
  // else if (model!.iconName == "My\nAppointments") {
  // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  // return OPDRegistrationScreen();
  // })).then((value) {
  // getDashBoardData!();
  // });
  // }
  // else if (model!.iconName == "Investigatin\nList") {
  // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  // return DoctorInvestigationListScreen();
  // })).then((value) {
  // getDashBoardData!();
  // });
  // }
  // else if (model!.iconName == "Doctor\nDashboard") {
  // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  // return DashboardDoctorScreen(
  // selectedOrganizationIDF: "$organizationIDF"
  // );
  // })).then((value) {
  // getDashBoardData!();
  // });
  // }
  //
  // // else if (model!.iconName == "Health Videos") {
  // //   Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  // //     return DoctorHealthVideos();
  // //   })).then((value) {
  // //     getDashBoardData!();
  // //   });
  // // }
  // else if (model!.iconName == "Send\nNotifications") {
  // var name = await getUserName();
  // Get.to(() => SelectPatientsForShareVideo(null, name))!
  //     .then((value) {
  // getDashBoardData!();
  // });
  // } else if (model!.iconName == "Camp") {
  // var name = await getUserName();
  // Get.to(() => CampScreen())!.then((value) {
  // //getDashBoardData();
  // });
  // } else if (model!.iconName == "Lab Reports") {
  // Get.to(() => LabReportsScreen())!.then((value) {
  // getDashBoardData!();
  // });
  // } else if (model!.iconName == "Services") {
  // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  // return OPDServiceListScreen();
  // })).then((value) {
  // getDashBoardData!();
  // });
  // } else if (model!.iconName == "Add\nNew Patient") {
  // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  // return AddPatientScreenDoctor(
  // from: "onlyAddPatient",
  // );
  // })).then((value) {
  // getDashBoardData!();
  // });
  // } else if (model!.iconName == "My\nPatients") {
  // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  // return MyPatientsScreen();
  // })).then((value) {
  // getDashBoardData!();
  // });
  // } else if (model!.iconName == "My\nLibrary") {
  // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  // return DoctorLibraryScreen(patientIDP: patientIDP);
  // })).then((value) {
  // getDashBoardData!();
  // });
  // }
  // //   else if (model!.iconName == "Drugs") {
  // //   Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  // //     return DrugsListScreen();
  // //   })).then((value) {
  // //     getDashBoardData!();
  // //   });
  // // }
  // else if (model!.iconName == "Form 3C") {
  // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  // return Form3CScreen();
  // })).then((value) {
  // getDashBoardData!();
  // });
  // }
  // },

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return
      Visibility(
          // visible: roleName =="frontoffice" ,
        // visible: shouldShowInkWell(model!.iconName, roleName),
        // visible: roleName =="frontoffice" &&
        //     model!.iconName == "Market\nPlace",
        child: InkWell(
          highlightColor: Colors.green[200],
          customBorder: CircleBorder(),
          onTap: () async {

            if (model!.iconName == "Invite Patient") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return InvitePatientScreen();
              })).then((value) {
                getDashBoardData!();
              });
            }
            else if (model!.iconName == "Event\nfor Drs") {
              _launchURL(); // Call the function directly
              getDashBoardData!();
            }
            else if (model!.iconName == "IPD") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return IndoorListScreen(
                    // patientindooridp: "20",
                    // PatientIDP: "736"
                );
              })).then((value) {
                getDashBoardData!();
              });
            }
            else if (model!.iconName == "Patient\nResources") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PatientResourcesScreen();
              })).then((value) {
                getDashBoardData!();
              });
            }
            else if (model!.iconName == "Market\nPlace") {
              if(roleName == ""){Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return MarketPlaceDashboardScreen(patientIDP!);
              })).then((value) {
                getDashBoardData!();
              });}
            }
            else if (model!.iconName == "My\nAppointments") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return OPDRegistrationScreen();
              })).then((value) {
                getDashBoardData!();
              });
            }
            else if (model!.iconName == "Investigatin\nList") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return DoctorInvestigationListScreen();
              })).then((value) {
                getDashBoardData!();
              });
            }
            else if (model!.iconName == "Doctor\nDashboard") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return DashboardDoctorScreen(
                    selectedOrganizationIDF: "${selectedOrganizationIDF}"
                );
              })).then((value) {
                getDashBoardData!();
              });
            }

            // else if (model!.iconName == "Health Videos") {
            //   Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            //     return DoctorHealthVideos();
            //   })).then((value) {
            //     getDashBoardData!();
            //   });
            // }
            else if (model!.iconName == "Send\nNotifications") {
              var name = await getUserName();
              Get.to(() => SelectPatientsForShareVideo(null, name))!
                  .then((value) {
                getDashBoardData!();
              });
            } else if (model!.iconName == "Camp") {
              var name = await getUserName();
              Get.to(() => CampScreen())!.then((value) {
                //getDashBoardData();
              });
            } else if (model!.iconName == "Lab Reports") {
              Get.to(() => LabReportsScreen())!.then((value) {
                getDashBoardData!();
              });
            } else if (model!.iconName == "Services") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return OPDServiceListScreen();
              })).then((value) {
                getDashBoardData!();
              });
            } else if (model!.iconName == "Add\nNew Patient") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return AddPatientScreenDoctor(
                  from: "onlyAddPatient",
                );
              })).then((value) {
                getDashBoardData!();
              });
            } else if (model!.iconName == "My\nPatients") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return MyPatientsScreen();
              })).then((value) {
                getDashBoardData!();
              });
            } else if (model!.iconName == "My\nLibrary") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return DoctorLibraryScreen(patientIDP: patientIDP);
              })).then((value) {
                getDashBoardData!();
              });
            }
            //   else if (model!.iconName == "Drugs") {
            //   Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            //     return DrugsListScreen();
            //   })).then((value) {
            //     getDashBoardData!();
            //   });
            // }
            else if (model!.iconName == "Form 3C") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return Form3CScreen();
              })).then((value) {
                getDashBoardData!();
              });
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal! * 0.0),
            child: Container(
              child: Card(
                color: colorWhite,
                elevation: 2.0,
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
                      Image(
                        width: SizeConfig.blockSizeHorizontal! * 7,
                        height: SizeConfig.blockSizeHorizontal! * 7,
                        image: AssetImage(
                          'images/${model!.image}',
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical! * 2,
                      ),
                      Flexible(
                        child: Text(model!.iconName!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeHorizontal! * 2.8,
                            )),
                      ),
                    ]),
              ),
            ),
          )),
      );
  }

  bool shouldShowInkWell(String? iconName, String? roleName) {
    if (iconName == "Market\nPlace" && roleName == "frontoffice") {
      return true;
    }
    // Add more conditions as needed
    return false;
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
                          "Choose Language",
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
        imageUrl: imageURL(widget.photos, _pos),
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

imageURL(List<String> photos, int _pos) {
  photos.length > 0
      ? "${photos[_pos]}"
      : AssetImage('images/shimmer_effect.png');
}
