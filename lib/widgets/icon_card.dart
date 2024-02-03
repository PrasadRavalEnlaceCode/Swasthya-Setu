// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:swasthyasetu/global/SizeConfig.dart';
// import 'package:swasthyasetu/podo/model_icon.dart';
// import 'package:swasthyasetu/utils/color.dart';
//
// class IconCard extends StatelessWidget
// {
//   final ModelIcon model;
//   final Function tap;
//
//   const IconCard({this.model,this.tap,Key key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     return InkWell(
//       highlightColor: Colors.green[200],
//       customBorder: CircleBorder(),
//       onTap: tap
//       // () async
//       // {
//       //   String patientIDP = await getPatientOrDoctorIDP();
//       //   if (model.iconName == "Consultation") {
//       //     Get.to(() => DocumentsListScreen(patientIDP));
//       //   } else if (model.iconName == "Order\nMedicine") {
//       //   } else if (model.iconName == "Order\nBlood Test") {
//       //   } else if (model.iconName == "Blood\nPressure") {
//       //     Get.to(() => VitalsListScreen(patientIDP, "1"));
//       //   } else if (model.iconName == "Blood\nSugar") {
//       //     Get.to(() => InvestigationsListWithGraph(
//       //       patientIDP,
//       //       from: "sugar",
//       //     ));
//       //   } else if (model.iconName == "Vitals") {
//       //     Get.to(() => VitalsListScreen(patientIDP, "2"));
//       //   }
//       // }
//         ,
//       child: Padding(
//         padding: EdgeInsets.symmetric(
//             horizontal: SizeConfig.blockSizeHorizontal * 0.0),
//         child: Card(
//           color: colorWhite,
//           elevation: 2.0,
//           //shadowColor: model.iconColor,
//           margin: EdgeInsets.all(
//             SizeConfig.blockSizeHorizontal * 2.0,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(
//               SizeConfig.blockSizeHorizontal * 2.0,
//             ),
//           ),
//           child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 Container(
//                   width: SizeConfig.blockSizeHorizontal * 15,
//                   height: SizeConfig.blockSizeHorizontal * 15,
//                   child: Padding(
//                     padding: EdgeInsets.all(
//                       SizeConfig.blockSizeHorizontal * 3.0,
//                     ),
//                     child: model.iconType == "image"
//                         ? Image(
//                       width: SizeConfig.blockSizeHorizontal * 5,
//                       height: SizeConfig.blockSizeHorizontal * 5,
//                       image: AssetImage(
//                         'images/${model.iconImg}',
//                       ),
//                     )
//                         : model.iconType == "faIcon"
//                         ? FaIcon(
//                       model.iconData,
//                       size: SizeConfig.blockSizeHorizontal * 5,
//                       color: Color(0xFF06A759),
//                     )
//                         : Container(
//                       width: SizeConfig.blockSizeHorizontal * 5,
//                       height: SizeConfig.blockSizeHorizontal * 5,
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: SizeConfig.blockSizeVertical * 0,
//                 ),
//                 Flexible(
//                   child: Text(model.iconName,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                         fontSize: SizeConfig.blockSizeHorizontal * 3.2,
//                         letterSpacing: 1.2,
//                       )),
//                 ),
//                 SizedBox(
//                   height: SizeConfig.blockSizeVertical * 2,
//                 ),
//               ]),
//         ),
//       ),
//     ) /*)*/;
//   }
// }