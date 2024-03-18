import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swasthyasetu/api/api_helper.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_investigation_master_list.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:swasthyasetu/widgets/extensions.dart';

import '../utils/color.dart';

List<ModelInvestigationMaster> listInvestigationsList = [];
List<String> listGroupNames = [];
String selectedGroupName = "All";

TextEditingController entryDateController = new TextEditingController();
TextEditingController entryTimeController = new TextEditingController();

var pickedDate = DateTime.now();
var pickedTime = TimeOfDay.now();

String preInvestTypeIDPGlobal = "";

class InvestigationListScreen extends StatefulWidget {
  String? patientIDP;

  String? emptyTextInvestigation1 =
      "You can enter your Investigation reports values by selecting Investigation from the list.";
  String? emptyTextInvestigation2 = "Share the details to your doctor any time.";

  String? emptyMessage = "";

  Widget? emptyMessageWidget;

  @override
  State<StatefulWidget> createState() {
    return InvestigationListScreenState();
  }

  InvestigationListScreen(String patientIDP,
      // List<ModelInvestigationMaster> listInvestigationMasterLocal,
      {preInvestTypeIDP}) {
    this.patientIDP = patientIDP;
    // listInvestigationsList = listInvestigationMasterLocal;
    preInvestTypeIDPGlobal = preInvestTypeIDP;
  }
}

class InvestigationListScreenState extends State<InvestigationListScreen> {
  bool apiCalled = false;
  TextEditingController? searchController;
  var focusNode = new FocusNode();
  ApiHelper apiHelper = ApiHelper();

  Icon icon = Icon(
    Icons.search,
    color: Colors.black,
  );
  Widget titleWidget = Text("Investigation List");

  @override
  void dispose() {
    entryDateController.clear();
    entryTimeController.clear();
    listInvestigationsList = [];
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: "");
    listGroupNames = [];
    listGroupNames.add("All");
    selectedGroupName = "All";
    widget.emptyMessage =
        "${widget.emptyTextInvestigation1}\n\n${widget.emptyTextInvestigation2}";
    var pickedDate = DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(pickedDate);
    entryDateController = TextEditingController(text: formatted);

    final now = new DateTime.now();
    var dateOfTime =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);

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

    pickedTime = TimeOfDay.now();
    var formatterTime = new DateFormat('HH:mm');
    String formattedTime = formatterTime.format(dateOfTime);
    entryTimeController = TextEditingController(text: formattedTime);
    setState(() {});
    getInvestigationList();
    // 1 comment this
    //getInvestigationList();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: titleWidget,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colorsblack),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                setState(() {
                  if (icon.icon == Icons.search) {
                    searchController = TextEditingController(text: "");
                    focusNode.requestFocus();
                    this.icon = Icon(
                      Icons.cancel,
                      color: Colors.red,
                    );
                    this.titleWidget = TextField(
                      controller: searchController,
                      focusNode: focusNode,
                      cursorColor: Colors.white,
                      onChanged: (text) {
                        searchAndFilterInvestigationList();
                        /*listInvestigationsList = listInvestigationsList
                            .where((dropDownObj) =>
                            dropDownObj.investigationType
                                .toLowerCase()
                                .contains(
                                text.toLowerCase()))
                            .toList();*/
                      },
                      style: TextStyle(
                        color: Colorsblack,
                        fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search Investigation",
                      ),
                    );
                  } else {
                    searchController = TextEditingController();
                    /*for (int i = 0; i < listInvestigationsList.length; i++) {
                      ModelInvestigationMaster model =
                          listInvestigationsList[i];
                      model.show = true;
                    }*/
                    searchAndFilterInvestigationList();
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    this.icon = Icon(
                      Icons.search,
                      color: Colors.black,
                    );
                    this.titleWidget = Text("Investigation List");
                  }
                });
              },
              icon: icon,
            ),
            IconButton(
              onPressed: () {
                showGroupNameSelectionDialog();
              },
              icon: Image(
                image: AssetImage('images/ic_filter.png'),
                color: Colors.black,
                width: SizeConfig.blockSizeHorizontal !* 5,
              ),
            )
          ], toolbarTextStyle: TextTheme(
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
                            showTimeSelectionDialog();
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
                Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Investigation Group - ",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: SizeConfig.blockSizeHorizontal !* 3.5,
                        ),
                      ),
                      Text(
                        selectedGroupName,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.5,
                        ),
                      ),
                    ],
                  ),
                ),
                listInvestigationsList.length > 0
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: listInvestigationsList.length,
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return MultiCard(
                                listInvestigationsList[index], index);
                          },
                        ),
                        /*child: GridView.builder(
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
                        ),*/
                      )
                    : Expanded(
                        child: widget.emptyMessageWidget!,
                      )
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
                listInvestigationsList.length > 0
                    ? Container(
                        height: 80.0,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: 25.0,
                              top: 10.0,
                            ),
                            child:
                                /*Container(
                              width: SizeConfig.blockSizeHorizontal * 12,
                              height: SizeConfig.blockSizeHorizontal * 12,
                              child:*/
                                RawMaterialButton(
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
                            /*),*/
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
          */ /*Expanded(
            child: */ /*Align(
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
    String loginUrl = "${baseURL}patientInvestNotSelected.php";
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
      listInvestigationsList = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listInvestigationsList.add(ModelInvestigationMaster(
          jo['PreInvestTypeIDP'].toString(),
          jo['GroupType'],
          jo['GroupName'],
          jo['InvestigationType'],
          jo['RangeValue'],
          false,
          displayType: jo['DisplayType'],
          radioValue: '',
        ));
        if (!listGroupNames.contains(jo['GroupName']))
          listGroupNames.add(jo['GroupName']);
      }

      /*if (listInvestigationMasterSelected.length > 0) {
        debugPrint("Inside for loop");
        debugPrint(listInvestigationMasterSelected.toString());
        for (int i = 0; i < listInvestigationsList.length; i++) {
          var modelNotSelected = listInvestigationsList[i];
          for (int j = 0; j < listInvestigationMasterSelected.length; j++) {
            var modelSelected = listInvestigationMasterSelected[j];
            if (modelSelected.preInvestTypeIDP ==
                modelNotSelected.preInvestTypeIDP) {
              modelNotSelected.isChecked = true;
            }
          }
        }
      }*/
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

    for (var i = 0; i < listInvestigationsList.length; i++) {
      if (listInvestigationsList[i].isChecked == true &&
          (valueFromType(listInvestigationsList[i]) == "null" ||
              valueFromType(listInvestigationsList[i]) == null ||
              valueFromType(listInvestigationsList[i]) == "")) {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please fill all selected Investigation Values"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }
    var jArrayInvestigationMaster = "[";
    for (var i = 0; i < listInvestigationsList.length; i++) {
      if (listInvestigationsList[i].isChecked) {
        jArrayInvestigationMaster =
            "$jArrayInvestigationMaster{\"PreInvestTypeIDP\":\"${listInvestigationsList[i].preInvestTypeIDP}\",\"InvestigationValue\":\"${valueFromType(listInvestigationsList[i])}\"},";
      }
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
    if (model.status == "OK") {
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text("Investigation successfully Added"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(milliseconds: 300), () {
        Navigator.of(context).pop();
      });
    }
    pr.hide();
  }

  void showGroupNameSelectionDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  height: SizeConfig.blockSizeVertical !* 8,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal !* 6.2,
                          ),
                          onTap: () {
                            /*setState(() {
                          widget.type = "My type";
                        });*/
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal !* 6,
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal !* 50,
                          height: SizeConfig.blockSizeVertical !* 8,
                          child: Center(
                            child: Text(
                              "Select Investigation Group",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal !* 4.8,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: listGroupNames.length,
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () {
                              /*for (int i = 0;
                                  i < listInvestigationsList.length;
                                  i++) {
                                debugPrint("let's print group names");
                                ModelInvestigationMaster model =
                                    listInvestigationsList[i];
                                debugPrint(model.groupName);
                                debugPrint(listGroupNames[index]);
                                if (model.groupName == listGroupNames[index]) {
                                  model.show = true;
                                } else {
                                  model.show = false;
                                }
                              }
                              setState(() {});*/
                              selectedGroupName = listGroupNames[index];
                              searchAndFilterInvestigationList();
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Container(
                                    width: SizeConfig.blockSizeHorizontal !* 90,
                                    padding: EdgeInsets.only(
                                      top: 5,
                                      bottom: 5,
                                      left: 5,
                                      right: 5,
                                    ),
                                    decoration: new BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.rectangle,
                                      border: Border(
                                        bottom: BorderSide(
                                            width: 2.0, color: Colors.grey),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10.0,
                                          offset: const Offset(0.0, 10.0),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        listGroupNames[index],
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ))));
                      }),
                ),
                /*Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: MaterialButton(
                        color: Colors.red,
                        onPressed: () {
                          Navigator.of(context).pop(); // To close the dialog
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ))*/
              ],
            )));
  }

  void searchAndFilterInvestigationList() {
    for (int i = 0; i < listInvestigationsList.length; i++) {
      ModelInvestigationMaster model = listInvestigationsList[i];
      if (selectedGroupName == model.groupName || selectedGroupName == "All") {
        if (model.groupName
        !.toLowerCase()
                .contains(searchController!.text.toLowerCase()) ||
            model.investigationType
            !.toLowerCase()
                .contains(searchController!.text.toLowerCase()) ||
            model.groupType
            !.toLowerCase()
                .contains(searchController!.text.toLowerCase())) {
          model.show = true;
        } else
          model.show = false;
      } else {
        model.show = false;
      }
      /*if (model.groupName
              .toLowerCase()
              .contains(searchController.text.toLowerCase()) ||
          model.investigationType
              .toLowerCase()
              .contains(searchController.text.toLowerCase()) ||
          model.groupType
              .toLowerCase()
              .contains(searchController.text.toLowerCase())) {
        if (selectedGroupName == "All" || searchController.text == "")
          model.show = true;
        else {
          if (selectedGroupName == model.groupName)
            model.show = true;
          else
            model.show = false;
        }
      } else {
        model.show = false;
      }*/
    }
    setState(() {});
  }

  valueFromType(ModelInvestigationMaster model) {
    if (model.displayType == "radiopositive") return model.radioValue;
    return model.rangeValue;
  }
}

class GroupNameSelectionDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GroupNameSelectionDialogState();
  }
}

class GroupNameSelectionDialogState extends State<GroupNameSelectionDialog> {
  @override
  Widget build(BuildContext context) {
    return Container();
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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.modelInvestigationMaster.rangeValue != null &&
        widget.modelInvestigationMaster.rangeValue != "null" &&
        widget.modelInvestigationMaster.rangeValue != "")
      investigationController = TextEditingController(
          text: widget.modelInvestigationMaster.rangeValue);
  }

  @override
  Widget build(BuildContext context) {
    return /*Card(
      color: mycolor,
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[*/
        Container(
      height: SizeConfig.blockSizeVertical !* 20,
      padding: EdgeInsets.only(
        left: SizeConfig.blockSizeVertical !* 2,
        right: SizeConfig.blockSizeVertical !* 2,
      ),
      child: TextField(
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
          hintText: "Enter value",
        ),
        onChanged: (text) {
          textChanged(text);
        },
      ),
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
    int index = listInvestigationsList.indexOf(widget.modelInvestigationMaster);
    debugPrint("Index - " + index.toString());
    debugPrint("Before");
    debugPrint(listInvestigationsList[index].isChecked.toString());
    setState(() {
      if (widget.modelInvestigationMaster.isChecked) {
        mycolor = Colors.white;
        widget.modelInvestigationMaster.isChecked = false;
        listInvestigationsList.remove(widget.modelInvestigationMaster);
        listInvestigationsList.insert(index, widget.modelInvestigationMaster);
        debugPrint("Index - " + index.toString());
        debugPrint("After");
        debugPrint(listInvestigationsList[index].isChecked.toString());
      } else {
        mycolor = Colors.grey;
        widget.modelInvestigationMaster.isChecked = true;
        listInvestigationsList.remove(widget.modelInvestigationMaster);
        listInvestigationsList.insert(index, widget.modelInvestigationMaster);
        debugPrint("Index - " + index.toString());
        debugPrint("After");
        debugPrint(listInvestigationsList[index].isChecked.toString());
      }
    });
  }

  void textChanged(String text) {
    int index = listInvestigationsList.indexOf(widget.modelInvestigationMaster);
    listInvestigationsList.remove(widget.modelInvestigationMaster);
    widget.modelInvestigationMaster.rangeValue = text;
    listInvestigationsList.insert(index, widget.modelInvestigationMaster);
    /*debugPrint(widget.modelInvestigationMaster.investigationType);
    debugPrint(widget.modelInvestigationMaster.rangeValue);*/
    setState(() {});
  }
}

class MultiCard extends StatefulWidget {
  ModelInvestigationMaster modelInvestigationMaster;
  int index;
  ModelInvestigationMaster? previousModelInvestigationMaster;

  MultiCard(this.modelInvestigationMaster, this.index);

  @override
  MultiCardState createState() => new MultiCardState();
}

class MultiCardState extends State<MultiCard> {
  var mycolor = Colors.white;
  var investigationController = TextEditingController();
  FocusNode? myFocusNode;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
    debugPrint("from widget idp");
    debugPrint(widget.modelInvestigationMaster.preInvestTypeIDP);
    debugPrint("from parent idp");
    debugPrint(preInvestTypeIDPGlobal);
    if (preInvestTypeIDPGlobal != "" &&
        preInvestTypeIDPGlobal ==
            widget.modelInvestigationMaster.preInvestTypeIDP) {
      toggleSelection();
    }
  }

  @override
  void dispose() {
    investigationController.clear();
    myFocusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void textChanged(String text) {
      int index =
          listInvestigationsList.indexOf(widget.modelInvestigationMaster);
      listInvestigationsList.remove(widget.modelInvestigationMaster);
      widget.modelInvestigationMaster.rangeValue = text;
      listInvestigationsList.insert(index, widget.modelInvestigationMaster);
      setState(() {});
    }

    if (widget.index > 0) {
      widget.previousModelInvestigationMaster =
          listInvestigationsList[widget.index - 1];
    }

    return widget.modelInvestigationMaster.show
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              showCategory()
                  ? Text(
                      widget.modelInvestigationMaster.groupName!.trim(),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal !* 5.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ).pO(
                      left: SizeConfig.blockSizeHorizontal !* 3.0,
                      top: SizeConfig.blockSizeVertical !* 2.5,
                      bottom: SizeConfig.blockSizeVertical !* 2.5,
                    )
                  : Container(),
              Card(
                color: mycolor,
                margin: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal !* 5.0,
                ),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  ListTile(
                    selected: widget.modelInvestigationMaster.isChecked,
                    contentPadding: EdgeInsets.all(
                      SizeConfig.blockSizeHorizontal !* 1.0,
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget
                                    .modelInvestigationMaster.investigationType
                                !.trim(),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal !* 3.8,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              /*SizedBox(
                                height: SizeConfig.blockSizeVertical * 0.6,
                              ),*/
                              /*Text(
                                widget.modelInvestigationMaster.groupType.trim() +
                                    " -> " +
                                    widget.modelInvestigationMaster.groupName.trim(),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal * 3.2,
                                ),
                              ),*/
                            ],
                          ),
                        ),
                        Expanded(
                            child: Visibility(
                          visible: widget.modelInvestigationMaster.isChecked,
                          child: widget.modelInvestigationMaster.displayType ==
                                      "number" ||
                                  widget.modelInvestigationMaster.displayType ==
                                      "open"
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Enter Value",
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal !* 3,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    TextField(
                                      //controller: mobileNoController,
                                      keyboardType: widget
                                                  .modelInvestigationMaster
                                                  .displayType ==
                                              "number"
                                          ? TextInputType.number
                                          : TextInputType.text,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize:
                                              SizeConfig.blockSizeVertical !*
                                                  2.1),
                                      controller: investigationController,
                                      focusNode: myFocusNode,
                                      decoration: InputDecoration(
                                        labelText:
                                            "${widget.modelInvestigationMaster.investigationType}",
                                        hintText: "",
                                      ),
                                      onChanged: (text) {
                                        textChanged(text);
                                      },
                                    ),
                                  ],
                                )
                              : widget.modelInvestigationMaster.displayType ==
                                      "radiopositive"
                                  ? Column(
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Radio(
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              value: "positive",
                                              groupValue: widget
                                                  .modelInvestigationMaster
                                                  .radioValue,
                                              onChanged:
                                                  changeRadioPositiveValue,
                                            ),
                                            Text(
                                              'Positive',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio(
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              value: "negative",
                                              groupValue: widget
                                                  .modelInvestigationMaster
                                                  .radioValue,
                                              onChanged: changeRadioPositiveValue,
                                            ),
                                            Text(
                                              'Negative',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  : Container(),
                        )),
                      ],
                    ),
                    leading: Checkbox(
                      onChanged: (isChecked) {
                        toggleSelection();
                      },
                      value: widget.modelInvestigationMaster.isChecked,
                    ),
                    onTap: () {
                      // what should I put here,
                    },
                  )
                ]),
              ),
            ],
          )
        : Container();
  }

  void toggleSelection() {
    int index = listInvestigationsList.indexOf(widget.modelInvestigationMaster);
    debugPrint("Index - " + index.toString());
    debugPrint("Before");
    debugPrint(listInvestigationsList[index].isChecked.toString());
    setState(() {
      if (widget.modelInvestigationMaster.isChecked) {
        mycolor = Colors.white;
        myFocusNode!.unfocus();
        widget.modelInvestigationMaster.isChecked = false;
      } else {
        mycolor = Colors.white;
        myFocusNode!.requestFocus();
        widget.modelInvestigationMaster.isChecked = true;
      }
    });
  }

  void changeRadioPositiveValue(String? value) {
    /*int index = listInvestigationsList.indexOf(widget.modelInvestigationMaster);
    debugPrint("Index - " + index.toString());
    debugPrint("Before");
    debugPrint(listInvestigationsList[index].isChecked.toString());*/
    setState(() {
      widget.modelInvestigationMaster.radioValue = value!;
      /*if (widget.modelInvestigationMaster.isChecked) {
        mycolor = Colors.white;
        myFocusNode.unfocus();
        widget.modelInvestigationMaster.isChecked = false;
      } else {
        mycolor = Colors.white;
        myFocusNode.requestFocus();
        widget.modelInvestigationMaster.isChecked = true;
      }*/
    });
  }

  bool showCategory() {
    if (widget.index == 0) return true;
    if (widget.previousModelInvestigationMaster!.groupName!.trim() !=
        widget.modelInvestigationMaster.groupName!.trim()) return true;
    return false;
  }
}
