import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:silvertouch/app_screens/chat_screen.dart';
import 'package:silvertouch/app_screens/fullscreen_image.dart';
import 'package:silvertouch/app_screens/selected_patient_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/model_my_patients.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import '../utils/color.dart';

List<ModelMyPatients> listMyPatients = [];
List<ModelMyPatients> listMyPatientsSearchResults = [];

class MyPatientsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyPatientsScreenState();
  }
}

class MyPatientsScreenState extends State<MyPatientsScreen> {
  Icon icon = Icon(
    Icons.search,
    color: black,
  );
  Widget titleWidget = Text(
    "My Patients",
    style: TextStyle(color: Colorsblack),
  );
  TextEditingController? searchController;
  var focusNode = new FocusNode();
  bool isDiabetesChecked = false;
  bool isHypertensionChecked = false;
  bool isHeartDiseaseChecked = false;
  bool isThyroidChecked = false;

  String userType = '';

  @override
  void initState() {
    super.initState();
    getUserType().then((value) {
      userType = value;
    });
    getMyPatientsList(context);
  }

  @override
  void dispose() {
    listMyPatients = [];
    listMyPatientsSearchResults = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: titleWidget,
        backgroundColor: white,
        iconTheme: IconThemeData(color: Colorsblack),
        toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(
          color: Colorsblack,
          fontFamily: "Ubuntu",
          fontSize: SizeConfig.blockSizeVertical! * 2.5,
        )).bodyMedium,
        titleTextStyle: TextTheme(
            titleMedium: TextStyle(
          color: Colorsblack,
          fontFamily: "Ubuntu",
          fontSize: SizeConfig.blockSizeVertical! * 2.5,
        )).titleLarge,
        /*actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                if (icon.icon == Icons.search) {
                  searchController = TextEditingController(text: "");
                  focusNode.requestFocus();
                  icon = Icon(
                    Icons.cancel,
                    color: black,
                  );
                  titleWidget = TextField(
                    controller: searchController,
                    focusNode: focusNode,
                    cursorColor: black,
                    onChanged: (text) {
                      setState(() {
                        listMyPatientsSearchResults = listMyPatients
                            .where((model) =>
                                (model.fName.toLowerCase().trim() +
                                        " " +
                                        model.mName.toLowerCase().trim() +
                                        " " +
                                        model.lName.toLowerCase().trim())
                                    .replaceAll("  ", " ")
                                    .contains(text.toLowerCase()) ||
                                model.cityName
                                    .toLowerCase()
                                    .contains(text.toLowerCase()) ||
                                model.number
                                    .toLowerCase()
                                    .contains(text.toLowerCase()) ||
                                (model.gender.toLowerCase() +
                                        "/" +
                                        model.age.toLowerCase())
                                    .contains(text.toLowerCase()))
                            .toList();
                      });
                    },
                    style: TextStyle(
                      color: black,
                      fontSize: SizeConfig.blockSizeHorizontal * 4.0,
                    ),
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical * 2.1),
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeVertical * 2.1),
                      hintText: "Search Patients",
                    ),
                  );
                } else {
                  icon = Icon(
                    Icons.search,
                    color: black,
                  );
                  titleWidget = Text("My Patients");
                  listMyPatientsSearchResults = listMyPatients;
                }
              });
            },
            icon: icon,
          )
        ],*/
      ),
      body: Builder(
        builder: (context) {
          return Container(
            color: colorGrayApp,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: SizeConfig.blockSizeVertical! * 2,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      //border corner radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2), //color of shadow
                          spreadRadius: 3, //spread radius
                          blurRadius: 7, // blur radius
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                        //you can set more BoxShadow() here
                      ],
                    ),
                    child: TextField(
                      onChanged: (text) {
                        setState(() {
                          listMyPatientsSearchResults = listMyPatients
                              .where((model) =>
                                  (model.fName.toLowerCase().trim() +
                                          " " +
                                          model.mName.toLowerCase().trim() +
                                          " " +
                                          model.lName.toLowerCase().trim())
                                      .replaceAll("  ", " ")
                                      .contains(text.toLowerCase()) ||
                                  model.cityName
                                      .toLowerCase()
                                      .contains(text.toLowerCase()) ||
                                  model.number
                                      .toLowerCase()
                                      .contains(text.toLowerCase()) ||
                                  (model.gender.toLowerCase() +
                                          "/" +
                                          model.age.toLowerCase())
                                      .contains(text.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(15),
                          border: InputBorder.none,
                          hintText: 'Search',
                          hintStyle: TextStyle(fontSize: 16),
                          suffixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF70a5db),
                          )),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: SizeConfig.blockSizeVertical !* 2,
                // ),
                // Container(
                //   color: white,
                //   child: Column(
                //     children: [
                //       Row(
                //         children: [
                //           SizedBox(
                //             width: SizeConfig.blockSizeHorizontal !* 6,
                //           ),
                //           Expanded(
                //             child: InkWell(
                //               onTap: () {
                //                 setState(() {
                //                   isDiabetesChecked = !isDiabetesChecked;
                //                 });
                //               },
                //               child: Row(
                //                 children: [
                //                   Checkbox(
                //                     materialTapTargetSize:
                //                         MaterialTapTargetSize.shrinkWrap,
                //                     value: isDiabetesChecked,
                //                     onChanged: (bool? value) {
                //                       setState(() {
                //                         isDiabetesChecked = value!;
                //                       });
                //                     },
                //                   ),
                //                   Text("Diabetes"),
                //                 ],
                //               ),
                //             ),
                //           ),
                //           Expanded(
                //             child: InkWell(
                //               onTap: () {
                //                 setState(() {
                //                   isHypertensionChecked =
                //                       !isHypertensionChecked;
                //                 });
                //               },
                //               child: Row(
                //                 children: [
                //                   Checkbox(
                //                     materialTapTargetSize:
                //                         MaterialTapTargetSize.shrinkWrap,
                //                     value: isHypertensionChecked,
                //                     onChanged: (bool? value) {
                //                       setState(() {
                //                         isHypertensionChecked = value!;
                //                       });
                //                     },
                //                   ),
                //                   Text("Hypertension"),
                //                 ],
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //       Row(
                //         children: [
                //           SizedBox(
                //             width: SizeConfig.blockSizeHorizontal !* 6,
                //           ),
                //           Expanded(
                //             child: InkWell(
                //               onTap: () {
                //                 setState(() {
                //                   isHeartDiseaseChecked =
                //                       !isHeartDiseaseChecked;
                //                 });
                //               },
                //               child: Row(
                //                 children: [
                //                   Checkbox(
                //                     materialTapTargetSize:
                //                         MaterialTapTargetSize.shrinkWrap,
                //                     value: isHeartDiseaseChecked,
                //                     onChanged: (bool? value) {
                //                       setState(() {
                //                         isHeartDiseaseChecked = value!;
                //                       });
                //                     },
                //                   ),
                //                   Text("Heart Disease"),
                //                 ],
                //               ),
                //             ),
                //           ),
                //           Expanded(
                //             child: InkWell(
                //               onTap: () {
                //                 setState(() {
                //                   isThyroidChecked = !isThyroidChecked;
                //                 });
                //               },
                //               child: Row(
                //                 children: [
                //                   Checkbox(
                //                     materialTapTargetSize:
                //                         MaterialTapTargetSize.shrinkWrap,
                //                     value: isThyroidChecked,
                //                     onChanged: (bool? value) {
                //                       setState(() {
                //                         isThyroidChecked = value!;
                //                       });
                //                     },
                //                   ),
                //                   Text("Thyroid"),
                //                 ],
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical! * 1.2,
                ),
                Expanded(
                  child: listMyPatientsSearchResults.length > 0
                      ? ListView.builder(
                          itemCount: listMyPatientsSearchResults.length,
                          itemBuilder: (context, index) {
                            return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        SizeConfig.blockSizeHorizontal! * 3),
                                child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          PageRouteBuilder(
                                              transitionDuration:
                                                  Duration(milliseconds: 500),
                                              pageBuilder: (context, _, __) {
                                                return SelectedPatientScreen(
                                                  listMyPatientsSearchResults[
                                                          index]
                                                      .patientIDP,
                                                  listMyPatientsSearchResults[
                                                          index]
                                                      .healthRecordsDisplayStatus,
                                                  "selectedPatient_$index",
                                                  notificationDisplayStatus:
                                                      listMyPatientsSearchResults[
                                                              index]
                                                          .notificationDisplayStatus,
                                                );
                                              }));
                                    },
                                    child: Hero(
                                      tag: "selectedPatient_$index",
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: IntrinsicHeight(
                                            child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Visibility(
                                              visible: false,
                                              child: VerticalDivider(
                                                width: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    2,
                                                thickness: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    2,
                                                color: Colors.green,
                                              ),
                                            ),
                                            SizedBox(
                                              width: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  3,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                if (listMyPatientsSearchResults[
                                                            index]
                                                        .imgUrl !=
                                                    "")
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return FullScreenImage(
                                                        "$userImgUrl${listMyPatientsSearchResults[index].imgUrl}");
                                                  }));
                                              },
                                              child: CircleAvatar(
                                                radius: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    6.5,
                                                backgroundColor: colorBlueApp,
                                                child: (listMyPatientsSearchResults[index]
                                                            .imgUrl !=
                                                        "")
                                                    ? CircleAvatar(
                                                        radius: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            6,
                                                        backgroundColor:
                                                            Colors.grey,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                "$userImgUrl${listMyPatientsSearchResults[index].imgUrl}"))
                                                    : CircleAvatar(
                                                        radius: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            6,
                                                        backgroundColor:
                                                            Colors.grey,
                                                        backgroundImage: AssetImage(
                                                            "images/ic_user_placeholder.png")),
                                              ),
                                            ),
                                            SizedBox(
                                              width: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  5,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: SizeConfig
                                                              .blockSizeHorizontal! *
                                                          3),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text(
                                                        (listMyPatientsSearchResults[index].fName.trim() +
                                                                " " +
                                                                listMyPatientsSearchResults[
                                                                        index]
                                                                    .mName
                                                                    .trim() +
                                                                " " +
                                                                listMyPatientsSearchResults[
                                                                        index]
                                                                    .lName
                                                                    .trim())
                                                            .replaceAll(
                                                                "  ", " "),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: SizeConfig
                                                                    .blockSizeHorizontal! *
                                                                4),
                                                      ),
                                                      SizedBox(
                                                        height: SizeConfig
                                                                .blockSizeVertical! *
                                                            1,
                                                      ),
                                                      Row(children: <Widget>[
                                                        Text(
                                                          "ID - ${listMyPatientsSearchResults[index].patientID}",
                                                          style: TextStyle(
                                                            fontSize: SizeConfig
                                                                    .blockSizeHorizontal! *
                                                                3.5,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: SizeConfig
                                                                  .blockSizeHorizontal! *
                                                              5,
                                                        ),
                                                        Text(
                                                          "${listMyPatientsSearchResults[index].gender}/${listMyPatientsSearchResults[index].age}",
                                                          style: TextStyle(
                                                            fontSize: SizeConfig
                                                                    .blockSizeHorizontal! *
                                                                3.5,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        /*VerticalDivider(
                                  color: Colors.grey,
                                ),*/
                                                      ]),
                                                      Text(
                                                        listMyPatientsSearchResults[
                                                                index]
                                                            .cityName,
                                                        style: TextStyle(
                                                            fontSize: SizeConfig
                                                                    .blockSizeHorizontal! *
                                                                3.5,
                                                            color: Colors.grey),
                                                      ),
                                                      SizedBox(
                                                        height: SizeConfig
                                                                .blockSizeVertical! *
                                                            1.0,
                                                      ),
                                                      userType == 'frontoffice'
                                                          ? Container()
                                                          : Row(
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      String
                                                                          patientIDP =
                                                                          listMyPatientsSearchResults[index]
                                                                              .patientIDP;
                                                                      String patientName = (listMyPatientsSearchResults[index].fName.trim() +
                                                                              " " +
                                                                              listMyPatientsSearchResults[index].mName.trim() +
                                                                              " " +
                                                                              listMyPatientsSearchResults[index].lName.trim())
                                                                          .replaceAll("  ", " ");

                                                                      Navigator.of(
                                                                              context)
                                                                          .push(MaterialPageRoute(builder:
                                                                              (context) {
                                                                        return ChatScreen(
                                                                          patientIDP:
                                                                              patientIDP,
                                                                          patientName:
                                                                              patientName,
                                                                          patientImage:
                                                                              listMyPatientsSearchResults[index].imgUrl,
                                                                          gender:
                                                                              listMyPatientsSearchResults[index].gender,
                                                                          age: listMyPatientsSearchResults[index]
                                                                              .age,
                                                                          cityName:
                                                                              listMyPatientsSearchResults[index].cityName,
                                                                          patientID:
                                                                              listMyPatientsSearchResults[index].patientID,
                                                                          heroTag:
                                                                              "selectedPatient_$index",
                                                                        );
                                                                      }));
                                                                    },
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Image(
                                                                          image:
                                                                              AssetImage(
                                                                            "images/icn-chat-dr.png",
                                                                          ),
                                                                          color:
                                                                              colorBlueApp,
                                                                          width:
                                                                              SizeConfig.blockSizeHorizontal! * 5.5,
                                                                          height:
                                                                              SizeConfig.blockSizeHorizontal! * 5.5,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              SizeConfig.blockSizeHorizontal! * 1.0,
                                                                        ),
                                                                        Text(
                                                                          "Chat",
                                                                          style: TextStyle(
                                                                              color: colorBlueApp,
                                                                              fontSize: SizeConfig.blockSizeHorizontal! * 3.5),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerRight,
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Text(
                                                                          "Call",
                                                                          style: TextStyle(
                                                                              color: colorBlueApp,
                                                                              fontSize: SizeConfig.blockSizeHorizontal! * 3.5),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              SizeConfig.blockSizeHorizontal! * 2.0,
                                                                        ),
                                                                        InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            String
                                                                                patientIDP =
                                                                                listMyPatientsSearchResults[index].patientIDP;
                                                                            String
                                                                                patientName =
                                                                                (listMyPatientsSearchResults[index].fName.trim() + " " + listMyPatientsSearchResults[index].mName.trim() + " " + listMyPatientsSearchResults[index].lName.trim()).replaceAll("  ", " ");
                                                                            String
                                                                                doctorImage =
                                                                                listMyPatientsSearchResults[index].imgUrl;
                                                                            showAudioCallRequestDialog(
                                                                                context,
                                                                                patientIDP,
                                                                                patientName,
                                                                                doctorImage);
                                                                          },
                                                                          child: Image(
                                                                              height: SizeConfig.blockSizeHorizontal! * 6.0,
                                                                              width: SizeConfig.blockSizeHorizontal! * 6.0,
                                                                              image: AssetImage(
                                                                                "images/icn-call-dr.png",
                                                                              )),
                                                                          /*Icon(
                                                                            Icons.call,
                                                                            size:
                                                                                SizeConfig.blockSizeHorizontal * 6.0,
                                                                            color:
                                                                                Colors.blueGrey,
                                                                          ),*/
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              SizeConfig.blockSizeHorizontal! * 2.0,
                                                                        ),
                                                                        InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            String
                                                                                patientIDP =
                                                                                listMyPatientsSearchResults[index].patientIDP;
                                                                            String
                                                                                patientName =
                                                                                (listMyPatientsSearchResults[index].fName.trim() + " " + listMyPatientsSearchResults[index].mName.trim() + " " + listMyPatientsSearchResults[index].lName.trim()).replaceAll("  ", " ");
                                                                            String
                                                                                doctorImage =
                                                                                listMyPatientsSearchResults[index].imgUrl;
                                                                            showVideoCallRequestDialog(
                                                                                context,
                                                                                patientIDP,
                                                                                patientName,
                                                                                doctorImage);
                                                                          },
                                                                          child: Image(
                                                                              height: SizeConfig.blockSizeHorizontal! * 6.0,
                                                                              width: SizeConfig.blockSizeHorizontal! * 6.0,
                                                                              image: AssetImage(
                                                                                "images/icn-video-dr.png",
                                                                              )),
                                                                          /*Icon(
                                                                            Icons.video_call,
                                                                            size:
                                                                                SizeConfig.blockSizeHorizontal * 6.5,
                                                                            color:
                                                                                Colors.blueGrey,
                                                                          ),*/
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    /*InkWell(
                                                                onTap:
                                                                    () async {
                                                                  String
                                                                      patientIDP =
                                                                      listMyPatientsSearchResults[
                                                                              index]
                                                                          .patientIDP;
                                                                  String patientName = (listMyPatientsSearchResults[index].fName.trim() +
                                                                          " " +
                                                                          listMyPatientsSearchResults[index]
                                                                              .mName
                                                                              .trim() +
                                                                          " " +
                                                                          listMyPatientsSearchResults[index]
                                                                              .lName
                                                                              .trim())
                                                                      .replaceAll(
                                                                          "  ",
                                                                          " ");
                                                                  String
                                                                      doctorImage =
                                                                      listMyPatientsSearchResults[
                                                                              index]
                                                                          .imgUrl;
                                                                  showVideoCallRequestDialog(
                                                                      context,
                                                                      patientIDP,
                                                                      patientName,
                                                                      doctorImage);
                                                                },
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Text(
                                                                      "Call",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                          SizeConfig.blockSizeHorizontal * 3.5),
                                                                    ),
                                                                    SizedBox(
                                                                      width: SizeConfig
                                                                              .blockSizeHorizontal *
                                                                          1.0,
                                                                    ),
                                                                    Icon(
                                                                      Icons
                                                                          .video_call,
                                                                      size: SizeConfig
                                                                          .blockSizeHorizontal *
                                                                          6.5,
                                                                      color: Colors
                                                                          .blueGrey,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),*/
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: SizeConfig
                                                                          .blockSizeHorizontal! *
                                                                      3.0,
                                                                ),
                                                              ],
                                                            )
                                                    ],
                                                  )),
                                            )
                                          ],
                                        )),
                                      ),
                                    )));
                          })
                      : Container(),
                ),
                Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 3),
                  child: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      child: Text(
                        "Scan".toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeConfig.blockSizeHorizontal! * 4.0),
                      ),
                      padding:
                          EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 3),
                      color: colorBlueApp,
                      onPressed: () async {
                        var result = await BarcodeScanner.scan();
                        if (result.type.toString() != "Cancelled" &&
                            result.rawContent != "") {
                          String decodedContent =
                              decodeBase64(result.rawContent);
                          String patientIDP =
                              decodedContent.replaceAll("patient-", "");
                          Navigator.of(context).push(PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 500),
                              pageBuilder: (context, _, __) {
                                return SelectedPatientScreen(
                                  patientIDP,
                                  "1",
                                  "selectedPatient_qr_scanned",
                                );
                              }));
                          //getAllPatientFields(patientIDP, context);
                        }
                        //launchURL(decodeBase64(result.rawContent));
                      }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  showVideoCallRequestDialog(
      BuildContext context, String patientIDP, patientName, doctorImage) {
    var title = "Do you want to send Video call request?";
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    requestCallFromDoctor(
                        patientIDP, patientName, doctorImage, "video");
                  },
                  child: Text("Yes"))
            ],
          );
        });
  }

  showAudioCallRequestDialog(
      BuildContext context, String patientIDP, patientName, doctorImage) {
    var title = "Do you want to send Audio call request?";
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    requestCallFromDoctor(
                        patientIDP, patientName, doctorImage, "audio");
                  },
                  child: Text("Yes"))
            ],
          );
        });
  }

  Future<void> _handlePermission(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  void getMyPatientsList(BuildContext context) async {
    listMyPatients = [];
    listMyPatientsSearchResults = [];
    String loginUrl = "${baseURL}doctorPatientList.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();

    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

    debugPrint(jsonStr);
    debugPrint(loginUrl);
    debugPrint("---------------------------------------------");

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
    pr!.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listMyPatients.add(ModelMyPatients(
          jo['PatientIDP'],
          jo['FName'],
          jo['MiddleName'],
          jo['LName'],
          jo['Gender'],
          jo['Age'],
          jo['MobileNo'],
          jo['CityName'],
          jo['PatientID'],
          jo['Image'],
          jo['HealthRecordsDisplayStatus'],
          jo['NotificationDisplayStatus'],
        ));
      }
      listMyPatientsSearchResults = listMyPatients;
      setState(() {});
    }
  }

  void getAllPatientFields(String patientIDPOrg, BuildContext context) async {
    String loginUrl = "${baseURL}doctorPatientData.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);

    String jsonStr = "{" +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDPOrg +
        "\"" +
        "}";

    debugPrint(jsonStr);
    debugPrint("---------------------------------------------");

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
    pr!.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      final jo = jsonData[0];
      /*Navigator.of(context).push(PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 500),
          pageBuilder: (context, _, __) {
            return SelectedPatientScreen(
              patientIDPOrg,
              "selectedPatient_qr_scanned",
            );
          }));*/
      setState(() {});
    }
  }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    //var base64str =
    return base64.encode(bytes);
    //= Base64Encoder().convert()
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }

  void getChannelIDForVideoCall(
      String patientIDP, String patientName, String startOrEnd) async {
    final String urlGetChannelIDForVidCall = "${baseURL}videocall.php";
    ProgressDialog pr = ProgressDialog(context);
    pr.show();

    try {
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      String doctorIDP = await getPatientOrDoctorIDP();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String fromType = "";
      if (userType == "patient") {
        fromType = "P";
      } else if (userType == "doctor") {
        fromType = "D";
      }
      String startOrEndCall = "";
      if (startOrEnd == "0") {
        startOrEndCall = "startcall";
      } else if (startOrEnd == "1") {
        startOrEndCall = "endcall";
      }
      String jsonStr = "{" +
          "\"PatientIDP\":\"$patientIDP\"" +
          ",\"DoctorIDP\":\"$doctorIDP\"" +
          ",\"FromType\":\"$fromType\"" +
          ",\"CallType\":\"$startOrEndCall\"" +
          /*"PatientIDP" +
          "\"" +
          ":" +
          "\"" +
          patientIDP +
          "\"" +*/
          "}";

      debugPrint(jsonStr);

      String encodedJSONStr = encodeBase64(jsonStr);
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: urlGetChannelIDForVidCall,
        headers: {
          "u": patientUniqueKey,
          "type": userType,
        },
        body: {"getjson": encodedJSONStr},
      );
      debugPrint(response.body.toString());
      final jsonResponse = json.decode(response.body.toString());
      ResponseModel model = ResponseModel.fromJSON(jsonResponse);
      pr.hide();
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array : " + strData);
        final jsonData = json.decode(strData);
        //debugPrint("Got height value - ${jsonData[0]['Height']}");
        await _handlePermission(Permission.camera);
        await _handlePermission(Permission.microphone);
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        //   return VideoCallScreen(
        //     patientIDP: patientIDP,
        //     channelID: jsonData[0]['VideoID'].toString(),
        //   );
        // }));
        setState(() {});
      } else {}
    } catch (exception) {}
  }

  void requestCallFromDoctor(String patientIDP, String patientName,
      String doctorImage, String type) async {
    String urlGetChannelIDForVidCall = "${baseURL}videocallRequest.php";
    if (type == "audio")
      urlGetChannelIDForVidCall = "${baseURL}audioCallRequest.php";
    ProgressDialog pr = ProgressDialog(context);
    pr.show();

    try {
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      String doctorIDP = await getPatientOrDoctorIDP();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String fromType = "";
      if (userType == "patient") {
        fromType = "P";
      } else if (userType == "doctor") {
        fromType = "D";
      }
      String jsonStr = "{" +
          "\"PatientIDP\":\"$patientIDP\"" +
          ",\"DoctorIDP\":\"$doctorIDP\"" +
          ",\"messagefrom\":\"$fromType\"" +
          "}";

      debugPrint(jsonStr);

      String encodedJSONStr = encodeBase64(jsonStr);
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: urlGetChannelIDForVidCall,
        //Uri.parse(loginUrl),
        headers: {
          "u": patientUniqueKey,
          "type": userType,
        },
        body: {"getjson": encodedJSONStr},
      );
      debugPrint(response.body.toString());
      final jsonResponse = json.decode(response.body.toString());
      ResponseModel model = ResponseModel.fromJSON(jsonResponse);
      pr.hide();
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array : " + strData);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return ChatScreen(
              patientIDP: patientIDP,
              patientName: patientName,
              patientImage: doctorImage,
            );
          },
        ));
      } else {}
    } catch (exception) {}
  }
}
