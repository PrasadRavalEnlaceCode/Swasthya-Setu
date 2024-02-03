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
  List<String> DataFormat = ["Type","Date","Patient","Doctor","OPD/IPD","Investigation","Lab Status","Created By","Action"];

  final sizeBox = SizedBox(width:30,height: 20,);

  @override
  void initState() {
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Investigation List"),
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
          return SingleChildScrollView(
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
                        getDoctorInvestigationList();
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
                  // Divider(
                  //   thickness: 3,
                  // ),
                  // SizedBox(height: 16.0),
                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     children: List.generate(
                  //       DataFormat.length,
                  //           (index) => Padding(
                  //             padding: EdgeInsets.only(
                  //               left: 35.0, // Add space only on the left side
                  //               right: 35.0,
                  //             ),
                  //         child: Text(
                  //           DataFormat[index],
                  //           style: TextStyle(
                  //             color: Colors.black,
                  //             fontFamily: "Ubuntu",
                  //             fontSize: SizeConfig.blockSizeVertical! * 2.5,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 16.0),
                  // Divider(
                  //   thickness: 3,
                  // ),
                  SizedBox(height: 16.0),
                  // ListView.builder(
                  //   itemCount: allInvestigations.length,
                  //   shrinkWrap: true,
                  //   physics: NeverScrollableScrollPhysics(),
                  //   itemBuilder: (context, index) {
                  //     return buildInvestigationItem(allInvestigations[index]);
                  //   },
                  // ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 1.0, color: Colors.black),
                          top: BorderSide(width: 1.0, color: Colors.black),
                        ),
                      ),
                      child: DataTable(
                        columnSpacing: 25.0,
                        columns: [
                          DataColumn(label: Text('Type',style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Ubuntu",
                        fontSize: SizeConfig.blockSizeVertical! * 2.5,
                      ),)),
                          DataColumn(label: Text('Date',
                            style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Ubuntu",
                            fontSize: SizeConfig.blockSizeVertical! * 2.5,
                          ),)),
                          DataColumn(label: Text('Patient',
                            style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Ubuntu",
                            fontSize: SizeConfig.blockSizeVertical! * 2.5,
                          ),)),
                          DataColumn(label: Text('Doctor',
                            style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Ubuntu",
                            fontSize: SizeConfig.blockSizeVertical! * 2.5,
                          ),)),
                          DataColumn(label: Text('Investigation List',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Ubuntu",
                              fontSize: SizeConfig.blockSizeVertical! * 2.5,
                            ),)),
                          DataColumn(label: Text('OPD Service',
                            style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Ubuntu",
                            fontSize: SizeConfig.blockSizeVertical! * 2.5,
                          ),)),
                          DataColumn(label: Text('Lab Status',
                            style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Ubuntu",
                            fontSize: SizeConfig.blockSizeVertical! * 2.5,
                          ),)),
                          DataColumn(label: Text('Created By',
                            style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Ubuntu",
                            fontSize: SizeConfig.blockSizeVertical! * 2.5,
                          ),)),
                          DataColumn(label: Text('Action',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Ubuntu",
                              fontSize: SizeConfig.blockSizeVertical! * 2.5,
                            ),)),
                          // Add more DataColumn widgets based on your requirements
                        ],
                        rows: allInvestigations.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(Text(item.type ?? '')),
                              DataCell(Text(item.sDate ?? '')),
                              DataCell(Text(item.patient ?? '')),
                              DataCell(Text(item.doctor ?? '')),
                              DataCell(Text(item.source ?? '')),
                              DataCell(Text(item.opdService ?? '')),
                              DataCell(Text(item.labStatus ?? '')),
                              DataCell(Text(item.createdBy ?? '')),
                              DataCell(
                                Visibility(
                                  visible: item.labStatus != 'new',
                                  child: InkWell(
                                    child: Center(
                                        child: Icon(Icons.remove_red_eye)),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => InvestigationViewReportScreen(
                                            id: item.id,
                                            INID: item.INID,
                                            PATID: item.patID,
                                            OPD:'OPD',
                                            ipd: 'ipd',
                                            pathology: item.type,
                                            HospitalConsultationIDP: item.hospitalConsultationIDP
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Add more DataCell widgets based on your requirements
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

  void getDoctorInvestigationList() async {
    print('getDoctorInvestigationList');

    try{

      if (fromDateString.isEmpty && toDateString.isEmpty) {
        fromDate = DateTime.now().subtract(Duration(days: 30));
        toDate = DateTime.now();
        fromDateString = DateFormat('yyyy-MM-dd').format(fromDate);
        toDateString = DateFormat('yyyy-MM-dd').format(toDate);
      }

      String loginUrl = "${baseURL}doctor_investigation_list.php";
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

        // Replace '}' with '},'
        strData = strData.replaceAllMapped(
          RegExp('}{"TYPE":"'),
              (match) => '},{"TYPE":"',
        );


        debugPrint("Decoded Data List : " + strData);

        final jsonData = json.decode(strData);

        for (var i = 0; i < jsonData.length; i++) {
          final investigationList = jsonData[i];

          if (investigationList.containsKey("OPD Investigation List") || investigationList.containsKey("IPD Investigation List")) {
            final investigationType = investigationList.keys.first;
            final investigationItems = (investigationList[investigationType] as List<dynamic>?)
                ?.map((item) => InvestigationItem.fromJson(item, investigationType))
                .toList();
            if (investigationItems != null) {
              allInvestigations.addAll(investigationItems);
            }
          }

          debugPrint("----------------------");
          // String organizationLogoImage = jo['OrganizationLogoImage'].toString();
          // String organizationIDF = jo['OrganizationIDF'].toString();
          // String businessName = jo['BusinessName'].toString();
          //
          // Map<String, dynamic> OrganizationMap = {
          //   "OrganizationLogoImage": organizationLogoImage,
          //   "OrganizationIDF": organizationIDF,
          //   "BusinessName" : businessName,
          // };
          // listInvestigations.add(OrganizationMap);
          // debugPrint("Added to list: $complainName");
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
