import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:silvertouch/app_screens/PDFViewerCachedFromUrl.dart';
import 'package:silvertouch/app_screens/ipd/input_chart_add_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/progress_dialog.dart';

class InputChartScreen extends StatefulWidget {

  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;

  InputChartScreen({
    required this.patientindooridp,
    required this.PatientIDP,
    required this.doctoridp,
    required this.firstname,
    required this.lastName,
  });


  @override
  State<InputChartScreen> createState() => _InputChartScreenState();
}

class _InputChartScreenState extends State<InputChartScreen> {

  TextEditingController tempController = TextEditingController();
  TextEditingController PulseController = TextEditingController();
  TextEditingController RespController = TextEditingController();
  TextEditingController BpSystolicController = TextEditingController();
  TextEditingController BpDiastolicController = TextEditingController();
  TextEditingController SPO2Controller = TextEditingController();

  List<Map<String, dynamic>> ViewTableDataList = <Map<String, dynamic>>[];
  // List<Map<String, dynamic>> srAndReportList = [];
  // String baseImageURL = "https://swasthyasetu.com/ws/images/labreports/new/";
  // List<Map<String, dynamic>> View1ReportList = <Map<String, dynamic>>[];
  // List<Map<String, dynamic>> srAnd1ReportList = [];
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

  @override
  void initState() {
    // selectedOrganizationName;
    // getOrganizations();
    getInputChartTableData(widget.PatientIDP,widget.patientindooridp);
    super.initState();
  }

  // Function to call API with updated date
  void callApiWithUpdatedDate() {
    // Call your API function here with updated selectedDate
    getInputChartTableData(widget.PatientIDP,widget.patientindooridp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Input Chart"),
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
                      onTap: () {
                        _selectDate(context);
                        // callApiWithUpdatedDate();
                      },
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
                      getInputChartPDF(
                        widget.patientindooridp ,
                      );
                    },
                    child: Icon(
                        Icons.cloud_download_outlined,size: 30.0,color: Colors.blue),),
                  SizedBox(width: 10,),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.black),
                    top: BorderSide(width: 1.0, color: Colors.black),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    dataTextStyle: TextStyle(
                      color: Colors.black,
                      fontFamily: "Ubuntu",
                      fontSize: SizeConfig.blockSizeVertical! * 2.5,
                    ),
                    columnSpacing: 25.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black), // Add your desired color and other properties
                    ),
                    columns: [
                      DataColumn(
                          label:
                          Text('Time',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Ubuntu",
                              fontSize: SizeConfig.blockSizeVertical! * 2.5,
                            ),
                        )),
                      DataColumn(
                        label:
                        Column(
                          children: [
                            Text("ORAL",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                            Text("SUB",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                          ],
                        ),
                      ),
                      DataColumn(
                        label:
                        Column(
                          children: [
                            Text("ORAL",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                            Text("QUANTITY",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                          ],
                        ),
                      ),
                      DataColumn(
                        label:
                        Column(
                          children: [
                            Text("RT",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                            Text("SUB",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                          ],
                        ),
                      ),
                      DataColumn(
                        label:
                        Column(
                          children: [
                            Text("RT",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                            Text("QUANTITY",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                          ],
                        ),
                      ),
                      DataColumn(
                        label:
                        Column(
                          children: [
                            Text("IV1",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                            Text("DRUG",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                          ],
                        ),
                      ),
                      DataColumn(
                        label:
                        Column(
                          children: [
                            Text("IV1",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                            Text("QUANTITY",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                          ],
                        ),
                      ),
                      DataColumn(
                        label:
                        Column(
                          children: [
                            Text("IV2",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                            Text("DRUG",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                          ],
                        ),
                      ),
                      DataColumn(
                        label:
                        Column(
                          children: [
                            Text("IV2",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                            Text("QUANTITY",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              ),),
                          ],
                        ),
                      ),
                    ],
                    rows: ViewTableDataList.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(
                              Text(item['EntryTime'].toString(),
                                style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Ubuntu",
                                fontSize: SizeConfig.blockSizeVertical! * 1.5,
                              ),)
                          ),
                          DataCell(
                              Text(item['OralSub'].toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Ubuntu",
                                  fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                ),)),
                          DataCell(
                              Text(item['OralQuantity'].toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Ubuntu",
                                  fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                ),)),
                          DataCell(
                              Text(item['RTSub'].toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Ubuntu",
                                  fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                ),)),
                          DataCell(
                              Text(item['RTQuantity'].toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Ubuntu",
                                  fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                ),)),
                          DataCell(
                              Text(item['IVDrug1'].toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Ubuntu",
                                  fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                ),)),
                          DataCell(
                              Text(item['IVQuantity1'].toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Ubuntu",
                                  fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                ),)),
                          DataCell(
                              Text(item['IVDrug2'].toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Ubuntu",
                                  fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                ),)),
                          DataCell(
                              Text(item['IVQuantity2'].toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Ubuntu",
                                  fontSize: SizeConfig.blockSizeVertical! * 1.5,
                                ),)),
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
                  InputChartAddScreen(
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

  void getInputChartTableData(String PatientIDF,PatientIndoorIDF) async {
    print('getIpdData');

    try{
      String loginUrl = "${baseURL}doctor_input_main_list.php";
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
          String OralSub = jo['OralSub'].toString();
          String OralQuantity = jo['OralQuantity'].toString();
          String IVDrug1 = jo['IVDrug1'].toString();
          String IVQuantity1 = jo['IVQuantity1'].toString();
          String IVDrug2 = jo['IVDrug2'].toString();
          String IVQuantity2 = jo['IVQuantity2'].toString();
          String RTSub = jo['RTSub'].toString();
          String RTQuantity = jo['RTQuantity'].toString();
          String EntryDate = jo['EntryDate'].toString();
          String EntryTime = jo['EntryTime'].toString();
          String EntryTimeID = jo['EntryTimeID'].toString();


          Map<String, dynamic> OrganizationMap = {
            "IndoorNursingChartIDP": IndoorNursingChartIDP,
            "OralSub": OralSub,
            "OralQuantity" : OralQuantity,
            "IVDrug1": IVDrug1,
            "IVQuantity1": IVQuantity1,
            "IVDrug2" : IVDrug2,
            "IVQuantity2": IVQuantity2,
            "RTSub": RTSub,
            "RTQuantity" : RTQuantity,
            "EntryDate": EntryDate,
            "EntryTime" : EntryTime,
            "EntryTimeID": EntryTimeID,
          };
          ViewTableDataList.add(OrganizationMap);
          // {"IndoorNursingChartIDP":"88614","OralSub":"",
          // "OralQuantity":"","IVDrug1":"","IVQuantity1":"",
          // "IVDrug2":"","IVQuantity2":"","RTSub":"","RTQuantity":"",
          // "EntryDate":"2022-12-05","EntryTime":"","EntryTimeID":"0"}
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

  void getInputChartPDF(String PatientIndoorIDF) async {
    print('getDoctorInvoiceList');

    try{
      String loginUrl = "${baseURL}doctor_input_chart.php";
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

        debugPrint("Decoded Input Chart Data : " + strData);

        // Parse the JSON string
        List<Map<String, dynamic>> fileList = List<Map<String, dynamic>>.from(json.decode(strData));

        String baseInputURL = "https://swasthyasetu.com/ws/images/input/";

        // Check if the list is not empty
        if (fileList.isNotEmpty) {
          // Extract the value of the "FileName" key
          String fileName = fileList[0]["FileName"];
          String downloadPdfUrl = baseInputURL + fileName;

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
