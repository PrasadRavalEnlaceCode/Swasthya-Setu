import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:swasthyasetu/app_screens/ipd/output_chart_Table_screen.dart';
import 'package:swasthyasetu/app_screens/ipd/vital_chart_table.dart';
import 'package:swasthyasetu/controllers/consultation_vitals_controller.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/color.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:swasthyasetu/utils/ultimate_slider.dart';

import '../add_consultation_screen.dart';
import '../add_vital_screen.dart';

double pulseValue = 20,
    bpSystolicValue = 30,
    bpDiastolicValue = 10,
    spo2Value = 0;
String heightInFeet = "0 Ft  0 In";

double tempValue = 90;

double weightValue = 0, heightValue = 0;

class MONotesScreen extends StatefulWidget {

  ConsultationVitalsController consultationVitalsController =
  Get.put(ConsultationVitalsController());

  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;

  MONotesScreen({
    required this.patientindooridp,
    required this.PatientIDP,
    required this.doctoridp,
    required this.firstname,
    required this.lastName,
  });

  @override
  State<MONotesScreen> createState() => _MONotesScreenState();
}
class _MONotesScreenState extends State<MONotesScreen> {

  List<Map<String, dynamic>> MONotes = <Map<String, dynamic>>[];

  ScrollController _scrollController = new ScrollController();

  TextEditingController SystolicController = TextEditingController();
  TextEditingController DiastolicController = TextEditingController();
  TextEditingController TemperatureController = TextEditingController();
  TextEditingController PulseController = TextEditingController();
  TextEditingController SPO2Controller = TextEditingController();
  TextEditingController ComplainController = TextEditingController();
  TextEditingController AdviceandPlanController = TextEditingController();
  TextEditingController CVSController = TextEditingController();
  TextEditingController CNSController = TextEditingController();
  TextEditingController RSController = TextEditingController();
  TextEditingController PandAController = TextEditingController();

  bool vitalsVisible = false;

  List<String> timeSlots = [];  // Declare the list once

  String selectedValue = 'Select Time';
  DateTime selectedDate = DateTime.now();
  DateTime selectedTime = DateTime.now();

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
  void initState() {
    vitalsVisible = false;
    SystolicController = TextEditingController();
    DiastolicController = TextEditingController();
    TemperatureController = TextEditingController();
    PulseController = TextEditingController();
    SPO2Controller = TextEditingController();
    ComplainController = TextEditingController();
    AdviceandPlanController = TextEditingController();
    CVSController = TextEditingController();
    CNSController = TextEditingController();
    RSController = TextEditingController();
    PandAController = TextEditingController();


    if (MONotes.isNotEmpty) {
      ComplainController.text = MONotes[0]["Urine"];
      AdviceandPlanController.text = MONotes[0]["Vomit"];
      CVSController.text = MONotes[0]["ASP"];
      CNSController.text = MONotes[0]["Stool"];
      RSController.text = MONotes[0]["Other"];
      PandAController.text = MONotes[0]["Other"];
    }
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medical Officer's Notes"),
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
                              fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                            size: SizeConfig.blockSizeHorizontal !* 4.0,
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
                            width: SizeConfig.blockSizeHorizontal !* 4.0,
                          ),
                          Text(
                            "${DateFormat('hh:mm a').format(selectedTime)}",
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
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
                    onTap: (){
                      // getInputChartPDF(
                      //   widget.patientindooridp ,
                      // );
                    },
                    child: Icon(
                        Icons.cloud_download_outlined,size: 30.0,color: Colors.blue),),
                ],
              ),

              Divider(),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: <Widget>[
                    SizedBox(
                      height: SizeConfig.blockSizeVertical !* 1,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockSizeHorizontal !* 3),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            vitalsVisible = !vitalsVisible;
                          });
                        },
                        child: Container(
                          color: const Color(0xFFeef2df),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.blockSizeHorizontal !* 3,
                                vertical: SizeConfig.blockSizeVertical !* 0.5),
                            child: Row(
                              children: [
                                Text(
                                  "Vitals",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                      SizeConfig.blockSizeHorizontal !* 4.2),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(
                                      vitalsVisible
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down,
                                      size: SizeConfig.blockSizeHorizontal !* 8,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: vitalsVisible,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockSizeHorizontal !* 3),
                        child: Container(
                          color: const Color(0x70eef2df),
                          child: Column(
                            children: [
                              SizedBox(
                                height: SizeConfig.blockSizeVertical !* 1,
                              ),
                              SliderWidget(
                                min: 30,
                                max: 250,
                                value: bpSystolicValue.toDouble(),
                                title: "BP Systolic",
                                unit: "mm of hg",
                              ),
                              SliderWidget(
                                min: 10,
                                max: 200,
                                value: bpDiastolicValue.toDouble(),
                                title: "BP Diastolic",
                                unit: "mm of hg",
                              ),
                              SliderWidget(
                                min: 0,
                                max: 100,
                                value: spo2Value.toDouble(),
                                title: "SPO2",
                                unit: "%",
                              ),
                              SliderWidget(
                                min: 20,
                                max: 250,
                                value: pulseValue.toDouble(),
                                title: "Pulse",
                                unit: "per min.",
                              ),
                              SliderWidget(
                                min: 90,
                                max: 105,
                                value: tempValue,
                                title: "Temperature",
                                unit: "per min.",
                                isDecimal: true,
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical !* 2.5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical !* 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          Container(
                              width:double.infinity,
                              child: TextField(
                                controller: ComplainController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(), // Add border here
                                  labelText: 'Complain', // Optional label
                                  hintText: 'Complain', // Optional hint text
                                ),
                              )
                          ),
                          SizedBox(height: SizeConfig.blockSizeVertical !* 2,),
                          Container(
                              width:double.infinity,
                              child: TextField(
                                controller: AdviceandPlanController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(), // Add border here
                                  labelText: 'Advise & Plan', // Optional label
                                  hintText: 'Advise Investigations', // Optional hint text
                                ),
                              )
                          ),
                          SizedBox(height: SizeConfig.blockSizeVertical !* 2,),
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
                                  SizedBox(height: SizeConfig.blockSizeVertical !* 2,),
                                  Container(
                                    child: Text(
                                      "Examination:- ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Ubuntu",
                                        fontSize: SizeConfig.blockSizeVertical! * 2.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: SizeConfig.blockSizeVertical !* 2,),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        width:double.infinity,
                                        child: TextField(
                                          controller: CVSController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(), // Add border here
                                            labelText: 'CVS', // Optional label
                                            hintText: 'CVS', // Optional hint text
                                          ),
                                        )
                                    ),
                                  ),
                                  SizedBox(height: SizeConfig.blockSizeVertical !* 2,),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        width:double.infinity,
                                        child: TextField(
                                          controller: CNSController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(), // Add border here
                                            labelText: 'CNS', // Optional label
                                            hintText: 'CNS', // Optional hint text
                                          ),
                                        )
                                    ),
                                  ),
                                  SizedBox(height: SizeConfig.blockSizeVertical !* 2,),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        width:double.infinity,
                                        child: TextField(
                                          controller: RSController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(), // Add border here
                                            labelText: 'RS', // Optional label
                                            hintText: 'RS', // Optional hint text
                                          ),
                                        )
                                    ),
                                  ),
                                  SizedBox(height: SizeConfig.blockSizeVertical !* 2,),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        width:double.infinity,
                                        child: TextField(
                                          controller: PandAController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(), // Add border here
                                            labelText: 'P/A', // Optional label
                                            hintText: 'P/A', // Optional hint text
                                          ),
                                        )
                                    ),
                                  ),
                                  SizedBox(height: SizeConfig.blockSizeVertical !* 2,),
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
                            // String formattedTime = convertToFormattedTime(selectedValue);

                            MONotesDataSend(
                              widget.patientindooridp,
                              widget.PatientIDP,
                              widget.doctoridp,
                              widget.firstname,
                              widget.lastName,
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


            ],
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

        MONotes.clear(); // Clear the list before adding new entries

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

          MONotes.add(OrganizationMap);
        }

        // Print the values of listVitalChartValues
        print("Vital Chart Values: $MONotes");

        setState(() {
          SystolicController.text = MONotes.isNotEmpty ? MONotes[0]["Urine"] : '';
          DiastolicController.text = MONotes.isNotEmpty ? MONotes[0]["Vomit"] : '';
          TemperatureController.text = MONotes.isNotEmpty ? MONotes[0]["ASP"] : '';
          PulseController.text = MONotes.isNotEmpty ? MONotes[0]["Stool"] : '';
          SPO2Controller.text = MONotes.isNotEmpty ? MONotes[0]["Other"] : '';

          print("Temperature: ${SystolicController.text}");
          print("Pulse: ${DiastolicController.text}");
        });
      }
    }catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  void MONotesDataSend(
      String patientindooridp,
      String PatientIDF,
      String doctoridp,
      String firstname,
      String lastName,
      )
  async {
    print('MoNotesSend');

    String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    String formattedTime = DateFormat('HH:mm').format(selectedTime);

    String loginUrl = "${baseURL}doctor_add_medical_officer_submit.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    String patientIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String bpSystolic = "",
        bpDiastolic = "",
        pulse = "",
        spo2 = "",
        IndoorMedicalOfficerIDP = "",
        temperature = "";
    // height = "",
    // weight = "";
    if (widget.consultationVitalsController.isCheckedBPSystolic.value) {
      bpSystolic = bpSystolicValue.toString();
      bpDiastolic = bpDiastolicValue.toString();
    }
    /*if (widget.consultationVitalsController.isCheckedBPDiastolic.value)*/
    if (widget.consultationVitalsController.isCheckedPulse.value)
      pulse = pulseValue.toString();
    if (widget.consultationVitalsController.isCheckedSPO2.value)
      spo2 = spo2Value.toString();
    if (widget.consultationVitalsController.isCheckedTemperature.value)
      temperature = tempValue.toStringAsFixed(2);
    // if (widget.consultationVitalsController.isCheckedHeight.value)
    //   height = heightValue.toString();
    // if (widget.consultationVitalsController.isCheckedWeight.value)
    //   weight = weightValue.toString();

    String jsonStr = "{" +
        "\"SPO2\":\"$spo2\"" +
        ",\"Pulse\":\"$pulse\"" +
        ",\"Temperature\":\"$temperature\"" +
        ",\"BPDystolic\":\"$bpDiastolic\"" +
        ",\"BPSystolic\":\"$bpSystolic\"" +
        ",\"advice\":\"${replaceNewLineBySlashN(AdviceandPlanController.text.toString().trim())}\"" +
        ",\"DoctorIDP\":\"${patientIDP}\"" +
        ",\"PatientIndoorIDF\":\"${patientindooridp}\"" +
        ",\"PatientIDP\":\"${PatientIDF}\"" +
        ",\"IndoorMedicalOfficerIDP\":\"${IndoorMedicalOfficerIDP}\"" +
        ",\"cvs\":\"${replaceNewLineBySlashN(CVSController.text.toString().trim())}\"" +
        ",\"cns\":\"${CNSController.text.trim()}\"" +
        ",\"rs\":\"${RSController.text.trim()}\"" +
        ",\"pa\":\"${PandAController.text.trim()}\""+
        ",\"EntryDate\":\"${formattedDate}\"" +
        ",\"EntryTime\":\"${formattedTime}\"" +
        ",\"Complain\":\"${replaceNewLineBySlashN(ComplainController.text.toString().trim())}\"" +

        "}";



    debugPrint('Check------------------------------------------------');
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
    pr!.hide();
    if (model.status == "OK") {
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr!.hide();

      Navigator.pop(context);
      // if (totalServices == "0") {
      //   Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      //     return OPDRegistrationDetailsScreen(widget.idp, widget.patientIDP);
      //   })).then((value) {
      //     Navigator.of(context).pop();
      //   });
      // } else {
      //   Future.delayed(Duration(milliseconds: 300), () {
      //     Navigator.of(context).pop();
      //   });
      // }
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr!.hide();
    }
  }

    // try{
    //
    //   String loginUrl = "${baseURL}doctor_add_output_chart_submit.php";
    //   ProgressDialog pr = ProgressDialog(context);
    //   Future.delayed(Duration.zero, () {
    //     pr.show();
    //   });
    //
    //   // Format the selected date
    //   String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    //
    //   String patientUniqueKey = await getPatientUniqueKey();
    //   String userType = await getUserType();
    //   String patientIDP = await getPatientOrDoctorIDP();
    //   debugPrint("Key and type");
    //   debugPrint(patientUniqueKey);
    //   debugPrint(userType);
    //   String jsonStr = "{" + "\"" + "PatientIDF" + "\"" + ":" + "\"" + PatientIDF + "\"" + "," +
    //       "\"" + "PatientIndoorIDF" + "\"" + ":" + "\"" + patientindooridp + "\"" + "," +
    //       "\"" + "EntryDate" + "\"" + ":" + "\"" + formattedDate + "\"" + "," +
    //       "\"" + "EntryTime" + "\"" + ":" + "\"" + selectedValue + "\"" + "," +
    //       "\"" + "Urine" + "\"" + ":" + "\"" + UrineController.text + "\"" + "," +
    //       "\"" + "Vomit" + "\"" + ":" + "\"" + VOMITController.text + "\"" + "," +
    //       "\"" + "ASP" + "\"" + ":" + "\"" + ASPController.text + "\"" + "," +
    //       "\"" + "Stool" + "\"" + ":" + "\"" + STOOLController.text + "\"" + "," +
    //       "\"" + "Other" + "\"" + ":" + "\"" + OTHERController.text+ "\"" +
    //       "}";
    //
    //   // {"PatientIDF":"736" , "PatientIndoorIDF":"20" ,
    //   // "EntryDate":"2022-12-05" ,"EntryTime":"8:00"
    //   // ,"Urine":"66" ,"Vomit":"56" ,"ASP":"65","Stool":"56","Other":"56"}
    //
    //   debugPrint(jsonStr);
    //
    //   String encodedJSONStr = encodeBase64(jsonStr);
    //   var response = await apiHelper.callApiWithHeadersAndBody(
    //     url: loginUrl,
    //
    //     headers: {
    //       "u": patientUniqueKey,
    //       "type": userType,
    //     },
    //     body: {"getjson": encodedJSONStr},
    //   );
    //   //var resBody = json.decode(response.body);
    //
    //   debugPrint(response.body.toString());
    //   final jsonResponse = json.decode(response.body.toString());
    //
    //   ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    //
    //   pr.hide();
    //
    //   if (model.status == "OK") {
    //
    //     final snackBar = SnackBar(
    //       backgroundColor: Colors.green,
    //       content: Text("Output Added Successfully"),
    //     );
    //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //     setState(() {});
    //
    //     Navigator.pop(context);
    //   }
    //   else {final snackBar = SnackBar(
    //     backgroundColor: Colors.red,
    //     content: Text("There are Some Issue in Adding Output Please Try Again"),
    //   );
    //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //
    //   setState(() {});
    //   }
    // }catch (e) {
    //   print('Error decoding JSON: $e');
    // }
  // }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }

}

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  int min;

  int max;
  String title = "";
  double value;
  final fullWidth;
  String unit;
  Function? callbackFromBMI;
  Function? selectedPatientOfSameDate;
  bool isDecimal;

  SliderWidget({
    this.sliderHeight = 50,
    this.max = 1000,
    this.min = 0,
    this.value = 0,
    this.title = "",
    this.fullWidth = true,
    this.unit = "",
    this.callbackFromBMI,
    this.selectedPatientOfSameDate,
    this.isDecimal = false,
  });

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  double _value = 0;
  ConsultationVitalsController consultationVitalsController = Get.find();

  @override
  void initState() {
    //_value = widget.value / (widget.max - widget.min);
    _value = widget.value;
    if (widget.title == "Pulse") pulseValue = _value;
    if (widget.title == "Temperature")
      tempValue = _value;
    else if (widget.title == "BP Systolic")
      bpSystolicValue = _value;
    else if (widget.title == "BP Diastolic")
      bpDiastolicValue = _value;
    else if (widget.title == "SPO2")
      spo2Value = _value;
    else if (widget.title == "Height")
      heightValue = _value;
    else if (widget.title == "Weight") weightValue = _value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color getColorFromTitle(String title) {
      if (title == "BP Systolic")
        return Colors.amber;
      else if (title == "BP Diastolic")
        return Colors.blue;
      else if (title == "SPO2")
        return Colors.green;
      else if (title == "Pulse")
        return Colors.deepOrangeAccent;
      else if (title == "Temperature")
        return Colors.teal;
      else if (title == "Height")
        return Colors.purpleAccent;
      else if (title == "Weight") return Colors.cyan;
      return Colors.amber;
    }

    return Container(
      color: Colors.white,
      width: SizeConfig.blockSizeHorizontal !* 92.0,
      padding:
      EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal !* 6),
      child: Obx(
            () => Column(
          children: <Widget>[
            Visibility(
              visible: widget.title == "Height",
              child: Text(
                '$heightInFeet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal !* 3.8,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Visibility(
              visible: widget.title == "Walking",
              child: Text(
                '$walkingStepsValue steps',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal !* 3.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Checkbox(
                    value: getValueOfCheckBox(),
                    onChanged: (isChecked) {
                      if (widget.title == "Pulse") {
                        consultationVitalsController.isCheckedPulse.value =
                        isChecked!;
                        /*if (!isChecked) {
                                widget.value = widget.min.toDouble();
                                pulseValue = widget.min.toDouble();
                                setState(() {});
                              }*/
                      } else if (widget.title == "BP Systolic") {
                        consultationVitalsController.isCheckedBPSystolic.value =
                        isChecked!;
                        /*if (!isChecked) {
                                widget.value = widget.min.toDouble();
                                bpSystolicValue = widget.min;
                                setState(() {});
                              }*/
                      } else if (widget.title == "BP Diastolic") {
                        consultationVitalsController.isCheckedBPSystolic.value =
                        isChecked!;
                        /*if (!isChecked) {
                                widget.value = widget.min.toDouble();
                                bpDiastolicValue = widget.min;
                                setState(() {});
                              }*/
                      } else if (widget.title == "Temperature") {
                        consultationVitalsController
                            .isCheckedTemperature.value = isChecked!;
                      } else if (widget.title == "Height") {
                        consultationVitalsController.isCheckedHeight.value =
                        isChecked!;
                        /*if (!isChecked) {
                                widget.value = widget.min.toDouble();
                                heightValue = widget.min;
                                setState(() {});
                              }*/
                      } else if (widget.title == "Weight") {
                        consultationVitalsController.isCheckedWeight.value =
                        isChecked!;
                        /*if (!isChecked) {
                                widget.value = widget.min.toDouble();
                                weightValue = widget.min;
                                setState(() {});
                              }*/
                      } else if (widget.title == "SPO2") {
                        consultationVitalsController.isCheckedSPO2.value =
                        isChecked!;
                        /*if (!isChecked) {
                                widget.value = widget.min.toDouble();
                                spo2Value = widget.min;
                                setState(() {});
                              }*/
                      }
                    }),
                Expanded(
                  child: UltimateSlider(
                      minValue: widget.min.toDouble(),
                      maxValue: widget.max.toDouble(),
                      value: widget.value,
                      showDecimals: widget.isDecimal,
                      decimalInterval: 0.05,
                      titleText: widget.title,
                      unitText: widget.unit,
                      indicatorColor: getColorFromTitle(widget.title),
                      bubbleColor: getColorFromTitle(widget.title),
                      onValueChange: (val) {
                        widget.value = val.toDouble();
                        if (jsonConsultation['CheckOutStatus'] == "0" &&
                            widget.selectedPatientOfSameDate!()) {
                          setState(() {
                            _value = val.toDouble();
                            widget.value = val.toDouble();
                            if (widget.title == "Pulse") {
                              pulseValue = widget.value;
                              consultationVitalsController
                                  .isCheckedPulse.value = true;
                              debugPrint(pulseValue.round().toString());
                            }
                            if (widget.title == "Temperature") {
                              tempValue = widget.value;
                              consultationVitalsController
                                  .isCheckedTemperature.value = true;
                            } else if (widget.title == "BP Systolic") {
                              bpSystolicValue = widget.value;
                              consultationVitalsController
                                  .isCheckedBPSystolic.value = true;
                              debugPrint(bpSystolicValue.round().toString());
                            } else if (widget.title == "BP Diastolic") {
                              bpDiastolicValue = widget.value;
                              consultationVitalsController
                                  .isCheckedBPSystolic.value = true;
                              /*consultationVitalsController
                                        .isCheckedBPDiastolic.value = true;*/
                              debugPrint(bpDiastolicValue.round().toString());
                            } else if (widget.title == "SPO2") {
                              spo2Value = widget.value;
                              consultationVitalsController.isCheckedSPO2.value =
                              true;
                              debugPrint(spo2Value.round().toString());
                            } else if (widget.title == "Weight") {
                              weightValue = widget.value;
                              consultationVitalsController
                                  .isCheckedWeight.value = true;
                              widget.callbackFromBMI!();
                            } else if (widget.title == "Height") {
                              heightValue = widget.value;
                              consultationVitalsController
                                  .isCheckedHeight.value = true;
                              cmToFeet();
                              widget.callbackFromBMI!();
                            }
                          });
                        }
                      }),
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical !* 5.0,
            )
          ],
        ),
      ),
    );
  }

  void cmToFeet() {
    double heightInFeetWithDecimal = heightValue * 0.0328084;
    int intHeightInFeet = heightInFeetWithDecimal.toInt();
    double remainingDecimals = heightInFeetWithDecimal - intHeightInFeet;
    int intHeightInInches = (remainingDecimals * 12).round().toInt();
    if (intHeightInInches == 12) {
      intHeightInFeet++;
      intHeightInInches = 0;
    }
    heightInFeet = "$intHeightInFeet Ft  $intHeightInInches In";
  }

  bool getValueOfCheckBox() {
    if (widget.title == "Pulse") {
      return consultationVitalsController.isCheckedPulse.value;
    }
    if (widget.title == "Temperature") {
      return consultationVitalsController.isCheckedTemperature.value;
    } else if (widget.title == "BP Systolic") {
      return consultationVitalsController.isCheckedBPSystolic.value;
    } else if (widget.title == "BP Diastolic") {
      return consultationVitalsController.isCheckedBPSystolic.value;
      /*return consultationVitalsController.isCheckedBPDiastolic.value;*/
    } else if (widget.title == "SPO2") {
      return consultationVitalsController.isCheckedSPO2.value;
    } else if (widget.title == "Height") {
      return consultationVitalsController.isCheckedHeight.value;
    } else if (widget.title == "Weight") {
      return consultationVitalsController.isCheckedWeight.value;
    }
    return false;
  }
}
