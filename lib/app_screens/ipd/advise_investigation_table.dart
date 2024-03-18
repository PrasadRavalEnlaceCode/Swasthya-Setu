import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swasthyasetu/api/api_helper.dart';
import 'package:swasthyasetu/app_screens/PDFViewerCachedFromUrl.dart';
import 'package:swasthyasetu/app_screens/doctor_dashboard_screen.dart';
import 'package:swasthyasetu/app_screens/investigation_view_report_screen.dart';
import 'package:swasthyasetu/app_screens/ipd/advise_investigation_screen.dart';
import 'package:swasthyasetu/app_screens/ipd/pmr_add_screen.dart';
import 'package:swasthyasetu/app_screens/ipd/pmr_screen.dart';
import 'package:swasthyasetu/app_screens/ipd/vital_chart_add_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/color.dart';
import 'package:swasthyasetu/utils/common_methods.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class investigationTableScreen extends StatefulWidget {

  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;

  investigationTableScreen({
    required this.patientindooridp,
    required this.PatientIDP,
    required this.doctoridp,
    required this.firstname,
    required this.lastName,
  });



  @override
  State<investigationTableScreen> createState() => _investigationTableScreenState();
}

class _investigationTableScreenState extends State<investigationTableScreen> {

  List<Map<String, dynamic>> IPDInvestigationList = <Map<String, dynamic>>[];
  int serialNumber = 1;

  DateTime selectedDate = DateTime.now();

  var fromDate = DateTime.now().subtract(Duration(days: 30));
  var toDate = DateTime.now();

  var fromDateString = "";
  var toDateString = "";
  var taskId;
  ProgressDialog? pr;
  late DateTimeRange dateRange;

  @override
  void initState() {
    dateRange = DateTimeRange(
        start: fromDate,
        end: toDate);
    getDoctorInvestigationIPD(widget.patientindooridp,widget.PatientIDP);
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
      body: Builder(builder: (context) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        "Patient Name:",
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Text(
                      "${widget.firstname} ${widget.lastName}",
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 2,
              ),

              // Container(
              //   height: SizeConfig.blockSizeVertical !* 15.5,
              //   child: Padding(
              //     padding: EdgeInsets.only(left: 5.0, right: 5.0),
              //     child: Container(
              //       child: InkWell(
              //           onTap: () {
              //             // showDateRangePickerDialog();
              //           },
              //           child: Column(
              //             children: [
              //               Row(
              //                 children: <Widget>[
              //
              //                   Expanded(
              //                       child: ElevatedButton(
              //                         child: Text('${start.day}-${start.month}-${start.year}'),
              //                         onPressed: pickDateRange,
              //                       )
              //                   ),
              //                   const SizedBox(width: 10,),
              //                   Expanded(
              //                       child: ElevatedButton(
              //                         child: Text('${end.day}-${end.month}-${end.year}'),
              //                         onPressed: pickDateRange,
              //                       )
              //                   ),
              //                 ],
              //               ),
              //               Divider(
              //                 thickness: 2,
              //               ),
              //               // SizedBox(
              //               //   height: SizeConfig.blockSizeVertical !* 1.0,
              //               // ),
              //               MaterialButton(
              //                 onPressed: () {
              //                   if (fromDate == "") {
              //                     final snackBar = SnackBar(
              //                       backgroundColor: Colors.red,
              //                       content: Text("Please select Date Range"),
              //                     );
              //                     ScaffoldMessenger.of(context).showSnackBar(snackBar);
              //                     return;
              //                   }
              //                   else{
              //                     getDoctorInvestigationIPD();
              //                   }
              //                 },
              //                 color: Colors.blue,
              //                 child: Text(
              //                   "Submit",
              //                   style: TextStyle(
              //                     color: Colors.white,
              //                     fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
              //                     fontWeight: FontWeight.w500,
              //                   ),
              //                 ),
              //               ),
              //
              //             ],
              //           )),
              //       padding: EdgeInsets.all(5.0),
              //       decoration: BoxDecoration(
              //         border: Border.all(
              //           color: Colors.black,
              //           width: 1.0,
              //         ),
              //         borderRadius: BorderRadius.circular(5.0),
              //       ),
              //     ),
              //   ),
              // ),
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
                                          pathology: IPDInvestigationList[index]['type'],
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
                                                "Type:${IPDInvestigationList[index]['type']}",
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
                    return getDoctorInvestigationIPD(widget.patientindooridp,widget.PatientIDP);
                  })
                  : Container()
            ],
          ),
        );
      },
      ),
      floatingActionButton:
      FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdviseInvestigationScreen(
                patientindooridp: widget.patientindooridp,
                PatientIDP: widget.PatientIDP,
                doctoridp: widget.doctoridp,
                firstname: widget.firstname,
                lastName: widget.lastName,
              )));
        },
        child: Icon(Icons.add,color: Colors.white,size: 35.0,),
        backgroundColor: Colors.black, // Set your desired button color
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Align to the bottom right corner
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

  Future<void> getDoctorInvestigationIPD(String patientindooridp,PatientIDP) async {
    print('getIpdData');

    IPDInvestigationList.clear();

    try{

      if (fromDateString.isEmpty && toDateString.isEmpty) {
        fromDate = DateTime.now().subtract(Duration(days: 30));
        toDate = DateTime.now();
        fromDateString = DateFormat('yyyy-MM-dd').format(fromDate);
        toDateString = DateFormat('yyyy-MM-dd').format(toDate);
      }

      String loginUrl = "${baseURL}doctor_patient_wise_ipd_investigation_list.php";
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
          "patientindooridp" +
          "\"" +
          ":" +
          "\"" +
          patientindooridp +
          "\"," +
          "\"" +
          "PatientIDP" +
          "\"" +
          ":" +
          "\"" +
          PatientIDP +
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
          String type = jo['type'].toString();
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
            "type" : type,
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

          // {"type":"radiology","id":7297,"INID":1755,
          // "PATID":7,"S_date":"2024-03-12 17:04:00",
          // "patient":"RUSHIL R SONI","doctor":"SUNIL M SHAH",
          // "labstatus":"new","R_date":"2024-03-12 17:04:47",
          // "OPDService":"ABDOMEN","CreatedBy":"DOCTOR","UpdateTimeStamp":null}

          // debugPrint("Decoded : ${OPDInvestigationList}");
        }

        setState(() {});
      }
    }catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  void InvestigationDelete(String PatientIndoorInvestigationIDP, patientindooridp, PatientIDP, status) async {
    print('getIpdData');

    try{
      String loginUrl = "${baseURL}doctor_ipd_investigation_delete.php";
      ProgressDialog pr = ProgressDialog(context);
      Future.delayed(Duration.zero, () {
        pr.show();
      });
      // String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      // ViewTableDataList.clear();

      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      String patientIDP = await getPatientOrDoctorIDP();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String jsonStr = "{" +
          "\"" + "PatientIndoorInvestigationIDP" + "\"" + ":" + "\"" + PatientIndoorInvestigationIDP + "\"" + "," +
          "\"" + "patientindooridp" + "\"" + ":" + "\"" + patientindooridp + "\"" + "," +
          "\"" + "PatientIDP" + "\"" + ":" + "\"" + PatientIDP + "\"" + "," +
          "\"" + "status" + "\"" + ":" + "\"" + status + "\"" + "," +
          "}";
      // "," + "\"" + "PatientIDF" + "\"" + ":" + "\"" + PatientIDF + "\"" +

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

      debugPrint(response.body.toString());
      final jsonResponse = json.decode(response.body.toString());

      ResponseModel model = ResponseModel.fromJSON(jsonResponse);

      pr.hide();

      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);

        debugPrint("Decoded Invoice Data : " + strData);

        // // Parse the JSON string
        // List<Map<String, dynamic>> fileList = List<Map<String, dynamic>>.from(json.decode(strData));
        // String baseInvoiceURL= "${baseURL}images/PMR/";
        // // Check if the list is not empty
        // if (fileList.isNotEmpty) {
        //   // Extract the value of the "FileName" key
        //   String fileName = fileList[0]["FileName"];
        //   String downloadPdfUrl = baseInvoiceURL + fileName;
        //
        //   Navigator.push(
        //       context,
        //       MaterialPageRoute<dynamic>(
        //         builder: (_) => PDFViewerCachedFromUrl(
        //           url: downloadPdfUrl,
        //         ),
        //       ));
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
