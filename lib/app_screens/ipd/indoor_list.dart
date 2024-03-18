import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:silvertouch/app_screens/add_patient_screen.dart';
import 'package:silvertouch/app_screens/ipd/indoor_list_icon_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_indoorlist.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/widgets/blinking_card.dart';

class IndoorListScreen extends StatefulWidget {

  String selectedOrganizationName = '';
  String imgUrl = "";
  // const SwitchOrganizationView({super.key});


  @override
  State<IndoorListScreen> createState() => _IndoorListScreenState();
}

class _IndoorListScreenState extends State<IndoorListScreen> {

  List<PatientDetails> listForIndoorPatient = [];
  String emptyMessage = "";
  Widget? emptyMessageWidget;
  TextEditingController _searchController = TextEditingController();
  List<PatientDetails> _filteredPatients = []; // Holds filtered patients

  @override
  void initState() {
    // selectedOrganizationName;
    getIndoorList();
    _filteredPatients = listForIndoorPatient;
    emptyMessageWidget = SizedBox(
      height: SizeConfig.blockSizeVertical !* 80,
      child: Container(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage("images/ic_idea_new.png"),
              width: 100,
              height: 100,
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              "$emptyMessage",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
    super.initState();
  }

  void _filterPatients(String query) {
    setState(() {
      _filteredPatients = listForIndoorPatient
          .where((patient) =>
      patient.firstName!.toLowerCase().contains(query.toLowerCase()) ||
          patient.lastName!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IPD List"),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(
            color: Colorsblack, size: SizeConfig.blockSizeVertical !* 2.2), toolbarTextStyle: TextTheme(
          titleMedium: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5)).bodyMedium, titleTextStyle: TextTheme(
          titleMedium: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5)).titleLarge,
      ),
      body: Builder(builder: (context) {
        return Container(
          color: colorGrayApp,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 2,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
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
                    onChanged: _filterPatients,
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
              // Padding(
              //   padding: const EdgeInsets.all(12.0),
              //   child: TextField(
              //   controller: _searchController,
              //   decoration: InputDecoration(
              //     hintText: 'Search Patients...',
              //   ),
              //   onChanged: _filterPatients,
              //               ),
              // ),
              SizedBox(height: SizeConfig.blockSizeHorizontal !* 3),
              Container(
                child: Row(
                  children: [
                    SizedBox(width: SizeConfig.blockSizeHorizontal !* 5),
                    Container(
                      width: SizeConfig.blockSizeHorizontal !* 7, // Adjust width of the box
                      height: SizeConfig.blockSizeHorizontal !* 7, // Adjust height of the box
                      color: Color(0xFFC3C3C3), // Set color of the box
                    ),
                    Text(
                      " Available Bed: ",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig
                              .blockSizeHorizontal !*
                              4,
                          fontWeight:
                          FontWeight
                              .w500),
                    ),
                    SizedBox(width: SizeConfig.blockSizeHorizontal !* 3), // Adjust spacing as needed
                    Container(
                      width: SizeConfig.blockSizeHorizontal !* 7, // Adjust width of the box
                      height: SizeConfig.blockSizeHorizontal !* 7, // Adjust height of the box
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "  Occupied Bed: ",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig
                              .blockSizeHorizontal !*
                              4,
                          fontWeight:
                          FontWeight
                              .w500),
                    ),
                    SizedBox(width: SizeConfig.blockSizeHorizontal !* 3), // Adjust spacing as needed

                  ],
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeHorizontal !* 3),
              Expanded(
                child: _filteredPatients.length > 0
                    ?
                RefreshIndicator(
                    child: ListView.builder(
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          var patientDetails = _filteredPatients[index];
                          if (patientDetails.firstName == "" || patientDetails.firstName == null) {
                            return Padding(
                                padding: EdgeInsets.only(
                                    left: SizeConfig.blockSizeHorizontal ! *
                                        2,
                                    right: SizeConfig.blockSizeHorizontal ! *
                                        2,
                                    top: SizeConfig.blockSizeHorizontal ! *
                                        2),
                                child: InkWell(
                                  onTap: () {},
                                  child: Card(
                                      color:
                                      // Colors.white,
                                      Color(0xFFC3C3C3),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(15.0),
                                          side: BorderSide(
                                            color:
                                            Colors.white,
                                          )),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height: SizeConfig
                                                  .blockSizeVertical ! * 0.5,
                                            ),
                                            SizedBox(
                                              height: SizeConfig
                                                  .blockSizeVertical ! *
                                                  1.5,
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: SizeConfig
                                                        .blockSizeHorizontal ! *
                                                        2,
                                                  ),
                                                  Text(
                                                    "Room No.${patientDetails.roomNumber}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: SizeConfig
                                                            .blockSizeHorizontal ! *
                                                            4,
                                                        fontWeight:
                                                        FontWeight
                                                            .w500),
                                                  ),

                                                  SizedBox(
                                                    width: SizeConfig
                                                        .blockSizeHorizontal ! *
                                                        4.0,
                                                  ),
                                                  Text(
                                                    "Bed:${patientDetails
                                                        .roomBed}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: SizeConfig
                                                            .blockSizeHorizontal ! *
                                                            4,
                                                        fontWeight:
                                                        FontWeight
                                                            .w500),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: SizeConfig
                                                  .blockSizeVertical ! *
                                                  1.5,
                                            ),
                                          ],
                                        ),
                                      )
                                  ),
                                ));
                          }
                          else if ( patientDetails.firstName != "") {
                            return  Padding(
                                padding: EdgeInsets.only(
                                    left: SizeConfig.blockSizeHorizontal ! *
                                        2,
                                    right: SizeConfig.blockSizeHorizontal ! *
                                        2,
                                    top: SizeConfig.blockSizeHorizontal ! *
                                        2),
                                child: InkWell(
                                  onTap: () {
                                    if (patientDetails
                                        .patientIndoorIDP!.isNotEmpty) {
                                      getUserType().then((value) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                IndoorListIconScreen(
                                                  patientindooridp: patientDetails
                                                      .patientIndoorIDP
                                                      .toString(),
                                                  PatientIDP: patientDetails
                                                      .patientIDF.toString(),
                                                  doctoridp: patientDetails
                                                      .doctorIDF.toString(),
                                                  firstname: patientDetails
                                                      .firstName.toString(),
                                                  lastName: patientDetails
                                                      .lastName.toString(),
                                                  RoomBedIDP:  patientDetails
                                                      .roomBedIDP.toString(),
                                                  allowFlag: patientDetails
                                                      .allowFlag.toString(),
                                                  PlanofManagement: patientDetails
                                                      .planOfManagement.toString(),
                                                ),
                                          ),
                                        );
                                      });
                                    }
                                  },
                                  child: patientDetails.allowFlag.toString() == "0" ?
                                  BlinkingCard(
                                    blinkDuration: Duration(milliseconds: 700),
                                    child: Card(
                                        color: Colors.red,
                                        // Color(0xFFC3C3C3),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(15.0),
                                            side: BorderSide(
                                              color: Colors.white,
                                            )),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: <Widget>[
                                              SizedBox(
                                                height: SizeConfig
                                                    .blockSizeVertical ! * 0.5,
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "${patientDetails
                                                          .firstName!} ${patientDetails
                                                          .lastName!}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: SizeConfig
                                                              .blockSizeHorizontal ! *
                                                              4,
                                                          fontWeight:
                                                          FontWeight.w600),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: SizeConfig
                                                        .blockSizeHorizontal ! *
                                                        3,
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.all(
                                                          SizeConfig
                                                              .blockSizeHorizontal ! *
                                                              0),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: SizeConfig
                                                                .blockSizeHorizontal ! *
                                                                3.0,
                                                          ),
                                                          Container(),
                                                          Container(),
                                                          SizedBox(
                                                            width: SizeConfig
                                                                .blockSizeHorizontal ! *
                                                                3.0,
                                                          ),
                                                          InkWell(
                                                            onTap: () {},
                                                            customBorder:
                                                            CircleBorder(),
                                                            child: Container(
                                                                padding: EdgeInsets
                                                                    .all(
                                                                    SizeConfig
                                                                        .blockSizeHorizontal ! *
                                                                        2.0),
                                                                child: Text(
                                                                  "Date: ${patientDetails
                                                                      .admitDt}",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize: SizeConfig
                                                                          .blockSizeHorizontal ! *
                                                                          4,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                                )
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: SizeConfig
                                                                .blockSizeHorizontal ! *
                                                                3.0,
                                                          ),
                                                          // InkWell(
                                                          //     onTap: () {
                                                          //       preparePdfList(
                                                          //           listForIndoorPatient[
                                                          //           index]);
                                                          //       showPdfTypeSelectionDialog(
                                                          //         listPdfType,
                                                          //         listForIndoorPatient[
                                                          //         index],
                                                          //         context,
                                                          //       );
                                                          //     },
                                                          //     customBorder:
                                                          //     CircleBorder(),
                                                          //     child: Container(
                                                          //       padding: EdgeInsets
                                                          //           .all(SizeConfig
                                                          //           .blockSizeHorizontal !*
                                                          //           2.0),
                                                          //       child: Image(
                                                          //           width: SizeConfig
                                                          //               .blockSizeHorizontal !*
                                                          //               4,
                                                          //           height: SizeConfig
                                                          //               .blockSizeHorizontal !*
                                                          //               4,
                                                          //           image: AssetImage(
                                                          //             "images/icn-download-fees.png",
                                                          //           )),
                                                          //     )),
                                                        ],
                                                      )),
                                                  /*InkWell(
                                                onTap: () {
                                                  if (listOPDRegistration[index]
                                                          .checkOutStatus ==
                                                      "1") {
                                                    getPdfDownloadPath(
                                                        context,
                                                        listOPDRegistration[index]
                                                            .idp,
                                                        listOPDRegistration[index]
                                                            .patientIDP);
                                                  } else {
                                                    final snackBar = SnackBar(
                                                      backgroundColor: Colors.red,
                                                      content: Text(
                                                          "Please checkout this patient to view the document."),
                                                    );
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(snackBar);
                                                  }
                                                },
                                                child: Image(
                                                  image: AssetImage(
                                                      "images/ic_pdf_opd_reg.png"),
                                                  width: SizeConfig
                                                          .blockSizeHorizontal *
                                                      8,
                                                ),
                                              )*/
                                                ],
                                              ),
                                              SizedBox(
                                                height: SizeConfig
                                                    .blockSizeVertical ! *
                                                    1.5,
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: SizeConfig
                                                          .blockSizeHorizontal ! *
                                                          2,
                                                    ),
                                                    Text(
                                                      "Room No.${patientDetails
                                                          .roomNumber}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: SizeConfig
                                                              .blockSizeHorizontal ! *
                                                              4,
                                                          fontWeight:
                                                          FontWeight
                                                              .w500),
                                                    ),

                                                    SizedBox(
                                                      width: SizeConfig
                                                          .blockSizeHorizontal ! *
                                                          4.0,
                                                    ),
                                                    Text(
                                                      "Bed:${patientDetails
                                                          .roomBed}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: SizeConfig
                                                              .blockSizeHorizontal ! *
                                                              4,
                                                          fontWeight:
                                                          FontWeight
                                                              .w500),
                                                    ),




                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: SizeConfig
                                                    .blockSizeVertical ! *
                                                    1.5,
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: SizeConfig
                                                        .blockSizeHorizontal ! *
                                                        4.0,
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Catagory: ${patientDetails
                                                          .patientCategoryName}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: SizeConfig
                                                              .blockSizeHorizontal ! *
                                                              4,
                                                          fontWeight:
                                                          FontWeight
                                                              .w500),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(
                                                height: SizeConfig
                                                    .blockSizeVertical ! *
                                                    1.5,
                                              ),
                                              Align(
                                                  alignment: Alignment
                                                      .centerLeft,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Dr.${patientDetails
                                                            .doctorFirstName} ${patientDetails
                                                            .doctorMiddleName} ${patientDetails
                                                            .doctorLastName}",
                                                        style: TextStyle(
                                                            color:
                                                            Colors.white,
                                                            fontSize: SizeConfig
                                                                .blockSizeHorizontal ! *
                                                                4,
                                                            fontWeight:
                                                            FontWeight
                                                                .w500),
                                                      ),
                                                      SizedBox(
                                                        width: SizeConfig
                                                            .blockSizeHorizontal ! *
                                                            8.0,
                                                      ),
                                                      Text(
                                                        "${patientDetails
                                                            .invoiceAmount}/-",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: SizeConfig
                                                                .blockSizeHorizontal ! *
                                                                3.5,
                                                            fontWeight:
                                                            FontWeight.w500),
                                                      ),
                                                      SizedBox(
                                                        width: SizeConfig
                                                            .blockSizeHorizontal ! *
                                                            2.0,
                                                      ),
                                                    ],
                                                  )
                                              ),
                                              Visibility(
                                                visible: patientDetails
                                                    .reffDoctorName!.isNotEmpty
                                                    &&
                                                    patientDetails
                                                        .refferPatient!
                                                        .isNotEmpty,
                                                child: Align(
                                                    alignment: Alignment
                                                        .centerLeft,
                                                    child: Row(
                                                      children: [

                                                        SizedBox(
                                                          width: SizeConfig
                                                              .blockSizeHorizontal ! *
                                                              2,
                                                        ),
                                                        Text(
                                                          "Dr.${patientDetails
                                                              .reffDoctorName}",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white,
                                                              fontSize: SizeConfig
                                                                  .blockSizeHorizontal ! *
                                                                  4,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w500),
                                                        ),
                                                        SizedBox(
                                                          width: SizeConfig
                                                              .blockSizeHorizontal ! *
                                                              8.0,
                                                        ),
                                                        Text(
                                                          "${patientDetails
                                                              .refferPatient}",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white,
                                                              fontSize: SizeConfig
                                                                  .blockSizeHorizontal ! *
                                                                  3.5,
                                                              fontWeight:
                                                              FontWeight.w500),
                                                        ),
                                                        SizedBox(
                                                          width: SizeConfig
                                                              .blockSizeHorizontal ! *
                                                              2.0,
                                                        ),
                                                      ],
                                                    )
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                    ),
                                  )
                                      : Card(
                                      color: Colors.white,
                                      // Color(0xFFC3C3C3),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(15.0),
                                          side: BorderSide(
                                            color: Colors.white,
                                          )),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height: SizeConfig
                                                  .blockSizeVertical ! * 0.5,
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "${patientDetails
                                                        .firstName!} ${patientDetails
                                                        .lastName!}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: SizeConfig
                                                            .blockSizeHorizontal ! *
                                                            4,
                                                        fontWeight:
                                                        FontWeight.w600),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: SizeConfig
                                                      .blockSizeHorizontal ! *
                                                      3,
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.all(
                                                        SizeConfig
                                                            .blockSizeHorizontal ! *
                                                            0),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width: SizeConfig
                                                              .blockSizeHorizontal ! *
                                                              3.0,
                                                        ),
                                                        Container(),
                                                        Container(),
                                                        SizedBox(
                                                          width: SizeConfig
                                                              .blockSizeHorizontal ! *
                                                              3.0,
                                                        ),
                                                        InkWell(
                                                          onTap: () {},
                                                          customBorder:
                                                          CircleBorder(),
                                                          child: Container(
                                                              padding: EdgeInsets
                                                                  .all(
                                                                  SizeConfig
                                                                      .blockSizeHorizontal ! *
                                                                      2.0),
                                                              child: Text(
                                                                "Date: ${patientDetails
                                                                    .admitDt}",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize: SizeConfig
                                                                        .blockSizeHorizontal ! *
                                                                        4,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                              )
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: SizeConfig
                                                              .blockSizeHorizontal ! *
                                                              3.0,
                                                        ),
                                                      ],
                                                    )),
                                              ],
                                            ),
                                            SizedBox(
                                              height: SizeConfig
                                                  .blockSizeVertical ! *
                                                  1.5,
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: SizeConfig
                                                        .blockSizeHorizontal ! *
                                                        2,
                                                  ),
                                                  Text(
                                                    "Room No.${patientDetails
                                                        .roomNumber}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: SizeConfig
                                                            .blockSizeHorizontal ! *
                                                            4,
                                                        fontWeight:
                                                        FontWeight
                                                            .w500),
                                                  ),

                                                  SizedBox(
                                                    width: SizeConfig
                                                        .blockSizeHorizontal ! *
                                                        4.0,
                                                  ),
                                                  Text(
                                                    "Bed:${patientDetails
                                                        .roomBed}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: SizeConfig
                                                            .blockSizeHorizontal ! *
                                                            4,
                                                        fontWeight:
                                                        FontWeight
                                                            .w500),
                                                  ),



                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: SizeConfig
                                                  .blockSizeVertical ! *
                                                  1.5,
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: SizeConfig
                                                      .blockSizeHorizontal ! *
                                                      4.0,
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "Catagory: ${patientDetails
                                                        .patientCategoryName}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: SizeConfig
                                                            .blockSizeHorizontal ! *
                                                            4,
                                                        fontWeight:
                                                        FontWeight
                                                            .w500),
                                                  ),
                                                ),

                                              ],
                                            ),
                                            SizedBox(
                                              height: SizeConfig
                                                  .blockSizeVertical ! *
                                                  1.5,
                                            ),
                                            Align(
                                                alignment: Alignment
                                                    .centerLeft,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Dr.${patientDetails
                                                          .doctorFirstName} ${patientDetails
                                                          .doctorMiddleName} ${patientDetails
                                                          .doctorLastName}",
                                                      style: TextStyle(
                                                          color:
                                                          colorBlueApp,
                                                          fontSize: SizeConfig
                                                              .blockSizeHorizontal ! *
                                                              4,
                                                          fontWeight:
                                                          FontWeight
                                                              .w500),
                                                    ),
                                                    SizedBox(
                                                      width: SizeConfig
                                                          .blockSizeHorizontal ! *
                                                          8.0,
                                                    ),
                                                    Text(
                                                      "${patientDetails
                                                          .invoiceAmount}/-",
                                                      style: TextStyle(
                                                          color: colorBlueApp,
                                                          fontSize: SizeConfig
                                                              .blockSizeHorizontal ! *
                                                              3.5,
                                                          fontWeight:
                                                          FontWeight.w500),
                                                    ),
                                                    SizedBox(
                                                      width: SizeConfig
                                                          .blockSizeHorizontal ! *
                                                          2.0,
                                                    ),
                                                  ],
                                                )
                                            ),
                                            Visibility(
                                              visible: patientDetails
                                                  .reffDoctorName!.isNotEmpty
                                                  &&
                                                  patientDetails
                                                      .refferPatient!
                                                      .isNotEmpty,
                                              child: Align(
                                                  alignment: Alignment
                                                      .centerLeft,
                                                  child: Row(
                                                    children: [

                                                      SizedBox(
                                                        width: SizeConfig
                                                            .blockSizeHorizontal ! *
                                                            2,
                                                      ),
                                                      Text(
                                                        "Dr.${patientDetails
                                                            .reffDoctorName}",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .black,
                                                            fontSize: SizeConfig
                                                                .blockSizeHorizontal ! *
                                                                4,
                                                            fontWeight:
                                                            FontWeight
                                                                .w500),
                                                      ),
                                                      SizedBox(
                                                        width: SizeConfig
                                                            .blockSizeHorizontal ! *
                                                            8.0,
                                                      ),
                                                      Text(
                                                        "${patientDetails
                                                            .refferPatient}",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .black,
                                                            fontSize: SizeConfig
                                                                .blockSizeHorizontal ! *
                                                                3.5,
                                                            fontWeight:
                                                            FontWeight.w500),
                                                      ),
                                                      SizedBox(
                                                        width: SizeConfig
                                                            .blockSizeHorizontal ! *
                                                            2.0,
                                                      ),
                                                    ],
                                                  )
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                  ),
                                ));
                          }
                          else{
                            return SizedBox.shrink();
                          }
                        }),
                    onRefresh: () {
                      return getIndoorList();
                    })
                    : emptyMessageWidget!,
              )
            ],
          ),
        );
        //   SingleChildScrollView(
        //   child:
        //   Container(
        //     decoration: BoxDecoration(
        //       border: Border(
        //         bottom: BorderSide(width: 1.0, color: Colors.black),
        //         top: BorderSide(width: 1.0, color: Colors.black),
        //       ),
        //     ),
        //     child: SingleChildScrollView(
        //       scrollDirection: Axis.horizontal,
        //       child: DataTable(
        //         columnSpacing: 25.0,
        //         columns: [
        //           DataColumn(label: Text('',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontFamily: "Ubuntu",
        //               fontSize: SizeConfig.blockSizeVertical! * 2.5,
        //             ),)),
        //           DataColumn(label: Text('Room No.',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontFamily: "Ubuntu",
        //               fontSize: SizeConfig.blockSizeVertical! * 2.5,
        //             ),)),
        //           DataColumn(label: Text('Bed No.',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontFamily: "Ubuntu",
        //               fontSize: SizeConfig.blockSizeVertical! * 2.5,
        //             ),)),
        //           DataColumn(label: Text('Charge Category',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontFamily: "Ubuntu",
        //               fontSize: SizeConfig.blockSizeVertical! * 2.5,
        //             ),)),
        //           DataColumn(label: Text('Admission Date',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontFamily: "Ubuntu",
        //               fontSize: SizeConfig.blockSizeVertical! * 2.5,
        //             ),)),
        //           DataColumn(label: Text('Patient Name',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontFamily: "Ubuntu",
        //               fontSize: SizeConfig.blockSizeVertical! * 2.5,
        //             ),)),
        //           DataColumn(label: Text('Doctor Name',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontFamily: "Ubuntu",
        //               fontSize: SizeConfig.blockSizeVertical! * 2.5,
        //             ),)),
        //           DataColumn(label: Text('Referring Doctor Name',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontFamily: "Ubuntu",
        //               fontSize: SizeConfig.blockSizeVertical! * 2.5,
        //             ),)),
        //           DataColumn(label: Text('Referring Patient Name',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontFamily: "Ubuntu",
        //               fontSize: SizeConfig.blockSizeVertical! * 2.5,
        //             ),)),
        //           DataColumn(label: Text('Balance Amount',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontFamily: "Ubuntu",
        //               fontSize: SizeConfig.blockSizeVertical! * 2.5,
        //             ),)),
        //           DataColumn(label: Text('Status',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontFamily: "Ubuntu",
        //               fontSize: SizeConfig.blockSizeVertical! * 2.5,
        //             ),)),
        //           // Add more DataColumn widgets based on your requirements
        //         ],
        //         rows: listForIndoorPatient.map((patient) {
        //           return DataRow(
        //             cells: [
        //               DataCell(
        //                   GestureDetector(
        //                     onTap: (){
        //                       if(patient.admitDt!.isNotEmpty) {
        //                         Navigator.of(context).push(
        //                           MaterialPageRoute(
        //                             builder: (context) => IndoorListIconScreen(
        //                               patientindooridp: patient.patientIndoorIDP.toString(),
        //                               PatientIDP: patient.patientIDF.toString(),
        //                               doctoridp: patient.doctorIDF.toString(),
        //                               firstname: patient.firstName.toString(),
        //                               lastName: patient.lastName.toString(),
        //                               // patientindooridp: patient['InvoiceAmount'].toString(),
        //                             ),
        //                           ),
        //                         );
        //                       }
        //                     },
        //                     child: Row(
        //                       children: [
        //                         Center(
        //                             child: Icon(Icons.navigate_next)),
        //                       ],
        //                     ),
        //                   )),
        //               DataCell(
        //                   GestureDetector(
        //                       onTap: (){
        //                         if(patient.admitDt!.isNotEmpty) {
        //                           Navigator.of(context).push(
        //                             MaterialPageRoute(
        //                               builder: (context) => IndoorListIconScreen(
        //                                 patientindooridp: patient.patientIndoorIDP.toString(),
        //                                 PatientIDP: patient.patientIDF.toString(),
        //                                 doctoridp: patient.doctorIDF.toString(),
        //                                 firstname: patient.firstName.toString(),
        //                                 lastName: patient.lastName.toString(),
        //                                 // patientindooridp: patient['InvoiceAmount'].toString(),
        //                               ),
        //                             ),
        //                           );
        //                         }
        //                       },
        //                       child: Text(patient.roomNumber.toString()))),
        //               DataCell(
        //                   GestureDetector(
        //                       onTap: (){
        //                         if(patient.admitDt!.isNotEmpty) {
        //                           Navigator.of(context).push(
        //                             MaterialPageRoute(
        //                               builder: (context) => IndoorListIconScreen(
        //                                 patientindooridp: patient.patientIndoorIDP.toString(),
        //                                 PatientIDP: patient.patientIDF.toString(),
        //                                 doctoridp: patient.doctorIDF.toString(),
        //                                 firstname: patient.firstName.toString(),
        //                                 lastName: patient.lastName.toString(),
        //                                 // patientindooridp: patient['InvoiceAmount'].toString(),
        //                               ),
        //                             ),
        //                           );
        //                         }
        //                       },
        //                       child: Text(patient.roomBed.toString()))),
        //               DataCell(
        //                   GestureDetector(
        //                       onTap: (){
        //                         if(patient.admitDt!.isNotEmpty) {
        //                           Navigator.of(context).push(
        //                             MaterialPageRoute(
        //                               builder: (context) => IndoorListIconScreen(
        //                                 patientindooridp: patient.patientIndoorIDP.toString(),
        //                                 PatientIDP: patient.patientIDF.toString(),
        //                                 doctoridp: patient.doctorIDF.toString(),
        //                                 firstname: patient.firstName.toString(),
        //                                 lastName: patient.lastName.toString(),
        //                                 // patientindooridp: patient['InvoiceAmount'].toString(),
        //                               ),
        //                             ),
        //                           );
        //                         }
        //                       },
        //                       child: Text(patient.patientCategoryName.toString()))),
        //               DataCell(
        //                   GestureDetector(
        //                       onTap: (){
        //                         if(patient.admitDt!.isNotEmpty) {
        //                           Navigator.of(context).push(
        //                             MaterialPageRoute(
        //                               builder: (context) =>
        //                                   IndoorListIconScreen(
        //                                     patientindooridp: patient.patientIndoorIDP.toString(),
        //                                     PatientIDP: patient.patientIDF.toString(),
        //                                     doctoridp: patient.doctorIDF.toString(),
        //                                     firstname: patient.firstName.toString(),
        //                                     lastName: patient.lastName.toString(),
        //                                     // patientindooridp: patient['InvoiceAmount'].toString(),
        //                                   ),
        //                             ),
        //                           );
        //                         }
        //                       },
        //                       child: Text(patient.admitDt.toString()))),
        //               DataCell(
        //                   GestureDetector(
        //                       onTap: (){
        //                         if(patient.admitDt!.isNotEmpty) {
        //                           Navigator.of(context).push(
        //                             MaterialPageRoute(
        //                               builder: (context) => IndoorListIconScreen(
        //                                 patientindooridp: patient.patientIndoorIDP.toString(),
        //                                 PatientIDP: patient.patientIDF.toString(),
        //                                 doctoridp: patient.doctorIDF.toString(),
        //                                 firstname: patient.firstName.toString(),
        //                                 lastName: patient.lastName.toString(),
        //                                 // patientindooridp: patient['InvoiceAmount'].toString(),
        //                               ),
        //                             ),
        //                           );
        //                         }
        //                       },
        //                       child: Text('${patient.firstName} ${patient.lastName}'))),
        //               DataCell(
        //                   GestureDetector(
        //                       onTap: (){
        //                         if(patient.admitDt!.isNotEmpty) {
        //                           Navigator.of(context).push(
        //                             MaterialPageRoute(
        //                               builder: (context) => IndoorListIconScreen(
        //                                 patientindooridp: patient.patientIndoorIDP.toString(),
        //                                 PatientIDP: patient.patientIDF.toString(),
        //                                 doctoridp: patient.doctorIDF.toString(),
        //                                 firstname: patient.firstName.toString(),
        //                                 lastName: patient.lastName.toString(),
        //                                 // patientindooridp: patient['InvoiceAmount'].toString(),
        //                               ),
        //                             ),
        //                           );
        //                         }
        //                       },
        //                       child: Text('${patient.doctorFirstName} ${patient.doctorMiddleName} ${patient.doctorLastName}'))),
        //               // DataCell(Text(patient['doctorfirstname'].toString() +
        //               //     patient['doctormiddlename'].toString() + patient['doctorlastname'].toString())),
        //               DataCell(
        //                   GestureDetector(
        //                       onTap: (){
        //                         if(patient.admitDt!.isNotEmpty) {
        //                           Navigator.of(context).push(
        //                             MaterialPageRoute(
        //                               builder: (context) => IndoorListIconScreen(
        //                                 patientindooridp: patient.patientIndoorIDP.toString(),
        //                                 PatientIDP: patient.patientIDF.toString(),
        //                                 doctoridp: patient.doctorIDF.toString(),
        //                                 firstname: patient.firstName.toString(),
        //                                 lastName: patient.lastName.toString(),
        //                                 // patientindooridp: patient['InvoiceAmount'].toString(),
        //                               ),
        //                             ),
        //                           );
        //                         }
        //                       },
        //                       child: Text(patient.reffDoctorName.toString()))),
        //               DataCell(
        //                   GestureDetector(
        //                       onTap: (){
        //                         if(patient.admitDt!.isNotEmpty) {
        //                           Navigator.of(context).push(
        //                             MaterialPageRoute(
        //                               builder: (context) => IndoorListIconScreen(
        //                                 patientindooridp: patient.patientIndoorIDP.toString(),
        //                                 PatientIDP: patient.patientIDF.toString(),
        //                                 doctoridp: patient.doctorIDF.toString(),
        //                                 firstname: patient.firstName.toString(),
        //                                 lastName: patient.lastName.toString(),
        //                                 // patientindooridp: patient['InvoiceAmount'].toString(),
        //                               ),
        //                             ),
        //                           );
        //                         }
        //                       },
        //                       child: Text(patient.refferPatient.toString()))),
        //               DataCell(
        //                   GestureDetector(
        //                       onTap: (){
        //                         if(patient.admitDt!.isNotEmpty) {
        //                           Navigator.of(context).push(
        //                             MaterialPageRoute(
        //                               builder: (context) => IndoorListIconScreen(
        //                                 patientindooridp: patient.patientIndoorIDP.toString(),
        //                                 PatientIDP: patient.patientIDF.toString(),
        //                                 doctoridp: patient.doctorIDF.toString(),
        //                                 firstname: patient.firstName.toString(),
        //                                 lastName: patient.lastName.toString(),
        //                                 // patientindooridp: patient['InvoiceAmount'].toString(),
        //                               ),
        //                             ),
        //                           );
        //                         }
        //                       },
        //                       child: Text(patient.invoiceAmount.toString()))),
        //               DataCell(
        //                   GestureDetector(
        //                       onTap: (){
        //                         if(patient.admitDt!.isNotEmpty) {
        //                           Navigator.of(context).push(
        //                             MaterialPageRoute(
        //                               builder: (context) => IndoorListIconScreen(
        //                                 patientindooridp: patient.patientIndoorIDP.toString(),
        //                                 PatientIDP: patient.patientIDF.toString(),
        //                                 doctoridp: patient.doctorIDF.toString(),
        //                                 firstname: patient.firstName.toString(),
        //                                 lastName: patient.lastName.toString(),
        //                               ),
        //                             ),
        //                           );
        //                         }
        //                       },
        //                       child:
        //                       Text(patient.admitDt!.isNotEmpty ?
        //                       "Occupied"
        //                           :"Available"
        //                       )
        //                   )
        //               ),
        //               // DataCell(Text(item.createdBy ?? '')),
        //             ],
        //           );
        //         }).toList(),
        //       ),
        //     ),
        //   ),
        // );
      },
      ),
    );
  }

  Future<void> getIndoorList() async {
    print('getIndoorList');

    listForIndoorPatient.clear();

    try{
      String loginUrl = "${baseURL}doctor_ipd_indoor_list.php";
      ProgressDialog pr = ProgressDialog(context);
      Future.delayed(Duration.zero, () {
        pr.show();
      });
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      String patientIDP = await getPatientOrDoctorIDP();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String jsonStr = "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

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

      pr.hide();

      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);

        // Replace '}' with '},'
        strData = strData.replaceAllMapped(
          RegExp('}{"Firstname":"'),
              (match) => '},{"Firstname":"',
        );

        debugPrint("Decoded Data List : " + strData);
        final jsonData = json.decode(strData);

        for (var i = 0; i < jsonData.length; i++) {
          final roomOccupied = RoomOccupied.fromJson(jsonData[i]);

          if (roomOccupied.nullList != null || roomOccupied.occupiedList != null) {
            if (roomOccupied.occupiedList != null) {
              listForIndoorPatient.addAll(roomOccupied.occupiedList!);
            }

            if (roomOccupied.nullList != null) {
              listForIndoorPatient.addAll(roomOccupied.nullList!);
            }

          }
          debugPrint("----------------------");


          for (var patientDetails in listForIndoorPatient) {
            debugPrint("Patient Details:");
            debugPrint("First Name: ${patientDetails.firstName}");
            debugPrint("Last Name: ${patientDetails.lastName}");
            debugPrint("Doctor First Name: ${patientDetails.doctorFirstName}");

            debugPrint("----------------------");
          }
        }
        // Add this section to manually set serial numbers
        // for (var i = 0; i < listForIndoorPatient.length; i++) {
        //   listForIndoorPatient[i].serialNumber = i + 1;
        // }

        //   final jo = jsonData[i];
        //   String roomBed = jo['RoomBed'].toString();
        //   String roomNumber = jo['RoomNumber'].toString();
        //   String roomBedIDP = jo['RoomBedIDP'].toString();
        //   String roomMasterIDP = jo['RoomMasterIDP'].toString();
        //   String PatientCategoryName = jo['PatientCategoryName'].toString();
        //   // String patientName = jo['Firstname'].toString() + jo['LastName'].toString();
        //   // String doctorName = jo['doctorfirstname'].toString() +jo['doctormiddlename'].toString() + jo['doctorlastname'].toString();
        //   String firstname = jo['Firstname'].toString();
        //   String lastName = jo['LastName'].toString();
        //   String doctorfirstname = jo['doctorfirstname'].toString();
        //   String doctorlastname = jo['doctorlastname'].toString();
        //   String doctormiddlename = jo['doctormiddlename'].toString();
        //   String admitDt = jo['AdmitDt'].toString();
        //   String planofManagement = jo['PlanofManagement'].toString();
        //   String summaryStatus = jo['SummaryStatus'].toString();
        //   String invoiceNumber = jo['InvoiceNumber'].toString();
        //   String paymentMode = jo['PaymentMode'].toString();
        //   String invoiceAmount = jo['InvoiceAmount'].toString();
        //   String paymentNarration = jo['PaymentNarration'].toString();
        //   String amount = jo['amount'].toString();
        //   String reffDoctorName = jo['ReffDoctorName'].toString();
        //   String allowflag = jo['allowflag'].toString();
        //   String RefferPatient = jo['RefferPatient'].toString();
        //
        //   Map<String, dynamic> OrganizationMap = {
        //     "RoomBed": roomBed,
        //     "RoomNumber": roomNumber,
        //     "RoomBedIDP" : roomBedIDP,
        //     "RoomMasterIDP" : roomMasterIDP,
        //     "PatientCategoryName" : PatientCategoryName,
        //     // "PatientName" : patientName,
        //     // "DoctorName" : doctorName,
        //     "Firstname": firstname,
        //     "LastName": lastName,
        //     "doctorfirstname": doctorfirstname,
        //     "doctorlastname": doctorlastname,
        //     "doctormiddlename": doctormiddlename,
        //     "AdmitDt": admitDt,
        //     "PlanofManagement": planofManagement,
        //     "SummaryStatus": summaryStatus,
        //     "InvoiceNumber": invoiceNumber,
        //     "PaymentMode": paymentMode,
        //     "InvoiceAmount": invoiceAmount,
        //     "PaymentNarration": paymentNarration,
        //     "amount": amount,
        //     "ReffDoctorName": reffDoctorName,
        //     "allowflag": allowflag,
        //     "RefferPatient": RefferPatient,
        //   };
        //   listForIndoorPatient.add(OrganizationMap);
        //   // debugPrint("Added to list: $complainName");
        //
        // }
        setState(() {});
      }
    }catch (e) {
      print('Error decoding JSON: $e');
    }
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


