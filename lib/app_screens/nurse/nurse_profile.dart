import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silvertouch/api/api_helper.dart';
import 'package:silvertouch/app_screens/change_password_doctor_screen.dart';
import 'package:silvertouch/app_screens/help_screen.dart';
import 'package:silvertouch/app_screens/landing_screen.dart';
import 'package:silvertouch/app_screens/nurse/nurse_doc_screen.dart';
import 'package:silvertouch/app_screens/nurse/nurse_org_switch_screen.dart';
import 'package:silvertouch/app_screens/nurse/switch_profile_screen.dart';
import 'package:silvertouch/app_screens/switch_organization.dart';
import 'package:silvertouch/app_screens/switch_role_screen.dart';
import 'package:silvertouch/app_screens/view_profile_details_doctor.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import '../../utils/color.dart';
import '../reception_dashboard_screen.dart';

String mainSliderTimeGlobal = "", subSliderTimeGlobal = "";

String imgUrl = "",
    firstName = "",
    lastName = "",
    middleName = "",
    userNameGlobal = "",
    patientID = "";
String? patientIDP;
String roleName = "";
String OPDRoleStatus ="" ,
    IPDRoleStatus = "",
    AccountsRoleStatus= "",
    ReportsRoleStatus= "",
    DashboardRoleStatus= "";


bool shouldExit = false;
String mobNo = "";
String orgFrontOfficeIDP = "";
String orgIDF = "";

String payGatewayURL = "";


class NurseProfileScreenScreen extends StatefulWidget {

  String selectedOrganizationName = '';
  String imgUrl = "";
  // const SwitchOrganizationView({super.key});


  @override
  State<NurseProfileScreenScreen> createState() => _NurseProfileScreenScreenState();
}

class _NurseProfileScreenScreenState extends State<NurseProfileScreenScreen> {

  @override
  void initState() {
    // selectedOrganizationName;
    getPatientProfileDetails();
    getDashboardData();
    super.initState();
  }

  final String urlFetchPatientProfileDetails =
      "${baseURL}doctorProfileData.php";

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
      // imgUrl = jsonData[0]['DoctorImage'];
      // firstName = jsonData[0]['FirstName'];
      // lastName = jsonData[0]['LastName'];
      // middleName = jsonData[0]['MiddleName'];
      // userNameGlobal = (firstName.trim() + " " + lastName.trim()).trim() != ""
      //     ? firstName.trim() + " " + lastName.trim()
      //     : "Complete your profile";

      // doctorSuffix = jsonData[0]['DoctorSuffix'];
      // couponCode = jsonData[0]['CouponCode'];
      // downloadURL = jsonData[0]['DownloadURL'];
      // setUserName(userNameGlobal);

      // Extract nested JSON data from 'dataDoctor' field
      var dataDoctor = jsonData[0]['dataFrontOfiice'];
      mobNo = dataDoctor['FrontOfficeMobileNo'] != "" ? dataDoctor['FrontOfficeMobileNo'] : "-";
      userNameGlobal = dataDoctor['doctorName'];
      roleName = dataDoctor['RoleName'];
      OPDRoleStatus = dataDoctor['OPDRoleStatus'];
      IPDRoleStatus = dataDoctor['IPDRoleStatus'];
      AccountsRoleStatus = dataDoctor['AccountsRoleStatus'];
      ReportsRoleStatus = dataDoctor['ReportsRoleStatus'];
      DashboardRoleStatus = dataDoctor['DashboardRoleStatus'];

      //setEmergencyNumber(jsonData[0]['EmergencyNumber']);
      debugPrint("Img url - $imgUrl");
      debugPrint("IPD Role -------------------------------------------------------- $IPDRoleStatus");
      debugPrint("Dashboard Role -------------------------------------------------------- $DashboardRoleStatus");


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
      //showUpdateDialog(context);
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      // String imgUrl = "${baseURL}images/popupimage/" + jsonData['PopupImage'];
      // final jsonArrayMainSlider = jsonData['MainSlider'];
      //
      // fullName = await getUserName();
      // email = await getEmail();
      // setPopUpIDP(jsonData['PopupIDP']);
      // payGatewayURL = jsonData['PayGatewayURL'];
      setState(() {
        // notificationCount = jsonData['NotificationCount'];
        // messageCount =
        // jsonData['ChatCount'] != null ? jsonData['ChatCount'] : "0";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ColoredBox(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
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
              ),
              InkWell(
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
                  ))
            ],
          ),
        ),
      ),
      body: Builder(builder: (context) {
        return nurseGeneralProfileWidget(context);
      },
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
                      // ColoredBox(
                      //   color: Colors.white,
                      //   child: Padding(
                      //     padding: EdgeInsets.symmetric(
                      //         horizontal:
                      //         SizeConfig.blockSizeHorizontal! * 2.0),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Padding(
                      //           padding: EdgeInsets.only(
                      //               left:
                      //               SizeConfig.blockSizeHorizontal! * 28.0),
                      //           child: Text(
                      //             "Nurse Profile",
                      //             style: TextStyle(
                      //               color: Colors.black,
                      //               fontWeight: FontWeight.w500,
                      //               fontSize:
                      //               SizeConfig.blockSizeHorizontal! * 5.0,
                      //             ),
                      //             textAlign: TextAlign.center,
                      //           ),
                      //         ),
                      //         Padding(
                      //           padding: EdgeInsets.only(
                      //             left: SizeConfig.blockSizeHorizontal! * 15.0,
                      //           ),
                      //           child: InkWell(
                      //               onTap: () {
                      //                 Navigator.of(context).push(
                      //                     MaterialPageRoute(builder: (context) {
                      //                       return HelpScreen(patientIDP!);
                      //                     })).then((value) {
                      //                   getDashboardData();
                      //                 });
                      //               },
                      //               child: Row(
                      //                 children: [
                      //                   Text(
                      //                     "help",
                      //                     style: TextStyle(
                      //                       color: Colors.black,
                      //                       fontWeight: FontWeight.w500,
                      //                       fontSize: SizeConfig
                      //                           .blockSizeHorizontal! *
                      //                           4.0,
                      //                     ),
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                   Image.asset(
                      //                     "images/v-2-icn-help.png",
                      //                     // alignment: Alignment.centerRight,
                      //                     width:
                      //                     SizeConfig.blockSizeHorizontal! *
                      //                         8.0,
                      //                   ),
                      //                 ],
                      //               )),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          // Navigator.of(context)
                          //     .push(MaterialPageRoute(builder: (context) {
                          //   return ViewProfileDetailsDoctor();
                          // })).then((value) {
                          //   getDashboardData();
                          //   getPatientProfileDetails();
                          // });
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
                          onTap: (){
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return SwitchProfileScreen();
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
                                      "Switch Profile",
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
                            return SwitchOrganizationStaffScreen();
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
                                      "Switch Staff",
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

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }

}





