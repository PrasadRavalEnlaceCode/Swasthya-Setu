import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swasthyasetu/api/api_helper.dart';
import 'package:swasthyasetu/app_screens/PDFViewerCachedFromUrl.dart';
import 'package:swasthyasetu/app_screens/doctor_dashboard_screen.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/common_methods.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global/SizeConfig.dart';
import '../utils/color.dart';
import '../utils/progress_dialog.dart';


class InvestigationViewReportScreen extends StatefulWidget {

  final String? id;
  final String? INID;
  final String? PATID;
  final String? ipd;
  final String? pathology;
  final String? HospitalConsultationIDP;
  final String? OPD;
  // String imgUrl = "";


  InvestigationViewReportScreen({
    this.id,
    this.INID,
    this.PATID,
    this.ipd,
    this.pathology,
    this.HospitalConsultationIDP,
    this.OPD,
  });


  @override
  State<InvestigationViewReportScreen> createState() => _InvestigationViewReportScreenState();
}

class _InvestigationViewReportScreenState extends State<InvestigationViewReportScreen> {

  List<Map<String, dynamic>> ViewReportList = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> srAndReportList = [];
  String baseImageURL = "https://swasthyasetu.com/ws/images/labreports/new/";
  List<Map<String, dynamic>> View1ReportList = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> srAnd1ReportList = [];
  bool isIpdData = false;


  @override
  void initState() {
    if (widget.INID != null && widget.INID!.isNotEmpty) {
      getIpdData(widget.id!, widget.INID, widget.PATID, widget.ipd, widget.pathology);
      setState(() {
        isIpdData = true;
      });
    } else {
      getOPDData(widget.id!, widget.HospitalConsultationIDP, widget.PATID, widget.OPD, widget.pathology);
      setState(() {
        isIpdData = false;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> currentSrAndReportList = isIpdData ? srAndReportList : srAnd1ReportList;
    return Scaffold(
      appBar: AppBar(
        title: Text("View Reports"),
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
          scrollDirection: Axis.horizontal,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1.0, color: Colors.black),
                top: BorderSide(width: 1.0, color: Colors.black),
              ),
            ),
            child:
            // Container(),
            DataTable(
              columnSpacing: 25.0,
              columns: [
                DataColumn(label: Text('Sr.no',
                  style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Ubuntu",
                  fontSize: SizeConfig.blockSizeVertical! * 2.5,
                ),)),
                DataColumn(label: Text('File Name',
                  style: TextStyle(
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
                DataColumn(label: Text('View',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                  ),)),

              ],
              rows: currentSrAndReportList.map(
                      (index) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                       index['Sr.no'] ?? '',
                      ),
                    ),
                    DataCell(
                      Text(
                        index['File Name'] ?? '',
                      ),
                    ),
                    DataCell(
                        Text(
                            index['ReportDate'] ?? ''
                        )
                    ),
                    DataCell(
                      InkWell(
                        child: Center(
                            child: Icon(Icons.remove_red_eye)),
                        onTap: () {
                          String downloadPdfUrl = baseImageURL + index["ReportImage"];
                          Navigator.push(
                              context,
                              MaterialPageRoute<dynamic>(
                                builder: (_) => PDFViewerCachedFromUrl(
                                  url: downloadPdfUrl,
                                ),
                              ));

                          // String path = baseImageURL + index["ReportImage"];
                          //
                          // // Encode the path to make it URL-safe
                          // String encodedPath = Uri.encodeFull(path);
                          //
                          // // Launch the URL using url_launcher
                          // launch(encodedPath);
                        },
                      ),
                    ),
                    // Add more DataCell widgets based on your requirements
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
      ),
    );
  }

  void getIpdData(String id,INID,PATID,ipd,pathology) async {
    print('getIpdData');

    try{
      String loginUrl = "${baseURL}doctor_ipd_report_view.php";
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
          "id" +
          "\"" +
          ":" +
          "\"" +
          id +
          "\"" +
          "," + "\"" + "INID" + "\"" + ":" + "\"" + INID + "\"" +
          "," + "\"" + "PATID" + "\"" + ":" + "\"" + PATID + "\"" +
          "," + "\"" + "ipd" + "\"" + ":" + "\"" + ipd + "\"" +
          "," + "\"" + "pathology" + "\"" + ":" + "\"" + pathology + "\"" +
          "}";
      // {"id":"719","INID":"452","PATID":"736","ipd":"ipd","pathology":"pathology"}

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

        debugPrint("Decoded Data List : " + strData);
        final jsonData = json.decode(strData);

        for (var i = 0; i < jsonData.length; i++) {

          final jo = jsonData[i];
          String reportImage = jo['ReportImage'].toString();
          String reportDate = jo['ReportDate'].toString();
          String reportTime = jo['ReportTime'].toString();

          Map<String, dynamic> OrganizationMap = {
            "ReportImage": reportImage,
            "ReportDate": reportDate,
            "ReportTime" : reportTime,
          };
          ViewReportList.add(OrganizationMap);
          // debugPrint("Added to list: $complainName");
        }

        for (int i = 0; i < ViewReportList.length; i++) {
          Map<String, dynamic> index = ViewReportList[i];
          Map<String, dynamic> srAndReportMap = {
            'Sr.no': (i + 1).toString(),
            'File Name': 'Report${i + 1}',
            'ReportDate': index['ReportDate'].toString(),
            'ReportTime': index['ReportTime'].toString(),
            'ReportImage': index['ReportImage'].toString(),
          };
          srAndReportList.add(srAndReportMap);
        }

        for (int i = 0; i < srAndReportList.length; i++) {
          print('Item $i:');
          print('Sr.no: ${srAndReportList[i]['Sr.no']}');
          print('File Name: ${srAndReportList[i]['File Name']}');
          print('ReportDate: ${srAndReportList[i]['sDate']}');
          print('ReportTime: ${srAndReportList[i]['sDate']}');
          print('ReportImage: ${srAndReportList[i]['sDate']}');
          print('------------------------');
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

  void getOPDData(String id,HospitalConsultationIDP,PATID,OPD,pathology) async {
    print('getOPDData');

    try{
      String loginUrl = "${baseURL}doctor_opd_report_view.php";
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
          "id" +
          "\"" +
          ":" +
          "\"" +
          id +
          "\"" +
          "," + "\"" + "HospitalConsultationIDP" + "\"" + ":" + "\"" + HospitalConsultationIDP + "\"" +
          "," + "\"" + "patientidf" + "\"" + ":" + "\"" + PATID + "\"" +
          "," + "\"" + "OPD" + "\"" + ":" + "\"" + OPD + "\"" +
          "," + "\"" + "laboratorytechnician" + "\"" + ":" + "\"" + pathology + "\"" +
          "}";
      // {"id":"4715","HospitalConsultationIDP":"55891","patientidf":"26671","OPD":"OPD","laboratorytechnician":"laboratorytechnician"}

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

        debugPrint("Decoded OPD Data List : " + strData);
        final jsonData = json.decode(strData);

        for (var i = 0; i < jsonData.length; i++) {

          final jo = jsonData[i];
          String reportImage = jo['ReportImage'].toString();
          String reportDate = jo['ReportDate'].toString();
          String reportTime = jo['ReportTime'].toString();

          Map<String, dynamic> OrganizationMap = {
            "ReportImage": reportImage,
            "ReportDate": reportDate,
            "ReportTime" : reportTime,
          };
          View1ReportList.add(OrganizationMap);
          // debugPrint("Added to list: $complainName");
        }

        for (int i = 0; i < View1ReportList.length; i++) {
          Map<String, dynamic> index = View1ReportList[i];
          Map<String, dynamic> srAndReportMap = {
            'Sr.no': (i + 1).toString(),
            'File Name': 'Report${i + 1}',
            'ReportDate': index['ReportDate'].toString(),
            'ReportTime': index['ReportTime'].toString(),
            'ReportImage': index['ReportImage'].toString(),
          };
          srAnd1ReportList.add(srAndReportMap);
        }

        for (int i = 0; i < srAnd1ReportList.length; i++) {
          print('Item $i:');
          print('Sr.no: ${srAnd1ReportList[i]['Sr.no']}');
          print('File Name: ${srAnd1ReportList[i]['File Name']}');
          print('ReportDate: ${srAnd1ReportList[i]['sDate']}');
          print('ReportTime: ${srAnd1ReportList[i]['sDate']}');
          print('ReportImage: ${srAnd1ReportList[i]['sDate']}');
          print('------------------------');
        }

        setState(() {});
      }
    }catch (e) {
      print('Error decoding JSON: $e');
    }
  }

}
