import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

/*import 'package:fl_animated_linechart/chart/animated_line_chart.dart';*/
//import 'package:fl_animated_linechart/chart/line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:silvertouch/app_screens/add_vital_screen.dart';
import 'package:silvertouch/app_screens/select_sugar_vital_type_screen.dart';
import 'package:silvertouch/app_screens/water_intake_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/dropdown_item.dart';
import 'package:silvertouch/podo/model_graph_values.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/model_vitals_list.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/flutter_echarts_custom.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

/*import 'package:mp_chart/mp/chart/line_chart.dart' as mpChart;
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/enums/legend_form.dart';
import 'package:mp_chart/mp/core/enums/limit_label_postion.dart';
import 'package:mp_chart/mp/core/limit_line.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';*/
//import 'package:flutter_echarts/flutter_echarts.dart';

var pickedDate = DateTime.now();

List<ModelGraphValues> listVitalsSelectedForGraph = [];

List<ModelGraphValues> listPulse = [];
List<ModelGraphValues> listBPSystolic = [];
List<ModelGraphValues> listBPDiastolic = [];
List<ModelGraphValues> listTemperature = [];
List<ModelGraphValues> listSPO2 = [];

List<ModelGraphValues> listVital = [];

List<String> listVitalByWhom = [];
List<String> listVitalByWhom2 = [];

//  Continue from here
List<ModelGraphValues> listVital2 = [];
List<ModelGraphValues> listAllVital = [];

List<String> listVitalOnlyString = [];
List<String> listVitalOnlyString2 = [];

List<String> listVitalOnlyStringDate = [];
List<String> listVitalOnlyStringDate2 = [];

var chartType = "";

String titleGlobal = "";

GlobalKey globalKey = GlobalKey();
File? imgFile;
String? vitalIDPGlobal;
GlobalKey<MyEChartState>? keyForChart = GlobalKey();
GlobalKey<MyEChartState>? keyForChart2 = GlobalKey();

int pulseValue = 20,
    bpSystolicValue = 30,
    bpDiastolicValue = 10,
    spo2Value = 0,
    fbsValue = 0,
    ppbsValue = 0,
    rbsValue = 0,
    hba1cValue = 2,
    rrValue = 0,
    weightValue = 0,
    heightValue = 0,
    exerciseValue = 0,
    walkingValue = 0,
    walkingStepsValue = 0;

double tempValue = 94;

class VitalsListForDoctorsPatientScreen extends StatefulWidget {
  List<ModelVitalsList> listVitals = [];
  String? patientIDP = "";
  String vitalIDP = "", vitalIDP2 = "", vitalIDP3 = "", vitalIDP4 = "4";
  String unit = "", unit2 = "", unit3 = "", unit4 = "";
  DropDownItem selectedCountry = DropDownItem("", "");
  DropDownItem selectedState = DropDownItem("", "");
  DropDownItem selectedCity = DropDownItem("", "");

  var fromDate = DateTime.now().subtract(Duration(days: 7));
  var toDate = DateTime.now();

  var fromDateString = "";
  var toDateString = "";

  var dateString = "Select Date Range";

  var mainType = "chart";

  String emptyTextBP1 =
      "Blood Pressure monitorig is very necessery on regular basis.";
  String emptyTextBP2 =
      "Monitor your Blood Pressure regularly and share to your doctor very easily.";
  String emptyTextBP3 =
      "Monitor and record your Blood Pressure values as B.P. Systolic and B.P. Dyiastolic by selecting PLUS button from the bottom of screen.";

  String emptyTextSugar1 =
      "Blood sugar monitoring is very necessery to maintain your health.";
  String emptyTextSugar2 =
      "Monitor your Blood sugar level regularly and share to your doctor very easily.";
  String emptyTextSugar3 =
      "Monitor and record your Blood Sugar values as Fasting Sugar (FBS), Sugar after Lunch (PPBS), RBS, HbA1C by selecting PLUS button from the bottom od screen.";

  String emptyTextVitals1 =
      "Monitor your Vitals regularly and share to your doctor very easily.";
  String emptyTextVitals2 =
      "Monitor and record your Vitals values of Pluse Rate, Temperature, SPO2 (Oxygen Saturation), Respiratory rate by selecting PLUS button from the bottom od screen.";

  String emptyTextWeight =
      "You can measure your Weight and Height regularly and can share your details to your doctor anytime.";

  /*String emptyTextVitals1 =  "- Monitor your Vitals regularly and share to your doctor very easily.";
  String emptyTextVitals2 ="- Monitor and record your Vitals values of Pluse Rate, Temperature, SPO2 (Oxygen Saturation), Respiratory rate by selecting PLUS button from the bottom od screen.";*/

  String emptyMessage = "";

  Widget? emptyMessageWidget;

  bool shouldShowEmptyMessageWidget = true;

  String? title = "", selectedSubCategoryIDP;

  VitalsListForDoctorsPatientScreen(String patientIDP, String title,
      {String selectedSubCategoryIDP = ""}) {
    this.patientIDP = patientIDP;
    this.title = title;
    this.selectedSubCategoryIDP = selectedSubCategoryIDP;
  }

  @override
  State<StatefulWidget> createState() {
    return VitalsListForDoctorsPatientScreenState();
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

class VitalsListForDoctorsPatientScreenState
    extends State<VitalsListForDoctorsPatientScreen> {
  int pulseMinValue = 20,
      bpSystolicMinValue = 30,
      bpDiastolicMinValue = 10,
      spo2MinValue = 0,
      fbsMinValue = 0,
      ppbsMinValue = 0,
      rbsMinValue = 0,
      hba1cMinValue = 2,
      rrMinValue = 0,
      weightMinValue = 0,
      heightMinValue = 0,
      exerciseMinValue = 0,
      walkingMinValue = 0,
      walkingMinStepsValue = 0,
      tempMinValue = 94,
      bmiMinValue = 0;

  ScrollController? hideFABController;
  var isFABVisible = true;
  List<Map<String, String>> listVitalCategories = [];
  var selectedVitalIDP = "1";
  var selectedVitalName = "BP Systolic";
  var selectedUnit = "mm of hg";

  List<Widget> listBPTabsWidgets = [];
  List<Widget> listVitalsTabsWidgets = [];
  List<Widget> listWeightHeightTabsWidgets = [];

  List<Map<String, String>> listVitalsDialog = [];

  ProgressDialog? pr;
  AutoScrollController chipListController = AutoScrollController();
  late DateTimeRange dateRange;
  var fromDate = DateTime.now().subtract(Duration(days: 7));
  var toDate = DateTime.now();

  @override
  void dispose() {
    listVitalCategories = [];
    keyForChart = null;
    keyForChart2 = null;
    listVital = [];
    listVital2 = [];
    widget.listVitals = [];
    listVitalOnlyString = [];
    listVitalOnlyString2 = [];
    listVitalOnlyStringDate = [];
    listVitalOnlyStringDate2 = [];

    selectedVitalIDP = "1";
    selectedVitalName = "BP Systolic";
    selectedUnit = "mm of hg";
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    listVitalByWhom = [];
    listVitalByWhom2 = [];
    pr = ProgressDialog(context);

    listVitalsDialog = [];

    listVitalsDialog.add({"Name": "Blood Pressure", "IDP": "1"});
    listVitalsDialog.add({"Name": "Vitals", "IDP": "3"});
    listVitalsDialog.add({"Name": "Sugar", "IDP": ""});
    listVitalsDialog.add({"Name": "Weight Measurement", "IDP": "11"});
    keyForChart = GlobalKey();
    keyForChart2 = GlobalKey();
    dateRange = DateTimeRange(start: fromDate!, end: toDate!);
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

    //setListsForTabs();

    var formatter = new DateFormat('dd-MM-yyyy');
    widget.fromDateString = formatter.format(widget.fromDate);
    widget.toDateString = formatter.format(widget.toDate);
    widget.dateString = "Select Date Range";
    hideFABController = ScrollController();
    hideFABController!.addListener(() {
      if (hideFABController!.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (isFABVisible == true) {
          print("**** ${isFABVisible} up"); //Move IO away from setState
          setState(() {
            isFABVisible = false;
          });
        }
      } else {
        if (hideFABController!.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (isFABVisible == false) {
            /* only set when the previous state is false
               * Less widget rebuilds
               */
            print("**** ${isFABVisible} down"); //Move IO away from setState
            setState(() {
              isFABVisible = true;
            });
          }
        }
      }
    });
    getVitalCategories();
  }

  @override
  Widget build(BuildContext context) {
    final start = dateRange.start;
    final end = dateRange.end;
    SizeConfig().init(context);
    return Scaffold(
      body: RefreshIndicator(
        child: Stack(
          children: [
            Container(
              height: SizeConfig.blockSizeVertical! * 100,
              child: ListView(
                shrinkWrap: true,
                controller: hideFABController,
                children: <Widget>[
                  /*Column(
            children: [*/
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: SizeConfig.blockSizeVertical! * 8,
                      color: Color(0xFFF0F0F0),
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Container(
                          child: InkWell(
                              onTap: () {
                                // showDateRangePickerDialog();
                              },
                              child: Row(
                                children: <Widget>[
                                  // Expanded(
                                  //   child: Text(
                                  //     "${widget.dateString}",
                                  //     textAlign: TextAlign.left,
                                  //     style: TextStyle(
                                  //         fontSize:
                                  //             SizeConfig.blockSizeVertical !*
                                  //                 2.6,
                                  //         fontWeight: FontWeight.w500,
                                  //         color: Colors.black),
                                  //   ),
                                  // ),
                                  // Container(
                                  //   width: SizeConfig.blockSizeHorizontal !* 15,
                                  //   child: Icon(
                                  //     Icons.arrow_drop_down,
                                  //     size: SizeConfig.blockSizeHorizontal !* 8,
                                  //   ),
                                  // ),
                                  Expanded(
                                      child: ElevatedButton(
                                    child: Text(
                                        '${start.day}/${start.month}/${start.year}'),
                                    onPressed: pickDateRange,
                                  )),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: ElevatedButton(
                                    child: Text(
                                        '${end.day}/${end.month}/${end.year}'),
                                    onPressed: pickDateRange,
                                  )),
                                ],
                              )),
                          padding: EdgeInsets.all(5.0),
                        ),
                      ),
                    ),
                  ),
                  /*SizedBox(
            height: SizeConfig.blockSizeVertical * 2,
          ),*/
                  Container(
                    height: SizeConfig.blockSizeVertical! * 10,
                    width: SizeConfig.blockSizeHorizontal! * 100,
                    color: Color(0xFFF0F0F0),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.blockSizeHorizontal! * 2,
                          right: SizeConfig.blockSizeHorizontal! * 2),
                      child: Container(
                        height: SizeConfig.blockSizeVertical! * 10,
                        child: ListView.separated(
                          itemCount: listVitalCategories.length,
                          scrollDirection: Axis.horizontal,
                          controller: chipListController,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return AutoScrollTag(
                              key: ValueKey(index),
                              controller: chipListController,
                              index: index,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedVitalIDP =
                                        listVitalCategories[index]["IDP"]!;
                                    selectedVitalName =
                                        listVitalCategories[index]["Name"]!;
                                    selectedUnit =
                                        listVitalCategories[index]["Unit"]!;
                                    getVitalsList();
                                  });
                                },
                                child: Chip(
                                  padding: EdgeInsets.all(
                                      SizeConfig.blockSizeHorizontal! * 3),
                                  label: Text(
                                    listVitalCategories[index]["Name"]!,
                                    style: TextStyle(
                                      color: listVitalCategories[index]
                                                  ["IDP"] ==
                                              selectedVitalIDP
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                  shape: StadiumBorder(
                                      side: BorderSide(
                                          color: Colors.grey, width: 1.0)),
                                  backgroundColor: listVitalCategories[index]
                                              ["IDP"] ==
                                          selectedVitalIDP
                                      ? Color(0xFF06A759)
                                      : Color(0xFFF0F0F0),
                                  /*listVitalCategories[index]["IDP"] == selectedVitalIDP
                              ? Color(0xFF06A759)
                              : Colors.grey,*/
                                ),
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
                  ),
                  /*SizedBox(
            height: SizeConfig.blockSizeVertical * 1,
          ),*/
                  listVital.length > 0
                      ? /*selectedVitalIDP == "1"
                          ? Column(
                              children: [
                                listVital.length > 0 && listVital2.length > 0
                                    ? MyEChart(
                                        key: keyForChart,
                                        chartTypeID: "1",
                                        titleOfChart: "BP Systolic",
                                        selectedVitalIDP: "1",
                                        value: getValueFromVitalIDP("1"))
                                    : Container(),
                                listVital.length > 0 && listVital2.length > 0
                                    ? MyEChart(
                                        key: keyForChart2,
                                        chartTypeID: "2",
                                        titleOfChart: "BP Diastolic",
                                        selectedVitalIDP: "2",
                                        value: getValueFromVitalIDP("2"))
                                    : Container(),
                              ],
                            )
                          :*/
                      MyEChart(
                          key: keyForChart!,
                          chartTypeID:
                              "1" /*selectedVitalIDP == "1" ? "5" : "1"*/,
                          titleOfChart: "$selectedVitalName ($selectedUnit)",
                          selectedVitalIDP: selectedVitalIDP,
                          value: getValueFromVitalIDP(selectedVitalIDP))
                      : SizedBox(
                          height: SizeConfig.blockSizeVertical! * 80,
                          child: Container(
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 5),
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
                                  "No Records for $selectedVitalName found.",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(
                    SizeConfig.blockSizeHorizontal! * 3,
                  ),
                  child: FloatingActionButton(
                    onPressed: () {
                      String vitalIDPForSelection = getSelectionVitalIDP();
                      if (vitalIDPForSelection != "") {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return AddVitalsScreen(
                            widget.patientIDP!,
                            vitalIDPForSelection,
                          );
                        })).then((value) {
                          getVitalsList();
                        });
                      }

                      //showAddVitalSelectionDialog();
                      /*else if (selectedCategoryIDP == "2") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return InvestigationListScreen(widget.patientIDP, List());
              })).then((value) {
                setState(() {});
              });
            } else if (selectedCategoryIDP == "3") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return AddPatientReportScreen(widget.patientIDP, "-");
              })).then((value) {
                setState(() {});
              });
            }*/
                    },
                    child: Icon(Icons.add),
                    backgroundColor: Colors.black,
                  ),
                )),
          ],
        ),
        /*],
      ),*/
        onRefresh: () {
          return getVitalsList();
        },
      ),
    );
  }

  Future pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (newDateRange == null) return;

    setState(() {
      dateRange = newDateRange;
      fromDate = dateRange.start;
      toDate = dateRange.end;
      var formatter = new DateFormat('dd-MM-yyyy');
      widget.fromDateString = formatter.format(fromDate);
      widget.toDateString = formatter.format(toDate);
    });
  }

  void showAddVitalSelectionDialog() {
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
              physics: ScrollPhysics(),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
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
                        "Select Vitals to Add",
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
                /*Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "Select $type :-",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),*/
                ListView.builder(
                    itemCount: listVitalsDialog.length,
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            if (listVitalsDialog[index]["IDP"] != "") {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return AddVitalsScreen(
                                  widget.patientIDP!,
                                  listVitalsDialog[index]["IDP"]!,
                                );
                              })).then((value) {
                                getVitalsList();
                              });
                            } else {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return SelectSugarTypeScreen(
                                    widget.patientIDP!);
                              })).then((value) {
                                getVitalsList();
                              });
                            }
                          },
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
                                      listVitalsDialog[index]["Name"]!,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ))));
                    }),
              ],
            )));
  }

  // Future<void> showDateRangePickerDialog() async {
  //   // final List<DateTime?>? listPicked = await DateRagePicker.showDatePicker(
  //   //     context: context,
  //   //     initialFirstDate: widget.fromDate,
  //   //     initialLastDate: widget.toDate,
  //   //     firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
  //   //     lastDate: DateTime.now(),
  //   //     handleOk: () {},
  //   //     handleCancel: () {});
  //   // if (listPicked!.length == 2) {
  //   //   widget.fromDate = listPicked[0]!;
  //   //   widget.toDate = listPicked[1]!;
  //   //   var formatter = new DateFormat('dd-MM-yyyy');
  //   //   widget.fromDateString = formatter.format(widget.fromDate);
  //   //   widget.toDateString = formatter.format(widget.toDate);
  //   //   widget.dateString =
  //   //       "${widget.fromDateString}  to  ${widget.toDateString}";
  //   //   setState(() {
  //   //     //setListsForTabs();
  //   //     getVitalsList();
  //   //   });
  //   //   //print(picked);
  //   // }
  //   // showCustomDateRangePicker(
  //   //   context,
  //   //   dismissible: true,
  //   //   minimumDate: DateTime.now().subtract(Duration(days: 365 * 100)),
  //   //   maximumDate: DateTime.now(),
  //   //   endDate: widget.toDate,
  //   //   startDate: widget.fromDate,
  //   //   backgroundColor: Colors.white,
  //   //   primaryColor: Colors.blue,
  //   //   onApplyClick: (start, end) {
  //   //     setState(() {
  //   //       widget.fromDate = start;
  //   //       widget.toDate = end;
  //   //       var formatter = new DateFormat('dd-MM-yyyy');
  //   //       widget.fromDateString = formatter.format(widget.fromDate);
  //   //       widget.toDateString = formatter.format(widget.toDate);
  //   //       widget.dateString =
  //   //       "${widget.fromDateString}  to  ${widget.toDateString}";
  //   //       getVitalsList();
  //   //       //print(picked);
  //   //     });
  //   //   },
  //   //   onCancelClick: () {
  //   //     setState(() {
  //   //       widget.fromDate = DateTime.now().subtract(Duration(days: 7));
  //   //       widget.toDate = DateTime.now();
  //   //       getVitalsList();
  //   //     });
  //   //   },
  //   // );
  // }

  Future<String?> getVitalsList() async {
    getVitalsListActual();
    return null;
    /*if (selectedVitalIDP == "1") {
      getVitalsListActualForBP1();
    } else {
      getVitalsListActual();
    }*/
  }

  void deleteTheVitalFromTheList(ModelGraphValues modelVitalList) async {
    String loginUrl = "${baseURL}patientVitalDelete.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new [];
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
        "VitalIDP" +
        "\"" +
        ":" +
        "\"" +
        modelVitalList.idp! +
        "\"" +
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
    pr!.hide();
    if (model.status == "OK") {
      getVitalsList();
    }
  }

  void deleteTheVitalFromTheListForBP1(
      ModelGraphValues modelVitalList, ModelGraphValues modelVitalList2) async {
    String loginUrl = "${baseURL}patientVitalDelete.php";
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new [];
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
        "VitalIDP" +
        "\"" +
        ":" +
        "\"" +
        modelVitalList.idp! +
        "\"" +
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
    if (model.status == "OK") {
      deleteTheVitalFromTheListForBP2(modelVitalList2);
    }
  }

  void deleteTheVitalFromTheListForBP2(ModelGraphValues modelVitalList) async {
    String loginUrl = "${baseURL}patientVitalDelete.php";
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
        "VitalIDP" +
        "\"" +
        ":" +
        "\"" +
        modelVitalList.idp! +
        "\"" +
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
    pr!.hide();
    if (model.status == "OK") {
      getVitalsList();
    }
  }

  // void getImageAndShare() async {
  //   RenderRepaintBoundary? boundary =
  //       globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  //   if(boundary ==null){
  //     debugPrint("got null boundary");
  //     return;
  //   }
  //   var image =
  //       await boundary.toImage(pixelRatio: vitalIDPGlobal == "3" ? 2.0 : 2.0);
  //   ByteData? pngBytes = await image.toByteData(format: ImageByteFormat.png);
  //   Directory tempDir = await getTemporaryDirectory();
  //   String tempPath = tempDir.path;
  //   imgFile = File('$tempPath/sharechart.png');
  //   imgFile?.writeAsBytesSync(pngBytes!.buffer.asUint8List());
  //   //setState(() {});
  //   //ShareExtend.share(imgFile.path, "file");
  //   //SimpleShare.share(uri: uri.toString());
  //   String imageName = '$tempPath/sharechart.png';
  //   shareFiles(context,imageName);
  //   // WcFlutterShare.share(
  //   //   sharePopupTitle: "Share Chart via",
  //   //   mimeType: 'image/png',
  //   //   fileName: "sharechart.png",
  //   //   bytesOfFile: pngBytes!.buffer.asUint8List(),
  //   // );
  // }

  Future<String?> getVitalsListForBP() async {
    debugPrint("Calling bp api");
    String loginUrl = "${baseURL}patientVitalsDataBPDoctor.php";
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new [];
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String fromDate = "";
    String toDate = "";
    if (widget.dateString != "Select Date Range") {
      fromDate = widget.fromDateString;
      toDate = widget.toDateString;
    }
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
        fromDate +
        "\"" +
        "," +
        "\"" +
        "ToDate" +
        "\"" +
        ":" +
        "\"" +
        toDate +
        "\"" +
        /*"," +
        "\"" +
        "VitalIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.vitalIDP2 +
        "\"" +*/
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
    debugPrint("Actual 2");
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    listVital = [];
    listVital2 = [];
    listVitalByWhom = [];
    widget.listVitals = [];
    listVitalOnlyString = [];
    listVitalOnlyStringDate = [];
    listVitalOnlyString2 = [];
    listVitalOnlyStringDate2 = [];

    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        var model = ModelVitalsList(
          widget.patientIDP!,
          jo['VitalIDP'],
          jo['VitalValue1'],
          jo['VitalValue2'],
          "",
          "",
          "",
          "",
          "",
          "",
          jo['VitalEntryDate'],
          jo['VitalEntryTime'],
          jo['VitalEntryTimeID'],
        );
        /*if (!widget.listVitals.contains(model))*/
        widget.listVitals.add(model);
        listVital.add(ModelGraphValues(
          jo['VitalEntryDate'],
          jo['VitalEntryTime'],
          jo['VitalValue1'],
          jo['VitalIDP1'],
        ));
        listVital2.add(ModelGraphValues(
          jo['VitalEntryDate'],
          jo['VitalEntryTime'],
          jo['VitalValue2'],
          jo['VitalIDP2'],
        ));
        String byWhom = "";
        if (jo['doctorentrystatus'] == "0")
          byWhom = "Entry by - Patient";
        else
          byWhom = "Entry by - Doctor";
        listVitalByWhom.add(byWhom);
        listVitalOnlyString.add(jo['VitalValue1']);
        listVitalOnlyString2.add(jo['VitalValue2']);
        debugPrint(
            "Entry date :- ${jo["VitalIDP1"]} ${jo["VitalIDP2"]} ${jo['VitalEntryDate']}");
        var date = model.vitalEntryDate;
        var time = model.vitalEntryTime;
        String year = date.split("-")[2];
        String month = date.split("-")[1];
        String day = date.split("-")[0];
        String hour = time.split(":")[0];
        String min = time.split(":")[1];
        var current = DateTime(int.parse(year), int.parse(month),
            int.parse(day), int.parse(hour), int.parse(min), 0, 0, 0);
        var formatter = new DateFormat('dd MMM HH:mm');
        listVitalOnlyStringDate.add("${formatter.format(current)}");
        listVitalOnlyStringDate2.add("${formatter.format(current)}");
      }
      if (widget.listVitals.length > 0)
        widget.shouldShowEmptyMessageWidget = false;
      else
        widget.shouldShowEmptyMessageWidget = true;
      debugPrint("Vitals list");
      debugPrint("1 - " + listVital.length.toString());
      debugPrint("2 - " + listVital2.length.toString());
      pr!.hide();
      setState(() {});
      /*if (widget.vitalIDP != "1" && widget.vitalIDP != "3") {*/
      //keyForChart.currentState.setStateInsideTheChart();
      setState(() {
        Future.delayed(Duration(milliseconds: 1500), () {
          setStateOfTheEChartWidget();
        });
        //setListsForTabs();
      });
      return 'success';
    }
    return null;
  }

  Future<String?> getVitalsListActual() async {
    String loginUrl = "${baseURL}patientVitalsDataDoctor.php";
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new [];
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String fromDate = "";
    String toDate = "";
    if (widget.dateString != "Select Date Range") {
      fromDate = widget.fromDateString;
      toDate = widget.toDateString;
    }
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
        fromDate +
        "\"" +
        "," +
        "\"" +
        "ToDate" +
        "\"" +
        ":" +
        "\"" +
        toDate +
        "\"" +
        "," +
        "\"" +
        "VitalIDP" +
        "\"" +
        ":" +
        "\"" +
        selectedVitalIDP +
        "\"" +
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
    debugPrint("Actual 1");
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    if (widget.vitalIDP != "1" && widget.vitalIDP != "3") pr!.hide();
    widget.listVitals = [];
    listVital = [];
    listPulse = [];
    listBPSystolic = [];
    listBPDiastolic = [];
    listTemperature = [];
    listSPO2 = [];
    listVitalByWhom = [];
    listVitalOnlyString = [];
    listVitalOnlyStringDate = [];

    pr!.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        var model = ModelVitalsList(
          widget.patientIDP!,
          jo['VitalIDP'],
          jo['VitalValue'],
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          jo['VitalEntryDate'],
          jo['VitalEntryTime'],
          jo['VitalEntryTimeID'],
        );
        /*if (!widget.listVitals.contains(model)) */
        widget.listVitals.add(model);
        listVital.add(ModelGraphValues(
          jo['VitalEntryDate'],
          jo['VitalEntryTime'],
          jo['VitalValue'],
          jo['VitalIDP'],
        ));
        String byWhom = "";
        if (jo['doctorentrystatus'] == "0")
          byWhom = "Entry by - Patient";
        else
          byWhom = "Entry by - Doctor";
        listVitalByWhom.add(byWhom);
        listVitalOnlyString.add(jo['VitalValue']);
        var date = model.vitalEntryDate;
        var time = model.vitalEntryTime;
        String year = date.split("-")[2];
        String month = date.split("-")[1];
        String day = date.split("-")[0];
        String hour = time.split(":")[0];
        String min = time.split(":")[1];
        var current = DateTime(int.parse(year), int.parse(month),
            int.parse(day), int.parse(hour), int.parse(min), 0, 0, 0);
        var formatter = new DateFormat('dd MMM HH:mm');
        listVitalOnlyStringDate.add("${formatter.format(current)}");
      }
      if (widget.listVitals.length > 0)
        widget.shouldShowEmptyMessageWidget = false;
      else
        widget.shouldShowEmptyMessageWidget = true;
      debugPrint("Vitals list");
      debugPrint(listVital.length.toString());
      setState(() {});
      /*if (widget.vitalIDP != "1" && widget.vitalIDP != "3") {*/
      //keyForChart.currentState.setStateInsideTheChart();
      //if (selectedVitalIDP == "1") getVitalsListActual2();
      setState(() {
        Future.delayed(Duration(milliseconds: 1500), () {
          setStateOfTheEChartWidget();
        });
        //setListsForTabs();
      });
      /*}*/
    }
    return null;
  }

  Future<String?> getVitalsListActualForBP1() async {
    String loginUrl = "${baseURL}patientVitalsDataDoctor.php";
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new [];
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String fromDate = "";
    String toDate = "";
    if (widget.dateString != "Select Date Range") {
      fromDate = widget.fromDateString;
      toDate = widget.toDateString;
    }
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
        fromDate +
        "\"" +
        "," +
        "\"" +
        "ToDate" +
        "\"" +
        ":" +
        "\"" +
        toDate +
        "\"" +
        "," +
        "\"" +
        "VitalIDP" +
        "\"" +
        ":" +
        "\"1\"" +
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
    debugPrint("Actual 1");
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    widget.listVitals = [];
    listVital = [];
    listPulse = [];
    listBPSystolic = [];
    listBPDiastolic = [];
    listTemperature = [];
    listSPO2 = [];
    listVitalByWhom = [];
    listVitalOnlyString = [];
    listVitalOnlyStringDate = [];

    pr!.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        var model = ModelVitalsList(
          widget.patientIDP!,
          jo['VitalIDP'],
          jo['VitalValue'],
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          jo['VitalEntryDate'],
          jo['VitalEntryTime'],
          jo['VitalEntryTimeID'],
        );
        /*if (!widget.listVitals.contains(model)) */
        widget.listVitals.add(model);
        listVital.add(ModelGraphValues(
          jo['VitalEntryDate'],
          jo['VitalEntryTime'],
          jo['VitalValue'],
          jo['VitalIDP'],
        ));
        String byWhom = "";
        if (jo['doctorentrystatus'] == "0")
          byWhom = "Entry by - Patient";
        else
          byWhom = "Entry by - Doctor";
        listVitalByWhom.add(byWhom);
        listVitalOnlyString.add(jo['VitalValue']);
        var date = model.vitalEntryDate;
        var time = model.vitalEntryTime;
        String year = date.split("-")[2];
        String month = date.split("-")[1];
        String day = date.split("-")[0];
        String hour = time.split(":")[0];
        String min = time.split(":")[1];
        var current = DateTime(int.parse(year), int.parse(month),
            int.parse(day), int.parse(hour), int.parse(min), 0, 0, 0);
        var formatter = new DateFormat('dd MMM HH:mm');
        listVitalOnlyStringDate.add("${formatter.format(current)}");
      }
      if (listVital.length > 0)
        widget.shouldShowEmptyMessageWidget = false;
      else
        widget.shouldShowEmptyMessageWidget = true;
      debugPrint("Vitals list");
      debugPrint(listVital.length.toString());
      getVitalsListActualForBP2();
    }
    return null;
  }

  Future<String?> getVitalsListActualForBP2() async {
    String loginUrl = "${baseURL}patientVitalsDataDoctor.php";
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new [];
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String fromDate = "";
    String toDate = "";
    if (widget.dateString != "Select Date Range") {
      fromDate = widget.fromDateString;
      toDate = widget.toDateString;
    }
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
        fromDate +
        "\"" +
        "," +
        "\"" +
        "ToDate" +
        "\"" +
        ":" +
        "\"" +
        toDate +
        "\"" +
        "," +
        "\"" +
        "VitalIDP" +
        "\"" +
        ":" +
        "\"2\"" +
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
    debugPrint("Actual 1");
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    widget.listVitals = [];
    listVital2 = [];
    listPulse = [];
    listBPSystolic = [];
    listBPDiastolic = [];
    listTemperature = [];
    listSPO2 = [];
    listVitalByWhom2 = [];
    listVitalOnlyString2 = [];
    listVitalOnlyStringDate2 = [];

    pr!.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        var model = ModelVitalsList(
          widget.patientIDP!,
          jo['VitalIDP'],
          jo['VitalValue'],
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          jo['VitalEntryDate'],
          jo['VitalEntryTime'],
          jo['VitalEntryTimeID'],
        );
        /*if (!widget.listVitals.contains(model)) */
        widget.listVitals.add(model);
        listVital2.add(ModelGraphValues(
          jo['VitalEntryDate'],
          jo['VitalEntryTime'],
          jo['VitalValue'],
          jo['VitalIDP'],
        ));
        String byWhom = "";
        if (jo['doctorentrystatus'] == "0")
          byWhom = "Entry by - Patient";
        else
          byWhom = "Entry by - Doctor";
        listVitalByWhom2.add(byWhom);
        listVitalOnlyString2.add(jo['VitalValue']);
        var date = model.vitalEntryDate;
        var time = model.vitalEntryTime;
        String year = date.split("-")[2];
        String month = date.split("-")[1];
        String day = date.split("-")[0];
        String hour = time.split(":")[0];
        String min = time.split(":")[1];
        var current = DateTime(int.parse(year), int.parse(month),
            int.parse(day), int.parse(hour), int.parse(min), 0, 0, 0);
        var formatter = new DateFormat('dd MMM HH:mm');
        listVitalOnlyStringDate2.add("${formatter.format(current)}");
      }
      if (listVital2.length > 0)
        widget.shouldShowEmptyMessageWidget = false;
      else
        widget.shouldShowEmptyMessageWidget = true;
      debugPrint("Vitals list");
      debugPrint(listVital2.length.toString());
      setState(() {
        Future.delayed(Duration(milliseconds: 1500), () {
          setStateOfTheEChartWidget();
        });
        //setListsForTabs();
      });
      /*}*/
    }
    return null;
  }

  void setStateOfTheEChartWidget() {
    //if (widget.vitalIDP == "3") {
    if (keyForChart == null)
      debugPrint("key null- chart 1 idp - 3");
    else if (keyForChart?.currentState == null)
      debugPrint("currentState null- chart 1 idp - 3");
    else {
      debugPrint("nothing null, setting state of chart - chart 1 idp - 3");
      keyForChart?.currentState?.setStateInsideTheChart();
    }

    if (selectedVitalIDP == "1") {
      if (keyForChart2 == null)
        debugPrint("key null- chart 1 idp - 3");
      else if (keyForChart2?.currentState == null)
        debugPrint("currentState null- chart 1 idp - 3");
      else {
        debugPrint("nothing null, setting state of chart - chart 1 idp - 3");
        keyForChart2?.currentState?.setStateInsideTheChart();
      }
    }
  }

  String getSelectionVitalIDP() {
    if (selectedVitalIDP == "1" || selectedVitalIDP == "2")
      return "1";
    else if (selectedVitalIDP == "3" ||
        selectedVitalIDP == "4" ||
        selectedVitalIDP == "5" ||
        selectedVitalIDP == "10")
      return "2";
    else if (selectedVitalIDP == "6" ||
        selectedVitalIDP == "7" ||
        selectedVitalIDP == "8" ||
        selectedVitalIDP == "9") {
      /*Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return AddVitalsScreen(
          widget.patientIDP,
          selectedVitalIDP,
        );
      })).then((value) {
        getVitalsList();
      });*/
      return "3";
    } else if (selectedVitalIDP == "11" ||
        selectedVitalIDP == "21" ||
        selectedVitalIDP == "12")
      return "4";
    else if (selectedVitalIDP == "13" || selectedVitalIDP == "14")
      return "5";
    else if (selectedVitalIDP == "15" ||
        selectedVitalIDP == "16" ||
        selectedVitalIDP == "17" ||
        selectedVitalIDP == "18" ||
        selectedVitalIDP == "19")
      return "6";
    else if (selectedVitalIDP == "20") {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return WaterIntakeScreen(
          widget.patientIDP!,
        );
      })).then((value) {
        getVitalsList();
      });
      return "";
    }
    return "";
  }

  double getValueFromVitalIDP(String selectedVitalIDP) {
    switch (selectedVitalIDP) {
      case "1":
        return bpSystolicValue.toDouble();
        break;
      case "2":
        return bpDiastolicValue.toDouble();
        break;
      case "3":
        return pulseValue.toDouble();
        break;
      case "4":
        return tempValue.toDouble();
        break;
      case "5":
        return spo2Value.toDouble();
        break;
      case "10":
        return rrValue.toDouble();
        break;
      case "6":
        return fbsValue.toDouble();
        break;
      case "7":
        return ppbsValue.toDouble();
        break;
      case "8":
        return rbsValue.toDouble();
        break;
      case "9":
        return hba1cValue.toDouble();
        break;
      case "11":
        return weightValue.toDouble();
        break;
      case "21":
        return heightValue.toDouble();
        break;
      case "12":
        return 0;
        break;
      default:
        return 0;
    }
  }

  void getVitalCategories() async {
    String loginUrl = "${baseURL}vitalDataNames.php";
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
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
      headers: {
        "u": patientUniqueKey,
        "type": userType,
      },
      body: {"getjson": encodedJSONStr},
    );
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    debugPrint("response :" + response.body.toString());
    debugPrint("Data :" + model.data!);
    listVitalCategories = [];
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);
      if (jsonData.length > 0) {
        for (int i = 0; i < jsonData.length; i++) {
          final jo = jsonData[i];
          listVitalCategories.add({
            "Name": jo['VitalName'],
            "IDP": jo['VitalMasterIDP'].toString(),
            "Unit": getUnitFromVitalIDP(jo['VitalMasterIDP'].toString()),
          });
        }
        if (listVitalCategories.length > 0) {
          if (widget.selectedSubCategoryIDP == "" ||
              widget.selectedSubCategoryIDP == "1") {
            getVitalsList();
          } else {
            selectedVitalIDP = widget.selectedSubCategoryIDP!;
            for (int i = 0; i < listVitalCategories.length; i++) {
              if (listVitalCategories[i]["IDP"] == selectedVitalIDP) {
                selectedVitalName = listVitalCategories[i]["Name"]!;
                selectedUnit = listVitalCategories[i]["Unit"]!;
                chipListController.scrollToIndex(i,
                    preferPosition: AutoScrollPosition.begin);
                getVitalsList();
                break;
              }
            }
          }
        }
      }
      pr!.hide();
      setState(() {});
    } else {
      pr!.hide();
      setState(() {});
    }
  }

  String getUnitFromVitalIDP(String vitalIDP) {
    switch (vitalIDP) {
      case "1":
        return "mm of hg";
      case "2":
        return "mm of hg";
      case "3":
        return "per min.";
      case "4":
        return "\u2109";
      case "5":
        return "%";
      case "10":
        return "per min.";
      case "11":
        return "kg";
      case "21":
        return "cm";
      case "12":
        return "Kg/m\u00B2";
      case "13":
        return "Mins.";
      case "14":
        return "Steps";
      case "20":
        return "ml";
      case "22":
        return "Hours";
      case "23":
        return "cm";
      case "24":
        return "cm";
      default:
        return "";
    }
    listVitalCategories = [];
    listVitalCategories
        .add({"Name": "BP Systolic", "IDP": "1", "Unit": "mm of hg"});
    listVitalCategories
        .add({"Name": "BP Diastolic", "IDP": "2", "Unit": "mm of hg"});
    /*listVitalCategories.add({"Name": "BP Diastolic", "IDP": "2"});*/
    listVitalCategories.add({"Name": "Pulse", "IDP": "3", "Unit": "per min."});
    listVitalCategories
        .add({"Name": "Temperature", "IDP": "4", "Unit": "\u2109"});
    listVitalCategories.add({"Name": "SPO2", "IDP": "5", "Unit": "%"});
    listVitalCategories
        .add({"Name": "Respiratory Rate", "IDP": "10", "Unit": "per min."});
    listVitalCategories.add({"Name": "FBS", "IDP": "6", "Unit": "mg/dl"});
    listVitalCategories.add({"Name": "PPBS", "IDP": "7", "Unit": "mg/dl"});
    listVitalCategories.add({"Name": "RBS", "IDP": "8", "Unit": "mg/dl"});
    listVitalCategories.add({"Name": "HbA1C", "IDP": "9", "Unit": "mg/dl"});
    listVitalCategories.add({"Name": "Weight", "IDP": "11", "Unit": "kg"});
    listVitalCategories.add({"Name": "Height", "IDP": "21", "Unit": "cm"});
    listVitalCategories.add({"Name": "BMI", "IDP": "12", "Unit": "Kg/m\u00B2"});
    listVitalCategories.add({"Name": "Exercise", "IDP": "13", "Unit": "Mins."});
    listVitalCategories.add({"Name": "Walking", "IDP": "14", "Unit": "Steps"});
    listVitalCategories.add({"Name": "TSH", "IDP": "15", "Unit": "uIU/mL"});
    listVitalCategories.add({"Name": "T3", "IDP": "16", "Unit": "ng/dL"});
    listVitalCategories.add({"Name": "T4", "IDP": "17", "Unit": "ug/dL"});
    listVitalCategories.add({"Name": "FreeT3", "IDP": "18", "Unit": "pg/mL"});
    listVitalCategories.add({"Name": "FreeT4", "IDP": "19", "Unit": "ng/dL"});
    listVitalCategories
        .add({"Name": "Water Intake", "IDP": "20", "Unit": "ml"});
  }
}

class MyEChart extends StatefulWidget {
  String? chartTypeID, titleOfChart, selectedVitalIDP;
  int? minValue;
  double? value;

  MyEChart(
      {Key? key,
      this.chartTypeID,
      this.titleOfChart,
      this.selectedVitalIDP,
      this.minValue,
      this.value})
      : super(key: key);

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
  int minYValue = 0;
  String minValueStr = "0";

  /*@override
  void dispose() {
    yAxisData = StringBuffer();
    xAxisDatesData = StringBuffer();
    yAxisData2 = StringBuffer();

    listOnlyString = [];
    listOnlyDate = [];
    super.dispose();
  }*/

  get byWhomList {
    if (widget.chartTypeID == "1")
      return listVitalByWhom;
    else
      return listVitalByWhom2;
  }

  void setStateInsideTheChart() {
    debugPrint("Let's set chart state");
    yAxisData = StringBuffer();
    yAxisData2 = StringBuffer();
    xAxisDatesData = StringBuffer();

    if (widget.chartTypeID == "1") {
      color = "'rgb(255, 0, 0)'";
      colorRGB = Color.fromRGBO(255, 0, 0, 1);
    } else if (widget.chartTypeID == "2") {
      color = "'rgb(0, 145, 234)'";
      colorRGB = Color.fromRGBO(0, 0, 255, 1);
    } else if (widget.chartTypeID == "3") {
      color = "'rgb(50, 205, 50)'";
      colorRGB = Color.fromRGBO(50, 205, 50, 1);
    } else if (widget.chartTypeID == "4") {
      color = "'rgb(150, 125, 105)'";
      colorRGB = Color.fromRGBO(150, 125, 105, 1);
    }

    series =
        "[{data: $yAxisData,type: 'line',symbol: 'circle',symbolSize: 8,smooth: true,itemStyle: {color: $color},},]";

    if (widget.chartTypeID == "1" || widget.chartTypeID == "5") {
      listOnlyString = listVitalOnlyString;
      listOnlyDate = listVitalOnlyStringDate;
    } else if (widget.chartTypeID == "2") {
      listOnlyString = listVitalOnlyString2;
      listOnlyDate = listVitalOnlyStringDate2;
    }
    /*else if (widget.chartTypeID == "3") {
      listOnlyString = listVitalOnlyString3;
      listOnlyDate = listVitalOnlyStringDate3;
    } else if (widget.chartTypeID == "4") {
      listOnlyString = listVitalOnlyString4;
      listOnlyDate = listVitalOnlyStringDate4;
    }*/

    List<int> listOnlyInt = [];
    for (int i = 0; i < listOnlyString.length; i++) {
      listOnlyInt.add(double.parse(listOnlyString[i]).round().toInt());
    }

    if (listOnlyInt.length > 0)
      minYValue = listOnlyInt.reduce((curr, next) => curr < next ? curr : next);

    if (listOnlyString.length > 1) {
      for (int i = 0; i < listOnlyString.length; i++) {
        if (i == 0)
          yAxisData.write(
              "[{value:${double.parse(listOnlyString[i]).round().toInt()},name:'${byWhomList[i]}'},");
        else if (i == listOnlyString.length - 1)
          yAxisData.write(
              "{value:${double.parse(listOnlyString[i]).round().toInt()},name:'${byWhomList[i]}'}]");
        else
          yAxisData.write(
              "{value:${double.parse(listOnlyString[i]).round().toInt()},name:'${byWhomList[i]}'},");

        if (i == 0)
          xAxisDatesData.write("['${listOnlyDate[i]}',");
        else if (i == listOnlyDate.length - 1)
          xAxisDatesData.write("'${listOnlyDate[i]}']");
        else
          xAxisDatesData.write("'${listOnlyDate[i]}',");
      }
    } else if (listOnlyString.length == 1) {
      yAxisData.write(
          "[{value:${double.parse(listOnlyString[0]).round().toInt()},name:'${byWhomList[0]}'}]");
      xAxisDatesData.write("['${listOnlyDate[0]}']");
    }

    if (widget.chartTypeID == "5") {
      for (int i = 0; i < listVitalOnlyString2.length; i++) {
        listOnlyInt.add(double.parse(listVitalOnlyString2[i]).round().toInt());
      }
      if (listOnlyInt.length > 0)
        minYValue =
            listOnlyInt.reduce((curr, next) => curr < next ? curr : next);
      if (listVitalOnlyString2.length > 1) {
        for (int i = 0; i < listVitalOnlyString2.length; i++) {
          if (i == 0)
            yAxisData2.write(
                "[{value:${double.parse(listVitalOnlyString2[i]).round().toInt()},name:'${byWhomList[i]}'},");
          else if (i == listVitalOnlyString2.length - 1)
            yAxisData2.write(
                "{value:${double.parse(listVitalOnlyString2[i]).round().toInt()},name:'${byWhomList[i]}'}]");
          else
            yAxisData2.write(
                "{value:${double.parse(listVitalOnlyString2[i]).round().toInt()},name:'${byWhomList[i]}'},");
        }
      } else if (listOnlyString.length == 1) {
        yAxisData2.write(
            "[{value:${double.parse(listVitalOnlyString2[0]).round().toInt()},name:'${byWhomList[0]}'}]");
      }
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
    if (widget.titleOfChart!.toLowerCase().startsWith("spo2")) {
      minValueStr = minYValue.toString();
    } else {
      minValueStr = widget.value.toString();
    }
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
                            boundaryGap: false,
                            min: $minValueStr,
                          },
                          legend: {
                            show: true,
                            data: [{name: '${widget.titleOfChart}', icon: 'square', textStyle: {color: $color}}]
                          },
                          series: [{data: $yAxisData,type: 'line',symbol: 'circle',symbolSize: 8,smooth: true,itemStyle: {color: $color},name:'${widget.titleOfChart}'}]
                        }
                        ''',

                        /*title: {
          text: 'BP',
          show: true
        },*/
                        //,name:'BP'
                      )
                    : EchartsCustom(
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
                            var byWhom;
                            let rez = params[0].axisValue + '</br>';
                            //console.log(params); //quite useful for debug
                            params.forEach(item => {
                            //console.log(item); //quite useful for debug
                            var xx = colorSpan(item.color) + ' ' + item.seriesName + ': ' + item.data.value + '</br>'
                            rez += xx;
                            byWhom = item.data.name;
                            });
                            rez += '---' + '</br>' + colorSpanDoctor(byWhom);
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
                      boundaryGap: false,
                      min: ${widget.value.toString()},
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
              ) /*)*/
            : Container() /*SizedBox(
            width: SizeConfig.screenWidth,
            height: SizeConfig.blockSizeVertical * 60,
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage("images/ic_no_result_found.png"),
                    width: 200,
                    height: SizeConfig.blockSizeVertical * 60,
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  Text(
                    "No Graph Data.",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
            ),
          )*/
        ;
  }
}
