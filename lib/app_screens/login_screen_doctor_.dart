// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
// import 'package:get/get.dart';
// import 'package:swasthyasetu/api/api_helper.dart';
// import 'package:swasthyasetu/app_screens/doctor_dashboard_screen.dart';
// import 'package:swasthyasetu/app_screens/doctor_registration_screen.dart';
// import 'package:swasthyasetu/app_screens/forgot_password_doctor_screen.dart';
// import 'package:swasthyasetu/global/SizeConfig.dart';
// import 'package:swasthyasetu/global/utils.dart';
// import 'package:swasthyasetu/podo/response_main_model.dart';
// import 'package:swasthyasetu/utils/progress_dialog.dart';
//
// import '../utils/color.dart';
// import '../utils/string_resource.dart';
// import 'reception_dashboard_screen.dart';
//
// final focus = FocusNode();
// TextEditingController mobileNoController = new TextEditingController();
// TextEditingController passwordController = new TextEditingController();
//
// class LoginScreenDoctor extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return LoginScreenDoctorState();
//   }
// }
//
// class LoginScreenDoctorState extends State<LoginScreenDoctor> {
//   bool _passwordVisible = false;
//   ApiHelper apiHelper = ApiHelper();
//
//   @override
//   void initState() {
//     mobileNoController = new TextEditingController();
//     passwordController = new TextEditingController();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
//       return Scaffold(
//         // resizeToAvoidBottomInset: false,
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
//             child: Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage("images/v2-login-doctor.png"),
//                   fit: BoxFit.fill,
//                 ),
//               ),
//               child: Stack(
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.fromLTRB(
//                         0, SizeConfig.blockSizeVertical !* 35, 0, 0),
//                     child: Center(
//                       child: Builder(builder: (BuildContext mContext) {
//                         return Column(children: <Widget>[
//                           Expanded(
//                             child: Center(
//                               child: ListView(
//                                 shrinkWrap: true,
//                                 children: <Widget>[
//                                   Align(
//                                       alignment: Alignment.center,
//                                       child:
//                                           Text("Healthcare\nProfessional Login",
//                                               textAlign: TextAlign.center,
//                                               style: TextStyle(
//                                                 fontSize: 20,
//                                                 color: Colors.white,
//                                               ))),
//                                   Align(
//                                       alignment: Alignment.topLeft,
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 30.0, vertical: 10),
//                                         child: Container(
//                                           width: SizeConfig.screenWidth,
//                                           child: TextField(
//                                             controller: mobileNoController,
//                                             style: TextStyle(color: black),
//                                             decoration: InputDecoration(
//                                               hintText: 'User Name',
//                                               hintStyle:
//                                                   TextStyle(fontSize: 16),
//                                               border: OutlineInputBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(30),
//                                                 borderSide: BorderSide(
//                                                   width: 0,
//                                                   style: BorderStyle.none,
//                                                 ),
//                                               ),
//                                               filled: true,
//                                               contentPadding:
//                                                   EdgeInsets.all(12),
//                                               fillColor: Colors.white,
//                                             ),
//                                           ),
//                                         ),
//                                       )),
//                                   Align(
//                                       alignment: Alignment.topLeft,
//                                       child: Padding(
//                                         padding: EdgeInsets.symmetric(
//                                           horizontal: 30.0,
//                                           vertical:
//                                               SizeConfig.blockSizeVertical !* 2,
//                                         ),
//                                         child: Container(
//                                           width: SizeConfig.screenWidth,
//                                           child: TextField(
//                                             controller: passwordController,
//                                             obscureText: !_passwordVisible,
//                                             style: TextStyle(color: black),
//                                             decoration: InputDecoration(
//                                               hintText: 'Password',
//                                               hintStyle:
//                                                   TextStyle(fontSize: 16),
//                                               border: OutlineInputBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(30),
//                                                 borderSide: BorderSide(
//                                                   width: 0,
//                                                   style: BorderStyle.none,
//                                                 ),
//                                               ),
//                                               suffixIcon: GestureDetector(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     _passwordVisible =
//                                                         !_passwordVisible;
//                                                   });
//                                                 },
//                                                 child: Icon(
//                                                     _passwordVisible
//                                                         ? Icons.visibility_off
//                                                         : Icons.visibility,
//                                                     color: black),
//                                               ),
//                                               filled: true,
//                                               contentPadding:
//                                                   EdgeInsets.all(12),
//                                               fillColor: Colors.white,
//                                             ),
//                                           ),
//                                         ),
//                                       )),
//                                   Padding(
//                                     padding: EdgeInsets.only(
//                                         right: SizeConfig.blockSizeHorizontal !*
//                                             13.0,
//                                         bottom:
//                                             SizeConfig.blockSizeVertical !* 2),
//                                     child: Align(
//                                       alignment: Alignment.centerRight,
//                                       child: InkWell(
//                                         onTap: () {
//                                           Navigator.of(context)
//                                               .pushAndRemoveUntil(
//                                                   MaterialPageRoute(
//                                                       builder: (context) {
//                                             return ForgotPasswordDoctorLogin();
//                                           }), (route) => false);
//                                         },
//                                         child: Text(
//                                           "Forgot Password?",
//                                           textAlign: TextAlign.right,
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize:
//                                                 SizeConfig.blockSizeHorizontal !*
//                                                     4,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 30.0),
//                                     child: SizedBox(
//                                       width: SizeConfig.screenWidth,
//                                       child: TextButton(
//                                           child: Text(str_login.toUpperCase(),
//                                               style: TextStyle(fontSize: 16)),
//                                           style: ButtonStyle(
//                                               padding:
//                                                   MaterialStateProperty.all<EdgeInsets>(
//                                                       EdgeInsets.all(15)),
//                                               foregroundColor:
//                                                   MaterialStateProperty.all<Color>(
//                                                       colorWhite),
//                                               backgroundColor:
//                                                   MaterialStateProperty.all<Color>(
//                                                       colorBlueDark),
//                                               shape: MaterialStateProperty.all<
//                                                       RoundedRectangleBorder>(
//                                                   RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
//                                           onPressed: () => doLogin(context)),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: SizeConfig.blockSizeVertical !* 2,
//                                   ),
//                                   Text("Don't Have a Account?",
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.white,
//                                       )),
//                                   SizedBox(
//                                     height: SizeConfig.blockSizeVertical !* 1.0,
//                                   ),
//                                   !isKeyboardVisible
//                                       ? /*Align(
//                                   alignment: Alignment.bottomCenter,
//                                   child: MaterialButton(
//                                       color: Color(0xFF06A759),
//                                       minWidth:
//                                           SizeConfig.blockSizeHorizontal * 50.0,
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                         SizeConfig.blockSizeHorizontal * 50.0,
//                                       )),
//                                       onPressed: () {
//                                         Get.to(
//                                             () => DoctorRegistrationScreen());
//                                       },
//                                       child: Padding(
//                                         padding: EdgeInsets.all(
//                                           SizeConfig.blockSizeHorizontal * 2.0,
//                                         ),
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Image(
//                                               width: SizeConfig
//                                                       .blockSizeHorizontal *
//                                                   6,
//                                               image: AssetImage(
//                                                   'images/ic_doctor_clinic.png'),
//                                               color: Colors.white,
//                                             ),
//                                             SizedBox(
//                                               width: SizeConfig
//                                                       .blockSizeHorizontal *
//                                                   3.0,
//                                             ),
//                                             Text(
//                                               "Register Here",
//                                               style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: SizeConfig
//                                                         .blockSizeHorizontal *
//                                                     4.0,
//                                                 fontWeight: FontWeight.w500,
//                                                 letterSpacing: 1.3,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       )
//                                       ),
//                                   */ /*)*/ /*
//                                 )*/
//                                       Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 30.0),
//                                           child: SizedBox(
//                                             width: SizeConfig.screenWidth,
//                                             child: TextButton(
//                                                 child: Text("Register Here".toUpperCase(),
//                                                     style: TextStyle(
//                                                         fontSize: 16)),
//                                                 style: ButtonStyle(
//                                                     padding: MaterialStateProperty.all<EdgeInsets>(
//                                                         EdgeInsets.all(15)),
//                                                     foregroundColor:
//                                                         MaterialStateProperty.all<Color>(
//                                                             colorWhite),
//                                                     backgroundColor:
//                                                         MaterialStateProperty.all<Color>(
//                                                             colorBlueDark),
//                                                     shape: MaterialStateProperty.all<
//                                                             RoundedRectangleBorder>(
//                                                         RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
//                                                 onPressed: () => Get.to(() => DoctorRegistrationScreen())),
//                                           ),
//                                         )
//                                       : Container(),
//                                   SizedBox(
//                                     height: SizeConfig.blockSizeVertical !* 1.0,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ]);
//                       }),
//                     ),
//                   ),
//                   Positioned(
//                     left: 40.0,
//                     bottom: 10.0,
//                     child: InkWell(
//                       onTap: () => Navigator.of(context).pop(),
//                       child: Wrap(
//                         crossAxisAlignment: WrapCrossAlignment.center,
//                         children: [
//                           ImageIcon(
//                             AssetImage("images/v-2-arrow-back.png"),
//                             color: colorWhite,
//                             size: 24,
//                           ),
//                           SizedBox(
//                             width: 5,
//                           ),
//                           Text(
//                             str_back,
//                             style: TextStyle(color: colorWhite, fontSize: 20),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
//
//   void doLogin(BuildContext context) async {
//     final String loginUrl = "${baseURL}doctorLogin.php";
//     /*List<IconModel> listIcon;*/
//     String mobNoToValidate = mobileNoController.text;
//     if (mobileNoController.text.length >= 12) {
//       if (mobileNoController.text.startsWith("+91")) {
//         mobNoToValidate = mobileNoController.text.replaceFirst("+91", "");
//       } else if (mobileNoController.text.startsWith("91")) {
//         mobNoToValidate = mobileNoController.text.replaceFirst("91", "");
//       }
//     }
//
//     if (mobNoToValidate == "") {
//       final snackBar = SnackBar(
//         backgroundColor: Colors.red,
//         content: Text("Please enter Username"),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     } else if (passwordController.text.trim() == "") {
//       final snackBar = SnackBar(
//         backgroundColor: Colors.red,
//         content: Text("Please enter Password"),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     } else {
//       ProgressDialog pr = ProgressDialog(context);
//       pr.show();
//       //listIcon = new List();
//       var response =
//           await apiHelper.callApiWithHeadersAndBody(url: loginUrl, headers: {
//         "u": mobNoToValidate,
//         "p": passwordController.text.trim(),
//         "type": "doctor",
//       });
//       /*await http.post(
//         Uri.encodeFull(loginUrl),
//         headers: {
//           "u": mobileNoController.text.trim(),
//           "p": passwordController.text.trim(),
//           "type": "doctor",
//         },
//       );*/
//       //var resBody = json.decode(response.body);
//       debugPrint(response.body.toString());
//       final jsonResponse = json.decode(response.body.toString());
//       ResponseModel model = ResponseModel.fromJSON(jsonResponse);
//       pr.hide();
//       if (model.status == "OK") {
//         var data = jsonResponse['Data'];
//         var strData = decodeBase64(data);
//         debugPrint("Decoded Data Array : " + strData);
//         final jsonData = json.decode(strData);
//         var patientIDP = jsonData[0]['DoctorIDP'];
//         var patientUniqueKey = decodeBase64(jsonData[0]['DoctorUniqueKey']);
//         var middleName = jsonData[0]['MiddleName'].toString();
//         setUserName(jsonData[0]['FirstName'].toString().trim() +
//             " " +
//             middleName.trim() +
//             " " +
//             jsonData[0]['LastName'].toString().trim());
//         setEmail(jsonData[0]['EmailID']);
//         setMobNo(jsonData[0]['MobileNo']);
//         setPatientIDP(patientIDP);
//         setCityIDF(jsonData[0]['CityIDF']);
//         setStateIDF(jsonData[0]['StateIDF']);
//         setCityName(jsonData[0]['CityName']);
//         setPatientUniqueKey(patientUniqueKey);
//         setUserType(jsonData[0]['ScreenType']);
//         if (jsonData[0]['ScreenType'] == 'frontoffice')
//           Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => ReceptionDashboardScreen()));
//         else
//           Navigator.pushReplacement(context,
//               MaterialPageRoute(builder: (context) => DoctorDashboardScreen()));
//       } else {
//         final snackBar = SnackBar(
//           backgroundColor: Colors.red,
//           content: Text(model.message!),
//         );
//         ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       }
//     }
//   }
//
//   /*void doLoginReception(BuildContext context) async {
//     final String loginUrl = "${baseURL}frontofficeLogin.php";
//     */ /*List<IconModel> listIcon;*/ /*
//     String mobNoToValidate = mobileNoController.text;
//     if (mobileNoController.text.length >= 12) {
//       if (mobileNoController.text.startsWith("+91")) {
//         mobNoToValidate = mobileNoController.text.replaceFirst("+91", "");
//       } else if (mobileNoController.text.startsWith("91")) {
//         mobNoToValidate = mobileNoController.text.replaceFirst("91", "");
//       }
//     }
//
//     if (mobNoToValidate == "") {
//       final snackBar = SnackBar(
//         backgroundColor: Colors.red,
//         content: Text("Please enter Username"),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     } else if (passwordController.text.trim() == "") {
//       final snackBar = SnackBar(
//         backgroundColor: Colors.red,
//         content: Text("Please enter Password"),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     } else {
//       ProgressDialog pr = ProgressDialog(context);
//       pr.show();
//       //listIcon = ne9-6999+w List();
//       var response =
//           await apiHelper.callApiWithHeadersAndBody(url: loginUrl, headers: {
//         "u": mobNoToValidate,
//         "p": passwordController.text.trim(),
//         "type": "frontoffice",
//       });
//       */ /*await http.post(
//         Uri.encodeFull(loginUrl),
//         headers: {
//           "u": mobileNoController.text.trim(),
//           "p": passwordController.text.trim(),
//           "type": "doctor",
//         },
//       );*/ /*
//       //var resBody = json.decode(response.body);
//       debugPrint(response.body.toString());
//       final jsonResponse = json.decode(response.body.toString());
//       ResponseModel model = ResponseModel.fromJSON(jsonResponse);
//       pr.hide();
//       if (model.status == "OK") {
//         var data = jsonResponse['Data'];
//         var strData = decodeBase64(data);
//         debugPrint("Decoded Data Array : " + strData);
//         final jsonData = json.decode(strData);
//         var patientIDP = jsonData[0]['DoctorIDP'];
//         var patientUniqueKey = decodeBase64(jsonData[0]['DoctorUniqueKey']);
//         var middleName = jsonData[0]['MiddleName'].toString();
//         setUserName(jsonData[0]['FirstName'].toString().trim() +
//             " " +
//             middleName.trim() +
//             " " +
//             jsonData[0]['LastName'].toString().trim());
//         setEmail(jsonData[0]['EmailID']);
//         setMobNo(jsonData[0]['MobileNo']);
//         setPatientIDP(patientIDP);
//         setCityIDF(jsonData[0]['CityIDF']);
//         setStateIDF(jsonData[0]['StateIDF']);
//         setCityName(jsonData[0]['CityName']);
//         setPatientUniqueKey(patientUniqueKey);
//         setUserType("frontoffice");
//         Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => ReceptionDashboardScreen()));
//       } else {
//         final snackBar = SnackBar(
//           backgroundColor: Colors.red,
//           content: Text(model.message),
//         );
//         ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       }
//     }
//   }*/
//
//   String encodeBase64(String text) {
//     var bytes = utf8.encode(text);
//     //var base64str =
//     return base64.encode(bytes);
//     //= Base64Encoder().convert()
//   }
//
//   String decodeBase64(String text) {
//     //var bytes = utf8.encode(text);
//     //var base64str =
//     var bytes = base64.decode(text);
//     return String.fromCharCodes(bytes);
//     //= Base64Encoder().convert()
//   }
// }
