// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:swasthyasetu/app_screens/patient_doctor_permissions_screen.dart';
// import 'package:swasthyasetu/global/SizeConfig.dart';
// import 'package:swasthyasetu/global/utils.dart';
// import 'package:swasthyasetu/podo/response_main_model.dart';
// import 'package:swasthyasetu/utils/color.dart';
// import 'package:swasthyasetu/utils/progress_dialog.dart';
// import 'package:swasthyasetu/widgets/extensions.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import 'chat_screen.dart';
// import 'fullscreen_image.dart';
// import 'make_a_payment_to_doctor.dart';
//
// class LaboratoryFullDetailsScreen extends StatefulWidget {
//   Map<String, String> laboratoryData;
//   String patientIDP, from;
//
//   LaboratoryFullDetailsScreen(this.laboratoryData, this.patientIDP,
//       {this.from = "laboratoryList"});
//
//   @override
//   State<StatefulWidget> createState() {
//     return LaboratoryFullDetailsScreenState();
//   }
// }
//
// class LaboratoryFullDetailsScreenState extends State<LaboratoryFullDetailsScreen> {
//   final String urlFetchDoctorProfileDetails = "${baseURL}/providerIDP.php";
//   String aboutDoctor = "",
//       clinicName = "",
//       clinicAddress = "",
//       clinicContactNumber = "",
//       whatsAppNo = "",
//       emailID = "";
//
//   @override
//   void initState() {
//     super.initState();
//     print('Doctor Full Details');
//     print(widget.laboratoryData["HealthCareProviderIDP"]);
//     if(widget.laboratoryData["HealthCareProviderIDP"]!=null)
//       getDoctorProfileDetails(context);
//     // if (widget.from == "doctorList") {
//     //   getDuePayment(context, widget.doctorData);
//     //   getPermissionsData(context);
//     // }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     return Scaffold(
//       backgroundColor: Color(0xFFf9faff),
//       appBar: AppBar(
//         title: Text("Profile", style: TextStyle(color: colorBlack)),
//         iconTheme: IconThemeData(
//             color: colorBlack, size: SizeConfig.blockSizeVertical !* 2.5),
//         backgroundColor: Color(0xFFf9faff),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Builder(builder: (context) {
//         return ListView(
//           shrinkWrap: true,
//           children: [
//             Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey,
//                     blurRadius: 1.0,
//                   ),
//                 ],
//                 color: colorWhite,
//                 borderRadius: BorderRadius.all(Radius.circular(
//                     20.0) //                 <--- border radius here
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: <Widget>[
//                       InkWell(
//                           onTap: () {
//                             Navigator.of(context)
//                                 .push(MaterialPageRoute(builder: (context) {
//                               return FullScreenImage(
//                                 "$doctorImgUrl${widget.laboratoryData["DoctorImage"]}",
//                                 heroTag:
//                                 "fullImg_$doctorImgUrl${widget.laboratoryData["DoctorImage"]}_${widget.laboratoryData['DoctorIDP']}",
//                                 showPlaceholder: !isImageNotNullAndBlank(),
//                               );
//                             }));
//                           },
//                           child: CircleAvatar(
//                             radius: 50,
//                             backgroundColor: colorBlueDark,
//                             child: CircleAvatar(
//                               backgroundImage: isImageNotNullAndBlank1(),
//                               radius: 48,
//                             ),
//                           )),
//                       SizedBox(
//                         width: SizeConfig.blockSizeHorizontal !* 3,
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Text(
//                             ("DR." +
//                                 widget.laboratoryData["FirstName"]!.trim() +
//                                 " " +
//                                 widget.laboratoryData["LastName"]!.trim())
//                                 .trim(),
//                             textAlign: TextAlign.left,
//                             style: TextStyle(
//                               fontSize: SizeConfig.blockSizeHorizontal !* 4.2,
//                               fontWeight: FontWeight.w500,
//                               color: colorBlueDark,
//                             ),
//                           ),
//                           SizedBox(
//                             height: SizeConfig.blockSizeVertical !* 0.5,
//                           ),
//                           Text(
//                             widget.laboratoryData["Specility"]!,
//                             textAlign: TextAlign.left,
//                             style: TextStyle(
//                               fontSize: SizeConfig.blockSizeHorizontal !* 3.3,
//                               fontWeight: FontWeight.w400,
//                               color: colorBlueDark,
//                             ),
//                           ),
//                           SizedBox(
//                             height: SizeConfig.blockSizeVertical !* 0.5,
//                           ),
//                           Text(
//                             widget.laboratoryData["CityName"]!,
//                             textAlign: TextAlign.left,
//                             style: TextStyle(
//                               fontSize: SizeConfig.blockSizeHorizontal !* 3.3,
//                               fontWeight: FontWeight.w400,
//                               color: colorBlueDark,
//                             ),
//                           ),
//                           SizedBox(
//                             height: SizeConfig.blockSizeVertical !* 1.3,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ).expanded(),
//                 ],
//               ),
//             ).pS(
//               horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
//               vertical: SizeConfig.blockSizeHorizontal !* 4.0,
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: widget.from == "doctorList"
//                       ? InkWell(
//                     onTap: () {
//                       showConfirmationDialogForUnbind(
//                         context,
//                         "0",
//                         widget.laboratoryData,
//                       );
//                     },
//                     child: Card(
//                       elevation: 0,
//                       shadowColor: Colors.grey,
//                       color: Color(0xffffefef),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(
//                               10.0) //                 <--- border radius here
//                           ),
//                           side: BorderSide(
//                               color: Color(0xffdcaead), width: 1.5)),
//                       margin: EdgeInsets.only(
//                         left: SizeConfig.blockSizeHorizontal !* 3.0,
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.all(
//                           SizeConfig.blockSizeHorizontal !* 3.0,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(
//                               "images/v-2-icn-remove-doctor.png",
//                               width: SizeConfig.blockSizeHorizontal !* 9.0,
//                             ),
//                             SizedBox(
//                               width: SizeConfig.blockSizeHorizontal !* 4.0,
//                             ),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Remove",
//                                     style: TextStyle(
//                                       fontSize:
//                                       SizeConfig.blockSizeHorizontal !*
//                                           4.2,
//                                       fontWeight: FontWeight.w400,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: SizeConfig.blockSizeVertical !*
//                                         0.4,
//                                   ),
//                                   Text(
//                                     "Doctor",
//                                     style: TextStyle(
//                                       fontSize:
//                                       SizeConfig.blockSizeHorizontal !*
//                                           4.2,
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   )
//                       : InkWell(
//                     onTap: () {
//                       bindRequestToDoctor(widget.laboratoryData);
//                     },
//                     child: Card(
//                       elevation: 0,
//                       shadowColor: Colors.grey,
//                       color: colorBlueDark,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(
//                               10.0) //                 <--- border radius here
//                           ),
//                           side: BorderSide(
//                               color: colorBlueDark, width: 1.5)),
//                       margin: EdgeInsets.only(
//                         left: SizeConfig.blockSizeHorizontal !* 3.0,
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.all(
//                           SizeConfig.blockSizeHorizontal !* 3.0,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(
//                               "images/ic_imp_links.png",
//                               width: SizeConfig.blockSizeHorizontal !* 9.0,
//                               color: colorWhite,
//                             ),
//                             SizedBox(
//                               width: SizeConfig.blockSizeHorizontal !* 4.0,
//                             ),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Connect to",
//                                     style: TextStyle(
//                                         fontSize: SizeConfig
//                                             .blockSizeHorizontal !*
//                                             4.2,
//                                         fontWeight: FontWeight.w400,
//                                         color: colorWhite),
//                                   ),
//                                   SizedBox(
//                                     height: SizeConfig.blockSizeVertical !*
//                                         0.4,
//                                   ),
//                                   Text(
//                                     "Doctor",
//                                     style: TextStyle(
//                                         fontSize: SizeConfig
//                                             .blockSizeHorizontal !*
//                                             4.2,
//                                         fontWeight: FontWeight.w700,
//                                         color: colorWhite),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       Navigator.of(context)
//                           .push(MaterialPageRoute(builder: (context) {
//                         return MakeAPaymentToDoctor(
//                             widget.laboratoryData['DoctorIDP']!,
//                             widget.laboratoryData["DoctorImage"]!,
//                             (widget.laboratoryData["FirstName"]!.trim() +
//                                 " " +
//                                 widget.laboratoryData["LastName"]!.trim())
//                                 .trim(),
//                             widget.laboratoryData["Specility"]!,
//                             widget.laboratoryData["CityName"]!);
//                       }));
//                       //startPayment(1, widget.doctorData);
//                     },
//                     child: Card(
//                       elevation: 0,
//                       shadowColor: Colors.grey,
//                       color: colorBlueDark,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(
//                               10.0) //                 <--- border radius here
//                           ),
//                           side: BorderSide(color: colorBlueDark, width: 1.5)),
//                       margin: EdgeInsets.only(
//                         left: SizeConfig.blockSizeHorizontal !* 3.0,
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.all(
//                           SizeConfig.blockSizeHorizontal !* 3.0,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image(
//                               image: AssetImage(
//                                 "images/v-2-icn-make-payment.png",
//                               ),
//                               height: SizeConfig.blockSizeHorizontal !* 9,
//                               width: SizeConfig.blockSizeHorizontal !* 9,
//                             ),
//                             SizedBox(
//                               width: SizeConfig.blockSizeHorizontal !* 4.0,
//                             ),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Make a",
//                                     style: TextStyle(
//                                         fontSize:
//                                         SizeConfig.blockSizeHorizontal !*
//                                             4.2,
//                                         fontWeight: FontWeight.w400,
//                                         color: colorWhite),
//                                   ),
//                                   SizedBox(
//                                     height: SizeConfig.blockSizeVertical !* 0.4,
//                                   ),
//                                   Text(
//                                     "Payment",
//                                     style: TextStyle(
//                                         fontSize:
//                                         SizeConfig.blockSizeHorizontal !*
//                                             4.2,
//                                         fontWeight: FontWeight.w700,
//                                         color: colorWhite),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ).paddingOnly(
//               right: SizeConfig.blockSizeHorizontal !* 3.0,
//             ),
//             Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: colorWhite,
//                 borderRadius: BorderRadius.all(Radius.circular(
//                     10.0) //                 <--- border radius here
//                 ),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "About Doctor",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: SizeConfig.blockSizeHorizontal !* 5.3,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ).pO(
//                     bottom: SizeConfig.blockSizeHorizontal !* 2.0,
//                   ),
//                   Text(
//                     aboutDoctor != "" ? aboutDoctor : "-",
//                     style: TextStyle(
//                       color: Colors.grey[500],
//                       fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//                 .pS(
//               horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
//             )
//                 .pO(top: SizeConfig.blockSizeHorizontal !* 4.0),
//             Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: colorWhite,
//                 borderRadius: BorderRadius.all(Radius.circular(
//                     10.0) //                 <--- border radius here
//                 ),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Clinic Details",
//                     style: TextStyle(
//                       color: colorBlack,
//                       fontSize: SizeConfig.blockSizeHorizontal !* 5.3,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     ("DR." +
//                         widget.laboratoryData["FirstName"]!.trim() +
//                         " " +
//                         widget.laboratoryData["LastName"]!.trim())
//                         .trim(),
//                     textAlign: TextAlign.left,
//                     style: TextStyle(
//                       fontSize: SizeConfig.blockSizeHorizontal !* 4.2,
//                       fontWeight: FontWeight.w400,
//                       color: colorBlack,
//                     ),
//                   ),
//                   new Divider(
//                     thickness: 2,
//                     color: Color(0xfff0f0f0),
//                   ),
//                   Text(
//                     "Address",
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 5,
//                   ),
//                   Text(
//                     clinicAddress,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
//                     ),
//                   ),
//                   new Divider(
//                     thickness: 2,
//                     color: Color(0xfff0f0f0),
//                   ),
//                   Text(
//                     "Phone",
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 5,
//                   ),
//                   InkWell(
//                       onTap: () {
//                         launchURL('tel:91$clinicContactNumber');
//                       },
//                       child: Text(
//                         clinicContactNumber,
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
//                         ),
//                       )),
//                   new Divider(
//                     thickness: 2,
//                     color: Color(0xfff0f0f0),
//                   ),
//                   whatsAppNo != ""
//                       ? Text(
//                     "Whatsapp",
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
//                     ),
//                   )
//                       : Container(),
//                   whatsAppNo != ""
//                       ? SizedBox(
//                     height: 5,
//                   )
//                       : Container(),
//                   whatsAppNo != ""
//                       ? InkWell(
//                       onTap: () async {
//                         if (await canLaunch(
//                             "whatsapp://send?phone=91$whatsAppNo&text=")) {
//                           launchURL(
//                               "whatsapp://send?phone=91$whatsAppNo&text=");
//                         } else {
//                           Fluttertoast.showToast(
//                               msg: "You need to Install Whatsapp!",
//                               toastLength: Toast.LENGTH_SHORT,
//                               gravity: ToastGravity.BOTTOM,
//                               timeInSecForIosWeb: 3,
//                               backgroundColor: Colors.red,
//                               textColor: Colors.white,
//                               fontSize: 16.0);
//                         }
//                       },
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             whatsAppNo,
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize:
//                               SizeConfig.blockSizeHorizontal !* 3.8,
//                             ),
//                           ),
//                         ],
//                       ))
//                       : Container(),
//                   whatsAppNo != ""
//                       ? new Divider(
//                     thickness: 2,
//                     color: Color(0xfff0f0f0),
//                   )
//                       : Container(),
//                   Text(
//                     "Email",
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 5,
//                   ),
//                   InkWell(
//                       onTap: () {
//                         launchURL('mailto:$emailID?subject=&body=');
//                       },
//                       child: Text(
//                         emailID,
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
//                         ),
//                       )),
//                 ],
//               ),
//             ).pS(
//               horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
//               vertical: SizeConfig.blockSizeHorizontal !* 4.0,
//             ),
//             widget.from == "doctorList"
//                 ? Column(
//               children: [
//                 widget.laboratoryData.containsKey("DueAmount") &&
//                     double.parse(widget.laboratoryData["DueAmount"]!) > 0
//                     ? Container(
//                   padding: EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: colorWhite,
//                     borderRadius: BorderRadius.all(Radius.circular(
//                         10.0) //                 <--- border radius here
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Image.asset(
//                         "images/ic_payment_due.png",
//                         width:
//                         SizeConfig.blockSizeHorizontal !* 12.0,
//                         fit: BoxFit.fill,
//                       ).paddingOnly(
//                         right: SizeConfig.blockSizeHorizontal !* 5.0,
//                       ),
//                       Column(
//                         children: [
//                           Text(
//                             "Payment Due",
//                             style: TextStyle(
//                               color: Colors.grey[500],
//                               fontSize:
//                               SizeConfig.blockSizeHorizontal !*
//                                   4.5,
//                               letterSpacing: 1.4,
//                             ),
//                           ).pO(
//                             bottom:
//                             SizeConfig.blockSizeVertical !* 1.0,
//                           ),
//                           Text(
//                             "\u20B9${widget.laboratoryData["DueAmount"]}",
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize:
//                               SizeConfig.blockSizeHorizontal !*
//                                   6.5,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1.8,
//                             ),
//                           ),
//                         ],
//                       ).pO(
//                           right:
//                           SizeConfig.blockSizeHorizontal !* 6.0),
//                       MaterialButton(
//                         onPressed: () {
//                           startPayment(0, widget.laboratoryData);
//                         },
//                         color: colorBlueDark,
//                         child: Text(
//                           "Pay Now",
//                           style: TextStyle(
//                             color: Colors.white,
//                             letterSpacing: 1.3,
//                             fontSize:
//                             SizeConfig.blockSizeHorizontal !*
//                                 4.2,
//                           ),
//                         ),
//                       )
//                     ],
//                   ).pO(
//                     left: SizeConfig.blockSizeHorizontal !* 3.0,
//                     bottom: SizeConfig.blockSizeVertical !* 4.0,
//                     top: SizeConfig.blockSizeVertical !* 3.0,
//                   ),
//                 ).pS(
//                   horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
//                 )
//                     : Container(),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: InkWell(
//                         onTap: () {
//                           String patientIDP =
//                           widget.laboratoryData['DoctorIDP']!;
//                           String patientName =
//                               widget.laboratoryData['FirstName']!.trim() +
//                                   " " +
//                                   widget.laboratoryData['LastName']!.trim();
//                           String doctorImage =
//                               "$doctorImgUrl${widget.laboratoryData["DoctorImage"]}";
//                           Get.to(() => ChatScreen(
//                             patientIDP: patientIDP,
//                             patientName: patientName,
//                             patientImage: doctorImage,
//                             heroTag:
//                             "selectedDoctor_${widget.laboratoryData['DoctorIDP']}",
//                           ));
//                         },
//                         child: Card(
//                           elevation: 0,
//                           shadowColor: Colors.grey,
//                           color: colorBlueDark,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.all(
//                                   Radius.circular(
//                                       10.0) //                 <--- border radius here
//                               ),
//                               side: BorderSide(
//                                   color: colorBlueDark, width: 1.5)),
//                           margin: EdgeInsets.only(
//                             left: SizeConfig.blockSizeHorizontal !* 3.0,
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.all(
//                               SizeConfig.blockSizeHorizontal !* 3.0,
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Image(
//                                   image: AssetImage(
//                                     "images/v-2-icn-chate.png",
//                                   ),
//                                   height:
//                                   SizeConfig.blockSizeHorizontal !* 9,
//                                   width:
//                                   SizeConfig.blockSizeHorizontal !* 9,
//                                 ),
//                                 SizedBox(
//                                   width: SizeConfig.blockSizeHorizontal !*
//                                       4.0,
//                                 ),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Chat with",
//                                         style: TextStyle(
//                                             fontSize: SizeConfig
//                                                 .blockSizeHorizontal !*
//                                                 4.2,
//                                             fontWeight: FontWeight.w400,
//                                             color: colorWhite),
//                                       ),
//                                       SizedBox(
//                                         height:
//                                         SizeConfig.blockSizeVertical !*
//                                             0.4,
//                                       ),
//                                       Text(
//                                         "Doctor",
//                                         style: TextStyle(
//                                             fontSize: SizeConfig
//                                                 .blockSizeHorizontal !*
//                                                 4.2,
//                                             fontWeight: FontWeight.w700,
//                                             color: colorWhite),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: SizeConfig.blockSizeHorizontal !* 2.0,
//                     ),
//                     Expanded(
//                       child: InkWell(
//                         onTap: () async {
//                           Get.to(() => PatientDoctorPermissionScreen(
//                             widget.laboratoryData["DoctorIDP"]!,
//                             widget.laboratoryData[
//                             "HealthRecordsDisplayStatus"]!,
//                             widget.laboratoryData[
//                             "ConsultationDisplayStatus"]!,
//                           ))!.then((value) {
//                             if (value != null && value == 1) {
//                               getDoctorProfileDetails(context);
//                               if (widget.from == "doctorList") {
//                                 getDuePayment(context, widget.laboratoryData);
//                                 getPermissionsData(context);
//                               }
//                             }
//                           });
//                         },
//                         child: Card(
//                           elevation: 0,
//                           shadowColor: Colors.grey,
//                           color: colorBlueDark,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.all(
//                                   Radius.circular(
//                                       10.0) //                 <--- border radius here
//                               ),
//                               side: BorderSide(
//                                   color: colorBlueDark, width: 1.5)),
//                           margin: EdgeInsets.only(
//                             right: SizeConfig.blockSizeHorizontal !* 3.0,
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.all(
//                               SizeConfig.blockSizeHorizontal !* 3.0,
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Image(
//                                   image: AssetImage(
//                                     "images/v-2-icn-setup-permission.png",
//                                   ),
//                                   height:
//                                   SizeConfig.blockSizeHorizontal !* 9,
//                                   width:
//                                   SizeConfig.blockSizeHorizontal !* 9,
//                                 ),
//                                 SizedBox(
//                                   width: SizeConfig.blockSizeHorizontal !*
//                                       2.0,
//                                 ),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Set up",
//                                         style: TextStyle(
//                                             fontSize: SizeConfig
//                                                 .blockSizeHorizontal !*
//                                                 4.2,
//                                             fontWeight: FontWeight.w400,
//                                             color: colorWhite),
//                                       ),
//                                       SizedBox(
//                                         height:
//                                         SizeConfig.blockSizeVertical !*
//                                             0.4,
//                                       ),
//                                       Text(
//                                         "Permissions",
//                                         style: TextStyle(
//                                             fontSize: SizeConfig
//                                                 .blockSizeHorizontal !*
//                                                 4.2,
//                                             fontWeight: FontWeight.w700,
//                                             color: colorWhite),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ).pO(
//                   top: SizeConfig.blockSizeVertical !* 1.5,
//                   bottom: SizeConfig.blockSizeVertical !* 1.0,
//                 ),
//               ],
//             )
//                 : Container(),
//           ],
//         );
//       }),
//     );
//   }
//
//   void bindRequestToDoctor(
//       /*String bindFlag,*/
//       Map<String, String> doctorData) async {
//     //String loginUrl = "${baseURL}patientBindDoctor.php";
//     String loginUrl = "${baseURL}patientBindRequesttoDoctor.php";
//     ProgressDialog? pr;
//     Future.delayed(Duration.zero, () {
//       pr = ProgressDialog(context);
//       pr!.show();
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
//         doctorData["DoctorIDP"]! +
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
//     pr!.hide();
//
//     if (model.status == "OK") {
//       /*final snackBar = SnackBar(
//         backgroundColor: Colors.green,
//         content: Text(model.message),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
//       showBindRequestSentDialog(
//         (doctorData["FirstName"]!.trim() + " " + doctorData["LastName"]!.trim())
//             .trim(),
//       );
//       getDoctorProfileDetails(context);
//     } else if (model.status == "ERROR") {
//       final snackBar = SnackBar(
//         backgroundColor: Colors.red,
//         content: Text(model.message!),
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
//                 fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
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
//
//   isImageNotNullAndBlank() {
//     return (widget.laboratoryData["DoctorImage"] != "" &&
//         widget.laboratoryData["DoctorImage"] != null &&
//         widget.laboratoryData["DoctorImage"] != "null");
//   }
//
//   void launchURL(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }
//
//   showConfirmationDialogForUnbind(
//       BuildContext mContext, String bindFlag, Map<String, String> doctorData) {
//     var title = "Are you sure to remove this doctor?";
//     var subTitle =
//         "By doing this the selected doctor will be removed from your list and you need to bind this doctor again.";
//     showDialog(
//         context: context,
//         barrierDismissible: false,
//         // user must tap button for close dialog!
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(title),
//             content: Text(subTitle),
//             actions: <Widget>[
//               TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: Text("No")),
//               TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     bindUnbindDoctor(mContext, bindFlag, doctorData);
//                   },
//                   child: Text("Yes"))
//             ],
//           );
//         });
//   }
//
//   void bindUnbindDoctor(BuildContext mContext, String bindFlag,
//       Map<String, String> doctorData) async {
//     String loginUrl = "${baseURL}patientBindDoctor.php";
//     ProgressDialog? pr;
//     Future.delayed(Duration.zero, () {
//       pr = ProgressDialog(context);
//       pr!.show();
//     });
//     String patientUniqueKey = await getPatientUniqueKey();
//     String userType = await getUserType();
//     String patientIDP = await getPatientOrDoctorIDP();
//     debugPrint("Key and type");
//     debugPrint(patientUniqueKey);
//     debugPrint(userType);
//     String jsonStr = "{" +
//         "\"" +
//         "PatientIDP" +
//         "\"" +
//         ":" +
//         "\"" +
//         patientIDP +
//         "\"" +
//         "," +
//         "\"" +
//         "DoctorIDP" +
//         "\"" +
//         ":" +
//         "\"" +
//         doctorData["DoctorIDP"]! +
//         "\"" +
//         "," +
//         "\"" +
//         "FirstName" +
//         "\"" +
//         ":" +
//         "\"" +
//         "" +
//         "\"" +
//         "," +
//         "\"" +
//         "LastName" +
//         "\"" +
//         ":" +
//         "\"" +
//         "" +
//         "\"" +
//         "," +
//         "\"" +
//         "BindFlag" +
//         "\"" +
//         ":" +
//         "\"" +
//         bindFlag +
//         "\"" +
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
//     pr!.hide();
//
//     if (model.status == "OK") {
//       final snackBar = SnackBar(
//         backgroundColor: Colors.green,
//         content: Text("Doctor Removed Successfully."),
//       );
//       ScaffoldMessenger.of(mContext).showSnackBar(snackBar);
//       Future.delayed(Duration(seconds: 1), () {
//         Navigator.of(mContext).pop(1);
//       });
//       //getPatientProfileDetails();
//     } else {
//       final snackBar = SnackBar(
//         backgroundColor: Colors.red,
//         content: Text(model.message!),
//       );
//       ScaffoldMessenger.of(mContext).showSnackBar(snackBar);
//       Future.delayed(Duration(seconds: 1), () {
//         Navigator.of(mContext).pop(0);
//       });
//     }
//   }
//
//   void getDoctorProfileDetails(BuildContext context) async {
//     ProgressDialog pr = ProgressDialog(context);
//     Future.delayed(Duration.zero, () {
//       pr.show();
//     });
//     String patientUniqueKey = await getPatientUniqueKey();
//     String userType = await getUserType();
//     String patientIDP = await getPatientOrDoctorIDP();
//     debugPrint("Key and type");
//     debugPrint(patientUniqueKey);
//     debugPrint(userType);
//     String jsonStr = "{" +
//         "\"" +
//         "HealthCareProviderIDP" +
//         "\"" +
//         ":" +
//         "\"" +
//         widget.laboratoryData["HealthCareProviderIDP"]! +
//         "\"" +
//         "}";
//
//     debugPrint(jsonStr);
//
//     String encodedJSONStr = encodeBase64(jsonStr);
//     //listIcon = new List();
//     var response = await apiHelper.callApiWithHeadersAndBody(
//       url: urlFetchDoctorProfileDetails,
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
//     if (model.status == "OK") {
//       var data = jsonResponse['Data'];
//       var strData = decodeBase64(data);
//       debugPrint("Decoded Data Array : " + strData);
//       final jsonData = json.decode(strData);
//       aboutDoctor = jsonData[0]['About'];
//       clinicName = jsonData[0]['BusinessName'];
//       clinicAddress = jsonData[0]['BusinessAddress'];
//       clinicContactNumber = jsonData[0]['BusinessMobileNo'];
//       whatsAppNo = jsonData[0]['WhatsappNo'];
//       emailID = jsonData[0]['EmailID'];
//       /*businessAddress = jsonData[0]['BusinessAddress'] != ""
//           ? jsonData[0]['BusinessAddress']
//           : "-";*/
//       /*latitude = jsonData[0]['Latitude'];
//       longitude = jsonData[0]['Longitude'];*/
//       setState(() {});
//     } else {
//       /*final snackBar = SnackBar(
//         backgroundColor: Colors.red,
//         content: Text(model.message),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
//     }
//   }
//
//   void getPermissionsData(BuildContext context) async {
//     String loginUrl = "${baseURL}patientDoctorRecordsPermission.php";
//     //listIcon = new List();
//     String patientUniqueKey = await getPatientUniqueKey();
//     String userType = await getUserType();
//     String patientIDP = await getPatientOrDoctorIDP();
//     debugPrint("Key and type");
//     debugPrint(patientUniqueKey);
//     debugPrint(userType);
//     String jsonStr = "{" +
//         "\"" +
//         "PatientIDP" +
//         "\"" +
//         ":" +
//         "\"" +
//         patientIDP +
//         "\"" +
//         "," +
//         "\"" +
//         "DoctorIDP" +
//         "\"" +
//         ":" +
//         "\"" +
//         widget.laboratoryData["DoctorIDP"]! +
//         "\"" +
//         "}";
//
//     debugPrint(jsonStr);
//
//     String encodedJSONStr = encodeBase64(jsonStr);
//     var response = await apiHelper.callApiWithHeadersAndBody(
//       url: loginUrl,
//       headers: {
//         "u": patientUniqueKey,
//         "type": userType,
//       },
//       body: {"getjson": encodedJSONStr},
//     );
//     debugPrint(response.body.toString());
//     final jsonResponse = json.decode(response.body.toString());
//     ResponseModel model = ResponseModel.fromJSON(jsonResponse);
//
//     if (model.status == "OK") {
//       var data = jsonResponse['Data'];
//       var strData = decodeBase64(data);
//       debugPrint("Decoded Data Array : " + strData);
//       final jsonData = json.decode(strData);
//       widget.laboratoryData["HealthRecordsDisplayStatus"] =
//       jsonData[0]['HealthRecordsDisplayStatus'];
//       widget.laboratoryData["ConsultationDisplayStatus"] =
//       jsonData[0]['ConsultationDisplayStatus'];
//       /*Get.snackbar(
//         "Success",
//         model.message,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//       Future.delayed(Duration(seconds: 1), () {
//         Get.back();
//         Navigator.of(context).pop(1);
//       });*/
//     } else {
//       Get.snackbar(
//         "Error",
//         model.message!,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   void getDuePayment(
//       BuildContext context, Map<String, String> doctorData) async {
//     String loginUrl = "${baseURL}patientDuePayment.php";
//     /*ProgressDialog pr;
//     Future.delayed(Duration.zero, () {
//       pr = ProgressDialog(context);
//       pr.show();
//     });*/
//     String patientUniqueKey = await getPatientUniqueKey();
//     String userType = await getUserType();
//     String patientIDP = await getPatientOrDoctorIDP();
//     debugPrint("Key and type");
//     debugPrint(patientUniqueKey);
//     debugPrint(userType);
//     String jsonStr = "{" +
//         "\"" +
//         "PatientIDP" +
//         "\"" +
//         ":" +
//         "\"" +
//         patientIDP +
//         "\"" +
//         "," +
//         "\"" +
//         "DoctorIDP" +
//         "\"" +
//         ":" +
//         "\"" +
//         doctorData["DoctorIDP"]! +
//         "\"" +
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
//     //pr.hide();
//     if (model.status == "OK") {
//       var data = jsonResponse['Data'];
//       var strData = decodeBase64(data);
//       debugPrint("Decoded Data Investigation Masters list : " + strData);
//       final jsonData = json.decode(strData);
//       String dueAmount = jsonData[0]['DueAmount'];
//       widget.laboratoryData["DueAmount"] = dueAmount;
//       //showPayNowBottomSheet(dueAmount, doctorData);
//     }
//   }
//
//   String encodeBase64(String text) {
//     var bytes = utf8.encode(text);
//     return base64.encode(bytes);
//   }
//
//   String decodeBase64(String text) {
//     var bytes = base64.decode(text);
//     return String.fromCharCodes(bytes);
//   }
//
//   void startPayment(int type, Map<String, String> doctorData) async {
//     String patientIDP = await getPatientOrDoctorIDP();
//     if (type == 0) {
//       goToWebview(context, "",
//           "${baseURL}paymentgatewayPayDuetoDoctor.php?appointid=-&amount=${doctorData["DueAmount"]}&idp=${doctorData["DoctorIDP"]}&idppt=$patientIDP");
//     } else if (type == 1) {
//       goToWebview(context, "",
//           "${baseURL}paymentgatewayPaytoDoctorDirect.php?idp=${doctorData["DoctorIDP"]}&idppt=$patientIDP");
//     }
//   }
//
//   goToWebview(BuildContext context, String iconName, String webView) {
//     // PaymentWebViewController paymentWebViewController =
//     //     Get.put(PaymentWebViewController());
//     // String webViewUrl = Uri.encodeFull(webView);
//     // paymentWebViewController.url.value = webViewUrl;
//     // debugPrint("encoded url :- $webViewUrl");
//     //
//     // if (webView != "") {
//     //   final flutterWebViewPlugin = FlutterWebviewPlugin();
//     //   flutterWebViewPlugin.onUrlChanged.listen((url) {
//     //     debugPrint(url);
//     //     paymentWebViewController.url.value = url;
//     //   });
//     //   flutterWebViewPlugin.onDestroy.listen((_) {
//     //     if (Navigator.canPop(context)) {
//     //       Navigator.of(context).pop();
//     //     }
//     //   });
//     //   Navigator.push(context, MaterialPageRoute(builder: (mContext) {
//     //     return new MaterialApp(
//     //       debugShowCheckedModeBanner: false,
//     //       theme:
//     //           ThemeData(fontFamily: "Ubuntu", primaryColor: Color(0xFF06A759)),
//     //       routes: {
//     //         "/": (_) => Obx(() => WebviewScaffold(
//     //               withLocalStorage: true,
//     //               withJavascript: true,
//     //               url: webViewUrl,
//     //               appBar:
//     //                   paymentWebViewController.url.value.contains(
//     //                               "swasthyasetu.com/ws/failurePayDuetoDoctor.php") ||
//     //                           paymentWebViewController.url.value.contains(
//     //                               "swasthyasetu.com/ws/successPayDuetoDoctor.php") ||
//     //                           paymentWebViewController.url.value.contains(
//     //                               "swasthyasetu.com/ws/paymentgatewayPaytoDoctorDirect.php")
//     //                       ? AppBar(
//     //                           backgroundColor: Colors.white,
//     //                           title: Text(iconName),
//     //                           leading: IconButton(
//     //                               icon: Icon(
//     //                                 Platform.isAndroid
//     //                                     ? Icons.arrow_back
//     //                                     : Icons.arrow_back_ios,
//     //                                 color: Colors.black,
//     //                                 size: SizeConfig.blockSizeHorizontal * 8.0,
//     //                               ),
//     //                               onPressed: () {
//     //                                 if (paymentWebViewController.url.value.contains(
//     //                                     "swasthyasetu.com/ws/failurePayDuetoDoctor.php"))
//     //                                   Navigator.of(context).pop();
//     //                                 else if (paymentWebViewController.url.value
//     //                                     .contains(
//     //                                         "swasthyasetu.com/ws/successPayDuetoDoctor.php")) {
//     //                                   Navigator.of(context).pop(1);
//     //                                   //Navigator.of(context).pop();
//     //                                 } else if (paymentWebViewController
//     //                                     .url.value
//     //                                     .contains(
//     //                                         "swasthyasetu.com/ws/paymentgatewayPaytoDoctorDirect.php")) {
//     //                                   Navigator.of(context).pop();
//     //                                   //Navigator.of(context).pop();
//     //                                 }
//     //                                 /*Navigator.pushAndRemoveUntil(
//     //                               context,
//     //                               MaterialPageRoute(
//     //                                   builder: (context) =>
//     //                                       CheckExpiryBlankScreen(
//     //                                           "", "coupon", false, null)),
//     //                               (Route<dynamic> route) => false);*/
//     //                               }),
//     //                           iconTheme: IconThemeData(
//     //                               color: Colors.white,
//     //                               size: SizeConfig.blockSizeVertical * 2.2),
//     //                           textTheme: TextTheme(
//     //                               subtitle1: TextStyle(
//     //                                   color: Colors.white,
//     //                                   fontFamily: "Ubuntu",
//     //                                   fontSize:
//     //                                       SizeConfig.blockSizeVertical * 2.3)),
//     //                         )
//     //                       : PreferredSize(
//     //                           child: Container(),
//     //                           preferredSize: Size(SizeConfig.screenWidth, 0),
//     //                         ),
//     //             )),
//     //       },
//     //     );
//     //   })).then((value) {
//     //     if (value != null && value == 1) {
//     //       getDoctorProfileDetails(context);
//     //       if (widget.from == "doctorList") {
//     //         getDuePayment(context, widget.doctorData);
//     //         getPermissionsData(context);
//     //       }
//     //     }
//     //   });
//     // }
//   }
//
//   isImageNotNullAndBlank1() {
//     isImageNotNullAndBlank()
//         ? NetworkImage(
//         "$doctorImgUrl${widget.laboratoryData["DoctorImage"]}")
//         : AssetImage(
//         "images/ic_user_placeholder.png");
//   }
// }
