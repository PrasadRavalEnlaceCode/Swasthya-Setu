import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swasthyasetu/api/api_helper.dart';
import 'package:swasthyasetu/app_screens/doctor_dashboard_screen.dart';
import 'package:swasthyasetu/app_screens/investigation_view_report_screen.dart';
import 'package:swasthyasetu/app_screens/opd_registration_screen.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_investigation_list_doctor.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';

import '../global/SizeConfig.dart';
import '../utils/color.dart';
import '../utils/progress_dialog.dart';


class DoctorInvestigationListScreen extends StatefulWidget {

  @override
  State<DoctorInvestigationListScreen> createState() => _DoctorInvestigationListScreenState();
}

class _DoctorInvestigationListScreenState extends
State<DoctorInvestigationListScreen> {

  var fromDate = DateTime.now().subtract(Duration(days: 30));
  var toDate = DateTime.now();

  var fromDateString = "";
  var toDateString = "";
  var taskId;
  ProgressDialog? pr;
  late DateTimeRange dateRange;

  late String selectedOrganizationIDF;
  List<InvestigationItem> allInvestigations = [];
  List<Map<String, dynamic>> OPDInvestigationList = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> IPDInvestigationList = <Map<String, dynamic>>[];

  final sizeBox = SizedBox(width:30,height: 20,);

  @override
  void initState() {
    dateRange = DateTimeRange(
        start: fromDate,
        end: toDate);
    // getDoctorInvestigationOPD();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = dateRange.start;
    final end = dateRange.end;
    SizeConfig().init(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Investigation List"),
          bottom: TabBar( // Add a TabBar for the tabs
            tabs: [
              Tab(text: "OPD"),
              Tab(text: "IPD"),
            ],
          ),
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
        body: Builder(
          builder: (context) {
            return TabBarView(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: SizeConfig.blockSizeVertical !* 2,
                          ),
                          Container(
                            height: SizeConfig.blockSizeVertical !* 15.5,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Container(
                                child: InkWell(
                                    onTap: () {
                                      // showDateRangePickerDialog();
                                    },
                                    child: Column(
                                      children: [
                                        Row(
                                          children: <Widget>[

                                            Expanded(
                                                child: ElevatedButton(
                                                  child: Text('${start.day}-${start.month}-${start.year}'),
                                                  onPressed: pickDateRange,
                                                )
                                            ),
                                            const SizedBox(width: 10,),
                                            Expanded(
                                                child: ElevatedButton(
                                                  child: Text('${end.day}-${end.month}-${end.year}'),
                                                  onPressed: pickDateRange,
                                                )
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                        ),
                                        MaterialButton(
                                          onPressed: () {
                                            if (fromDate == "") {
                                              final snackBar = SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text("Please select Date Range"),
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              return;
                                            }
                                            else{
                                              getDoctorInvestigationOPD();
                                            }
                                          },
                                          color: Colors.blue,
                                          child: Text(
                                            "Submit",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),

                                      ],
                                    )),
                                padding: EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          OPDInvestigationList.length > 0
                              ?
                          RefreshIndicator(
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: OPDInvestigationList.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                        padding: EdgeInsets.only(
                                            left: SizeConfig.blockSizeHorizontal !* 2,
                                            right: SizeConfig.blockSizeHorizontal !* 2,
                                            top: SizeConfig.blockSizeHorizontal !* 2),
                                        child: InkWell(
                                          onTap: (){
                                            OPDInvestigationList[index]['labstatus'] == "new"
                                                ? Container()
                                                : Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    InvestigationViewReportScreen(
                                                        id: OPDInvestigationList[index]['id'],
                                                        // INID: OPDInvestigationList[index]['labstatus'],
                                                        PATID: OPDInvestigationList[index]['PATID'],
                                                        OPD: "OPD",
                                                        // ipd: OPDInvestigationList[index]['labstatus'],
                                                        pathology: OPDInvestigationList[index]['TYPE'],
                                                        HospitalConsultationIDP: OPDInvestigationList[index]['HospitalConsultationIDP']
                                                            ),
                                              ),
                                            );
                                          },
                                          child: Card(
                                              color: OPDInvestigationList[index]['labstatus'] == "new"
                                              ? Colors.white
                                              : Color(0xFFC3C3C3),
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
                                                      height: SizeConfig.blockSizeVertical !* 0.5,
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          "${OPDInvestigationList[index]['Patient']}",
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: SizeConfig
                                                                  .blockSizeHorizontal !*
                                                                  4,
                                                              fontWeight:
                                                              FontWeight.w600),
                                                        ),
                                                        SizedBox(
                                                          width: SizeConfig
                                                              .blockSizeHorizontal !*
                                                              18,
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            "Date: ${OPDInvestigationList[index]['S_date']}",
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                    4,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                          ),
                                                        ),
                                                        // Padding(
                                                        //     padding: EdgeInsets.all(SizeConfig
                                                        //         .blockSizeHorizontal !*
                                                        //         0),
                                                        //     child: Row(
                                                        //       children: [
                                                        //         SizedBox(
                                                        //           width: SizeConfig
                                                        //               .blockSizeHorizontal !*
                                                        //               3.0,
                                                        //         ),
                                                        //         InkWell(
                                                        //           onTap: () {},
                                                        //           customBorder:
                                                        //           CircleBorder(),
                                                        //           child: Container(
                                                        //               padding: EdgeInsets.all(
                                                        //                   SizeConfig
                                                        //                       .blockSizeHorizontal !*
                                                        //                       2.0),
                                                        //               child:
                                                        //
                                                        //               Text(
                                                        //                 "Date: ${OPDInvestigationList[index]['S_date']}",
                                                        //                 style: TextStyle(
                                                        //                     color: Colors.black,
                                                        //                     fontSize: SizeConfig
                                                        //                         .blockSizeHorizontal !*
                                                        //                         4,
                                                        //                     fontWeight:
                                                        //                     FontWeight
                                                        //                         .w500),
                                                        //               )
                                                        //
                                                        //           ),
                                                        //         ),
                                                        //         SizedBox(
                                                        //           width: SizeConfig
                                                        //               .blockSizeHorizontal !*
                                                        //               3.0,
                                                        //         ),
                                                        //
                                                        //       ],
                                                        //     )),
                                                      ],
                                                    ),


                                                    SizedBox(
                                                      height: SizeConfig.blockSizeVertical !*
                                                          2,
                                                    ),

                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: SizeConfig
                                                                .blockSizeHorizontal !*
                                                                2,
                                                          ),
                                                          Text(
                                                            "Type:${OPDInvestigationList[index]['TYPE']}",
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                    4,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                          ),

                                                          SizedBox(
                                                            width: SizeConfig
                                                                .blockSizeHorizontal !*
                                                                10.0,
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child: Text(
                                                              "Status: ${OPDInvestigationList[index]['labstatus']}",
                                                              style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: SizeConfig
                                                                      .blockSizeHorizontal !*
                                                                      4,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                            ),
                                                          ),

                                                          SizedBox(
                                                            width: SizeConfig
                                                                .blockSizeHorizontal !*
                                                                4.0,
                                                          ),
                                                          // Text(
                                                          //   "Catagory: ${OPDInvestigationList[index]['TYPE']}",
                                                          //   style: TextStyle(
                                                          //       color: Colors.black,
                                                          //       fontSize: SizeConfig
                                                          //           .blockSizeHorizontal !*
                                                          //           4,
                                                          //       fontWeight:
                                                          //       FontWeight
                                                          //           .w500),
                                                          // ),

                                                        ],
                                                      ),
                                                    ),

                                                    SizedBox(
                                                      height: SizeConfig.blockSizeVertical !*
                                                          2,
                                                    ),
                                                    Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "Dr.${OPDInvestigationList[index]['Doctor']}",
                                                              style: TextStyle(
                                                                  color:
                                                                  colorBlueApp,
                                                                  fontSize: SizeConfig
                                                                      .blockSizeHorizontal !*
                                                                      4,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                            ),
                                                            SizedBox(
                                                              width: SizeConfig
                                                                  .blockSizeHorizontal !*
                                                                  10.0,
                                                            ),
                                                          ],
                                                        )
                                                    ),
                                                    SizedBox(
                                                      height: SizeConfig.blockSizeVertical !*
                                                          2,
                                                    ),Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: SizeConfig
                                                                  .blockSizeHorizontal !*
                                                                  2.0,
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                "Created by:${OPDInvestigationList[index]['CreatedBy']}",
                                                                style: TextStyle(
                                                                    color: colorBlueApp,
                                                                    fontSize: SizeConfig
                                                                        .blockSizeHorizontal !*
                                                                        3.5,
                                                                    fontWeight:
                                                                    FontWeight.w500),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: SizeConfig
                                                                  .blockSizeHorizontal !*
                                                                  2.0,
                                                            ),
                                                          ],
                                                        )
                                                    ),
                                                    SizedBox(
                                                      height: SizeConfig.blockSizeVertical !*
                                                          2,
                                                    ),

                                                    Visibility(
                                                      // visible: OPDInvestigationList[index].reffDoctorName!.isNotEmpty
                                                      //     && OPDInvestigationList[index].refferPatient!.isNotEmpty,
                                                      child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Row(
                                                            children: [

                                                              SizedBox(
                                                                width: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                    2,
                                                              ),
                                                              Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                  "Investigation:${OPDInvestigationList[index]['OPDService']}",
                                                                  style: TextStyle(
                                                                      color: Colors.black,
                                                                      fontSize: SizeConfig
                                                                          .blockSizeHorizontal !*
                                                                          4,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                    8.0,
                                                              ),
                                                              // Text(
                                                              //   "${OPDInvestigationList[index]['TYPE']}",
                                                              //   style: TextStyle(
                                                              //       color: Colors.black,
                                                              //       fontSize: SizeConfig
                                                              //           .blockSizeHorizontal !*
                                                              //           3.5,
                                                              //       fontWeight:
                                                              //       FontWeight.w500),
                                                              // ),
                                                              SizedBox(
                                                                width: SizeConfig
                                                                    .blockSizeHorizontal !*
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
                                  }),
                              onRefresh: () {
                                return getDoctorInvestigationOPD();
                              })
                              : Container()
                        ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: SizeConfig.blockSizeVertical !* 2,
                          ),

                          Container(
                            height: SizeConfig.blockSizeVertical !* 15.5,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Container(
                                child: InkWell(
                                    onTap: () {
                                      // showDateRangePickerDialog();
                                    },
                                    child: Column(
                                      children: [
                                        Row(
                                          children: <Widget>[

                                            Expanded(
                                                child: ElevatedButton(
                                                  child: Text('${start.day}-${start.month}-${start.year}'),
                                                  onPressed: pickDateRange,
                                                )
                                            ),
                                            const SizedBox(width: 10,),
                                            Expanded(
                                                child: ElevatedButton(
                                                  child: Text('${end.day}-${end.month}-${end.year}'),
                                                  onPressed: pickDateRange,
                                                )
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                        ),
                                        // SizedBox(
                                        //   height: SizeConfig.blockSizeVertical !* 1.0,
                                        // ),
                                        MaterialButton(
                                          onPressed: () {
                                            if (fromDate == "") {
                                              final snackBar = SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text("Please select Date Range"),
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              return;
                                            }
                                            else{
                                              getDoctorInvestigationIPD();
                                            }
                                          },
                                          color: Colors.blue,
                                          child: Text(
                                            "Submit",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),

                                      ],
                                    )),
                                padding: EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),

                          IPDInvestigationList.length > 0
                              ?
                          RefreshIndicator(
                              child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: IPDInvestigationList.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                        padding: EdgeInsets.only(
                                            left: SizeConfig.blockSizeHorizontal !* 2,
                                            right: SizeConfig.blockSizeHorizontal !* 2,
                                            top: SizeConfig.blockSizeHorizontal !* 2),
                                        child: InkWell(
                                          onTap: (){
                                            IPDInvestigationList[index]['labstatus'] == "new"
                                                ? Container()
                                                : Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    InvestigationViewReportScreen(
                                                        id: IPDInvestigationList[index]['id'],
                                                        INID: IPDInvestigationList[index]['INID'],
                                                        PATID: IPDInvestigationList[index]['PATID'],
                                                        // OPD: "OPD",
                                                        ipd: "IPD",
                                                        pathology: IPDInvestigationList[index]['TYPE'],
                                                        // HospitalConsultationIDP: IPDInvestigationList[index]['HospitalConsultationIDP']
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Card(
                                              color: IPDInvestigationList[index]['labstatus'] == "new"
                                                  ? Colors.white
                                                  : Color(0xFFC3C3C3),
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
                                                      height: SizeConfig.blockSizeVertical !* 0.5,
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          "${IPDInvestigationList[index]['Patient']}",
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: SizeConfig
                                                                  .blockSizeHorizontal !*
                                                                  4,
                                                              fontWeight:
                                                              FontWeight.w600),
                                                        ),
                                                        SizedBox(
                                                          width: SizeConfig
                                                              .blockSizeHorizontal !*
                                                              18,
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            "Date: ${IPDInvestigationList[index]['S_date']}",
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                    4,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                          ),
                                                        ),
                                                        // Padding(
                                                        //     padding: EdgeInsets.all(SizeConfig
                                                        //         .blockSizeHorizontal !*
                                                        //         0),
                                                        //     child: Row(
                                                        //       children: [
                                                        //         SizedBox(
                                                        //           width: SizeConfig
                                                        //               .blockSizeHorizontal !*
                                                        //               3.0,
                                                        //         ),
                                                        //         InkWell(
                                                        //           onTap: () {},
                                                        //           customBorder:
                                                        //           CircleBorder(),
                                                        //           child: Container(
                                                        //               padding: EdgeInsets.all(
                                                        //                   SizeConfig
                                                        //                       .blockSizeHorizontal !*
                                                        //                       2.0),
                                                        //               child:
                                                        //
                                                        //               Text(
                                                        //                 "Date: ${OPDInvestigationList[index]['S_date']}",
                                                        //                 style: TextStyle(
                                                        //                     color: Colors.black,
                                                        //                     fontSize: SizeConfig
                                                        //                         .blockSizeHorizontal !*
                                                        //                         4,
                                                        //                     fontWeight:
                                                        //                     FontWeight
                                                        //                         .w500),
                                                        //               )
                                                        //
                                                        //           ),
                                                        //         ),
                                                        //         SizedBox(
                                                        //           width: SizeConfig
                                                        //               .blockSizeHorizontal !*
                                                        //               3.0,
                                                        //         ),
                                                        //
                                                        //       ],
                                                        //     )),
                                                      ],
                                                    ),


                                                    SizedBox(
                                                      height: SizeConfig.blockSizeVertical !*
                                                          2,
                                                    ),

                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: SizeConfig
                                                                .blockSizeHorizontal !*
                                                                2,
                                                          ),
                                                          Text(
                                                            "Type:${IPDInvestigationList[index]['TYPE']}",
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                    4,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                          ),

                                                          SizedBox(
                                                            width: SizeConfig
                                                                .blockSizeHorizontal !*
                                                                10.0,
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child: Text(
                                                              "Status: ${IPDInvestigationList[index]['labstatus']}",
                                                              style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: SizeConfig
                                                                      .blockSizeHorizontal !*
                                                                      4,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                            ),
                                                          ),

                                                          SizedBox(
                                                            width: SizeConfig
                                                                .blockSizeHorizontal !*
                                                                4.0,
                                                          ),
                                                          // Text(
                                                          //   "Catagory: ${OPDInvestigationList[index]['TYPE']}",
                                                          //   style: TextStyle(
                                                          //       color: Colors.black,
                                                          //       fontSize: SizeConfig
                                                          //           .blockSizeHorizontal !*
                                                          //           4,
                                                          //       fontWeight:
                                                          //       FontWeight
                                                          //           .w500),
                                                          // ),

                                                        ],
                                                      ),
                                                    ),

                                                    SizedBox(
                                                      height: SizeConfig.blockSizeVertical !*
                                                          2,
                                                    ),
                                                    Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "Dr.${IPDInvestigationList[index]['Doctor']}",
                                                              style: TextStyle(
                                                                  color:
                                                                  colorBlueApp,
                                                                  fontSize: SizeConfig
                                                                      .blockSizeHorizontal !*
                                                                      4,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                            ),
                                                            SizedBox(
                                                              width: SizeConfig
                                                                  .blockSizeHorizontal !*
                                                                  10.0,
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                "Created by:${IPDInvestigationList[index]['CreatedBy']}",
                                                                style: TextStyle(
                                                                    color: colorBlueApp,
                                                                    fontSize: SizeConfig
                                                                        .blockSizeHorizontal !*
                                                                        3.5,
                                                                    fontWeight:
                                                                    FontWeight.w500),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: SizeConfig
                                                                  .blockSizeHorizontal !*
                                                                  2.0,
                                                            ),
                                                          ],
                                                        )
                                                    ),
                                                    SizedBox(
                                                      height: SizeConfig.blockSizeVertical !*
                                                          2,
                                                    ),

                                                    Visibility(
                                                      // visible: OPDInvestigationList[index].reffDoctorName!.isNotEmpty
                                                      //     && OPDInvestigationList[index].refferPatient!.isNotEmpty,
                                                      child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Row(
                                                            children: [

                                                              SizedBox(
                                                                width: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                    2,
                                                              ),
                                                              Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                  "Investigation:${IPDInvestigationList[index]['OPDService']}",
                                                                  style: TextStyle(
                                                                      color: Colors.black,
                                                                      fontSize: SizeConfig
                                                                          .blockSizeHorizontal !*
                                                                          4,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: SizeConfig
                                                                    .blockSizeHorizontal !*
                                                                    8.0,
                                                              ),
                                                              // Text(
                                                              //   "${OPDInvestigationList[index]['TYPE']}",
                                                              //   style: TextStyle(
                                                              //       color: Colors.black,
                                                              //       fontSize: SizeConfig
                                                              //           .blockSizeHorizontal !*
                                                              //           3.5,
                                                              //       fontWeight:
                                                              //       FontWeight.w500),
                                                              // ),
                                                              SizedBox(
                                                                width: SizeConfig
                                                                    .blockSizeHorizontal !*
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
                                  }),
                              onRefresh: () {
                                return getDoctorInvestigationIPD();
                              })
                              : Container()
                        ],
                      ),
                    ),
                  ),
            ]
            );

          },
        ),
      ),
    );
  }

  Future pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if(newDateRange == null) return;

    setState(() {
      dateRange = newDateRange;
      fromDate = dateRange.start;
      toDate = dateRange.end;
      var formatter = new DateFormat('yyyy-MM-dd');
      fromDateString = formatter.format(fromDate);
      toDateString = formatter.format(toDate);
    });
  }

  // Widget buildInvestigationItem(InvestigationItem item) {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Container(
  //       child: SingleChildScrollView(
  //         scrollDirection: Axis.horizontal,
  //         child: Row(
  //           children: [
  //             Text(item.type ?? '',),sizeBox,
  //             Text(item.sDate ?? ''),sizeBox,
  //             Text(item.patient ?? ''),sizeBox,
  //             Text(item.doctor ?? ''),sizeBox,
  //             Text(item.opdService ?? ''),sizeBox,
  //             Text(item.labStatus ?? ''),sizeBox,
  //             Text(item.INID ?? ''),sizeBox,
  //             // ... Add more widgets based on your requirements
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Future<void> getDoctorInvestigationList() async {
  //   print('getDoctorInvestigationList');
  //
  //   try{
  //
  //     if (fromDateString.isEmpty && toDateString.isEmpty) {
  //       fromDate = DateTime.now().subtract(Duration(days: 30));
  //       toDate = DateTime.now();
  //       fromDateString = DateFormat('yyyy-MM-dd').format(fromDate);
  //       toDateString = DateFormat('yyyy-MM-dd').format(toDate);
  //     }
  //
  //     String loginUrl = "${baseURL}doctor_investigation_list.php";
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
  //         "DoctorIDP" +
  //         "\"" +
  //         ":" +
  //         "\"" +
  //         patientIDP +
  //         "\"," +
  //         "\"" +
  //         "fromdate" +
  //         "\"" +
  //         ":" +
  //         "\"" +
  //         fromDateString +
  //         "\"" +
  //         ",\""+
  //         "todate" +
  //         "\"" +
  //         ":" +
  //         "\"" +
  //         toDateString +
  //         "\"" +
  //         "}";
  //
  //     debugPrint(jsonStr);
  //
  //     String encodedJSONStr = encodeBase64(jsonStr);
  //     var response = await apiHelper.callApiWithHeadersAndBody(
  //       url: loginUrl,
  //
  //       headers: {
  //         "u": patientUniqueKey,
  //         "type": userType,
  //       },
  //       body: {"getjson": encodedJSONStr},
  //     );
  //     //var resBody = json.decode(response.body);
  //
  //     debugPrint(response.body.toString());
  //     final jsonResponse = json.decode(response.body.toString());
  //
  //     ResponseModel model = ResponseModel.fromJSON(jsonResponse);
  //
  //     pr.hide();
  //
  //     if (model.status == "OK") {
  //       var data = jsonResponse['Data'];
  //       var strData = decodeBase64(data);
  //
  //       // Replace '}' with '},'
  //       strData = strData.replaceAllMapped(
  //         RegExp('}{"TYPE":"'),
  //             (match) => '},{"TYPE":"',
  //       );
  //
  //
  //       debugPrint("Decoded Data List : " + strData);
  //
  //       final jsonData = json.decode(strData);
  //
  //       for (var i = 0; i < jsonData.length; i++) {
  //         final investigationList = jsonData[i];
  //
  //         if (investigationList.containsKey("OPD Investigation List") || investigationList.containsKey("IPD Investigation List")) {
  //           final investigationType = investigationList.keys.first;
  //           final investigationItems = (investigationList[investigationType] as List<dynamic>?)
  //               ?.map((item) => InvestigationItem.fromJson(item, investigationType))
  //               .toList();
  //           if (investigationItems != null) {
  //             allInvestigations.addAll(investigationItems);
  //           }
  //         }
  //
  //         debugPrint("----------------------");
  //
  //       }
  //       setState(() {});
  //     }
  //   }catch (e) {
  //     print('Error decoding JSON: $e');
  //   }
  // }

  Future<void> getDoctorInvestigationOPD() async {
    print('getOpdData');

    try{

      if (fromDateString.isEmpty && toDateString.isEmpty) {
        fromDate = DateTime.now().subtract(Duration(days: 30));
        toDate = DateTime.now();
        fromDateString = DateFormat('yyyy-MM-dd').format(fromDate);
        toDateString = DateFormat('yyyy-MM-dd').format(toDate);
      }

      String loginUrl = "${baseURL}doctor_opd_investigation_list.php";
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
      String jsonStr = "{" +
          "\"" +
          "DoctorIDP" +
          "\"" +
          ":" +
          "\"" +
          patientIDP +
          "\"," +
          "\"" +
          "fromdate" +
          "\"" +
          ":" +
          "\"" +
          fromDateString +
          "\"" +
          ",\""+
          "todate" +
          "\"" +
          ":" +
          "\"" +
          toDateString +
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

      debugPrint(response.body.toString());
      final jsonResponse = json.decode(response.body.toString());

      ResponseModel model = ResponseModel.fromJSON(jsonResponse);

      pr.hide();

      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);

        debugPrint("Decoded Vital Data List : " + strData);
        final jsonData = json.decode(strData);

        for (var i = 0; i < jsonData.length; i++) {

          final jo = jsonData[i];
          String TYPE = jo['TYPE'].toString();
          String id = jo['id'].toString();
          String HospitalConsultationIDP = jo['HospitalConsultationIDP'].toString();
          String S_date = jo['S_date'].toString();
          String Patient = jo['Patient'].toString();
          String Doctor = jo['Doctor'].toString();
          String labstatus = jo['labstatus'].toString();
          String R_date = jo['R_date'].toString();
          String OPDService = jo['OPDService'].toString();
          String PATID = jo['PATID'].toString();
          String CreatedBy = jo['CreatedBy'].toString();

          Map<String, dynamic> OrganizationMap = {
            "TYPE" : TYPE,
            "id": id,
            "HospitalConsultationIDP": HospitalConsultationIDP,
            "S_date" : S_date,
            "Patient": Patient,
            "Doctor": Doctor,
            "labstatus" : labstatus,
            "R_date": R_date,
            "OPDService": OPDService,
            "PATID" : PATID,
            "CreatedBy": CreatedBy,
          };
          OPDInvestigationList.add(OrganizationMap);
          // {"TYPE":"radiology","id":6279,"HospitalConsultationIDP":63582,
          // "S_date":"2024-03-04 11:34:44","Patient":"PRIYANKABEN PARAMAR",
          // "Doctor":"CHIRAG RAJESHBHAI PATEL","labstatus":"Report Send",
          // "R_date":"2024-03-04 11:34:44","OPDService":"LEFT ELBOW AP\/ LAT",
          // "PATID":19267,"CreatedBy":"varsha wadhwani"},

          // debugPrint("Decoded : ${OPDInvestigationList}");
        }

        setState(() {});
      }
    }catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  Future<void> getDoctorInvestigationIPD() async {
    print('getIpdData');

    try{

      if (fromDateString.isEmpty && toDateString.isEmpty) {
        fromDate = DateTime.now().subtract(Duration(days: 30));
        toDate = DateTime.now();
        fromDateString = DateFormat('yyyy-MM-dd').format(fromDate);
        toDateString = DateFormat('yyyy-MM-dd').format(toDate);
      }

      String loginUrl = "${baseURL}doctor_ipd_investigation_list.php";
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
      String jsonStr = "{" +
          "\"" +
          "DoctorIDP" +
          "\"" +
          ":" +
          "\"" +
          patientIDP +
          "\"," +
          "\"" +
          "fromdate" +
          "\"" +
          ":" +
          "\"" +
          fromDateString +
          "\"" +
          ",\""+
          "todate" +
          "\"" +
          ":" +
          "\"" +
          toDateString +
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

      debugPrint(response.body.toString());
      final jsonResponse = json.decode(response.body.toString());

      ResponseModel model = ResponseModel.fromJSON(jsonResponse);

      pr.hide();

      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);

        debugPrint("Decoded Vital Data List : " + strData);
        final jsonData = json.decode(strData);

        for (var i = 0; i < jsonData.length; i++) {

          final jo = jsonData[i];
          String TYPE = jo['TYPE'].toString();
          String id = jo['id'].toString();
          String INID = jo['INID'].toString();
          String HospitalConsultationIDP = jo['HospitalConsultationIDP'].toString();
          String S_date = jo['S_date'].toString();
          String Patient = jo['Patient'].toString();
          String Doctor = jo['Doctor'].toString();
          String labstatus = jo['labstatus'].toString();
          String R_date = jo['R_date'].toString();
          String OPDService = jo['OPDService'].toString();
          String PATID = jo['PATID'].toString();
          String CreatedBy = jo['CreatedBy'].toString();
          String UpdateTimeStamp = jo['UpdateTimeStamp'].toString();


          Map<String, dynamic> OrganizationMap = {
            "TYPE" : TYPE,
            "id": id,
            "INID": INID,
            "HospitalConsultationIDP": HospitalConsultationIDP,
            "S_date" : S_date,
            "Patient": Patient,
            "Doctor": Doctor,
            "labstatus" : labstatus,
            "R_date": R_date,
            "OPDService": OPDService,
            "PATID" : PATID,
            "CreatedBy": CreatedBy,
            "UpdateTimeStamp": UpdateTimeStamp,

          };
          IPDInvestigationList.add(OrganizationMap);
          // {"TYPE":"radiology","id":7019,"INID":2575,"PATID":31614,
          // "S_date":"2024-03-06 18:35:00","Patient":"PRIYANKABEN PARMAR F\/25","Doctor":"CHIRAG RAJESHBHAI PATEL",
          // "labstatus":"Report Send","R_date":"2024-03-06 18:36:23","OPDService":"LEFT ELBOW AP\/ LAT",
          // "CreatedBy":"SHUBH PATEL","UpdateTimeStamp":"2024-03-07 10:05:54"}

          // debugPrint("Decoded : ${OPDInvestigationList}");
        }

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
