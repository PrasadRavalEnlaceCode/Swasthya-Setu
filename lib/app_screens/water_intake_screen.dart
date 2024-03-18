import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

import '../utils/color.dart';

TextEditingController entryDateController = new TextEditingController();
TextEditingController entryTimeController = new TextEditingController();

var pickedDate = DateTime.now();
var pickedTime = TimeOfDay.now();

int waterTaken = 0;
int waterUnitGlass = 0;
int waterUnitSmallBottle = 0;
int waterUnitLargeBottle = 0;

class WaterIntakeScreen extends StatefulWidget {
  String patientIDP;

  WaterIntakeScreen(this.patientIDP);

  @override
  State<StatefulWidget> createState() {
    return WaterIntakeScreenState();
  }
}

class WaterIntakeScreenState extends State<WaterIntakeScreen> {
  ProgressDialog? pr;

  @override
  void initState() {
    super.initState();
    pickedDate = DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(pickedDate);
    entryDateController = TextEditingController(text: formatted);

    final now = new DateTime.now();
    var dateOfTime =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);

    pickedTime = TimeOfDay.now();

    var formatterTime = new DateFormat('HH:mm');
    String formattedTime = formatterTime.format(dateOfTime);
    debugPrint("formatted time");
    debugPrint(formattedTime);
    entryTimeController = TextEditingController(text: formattedTime);
    setState(() {});
  }

  @override
  void dispose() {
    entryDateController.clear();
    entryTimeController.clear();
    waterTaken = 0;
    waterUnitGlass = 0;
    waterUnitSmallBottle = 0;
    waterUnitLargeBottle = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Water Intake"),
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(color: Colorsblack), toolbarTextStyle: TextTheme(
              titleMedium: TextStyle(
            color: Colorsblack,
            fontFamily: "Ubuntu",
            fontSize: SizeConfig.blockSizeVertical !* 2.5,
          )).bodyMedium, titleTextStyle: TextTheme(
              titleMedium: TextStyle(
            color: Colorsblack,
            fontFamily: "Ubuntu",
            fontSize: SizeConfig.blockSizeVertical !* 2.5,
          )).titleLarge,
        ),
        body: Builder(
          builder: (context) {
            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.center,
                              child: MaterialButton(
                                onPressed: () {
                                  showDateSelectionDialog();
                                },
                                child: Container(
                                  child: IgnorePointer(
                                    child: TextField(
                                      controller: entryDateController,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.1),
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.1),
                                        labelStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.1),
                                        labelText: "Entry Date",
                                        hintText: "",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.center,
                              child: MaterialButton(
                                onPressed: () {
                                  showTimeSelectionDialog();
                                },
                                child: Container(
                                  child: IgnorePointer(
                                    child: TextField(
                                      controller: entryTimeController,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.1),
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.1),
                                        labelStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.blockSizeVertical !*
                                                    2.1),
                                        labelText: "Entry Time",
                                        hintText: "",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical !* 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          /*Visibility(
                        child: InkWell(
                          onTap: () {},
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal * 6,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal * 3,
                      ),*/
                          Text(
                            "${waterTaken.toString()} ml",
                            style: TextStyle(
                                color: Color(0xFF5FC4F8),
                                fontSize: SizeConfig.blockSizeHorizontal !* 8),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical !* 3,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Image(
                              width: SizeConfig.blockSizeHorizontal !* 12,
                              height: SizeConfig.blockSizeHorizontal !* 12,
                              //height: 80,
                              image: AssetImage("images/ic_water_glass.png"),
                            ),
                          )),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal !* 3,
                          ),
                          Expanded(
                            child: Image(
                              width: SizeConfig.blockSizeHorizontal !* 20,
                              height: SizeConfig.blockSizeHorizontal !* 20,
                              //height: 80,
                              image: AssetImage("images/ic_water_bottle.png"),
                            ),
                          ),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal !* 3,
                          ),
                          Expanded(
                            child: Image(
                              width: SizeConfig.blockSizeHorizontal !* 28,
                              height: SizeConfig.blockSizeHorizontal !* 28,
                              //height: 80,
                              image: AssetImage("images/ic_water_bottle.png"),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical !* 2,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              "Glass",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: SizeConfig.blockSizeHorizontal !* 4),
                            ),
                          )),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal !* 3,
                          ),
                          Expanded(
                              child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              "Small Bottle",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: SizeConfig.blockSizeHorizontal !* 4),
                            ),
                          )),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal !* 3,
                          ),
                          Expanded(
                              child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              "Large Bottle",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: SizeConfig.blockSizeHorizontal !* 4),
                            ),
                          )),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical !* 0.5,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              "250 ml",
                              style: TextStyle(
                                  color: Color(0xFF84879C),
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal !* 3.2),
                            ),
                          )),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal !* 3,
                          ),
                          Expanded(
                              child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              "500 ml",
                              style: TextStyle(
                                  color: Color(0xFF84879C),
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal !* 3.2),
                            ),
                          )),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal !* 3,
                          ),
                          Expanded(
                              child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              "1000 ml",
                              style: TextStyle(
                                  color: Color(0xFF84879C),
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal !* 3.2),
                            ),
                          )),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical !* 1.5,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    waterTaken = waterTaken + 250;
                                    waterUnitGlass = waterUnitGlass + 1;
                                  });
                                },
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color: Color(0xFF5FC4F8),
                                  size: SizeConfig.blockSizeHorizontal !* 10,
                                ),
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal !* 1,
                              ),
                              Text(
                                waterUnitGlass.toString(),
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal !* 5,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal !* 1,
                              ),
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      waterTaken = waterTaken - 250;
                                      waterUnitGlass = waterUnitGlass - 1;
                                    });
                                  },
                                  child: Visibility(
                                    visible: waterUnitGlass > 0,
                                    child: Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                      size: SizeConfig.blockSizeHorizontal !* 10,
                                    ),
                                  )),
                            ],
                          )),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal !* 3,
                          ),
                          Expanded(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    waterTaken = waterTaken + 500;
                                    waterUnitSmallBottle =
                                        waterUnitSmallBottle + 1;
                                  });
                                },
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color: Color(0xFF5FC4F8),
                                  size: SizeConfig.blockSizeHorizontal !* 10,
                                ),
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal !* 1,
                              ),
                              Text(
                                waterUnitSmallBottle.toString(),
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal !* 5,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal !* 1,
                              ),
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      waterTaken = waterTaken - 500;
                                      waterUnitSmallBottle =
                                          waterUnitSmallBottle - 1;
                                    });
                                  },
                                  child: Visibility(
                                    visible: waterUnitSmallBottle > 0,
                                    child: Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                      size: SizeConfig.blockSizeHorizontal !* 10,
                                    ),
                                  )),
                            ],
                          )),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal !* 3,
                          ),
                          Expanded(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    waterTaken = waterTaken + 1000;
                                    waterUnitLargeBottle =
                                        waterUnitLargeBottle + 1;
                                  });
                                },
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color: Color(0xFF5FC4F8),
                                  size: SizeConfig.blockSizeHorizontal !* 10,
                                ),
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal !* 1,
                              ),
                              Text(
                                waterUnitLargeBottle.toString(),
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal !* 5,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal !* 1,
                              ),
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      waterTaken = waterTaken - 1000;
                                      waterUnitLargeBottle =
                                          waterUnitLargeBottle - 1;
                                    });
                                  },
                                  child: Visibility(
                                    visible: waterUnitLargeBottle > 0,
                                    child: Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                      size: SizeConfig.blockSizeHorizontal !* 10,
                                    ),
                                  )),
                            ],
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: waterTaken > 0,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 2.0,
                      ),
                      child: RawMaterialButton(
                        onPressed: () {
                          submitVitalDetails(context);
                        },
                        elevation: 2.0,
                        fillColor: Color(0xFF06A759),
                        child: Image(
                          width: SizeConfig.blockSizeHorizontal !* 5.5,
                          height: SizeConfig.blockSizeHorizontal !* 5.5,
                          //height: 80,
                          image: AssetImage(
                              "images/ic_right_arrow_triangular.png"),
                        ),
                        shape: CircleBorder(),
                      ),
                      /*),*/
                    ),
                  ),
                )
              ],
            );
          },
        ));
  }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    //var base64str =
    return base64.encode(bytes);
    //= Base64Encoder().convert()
  }

  String decodeBase64(String text) {
    //var bytes = utf8.encode(text);
    //var base64str =
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
    //= Base64Encoder().convert()
  }

  Future<void> submitVitalDetails(BuildContext context) async {
    if (entryDateController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Entry Date"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (entryTimeController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Temperature is compulsory"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (waterTaken == 0) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Water Intake"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    String loginUrl = "${baseURL}patientVitalSubmit.php";

    pr = ProgressDialog(context);

    pr!.show();

    String patientUniqueKey = await getPatientUniqueKey();

    String userType = await getUserType();

    debugPrint("Key and type");

    debugPrint(patientUniqueKey);

    debugPrint(userType);

    String vitalValue = waterTaken.toString();

    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP +
        "\"" +
        "," +
        "\"" +
        "VitalEntryDate" +
        "\"" +
        ":" +
        "\"" +
        entryDateController.text +
        "\"" +
        "," +
        "\"" +
        "VitalEntryTime" +
        "\"" +
        ":" +
        "\"" +
        entryTimeController.text +
        "\"" +
        "," +
        "\"" +
        "VitalIDP" +
        "\"" +
        ":" +
        "\"" +
        "20" +
        "\"" +
        "," +
        "\"" +
        "VitalValue" +
        "\"" +
        ":" +
        "\"" +
        vitalValue.toString() +
        "\"" +
        "}";

    debugPrint("Vital value");

    debugPrint(vitalValue.toString());

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

    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text("Water Intake details added successfully."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr!.hide();
      Future.delayed(Duration(milliseconds: 300), () {
        Navigator.of(context).pop();
      });
      setState(() {});
    }
  }

  void showDateSelectionDialog() async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    DateTime firstDate = DateTime.now().subtract(Duration(days: 365 * 100));
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: pickedDate,
        firstDate: firstDate,
        lastDate: DateTime.now());

    if (date != null) {
      pickedDate = date;
      var formatter = new DateFormat('dd-MM-yyyy');
      String formatted = formatter.format(pickedDate);
      entryDateController = TextEditingController(text: formatted);
      setState(() {});
    }
  }

  void showTimeSelectionDialog() async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: pickedTime,
        builder: (BuildContext? context, Widget? child) {
          return MediaQuery(
              child: child!,
              data:
                  MediaQuery.of(context!).copyWith(alwaysUse24HourFormat: true));
        });

    if (time != null) {
      pickedTime = time;
      final now = new DateTime.now();
      var dateOfTime = DateTime(
          now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);

      var formatter = new DateFormat('HH:mm');
      String formatted = formatter.format(dateOfTime);
      entryTimeController = TextEditingController(text: formatted);

      setState(() {});
    }
  }
}
