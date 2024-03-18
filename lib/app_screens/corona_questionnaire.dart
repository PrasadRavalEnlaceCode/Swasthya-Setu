import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_questionnaire.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';

import '../utils/color.dart';
import '../utils/progress_dialog.dart';

TextEditingController entryDateController = new TextEditingController();
TextEditingController entryTimeController = new TextEditingController();

var pickedDate = DateTime.now();
var pickedTime = TimeOfDay.now();

class CoronaQuestionnaireScreen extends StatefulWidget {
  String patientIDP, language;

  List<ModelCoronaQuestionnaire> listEngQuestions = [];
  List<ModelCoronaQuestionnaire> listGujQuestions = [];

  List<ModelCoronaQuestionnaire> listQuestions = [];

  CoronaQuestionnaireScreen(this.patientIDP, this.language);

  @override
  State<StatefulWidget> createState() {
    return CoronaQuestionnaireScreenState();
  }
}

class CoronaQuestionnaireScreenState extends State<CoronaQuestionnaireScreen> {
  @override
  void initState() {
    super.initState();

    var pickedDate = DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(pickedDate);
    entryDateController = TextEditingController(text: formatted);

    final now = new DateTime.now();
    var dateOfTime =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);

    pickedTime = TimeOfDay.now();

    var formatterTime = new DateFormat('HH:mm');
    String formattedTime = formatterTime.format(dateOfTime);
    entryTimeController = TextEditingController(text: formattedTime);

    widget.listEngQuestions = [];
    widget.listGujQuestions = [];

    widget.listEngQuestions.add(
        ModelCoronaQuestionnaire("1", "Are you suffering from fever?", "1"));
    widget.listEngQuestions.add(ModelCoronaQuestionnaire(
        "2", "Are you suffering from breathlessness?", ""));
    widget.listEngQuestions.add(
        ModelCoronaQuestionnaire("3", "Are you suffering from Cough?", ""));
    widget.listEngQuestions.add(
        ModelCoronaQuestionnaire("4", "Are you suffering from headache?", ""));
    widget.listEngQuestions.add(
        ModelCoronaQuestionnaire("5", "Are you suffering from diarrhoea?", ""));
    widget.listEngQuestions.add(
        ModelCoronaQuestionnaire("6", "Are you suffering from bodyache?", ""));

    widget.listGujQuestions
        .add(ModelCoronaQuestionnaire("1", "તાવ આવે છે?", "1"));
    widget.listGujQuestions
        .add(ModelCoronaQuestionnaire("2", "શ્વાસની તકલીફ થાય છે?", ""));
    widget.listGujQuestions
        .add(ModelCoronaQuestionnaire("3", "ઉધરસ આવે છે?", ""));
    widget.listGujQuestions
        .add(ModelCoronaQuestionnaire("4", "માથાનો દુખાવો છે?", ""));
    widget.listGujQuestions
        .add(ModelCoronaQuestionnaire("5", "ઝાડાની તકલીફ છે?", ""));
    widget.listGujQuestions
        .add(ModelCoronaQuestionnaire("6", "શરીર દુખે છે?", ""));

    if (widget.language == "eng") {
      widget.listQuestions = widget.listEngQuestions;
    } else if (widget.language == "guj") {
      widget.listQuestions = widget.listGujQuestions;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Health Questionnaire",
            style: TextStyle(fontSize: SizeConfig.blockSizeVertical !* 2.5)),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(color: Colorsblack), toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(color: Colorsblack, fontFamily: "Ubuntu")).bodyMedium, titleTextStyle: TextTheme(
            titleMedium: TextStyle(color: Colorsblack, fontFamily: "Ubuntu")).titleLarge,
      ),
      body: Builder(builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                          child: Container(
                            child: IgnorePointer(
                              child: TextField(
                                controller: entryDateController,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.1),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.1),
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.1),
                                  labelText: "Entry Date",
                                  hintText: "",
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
                          child: Container(
                            child: IgnorePointer(
                              child: TextField(
                                controller: entryTimeController,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.1),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.1),
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.1),
                                  labelText: "Entry Time",
                                  hintText: "",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: widget.listQuestions.length,
                      itemBuilder: (context, index) {
                        return index != 0
                            ? QuestionCard(widget.listQuestions[index], index,
                                widget.language)
                            : Container();
                      }),
                ],
              )),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 10.0,
                  ),
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal !* 12,
                    height: SizeConfig.blockSizeHorizontal !* 12,
                    child: RawMaterialButton(
                      onPressed: () {
                        validateAndSubmitQuestionnaire(context);
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
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
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

  void validateAndSubmitQuestionnaire(BuildContext context) async {
    for (var i = 0; i < widget.listQuestions.length; i++) {
      if (widget.listQuestions[i].answerGiven == "null" ||
          widget.listQuestions[i].answerGiven == "") {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please answer all the questions"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }

    var jArrayQuestions = "[";
    for (var i = 0; i < widget.listQuestions.length; i++) {
      //if (listInvestigationMaster[i].isChecked) {
      jArrayQuestions =
          "$jArrayQuestions{\"QuestionIDP\":\"${i + 1}\",\"Answer\":\"${widget.listQuestions[i].answerGiven}\"},";
      //}
    }
    jArrayQuestions = jArrayQuestions + "]";
    jArrayQuestions = jArrayQuestions.replaceAll(",]", "]");
    debugPrint("Final Array");
    debugPrint(jArrayQuestions);

    String loginUrl = "${baseURL}patientQuestionarySubmit.php";
    ProgressDialog pr;
    pr = ProgressDialog(context);
    pr.show();
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP +
        "\"" +
        "," +
        "\"QuestionDataObject" +
        "\"" +
        ":" +
        jArrayQuestions +
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
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(milliseconds: 3000), () {
        Navigator.of(context).pop();
      });
    }
  }
}

class QuestionCard extends StatefulWidget {
  ModelCoronaQuestionnaire modelQuestion;
  int index;
  String language;

  QuestionCard(this.modelQuestion, this.index, this.language);

  @override
  State<StatefulWidget> createState() {
    return QuestionCardState();
  }
}

class QuestionCardState extends State<QuestionCard> {
  int _radioValue = -1;
  String engYes = "Yes";
  String engNo = "No";
  String gujYes = "હા";
  String gujNo = "ના";

  void _handleRadioValueChange(value) {
    setState(() {
      _radioValue = value;
      widget.modelQuestion.answerGiven = value.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "${widget.index}) ${widget.modelQuestion.question}",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: SizeConfig.blockSizeVertical !* 2.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
              value: 0,
              groupValue: _radioValue,
              onChanged: _handleRadioValueChange,
            ),
            InkWell(
              onTap: () {
                _handleRadioValueChange(0);
              },
              child: Text(widget.language == "eng" ? engNo : gujNo),
            ),
            SizedBox(
              width: 5.0,
            ),
            Radio(
              value: 1,
              groupValue: _radioValue,
              onChanged: _handleRadioValueChange,
            ),
            InkWell(
              onTap: () {
                _handleRadioValueChange(1);
              },
              child: Text(widget.language == "eng" ? engYes : gujYes),
            ),
          ],
        ),
      ],
    );
  }
}
