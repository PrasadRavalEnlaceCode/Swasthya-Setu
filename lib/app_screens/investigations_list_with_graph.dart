import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:silvertouch/app_screens/add_vital_screen.dart';
import 'package:silvertouch/app_screens/investigation_list_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/dropdown_item.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/model_investigation_master_list_with_date_time.dart';
import 'package:silvertouch/podo/model_vitals_list.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/flutter_echarts_custom.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import '../utils/color.dart';
import 'investigation_list_read_only_screen.dart';

var pickedDate = DateTime.now();
List<Map<String, String>> listCategories = [];
var selectedCategoryIDP = "";
var selectedCategory = "";
GlobalKey<MyEChartState> keyForChart = GlobalKey();
List<ModelInvestigationMasterWithDateTime> listInvestigations = [];
List<String> listVitalByWhom = [];

List<String> listVitalOnlyString = [];

List<String> listVitalOnlyStringDate = [];

ProgressDialog? pr;

class InvestigationsListWithGraph extends StatefulWidget {
  String patientIDP = "";
  DropDownItem selectedCountry = DropDownItem("", "");
  DropDownItem selectedState = DropDownItem("", "");
  DropDownItem selectedCity = DropDownItem("", "");

  var fromDate = DateTime.now().subtract(Duration(days: 7));
  var toDate = DateTime.now();

  var fromDateString = "";
  var toDateString = "";
  var dateString = "Select Date Range";

  String emptyTextInvestigation1 =
      "You can enter your Investigation reports values by selecting Investigation from the list.";
  String emptyTextInvestigation2 = "Share the details to your doctor any time.";

  String emptyTextSugar1 = "FBS (Fasting Blood Sugar) : 8-10 hrs. of Fasting.";
  String emptyTextSugar2 =
      "PPBS (Post Prandial Blood Sugar) : After 2 hours of Proper Lunch.";
  String emptyTextSugar3 = "RBS (Random Blood Sugar) : At any random time.";
  String emptyTextSugar4 =
      "HbA1C (Hemoglobin A1C) : Average Sugar control of last 90 days.";

  String emptyTextThyroid =
      "You can Add Your Thyroid Data. Kindly click on Plus icon to add one.";

  String emptyMessage = "";

  Widget? emptyMessageWidget;

  var mainType = "chart";

  bool shouldShowEmptyMessageWidget = true;

  String? from = "";

  InvestigationsListWithGraph(String patientIDP,
      {String from = "investigation"}) {
    this.patientIDP = patientIDP;
    this.from = from;
  }

  @override
  State<StatefulWidget> createState() {
    return InvestigationsListWithGraphState();
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

class InvestigationsListWithGraphState
    extends State<InvestigationsListWithGraph> {
  ScrollController? hideFABController;
  var isFABVisible = true;
  late DateTimeRange dateRange;

  @override
  void initState() {
    super.initState();
    keyForChart = GlobalKey();
    if (widget.from == "sugar")
      widget.emptyMessage =
          "${widget.emptyTextSugar1}\n\n${widget.emptyTextSugar2}\n\n${widget.emptyTextSugar3}\n\n${widget.emptyTextSugar4}";
    else if (widget.from == "thyroid")
      widget.emptyMessage = "${widget.emptyTextThyroid}";
    else
      widget.emptyMessage =
          "${widget.emptyTextInvestigation1}\n\n${widget.emptyTextInvestigation2}";
    // var formatter = new DateFormat('dd-MM-yyyy');
    /*widget.fromDateString = formatter.format(widget.fromDate);
    widget.toDateString = formatter.format(widget.toDate);*/
    widget.dateString = "Select Date Range";
    var formatter = new DateFormat('dd-MM-yyyy');
    widget.fromDate = DateTime.now().subtract(const Duration(days: 30));
    widget.toDate = DateTime.now();
    widget.fromDateString = formatter.format(widget.fromDate!);
    widget.toDateString = formatter.format(widget.toDate!);
    dateRange = DateTimeRange(start: widget.fromDate!, end: widget.toDate!);

    hideFABController = ScrollController();
    hideFABController!.addListener(() {
      if (hideFABController!.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (isFABVisible == true) {
          /* only set when the previous state is false
             * Less widget rebuilds
             */
          print("**** $isFABVisible up"); //Move IO away from setState
          setState(() {
            isFABVisible = false;
          });
        }
      } else {
        if (hideFABController!.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (isFABVisible == false) {
            print("**** ${isFABVisible} down"); //Move IO away from setState
            setState(() {
              isFABVisible = true;
            });
          }
        }
      }
    });
    widget.emptyMessageWidget = SizedBox(
      height: SizeConfig.blockSizeVertical! * 80,
      child: Container(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 5),
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
    getCategoryList(context);
  }

  @override
  void dispose() {
    listCategories = [];
    selectedCategoryIDP = "";
    selectedCategory = "";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        /*key: navigatorKey,*/
        appBar: AppBar(
          title: Text(widget.from == "sugar"
              ? "Sugar"
              : widget.from == "thyroid"
                  ? "Thyroid"
                  : "Investigations List"),
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(
              color: Colorsblack, size: SizeConfig.blockSizeVertical! * 2.5),
          actions: <Widget>[
            InkWell(
              onTap: () {
                setState(() {
                  if (widget.mainType == "list") {
                    widget.mainType = "chart";
                    setStateOfTheEChartWidget();
                  } else if (widget.mainType == "chart")
                    widget.mainType = "list";
                });
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Image(
                  image: widget.mainType == "chart"
                      ? AssetImage("images/list.png")
                      : AssetImage("images/graph.png"),
                  width: 23,
                  height: 23,
                  color: Colors.black,
                ),
              ),
            ),
            /*IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {

            },
          )*/
          ],
          toolbarTextStyle: TextTheme(
                  titleMedium: TextStyle(
                      color: Colorsblack,
                      fontFamily: "Ubuntu",
                      fontSize: SizeConfig.blockSizeVertical! * 2.5))
              .bodyMedium,
          titleTextStyle: TextTheme(
                  titleMedium: TextStyle(
                      color: Colorsblack,
                      fontFamily: "Ubuntu",
                      fontSize: SizeConfig.blockSizeVertical! * 2.5))
              .titleLarge,
        ),
        floatingActionButton: Visibility(
          visible: isFABVisible,
          child: FloatingActionButton(
            onPressed: () {
              if (widget.from == "sugar")
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AddVitalsScreen(widget.patientIDP, "3")))
                    .then((value) {
                  getCategoryList(context);
                });
              else if (widget.from == "thyroid")
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AddVitalsScreen(widget.patientIDP, "6")))
                    .then((value) {
                  getCategoryList(context);
                });
              else
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InvestigationListScreen(
                                widget.patientIDP,
                                preInvestTypeIDP: selectedCategoryIDP)))
                    .then((value) {
                  getCategoryList(context);
                });
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.black,
            /*),*/
          ),
        ),
        body: RefreshIndicator(
          child: ListView(
            shrinkWrap: true,
            controller: hideFABController,
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    height: SizeConfig.blockSizeVertical! * 8,
                    child: Padding(
                      padding: EdgeInsets.only(left: 5.0, right: 5.0),
                      child: Container(
                        child: InkWell(
                            onTap: () {
                              showDateRangePickerDialog();
                            },
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    widget.dateString,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeVertical! * 2.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black),
                                  ),
                                ),
                                Container(
                                  width: SizeConfig.blockSizeHorizontal! * 15,
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    size: SizeConfig.blockSizeHorizontal! * 8,
                                  ),
                                ),
                              ],
                            )),
                        padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: SizeConfig.blockSizeHorizontal! * 2,
                        right: SizeConfig.blockSizeHorizontal! * 2),
                    child: Container(
                      height: SizeConfig.blockSizeVertical! * 10,
                      child: ListView.separated(
                        itemCount: listCategories.length,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedCategoryIDP =
                                    listCategories[index]["categoryIDP"]!;
                                selectedCategory =
                                    listCategories[index]["categoryName"]!;
                                getInvestigationDatesList();
                              });
                            },
                            child: Chip(
                              padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal! * 3),
                              label: Text(
                                listCategories[index]["categoryName"]!.trim(),
                                style: TextStyle(
                                  color: listCategories[index]["categoryIDP"] ==
                                          selectedCategoryIDP
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              backgroundColor: listCategories[index]
                                          ["categoryIDP"] ==
                                      selectedCategoryIDP
                                  ? Color(0xFF06A759)
                                  : Colors.grey,
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            width: SizeConfig.blockSizeHorizontal! * 5,
                          );
                        },
                      ),
                    ),
                  ),
                  widget.mainType == "chart"
                      ? //DateTimeComboLinePointChart.withSampleData()
                      RepaintBoundary(
                          child: Container(
                              width: SizeConfig.screenWidth,
                              color: Colors.white,
                              child: Padding(
                                  padding: EdgeInsets.all(
                                      SizeConfig.blockSizeHorizontal! * 3),
                                  child: Column(
                                    children: <Widget>[
                                      widget.shouldShowEmptyMessageWidget
                                          ? widget.emptyMessageWidget!
                                          : Container(),
                                      !widget.shouldShowEmptyMessageWidget
                                          ? MyEChart(
                                              key: keyForChart,
                                              chartTypeID: "1",
                                              titleOfChart:
                                                  selectedCategory.trim())
                                          : Container(),
                                    ],
                                  ))))
                      //ColoredChart(context, listVital) // MyAnimatedChart()
                      : (listInvestigations.length > 0
                          ? ListView.builder(
                              padding: const EdgeInsets.only(
                                  bottom: kFloatingActionButtonMargin + 60),
                              itemCount: listInvestigations.length,
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return InkWell(
                                    onTap: () {
                                      var modelInvestigation =
                                          listInvestigations[index];
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  InvestigationListReadOnlyScreen(
                                                      widget.patientIDP,
                                                      modelInvestigation)))
                                          .then((value) =>
                                              getCategoryList(context));
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(0.0),
                                        child: Container(
                                            width: SizeConfig
                                                    .blockSizeHorizontal! *
                                                90,
                                            padding: EdgeInsets.only(
                                              top: SizeConfig
                                                      .blockSizeVertical! *
                                                  0.4,
                                              bottom: SizeConfig
                                                      .blockSizeVertical! *
                                                  0.4,
                                              left: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  1.5,
                                              right: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  1.5,
                                            ),
                                            decoration: new BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.rectangle,
                                              border: Border(
                                                bottom: BorderSide(
                                                    width: 1.0,
                                                    color: Color(0xFF636F7B)),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 10.0,
                                                  offset:
                                                      const Offset(0.0, 10.0),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Container(
                                                  /*decoration: BoxDecoration(
                                color: Colors.primaries[Random()
                                    .nextInt(Colors.primaries.length)],
                                borderRadius: BorderRadius.circular(35),
                              ),*/
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              Text(
                                                                "${listInvestigations[index].date} (",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeVertical! *
                                                                          2.3,
                                                                ),
                                                              ),
                                                              Text(
                                                                "${listInvestigations[index].time})",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontSize:
                                                                      SizeConfig
                                                                              .blockSizeVertical! *
                                                                          2.3,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: SizeConfig
                                                                    .blockSizeVertical! *
                                                                0.8,
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Column(
                                                                  children: <Widget>[
                                                                    Text(
                                                                      selectedCategory
                                                                          .trim(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xFF636F7B),
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontSize:
                                                                            SizeConfig.blockSizeVertical! *
                                                                                2.1,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          SizeConfig.blockSizeVertical! *
                                                                              0.8,
                                                                    ),
                                                                    Text(
                                                                      "${listInvestigations[index].rangeValue}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xFF636F7B),
                                                                        fontSize:
                                                                            SizeConfig.blockSizeVertical! *
                                                                                2.1,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  width: 20,
                                                                  height: 20,
                                                                ),
                                                                Column(
                                                                  children: <Widget>[
                                                                    Text(
                                                                      "Entry By",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xFF636F7B),
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontSize:
                                                                            SizeConfig.blockSizeVertical! *
                                                                                2.1,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          SizeConfig.blockSizeVertical! *
                                                                              0.8,
                                                                    ),
                                                                    Text(
                                                                      "${listInvestigations[index].byWhom}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xFF636F7B),
                                                                        fontSize:
                                                                            SizeConfig.blockSizeVertical! *
                                                                                2.1,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Expanded(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: InkWell(
                                                            onTap: () {
                                                              var modelInvestigation =
                                                                  listInvestigations[
                                                                      index];
                                                              Navigator.of(
                                                                      context)
                                                                  .push(MaterialPageRoute(
                                                                      builder: (context) => InvestigationListReadOnlyScreen(
                                                                          widget
                                                                              .patientIDP,
                                                                          modelInvestigation)))
                                                                  .then((value) =>
                                                                      getCategoryList(
                                                                          context));
                                                            },
                                                            child: Icon(
                                                              Icons
                                                                  .chevron_right,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )))));
                              })
                          : widget.emptyMessageWidget!),
                ],
              ),
            ],
          ),
          onRefresh: () {
            return getCategoryList(context);
          },
        ));
  }

  Future<Future<String?>?> getCategoryList(BuildContext context) async {
    String loginUrl = "${baseURL}patientInvestDataNames.php";
    if (widget.from == "sugar")
      loginUrl = "${baseURL}patientInvestDataNamesSugar.php";
    if (widget.from == "thyroid")
      loginUrl = "${baseURL}patientInvestDataNamesThyroid.php";
    /*Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr.show();
    });*/
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
        widget.patientIDP +
        "\"" +
        "," +
        "\"" +
        "FromDate" +
        "\"" +
        ":" +
        "\"" +
        widget.fromDateString +
        "\"" +
        "," +
        "\"" +
        "ToDate" +
        "\"" +
        ":" +
        "\"" +
        widget.toDateString +
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
    //pr.hide();
    debugPrint("response :" + response.body.toString());
    debugPrint("Data :" + model.data!);
    listCategories = [];
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);
      //listCategories.add({"categoryName": "All", "categoryIDP": "-"});
      if (jsonData.length > 0) {
        selectedCategoryIDP = jsonData[0]['PreInvestTypeIDP'];
        selectedCategory = jsonData[0]['InvestigationType'];
        for (int i = 0; i < jsonData.length; i++) {
          final jo = jsonData[i];
          listCategories.add({
            "categoryName": jo['InvestigationType'],
            "categoryIDP": jo['PreInvestTypeIDP']
          });
        }
      }
      pr!.hide();
      setState(() {});
      return getInvestigationDatesList();
      /*final List<Map<String, String>> listOfColumns = [
        {"Name": "AAAAAA", "Number": "1", "State": "Yes"},
        {"Name": "BBBBBB", "Number": "2", "State": "no"},
        {"Name": "CCCCCC", "Number": "3", "State": "Yes"}
      ];*/
      //String cp = jo['CreditPoints'];
    } else {
      pr!.hide();
      setState(() {});
      return getInvestigationDatesList();
    }
  }

  // Future<String?>? getCategoryListOnly(BuildContext context) async {
  //   String loginUrl = "${baseURL}patientInvestDataNames.php";
  //   /*Future.delayed(Duration.zero, () {
  //     pr = ProgressDialog(context);
  //     pr.show();
  //   });*/
  //   Future.delayed(Duration.zero, () {
  //     pr = ProgressDialog(context);
  //     pr!.show();
  //   });
  //   //listIcon = new List();
  //   String patientUniqueKey = await getPatientUniqueKey();
  //   String userType = await getUserType();
  //   debugPrint("Key and type");
  //   debugPrint(patientUniqueKey);
  //   debugPrint(userType);
  //   String jsonStr = "{" +
  //       "\"" +
  //       "PatientIDP" +
  //       "\"" +
  //       ":" +
  //       "\"" +
  //       widget.patientIDP +
  //       "\"" +
  //       "," +
  //       "\"" +
  //       "FromDate" +
  //       "\"" +
  //       ":" +
  //       "\"" +
  //       widget.fromDateString +
  //       "\"" +
  //       "," +
  //       "\"" +
  //       "ToDate" +
  //       "\"" +
  //       ":" +
  //       "\"" +
  //       widget.toDateString +
  //       "\"" +
  //       "}";
  //
  //   debugPrint(jsonStr);
  //
  //   String encodedJSONStr = encodeBase64(jsonStr);
  //   var response = await apiHelper.callApiWithHeadersAndBody(
  //     url: loginUrl,
  //     //Uri.parse(loginUrl),
  //     headers: {
  //       "u": patientUniqueKey,
  //       "type": userType,
  //     },
  //     body: {"getjson": encodedJSONStr},
  //   );
  //   //var resBody = json.decode(response.body);
  //   debugPrint(response.body.toString());
  //   final jsonResponse = json.decode(response.body.toString());
  //   ResponseModel model = ResponseModel.fromJSON(jsonResponse);
  //   //pr.hide();
  //   debugPrint("response :" + response.body.toString());
  //   debugPrint("Data :" + model.data!);
  //   listCategories = [];
  //   if (model.status == "OK") {
  //     var data = jsonResponse['Data'];
  //     var strData = decodeBase64(data);
  //     debugPrint("Decoded Data Array : " + strData);
  //     final jsonData = json.decode(strData);
  //     //listCategories.add({"categoryName": "All", "categoryIDP": "-"});
  //     if (jsonData.length > 0) {
  //       for (int i = 0; i < jsonData.length; i++) {
  //         final jo = jsonData[i];
  //         listCategories.add({
  //           "categoryName": jo['InvestigationType'],
  //           "categoryIDP": jo['PreInvestTypeIDP']
  //         });
  //       }
  //     }
  //     pr!.hide();
  //     setState(() {});
  //     keyForChart.currentState!.setStateInsideTheChart();
  //     /*final List<Map<String, String>> listOfColumns = [
  //       {"Name": "AAAAAA", "Number": "1", "State": "Yes"},
  //       {"Name": "BBBBBB", "Number": "2", "State": "no"},
  //       {"Name": "CCCCCC", "Number": "3", "State": "Yes"}
  //     ];*/
  //     //String cp = jo['CreditPoints'];
  //   } else {
  //     pr!.hide();
  //     setState(() {});
  //   }
  //   return null;
  // }

  void setStateOfTheEChartWidget() {
    if (keyForChart == null)
      debugPrint("key null");
    else if (keyForChart.currentState == null)
      debugPrint("currentState null");
    else {
      debugPrint(
          "nothing null, setting state of chart  - chart 1 idp - x, title - Investigation");
      keyForChart.currentState!.setStateInsideTheChart();
    }
  }

  void showCountrySelectionDialog(List<DropDownItem> list, String type) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.red,
                          size: SizeConfig.blockSizeHorizontal! * 6.2,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal! * 6,
                      ),
                      Text(
                        "Select $type",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 4.8,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                    itemCount: list.length,
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {},
                          child: Padding(
                              padding: EdgeInsets.all(0.0),
                              child: Container(
                                  width: SizeConfig.blockSizeHorizontal! * 90,
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
                                      list[index].value,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ))));
                    }),
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

  Future<String?>? getInvestigationDatesList() async {
    String loginUrl = "${baseURL}patientInvestDataNamesSingle.php";
    //listIcon = new List();
    pr = ProgressDialog(context);
    pr!.show();
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
        "\"" +
        "FromDate" +
        "\"" +
        ":" +
        "\"" +
        widget.fromDateString +
        "\"" +
        "," +
        "\"" +
        "ToDate" +
        "\"" +
        ":" +
        "\"" +
        widget.toDateString +
        "\"" +
        "," +
        "\"" +
        "PreInvestTypeIDP" +
        "\"" +
        ":" +
        "\"" +
        selectedCategoryIDP +
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
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      listInvestigations = [];
      listVitalByWhom = [];
      listVitalOnlyString = [];
      listVitalOnlyStringDate = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        //listVitalOnlyString.add(jo['InvestValue']);
        var date = jo["EntryDate"];
        var time = jo["EntryTime"];
        String year = date.split("-")[2];
        String month = date.split("-")[1];
        String day = date.split("-")[0];
        String hour = time.split(":")[0];
        String min = time.split(":")[1];
        var current = DateTime(int.parse(year), int.parse(month),
            int.parse(day), int.parse(hour), int.parse(min), 0, 0, 0);
        var formatter = new DateFormat('dd MMM HH:mm');
        listVitalOnlyStringDate.add("${formatter.format(current)}");
        listVitalOnlyString.add(jo["InvestValue"]);
        String byWhom = "";
        if (jo['doctorentrystatus'] == "0")
          byWhom = "Patient";
        else if (jo['doctorentrystatus'] == "1") byWhom = "Doctor";
        listInvestigations.add(ModelInvestigationMasterWithDateTime(
          jo["PreInvestDataIDP"].toString(),
          "",
          "",
          "",
          jo["InvestValue"],
          false,
          jo["EntryDate"],
          jo["EntryTime"],
          jo["EntryTimeId"].toString(),
          byWhom: byWhom,
        ));
        listVitalByWhom.add(byWhom);
      }
      if (listInvestigations.length > 0)
        widget.shouldShowEmptyMessageWidget = false;
      else
        widget.shouldShowEmptyMessageWidget = true;
      setState(() {});
      return 'success';
    }
    return null;
  }

  void deleteTheVitalFromTheList(ModelVitalsList modelVitalList) async {
    String loginUrl = "${baseURL}patientVitalDelete.php";
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
        widget.patientIDP +
        "\"" +
        "," +
        "\"" +
        "VitalIDP" +
        "\"" +
        ":" +
        "\"" +
        modelVitalList.vitalIDP +
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
    if (model.status == "OK") {
      getCategoryList(context);
    }
  }

  Future<void> showDateRangePickerDialog() async {
    print('showDateRangePickerDialog $showDateRangePickerDialog');
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (newDateRange == null) return;

    setState(() {
      dateRange = newDateRange;
      widget.fromDate = dateRange.start;
      widget.toDate = dateRange.end;
      var formatter = new DateFormat('dd-MM-yyyy');
      widget.fromDateString = formatter.format(widget.fromDate!);
      widget.toDateString = formatter.format(widget.toDate!);
      widget.dateString =
          "${widget.fromDateString}  to  ${widget.toDateString}";
      getCategoryList(context);
    });
    // final List<DateTime>? listPicked = await DateRagePicker.showDatePicker(
    //     context: context,
    //     initialFirstDate: widget.fromDate,
    //     initialLastDate: widget.toDate,
    //     firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
    //     lastDate: DateTime.now(),
    //     handleOk: () {},
    //     handleCancel: () {});
    // showCustomDateRangePicker(
    //   context,
    //   dismissible: true,
    //   minimumDate: DateTime.now().subtract(Duration(days: 365 * 100)),
    //   maximumDate: DateTime.now(),
    //   endDate: widget.toDate,
    //   startDate: widget.fromDate,
    //   backgroundColor: Colors.white,
    //   primaryColor: Colors.blue,
    //   onApplyClick: (start, end) {
    //     setState(() {
    //         widget.fromDate = start;
    //         widget.toDate = end;
    //         var formatter = new DateFormat('dd-MM-yyyy');
    //         widget.fromDateString = formatter.format(widget.fromDate);
    //         widget.toDateString = formatter.format(widget.toDate);
    //         widget.dateString =
    //         "${widget.fromDateString}  to  ${widget.toDateString}";
    //         getCategoryList(context);
    //         //print(picked);
    //     });
    //   },
    //   onCancelClick: () {
    //     setState(() {
    //       widget.fromDate = DateTime.now().subtract(Duration(days: 7));
    //       widget.toDate = DateTime.now();
    //       getCategoryList(context);
    //     });
    //   },
    // );
  }
}

class MyEChart extends StatefulWidget {
  String? chartTypeID, titleOfChart;

  MyEChart({Key? key, this.chartTypeID, this.titleOfChart}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyEChartState();
  }
}

class MyEChartState extends State<MyEChart> {
  var yAxisData = StringBuffer();
  var xAxisDatesData = StringBuffer();
  var yAxisData2 = StringBuffer();

  var color;
  var colorRGB;
  var series;

  var listOnlyString, listOnlyDate;

  void setStateInsideTheChart() {
    debugPrint("Let's set chart state");
    yAxisData = StringBuffer();
    yAxisData2 = StringBuffer();
    xAxisDatesData = StringBuffer();

    color = "'rgb(255, 0, 0)'";
    colorRGB = Color.fromRGBO(255, 0, 0, 1);

    series =
        "[{data: $yAxisData,type: 'line',symbol: 'circle',symbolSize: 8,smooth: true,itemStyle: {color: $color},},]";

    listOnlyString = listVitalOnlyString;
    listOnlyDate = listVitalOnlyStringDate;

    debugPrint(listOnlyString.toString());

    if (listOnlyString.length > 1) {
      for (int i = 0; i < listOnlyString.length; i++) {
        if (i == 0)
          yAxisData.write(
              "[{value:${double.parse(listOnlyString[i]).round().toInt()},name:'${listVitalByWhom[i]}'},");
        else if (i == listOnlyString.length - 1)
          yAxisData.write(
              "{value:${double.parse(listOnlyString[i]).round().toInt()},name:'${listVitalByWhom[i]}'}]");
        else
          yAxisData.write(
              "{value:${double.parse(listOnlyString[i]).round().toInt()},name:'${listVitalByWhom[i]}'},");

        if (i == 0)
          xAxisDatesData.write("['${listOnlyDate[i]}',");
        else if (i == listOnlyDate.length - 1)
          xAxisDatesData.write("'${listOnlyDate[i]}']");
        else
          xAxisDatesData.write("'${listOnlyDate[i]}',");
      }
    } else if (listOnlyString.length == 1) {
      yAxisData.write(
          "[{value:${double.parse(listOnlyString[0]).round().toInt()},name:'${listVitalByWhom[0]}'}]");
      xAxisDatesData.write("['${listOnlyDate[0]}']");
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(MyEChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    setStateInsideTheChart();
  }

  @override
  void initState() {
    //setState(() {});
    super.initState();
    setStateInsideTheChart();
  }

  @override
  Widget build(BuildContext context) {
    return listOnlyString.length > 0
        ? Container(
            width: SizeConfig.screenWidth,
            height: SizeConfig.blockSizeVertical! * 60,
            child: widget.chartTypeID != "5"
                ? EchartsCustom(
                    option:
                        '''
                        {
                          tooltip: {
                                trigger: 'axis',
                              backgroundColor: 'rgba(0, 0, 0, 0.8)',
                              textStyle: {
                               fontWeight: 'bold',
                               color: 'white',
                              },
                              formatter: function (params) {
                                var colorSpan = color => '<span style="display:inline-block;margin-right:5px;border-radius:20px;width:12px;height:12px;background-color:' + color + '"></span>';
                                var colorSpanDoctor = drName => '<span style="font_size:16;">' + drName + '</span>';
                                let rez = params[0].axisValue + '</br>';
                                //console.log(params); //quite useful for debug
                                params.forEach(item => {
                                //console.log(item); //quite useful for debug
                                var xx = colorSpan(item.color) + ' ' + item.seriesName + ': ' + item.data.value + '</br>' + '---' + '</br>' + colorSpanDoctor(item.data.name) + '</br>'
                                rez += xx;
                                });
                                return rez;
                              }
                            },
                          xAxis: {
                            type: 'category',
                            boundaryGap: false,
                            data: $xAxisDatesData,
                          },
                          yAxis: {
                            type: 'value',
                            boundaryGap: false
                          },
                          legend: {
                            show: true,
                            data: [{name: '${widget.titleOfChart}', icon: 'square', textStyle: {color: $color}}]
                          },
                          series: [{data: $yAxisData,type: 'line',symbol: 'circle',symbolSize: 8,smooth: true,itemStyle: {color: $color},name:'${widget.titleOfChart}'}]
                        }
                        ''',

                    //,name:'BP'
                  )
                : EchartsCustom(
                    option:
                        '''
                  {
                    tooltip: {
                          trigger: 'axis',
                      },
                    xAxis: {
                      type: 'category',
                      boundaryGap: false,
                      data: $xAxisDatesData,
                    },
                    yAxis: {
                      type: 'value',
                      boundaryGap: false
                    },
                    title: {
                            text: 'BP',
                            show: true
                          },
                    legend: {
                            show: true,
                            orient: 'vertical',
                            data: [{name: 'Systolic (mm of hg)', icon: 'square', textStyle: {color: 'rgb(255, 0, 0)', padding: 2}}, {name: 'Diastolic (mm of hg)', icon: 'square', textStyle: {color: 'rgb(0, 145, 234)'}}]
                          },
                    series: [{data: $yAxisData,type: 'line',symbol: 'circle',symbolSize: 8,smooth: true,itemStyle: {color: 'rgb(255, 0, 0)'}, name:'Systolic (mm of hg)'},
                    {data: $yAxisData2,type: 'line',symbol: 'circle',symbolSize: 8,smooth: true,itemStyle: {color: 'rgb(0, 145, 234)'}, name:'Diastolic (mm of hg)'}]
                  }
                ''',
                  ),
          )
        : Container();
  }
}
//JSON Parsing
//https://medium.com/flutter-community/parsing-complex-json-in-flutter-747c46655f51
