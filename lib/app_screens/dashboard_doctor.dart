import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silvertouch/api/api_helper.dart';
import 'package:silvertouch/app_screens/dashboard_doctor_view.dart';
import 'package:silvertouch/app_screens/doctor_dashboard_screen.dart';
import 'package:silvertouch/app_screens/investigation_view_report_screen.dart';
import 'package:silvertouch/app_screens/opd_registration_screen.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global/SizeConfig.dart';
import '../utils/color.dart';
import '../utils/progress_dialog.dart';


class DashboardDoctorScreen extends StatefulWidget {

  final String? selectedOrganizationIDF;

  DashboardDoctorScreen({this.selectedOrganizationIDF});

  @override
  State<DashboardDoctorScreen> createState() => _DashboardDoctorScreenState();
}

class _DashboardDoctorScreenState extends
State<DashboardDoctorScreen> {

  // late String patientIDP;
  // // Function to update patientIDP
  // void updatePatientIDP(String updatedPatientIDP) {
  //   setState(() {
  //     patientIDP = updatedPatientIDP;
  //   });
  // }

  var fromDate = DateTime.now().subtract(Duration(days: 30));
  var toDate = DateTime.now();

  var fromDateString = "";
  var toDateString = "";
  var taskId;
  ProgressDialog? pr;
  late DateTimeRange dateRange;
  late String selectedOrganizationIDF;

  // late String selectedOrganizationIDF;
  List<InvestigationItem> allInvestigations = [];

  final sizeBox = SizedBox(width:30,height: 20,);

  @override
  void initState() {
    selectedOrganizationIDF = widget.selectedOrganizationIDF ?? "5";
    dateRange = DateTimeRange(
        start: fromDate,
        end: toDate);
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
          title: Text("Doctor Dashboard"),
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
            return
              TabBarView(
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
                            height: SizeConfig.blockSizeVertical !* 8,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Container(
                                child: InkWell(
                                    onTap: () {
                                      // showDateRangePickerDialog();
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        // Expanded(
                                        //   child: Text(
                                        //     fromDateString == ""
                                        //         ? "Select Date Range"
                                        //         : "$fromDateString  to  $toDateString",
                                        //     textAlign: TextAlign.center,
                                        //     style: TextStyle(
                                        //         fontSize:
                                        //             SizeConfig.blockSizeVertical !* 2.6,
                                        //         fontWeight: FontWeight.w500,
                                        //         color: Colors.black),
                                        //   ),
                                        // ),
                                        // Container(
                                        //   width: SizeConfig.blockSizeHorizontal !* 15,
                                        //   child: Icon(
                                        //     Icons.arrow_drop_down,
                                        //     size: SizeConfig.blockSizeHorizontal !* 8,
                                        //   ),
                                        // ),
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
                          SizedBox(
                            height: SizeConfig.blockSizeVertical !* 2,
                          ),
                          MaterialButton(
                            onPressed: () async {
                              if (fromDate == "") {
                                final snackBar = SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text("Please select Date Range"),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                return;
                              }
                              else{
                                String patientIDP = await getPatientOrDoctorIDP();

                                //  void updatepatientIDP(String organizationIDF) {
                                //   patientIDP = organizationIDF;
                                // }https://swasthyasetu.com/ws/doctor_opd_dashboard.php?
                                // DoctorIDP=1&OrganizationIDF=5&formDate=2023-12-19&toDate=2024-01-18
                                // String updatedAppId = ApiHelper.updateDefaultHeaders("your_organization_id_here");

                                String defaultFromDate = '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
                                String defaultToDate = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
                                // "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-"
                                //     "${selectedDate.day.toString().padLeft(2, '0')}"
                                String dynamicURL = 'https://swasthyasetu.com/ws/doctor_opd_dashboard.php?'
                                    'DoctorIDP=${patientIDP}&'
                                    'OrganizationIDF=${selectedOrganizationIDF}&'
                                    'formDate=${fromDateString.isNotEmpty ? fromDateString : defaultFromDate}&'
                                    'toDate=${toDateString.isNotEmpty ? toDateString : defaultToDate}';

                                // Now you can use 'dynamicURL' for your purposes (e.g., navigation, API requests)
                                print(dynamicURL);
                                try {

                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => DashBoardDoctorWebView(url: dynamicURL)));

                                } catch (e) {
                                  print('Error launching URL: $e');
                                }
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
                          sizeBox,
                          SizedBox(height: 16.0),

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
                            height: SizeConfig.blockSizeVertical !* 8,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Container(
                                child: InkWell(
                                    onTap: () {
                                      // showDateRangePickerDialog();
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        // Expanded(
                                        //   child: Text(
                                        //     fromDateString == ""
                                        //         ? "Select Date Range"
                                        //         : "$fromDateString  to  $toDateString",
                                        //     textAlign: TextAlign.center,
                                        //     style: TextStyle(
                                        //         fontSize:
                                        //             SizeConfig.blockSizeVertical !* 2.6,
                                        //         fontWeight: FontWeight.w500,
                                        //         color: Colors.black),
                                        //   ),
                                        // ),
                                        // Container(
                                        //   width: SizeConfig.blockSizeHorizontal !* 15,
                                        //   child: Icon(
                                        //     Icons.arrow_drop_down,
                                        //     size: SizeConfig.blockSizeHorizontal !* 8,
                                        //   ),
                                        // ),
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
                          SizedBox(
                            height: SizeConfig.blockSizeVertical !* 2,
                          ),
                          MaterialButton(
                            onPressed: () async {
                              if (fromDate == "") {
                                final snackBar = SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text("Please select Date Range"),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                return;
                              }
                              else{
                                String patientIDP = await getPatientOrDoctorIDP();

                                //  void updatepatientIDP(String organizationIDF) {
                                //   patientIDP = organizationIDF;
                                // }https://swasthyasetu.com/ws/doctor_opd_dashboard.php?
                                // DoctorIDP=1&OrganizationIDF=5&formDate=2023-12-19&toDate=2024-01-18
                                // String updatedAppId = ApiHelper.updateDefaultHeaders("your_organization_id_here");

                                String defaultFromDate = '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
                                String defaultToDate = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
                                // "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-"
                                //     "${selectedDate.day.toString().padLeft(2, '0')}"
                                String dynamicURL = 'https://swasthyasetu.com/ws/doctor_ipd_dashboard.php?'
                                    'DoctorIDP=${patientIDP}&'
                                    'OrganizationIDF=${selectedOrganizationIDF}&'
                                    'formDate=${fromDateString.isNotEmpty ? fromDateString : defaultFromDate}&'
                                    'toDate=${toDateString.isNotEmpty ? toDateString : defaultToDate}';

                                // Now you can use 'dynamicURL' for your purposes (e.g., navigation, API requests)
                                print(dynamicURL);
                                try {

                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => DashBoardDoctorWebView(url: dynamicURL)));

                                } catch (e) {
                                  print('Error launching URL: $e');
                                }
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
                          sizeBox,
                          SizedBox(height: 16.0),

                        ],
                      ),
                    ),
                  ),
                ],
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

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }

}
