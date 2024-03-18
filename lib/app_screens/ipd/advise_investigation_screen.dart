import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silvertouch/api/api_helper.dart';
import 'package:silvertouch/app_screens/PDFViewerCachedFromUrl.dart';
import 'package:silvertouch/app_screens/doctor_dashboard_screen.dart';
import 'package:silvertouch/app_screens/ipd/pmr_add_screen.dart';
import 'package:silvertouch/app_screens/ipd/pmr_screen.dart';
import 'package:silvertouch/app_screens/ipd/vital_chart_add_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/common_methods.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../add_consultation_screen.dart';
import 'advise_investigation_table.dart';

class AdviseInvestigationScreen extends StatefulWidget {

  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;

  AdviseInvestigationScreen({
    required this.patientindooridp,
    required this.PatientIDP,
    required this.doctoridp,
    required this.firstname,
    required this.lastName,
  });



  @override
  State<AdviseInvestigationScreen> createState() => _AdviseInvestigationScreenState();
}

class _AdviseInvestigationScreenState extends State<AdviseInvestigationScreen> {

  List<Map<String, dynamic>> ViewTableDataList = <Map<String, dynamic>>[];
  int serialNumber = 1;
  List<Map<String, dynamic>> listInputChartValues = <Map<String, dynamic>>[];

  TextEditingController pathologyInvestigationController = TextEditingController();
  TextEditingController radiologyInvestigationsController = TextEditingController();

  List<String> listRadiologyDetails = [];
  List<String> listPathologyDetails = [];

  List<String> listRadiologyIDP = [];
  List<String> listPathologyIDP = [];

  List<String> _selectedAdviceInvestigation = [];
  List<String> _selectedRadiologyInvestigations = [];
  List<String> _selectedRadiologyIDP = [];
  List<String> _selectedAdviceIDP = [];


  @override
  void initState() {
    getRadiologyList(context);
    getPathologyList(context);
    pathologyInvestigationController = TextEditingController();
    radiologyInvestigationsController = TextEditingController();
    super.initState();
  }

  DateTime selectedTime = DateTime.now();
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Investigation"),
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
                Row(
                  children: [
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
                              "${DateFormat('hh:mm a').format(selectedTime)}", // Format the time using 'hh:mm a' pattern
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

                Divider(),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.all(17.0),
                      //   child: Container(
                      //       width: double.infinity,
                      //       decoration: BoxDecoration(
                      //         border: Border.all(
                      //           color: Colors.black, // Set the border color
                      //           width: 2.0, // Set the border width
                      //         ),
                      //         borderRadius: BorderRadius.circular(8.0), // Set border radius if you want rounded corners
                      //       ),
                      //       child:
                      //       DropdownButton<String>(
                      //         value: selectedValue,
                      //         isExpanded: true,
                      //         items: [
                      //           DropdownMenuItem<String>(
                      //             value: 'Select Time',  // Placeholder value
                      //             child: Center(child: Text('Select Time',textAlign: TextAlign.center)),
                      //           ),
                      //           ...List.generate(12, (index) {
                      //             String hour = (index + 1).toString();
                      //             String labelAM = '$hour AM';
                      //             String labelPM = '$hour PM';
                      //
                      //             // // Swap 12 AM to 12 PM and 12 PM to 12 AM
                      //             // if (hour == '12') {
                      //             //   labelAM = '12 PM';
                      //             //   labelPM = '12 AM';
                      //             // }
                      //
                      //             return DropdownMenuItem<String>(
                      //               value: labelAM,
                      //               child: Text(labelAM),
                      //             );
                      //           }),
                      //           ...List.generate(12, (index) {
                      //             String hour = (index + 1).toString();
                      //             String labelPM = '$hour PM';
                      //
                      //             return DropdownMenuItem<String>(
                      //               value: labelPM,
                      //               child: Text(labelPM),
                      //             );
                      //           }),
                      //         ],
                      //         onChanged: (value) {
                      //           setState(() {
                      //             selectedValue = value!;
                      //           });
                      //           // Convert to formatted time
                      //           String formattedTime = convertToFormattedTime(selectedValue);
                      //         },
                      //       )
                      //
                      //   ),
                      // ),
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
                                  "Radiology Investigations: ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Ubuntu",
                                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                                  ),
                                ),
                              ),
                              // SizedBox(height: 10,),
                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: Container(
                              //     decoration: BoxDecoration(
                              //       border: Border.all(
                              //         color: Colors.black, // Set the border color
                              //         width: 2.0, // Set the border width
                              //       ),
                              //       borderRadius: BorderRadius.circular(8.0), // Set border radius if you want rounded corners
                              //     ),
                              //     width:double.infinity,
                              //     child: Center(
                              //       child: DropdownButton<Map<String, dynamic>>(
                              //         hint: Center(child: Text('Select a Medicine')),
                              //         value: selectedMedicine,
                              //         onChanged: (Map<String, dynamic>? newValue) {
                              //           setState(() {
                              //             selectedMedicine = newValue;
                              //             if (newValue != null) {
                              //               selectedMedicineIDP = newValue['HospitalMedicineIDP'];
                              //             } else {
                              //               // Reset selected IDP when no value is selected
                              //               selectedMedicineIDP = "";
                              //             }
                              //           });
                              //         },
                              //         isExpanded: true,
                              //         items: listOfDocumentDropDown.map<DropdownMenuItem<Map<String, dynamic>>>((Map<String, dynamic> medicine) {
                              //           return DropdownMenuItem<Map<String, dynamic>>(
                              //             value: medicine,
                              //             child: Row(
                              //               // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //               children: [
                              //                 Text(medicine['MedicineName'],
                              //                   overflow: TextOverflow.ellipsis,
                              //                   maxLines: 1,),
                              //                 SizedBox(width: 10),
                              //                 Text("(${medicine['DoseSchedule']})",
                              //                   overflow: TextOverflow.ellipsis,
                              //                   maxLines: 1,),
                              //               ],
                              //             ),
                              //           );
                              //         }).toList(),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              SizedBox(height: 10,),
                              Column(
                                children: [
                                  Container(
                                      width: SizeConfig.blockSizeVertical !* 40,
                                      child:
                                      TypeAheadField<String>(
                                        textFieldConfiguration: TextFieldConfiguration(
                                          controller: radiologyInvestigationsController,
                                          decoration: InputDecoration(
                                            labelText: 'Radiology Investigations',
                                            border: OutlineInputBorder(), // Add border here
                                          ),
                                        ),
                                        suggestionsCallback: (pattern) {
                                          // Always return the full list of options
                                          // return listComplaintDetails;

                                          return listRadiologyDetails.where((listRadiologyDetails) =>
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
                                            // Find the index of the selected suggestion
                                            int index = listRadiologyDetails.indexOf(suggestion);
                                            if (index != -1 && index < listRadiologyIDP.length) {
                                              // Add the corresponding IDP to the selected IDP list
                                              _selectedRadiologyIDP.add(listRadiologyIDP[index]);
                                              // Add the selected suggestion to the display list
                                              _selectedRadiologyInvestigations.add(suggestion);
                                            }
                                          });
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width -50, // Set maximum width
                                        ),
                                        child:
                                        Wrap(
                                          spacing: 8.0,
                                          runSpacing: 4.0,
                                          children: _selectedRadiologyInvestigations
                                              .map(
                                                (String option) => Chip(
                                              label: Text(option),
                                              onDeleted: () {
                                                setState(() {
                                                  _selectedRadiologyInvestigations.remove(option);
                                                });
                                              },
                                            ),
                                          )
                                              .toList(),
                                        ),
                                      ),
                                    ],
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
                                  "Pathology Investigations: ",
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
                                          controller: pathologyInvestigationController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(), // Add border here
                                            labelText: 'Pathology Investigations',
                                            // border: OutlineInputBorder(),
                                          ),
                                        ),
                                        suggestionsCallback: (pattern) {
                                          // Always return the full list of options
                                          // return listPathologyDetails;

                                          return listPathologyDetails.where((listPathologyDetails) =>
                                              listPathologyDetails.toLowerCase().contains(pattern.toLowerCase()));
                                        },
                                        itemBuilder: (context,String  suggestion) {
                                          return ListTile(
                                            title: Text(suggestion),
                                          );
                                        },
                                        onSuggestionSelected: (String suggestion) {
                                          setState(() {
                                            // Find the index of the selected suggestion
                                            int index = listPathologyDetails.indexOf(suggestion);
                                            if (index != -1 && index < listPathologyIDP.length) {
                                              // Add the corresponding IDP to the selected IDP list
                                              _selectedAdviceIDP.add(listPathologyIDP[index]);
                                              // Add the selected suggestion to the display list
                                              _selectedAdviceInvestigation.add(suggestion);
                                            }
                                          });
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width -50, // Set maximum width
                                        ),
                                        child:
                                        Wrap(
                                          spacing: 8.0,
                                          runSpacing: 4.0,
                                          children: _selectedAdviceInvestigation
                                              .map(
                                                (String option) => Chip(
                                              label: Text(option),
                                              onDeleted: () {
                                                setState(() {
                                                  _selectedAdviceInvestigation.remove(option);
                                                });
                                              },
                                            ),
                                          )
                                              .toList(),
                                        ),
                                      ),
                                    ],
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
                        InvestigationSubmit(
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

  String convertToFormattedTime(String selectedTime) {
    if (selectedTime == 'Select Time') {
      // Handle the case when 'Select Time' is selected, you may return a default value or handle it accordingly.
      return 'N/A';
    }

    // Split the time into hour and period
    List<String> timeParts = selectedTime.split(' ');
    int hour = int.parse(timeParts[0]);

    // Adjust the hour based on AM/PM
    if (timeParts[1] == 'PM' && hour != 12) {
      hour += 12;
    } else if (timeParts[1] == 'AM' && hour == 12) {
      hour = 0;
    }

    // Format the time as HH:mm
    String formattedHour = hour.toString().padLeft(2, '0');
    String formattedTime = '$formattedHour:00';

    return formattedTime;
  }

  // void combineAndStoreValues() {
  //
  //
  //   // Combine selected options and text from the controller
  //   String combinedValueAdviceInvestigation = _selectedAdviceInvestigation.join(', ');
  //   // String combinedValueAdviceInvestigation = _selectedAdviceInvestigation .join(', ') + (adviceInvestigationSupportController.text.isNotEmpty ? ', ${adviceInvestigationSupportController.text}' : '');
  //
  //   // // Store the combined value into the complaintController (which is also textEditingController)
  //   // pathologyInvestigationController.text = combinedValueAdviceInvestigation;
  //
  //   // Combine selected options and text from the controller
  //   String combinedValueRadiologyInvestigations = _selectedRadiologyInvestigations.join(', ');
  //   // String combinedValueRadiologyInvestigations = _selectedRadiologyInvestigations .join(', ') + (radiologyInvestigationsSupportController.text.isNotEmpty ? ', ${radiologyInvestigationsSupportController.text}' : '');
  //
  //   setState(() {
  //     _selectedAdviceInvestigation.clear();
  //     _selectedRadiologyInvestigations.clear();
  //   });
  // }

  void getRadiologyList(BuildContext context) async{
    listRadiologyDetails = [];
    String loginUrl = "${baseURL}doctor_ipd_radiology_investigations_list.php";
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
        ","+
        "\"" +
        "CustomTemplateStatus" +
        "\"" +
        ":" +
        "\"" +
        "0" +
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
          debugPrint("Decoded Radiology List: " + strData);

          final jsonData = json.decode(strData);

          for (var i = 0; i < jsonData.length; i++)
          {
            final jo = jsonData[i];
            String adviceInvestigationName = jo['AdviceInvestigationName'].toString();
            listRadiologyDetails.add(adviceInvestigationName);
            // debugPrint("Added to list: $diagnosisName");

            String adviceInvestigationIDP = jo['HospitalOPDServcesIDP'].toString();
            listRadiologyIDP.add(adviceInvestigationIDP);

          }
          setState(() {});
        }
      }catch(e){
        print("Error decoding JSON: $e");
      }else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void getPathologyList(BuildContext context) async{
    listPathologyDetails = [];
    String loginUrl = "${baseURL}doctor_ipd_pathology_investigations_list.php";
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
        ","+
        "\"" +
        "CustomTemplateStatus" +
        "\"" +
        ":" +
        "\"" +
        "0" +
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
          debugPrint("Decoded Pathology List: " + strData);

          final jsonData = json.decode(strData);

          for (var i = 0; i < jsonData.length; i++)

          {
            final jo = jsonData[i];
            String adviceInvestigationName = jo['AdviceInvestigationName'].toString();
            listPathologyDetails.add(adviceInvestigationName);
            // debugPrint("Added to list: $diagnosisName");

            String adviceInvestigationIDP = jo['HospitalOPDServcesIDP'].toString();
            listPathologyIDP.add(adviceInvestigationIDP);

          }

          // for (var i = 0; i < jsonData.length; i++) {
          //
          //   final jo = jsonData[i];
          //   String adviceInvestigationsMasterIDP = jo['AdviceInvestigationsMasterIDP'].toString();
          //   String adviceInvestigationName = jo['AdviceInvestigationName'].toString();
          //   String doctorIDF = jo['DoctorIDF'].toString();
          //   String organizationIDF = jo['OrganizationIDF'].toString();
          //
          //   Map<String, dynamic> OrganizationMap = {
          //     "AdviceInvestigationsMasterIDP": adviceInvestigationsMasterIDP,
          //     "AdviceInvestigationName": adviceInvestigationName,
          //     "DoctorIDF" : doctorIDF,
          //     "OrganizationIDF" : organizationIDF,
          //   };
          //   listRadiologyDetails.add(OrganizationMap);
          //   // debugPrint("Added to list: $complainName");
          //
          // }
          setState(() {});
        }
      }catch(e){
        print("Error decoding JSON: $e");
      }else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void InvestigationSubmit(
      String patientindooridf,
      patientidf,
      ) async {
    print('InvestigationSubmit');

    try{
      String loginUrl = "${baseURL}doctor_add_ipd_investigation_advice_submit.php";
      ProgressDialog pr = ProgressDialog(context);
      Future.delayed(Duration.zero, () {
        pr.show();
      });

      String combinedValueAdviceInvestigation = _selectedRadiologyIDP.join(', ');

      String combinedValueRadiologyInvestigations = _selectedAdviceIDP.join(', ');

      String formattedTime = DateFormat('HH:mm:ss').format(selectedTime);

      // Format the selected date
      String formattedDateTime = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} ${formattedTime}";

      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      String patientIDP = await getPatientOrDoctorIDP();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String jsonStr = "{" + "\"" + "patientindooridf" + "\"" + ":" + "\"" + patientindooridf + "\"" + "," +
          "\"" + "inv_date" + "\"" + ":" + "\"" + formattedDateTime + "\"" + "," +
          "\"" + "patientidf" + "\"" + ":" + "\"" + patientidf + "\"" + "," +
          "\"" + "DoctorIDF" + "\"" + ":" + "\"" + patientIDP + "\"" + "," +
          "\"" + "adviceinvestigationradio" + "\"" + ":" + "\"" + combinedValueAdviceInvestigation + "\"" + "," +
          "\"" + "adviceinvestigation" + "\"" + ":" + "\"" + combinedValueRadiologyInvestigations + "\"" +
          "}";

      // {"patientindooridf":"","inv_date":"","patientidf":"",
      // "DoctorIDF":"","adviceinvestigationradio":"",
      // "adviceinvestigation":""}

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
        _selectedAdviceInvestigation.clear();
        _selectedRadiologyInvestigations.clear();
      }
      else {final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("There are Some Issue in Adding Input Please Try Again"),
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
