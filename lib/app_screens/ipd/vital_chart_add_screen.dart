import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/color.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

class VitalChartScreen extends StatefulWidget {


  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;

  VitalChartScreen({
    required this.patientindooridp,
    required this.PatientIDP,
    required this.doctoridp,
    required this.firstname,
    required this.lastName,
  });

  @override
  State<VitalChartScreen> createState() => _VitalChartScreenState();
}
class _VitalChartScreenState extends State<VitalChartScreen> {

  List<Map<String, dynamic>> listVitalChartValues = <Map<String, dynamic>>[];

  TextEditingController tempController = TextEditingController();
  TextEditingController PulseController = TextEditingController();
  TextEditingController RespController = TextEditingController();
  TextEditingController BpSystolicController = TextEditingController();
  TextEditingController BpDiastolicController = TextEditingController();
  TextEditingController SPO2Controller = TextEditingController();

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

    tempController = TextEditingController();
    PulseController = TextEditingController();
    RespController = TextEditingController();
    BpSystolicController = TextEditingController();
    BpDiastolicController = TextEditingController();
    SPO2Controller = TextEditingController();

    if (listVitalChartValues.isNotEmpty) {
      tempController.text = listVitalChartValues[0]["Temperature"];
      PulseController.text = listVitalChartValues[0]["Pulse"];
      RespController.text = listVitalChartValues[0]["RR"];
      BpSystolicController.text = listVitalChartValues[0]["BPSystolic"];
      BpDiastolicController.text = listVitalChartValues[0]["BPDiastolic"];
      SPO2Controller.text = listVitalChartValues[0]["SPO2"];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vital Chart"),
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
                ElevatedButton(
                  onPressed: () => _selectDate(context),

                  child: Text("${selectedDate.day}-${selectedDate.month}-${selectedDate.year}"),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [

                      Padding(
                        padding: const EdgeInsets.all(17.0),
                        child: Container(
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
                            items: [
                              DropdownMenuItem<String>(
                                value: 'Select Time',  // Placeholder value
                                child: Text('Select Time'),
                              ),
                              ...List.generate(12, (index) {
                                String hour = (index + 1).toString();
                                String labelAM = '$hour AM';
                                String labelPM = '$hour PM';

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
                              width:SizeConfig.blockSizeHorizontal! *30,
                              child: TextField(
                                controller: tempController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(), // Add border here
                                  labelText: 'temp', // Optional label
                                  hintText: 'Enter temperature', // Optional hint text
                                ),
                              )
                          ),
                          SizedBox(height: 10,),
                          Container(
                              width:SizeConfig.blockSizeHorizontal! *30,
                              child: TextField(
                                controller: PulseController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(), // Add border here
                                  labelText: 'Pulse', // Optional label
                                  hintText: 'Enter temperature', // Optional hint text
                                ),
                              )
                          ),
                          SizedBox(height: 10,),
                          Container(
                              width:SizeConfig.blockSizeHorizontal! *30,
                              child: TextField(
                                controller: RespController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(), // Add border here
                                  labelText: 'Resp', // Optional label
                                  hintText: 'Enter temperature', // Optional hint text
                                ),
                              )
                          ),
                          SizedBox(height: 10,),
                          Container(
                              width:SizeConfig.blockSizeHorizontal! *30,
                              child: TextField(
                                controller: BpSystolicController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(), // Add border here
                                  labelText: 'BpSystolic', // Optional label
                                  hintText: 'Enter temperature', // Optional hint text
                                ),
                              )
                          ),
                          SizedBox(height: 10,),
                          Container(
                              width:SizeConfig.blockSizeHorizontal! *30,
                              child: TextField(
                                controller: BpDiastolicController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(), // Add border here
                                  labelText: 'BpDiastolic', // Optional label
                                  hintText: 'Enter temperature', // Optional hint text
                                ),
                              )
                          ),
                          SizedBox(height: 10,),
                              Container(
                                  width:SizeConfig.blockSizeHorizontal! *30,
                                  child: TextField(
                                    controller: SPO2Controller,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'SPO2',
                                      hintText: 'Enter temperature',
                                    ),
                                  )
                              ),
                        ],
                      ),

                    ],
                  ),
                ),
                Container(
                  child: InkWell(
                    onTap: () {
                      String formattedTime = convertToFormattedTime(selectedValue);


                      VitalChartValueSend(
                        widget.patientindooridp,
                        widget.PatientIDP,
                        formattedTime,
                        tempController,
                        PulseController,
                        RespController,
                        BpSystolicController,
                        BpDiastolicController,
                        SPO2Controller,
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
      String loginUrl = "${baseURL}doctor_vitals_nursing_chart_list.php";
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

        // [{"IndoorNursingChartIDP":"1","Temperature":"66.00",
        //   "Pulse":"56.00","RR":"","BPSystolic":"56.00","BPDiastolic":"56.00","SPO2":"56.00"}]

        listVitalChartValues.clear(); // Clear the list before adding new entries

        for (var i = 0; i < jsonData.length; i++) {
          print("Processing Entry $i: ${jsonData[i]}");
          final jo = jsonData[i];
          String IndoorNursingChartIDP = jo['IndoorNursingChartIDP'].toString();
          String Temperature = jo['Temperature'].toString();
          String Pulse = jo['Pulse'].toString();
          String RR = jo['RR'].toString();
          String BPSystolic = jo['BPSystolic'].toString();
          String BPDiastolic = jo['BPDiastolic'].toString();
          String SPO2 = jo['SPO2'].toString();

          print("Temperature: $Temperature, Pulse: $Pulse, RR: $RR, BPSystolic: $BPSystolic, BPDiastolic: $BPDiastolic, SPO2: $SPO2");

          // Check if all values are non-empty

            Map<String, dynamic> OrganizationMap = {
              "IndoorNursingChartIDP": IndoorNursingChartIDP,
              "Temperature": Temperature,
              "Pulse": Pulse,
              "RR": RR,
              "BPSystolic": BPSystolic,
              "BPDiastolic": BPDiastolic,
              "SPO2": SPO2,
            };

            listVitalChartValues.add(OrganizationMap);
        }

        // Print the values of listVitalChartValues
        print("Vital Chart Values: $listVitalChartValues");

        setState(() {
          tempController.text = listVitalChartValues.isNotEmpty ? listVitalChartValues[0]["Temperature"] : '';
          PulseController.text = listVitalChartValues.isNotEmpty ? listVitalChartValues[0]["Pulse"] : '';
          RespController.text = listVitalChartValues.isNotEmpty ? listVitalChartValues[0]["RR"] : '';
          BpSystolicController.text = listVitalChartValues.isNotEmpty ? listVitalChartValues[0]["BPSystolic"] : '';
          BpDiastolicController.text = listVitalChartValues.isNotEmpty ? listVitalChartValues[0]["BPDiastolic"] : '';
          SPO2Controller.text = listVitalChartValues.isNotEmpty ? listVitalChartValues[0]["SPO2"] : '';

          print("Temperature: ${tempController.text}");
          print("Pulse: ${PulseController.text}");
        });
      }
    }catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  void VitalChartValueSend(
      String patientindooridp,
      String PatientIDF,
      selectedValue,
      TextEditingController tempController,
      TextEditingController PulseController,
      TextEditingController RespController,
      TextEditingController BpSystolicController,
      TextEditingController BpDiastolicController,
      TextEditingController SPO2Controller,
      )
  async {
    print('getdoctorswitchorganization');

    try{
      String loginUrl = "${baseURL}doctor_add_vitals_chart_submit.php";
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
          "\"" + "Temperature" + "\"" + ":" + "\"" + tempController.text + "\"" + "," +
          "\"" + "Pulse" + "\"" + ":" + "\"" + PulseController.text + "\"" + "," +
          "\"" + "RR" + "\"" + ":" + "\"" + RespController.text + "\"" + "," +
          "\"" + "BPSystolic" + "\"" + ":" + "\"" + BpSystolicController.text + "\"" + "," +
          "\"" + "BPDiastolic" + "\"" + ":" + "\"" + BpDiastolicController.text+ "\"" + "," +
          "\"" + "SPO2" + "\"" + ":" + "\"" + SPO2Controller.text + "\"" +
          "}";

      // {"PatientIDF":"736" , "PatientIndoorIDF":"20" ,
      // "EntryDate":"2022-12-05" ,
      // "EntryTime":"8:00" ,"Temperature":"66" ,"Pulse":"56" ,
      // "RR":"65","BPSystolic":"56","BPDiastolic":"56","SPO2":"56"}

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

        // [{"IndoorNursingChartIDP":"1","Temperature":"66.00",
        //   "Pulse":"56.00","RR":"","BPSystolic":"56.00","BPDiastolic":"56.00","SPO2":"56.00"}]

        // for (var i = 0; i < jsonData.length; i++) {
        //
        //   final jo = jsonData[i];
        //   String Temperature = jo['Temperature'].toString();
        //   String Pulse = jo['Pulse'].toString();
        //   String RR = jo['RR'].toString();
        //   String BPSystolic = jo['BPSystolic'].toString();
        //   String BPDiastolic = jo['BPDiastolic'].toString();
        //   String SPO2 = jo['SPO2'].toString();
        //
        //   Map<String, dynamic> OrganizationMap = {
        //     "Temperature": Temperature,
        //     "Pulse": Pulse,
        //     "RR" : RR,
        //     "BPSystolic" : BPSystolic,
        //     "BPDiastolic" : BPDiastolic,
        //     "SPO2" : SPO2,
        //   };
        //   listVitalChartValues.add(OrganizationMap);
        //   // debugPrint("Added to list: $complainName");
        //
        // }
        final snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text("Vitals Added Successfully"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {});

      }
      else {final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("There are Some Issue in Adding Vitals Please Try Again"),
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