import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:silvertouch/app_screens/ipd/input_chart_screen.dart';
import 'package:silvertouch/app_screens/ipd/output_chart_Table_screen.dart';
import 'package:silvertouch/app_screens/ipd/vital_chart_table.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/progress_dialog.dart';

class InputChartAddScreen extends StatefulWidget {


  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;

  InputChartAddScreen({
    required this.patientindooridp,
    required this.PatientIDP,
    required this.doctoridp,
    required this.firstname,
    required this.lastName,
  });

  @override
  State<InputChartAddScreen> createState() => _InputChartAddScreenState();
}
class _InputChartAddScreenState extends State<InputChartAddScreen> {

  List<Map<String, dynamic>> listInputChartValues = <Map<String, dynamic>>[];

  TextEditingController OralSubController = TextEditingController();
  TextEditingController OralQuantityController = TextEditingController();
  TextEditingController RTSubController = TextEditingController();
  TextEditingController RTQuantityController = TextEditingController();
  TextEditingController IV1QuantityController = TextEditingController();
  TextEditingController IV2QuantityController = TextEditingController();
  TextEditingController IV1DrugController = TextEditingController();
  TextEditingController IV2DrugController = TextEditingController();

  List<Map<String,dynamic>> listOfDocumentDropDown = <Map<String,dynamic>>[];
  Map<String, dynamic>? selectedMedicine;
  Map<String, dynamic>? selectedMedicine1;
  String? selectedMedicineIDP;
  String? selectedMedicineIDP1;

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
    getListOfDocumentDropDown(context);
    OralSubController = TextEditingController();
    OralQuantityController = TextEditingController();
    RTSubController = TextEditingController();
    RTQuantityController = TextEditingController();
    IV1QuantityController = TextEditingController();
    IV1DrugController = TextEditingController();
    IV2DrugController = TextEditingController();
    IV2QuantityController = TextEditingController();

    if (listInputChartValues.isNotEmpty) {
      OralSubController.text = listInputChartValues[0]["OralSub"];
      OralQuantityController.text = listInputChartValues[0]["OralQuantity"];
      RTSubController.text = listInputChartValues[0]["RTSub"];
      RTQuantityController.text = listInputChartValues[0]["RTQuantity"];
      IV1QuantityController.text = listInputChartValues[0]["IVDrug1"];
      IV1DrugController.text = listInputChartValues[0]["IVQuantity1"];
      IV2DrugController.text = listInputChartValues[0]["IVDrug2"];
      IV2QuantityController.text = listInputChartValues[0]["IVQuantity2"];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Input Chart"),
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
                                getInputChartValue(
                                  widget.patientindooridp,
                                  widget.PatientIDP,
                                  formattedTime,
                                );
                              },
                            )

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
                                  "ORAL: ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Ubuntu",
                                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    width:double.infinity,
                                    child: TextField(
                                      controller: OralSubController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 5,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(), // Add border here
                                        labelText: 'SUB', // Optional label
                                        hintText: 'Enter SUB', // Optional hint text
                                      ),
                                    )
                                ),
                              ),
                              SizedBox(height: 10,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    width:double.infinity,
                                    child: TextField(
                                      controller: OralQuantityController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 5,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(), // Add border here
                                        labelText: 'QUANTITY', // Optional label
                                        hintText: 'Enter QUANTITY', // Optional hint text
                                      ),
                                    )
                                ),
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
                                  "RT: ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Ubuntu",
                                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    width:double.infinity,
                                    child: TextField(
                                      controller: RTSubController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 5,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(), // Add border here
                                        labelText: 'SUB', // Optional label
                                        hintText: 'Enter SUB', // Optional hint text
                                      ),
                                    )
                                ),
                              ),
                              SizedBox(height: 10,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    width:double.infinity,
                                    child: TextField(
                                      controller: RTQuantityController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 5,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(), // Add border here
                                        labelText: 'QUANTITY', // Optional label
                                        hintText: 'Enter QUANTITY', // Optional hint text
                                      ),
                                    )
                                ),
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
                                  "IV1: ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Ubuntu",
                                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black, // Set the border color
                                      width: 2.0, // Set the border width
                                    ),
                                    borderRadius: BorderRadius.circular(8.0), // Set border radius if you want rounded corners
                                  ),
                                  width:double.infinity,
                                  child: Center(
                                    child: DropdownButton<Map<String, dynamic>>(
                                      hint: Center(child: Text('Select a Medicine')),
                                      value: selectedMedicine,
                                      onChanged: (Map<String, dynamic>? newValue) {
                                        setState(() {
                                          selectedMedicine = newValue;
                                          if (newValue != null) {
                                            selectedMedicineIDP = newValue['HospitalMedicineIDP'];
                                          } else {
                                            // Reset selected IDP when no value is selected
                                            selectedMedicineIDP = "";
                                          }
                                        });
                                      },
                                      isExpanded: true,
                                      items: listOfDocumentDropDown.map<DropdownMenuItem<Map<String, dynamic>>>((Map<String, dynamic> medicine) {
                                        return DropdownMenuItem<Map<String, dynamic>>(
                                          value: medicine,
                                          child: Row(
                                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(medicine['MedicineName'],
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,),
                                              SizedBox(width: 10),
                                              Text("(${medicine['DoseSchedule']})",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    width:double.infinity,
                                    child: TextField(
                                      controller: IV1QuantityController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 5,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(), // Add border here
                                        labelText: 'QUANTITY', // Optional label
                                        hintText: 'Enter QUANTITY', // Optional hint text
                                      ),
                                    )
                                ),
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
                                  "IV2: ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Ubuntu",
                                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black, // Set the border color
                                      width: 2.0, // Set the border width
                                    ),
                                    borderRadius: BorderRadius.circular(8.0), // Set border radius if you want rounded corners
                                  ),
                                  width:double.infinity,
                                  child: Center(
                                    child: DropdownButton<Map<String, dynamic>>(
                                      hint: Center(child: Text('Select a Medicine')),
                                      value: selectedMedicine1,
                                      onChanged: (Map<String, dynamic>? newValue) {
                                        setState(() {
                                          selectedMedicine1 = newValue;
                                          if (newValue != null) {
                                            selectedMedicineIDP1 = newValue['HospitalMedicineIDP'];
                                          } else {
                                            // Reset selected IDP when no value is selected
                                            selectedMedicineIDP1 = "";
                                          }
                                        });
                                      },
                                      isExpanded: true,
                                      items: listOfDocumentDropDown.map<DropdownMenuItem<Map<String, dynamic>>>((Map<String, dynamic> medicine) {
                                        return DropdownMenuItem<Map<String, dynamic>>(
                                          value: medicine,
                                          child: Row(
                                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(medicine['MedicineName']),
                                              SizedBox(width: 10),
                                              Text("(${medicine['DoseSchedule']})"),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    width:double.infinity,
                                    child: TextField(
                                      controller: IV2QuantityController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 5,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(), // Add border here
                                        labelText: 'QUANTITY', // Optional label
                                        hintText: 'Enter QUANTITY', // Optional hint text
                                      ),
                                    )
                                ),
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
                        String formattedTime = convertToFormattedTime(selectedValue);

                        // TextEditingController OralSubController,
                        //     TextEditingController OralQuantityController,
                        // TextEditingController RTSubController,
                        // TextEditingController RTQuantityController,
                        // TextEditingController IV1QuantityController,
                        // TextEditingController IV1DrugController,
                        // TextEditingController IV2DrugController,
                        // TextEditingController IV2QuantityController,
                        InputChartValueSend(
                          widget.patientindooridp,
                          widget.PatientIDP,
                          widget.doctoridp,
                          widget.firstname,
                          widget.lastName,
                          formattedTime,
                          OralSubController,
                          OralQuantityController,
                          RTSubController,
                          RTQuantityController,
                          IV1QuantityController,
                          selectedMedicineIDP.toString(),
                          selectedMedicineIDP1.toString(),
                          IV2QuantityController,
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

  void getListOfDocumentDropDown(BuildContext context) async{
    listOfDocumentDropDown = [];
    String loginUrl = "${baseURL}doctor_nursing_medicines_list.php";
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
      headers: {
        "u": patientUniqueKey,
        "type": userType,
      },
      body: {"getjson": encodedJSONStr},
    );

    debugPrint(response.body.toString());

    final jsonResponse = json.decode(response.body.toString());

    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    if (response.statusCode == 200)
      try{
        if (model.status == "OK") {
          var data = jsonResponse['Data'];
          var strData = decodeBase64(data);
          debugPrint("Decoded Buttton List: " + strData);

          final jsonData = json.decode(strData);

          for (var i = 0; i < jsonData.length; i++) {
            final jo = jsonData[i];

            String MedicineName = jo['MedicineName'].toString();
            String HospitalMedicineIDP = jo['HospitalMedicineIDP'].toString();
            String DoseSchedule = jo['DoseSchedule'].toString();
            String MedicineContent = jo['MedicineContent'].toString();

            Map<String, dynamic> MedicineMap = {
              "MedicineName": MedicineName,
              "HospitalMedicineIDP": HospitalMedicineIDP,
              "DoseSchedule" : DoseSchedule,
              "MedicineContent" : MedicineContent,
            };

            listOfDocumentDropDown.add(MedicineMap);

          }
          setState(() {});
        }
      }catch(e){
        print("Error decoding JSON: $e");
      }else {
      print("HTTP error: ${response.statusCode}");
    }
  }


  void getInputChartValue(
      String patientindooridp,
      String PatientIDF,
      selectedValue
      )
  async {
    print('getdoctorswitchorganization');

    try{
      String loginUrl = "${baseURL}doctor_input_nursing_chart_list.php";
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

      // {"PatientIDF":"736" , "PatientIndoorIDF":"20" ,"EntryDate":"2022-12-05" ,"EntryTime":"08:00"}

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

        // [{"IndoorNursingChartIDP":"1","OralSub":"30",
        // "OralQuantity":"30","IVDrug1":"30",
        // "IVQuantity1":"30","IVDrug2":"30","IVQuantity2":"30","RTSub":"30","RTQuantity":"30"}]

        listInputChartValues.clear(); // Clear the list before adding new entries

        for (var i = 0; i < jsonData.length; i++) {
          print("Processing Entry $i: ${jsonData[i]}");
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

          // String Stool = jo['Stool'].toString();
          // String Other = jo['Other'].toString();

          print("OralSub: $OralSub, OralQuantity: $OralQuantity, IVDrug1: $IVDrug1,"
              "IVQuantity1: $IVQuantity1, IVDrug2: $IVDrug2, IVQuantity2: $IVQuantity2"
              "RTSub: $RTSub, RTQuantity: $RTQuantity");

          // Check if all values are non-empty

          Map<String, dynamic> OrganizationMap = {
            "IndoorNursingChartIDP": IndoorNursingChartIDP,
            "OralSub": OralSub,
            "OralQuantity": OralQuantity,
            "IVDrug1": IVDrug1,
            "IVQuantity1": IVQuantity1,
            "IVDrug2": IVDrug2,
            "IVQuantity2": IVQuantity2,
            "RTSub": RTSub,
            "RTQuantity": RTQuantity,
          };

          listInputChartValues.add(OrganizationMap);
        }

        // Print the values of listVitalChartValues
        // OralSubController = TextEditingController();
        // OralQuantityController = TextEditingController();
        // RTSubController = TextEditingController();
        // RTQuantityController = TextEditingController();
        // IV1QuantityController = TextEditingController();
        // IV1DrugController = TextEditingController();
        // IV2DrugController = TextEditingController();
        // IV2QuantityController = TextEditingController();

        print("Vital Chart Values: $listInputChartValues");

        setState(() {
          OralSubController.text = listInputChartValues.isNotEmpty ? listInputChartValues[0]["OralSub"] : '';
          OralQuantityController.text = listInputChartValues.isNotEmpty ? listInputChartValues[0]["OralQuantity"] : '';
          RTSubController.text = listInputChartValues.isNotEmpty ? listInputChartValues[0]["RTSub"] : '';
          RTQuantityController.text = listInputChartValues.isNotEmpty ? listInputChartValues[0]["RTQuantity"] : '';
          IV1QuantityController.text = listInputChartValues.isNotEmpty ? listInputChartValues[0]["IVQuantity1"] : '';
          IV1DrugController.text = listInputChartValues.isNotEmpty ? listInputChartValues[0]["IVDrug1"] : '';
          IV2DrugController.text = listInputChartValues.isNotEmpty ? listInputChartValues[0]["IVDrug2"] : '';
          IV2QuantityController.text = listInputChartValues.isNotEmpty ? listInputChartValues[0]["IVQuantity2"] : '';

          print("Temperature: ${OralSubController.text}");
          print("Pulse: ${OralQuantityController.text}");
        });
      }
    }catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  void InputChartValueSend(
      String patientindooridp,
      String PatientIDF,
      String doctoridp,
      String firstname,
      String lastName,
      selectedValue,
      TextEditingController OralSubController,
      TextEditingController OralQuantityController,
      TextEditingController RTSubController,
      TextEditingController RTQuantityController,
      TextEditingController IV1QuantityController,
      String selectedMedicine,
      String selectedMedicine1,
      TextEditingController IV2QuantityController,
      )
  async {
    print('getdoctorswitchorganization');

    try{
      String loginUrl = "${baseURL}doctor_add_input_chart_submit.php";
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
          "\"" + "OralSub" + "\"" + ":" + "\"" + OralSubController.text + "\"" + "," +
          "\"" + "OralQuantity" + "\"" + ":" + "\"" + OralQuantityController.text + "\"" + "," +
          "\"" + "IVDrug1" + "\"" + ":" + "\"" + selectedMedicine + "\"" + "," +
          "\"" + "IVQuantity1" + "\"" + ":" + "\"" + IV1QuantityController.text + "\"" + "," +
          "\"" + "IVDrug2" + "\"" + ":" + "\"" + selectedMedicine1+ "\"" + "," +
          "\"" + "IVQuantity2" + "\"" + ":" + "\"" + IV2QuantityController.text + "\"" + "," +
          "\"" + "RTSub" + "\"" + ":" + "\"" + RTSubController.text + "\"" + "," +
          "\"" + "RTQuantity" + "\"" + ":" + "\"" + RTQuantityController.text+ "\"" +
          "}";

      // {"PatientIDF":"736" , "PatientIndoorIDF":"20" ,
      // "EntryDate":"2022-12-05" ,
      // "EntryTime":"8:00" ,"OralSub":"66" ,"OralQuantity":"56" ,
      // "IVDrug1":"65","IVQuantity1":"56","IVDrug2":"56",
      // "IVQuantity2":"56","RTSub":"9909","RTQuantity":"453"}

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
        Navigator.pushReplacement (
            context,
            MaterialPageRoute(
                builder: (context) =>
                    InputChartScreen(
                        patientindooridp: patientindooridp,
                        PatientIDP: PatientIDF,
                        doctoridp: doctoridp,
                        firstname: firstname,
                        lastName: lastName)
            )
        );
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
