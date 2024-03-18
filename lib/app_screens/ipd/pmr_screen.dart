// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:swasthyasetu/app_screens/ipd/indoor_list_icon_screen.dart';
// import 'package:swasthyasetu/app_screens/ipd/pmr_table_screen.dart';
// import 'package:swasthyasetu/global/SizeConfig.dart';
// import 'package:swasthyasetu/global/utils.dart';
// import 'package:swasthyasetu/podo/model_pmr_send.dart';
// import 'package:swasthyasetu/podo/response_main_model.dart';
// import 'package:swasthyasetu/utils/color.dart';
// import 'package:swasthyasetu/utils/progress_dialog.dart';
//
// import '../../podo/model_pmr.dart';
//
// List<String> listPMR = [];
// List<MedicineFormData> listPMRSend = [];
// List<int> listPMRNumber = [];
// List<String> listPMRSchedule = [];
// // List<int> listPMRSchedule1 = [];
//
//
//
// ScrollController _scrollController = new ScrollController();
//
// TextEditingController SelectPMRController = TextEditingController();
// TextEditingController pmrIDPController = TextEditingController();
// TextEditingController QtyController = TextEditingController();
// TextEditingController RemarksController = TextEditingController();
//
//
// class PMRScreen extends StatefulWidget {
//
//
//   final String patientindooridp;
//   final String PatientIDP;
//   final String doctoridp;
//   final String firstname;
//   final String lastName;
//
//   PMRScreen({
//     required this.patientindooridp,
//     required this.PatientIDP,
//     required this.doctoridp,
//     required this.firstname,
//     required this.lastName,
//   });
//
//   @override
//   State<PMRScreen> createState() => _PMRScreenState();
// }
//
// class _PMRScreenState extends State<PMRScreen> {
//
//
//   List<Map<String, dynamic>> listBillingServices1 = <Map<String, dynamic>>[];
//
//   // List<String> listBillingServices = [];
//   // List<TextEditingController> serviceControllers = [];
//   // List<TextEditingController> serviceControllers1 = [];
//   // List<TextEditingController> serviceControllers2 = [];
//
//
//   @override
//   void initState() {
//     // selectedOrganizationName;
//     listPMRSend.clear();
//     getPMRList(context);
//     super.initState();
//   }
//
//   void getPMRList(BuildContext context) async {
//     print('getBillingList');
//
//     try{
//       String loginUrl = "${baseURL}doctor_particular_list.php";
//       ProgressDialog pr = ProgressDialog(context);
//       Future.delayed(Duration.zero, () {
//         pr.show();
//       });
//       String patientUniqueKey = await getPatientUniqueKey();
//       String userType = await getUserType();
//       String patientIDP = await getPatientOrDoctorIDP();
//       debugPrint("Key and type");
//       debugPrint(patientUniqueKey);
//       debugPrint(userType);
//       String jsonStr = "{" +
//           "\"" +
//           "DoctorIDP" +
//           "\"" +
//           ":" +
//           "\"" +
//           patientIDP +
//           "\"" +
//           "}";
//
//       debugPrint(jsonStr);
//
//       String encodedJSONStr = encodeBase64(jsonStr);
//       var response = await apiHelper.callApiWithHeadersAndBody(
//         url: loginUrl,
//
//         headers: {
//           "u": patientUniqueKey,
//           "type": userType,
//         },
//         body: {"getjson": encodedJSONStr},
//       );
//       //var resBody = json.decode(response.body);
//
//       debugPrint(response.body.toString());
//       final jsonResponse = json.decode(response.body.toString());
//
//       ResponseModel model = ResponseModel.fromJSON(jsonResponse);
//
//       pr.hide();
//
//       if (model.status == "OK") {
//         var data = jsonResponse['Data'];
//         var strData = decodeBase64(data);
//
//         debugPrint("Decoded Data List : " + strData);
//         final jsonData = json.decode(strData);
//
//         // Clear the existing listPMR
//         listPMR.clear();
//
//         listPMRNumber.clear();
//
//         listPMRSchedule.clear();
//
//         // Populate the listPMR with the fetched medicineName values
//         for (var medicineJson in jsonData) {
//
//           String medicineName = medicineJson['MedicineName'];
//           listPMR.add(medicineName);
//
//           int medicineIDP = medicineJson['HospitalMedicineIDP'];
//           listPMRNumber.add(medicineIDP);
//
//           String schedule = medicineJson['DoseSchedule'].toString();
//           listPMRSchedule.add(schedule);
//
//         }
//
//         print("ListPMR: " + "${listPMR}");
//         print("ListPMRNumber: " + "${listPMRNumber}");
//         print("listPMRSchedule: " + "${listPMRSchedule}");
//
//         // Now you have the doctorMedicineList containing the fetched data.
//         // You can use it as needed. For example, you can store it in a state variable.
//
//         setState(() {});
//       }
//     }catch (e) {
//       print('Error decoding JSON: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: colorGrayApp,
//       appBar: AppBar(
//         elevation: 0,
//         title: Text("PMR"),
//         backgroundColor: Color(0xFFFFFFFF),
//         iconTheme: IconThemeData(color: Colorsblack),
//         toolbarTextStyle: TextTheme(
//             titleMedium: TextStyle(
//               color: Colorsblack,
//               fontFamily: "Ubuntu",
//               fontSize: SizeConfig.blockSizeVertical !* 2.5,
//             )).bodyMedium,
//         titleTextStyle: TextTheme(
//             titleMedium: TextStyle(
//               color: Colorsblack,
//               fontFamily: "Ubuntu",
//               fontSize: SizeConfig.blockSizeVertical !* 2.5,
//             )).titleLarge,
//       ),
//       body: Builder(
//         builder: (context) {
//           // return Container();
//           return Column(
//             children: <Widget>[
//               Row(
//                 children: [
//                   SizedBox(
//                     width: SizeConfig.blockSizeHorizontal !* 35,
//                   ),
//                   Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
//                     ),
//                     child: MaterialButton(
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(22.0)),
//                       onPressed: () {
//                         showBottomSheetDialog();
//                       },
//                       color: Colors.green,
//                       splashColor: Colors.green[800],
//                       child: Text(
//                         "ADD",
//                         style: TextStyle(
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Expanded(
//                 child: listPMRSend.length > 0
//                     ? ListView(
//                   shrinkWrap: true,
//                   children: <Widget>[
//                     ListView.builder(
//                         shrinkWrap: true,
//                         physics: ScrollPhysics(),
//                         itemCount: listPMRSend.length,
//                         itemBuilder: (context, index) {
//                           TextEditingController SelectPMRController1 =
//                           TextEditingController(
//                               text: listPMRSend[index].pmr );
//                           TextEditingController pmrIDPController1 =
//                           TextEditingController(
//                               text: listPMRSend[index].pmrIDP );
//
//                           TextEditingController QtyController1 =
//                           TextEditingController(text: listPMRSend[index].quantity);
//
//                           TextEditingController RemarksController1 =
//                           TextEditingController(
//                               text: listPMRSend[index].remarks );
//                           return Card(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10)),
//                             margin: EdgeInsets.all(
//                                 SizeConfig.blockSizeHorizontal !* 2),
//                             color: white,
//                             child: Row(
//                               children: <Widget>[
//                                 Expanded(
//                                   child: Container(
//                                     width:
//                                     SizeConfig.blockSizeHorizontal !*
//                                         100,
//                                     child: Column(
//                                       children: <Widget>[
//                                         Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: <Widget>[
//                                             Expanded(
//                                                 child: Padding(
//                                                     padding: EdgeInsets
//                                                         .all(SizeConfig
//                                                         .blockSizeHorizontal !*
//                                                         2),
//                                                     child: IgnorePointer(
//                                                       child: TextField(
//                                                         controller:
//                                                         SelectPMRController1,
//                                                         style: TextStyle(
//                                                             color: black),
//                                                         keyboardType:
//                                                         TextInputType
//                                                             .phone,
//                                                         decoration:
//                                                         InputDecoration(
//                                                           hintStyle:
//                                                           TextStyle(
//                                                               color:
//                                                               darkgrey),
//                                                           labelStyle:
//                                                           TextStyle(
//                                                               color:
//                                                               darkgrey),
//                                                           labelText:
//                                                           "Select Particular Name",
//                                                           hintText: "",
//                                                         ),
//                                                       ),
//                                                     ))),
//                                             // Expanded(
//                                             //     child: Padding(
//                                             //       padding: EdgeInsets.all(
//                                             //           SizeConfig
//                                             //               .blockSizeHorizontal !*
//                                             //               2),
//                                             //       child: IgnorePointer(
//                                             //         child: TextField(
//                                             //           controller:
//                                             //           pmrIDPController1,
//                                             //
//                                             //           style: TextStyle(
//                                             //               color: black),
//                                             //           keyboardType: TextInputType.number,
//                                             //           decoration:
//                                             //           InputDecoration(
//                                             //             hintStyle: TextStyle(
//                                             //                 color: darkgrey),
//                                             //             labelStyle: TextStyle(
//                                             //                 color: darkgrey),
//                                             //             labelText:
//                                             //             "Particular Name IDP",
//                                             //             hintText: "",
//                                             //           ),
//                                             //         ),
//                                             //       ),
//                                             //     )),
//                                           ],
//                                         ),
//                                         Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Expanded(
//                                                 child: Padding(
//                                                   padding: EdgeInsets.all(
//                                                       SizeConfig
//                                                           .blockSizeHorizontal !*
//                                                           2),
//                                                   child: IgnorePointer(
//                                                     child: TextField(
//                                                       controller:
//                                                       QtyController1,
//
//                                                       style: TextStyle(
//                                                           color: black),
//                                                       keyboardType: TextInputType.number,
//                                                       decoration:
//                                                       InputDecoration(
//                                                         hintStyle: TextStyle(
//                                                             color: darkgrey),
//                                                         labelStyle: TextStyle(
//                                                             color: darkgrey),
//                                                         labelText:
//                                                         "Requested Qty.",
//                                                         hintText: "",
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 )),
//                                             Expanded(
//                                                 child: Padding(
//                                                     padding: EdgeInsets
//                                                         .all(SizeConfig
//                                                         .blockSizeHorizontal !*
//                                                         2),
//                                                     child: IgnorePointer(
//                                                       child: TextField(
//                                                         controller:
//                                                         RemarksController1,
//                                                         style: TextStyle(
//                                                             color: black),
//                                                         keyboardType:
//                                                         TextInputType
//                                                             .phone,
//                                                         decoration:
//                                                         InputDecoration(
//                                                           hintStyle:
//                                                           TextStyle(
//                                                               color:
//                                                               darkgrey),
//                                                           labelStyle:
//                                                           TextStyle(
//                                                               color:
//                                                               darkgrey),
//                                                           labelText:
//                                                           "Remarks",
//                                                           hintText: "",
//                                                         ),
//                                                       ),
//                                                     )
//                                                 ))
//                                           ],
//                                         )
//
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 InkWell(
//                                   onTap: () {
//                                     setState(() {
//                                       listPMRSend.removeAt(index);
//                                     });
//                                   },
//                                   child: Align(
//                                     alignment: Alignment.bottomRight,
//                                     child: Image(
//                                       image: AssetImage(
//                                           "images/icn-delete-medicine.png"),
//                                       height: 25,
//                                       width: 25,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width:
//                                   SizeConfig.blockSizeHorizontal !* 2,
//                                 ),
//                               ],
//                             ),
//                           );
//                         })
//                   ],
//                 )
//                     : Column(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     Expanded(
//                       child: Image(
//                         image: AssetImage("images/ic_idea_new.png"),
//                         width: 100,
//                         height: 100,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 10.0,
//                     ),
//                     SizedBox(
//                       height: 10.0,
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: SizeConfig.blockSizeHorizontal !* 3),
//                 child: MaterialButton(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(22.0)),
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: SizeConfig.blockSizeHorizontal !* 3),
//                       child: Text(
//                         "Submit",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: SizeConfig.blockSizeHorizontal !* 4.3),
//                       ),
//                     ),
//                     color: colorBlueApp,
//                     onPressed: () async {
//                       if (listPMRSend.isEmpty ) {
//                         final snackBar = SnackBar(
//                           backgroundColor: Colors.red,
//                           content: Text(
//                               "Please enter Atleast one Services record"),
//                         );
//                         ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                         Future.delayed(Duration(seconds: 2), () {
//                           ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                         });
//                       } else
//                         // {
//                         //   bool atleastOneIsAddedFromDevice = false;
//                         //   for (int i = 0; i < listPMR.length; i++) {
//                         //     if (!listPMR[i].fromServer) {
//                         //       atleastOneIsAddedFromDevice = true;
//                         //       break;
//                         //     }
//                         //   }
//                         //   if (atleastOneIsAddedFromDevice) {
//                         //     addPrescription(context);
//                         //   } else
//                           {
//                         final snackBar = SnackBar(
//                           backgroundColor: Colors.green,
//                           content: Text(
//                               "Entered Services Added"),
//                         );
//                         ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                         Future.delayed(Duration(seconds: 2), () {
//                           ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                         });
//                         sendPMRData(
//                           context,
//                           widget.patientindooridp,
//                           widget.PatientIDP,
//                         );
//                         Navigator.of(context).push(
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                     PMRTableScreen(
//                                       patientindooridp:  widget.patientindooridp,
//                                       PatientIDP:  widget.PatientIDP,
//                                       doctoridp:  widget.doctoridp,
//                                       firstname:  widget.firstname,
//                                       lastName:  widget.lastName,)
//                             )
//                         );
//                       }
//                     }
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   void setStateOfParent() {
//     setState(() {});
//   }
//
//   showBottomSheetDialog() {
//     showModalBottomSheet<void>(
//       // context and builder are
//       // required properties in this widget
//       context: context,
//       builder: (BuildContext context) {
//         // we set up a container inside which
//         // we create center column and display text
//
//         // Returning SizedBox instead of a Container
//         return Wrap(
//           children: [
//             Column(
//               children: [
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     Expanded(
//                         child: Container(
//                           width: SizeConfig.blockSizeHorizontal !* 100,
//                           child: Column(
//                             children: <Widget>[
//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: <Widget>[
//                                   Flexible(
//                                     child: Padding(
//                                         padding: EdgeInsets.symmetric(
//                                             horizontal:
//                                             SizeConfig.blockSizeHorizontal !* 2),
//                                         child: InkWell(
//                                           onTap: () {
//                                             showMasterSelectionDialog(
//                                                 listPMR,
//                                                 listPMRSchedule,
//                                                 listPMRNumber,
//                                                 setStateOfParent
//                                             );
//                                           },
//                                           child: Container(
//                                             width:
//                                             SizeConfig.blockSizeHorizontal !* 90,
//                                             padding: EdgeInsets.all(
//                                                 SizeConfig.blockSizeHorizontal !* 1),
//                                             child: IgnorePointer(
//                                               child: TextField(
//                                                 controller: SelectPMRController,
//                                                 style: TextStyle(
//                                                     color: black,
//                                                     fontSize: SizeConfig
//                                                         .blockSizeVertical !*
//                                                         2.3),
//                                                 decoration: InputDecoration(
//                                                   hintStyle: TextStyle(
//                                                       color: darkgrey,
//                                                       fontSize: SizeConfig
//                                                           .blockSizeVertical !*
//                                                           2.3),
//                                                   labelStyle: TextStyle(
//                                                       color: darkgrey,
//                                                       fontSize: SizeConfig
//                                                           .blockSizeVertical !*
//                                                           2.3),
//                                                   labelText: "Select Particular Name",
//                                                   hintText: "",
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         )
//                                     ),
//                                   ),
//                                   // Flexible(
//                                   //   child: Padding(
//                                   //       padding: EdgeInsets.symmetric(
//                                   //           horizontal:
//                                   //           SizeConfig.blockSizeHorizontal !* 2),
//                                   //       child: Container(
//                                   //         width:
//                                   //         SizeConfig.blockSizeHorizontal !* 90,
//                                   //         padding: EdgeInsets.all(
//                                   //             SizeConfig.blockSizeHorizontal !* 1),
//                                   //         child: IgnorePointer(
//                                   //           child: TextField(
//                                   //             controller: pmrIDPController,
//                                   //             style: TextStyle(
//                                   //                 color: black,
//                                   //                 fontSize: SizeConfig
//                                   //                     .blockSizeVertical !*
//                                   //                     2.3),
//                                   //             decoration: InputDecoration(
//                                   //               hintStyle: TextStyle(
//                                   //                   color: darkgrey,
//                                   //                   fontSize: SizeConfig
//                                   //                       .blockSizeVertical !*
//                                   //                       2.3),
//                                   //               labelStyle: TextStyle(
//                                   //                   color: darkgrey,
//                                   //                   fontSize: SizeConfig
//                                   //                       .blockSizeVertical !*
//                                   //                       2.3),
//                                   //               labelText: "Particular Name IDP",
//                                   //               hintText: "",
//                                   //             ),
//                                   //           ),
//                                   //         ),
//                                   //       )
//                                   //   ),
//                                   // ),
//                                 ],
//                               ),
//                               Row(
//                                 children: <Widget>[
//                                   Flexible(
//                                     child: Padding(
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal:
//                                           SizeConfig.blockSizeHorizontal !* 2),
//                                       child: TextField(
//                                         controller: QtyController,
//                                         // keyboardType: TextInputType.number,
//                                         style: TextStyle(color: black),
//                                         keyboardType: TextInputType.number,
//                                         decoration: InputDecoration(
//                                           hintStyle: TextStyle(color: darkgrey),
//                                           labelStyle: TextStyle(color: darkgrey),
//                                           labelText: "Requested Qty.",
//                                           hintText: "",
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Flexible(
//                                     child: Padding(
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal:
//                                           SizeConfig.blockSizeHorizontal !* 2),
//                                       child: TextField(
//                                         controller: RemarksController,
//                                         // keyboardType: TextInputType.number,
//                                         style: TextStyle(color: black),
//                                         decoration: InputDecoration(
//                                           hintStyle: TextStyle(color: darkgrey),
//                                           labelStyle: TextStyle(color: darkgrey),
//                                           labelText: "Remarks",
//                                           hintText: "",
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   // Flexible(
//                                   //   child: Padding(
//                                   //       padding: EdgeInsets.symmetric(
//                                   //           horizontal:
//                                   //           SizeConfig.blockSizeHorizontal !* 2),
//                                   //       child: InkWell(
//                                   //         onTap: () {
//                                   //           // showMasterSelectionDialog(
//                                   //           //     listMastersAdviceTypeString,
//                                   //           //     1,
//                                   //           //     setStateOfParent);
//                                   //         },
//                                   //         child: Container(
//                                   //           width:
//                                   //           SizeConfig.blockSizeHorizontal !* 90,
//                                   //           padding: EdgeInsets.all(
//                                   //               SizeConfig.blockSizeHorizontal !* 1),
//                                   //           child: IgnorePointer(
//                                   //             child: TextField(
//                                   //               controller: RemarksController,
//                                   //               style: TextStyle(
//                                   //                   color: black,
//                                   //                   fontSize: SizeConfig
//                                   //                       .blockSizeVertical !*
//                                   //                       2.3),
//                                   //               decoration: InputDecoration(
//                                   //                 hintStyle: TextStyle(
//                                   //                     color: darkgrey,
//                                   //                     fontSize: SizeConfig
//                                   //                         .blockSizeVertical !*
//                                   //                         2.3),
//                                   //                 labelStyle: TextStyle(
//                                   //                     color: darkgrey,
//                                   //                     fontSize: SizeConfig
//                                   //                         .blockSizeVertical !*
//                                   //                         2.3),
//                                   //                 labelText: "Remarks",
//                                   //                 hintText: "",
//                                   //               ),
//                                   //             ),
//                                   //           ),
//                                   //         ),
//                                   //       )
//                                   //   ),
//                                   // ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         )),
//                     SizedBox(
//                       width: SizeConfig.blockSizeHorizontal !* 2,
//                     ),
//                     SizedBox(
//                       width: SizeConfig.blockSizeHorizontal !* 2,
//                     ),
//                   ],
//                 ),
//                 Wrap(
//                   children: <Widget>[
//                     MaterialButton(
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(22.0)),
//                         child: Text(
//                           "ADD",
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: SizeConfig.blockSizeVertical !* 2),
//                         ),
//                         color: colorBlueApp,
//                         onPressed:
//                         /*isAddButtonEnabled
//                               ?*/
//                             () {
//                           Navigator.pop(context);
//                           if (SelectPMRController.text.trim() ==
//                               "" /*||
//                                     drugDosageController.text.trim() == ""*/
//                               ||
//                               QtyController.text.trim() ==
//                                   "" /*||
//                                     drugAdviceController.text.trim() == ""*/
//                           ) {
//                             debugPrint(SelectPMRController.text.trim());
//                             debugPrint(pmrIDPController.text.trim());
//                             debugPrint(QtyController.text.trim());
//                             debugPrint(RemarksController.text.trim());
//                             final snackBar = SnackBar(
//                               backgroundColor: Colors.red,
//                               content: Text("Please enter the fields"),
//                             );
//                             ScaffoldMessenger.of(context)
//                                 .showSnackBar(snackBar);
//                             Future.delayed(Duration(seconds: 2), () {
//                               ScaffoldMessenger.of(context)
//                                   .hideCurrentSnackBar();
//                             });
//                           } else {
//                             listPMRSend.add(MedicineFormData(
//                               pmr: SelectPMRController.text.toString(),
//                               pmrIDP: pmrIDPController.text.toString(),
//                               quantity:QtyController.text.toString(),
//                               remarks: RemarksController.text.toString(),
//                             ));
//                             SelectPMRController = TextEditingController();
//                             pmrIDPController = TextEditingController();
//                             QtyController = TextEditingController();
//                             RemarksController = TextEditingController();
//                           }
//                           setState(() {});
//                         }),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//   void showMasterSelectionDialog(
//       List<String> listPMR,
//       List<String>listSchedule,
//       List<int> idList,
//       VoidCallback setStateOfParent) {
//     FocusScopeNode currentFocus = FocusScope.of(context);
//     if (!currentFocus.hasPrimaryFocus) {
//       currentFocus.unfocus();
//     }
//     showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (BuildContext context) => Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           backgroundColor: Colors.white,
//           child: SelectPMRDialog(
//             setStateOfParent: setStateOfParent,
//             listPMR: listPMR,
//             listSchedule: listSchedule,
//             idList: idList,),
//         )
//     );
//   }
//
//   void sendPMRData(
//       BuildContext context,
//       String patientindooridp,
//       String PatientIDF
//       ) async {
//     print('sendPMRData');
//
//     try {
//       String loginUrl = "${baseURL}doctor_add_pmr_submit.php";
//       ProgressDialog pr = ProgressDialog(context);
//       Future.delayed(Duration.zero, () {
//         pr.show();
//       });
//
//
//       var jArrayPMRData = "[";
//       for (var i = 0; i < listPMRSend.length; i++) {
//         var formData = listPMRSend[i];
//
//         jArrayPMRData +=
//         "{\"pmr\":\"${formData.pmrIDP}\","
//         // "\"pmrID\":\"${formData.pmr}\","
//             "\"quantity\":\"${formData.quantity}\","
//             "\"remarks\":\"${formData.remarks}\"},";
//
//       }
//       // Remove the trailing comma if it exists
//       if (listPMRSend.isNotEmpty) {
//         jArrayPMRData = jArrayPMRData.substring(0, jArrayPMRData.length - 1);
//       }
//
//       jArrayPMRData += "]";
//
//
//       print(jArrayPMRData);
//
//       // List<String> serviceValues = serviceControllers.map((controller) => controller.text).toList();
//
//       // var jsonArrayServices = "[";
//       // for (var i = 0; i < serviceValues.length; i++) {
//       //   jsonArrayServices += "\"${serviceValues[i]}\"";
//       //
//       //   // Add a comma if it's not the last element
//       //   if (i < serviceValues.length - 1) {
//       //     jsonArrayServices += ",";
//       //   }
//       // }
//       // jsonArrayServices += "]";
//       String patientUniqueKey = await getPatientUniqueKey();
//       String userType = await getUserType();
//       String patientIDP = await getPatientOrDoctorIDP();
//       debugPrint("Key and type");
//       debugPrint(patientUniqueKey);
//       debugPrint(userType);
//       String jsonStr = "{" +
//           "\"" +
//           "PatientIDF" +
//           "\"" +
//           ":" +
//           "\"" +
//           PatientIDF +
//           "\"" +
//           "," +
//           "\"" +
//           "DoctorIDP" +
//           "\"" +
//           ":" +
//           "\"" +
//           patientIDP +
//           "\"" +
//           "," +
//           "\"" +
//           "PatientIndoorIDF" +
//           "\"" +
//           ":" +
//           "\"" +
//           patientindooridp +
//           "\"" +
//           "," +
//           "\"" +
//           "PMRData" +
//           "\"" +
//           ":" +
//           jArrayPMRData +
//           "}";
//
//       // {"pmrlength":"1","particularname":"123",
//       // "requestedqty":"1","remark":"hii hellorwerwerwerewrewr",
//       // "PatientIDF":"736","DoctorIDP":"1","PatientIndoorIDF":"452"}
//
//       debugPrint(jsonStr);
//
//       String encodedJSONStr = encodeBase64(jsonStr);
//       var response = await apiHelper.callApiWithHeadersAndBody(
//         url: loginUrl,
//
//         headers: {
//           "u": patientUniqueKey,
//           "type": userType,
//         },
//         body: {"getjson": encodedJSONStr},
//       );
//       //var resBody = json.decode(response.body);
//
//       debugPrint(response.body.toString());
//       final jsonResponse = json.decode(response.body.toString());
//
//       ResponseModel model = ResponseModel.fromJSON(jsonResponse);
//
//       pr.hide();
//
//       // if (model.status == "OK") {
//       //   var data = jsonResponse['Data'];
//       //   var strData = decodeBase64(data);
//       //
//       //   debugPrint("Decoded Data List : " + strData);
//       //   final jsonData = json.decode(strData);
//       //
//       //   for (var i = 0; i < jsonData.length; i++)
//       //   {
//       //     final jo = jsonData[i];
//       //     String OPDService = jo['OPDService'].toString();
//       //     listBillingServices.add(OPDService);
//       //     // debugPrint("Added to list: $diagnosisName");
//       //   }
//       //
//       //
//       //   setState(() {});
//       // }
//     }catch (e) {
//       print('Error decoding JSON: $e');
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
// }
//
// class SelectPMRDialog extends StatefulWidget {
//   Function setStateOfParent;
//   List<String> listPMR;
//   List<String> listSchedule;
//   List<int> idList;
//
//   SelectPMRDialog({
//     required this.setStateOfParent,
//     required this.listPMR,
//     required this.listSchedule,
//     required this.idList,
//   });
//
//   @override
//   State<StatefulWidget> createState() {
//     return SelectPMRDialogState();
//   }
// }
//
// class SelectPMRDialogState extends State<SelectPMRDialog> {
//   late Icon? icon;
//   late Widget? titleWidget;
//   late TextEditingController searchController;
//   late FocusNode focusNode;
//   late List<String> filteredList;
//
//   @override
//   void initState() {
//     super.initState();
//     searchController = TextEditingController(text: "");
//     focusNode = FocusNode();
//     icon = Icon(
//       Icons.cancel,
//       color: Colors.red,
//     );
//     titleWidget = TextField(
//       controller: searchController,
//       focusNode: focusNode,
//       cursorColor: Colors.black,
//       onChanged: (text) {
//         setState(() {
//           // Filter the list based on search text
//           filteredList = _filterMedicines(text);
//         });
//       },
//       decoration: InputDecoration(
//         hintText: "Search Here",
//       ),
//     );
//     // Initialize filteredList with the full list of PMRs
//     filteredList = widget.listPMR;
//   }
//
//   List<String> _filterMedicines(String searchText) {
//     return widget.listPMR
//         .where((medicine) => medicine.toLowerCase().contains(searchText.toLowerCase()))
//         .toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: <Widget>[
//         Container(
//           height: 60,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: <Widget>[
//               InkWell(
//                 child: Icon(
//                   Icons.arrow_back,
//                   color: Colors.red,
//                 ),
//                 onTap: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//               SizedBox(
//                 width: 20,
//               ),
//               Container(
//                 width: 200,
//                 child: Center(
//                   child: titleWidget!,
//                 ),
//               ),
//               Expanded(
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: Padding(
//                     padding: EdgeInsets.all(8),
//                     child: InkWell(
//                       child: icon!,
//                       onTap: () {
//                         setState(() {
//                           if (icon?.icon == Icons.cancel) {
//                             searchController.clear();
//                             // Reset filteredList to the full list when canceling search
//                             filteredList = widget.listPMR;
//                           }
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             itemCount: filteredList.length,
//             itemBuilder: (contextFromList, index) {
//               return InkWell(
//                 onTap: () {
//                   Navigator.of(context).pop();
//                   // Update the controller's value
//                   // Assuming listSchedule and listPMRNumber are properties of this class
//                   SelectPMRController.text =
//                   '${filteredList[index]}  (${widget.listSchedule[index]})';
//                   pmrIDPController.text = widget.idList[index].toString();
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: [
//                         Text(
//                           filteredList[index],
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.black,
//                           ),
//                         ),
//                         Text(
//                           "  (${widget.listSchedule[index]})",
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }