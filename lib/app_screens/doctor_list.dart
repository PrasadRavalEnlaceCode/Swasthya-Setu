// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:swasthyasetu/app_screens/chat_screen.dart';
// import 'package:swasthyasetu/app_screens/doctor_full_details_screen.dart';
// import 'package:swasthyasetu/app_screens/patient_doctor_permissions_screen.dart';
// import 'package:swasthyasetu/app_screens/video_call_screen.dart';
// import 'package:swasthyasetu/controllers/payment_webview_controller.dart';
// import 'package:swasthyasetu/global/SizeConfig.dart';
// import 'package:swasthyasetu/global/utils.dart';
// import 'package:swasthyasetu/podo/dropdown_item.dart';
// import 'package:swasthyasetu/podo/response_main_model.dart';
//
// import 'package:http/http.dart' as http;
// import 'package:swasthyasetu/widgets/extensions.dart';
//
// import '../utils/color.dart';
// import '../utils/progress_dialog.dart';
// import 'appointment_doctors_list.dart';
// import 'fullscreen_image.dart';
// import 'not_connected_doctors_list.dart';
//
// class DoctorListScreen extends StatefulWidget {
//   String patientIDP = "";
//   Widget emptyMessageWidget;
//   String emptyMessage = "";
//   String emptyTextMyDoctors1 =
//       "Ask your Doctor to send you bind request from Swasthya setu Doctor panel so that you can able to share all your Health records to your prefered doctor.";
//   final String urlFetchPatientProfileDetails =
//       "${baseURL}patientProfileData.php";
//
//   DoctorListScreen(String patientIDP) {
//     this.patientIDP = patientIDP;
//   }
//
//   @override
//   State<StatefulWidget> createState() {
//     return DoctorListScreenState();
//   }
// }
//
// class DoctorListScreenState extends State<DoctorListScreen> {
//   List<Map<String, String>> listDoctors = [];
//   List<Map<String, String>> listDoctorsSearchResults = [];
//   Widget titleWidget = Text("My Doctors");
//   String cityIDF = "";
//   String firstName = "";
//   String lastName = "";
//   bool doctorApiCalled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     widget.emptyMessage = "${widget.emptyTextMyDoctors1}";
//     widget.emptyMessageWidget = SizedBox(
//       height: SizeConfig.blockSizeVertical * 80,
//       child: Container(
//         padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 5),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             Image(
//               image: AssetImage("images/ic_idea_new.png"),
//               width: 100,
//               height: 100,
//             ),
//             SizedBox(
//               height: 30.0,
//             ),
//             Text(
//               "${widget.emptyMessage}",
//               style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
//             ),
//           ],
//         ),
//       ),
//     );
//     getPatientProfileDetails();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: titleWidget,
//         backgroundColor: Color(0xFFFFFFFF),
//         iconTheme: IconThemeData(
//             color: colorBlack, size: SizeConfig.blockSizeVertical * 2.5),
//         toolbarTextStyle: TextTheme(
//           headline6: TextStyle(
//               color: colorBlack,
//               fontFamily: "Ubuntu",
//               fontSize: SizeConfig.blockSizeVertical * 2.5)).bodyText2,
//         titleTextStyle: TextTheme(
//             headline6: TextStyle(
//                 color: colorBlack,
//                 fontFamily: "Ubuntu",
//                 fontSize: SizeConfig.blockSizeVertical * 2.5)).headline6,
//       ),
//       body: Builder(
//
//       )
//     )
//   }
//
//   Future<String> getPatientProfileDetails() async {
//     /*List<IconModel> listIcon;*/
//     var doctorApiCalled = false;
//     ProgressDialog pr = ProgressDialog(context);
//     Future.delayed(Duration.zero, () {
//       pr.show();
//     });
//
//     try {
//       String patientUniqueKey = await getPatientUniqueKey();
//       String userType = await getUserType();
//       debugPrint("Key and type");
//       debugPrint(patientUniqueKey);
//       debugPrint(userType);
//       String jsonStr = "{" +
//           "\"" +
//           "PatientIDP" +
//           "\"" +
//           ":" +
//           "\"" +
//           widget.patientIDP +
//           "\"" +
//           "}";
//
//       debugPrint(jsonStr);
//
//       String encodedJSONStr = encodeBase64(jsonStr);
//       //listIcon = new List();
//       var response = await apiHelper.callApiWithHeadersAndBody(
//         url: widget.urlFetchPatientProfileDetails,
//         headers: {
//           "u": patientUniqueKey,
//           "type": userType,
//         },
//         body: {"getjson": encodedJSONStr},
//       );
//       //var resBody = json.decode(response.body);
//       debugPrint(response.body.toString());
//       final jsonResponse = json.decode(response.body.toString());
//       ResponseModel model = ResponseModel.fromJSON(jsonResponse);
//       if (model.status == "OK") {
//         var data = jsonResponse['Data'];
//         var strData = decodeBase64(data);
//         debugPrint("Decoded Data Array : " + strData);
//         final jsonData = json.decode(strData);
//         cityIDF = jsonData[0]['CityIDF'];
//         firstName = jsonData[0]['FirstName'];
//         lastName = jsonData[0]['LastName'];
//
//         listDoctors = [];
//         listDoctorsSearchResults = [];
//         String loginUrl = "${baseURL}doctorList.php";
//         //listIcon = new List();
//         String patientUniqueKey = await getPatientUniqueKey();
//         String userType = await getUserType();
//         debugPrint("Key and type");
//         debugPrint(patientUniqueKey);
//         debugPrint(userType);
//         var cityIdp = "";
//         if (cityIDF != "")
//           cityIdp = cityIDF;
//         else
//           cityIdp = "-";
//         String jsonStr = "{" +
//             "\"" +
//             "PatientIDP" +
//             "\"" +
//             ":" +
//             "\"" +
//             widget.patientIDP +
//             "\"" +
//             "," +
//             "\"" +
//             "CityIDP" +
//             "\"" +
//             ":" +
//             "\"" +
//             cityIdp +
//             "\"" +
//             "}";
//
//         debugPrint("Doctor API request object");
//         debugPrint(jsonStr);
//
//         String encodedJSONStr = encodeBase64(jsonStr);
//         var response = await apiHelper.callApiWithHeadersAndBody(
//           url: loginUrl,
//           //Uri.parse(loginUrl),
//           headers: {
//             "u": patientUniqueKey,
//             "type": userType,
//           },
//           body: {"getjson": encodedJSONStr},
//         );
//         //var resBody = json.decode(response.body);
//         debugPrint(response.body.toString());
//         final jsonResponse1 = json.decode(response.body.toString());
//         ResponseModel model = ResponseModel.fromJSON(jsonResponse1);
//         pr.hide();
//
//         if (model.status == "OK") {
//           var data = jsonResponse1['Data'];
//           var strData = decodeBase64(data);
//           debugPrint("Decoded Data Array Dashboard : " + strData);
//           final jsonData = json.decode(strData);
//           if (jsonData.length > 0)
//             doctorApiCalled = true;
//           else
//             doctorApiCalled = false;
//           for (var i = 0; i < jsonData.length; i++) {
//             var jo = jsonData[i];
//             listDoctors.add({
//               "DoctorIDP": jo['DoctorIDP'].toString(),
//               "DoctorID": jo['DoctorID'].toString(),
//               "FirstName": jo['FirstName'].toString(),
//               "LastName": jo['LastName'].toString(),
//               "MobileNo": jo['MobileNo'].toString(),
//               "Specility": jo['Specility'].toString(),
//               "DoctorImage": jo['DoctorImage'].toString(),
//               "CityName": jo['CityName'].toString(),
//               "BindedTag": jo['BindedTag'].toString(),
//               "HealthRecordsDisplayStatus":
//               jo['HealthRecordsDisplayStatus'].toString(),
//               "ConsultationDisplayStatus":
//               jo['ConsultationDisplayStatus'].toString(),
//               "DueAmount": jo['DueAmount'].toString(),
//             });
//             listDoctorsSearchResults.add({
//               "DoctorIDP": jo['DoctorIDP'].toString(),
//               "DoctorID": jo['DoctorID'].toString(),
//               "FirstName": jo['FirstName'].toString(),
//               "LastName": jo['LastName'].toString(),
//               "MobileNo": jo['MobileNo'].toString(),
//               "Specility": jo['Specility'].toString(),
//               "DoctorImage": jo['DoctorImage'].toString(),
//               "CityName": jo['CityName'].toString(),
//               "BindedTag": jo['BindedTag'].toString(),
//               "HealthRecordsDisplayStatus":
//               jo['HealthRecordsDisplayStatus'].toString(),
//               "ConsultationDisplayStatus":
//               jo['ConsultationDisplayStatus'].toString(),
//               "DueAmount": jo['DueAmount'].toString(),
//             });
//           }
//           setState(() {});
//         }
//         //setState(() {});
//       } else {
//         final snackBar = SnackBar(
//           backgroundColor: Colors.red,
//           content: Text(model.message),
//         );
//         ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       }
//     } catch (exception) {
//       if (!doctorApiCalled) {
//         try {
//           listDoctors = [];
//           listDoctorsSearchResults = [];
//           String loginUrl = "${baseURL}doctorList.php";
//           //listIcon = new List();
//           String patientUniqueKey = await getPatientUniqueKey();
//           String userType = await getUserType();
//           debugPrint("Key and type");
//           debugPrint(patientUniqueKey);
//           debugPrint(userType);
//           var cityIdp = "";
//           if (cityIDF != "")
//             cityIdp = cityIDF;
//           else
//             cityIdp = "-";
//           String jsonStr = "{" +
//               "\"" +
//               "PatientIDP" +
//               "\"" +
//               ":" +
//               "\"" +
//               widget.patientIDP +
//               "\"" +
//               "," +
//               "\"" +
//               "CityIDP" +
//               "\"" +
//               ":" +
//               "\"" +
//               cityIdp +
//               "\"" +
//               "}";
//
//           debugPrint("Doctor API request object");
//           debugPrint(jsonStr);
//
//           String encodedJSONStr = encodeBase64(jsonStr);
//           var response = await apiHelper.callApiWithHeadersAndBody(
//             url: loginUrl,
//             //Uri.parse(loginUrl),
//             headers: {
//               "u": patientUniqueKey,
//               "type": userType,
//             },
//             body: {"getjson": encodedJSONStr},
//           );
//           //var resBody = json.decode(response.body);
//           debugPrint(response.body.toString());
//           final jsonResponse1 = json.decode(response.body.toString());
//           ResponseModel model = ResponseModel.fromJSON(jsonResponse1);
//           pr.hide();
//
//           if (model.status == "OK") {
//             var data = jsonResponse1['Data'];
//             var strData = decodeBase64(data);
//             debugPrint("Decoded Data Array Dashboard : " + strData);
//             final jsonData = json.decode(strData);
//             if (jsonData.length > 0)
//               doctorApiCalled = true;
//             else
//               doctorApiCalled = false;
//             for (var i = 0; i < jsonData.length; i++) {
//               var jo = jsonData[i];
//               listDoctors.add({
//                 "DoctorIDP": jo['DoctorIDP'].toString(),
//                 "DoctorID": jo['DoctorID'].toString(),
//                 "FirstName": jo['FirstName'].toString(),
//                 "LastName": jo['LastName'].toString(),
//                 "MobileNo": jo['MobileNo'].toString(),
//                 "Specility": jo['Specility'].toString(),
//                 "DoctorImage": jo['DoctorImage'].toString(),
//                 "CityName": jo['CityName'].toString(),
//                 "BindedTag": jo['BindedTag'].toString(),
//                 "HealthRecordsDisplayStatus":
//                 jo['HealthRecordsDisplayStatus'].toString(),
//                 "ConsultationDisplayStatus":
//                 jo['ConsultationDisplayStatus'].toString(),
//                 "DueAmount": jo['DueAmount'].toString(),
//               });
//               listDoctorsSearchResults.add({
//                 "DoctorIDP": jo['DoctorIDP'].toString(),
//                 "DoctorID": jo['DoctorID'].toString(),
//                 "FirstName": jo['FirstName'].toString(),
//                 "LastName": jo['LastName'].toString(),
//                 "MobileNo": jo['MobileNo'].toString(),
//                 "Specility": jo['Specility'].toString(),
//                 "DoctorImage": jo['DoctorImage'].toString(),
//                 "CityName": jo['CityName'].toString(),
//                 "BindedTag": jo['BindedTag'].toString(),
//                 "HealthRecordsDisplayStatus":
//                 jo['HealthRecordsDisplayStatus'].toString(),
//                 "ConsultationDisplayStatus":
//                 jo['ConsultationDisplayStatus'].toString(),
//                 "DueAmount": jo['DueAmount'].toString(),
//               });
//             }
//             setState(() {});
//           }
//         } catch (exception) {
//           pr.hide();
//         }
//       } else {
//         pr.hide();
//       }
//     }
//
//     return 'success';
//   }
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
//
//   void showCitySelectionDialog(List<DropDownItem> list, String type) {
//     // showDialog(
//     //     barrierDismissible: false,
//     //     context: context,
//     //     builder: (BuildContext context) => CountryDialog(list, type, callbackFromCountryDialog));
//   }
//
//   isImageNotNullAndBlank(int index) {
//     return (listDoctorsSearchResults[index]["DoctorImage"] != "" &&
//         listDoctorsSearchResults[index]["DoctorImage"] != null &&
//         listDoctorsSearchResults[index]["DoctorImage"] != "null");
//   }
//
//   void bindUnbindDoctor(
//       /*String bindFlag,*/
//       Map<String, String> doctorData) async {
//     //String loginUrl = "${baseURL}patientBindDoctor.php";
//     String loginUrl = "${baseURL}patientBindRequesttoDoctor.php";
//     ProgressDialog pr;
//     Future.delayed(Duration.zero, () {
//       pr = ProgressDialog(context);
//       pr.show();
//     });
//     //listIcon = new [];
//     String patientUniqueKey = await getPatientUniqueKey();
//     String userType = await getUserType();
//     debugPrint("Key and type");
//     debugPrint(patientUniqueKey);
//     debugPrint(userType);
//     String jsonStr = "{" +
//         "\"" +
//         "PatientIDP" +
//         "\"" +
//         ":" +
//         "\"" +
//         widget.patientIDP +
//         "\"" +
//         "," +
//         "\"" +
//         "DoctorIDP" +
//         "\"" +
//         ":" +
//         "\"" +
//         doctorData["DoctorIDP"] +
//         "\"" +
//         /*"," +
//         "\"" +
//         "FirstName" +
//         "\"" +
//         ":" +
//         "\"" +
//         firstName +
//         "\"" +
//         "," +
//         "\"" +
//         "LastName" +
//         "\"" +
//         ":" +
//         "\"" +
//         lastName +
//         "\"" +
//         "," +
//         "\"" +
//         "BindFlag" +
//         "\"" +
//         ":" +
//         "\"" +
//         bindFlag +
//         "\"" +*/
//         "}";
//
//     debugPrint(jsonStr);
//
//     String encodedJSONStr = encodeBase64(jsonStr);
//     var response = await apiHelper.callApiWithHeadersAndBody(
//       url: loginUrl,
//       //Uri.parse(loginUrl),
//       headers: {
//         "u": patientUniqueKey,
//         "type": userType,
//       },
//       body: {"getjson": encodedJSONStr},
//     );
//     //var resBody = json.decode(response.body);
//     debugPrint(response.body.toString());
//     final jsonResponse = json.decode(response.body.toString());
//     ResponseModel model = ResponseModel.fromJSON(jsonResponse);
//     pr.hide();
//
//     if (model.status == "OK") {
//       /*final snackBar = SnackBar(
//         backgroundColor: Colors.green,
//         content: Text(model.message),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
//       showBindRequestSentDialog(
//         (doctorData["FirstName"].trim() + " " + doctorData["LastName"].trim())
//             .trim(),
//       );
//       getPatientProfileDetails();
//     } else if (model.status == "ERROR") {
//       final snackBar = SnackBar(
//         backgroundColor: Colors.red,
//         content: Text(model.message),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     }
//   }
//
//   void showBindRequestSentDialog(String patientName) {
//     showDialog(
//         context: context,
//         barrierDismissible: false,
//         // user must tap button for close dialog!
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(
//               "Request has been sent to $patientName to connect with you. You will be connected once doctor accepts your request.",
//               style: TextStyle(
//                 fontSize: SizeConfig.blockSizeHorizontal * 3.8,
//                 color: Colors.black,
//               ),
//             ),
//             actions: <Widget>[
//               TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: Text(
//                     "Okay",
//                     style: TextStyle(
//                       color: Colors.green,
//                     ),
//                   )),
//             ],
//           );
//         });
//   }
// }
//
//
//
//
