import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
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

import '../add_consultation_screen.dart';
import 'advise_investigation_table.dart';

class AddToOTScreen extends StatefulWidget {

  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;

  AddToOTScreen({
    required this.patientindooridp,
    required this.PatientIDP,
    required this.doctoridp,
    required this.firstname,
    required this.lastName,
  });



  @override
  State<AddToOTScreen> createState() => _AddToOTScreenState();
}

class _AddToOTScreenState extends State<AddToOTScreen> {

  List<Map<String, dynamic>> ViewTableDataList = <Map<String, dynamic>>[];
  int serialNumber = 1;
  List<Map<String, dynamic>> listInputChartValues = <Map<String, dynamic>>[];

  TextEditingController ConsultantDoctorNameController = TextEditingController();
  TextEditingController OTNameController = TextEditingController();
  TextEditingController AnestheticDoctorNameController = TextEditingController();
  TextEditingController SurgeryNameController = TextEditingController();

  List<String> listConsultantDoctorNameDetails = [];
  List<String> listOTNameDetails = [];
  List<String> listAnestheticDoctorNameDetails = [];
  List<String> listSurgeryNameDetails = [];

  List<String> listConsultantDoctorNameIDP = [];
  List<String> listOTNameIDP = [];
  List<String> listAnestheticDoctorNameIDP = [];
  List<String> listSurgeryNameIDP = [];


  List<String> _selectedConsultantDoctorNameIDP = [];
  List<String> _selectedOTNameIDP = [];
  List<String> _selectedAnestheticDoctorNameIDP = [];
  List<String> _selectedSurgeryNameIDP = [];


  @override
  void initState() {
    getConsultantDoctorNameList(context);
    getOTNameList(context);
    getAnestheticDoctorNameList(context);
    getSurgeryNameList(context);

    ConsultantDoctorNameController = TextEditingController();
    OTNameController = TextEditingController();
    AnestheticDoctorNameController = TextEditingController();
    SurgeryNameController = TextEditingController();

    super.initState();
  }

  DateTime selectedTime = DateTime.now();
  DateTime selectedTime1 = DateTime.now();
  String selectedValue = 'Select Time';
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
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay initialTimeOfDay = TimeOfDay.fromDateTime(selectedTime);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTimeOfDay,
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        // Convert pickedTime to DateTime and update selectedTime
        selectedTime = DateTime(selectedTime.year, selectedTime.month, selectedTime.day, pickedTime.hour, pickedTime.minute);

        // Format the selected time in your custom format
        String formattedTime = "${pickedTime.hourOfPeriod}:${pickedTime.minute.toString().padLeft(2, '0')} ${pickedTime.period == DayPeriod.am ? 'AM' : 'PM'}";
        // Display the formatted time (optional)
        print("Selected time: $formattedTime");
      });
    }
  }

  Future<void> _selectTime1(BuildContext context) async {
    final TimeOfDay initialTimeOfDay = TimeOfDay.fromDateTime(selectedTime1);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTimeOfDay,
    );

    if (pickedTime != null && pickedTime != selectedTime1) {
      setState(() {
        // Convert pickedTime to DateTime and update selectedTime
        selectedTime1 = DateTime(selectedTime1.year, selectedTime1.month, selectedTime1.day, pickedTime.hour, pickedTime.minute);

        // Format the selected time in your custom format
        String formattedTime1 = "${pickedTime.hourOfPeriod}:${pickedTime.minute.toString().padLeft(2, '0')} ${pickedTime.period == DayPeriod.am ? 'AM' : 'PM'}";
        // Display the formatted time (optional)
        print("Selected time: $formattedTime1");
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("OT Booking"),
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
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            // scrollDirection: Axis.horizontal,
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
                InkWell(
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
                Divider(),
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 2.0,
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          "OT Booking In Time:",
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal !* 3.7,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                          ),
                        ),
                        InkWell(
                          onTap: () => _selectTime(context),
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
                                  "${DateFormat('hh:mm a').format(selectedTime)}",
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
                      ],
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeVertical !* 0.7,
                    ),
                    Column(
                      children: [
                        Text(
                          "OT Booking Out Time:",
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal !* 3.7,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                          ),
                        ),
                        InkWell(
                          onTap: () => _selectTime1(context),
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
                                  "${DateFormat('hh:mm a').format(selectedTime1)}",
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
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 12.0),
                          // height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black, // Border color
                                width: 2, // Border width
                              ),
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 10,),
                              Container(
                                child: Text(
                                  "Consultant Doctor Name: ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Ubuntu",
                                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Column(
                                children: [
                                  Container(
                                      width: SizeConfig.blockSizeVertical !* 40,
                                      child:
                                      TypeAheadField<String>(
                                        textFieldConfiguration: TextFieldConfiguration(
                                          controller: ConsultantDoctorNameController,
                                          decoration: InputDecoration(
                                            labelText: '-Select Consultant Doctor Name-',
                                            border: OutlineInputBorder(), // Add border here
                                          ),
                                        ),
                                        suggestionsCallback: (pattern) {
                                          // Always return the full list of options
                                          // return listComplaintDetails;

                                          return listConsultantDoctorNameDetails.where((listRadiologyDetails) =>
                                              listRadiologyDetails.toLowerCase().contains(pattern.toLowerCase()));
                                        },
                                        itemBuilder: (context,String  suggestion) {
                                          return ListTile(
                                            title: Text(suggestion),
                                          );
                                        },
                                        // Inside the onSuggestionSelected callback
                                        onSuggestionSelected: (String suggestion) {
                                          setState(() {

                                            int index = listConsultantDoctorNameDetails.indexOf(suggestion);
                                            if (index != -1 && index < listConsultantDoctorNameIDP.length) {
                                              String selectedIDP = listConsultantDoctorNameIDP[index];
                                              if (_selectedConsultantDoctorNameIDP.contains(selectedIDP)) {
                                                _selectedConsultantDoctorNameIDP.remove(selectedIDP);
                                              } else {
                                                _selectedConsultantDoctorNameIDP.clear();
                                                _selectedConsultantDoctorNameIDP.add(selectedIDP);
                                                ConsultantDoctorNameController.text = suggestion;
                                              }
                                            }
                                          });
                                        },
                                      )
                                  ),
                                ],
                              ),
                              SizedBox(height: 10,),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 12.0),
                          // height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black, // Border color
                                width: 2, // Border width
                              ),
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 10,),
                              Container(
                                child: Text(
                                  "OT Name: ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Ubuntu",
                                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Column(
                                children: [
                                  Container(
                                      width: SizeConfig.blockSizeVertical !* 40,
                                      child:
                                      TypeAheadField<String>(
                                        textFieldConfiguration: TextFieldConfiguration(
                                          controller: OTNameController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(), // Add border here
                                            labelText: '-Select OT Name-',
                                            // border: OutlineInputBorder(),
                                          ),
                                        ),
                                        suggestionsCallback: (pattern) {
                                          // Always return the full list of options
                                          // return listPathologyDetails;

                                          return listOTNameDetails.where((listPathologyDetails) =>
                                              listPathologyDetails.toLowerCase().contains(pattern.toLowerCase()));
                                        },
                                        itemBuilder: (context,String  suggestion) {
                                          return ListTile(
                                            title: Text(suggestion),
                                          );
                                        },
                                        onSuggestionSelected: (String suggestion) {
                                          setState(() {

                                            int index = listOTNameDetails.indexOf(suggestion);
                                            if (index != -1 && index < listOTNameIDP.length) {
                                              String selectedIDP = listOTNameIDP[index];
                                              if (_selectedOTNameIDP.contains(selectedIDP)) {
                                                _selectedOTNameIDP.remove(selectedIDP);
                                              } else {
                                                _selectedOTNameIDP.clear();
                                                _selectedOTNameIDP.add(selectedIDP);
                                                OTNameController.text = suggestion;
                                              }
                                            }
                                          });
                                        },
                                      )
                                  ),
                                ],
                              ),
                              SizedBox(height: 10,),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 12.0),
                          // height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black, // Border color
                                width: 2, // Border width
                              ),
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 10,),
                              Container(
                                child: Text(
                                  "Anesthetic Doctor Name: ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Ubuntu",
                                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Column(
                                children: [
                                  Container(
                                      width: SizeConfig.blockSizeVertical !* 40,
                                      child:
                                      TypeAheadField<String>(
                                        textFieldConfiguration: TextFieldConfiguration(
                                          controller: AnestheticDoctorNameController,
                                          decoration: InputDecoration(
                                            labelText: '-Select Anesthetic Doctor Name-',
                                            border: OutlineInputBorder(), // Add border here
                                          ),
                                        ),
                                        suggestionsCallback: (pattern) {
                                          // Always return the full list of options
                                          // return listComplaintDetails;

                                          return listAnestheticDoctorNameDetails.where((listRadiologyDetails) =>
                                              listRadiologyDetails.toLowerCase().contains(pattern.toLowerCase()));
                                        },
                                        itemBuilder: (context,String  suggestion) {
                                          return ListTile(
                                            title: Text(suggestion),
                                          );
                                        },
                                        // Inside the onSuggestionSelected callback
                                        onSuggestionSelected: (String suggestion) {
                                          setState(() {
                                            int index = listAnestheticDoctorNameDetails.indexOf(suggestion);
                                            if (index != -1 && index < listAnestheticDoctorNameIDP.length) {
                                              String selectedIDP = listAnestheticDoctorNameIDP[index];
                                              if (_selectedAnestheticDoctorNameIDP.contains(selectedIDP)) {
                                                _selectedAnestheticDoctorNameIDP.remove(selectedIDP);
                                              } else {
                                                _selectedAnestheticDoctorNameIDP.clear();
                                                _selectedAnestheticDoctorNameIDP.add(selectedIDP);
                                                AnestheticDoctorNameController.text = suggestion;
                                              }
                                            }
                                          });
                                        },
                                      )
                                  ),
                                ],
                              ),
                              SizedBox(height: 10,),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 12.0),
                          // height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black, // Border color
                                width: 2, // Border width
                              ),
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 10,),
                              Container(
                                child: Text(
                                  "Surgery Name: ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Ubuntu",
                                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Column(
                                children: [
                                  Container(
                                      width: SizeConfig.blockSizeVertical !* 40,
                                      child:
                                      TypeAheadField<String>(
                                        textFieldConfiguration: TextFieldConfiguration(
                                          controller: SurgeryNameController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(), // Add border here
                                            labelText: '-Select Surgery Name-',
                                            // border: OutlineInputBorder(),
                                          ),
                                        ),
                                        suggestionsCallback: (pattern) {
                                          // Always return the full list of options
                                          // return listPathologyDetails;

                                          return listSurgeryNameDetails.where((listSurgeryNameDetails) =>
                                              listSurgeryNameDetails.toLowerCase().contains(pattern.toLowerCase()));
                                        },
                                        itemBuilder: (context,String  suggestion) {
                                          return ListTile(
                                            title: Text(suggestion),
                                          );
                                        },
                                        onSuggestionSelected: (String suggestion) {
                                          setState(() {

                                            int index = listSurgeryNameDetails.indexOf(suggestion);
                                            if (index != -1 && index < listSurgeryNameIDP.length) {
                                              String selectedIDP = listSurgeryNameIDP[index];
                                              if (_selectedSurgeryNameIDP.contains(selectedIDP)) {
                                                _selectedSurgeryNameIDP.remove(selectedIDP);
                                              } else {
                                                _selectedSurgeryNameIDP.clear();
                                                _selectedSurgeryNameIDP.add(selectedIDP);
                                                SurgeryNameController.text = suggestion;
                                              }
                                            }
                                          });
                                        },
                                      )
                                  ),
                                ],
                              ),
                              SizedBox(height: 10,),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    child: InkWell(
                      onTap: () {
                        OTSubmit(
                          widget.patientindooridp,
                          widget.PatientIDP,
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: SizeConfig.blockSizeHorizontal !*
                                3),
                        child: ClipOval(
                          child: Container(
                              color: Color(0xFF06A759),
                              height:
                              SizeConfig.blockSizeHorizontal !*
                                  12,
                              // height of the button
                              width:
                              SizeConfig.blockSizeHorizontal !*
                                  12,
                              // width of the button
                              child: Padding(
                                padding: EdgeInsets.all(SizeConfig
                                    .blockSizeHorizontal !*
                                    3),
                                child: Image(
                                  width: SizeConfig
                                      .blockSizeHorizontal !*
                                      7.5,
                                  height: SizeConfig
                                      .blockSizeHorizontal !*
                                      7.5,
                                  //height: 80,
                                  image: AssetImage(
                                      "images/ic_right_arrow_triangular.png"),
                                ),
                              )),
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: Colors.grey, width: 1.0))),
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


  void getConsultantDoctorNameList(BuildContext context) async{
    String loginUrl = "${baseURL}doctor_consultant_list.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("------");
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
        "}";

    debugPrint(jsonStr);
    debugPrint("----------");
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr?.hide();
    if (response.statusCode == 200)
      try{
        if (model.status == "OK") {
          var data = jsonResponse['Data'];
          var strData = decodeBase64(data);
          debugPrint("Decoded ConsulDoctorName List: " + strData);

          final jsonData = json.decode(strData);

          for (var i = 0; i < jsonData.length; i++)
          {
            final jo = jsonData[i];
            String adviceInvestigationName = "${jo['FirstName'].toString()} ${jo['MiddleName'].toString()} ${jo['LastName'].toString()}";
            listConsultantDoctorNameDetails.add(adviceInvestigationName);
            // debugPrint("Added to list: $diagnosisName");

            String adviceInvestigationIDP = jo['DoctorIDP'].toString();
            listConsultantDoctorNameIDP.add(adviceInvestigationIDP);

          }
          setState(() {});
        }
      }catch(e){
        print("Error decoding JSON: $e");
      }else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void getOTNameList(BuildContext context) async{

    String loginUrl = "${baseURL}doctor_ot_list.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("---------------------################");
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
        "}";

    debugPrint(jsonStr);
    debugPrint("------------------##############");
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr?.hide();
    if (response.statusCode == 200)
      try{
        if (model.status == "OK") {
          var data = jsonResponse['Data'];
          var strData = decodeBase64(data);
          debugPrint("Decoded OT List: " + strData);

          final jsonData = json.decode(strData);

          for (var i = 0; i < jsonData.length; i++)

          {
            final jo = jsonData[i];
            String adviceInvestigationName = jo['OTName'].toString();
            listOTNameDetails.add(adviceInvestigationName);
            // debugPrint("Added to list: $diagnosisName");

            String adviceInvestigationIDP = jo['OTMasterIDP'].toString();
            listOTNameIDP.add(adviceInvestigationIDP);
          }
          setState(() {});
        }
      }catch(e){
        print("Error decoding JSON: $e");
      }else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void getAnestheticDoctorNameList(BuildContext context) async{
    String loginUrl = "${baseURL}doctor_anesthetic_list.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("------");
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
        "}";

    debugPrint(jsonStr);
    debugPrint("----------");
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr?.hide();
    if (response.statusCode == 200)
      try{
        if (model.status == "OK") {
          var data = jsonResponse['Data'];
          var strData = decodeBase64(data);
          debugPrint("Decoded AnestheticDoctorName List: " + strData);

          final jsonData = json.decode(strData);

          for (var i = 0; i < jsonData.length; i++)
          {
            final jo = jsonData[i];
            String adviceInvestigationName = jo['doctor'].toString();
            listAnestheticDoctorNameDetails.add(adviceInvestigationName);
            // debugPrint("Added to list: $diagnosisName");

            String adviceInvestigationIDP = jo['id'].toString();
            listAnestheticDoctorNameIDP.add(adviceInvestigationIDP);

          }
          setState(() {});
        }
      }catch(e){
        print("Error decoding JSON: $e");
      }else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void getSurgeryNameList(BuildContext context) async{
    String loginUrl = "${baseURL}doctor_surgery_list.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("------########");
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
        "}";

    debugPrint(jsonStr);
    debugPrint("##############");
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr?.hide();
    if (response.statusCode == 200)
      try{
        if (model.status == "OK") {
          var data = jsonResponse['Data'];
          var strData = decodeBase64(data);
          debugPrint("Decoded SurgeryName List: " + strData);

          final jsonData = json.decode(strData);

          for (var i = 0; i < jsonData.length; i++)

          {
            final jo = jsonData[i];
            String adviceInvestigationName = jo['Service'].toString();
            listSurgeryNameDetails.add(adviceInvestigationName);
            // debugPrint("Added to list: $diagnosisName");

            String adviceInvestigationIDP = jo['IDP'].toString();
            listSurgeryNameIDP.add(adviceInvestigationIDP);
          }
          setState(() {});
        }
      }catch(e){
        print("Error decoding JSON: $e");
      }else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void OTSubmit(
      String patientindooridf,
      patientidf,
      ) async {
    print('OTSubmit');


    if (OTNameController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please Select OT Name"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (selectedDate == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please Select Date"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (selectedTime == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select OT Booking in Time"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (selectedTime1 == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select OT Booking in Time"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    try{
      String loginUrl = "${baseURL}doctor_add_ot_submit.php";
      ProgressDialog pr = ProgressDialog(context);
      Future.delayed(Duration.zero, () {
        pr.show();
      });

      String consultantdoctoridp = _selectedConsultantDoctorNameIDP.toString();
      // Remove the first and last characters (square brackets)
      consultantdoctoridp = consultantdoctoridp.substring(1, consultantdoctoridp.length - 1);

      String otname = _selectedOTNameIDP.toString();
      // Remove the first and last characters (square brackets)
      otname = otname.substring(1, otname.length - 1);

      String anestheticdoctoridp = _selectedAnestheticDoctorNameIDP.toString();
      // Remove the first and last characters (square brackets)
      anestheticdoctoridp = anestheticdoctoridp.substring(1, anestheticdoctoridp.length - 1);

      String surgerynameidp = _selectedSurgeryNameIDP.toString();
      // Remove the first and last characters (square brackets)
      surgerynameidp = surgerynameidp.substring(1, surgerynameidp.length - 1);

      String formattedTime1 = DateFormat('HH:mm').format(selectedTime);

      String formattedTime2 = DateFormat('HH:mm').format(selectedTime1);

      String formattedTimeIn = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} ${formattedTime1}";

      String formattedTimeOut = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} ${formattedTime2}";

      // Format the selected date
      String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      String patientIDP = await getPatientOrDoctorIDP();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String jsonStr = "{" + "\"" + "consultantdoctoridp" + "\"" + ":" + "\"" + consultantdoctoridp + "\"" + "," +
          "\"" + "otname" + "\"" + ":" + "\"" + otname + "\"" + "," +
          "\"" + "otdate" + "\"" + ":" + "\"" + formattedDate + "\"" + "," +
          "\"" + "otbookingintime" + "\"" + ":" + "\"" + formattedTimeIn + "\"" + "," +
          "\"" + "otbookingouttime" + "\"" + ":" + "\"" + formattedTimeOut + "\"" + "," +
          "\"" + "anestheticdoctoridp" + "\"" + ":" + "\"" + anestheticdoctoridp + "\"" + "," +
          "\"" + "surgerynameidp" + "\"" + ":" + "\"" + surgerynameidp + "\"" + "," +
          "\"" + "DoctorIDF" + "\"" + ":" + "\"" + patientIDP + "\"" + "," +
          "\"" + "PatientIndoorIDF" + "\"" + ":" + "\"" + patientindooridf + "\"" + "," +
          "\"" + "PatientIDF" + "\"" + ":" + "\"" + patientidf + "\"" +
          "}";

      // {"consultantdoctoridp":"","otname":"","otdate":"","otbookingintime":"",
      // "otbookingouttime":"","anestheticdoctoridp":"","surgerynameidp":"",
      // "DoctorIDF":"","PatientIndoorIDF":"","PatientIDF":""}

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

        final snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text("Input Added Successfully"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {});
        Navigator.pop(context);
        _selectedOTNameIDP.clear();
        _selectedAnestheticDoctorNameIDP.clear();
      }
      else {final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("There are Some Issue in Adding to OT Please Try Again"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
