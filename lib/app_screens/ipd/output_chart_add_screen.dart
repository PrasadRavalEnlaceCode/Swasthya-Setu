import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swasthyasetu/app_screens/ipd/output_chart_Table_screen.dart';
import 'package:swasthyasetu/app_screens/ipd/vital_chart_table.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/color.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

class OutputChartAddScreen extends StatefulWidget {


  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;

  OutputChartAddScreen({
    required this.patientindooridp,
    required this.PatientIDP,
    required this.doctoridp,
    required this.firstname,
    required this.lastName,
  });

  @override
  State<OutputChartAddScreen> createState() => _OutputChartAddScreenState();
}
class _OutputChartAddScreenState extends State<OutputChartAddScreen> {

  List<Map<String, dynamic>> listOutputChartValues = <Map<String, dynamic>>[];

  TextEditingController UrineController = TextEditingController();
  TextEditingController VOMITController = TextEditingController();
  TextEditingController ASPController = TextEditingController();
  TextEditingController STOOLController = TextEditingController();
  TextEditingController OTHERController = TextEditingController();

  List<String> timeSlots = [];  // Declare the list once

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


  @override
  void initState() {

    UrineController = TextEditingController();
    VOMITController = TextEditingController();
    ASPController = TextEditingController();
    STOOLController = TextEditingController();
    OTHERController = TextEditingController();

    if (listOutputChartValues.isNotEmpty) {
      UrineController.text = listOutputChartValues[0]["Urine"];
      VOMITController.text = listOutputChartValues[0]["Vomit"];
      ASPController.text = listOutputChartValues[0]["ASP"];
      STOOLController.text = listOutputChartValues[0]["Stool"];
      OTHERController.text = listOutputChartValues[0]["Other"];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Output Chart"),
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
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(17.0),
                        child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black, // Set the border color
                                width: 2.0, // Set the border width
                              ),
                              borderRadius: BorderRadius.circular(8.0), // Set border radius if you want rounded corners
                            ),
                            child:
                            DropdownButton<String>(
                              value: selectedValue,
                              isExpanded: true,
                              items: [
                                DropdownMenuItem<String>(
                                  value: 'Select Time',  // Placeholder value
                                  child: Center(child: Text('Select Time',textAlign: TextAlign.center)),
                                ),
                                ...List.generate(12, (index) {
                                  String hour = (index + 1).toString();
                                  String labelAM = '$hour AM';
                                  String labelPM = '$hour PM';

                                  // // Swap 12 AM to 12 PM and 12 PM to 12 AM
                                  // if (hour == '12') {
                                  //   labelAM = '12 PM';
                                  //   labelPM = '12 AM';
                                  // }

                                  return DropdownMenuItem<String>(
                                    value: labelAM,
                                    child: Text(labelAM),
                                  );
                                }),
                                ...List.generate(12, (index) {
                                  String hour = (index + 1).toString();
                                  String labelPM = '$hour PM';

                                  return DropdownMenuItem<String>(
                                    value: labelPM,
                                    child: Text(labelPM),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value!;
                                });
                                // Convert to formatted time
                                String formattedTime = convertToFormattedTime(selectedValue);

                                // Call your API with the formatted time value
                                getVitalChartValue(
                                  widget.patientindooridp,
                                  widget.PatientIDP,
                                  formattedTime,
                                );
                              },
                            )

                        ),
                      ),

                      // SizedBox(width: 40,),

                      Column(
                        children: [
                          Container(
                              width:double.infinity,
                              child: TextField(
                                controller: UrineController,
                                keyboardType: TextInputType.number,
                                maxLength: 5,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(), // Add border here
                                  labelText: 'URINE', // Optional label
                                  hintText: 'Enter URINE', // Optional hint text
                                ),
                              )
                          ),
                          SizedBox(height: 10,),
                          Container(
                              width:double.infinity,
                              child: TextField(
                                controller: VOMITController,
                                keyboardType: TextInputType.number,
                                maxLength: 5,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(), // Add border here
                                  labelText: 'VOMIT', // Optional label
                                  hintText: 'Enter VOMIT', // Optional hint text
                                ),
                              )
                          ),
                          SizedBox(height: 10,),
                          Container(
                              width:double.infinity,
                              child: TextField(
                                controller: ASPController,
                                keyboardType: TextInputType.number,
                                maxLength: 5,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(), // Add border here
                                  labelText: 'ASP', // Optional label
                                  hintText: 'Enter ASP', // Optional hint text
                                ),
                              )
                          ),
                          SizedBox(height: 10,),
                          Container(
                              width:double.infinity,
                              child: TextField(
                                controller: STOOLController,
                                maxLength: 5,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(), // Add border here
                                  labelText: 'STOOL', // Optional label
                                  hintText: 'Enter STOOL', // Optional hint text
                                ),
                              )
                          ),
                          SizedBox(height: 10,),
                          Container(
                              width:double.infinity,
                              child: TextField(
                                controller: OTHERController,
                                keyboardType: TextInputType.number,
                                maxLength: 5,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(), // Add border here
                                  labelText: 'OTHER', // Optional label
                                  hintText: 'Enter OTHER', // Optional hint text
                                ),
                              )
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    child: InkWell(
                      onTap: () {
                        String formattedTime = convertToFormattedTime(selectedValue);

                        VitalChartValueSend(
                          widget.patientindooridp,
                          widget.PatientIDP,
                          widget.doctoridp,
                          widget.firstname,
                          widget.lastName,
                          formattedTime,
                          UrineController,
                          VOMITController,
                          ASPController,
                          STOOLController,
                          OTHERController,
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

  void getVitalChartValue(
      String patientindooridp,
      String PatientIDF,
      selectedValue
      )
  async {
    print('getdoctorswitchorganization');

    try{
      String loginUrl = "${baseURL}doctor_output_nursing_chart_list.php";
      ProgressDialog pr = ProgressDialog(context);
      Future.delayed(Duration.zero, () {
        pr.show();
      });

      // Format the selected date
      String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

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
          "," +
          "\"" +
          "PatientIndoorIDF" +
          "\"" +
          ":" +
          "\"" +
          patientindooridp +
          "\"" +
          "," +
          "\"" +
          "EntryDate" +
          "\"" +
          ":" +
          "\"" +
          formattedDate +
          "\"" +
          "," +
          "\"" +
          "EntryTime" +
          "\"" +
          ":" +
          "\"" +
          selectedValue +
          "\"" +
          "}";

      // {"PatientIDF":"736" , "PatientIndoorIDF":"20" ,"EntryDate":"2022-12-05" ,"EntryTime":"8:00"}

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

        // [{"IndoorNursingChartIDP":"1","Urine":"30","Vomit":"30",
        // "ASP":"30","Stool":"30","Other":"30"}]

        listOutputChartValues.clear(); // Clear the list before adding new entries

        for (var i = 0; i < jsonData.length; i++) {
          print("Processing Entry $i: ${jsonData[i]}");
          final jo = jsonData[i];
          String IndoorNursingChartIDP = jo['IndoorNursingChartIDP'].toString();
          String Urine = jo['Urine'].toString();
          String Vomit = jo['Vomit'].toString();
          String ASP = jo['ASP'].toString();
          String Stool = jo['Stool'].toString();
          String Other = jo['Other'].toString();

          print("Urine: $Urine, Vomit: $Vomit, ASP: $ASP, Stool: $Stool, Other: $Other");

          // Check if all values are non-empty

          Map<String, dynamic> OrganizationMap = {
            "IndoorNursingChartIDP": IndoorNursingChartIDP,
            "Urine": Urine,
            "Vomit": Vomit,
            "ASP": ASP,
            "Stool": Stool,
            "Other": Other,
          };

          listOutputChartValues.add(OrganizationMap);
        }

        // Print the values of listVitalChartValues
        print("Vital Chart Values: $listOutputChartValues");

        setState(() {
          UrineController.text = listOutputChartValues.isNotEmpty ? listOutputChartValues[0]["Urine"] : '';
          VOMITController.text = listOutputChartValues.isNotEmpty ? listOutputChartValues[0]["Vomit"] : '';
          ASPController.text = listOutputChartValues.isNotEmpty ? listOutputChartValues[0]["ASP"] : '';
          STOOLController.text = listOutputChartValues.isNotEmpty ? listOutputChartValues[0]["Stool"] : '';
          OTHERController.text = listOutputChartValues.isNotEmpty ? listOutputChartValues[0]["Other"] : '';

          print("Temperature: ${UrineController.text}");
          print("Pulse: ${VOMITController.text}");
        });
      }
    }catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  void VitalChartValueSend(
      String patientindooridp,
      String PatientIDF,
      String doctoridp,
      String firstname,
      String lastName,
      selectedValue,
      TextEditingController UrineController,
      TextEditingController VOMITController,
      TextEditingController ASPController,
      TextEditingController STOOLController,
      TextEditingController OTHERController,
      )
  async {
    print('getdoctorswitchorganization');

    try{
      String loginUrl = "${baseURL}doctor_add_output_chart_submit.php";
      ProgressDialog pr = ProgressDialog(context);
      Future.delayed(Duration.zero, () {
        pr.show();
      });

      // Format the selected date
      String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      String patientIDP = await getPatientOrDoctorIDP();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String jsonStr = "{" + "\"" + "PatientIDF" + "\"" + ":" + "\"" + PatientIDF + "\"" + "," +
          "\"" + "PatientIndoorIDF" + "\"" + ":" + "\"" + patientindooridp + "\"" + "," +
          "\"" + "EntryDate" + "\"" + ":" + "\"" + formattedDate + "\"" + "," +
          "\"" + "EntryTime" + "\"" + ":" + "\"" + selectedValue + "\"" + "," +
          "\"" + "Urine" + "\"" + ":" + "\"" + UrineController.text + "\"" + "," +
          "\"" + "Vomit" + "\"" + ":" + "\"" + VOMITController.text + "\"" + "," +
          "\"" + "ASP" + "\"" + ":" + "\"" + ASPController.text + "\"" + "," +
          "\"" + "Stool" + "\"" + ":" + "\"" + STOOLController.text + "\"" + "," +
          "\"" + "Other" + "\"" + ":" + "\"" + OTHERController.text+ "\"" +
          "}";

      // {"PatientIDF":"736" , "PatientIndoorIDF":"20" ,
      // "EntryDate":"2022-12-05" ,"EntryTime":"8:00"
      // ,"Urine":"66" ,"Vomit":"56" ,"ASP":"65","Stool":"56","Other":"56"}

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
          content: Text("Output Added Successfully"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {});

        Navigator.pop(context);
        // Navigator.pop(context);
        // Navigator.pushReplacement (
        //   context,
        //     MaterialPageRoute(
        //     builder: (context) =>
        //         OutputChartTableScreen(
        //             patientindooridp: patientindooridp,
        //             PatientIDP: PatientIDF,
        //             doctoridp: doctoridp,
        //             firstname: firstname,
        //             lastName: lastName)
        // )
        // );
      }
      else {final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("There are Some Issue in Adding Output Please Try Again"),
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

// Text("Selected Date: ${selectedDate.toLocal()}"),
// Container(
//   // decoration: BoxDecoration(
//   //   border: Border(
//   //     bottom: BorderSide(width: 1.0, color: Colors.black),
//   //     top: BorderSide(width: 1.0, color: Colors.black),
//   //   ),
//   // ),
//   child: Table(
//     border: TableBorder.all(),
//     children: [
//       TableRow(
//         children: [
//           TableCell(
//             child: Text('Time'),
//           ),
//         ]
//       )
//     ],
//   ),
// DataTable(
//   columnSpacing: 25.0,
//   decoration: BoxDecoration(
//     border: Border.all(color: Colors.black), // Add your desired color and other properties
//   ),
//   columns: [
//     DataColumn(label: Text('Time',
//       style: TextStyle(
//         color: Colors.black,
//         fontFamily: "Ubuntu",
//         fontSize: SizeConfig.blockSizeVertical! * 2.5,
//       ),)),
//     DataColumn(label: Text('Temp',
//       style: TextStyle(
//         color: Colors.black,
//         fontFamily: "Ubuntu",
//         fontSize: SizeConfig.blockSizeVertical! * 2.5,
//       ),)),
//     DataColumn(label: Text('Pulse',
//       style: TextStyle(
//         color: Colors.black,
//         fontFamily: "Ubuntu",
//         fontSize: SizeConfig.blockSizeVertical! * 2.5,
//       ),)),
//     DataColumn(label: Text('Resp',
//       style: TextStyle(
//         color: Colors.black,
//         fontFamily: "Ubuntu",
//         fontSize: SizeConfig.blockSizeVertical! * 2.5,
//       ),)),
//     DataColumn(label: Text('BP Systolic',
//       style: TextStyle(
//         color: Colors.black,
//         fontFamily: "Ubuntu",
//         fontSize: SizeConfig.blockSizeVertical! * 2.5,
//       ),)),
//     DataColumn(label: Text('BP Diastolic',
//       style: TextStyle(
//         color: Colors.black,
//         fontFamily: "Ubuntu",
//         fontSize: SizeConfig.blockSizeVertical! * 2.5,
//       ),)),
//     DataColumn(label: Text('SPO2',
//       style: TextStyle(
//         color: Colors.black,
//         fontFamily: "Ubuntu",
//         fontSize: SizeConfig.blockSizeVertical! * 2.5,
//       ),)),
//   ],
//   rows: listOrganizations.map((item) {
//     return DataRow(
//       cells: [
//         DataCell(
//           SizedBox(
//             width: 150,
//             child:
//             DropdownButton<String>(
//               value: selectedTimeSlot,
//               onChanged: (newValue) {
//                 setState(() {
//                   selectedTimeSlot = newValue!;
//                 });
//               },
//               items: generateTimeSlots()
//                   .map<DropdownMenuItem<String>>(
//                     (String value) => DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                 ),
//               ).toList(),
//             ),
//           ),
//         ),
//         DataCell(
//             TextField(
//           controller: tempController,
//         )),
//         DataCell(
//             TextField(
//               controller: PulseController,
//             )),
//         DataCell(
//             TextField(
//               controller: RespController,
//             )),
//         DataCell(
//             TextField(
//               controller: BpSystolicController,
//             )),
//         DataCell(
//             TextField(
//               controller: BpDiastolicController,
//             )),
//         DataCell(
//             TextField(
//               controller: SPO2Controller,
//             )),
//         // DataCell(Text(item.createdBy ?? '')),
//         // Add more DataCell widgets based on your requirements
//       ],
//     );
//   }).toList(),
// ),