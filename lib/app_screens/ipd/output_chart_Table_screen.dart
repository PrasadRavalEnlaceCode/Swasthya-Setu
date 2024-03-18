import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silvertouch/api/api_helper.dart';
import 'package:silvertouch/app_screens/PDFViewerCachedFromUrl.dart';
import 'package:silvertouch/app_screens/doctor_dashboard_screen.dart';
import 'package:silvertouch/app_screens/ipd/output_chart_add_screen.dart';
import 'package:silvertouch/app_screens/ipd/vital_chart_add_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/common_methods.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class OutputChartTableScreen extends StatefulWidget {

  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;

  OutputChartTableScreen({
    required this.patientindooridp,
    required this.PatientIDP,
    required this.doctoridp,
    required this.firstname,
    required this.lastName,
  });



  @override
  State<OutputChartTableScreen> createState() => _OutputChartTableScreenState();
}

class _OutputChartTableScreenState extends State<OutputChartTableScreen> {

  List<Map<String, dynamic>> ViewTableDataList = <Map<String, dynamic>>[];
  bool isIpdData = false;

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
    getOutputChartTableData(widget.PatientIDP,widget.patientindooridp);
  }



  @override
  void initState() {

    getOutputChartTableData(widget.PatientIDP,widget.patientindooridp);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Output Vital Table"),
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
                    Flexible(
                      child: Text(
                        "${widget.firstname} ${widget.lastName}",
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
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
                  InkWell(
                    onTap: (){
                      getOutputChartPDF(
                        widget.patientindooridp ,
                      );
                    },
                    child: Icon(
                        Icons.cloud_download_outlined,size: 30.0,color: Colors.blue),),
                  SizedBox(width: 10,),
                ],
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.of(context).push(MaterialPageRoute(builder: (context)
              //     => OutputChartAddScreen(
              //         patientindooridp: widget.patientindooridp,
              //         PatientIDP: widget.PatientIDP,
              //         doctoridp: widget.doctoridp,
              //         firstname: widget.firstname,
              //         lastName: widget.lastName)));
              //   },
              //
              //   child: Text("Add Output Data"),
              // ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.black),
                    top: BorderSide(width: 1.0, color: Colors.black),
                  ),
                ),
                child:
                // Container(Time	URINE	VOMIT	ASP	STOOL	OTHER),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 25.0,
                    columns: [
                      DataColumn(label: Text('Time',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Ubuntu",
                          fontSize: SizeConfig.blockSizeVertical! * 1.7,
                        ),)),
                      DataColumn(label: Text('URINE',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Ubuntu",
                          fontSize: SizeConfig.blockSizeVertical! * 1.7,
                        ),)),
                      DataColumn(label: Text('VOMIT',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Ubuntu",
                          fontSize: SizeConfig.blockSizeVertical! * 1.7,
                        ),)),
                      DataColumn(label: Text('ASP',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Ubuntu",
                          fontSize: SizeConfig.blockSizeVertical! * 1.7,
                        ),)),
                      DataColumn(label: Text('STOOL',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Ubuntu",
                          fontSize: SizeConfig.blockSizeVertical! * 1.7,
                        ),)),
                      DataColumn(label: Text('OTHER',
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
                                  index['EntryTime'] ?? '00.00',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Ubuntu",
                                    fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                  ),

                                ),
                              ),
                              DataCell(
                                Text(
                                  index['Urine'] ?? '',
                                  style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Ubuntu",
                                  fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                ),
                                ),
                              ),
                              DataCell(
                                  Text(
                                      index['Vomit'] ?? '',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "Ubuntu",
                                      fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                    ),
                                  )
                              ),
                              DataCell(
                                  Text(
                                      index['ASP'] ?? '',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "Ubuntu",
                                      fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                    ),
                                  )
                              ),
                              DataCell(
                                Text(
                                  index['Stool'] ?? '',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Ubuntu",
                                    fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  index['Other'] ?? '',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Ubuntu",
                                    fontSize: SizeConfig.blockSizeVertical! * 1.5,
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
        );
      },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement (
              context,
              MaterialPageRoute(builder: (context) =>
                  OutputChartAddScreen(
                    patientindooridp: widget.patientindooridp,
                    PatientIDP: widget.PatientIDP,
                    doctoridp: widget.doctoridp,
                    firstname: widget.firstname,
                    lastName: widget.lastName,
                  )));
        },
        child: Icon(Icons.add,color:Colors.blue),
        backgroundColor: Colors.black, // Set your desired button color
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Align to the bottom right corner
    );
  }

  void getOutputChartTableData(String PatientIDF,PatientIndoorIDF) async {
    print('getIpdData');

    try{
      String loginUrl = "${baseURL}doctor_output_main_list.php";
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
          "PatientIDF" +
          "\"" +
          ":" +
          "\"" +
          PatientIDF +
          "\"" +
          "," + "\"" + "PatientIndoorIDF" + "\"" + ":" + "\"" + PatientIndoorIDF + "\"" +
          "," + "\"" + "EntryDate" + "\"" + ":" + "\"" + formattedDate + "\"" +
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
          String IndoorNursingChartIDP = jo['IndoorNursingChartIDP'].toString();
          String Urine = jo['Urine'].toString();
          String Vomit = jo['Vomit'].toString();
          String ASP = jo['ASP'].toString();
          String Stool = jo['Stool'].toString();
          String Other = jo['Other'].toString();
          String EntryDate = jo['EntryDate'].toString();
          String EntryTime = jo['EntryTime'].toString();
          String EntryTimeID = jo['EntryTimeID'].toString();


          Map<String, dynamic> OrganizationMap = {
            "IndoorNursingChartIDP": IndoorNursingChartIDP,
            "Urine": Urine,
            "Vomit" : Vomit,
            "ASP": ASP,
            "Stool": Stool,
            "Other" : Other,
            "EntryDate": EntryDate,
            "EntryTime" : EntryTime,
            "EntryTimeID": EntryTimeID,
          };
          ViewTableDataList.add(OrganizationMap);
          // [{"IndoorNursingChartIDP":"88614","Urine":"","Vomit":"",
          // "ASP":"","Stool":"","Other":"","EntryDate":"2022-12-05",
          // "EntryTime":"","EntryTimeID":"0"}
        }

        print("data table values : ${ViewTableDataList}");

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

  void getOutputChartPDF(String PatientIndoorIDF) async {
    print('getDoctorInvoiceList');

    try{
      String loginUrl = "${baseURL}doctor_output_chart.php";
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
          "\"" +
          "patientindooridp" +
          "\"" +
          ":" +
          "\"" +
          PatientIndoorIDF +
          "\"," +
          "\"" +
          "entrydate" +
          "\"" +
          ":" +
          "\"" +
          formattedDate +
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

        debugPrint("Decoded Invoice Data : " + strData);

        // Parse the JSON string
        List<Map<String, dynamic>> fileList = List<Map<String, dynamic>>.from(json.decode(strData));

        String baseInvoiceURL = "https://swasthyasetu.com/ws/images/output/";

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
    } catch (e) {
      print('Error decoding JSON: $e');
    }
  }

}
