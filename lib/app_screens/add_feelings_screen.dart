import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';

import '../utils/color.dart';
import '../utils/progress_dialog.dart';

int selectedFeeling = 0;
TextEditingController descriptionController = TextEditingController();

TextEditingController entryDateController = new TextEditingController();
TextEditingController entryTimeController = new TextEditingController();

var pickedDate = DateTime.now();
var pickedTime = TimeOfDay.now();

class AddFeelingsScreen extends StatefulWidget {
  String patientIDP;
  var veryHappyColor = 0xFFE7993B;
  var happyColor = 0xFFCE5717;
  var neutralColor = 0xFF51BDEF;
  var worriedColor = 0xFF030AFF;
  var sadColor = 0xFF5D56F7;
  var angryColor = 0xFFFF0000;
  var selectedColor;
  Widget? bigCircle;

  AddFeelingsScreen(this.patientIDP);

  @override
  State<StatefulWidget> createState() {
    return AddFeelingsScreenState();
  }
}

class AddFeelingsScreenState extends State<AddFeelingsScreen> {
  double opacityLevel = 0.5;
  double opacityLevelVeryHappy = 1;
  double opacityLevelHappy = 0;
  double opacityLevelNeutral = 0;
  double opacityLevelWorried = 0;
  double opacityLevelSad = 0;
  double opacityLevelAngry = 0;

  changeOpacityLevel() {
    setState(() {
      opacityLevel = 0.35;
      widget.bigCircle = Opacity(
        opacity: opacityLevel,
        child: Container(
          width: 300.0,
          height: 300.0,
          decoration: BoxDecoration(
            color: Color(widget.selectedColor),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        opacityLevel = 0.5;
        widget.bigCircle = Opacity(
          opacity: opacityLevel,
          child: Container(
            width: 300.0,
            height: 300.0,
            decoration: BoxDecoration(
              color: Color(widget.selectedColor),
              shape: BoxShape.circle,
            ),
          ),
        );
      });
    });
  }

  @override
  void initState() {
    super.initState();
    pickedDate = DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(pickedDate);
    entryDateController = TextEditingController(text: formatted);
    descriptionController = TextEditingController();

    final now = new DateTime.now();
    var dateOfTime =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);

    pickedTime = TimeOfDay.now();

    var formatterTime = new DateFormat('HH:mm');
    String formattedTime = formatterTime.format(dateOfTime);
    debugPrint("formatted time");
    debugPrint(formattedTime);
    entryTimeController = TextEditingController(text: formattedTime);
    widget.selectedColor = widget.veryHappyColor;
    selectedFeeling = 0;
    setState(() {});
  }

  @override
  void dispose() {
    widget.patientIDP = "";
    widget.veryHappyColor = 0xFFE7993B;
    widget.happyColor = 0xFFCE5717;
    widget.neutralColor = 0xFF51BDEF;
    widget.worriedColor = 0xFF030AFF;
    widget.sadColor = 0xFF5D56F7;
    widget.angryColor = 0xFFFF0000;
    widget.selectedColor = widget.veryHappyColor;
    selectedFeeling = 0;
    super.dispose();
  }

  String getFeelingName() {
    if (selectedFeeling == 0)
      return "Very Happy";
    else if (selectedFeeling == 1)
      return "Happy";
    else if (selectedFeeling == 2)
      return "Neutral";
    else if (selectedFeeling == 3)
      return "Worried";
    else if (selectedFeeling == 4)
      return "Sad";
    else if (selectedFeeling == 5) return "Angry";
    return "";
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    widget.bigCircle = Opacity(
      opacity: opacityLevel,
      child: Container(
        width: 300.0,
        height: 300.0,
        decoration: BoxDecoration(
          color: Color(widget.selectedColor),
          shape: BoxShape.circle,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Feelings"),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    children: <Widget>[
                      Center(
                        child: Row(
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
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical !* 5,
                      ),
                      Center(
                        child: Stack(
                          children: <Widget>[
                            (widget.bigCircle)!,
                            Positioned(
                              child: CircleButton(
                                onTap: () {
                                  setState(() {
                                    selectedFeeling = 0;
                                    widget.selectedColor =
                                        widget.veryHappyColor;
                                    opacityLevelVeryHappy = 1.0;
                                    opacityLevelHappy = 0;
                                    opacityLevelNeutral = 0;
                                    opacityLevelWorried = 0;
                                    opacityLevelSad = 0;
                                    opacityLevelAngry = 0;
                                    changeOpacityLevel();
                                  });
                                },
                                imgPath: selectedFeeling == 0
                                    ? "images/ic_emoji_very_happy_filled.png"
                                    : "images/ic_emoji_very_happy.png",
                                selectedCode: 0,
                              ),
                              top: 10.0,
                              left: 130.0,
                            ),
                            Positioned(
                              child: AnimatedOpacity(
                                opacity: opacityLevelVeryHappy,
                                duration: Duration(milliseconds: 300),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              top: 90.0,
                              left: 130.0 + 20,
                            ),
                            Positioned(
                              child: CircleButton(
                                onTap: () {
                                  setState(() {
                                    selectedFeeling = 1;
                                    widget.selectedColor = widget.happyColor;
                                    opacityLevelVeryHappy = 0;
                                    opacityLevelHappy = 1.0;
                                    opacityLevelNeutral = 0;
                                    opacityLevelWorried = 0;
                                    opacityLevelSad = 0;
                                    opacityLevelAngry = 0;
                                    changeOpacityLevel();
                                  });
                                },
                                imgPath: selectedFeeling == 1
                                    ? "images/ic_emoji_happy_filled.png"
                                    : "images/ic_emoji_happy.png",
                                selectedCode: 1,
                              ),
                              top: 70.0,
                              right: 25.0,
                            ),
                            Positioned(
                              child: AnimatedOpacity(
                                opacity: opacityLevelHappy,
                                duration: Duration(milliseconds: 300),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              top: 70.0 + 45,
                              right: 100.0,
                            ),
                            Positioned(
                              child: CircleButton(
                                onTap: () {
                                  setState(() {
                                    selectedFeeling = 2;
                                    widget.selectedColor = widget.neutralColor;
                                    opacityLevelVeryHappy = 0;
                                    opacityLevelHappy = 0;
                                    opacityLevelNeutral = 1.0;
                                    opacityLevelWorried = 0;
                                    opacityLevelSad = 0;
                                    opacityLevelAngry = 0;
                                    changeOpacityLevel();
                                  });
                                },
                                imgPath: selectedFeeling == 2
                                    ? "images/ic_emoji_neutral_filled.png"
                                    : "images/ic_emoji_neutral.png",
                                selectedCode: 2,
                              ),
                              bottom: 70.0,
                              right: 25.0,
                            ),
                            Positioned(
                              child: AnimatedOpacity(
                                opacity: opacityLevelNeutral,
                                duration: Duration(milliseconds: 300),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              bottom: 70.0 + 50,
                              right: 100.0,
                            ),
                            Positioned(
                              child: CircleButton(
                                onTap: () {
                                  setState(() {
                                    selectedFeeling = 3;
                                    widget.selectedColor = widget.worriedColor;
                                    opacityLevelVeryHappy = 0;
                                    opacityLevelHappy = 0;
                                    opacityLevelNeutral = 0;
                                    opacityLevelWorried = 1.0;
                                    opacityLevelSad = 0;
                                    opacityLevelAngry = 0;
                                    changeOpacityLevel();
                                  });
                                },
                                imgPath: selectedFeeling == 3
                                    ? "images/ic_emoji_worried_filled.png"
                                    : "images/ic_emoji_worried.png",
                                selectedCode: 3,
                              ),
                              bottom: 10.0,
                              left: 130.0,
                            ),
                            Positioned(
                              child: AnimatedOpacity(
                                opacity: opacityLevelWorried,
                                duration: Duration(milliseconds: 300),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              bottom: 90.0,
                              left: 150.0,
                            ),
                            Positioned(
                              child: CircleButton(
                                onTap: () {
                                  setState(() {
                                    selectedFeeling = 4;
                                    widget.selectedColor = widget.sadColor;
                                    opacityLevelVeryHappy = 0;
                                    opacityLevelHappy = 0;
                                    opacityLevelNeutral = 0;
                                    opacityLevelWorried = 0;
                                    opacityLevelSad = 1.0;
                                    opacityLevelAngry = 0;
                                    changeOpacityLevel();
                                  });
                                },
                                imgPath: selectedFeeling == 4
                                    ? "images/ic_emoji_sad_filled.png"
                                    : "images/ic_emoji_sad.png",
                                selectedCode: 4,
                              ),
                              bottom: 70.0,
                              left: 25.0,
                            ),
                            Positioned(
                              child: AnimatedOpacity(
                                opacity: opacityLevelSad,
                                duration: Duration(milliseconds: 300),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              bottom: 115.0,
                              left: 100.0,
                            ),
                            Positioned(
                              child: CircleButton(
                                onTap: () {
                                  setState(() {
                                    selectedFeeling = 5;
                                    widget.selectedColor = widget.angryColor;
                                    opacityLevelVeryHappy = 0;
                                    opacityLevelHappy = 0;
                                    opacityLevelNeutral = 0;
                                    opacityLevelWorried = 0;
                                    opacityLevelSad = 0;
                                    opacityLevelAngry = 1.0;
                                    changeOpacityLevel();
                                  });
                                },
                                imgPath: selectedFeeling == 5
                                    ? "images/ic_emoji_angry_filled.png"
                                    : "images/ic_emoji_angry.png",
                                selectedCode: 5,
                              ),
                              top: 70.0,
                              left: 25.0,
                            ),
                            Positioned(
                              child: AnimatedOpacity(
                                opacity: opacityLevelAngry,
                                duration: Duration(milliseconds: 300),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              top: 115.0,
                              left: 100.0,
                            ),
                            /*Positioned(
                  child: CircleButton(
                      onTap: () {
                        setState(() {
                          selectedFeeling = 3;
                          widget.selectedColor = widget.worriedColor;
                        });
                      },
                      imgPath: selectedFeeling == 3
                          ? "images/ic_emoji_worried_filled.png"
                          : "images/ic_emoji_worried.png"),
                  top: 70.0,
                  right: 25.0,
                ),*/
                            /*Positioned(
                  child: CircleButton(
                      onTap: () {
                        setState(() {
                          selectedFeeling = 4;
                          widget.selectedColor = widget.sadColor;
                        });
                      },
                      imgPath: selectedFeeling == 4
                          ? "images/ic_emoji_sad_filled.png"
                          : "images/ic_emoji_sad.png"),
                  bottom: 70.0,
                  right: 25.0,
                ),*/
                            /*Positioned(
                  child: CircleButton(
                      onTap: () {
                        setState(() {
                          selectedFeeling = 5;
                          widget.selectedColor = widget.angryColor;
                        });
                      },
                      imgPath: selectedFeeling == 5
                          ? "images/ic_emoji_angry_filled.png"
                          : "images/ic_emoji_angry.png"),
                  top: 240.0,
                  left: 130.0,
                ),*/
                            /*Positioned(
                  child: CircleButton(
                      onTap: () => print("Cool 5"), iconData: Icons.satellite),
                  top: 120.0,
                  left: 130.0,
                ),*/
                          ],
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical !* 3,
                      ),
                      Center(
                          child: Text(
                        getFeelingName(),
                        style: TextStyle(
                            color: Color(widget.selectedColor),
                            fontSize: SizeConfig.blockSizeHorizontal !* 7,
                            fontWeight: FontWeight.w500),
                      )),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical !* 2,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockSizeHorizontal !* 3),
                        child: TextField(
                          maxLength: 100,
                          controller: descriptionController,
                          style: TextStyle(color: Colors.green),
                          decoration: InputDecoration(
                            counterText: "",
                            hintStyle: TextStyle(color: Colors.black),
                            labelStyle: TextStyle(color: Colors.black),
                            labelText: "Description",
                            hintText: "",
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 2.0,
                    ),
                    child: RawMaterialButton(
                      onPressed: () {
                        submitFeelings(context);
                      },
                      elevation: 2.0,
                      fillColor: Color(0xFF06A759),
                      child: Image(
                        width: SizeConfig.blockSizeHorizontal !* 5.5,
                        height: SizeConfig.blockSizeHorizontal !* 5.5,
                        //height: 80,
                        image:
                            AssetImage("images/ic_right_arrow_triangular.png"),
                      ),
                      shape: CircleBorder(),
                    ),
                    /*),*/
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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

  void submitFeelings(BuildContext context) async {
    String loginUrl = "${baseURL}patientFeelingsSubmit.php";
    ProgressDialog pr;
    pr = ProgressDialog(context);
    pr.show();
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = /*[*/ "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP +
        "\"" +
        "," +
        "\"FeelingsValue\"" +
        ":" +
        "\"${getFeelingName()}\"" +
        "," +
        "\"FeelingsValueDescp\"" +
        ":" +
        "\"${descriptionController.text}\"" +
        "," +
        "\"FeelingsEntryDate\"" +
        ":" +
        "\"${entryDateController.text}\"" +
        "," +
        "\"FeelingsEntryTime\"" +
        ":" +
        "\"${entryTimeController.text}\"" +
        "}";

    debugPrint(jsonStr);

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
    //var resBody = json.decode(response.body);
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr.hide();
    if (model.status == "OK") {
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    }
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

class CircleButton extends StatelessWidget {
  final GestureTapCallback? onTap;
  final String? imgPath;
  final int? selectedCode;

  const CircleButton({Key? key, this.onTap, this.imgPath, this.selectedCode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = 50.0;

    return InkResponse(
      onTap: onTap,
      child: Container(
          width: selectedCode == selectedFeeling ? 65 : 50,
          height: selectedCode == selectedFeeling ? 65 : 50,
          decoration: BoxDecoration(
            color: selectedCode == selectedFeeling
                ? Color(0x66FFFFFF)
                : Color(0xAEFFFFFF),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(selectedCode == selectedFeeling ? 8 : 0),
            child: Image(
              image: AssetImage(imgPath!),
            ),
          )
          /*Icon(
          iconData,
          color: Colors.black,
        ),*/
          ),
    );
  }
}
