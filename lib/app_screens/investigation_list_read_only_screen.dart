import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_investigation_master_list.dart';
import 'package:swasthyasetu/podo/model_investigation_master_list_with_date_time.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';

import '../utils/color.dart';
import '../utils/progress_dialog.dart';

List<ModelInvestigationMaster> listInvestigationMaster = [];
ModelInvestigationMasterWithDateTime? modelInvestigationMasterWithDateTime;
TextEditingController entryDateController = new TextEditingController();
TextEditingController entryTimeController = new TextEditingController();

var pickedDate = DateTime.now();
var pickedTime = TimeOfDay.now();

class InvestigationListReadOnlyScreen extends StatefulWidget {
  String? patientIDP;

  String? emptyTextInvestigation1 =
      "You can enter your Investigation reports values by selecting Investigation from the list.";
  String? emptyTextInvestigation2 = "Share the details to your doctor any time.";

  String? emptyMessage = "";

  Widget? emptyMessageWidget;

  @override
  State<StatefulWidget> createState() {
    return InvestigationListReadOnlyScreenState();
  }

  InvestigationListReadOnlyScreen(
      String patientIDP,
      ModelInvestigationMasterWithDateTime
          modelInvestigationMasterWithDateTimeLocal) {
    this.patientIDP = patientIDP;
    modelInvestigationMasterWithDateTime =
        modelInvestigationMasterWithDateTimeLocal;
  }
}

class InvestigationListReadOnlyScreenState
    extends State<InvestigationListReadOnlyScreen> {
  bool apiCalled = false;

  @override
  void dispose() {
    entryDateController.clear();
    entryTimeController.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.emptyMessage =
        "${widget.emptyTextInvestigation1}\n\n${widget.emptyTextInvestigation2}";
    var pickedDate = DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(pickedDate);
    //entryDateController = TextEditingController(text: formatted);
    entryDateController =
        TextEditingController(text: modelInvestigationMasterWithDateTime!.date);
    entryTimeController =
        TextEditingController(text: modelInvestigationMasterWithDateTime!.time);

    widget.emptyMessageWidget = SizedBox(
      height: SizeConfig.blockSizeVertical !* 80,
      child: Container(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage("images/ic_idea_new.png"),
              width: 100,
              height: 100,
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              "${widget.emptyMessage}",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );

    setState(() {});
    // 1 comment this
    getInvestigationList();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Investigation List"),
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
                /*MaterialButton(
                  child: Text(
                    "Add Investigation",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.blockSizeVertical * 2.3),
                  ),
                  minWidth: double.maxFinite,
                  color: Color(0xFF06A759),
                  onPressed: () async {
                    // 2 uncomment commented and vice versa
                    var results = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => InvestigationMasterListScreen(
                                widget.patientIDP, listInvestigationMaster)));
                    */
                /*.then((value) {
                      getInvestigationList();
                    });*/
                /*
                    if (results != null && results.containsKey('selection')) {
                      setState(() {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        listInvestigationMaster = results['selection'];
                      });
                    }
                  },
                ),*/
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: MaterialButton(
                          onPressed: () {
                            //showDateSelectionDialog();
                          },
                          child: Container(
                            child: IgnorePointer(
                              child: TextField(
                                controller: entryDateController,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.1),
                                decoration: InputDecoration(
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
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: MaterialButton(
                          onPressed: () {
                            //showTimeSelectionDialog();
                          },
                          child: Container(
                            child: IgnorePointer(
                              child: TextField(
                                controller: entryTimeController,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.1),
                                decoration: InputDecoration(
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
                    ),
                  ],
                ),
                listInvestigationMaster.length > 0
                    ? Expanded(
                        child: GridView.builder(
                          itemCount: listInvestigationMaster.length,
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 2.5, crossAxisCount: 2),
                          itemBuilder: (context, index) {
                            return DynamicTextField(
                                listInvestigationMaster[index]);
                          },
                        ),
                      ): widget.emptyMessageWidget!
                /*(apiCalled
                        ? Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image(
                                    image: AssetImage(
                                        "images/ic_no_result_found.png"),
                                    width: 200,
                                    height: 200,
                                  ),
                                  SizedBox(
                                    height: 12.0,
                                  ),
                                  Text(
                                    "No Investigations found.",
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          ))*/
                ,
                listInvestigationMaster.length > 0
                    ? Container(
                        height: 80.0,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: 25.0,
                              top: 10.0,
                            ),
                            child: Container(
                              width: SizeConfig.blockSizeHorizontal !* 12,
                              height: SizeConfig.blockSizeHorizontal !* 12,
                              child: RawMaterialButton(
                                onPressed: () {
                                  validateAndSubmitInvestigations(context);
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
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            );
          },
        )
        /*body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ListView.builder(
            itemCount: listInvestigationMaster.length,
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return MultiCard(listInvestigationMaster[index]);
            },
          ),
          */
      /*Expanded(
            child: */
      /*Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 25.0,
                    top: 10.0,
                  ),
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal * 12,
                    height: SizeConfig.blockSizeHorizontal * 12,
                    child: RawMaterialButton(
                      onPressed: () {
                        //submitImageForUpdate(context, widget.image);
                      },
                      elevation: 2.0,
                      fillColor: Color(0xFF06A759),
                      child: Image(
                        width: SizeConfig.blockSizeHorizontal * 5.5,
                        height: SizeConfig.blockSizeHorizontal * 5.5,
                        //height: 80,
                        image:
                            AssetImage("images/ic_right_arrow_triangular.png"),
                      ),
                      shape: CircleBorder(),
                    ),
                  ),
                ) */ /*),*/ /*
          ),
        ],
      ),*/
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

  void getInvestigationList() async {
    String loginUrl = "${baseURL}patientInvestTimeWise.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
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
        widget.patientIDP! +
        "\"" +
        "," +
        "\"" +
        "FromDate" +
        "\"" +
        ":" +
        "\"" +
        modelInvestigationMasterWithDateTime!.date! +
        "\"" +
        "," +
        "\"" +
        "TimeId" +
        "\"" +
        ":" +
        "\"" +
        modelInvestigationMasterWithDateTime!.entryTimeId! +
        "\"" +
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
    pr!.hide();
    apiCalled = true;
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      listInvestigationMaster = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listInvestigationMaster.add(ModelInvestigationMaster(
          jo['PreInvestTypeIDF'].toString(),
          jo['GroupType'],
          jo['GroupName'],
          jo['InvestigationType'],
          jo['InvestValue'],
          false,
        ));
      }

      /*listInvestigationMaster
          .add(ModelInvestigationMaster("1", "2", "3", "Type 1", "5", false));

      listInvestigationMaster
          .add(ModelInvestigationMaster("1", "2", "3", "Type 2", "5", false));

      listInvestigationMaster
          .add(ModelInvestigationMaster("1", "2", "3", "Type 3", "5", false));

      listInvestigationMaster
          .add(ModelInvestigationMaster("1", "2", "3", "Type 4", "5", false));

      listInvestigationMaster
          .add(ModelInvestigationMaster("1", "2", "3", "Type 5", "5", false));*/
      setState(() {});
    }
  }

  void validateAndSubmitInvestigations(BuildContext context) async {
    if (entryDateController.text == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Entry Date"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    if (entryTimeController.text == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Entry Time"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    for (var i = 0; i < listInvestigationMaster.length; i++) {
      if (listInvestigationMaster[i].rangeValue == null ||
          listInvestigationMaster[i].rangeValue == "null" ||
          listInvestigationMaster[i].rangeValue == "") {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please fill all the investigation details"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }
    var jArrayInvestigationMaster = "[";
    for (var i = 0; i < listInvestigationMaster.length; i++) {
      //if (listInvestigationMaster[i].isChecked) {
      jArrayInvestigationMaster =
          "$jArrayInvestigationMaster{\"PreInvestTypeIDP\":\"${listInvestigationMaster[i].preInvestTypeIDP}\",\"InvestigationValue\":\"${listInvestigationMaster[i].rangeValue}\"},";
      //}
    }
    jArrayInvestigationMaster = jArrayInvestigationMaster + "]";
    jArrayInvestigationMaster = jArrayInvestigationMaster.replaceAll(",]", "]");
    debugPrint("Final Array");
    debugPrint(jArrayInvestigationMaster);

    String loginUrl = "${baseURL}patientInvestSave.php";
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
        widget.patientIDP! +
        "\"" +
        "," +
        "\"" +
        "EntryDate" +
        "\"" +
        ":" +
        "\"" +
        entryDateController.text +
        "\"" +
        "," +
        "\"" +
        "EntryTime" +
        "\"" +
        ":" +
        "\"" +
        entryTimeController.text +
        "\"" +
        "," +
        "\"InvestgationData" +
        "\"" +
        ":" +
        jArrayInvestigationMaster +
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
      /*var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      listInvestigationMaster = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listInvestigationMaster.add(ModelInvestigationMaster(
          jo['PreInvestTypeIDP'].toString(),
          jo['GroupType'],
          jo['GroupName'],
          jo['InvestigationType'],
          jo['RangeValue'],
          false,
        ));
      }*/
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text("Investigation successfully Added"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.of(context).pop();
    }
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

class DynamicTextField extends StatefulWidget {
  ModelInvestigationMaster modelInvestigationMaster;

  DynamicTextField(this.modelInvestigationMaster);

  @override
  DynamicTextFieldState createState() => new DynamicTextFieldState();
}

class DynamicTextFieldState extends State<DynamicTextField> {
  var mycolor = Colors.white;
  var investigationController = TextEditingController();

  @override
  void dispose() {
    investigationController.clear();
    listInvestigationMaster = [];
    super.dispose();
  }

  @override
  void initState() {
    if (widget.modelInvestigationMaster.rangeValue != null &&
        widget.modelInvestigationMaster.rangeValue != "null" &&
        widget.modelInvestigationMaster.rangeValue != "")
      investigationController = TextEditingController(
          text: widget.modelInvestigationMaster.rangeValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return /*Card(
      color: mycolor,
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[*/
        Container(
      height: SizeConfig.blockSizeVertical !* 8,
      padding: EdgeInsets.only(
        left: SizeConfig.blockSizeVertical !* 2,
        right: SizeConfig.blockSizeVertical !* 2,
      ),
      child: /*IgnorePointer(
        child:*/
          TextField(
        //controller: mobileNoController,
        style: TextStyle(
            color: Colors.green, fontSize: SizeConfig.blockSizeVertical !* 2.1),
        controller: investigationController,
        decoration: InputDecoration(
          hintStyle: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.blockSizeVertical !* 2.1),
          labelStyle: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.blockSizeVertical !* 2.1),
          labelText: widget.modelInvestigationMaster.investigationType,
          hintText: "",
        ),
        onChanged: (text) {
          textChanged(text);
        },
      ),
      /*),*/
    );
    /*ListTile(
            selected: widget.modelInvestigationMaster.isChecked,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.modelInvestigationMaster.groupName
                          .replaceAll("\n", "")
                          .replaceAll("\r", "") +
                      " -> " +
                      widget.modelInvestigationMaster.investigationType,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(
                  height: 0,
                ),
                Text(
                  widget.modelInvestigationMaster.groupType,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
            */ /*subtitle: new Text(
              widget.modelInvestigationMaster.groupType,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15.0,
              ),
            ),*/ /*
            trailing: Checkbox(
              onChanged: (isChecked) {
                toggleSelection();
              },
              value: widget.modelInvestigationMaster.isChecked,
            ),
            onTap: toggleSelection // what should I put here,
            )*/
    /*]),
    );*/
  }

  void toggleSelection() {
    int index =
        listInvestigationMaster.indexOf(widget.modelInvestigationMaster);
    debugPrint("Index - " + index.toString());
    debugPrint("Before");
    debugPrint(listInvestigationMaster[index].isChecked.toString());
    setState(() {
      if (widget.modelInvestigationMaster.isChecked) {
        mycolor = Colors.white;
        widget.modelInvestigationMaster.isChecked = false;
        listInvestigationMaster.remove(widget.modelInvestigationMaster);
        listInvestigationMaster.insert(index, widget.modelInvestigationMaster);
        debugPrint("Index - " + index.toString());
        debugPrint("After");
        debugPrint(listInvestigationMaster[index].isChecked.toString());
      } else {
        mycolor = Colors.grey;
        widget.modelInvestigationMaster.isChecked = true;
        listInvestigationMaster.remove(widget.modelInvestigationMaster);
        listInvestigationMaster.insert(index, widget.modelInvestigationMaster);
        debugPrint("Index - " + index.toString());
        debugPrint("After");
        debugPrint(listInvestigationMaster[index].isChecked.toString());
      }
    });
  }

  void textChanged(String text) {
    int index =
        listInvestigationMaster.indexOf(widget.modelInvestigationMaster);
    listInvestigationMaster.remove(widget.modelInvestigationMaster);
    widget.modelInvestigationMaster.rangeValue = text;
    listInvestigationMaster.insert(index, widget.modelInvestigationMaster);
    /*debugPrint(widget.modelInvestigationMaster.investigationType);
    debugPrint(widget.modelInvestigationMaster.rangeValue);*/
    setState(() {});
  }
}
