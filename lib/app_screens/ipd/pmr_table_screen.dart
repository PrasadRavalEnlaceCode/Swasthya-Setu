import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swasthyasetu/api/api_helper.dart';
import 'package:swasthyasetu/app_screens/PDFViewerCachedFromUrl.dart';
import 'package:swasthyasetu/app_screens/doctor_dashboard_screen.dart';
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

class PMRTableScreen extends StatefulWidget {

  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;

  PMRTableScreen({
    required this.patientindooridp,
    required this.PatientIDP,
    required this.doctoridp,
    required this.firstname,
    required this.lastName,
  });



  @override
  State<PMRTableScreen> createState() => _PMRTableScreenState();
}

class _PMRTableScreenState extends State<PMRTableScreen> {

  List<Map<String, dynamic>> ViewTableDataList = <Map<String, dynamic>>[];
  int serialNumber = 1;

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        callApiWithUpdatedDate();
      });
    }
  }

  // Function to call API with updated date
  void callApiWithUpdatedDate() {
    // Call your API function here with updated selectedDate
    getPMRTableData(widget.PatientIDP,widget.patientindooridp);
  }



  @override
  void initState() {
    getPMRTableData(widget.PatientIDP,widget.patientindooridp);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("PMR Table"),
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
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        margin: EdgeInsets.all(
                          SizeConfig.blockSizeHorizontal !* 3.0,
                        ),
                        padding: EdgeInsets.all(
                          SizeConfig.blockSizeHorizontal !* 3.0,
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(5.0))),
                        child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal !* 3.0,
                            ),
                            Text(
                              "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal !* 5.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                              size: SizeConfig.blockSizeHorizontal !* 6.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // InkWell(
                  //   onTap: (){
                  //     getVitalChartPDF(
                  //       widget.patientindooridp ,
                  //     );
                  //   },
                  //   child: Icon(
                  //       Icons.cloud_download_outlined,size: 30.0,color: Colors.blue),),
                  SizedBox(width: 10,),
                ],
              ),

              Visibility(
                visible: ViewTableDataList.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    // height: 450,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1.0, color: Colors.black),
                        top: BorderSide(width: 1.0, color: Colors.black),
                      ),
                    ),
                    child:
                    // Container(),Search:
                    // Sr No.	Medicine Name	Requested Qty.	Remark	Issued Quantity	Created By	Action
                    DataTable(
                      columnSpacing: 25.0,
                      columns: [
                        DataColumn(label: Text('Sr No.',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Ubuntu",
                            fontSize: SizeConfig.blockSizeVertical! * 1.7,
                          ),)),
                        DataColumn(label: Text('PMR No.',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Ubuntu",
                            fontSize: SizeConfig.blockSizeVertical! * 1.7,
                          ),)),
                        DataColumn(label: Text('Created By',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Ubuntu",
                            fontSize: SizeConfig.blockSizeVertical! * 1.7,
                          ),)),
                        DataColumn(label: Text('Action',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Ubuntu",
                            fontSize: SizeConfig.blockSizeVertical! * 1.7,
                          ),)),
                      ],
                      rows: ViewTableDataList.map(
                              (index) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    (serialNumber++).toString(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "Ubuntu",
                                      fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                    ),
                                  ),
                                ),
                                DataCell(
                                    Text(
                                        index['PMRNo'] == "null" ? "" : index['PMRNo'] ?? "",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Ubuntu",
                                        fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                      ),
                                    )
                                ),
                                DataCell(
                                  Text(
                                    index['Created'] ?? '0',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "Ubuntu",
                                      fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  // Row(
                                  //   children: [
                                      InkWell(
                                        child: Center(
                                            child: Icon(Icons.remove_red_eye)),
                                        onTap: (){
                                          getPMRPdf(widget.PatientIDP,
                                              widget.patientindooridp,
                                              index['PMRDateTime']);
                                        },
                                      ),
                                      // InkWell(
                                      //   child: Center(
                                      //       child: Icon(Icons.delete_outline)),
                                      //   onTap: () {
                                      //     PMRPdfDelete(index['PatientPMRIDP']);
                                      //   },
                                      // ),
                                  //   ],
                                  // ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: ViewTableDataList.isEmpty,
                child: Center(
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal! * 30,
                    child: SizedBox(
                      height: SizeConfig.blockSizeVertical! * 80,
                      width: SizeConfig.blockSizeHorizontal! * 100,
                      child: Container(
                        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image(
                              image: AssetImage("images/ic_idea_new.png"),
                              width: 200,
                              height: 100,
                            ),
                            SizedBox(
                              height: 30.0,
                            ),
                            Text(
                              "",
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
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
              MaterialPageRoute(builder: (context) => PMRScreen(
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


  void getPMRTableData(String PatientIDF,PatientIndoorIDF) async {
    print('getIpdData');

    try{
      String loginUrl = "${baseURL}doctor_pmr_main_list.php";
      ProgressDialog pr = ProgressDialog(context);
      Future.delayed(Duration.zero, () {
        pr.show();
      });

      String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      ViewTableDataList.clear();

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
          "," + "\"" + "PatientIDF" + "\"" + ":" + "\"" + PatientIDF + "\"" +
          "," + "\"" + "PatientIndoorIDF" + "\"" + ":" + "\"" + PatientIndoorIDF + "\"" +
          "," + "\"" + "FromDate" + "\"" + ":" + "\"" + formattedDate + "\"" +
          "}";
      // {"PatientIDF":"736" , "PatientIndoorIDF":"20" ,"EntryDate":"2022-12-05" }

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
          String patientPMRIDP = jo['PatientPMRIDP'].toString();
          String MedicineName = jo['MedicineName'].toString();
          String RequestedOty = jo['RequestedOty'].toString();
          String Remarks = jo['Remarks'].toString();
          String Created = jo['Created'].toString();
          String IssuedQty = jo['IssuedQty'].toString();

          String pMRDateTime = jo['PMRDateTime'].toString();
          String pMRNo = jo['PMRNo'].toString();


          Map<String, dynamic> OrganizationMap = {
            "PatientPMRIDP" : patientPMRIDP,
            "MedicineName": MedicineName,
            "RequestedOty": RequestedOty,
            "Remarks" : Remarks,
            "Created": Created,
            "IssuedQty": IssuedQty,

            "PMRDateTime" : pMRDateTime,
            "PMRNo": pMRNo,
          };
          ViewTableDataList.add(OrganizationMap);
          // {"PatientPMRIDP":30989,"MedicineName":"ATARAX 10MG TABLET",
          // "RequestedOty":2,"Remarks":"","Created":"DOCTOR",
          // "IssuedQty":"-","PMRDateTime":"2024-03-08 16:45:33","PMRNo":null}

          debugPrint("Decoded Vital Data List : ${ViewTableDataList}");
        }

        setState(() {});
      }
    }catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  void getPMRPdf(String PatientIDF,PatientIndoorIDF,PMRdate) async {
    print('getIpdData');

    try{
      String loginUrl = "${baseURL}doctor_pmr_master.php";
      ProgressDialog pr = ProgressDialog(context);
      Future.delayed(Duration.zero, () {
        pr.show();
      });

      String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";



      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      String patientIDP = await getPatientOrDoctorIDP();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String jsonStr = "{" +
          "\"" + "patientindooridp" + "\"" + ":" + "\"" + PatientIndoorIDF + "\"" + "," +
          "\"" +
          "DoctorIDP" +
          "\"" +
          ":" +
          "\"" +
          patientIDP +
          "\"" +
          "," + "\"" + "entrydate" + "\"" + ":" + "\"" + PMRdate + "\"" +
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
      //var resBody = json.decode(response.body);

      debugPrint(response.body.toString());
      final jsonResponse = json.decode(response.body.toString());

      ResponseModel model = ResponseModel.fromJSON(jsonResponse);

      pr.hide();

      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);

        debugPrint("Decoded Invoice Data : " + strData);

        // Parse the JSON string
        List<Map<String, dynamic>> fileList = List<Map<String, dynamic>>.from(json.decode(strData));
        String baseInvoiceURL= "${baseURL}images/PMR/";
        // Check if the list is not empty
        if (fileList.isNotEmpty) {
          // Extract the value of the "FileName" key
          String fileName = fileList[0]["FileName"];
          String downloadPdfUrl = baseInvoiceURL + fileName;

          Navigator.push(
              context,
              MaterialPageRoute<dynamic>(
                builder: (_) => PDFViewerCachedFromUrl(
                  url: downloadPdfUrl,
                ),
              ));
        }
        setState(() {});
      }
    }catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  void PMRPdfDelete(String PatientPMRIDP) async {
    print('getIpdData');

    try{
      String loginUrl = "${baseURL}doctor_pmr_delete.php";
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
          "\"" + "PatientPMRIDP" + "\"" + ":" + "\"" + PatientPMRIDP + "\"" +
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

        // Parse the JSON string
        List<Map<String, dynamic>> fileList = List<Map<String, dynamic>>.from(json.decode(strData));
        String baseInvoiceURL= "${baseURL}images/PMR/";
        // Check if the list is not empty
        if (fileList.isNotEmpty) {
          // Extract the value of the "FileName" key
          String fileName = fileList[0]["FileName"];
          String downloadPdfUrl = baseInvoiceURL + fileName;

          Navigator.push(
              context,
              MaterialPageRoute<dynamic>(
                builder: (_) => PDFViewerCachedFromUrl(
                  url: downloadPdfUrl,
                ),
              ));
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
