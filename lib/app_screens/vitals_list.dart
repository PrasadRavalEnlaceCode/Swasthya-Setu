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
import 'package:silvertouch/api/api_helper.dart';
import 'package:silvertouch/app_screens/add_vital_screen.dart';
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
import 'package:silvertouch/utils/fontstyle.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import '../utils/color.dart';

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

//  Continue from here
List<ModelGraphValues> listVital2 = [];
List<ModelGraphValues> listVital3 = [];
List<ModelGraphValues> listVital4 = [];
List<ModelGraphValues> listVital5 = [];
List<ModelGraphValues> listAllVital = [];

List<String> listVitalByWhom = [];
List<String> listVital2ByWhom = [];
List<String> listVital3ByWhom = [];
List<String> listVital4ByWhom = [];
List<String> listVital5ByWhom = [];

List<String> listChartType = [];

List<String> listVitalOnlyString = [];
List<String> listVitalOnlyString2 = [];
List<String> listVitalOnlyString3 = [];
List<String> listVitalOnlyString4 = [];
List<String> listVitalOnlyString5 = [];

List<String> listVitalOnlyStringDate = [];
List<String> listVitalOnlyStringDate2 = [];
List<String> listVitalOnlyStringDate3 = [];
List<String> listVitalOnlyStringDate4 = [];
List<String> listVitalOnlyStringDate5 = [];

var chartType = "";

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
    walkingStepsValue = 0,
    sleepValue = 0;

double tempValue = 94;

double bmi = 0;

var selectedGradientColors = [
  Colors.white,
  Colors.red,
  Colors.black,
];

var notSelectedGradientColors = [
  Colors.white,
  Color(0xFF636F7B),
  Colors.black,
];

String titleGlobal = "";

GlobalKey globalKey = GlobalKey();
File? imgFile;
String? vitalIDPGlobal;
GlobalKey<MyEChartState>? keyForChart = GlobalKey();
GlobalKey<MyEChartState>? keyForChart2 = GlobalKey();
GlobalKey<MyEChartState>? keyForChart3 = GlobalKey();
GlobalKey<MyEChartState>? keyForChart4 = GlobalKey();
GlobalKey<MyEChartState>? keyForChart5 = GlobalKey();

class VitalsListScreen extends StatefulWidget {
  List<ModelVitalsList?>? listVitals = [];
  String? patientIDP = "";
  String? vitalIDP = "",
      vitalIDP2 = "",
      vitalIDP3 = "",
      vitalIDP4 = "",
      vitalIDP5 = "";
  String? vitalGroupIDP = "";
  String? unit = "", unit2 = "", unit3 = "", unit4 = "", unit5 = "";
  DropDownItem? selectedCountry = DropDownItem("", "");
  DropDownItem? selectedState = DropDownItem("", "");
  DropDownItem? selectedCity = DropDownItem("", "");

  var fromDate = DateTime.now().subtract(Duration(days: 7));
  var toDate = DateTime.now();

  var fromDateString = "";
  var toDateString = "";
  var dateString = "Select Date Range";

  var mainType = "chart";
  late DateTimeRange dateRange;

  ProgressDialog? pr;

  /*String emptyTextBP1 =
      "Blood Pressure monitorig is very necessery on regular basis.";
  String emptyTextBP2 =
      "Monitor your Blood Pressure regularly and share to your doctor very easily.";
  String emptyTextBP3 =
      "Monitor and record your Blood Pressure values as B.P. Systolic and B.P. Diastolic by selecting PLUS button from the bottom of screen.";*/

  String? emptyTextBP1 = "Sit up right";
  String? emptyTextBP2 = "Back supported";
  String? emptyTextBP3 = "Bp instrument at the level of heart";
  String? emptyTextBP4 = "It is important to Measure regularly.";

  /*String emptyTextSugar1 =
      "Blood sugar monitoring is very necessery to maintain your health.";
  String emptyTextSugar2 =
      "Monitor your Blood sugar level regularly and share to your doctor very easily.";
  String emptyTextSugar3 =
      "Monitor and record your Blood Sugar values as Fasting Sugar (FBS), Sugar after Lunch (PPBS), RBS, HbA1C by selecting PLUS button from the bottom od screen.";*/

  String? emptyTextSugar1 = "FBS (Fasting Blood Sugar) : 8-10 hrs. of Fasting.";
  String? emptyTextSugar2 =
      "PPBS (Post Prandial Blood Sugar) : After 2 hours of Proper Lunch.";
  String? emptyTextSugar3 = "RBS (Random Blood Sugar) : At any random time.";
  String? emptyTextSugar4 =
      "HbA1C (Hemoglobin A1C) : Average Sugar control of last 90 days.";

  String? emptyTextVitals1 =
      "Monitor your Vitals regularly and share to your doctor very easily.";
  String? emptyTextVitals2 =
      "Monitor and record your Vitals values of Pluse Rate, Temperature, SPO2 (Oxygen Saturation), Respiratory rate by selecting PLUS button from the bottom od screen.";

  String? emptyTextWeight =
      "You can measure your Weight and Height regularly and can share your details to your doctor anytime.";

  String? emptyTextExercise =
      "You can Track the exercises and how many steps you walked.";

  String? emptyTextThyroid =
      "You can Add Your Thyroid Data. Kindly click on Plus icon to add one.";

  String? emptyTextWaterIntake =
      "You can Add Your Water Intake Data. Kindly click on Plus icon to add one.";

  String? emptyTextSleep =
      "You can track how many hours you sleep every night.";

  /*String emptyTextVitals1 =  "- Monitor your Vitals regularly and share to your doctor very easily.";
  String emptyTextVitals2 ="- Monitor and record your Vitals values of Pluse Rate, Temperature, SPO2 (Oxygen Saturation), Respiratory rate by selecting PLUS button from the bottom od screen.";*/

  String? emptyMessage = "";

  Widget? emptyMessageWidget;

  Widget? emptyMessageWidgetFBS;
  Widget? emptyMessageWidgetPPBS;
  Widget? emptyMessageWidgetRBS;
  Widget? emptyMessageWidgetHbA1C;

  bool? shouldShowEmptyMessageWidget = true;

  VitalsListScreen(String patientIDP, String vitalIDP) {
    this.patientIDP = patientIDP;
    this.vitalIDP = vitalIDP;
    this.vitalGroupIDP = vitalIDP;
    vitalIDPGlobal = vitalIDP;
  }

  @override
  State<StatefulWidget> createState() {
    return VitalsListScreenState();
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

class VitalsListScreenState extends State<VitalsListScreen> {
  ScrollController? hideFABController;
  var isFABVisible = true;
  String title = "";
  String title1 = "";
  String title2 = "";
  String title3 = "";
  String title4 = "";
  String title5 = "";

  List<Widget> listBPTabsWidgets = [];
  List<Widget> listVitalsTabsWidgets = [];
  List<Widget> listWeightHeightTabsWidgets = [];
  List<Widget> listThyroidTabsWidgets = [];
  List<String> listVitalIDPs = [];
  var fromDate = DateTime.now().subtract(Duration(days: 7));
  var toDate = DateTime.now();

  int vitalsAPICount = 0;
  ApiHelper apiHelper = ApiHelper();

  List<DropDownItem> listCategories = [];
  String selectedCategoryIDP = "0";
  String selectedCategory = "";
  late DateTimeRange dateRange;
  var fromDateString = "";
  var toDateString = "";

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
      fromDateString = formatter.format(fromDate);
      toDateString = formatter.format(toDate);
      setListsForTabs();
      getVitalsList();
    });
  }

  @override
  void dispose() {
    keyForChart = null;
    keyForChart2 = null;
    keyForChart3 = null;
    keyForChart4 = null;
    keyForChart5 = null;
    listVital = [];
    listVital2 = [];
    listVital3 = [];
    listVital4 = [];
    listVital5 = [];
    widget.listVitals = [];
    listVitalOnlyString = [];
    listVitalOnlyString2 = [];
    listVitalOnlyString3 = [];
    listVitalOnlyString4 = [];
    listVitalOnlyString5 = [];
    listVitalOnlyStringDate = [];
    listVitalOnlyStringDate2 = [];
    listVitalOnlyStringDate3 = [];
    listVitalOnlyStringDate4 = [];
    listVitalOnlyStringDate5 = [];
    super.dispose();
  }

  void setListsForTabs() {
    listBPTabsWidgets = [
      widget.vitalGroupIDP == "1"
          ? widget.listVitals!.length > 0
              ? ListView.builder(
                  padding: const EdgeInsets.only(
                      bottom: kFloatingActionButtonMargin + 60),
                  itemCount: widget.listVitals!.length,
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
                                        width: 1.0, color: Color(0xFF636F7B)),
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
                                    padding: EdgeInsets.all(5.0),
                                    child: Container(
                                      /*decoration: BoxDecoration(
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        borderRadius: BorderRadius.circular(35),
                                      ),*/
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    "${widget.listVitals![index]!.vitalEntryDate} (",
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: SizeConfig
                                                              .blockSizeVertical! *
                                                          2.3,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${widget.listVitals![index]!.vitalEntryTime})",
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: SizeConfig
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
                                                alignment: Alignment.topLeft,
                                                child: Row(
                                                  children: [
                                                    Column(
                                                      children: <Widget>[
                                                        Text(
                                                          widget.vitalGroupIDP ==
                                                                  "2"
                                                              ? "Pulse"
                                                              : (widget.vitalGroupIDP ==
                                                                      "1"
                                                                  ? "BP Systolic"
                                                                  : title1),
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF636F7B),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: SizeConfig
                                                                    .blockSizeVertical! *
                                                                2.1,
                                                          ),
                                                        ),
                                                        Text(
                                                          "${listVital[index].value} (${widget.unit})",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF636F7B),
                                                            fontSize: SizeConfig
                                                                    .blockSizeVertical! *
                                                                2.1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: <Widget>[
                                                        Text(
                                                          "Entry By",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF636F7B),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: SizeConfig
                                                                    .blockSizeVertical! *
                                                                2.1,
                                                          ),
                                                        ),
                                                        Text(
                                                          listVital[index]
                                                              .byWhom!,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF636F7B),
                                                            fontSize: SizeConfig
                                                                    .blockSizeVertical! *
                                                                2.1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Row(
                                                  children: [
                                                    Column(
                                                      children: <Widget>[
                                                        Text(
                                                          widget.vitalGroupIDP ==
                                                                  "1"
                                                              ? "BP Diastolic"
                                                              : "$title2 (${widget.unit2})",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF636F7B),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: SizeConfig
                                                                    .blockSizeVertical! *
                                                                2.1,
                                                          ),
                                                        ),
                                                        Text(
                                                          "${listVital2[index].value} (${widget.unit2})",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF636F7B),
                                                            fontSize: SizeConfig
                                                                    .blockSizeVertical! *
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
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF636F7B),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: SizeConfig
                                                                    .blockSizeVertical! *
                                                                2.1,
                                                          ),
                                                        ),
                                                        Text(
                                                          listVital[index]
                                                              .byWhom!,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF636F7B),
                                                            fontSize: SizeConfig
                                                                    .blockSizeVertical! *
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
                                              alignment: Alignment.centerRight,
                                              child: InkWell(
                                                onTap: () {
                                                  deleteTheVitalFromTheListForBP1(
                                                      listVital[index],
                                                      listVital2[index]);
                                                },
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )))));
                  })
              : widget.emptyMessageWidget!
          : widget.listVitals!.length > 0
              ? ListView.builder(
                  padding: const EdgeInsets.only(
                      bottom: kFloatingActionButtonMargin + 60),
                  itemCount: listVital.length,
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
                                        width: 1.0, color: Color(0xFF636F7B)),
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
                                    padding: EdgeInsets.all(5.0),
                                    child: Container(
                                      /*decoration: BoxDecoration(
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        borderRadius: BorderRadius.circular(35),
                                      ),*/
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    "${listVital[index].date} (",
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: SizeConfig
                                                              .blockSizeVertical! *
                                                          2.3,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${listVital[index].time})",
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: SizeConfig
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
                                                alignment: Alignment.topLeft,
                                                child: Row(
                                                  children: [
                                                    Column(
                                                      children: <Widget>[
                                                        Text(
                                                          widget.vitalGroupIDP ==
                                                                  "2"
                                                              ? "Pulse"
                                                              : (widget.vitalGroupIDP ==
                                                                      "1"
                                                                  ? "BP Systolic"
                                                                  : title1),
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF636F7B),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: SizeConfig
                                                                    .blockSizeVertical! *
                                                                2.1,
                                                          ),
                                                        ),
                                                        Text(
                                                          " -  ${listVital[index].value} (${widget.unit})",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF636F7B),
                                                            fontSize: SizeConfig
                                                                    .blockSizeVertical! *
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
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF636F7B),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: SizeConfig
                                                                    .blockSizeVertical! *
                                                                2.1,
                                                          ),
                                                        ),
                                                        Text(
                                                          listVital[index]
                                                              .byWhom!,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF636F7B),
                                                            fontSize: SizeConfig
                                                                    .blockSizeVertical! *
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
                                              alignment: Alignment.centerRight,
                                              child: InkWell(
                                                onTap: () {
                                                  deleteTheVitalFromTheList(
                                                      listVital[index]);
                                                },
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )))));
                  })
              : widget.emptyMessageWidget!,
      listVital2.length > 0
          ? ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: kFloatingActionButtonMargin + 60),
              itemCount: listVital2.length,
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
                                    width: 1.0, color: Color(0xFF636F7B)),
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
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  /*decoration: BoxDecoration(
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        borderRadius: BorderRadius.circular(35),
                                      ),*/
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${listVital2[index].date} (",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                              Text(
                                                "${listVital2[index].time})",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    0.8,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: <Widget>[
                                                    Text(
                                                      widget.vitalGroupIDP ==
                                                              "2"
                                                          ? "Temperature"
                                                          : (widget.vitalGroupIDP ==
                                                                  "1"
                                                              ? "BP Diastolic"
                                                              : (widget.vitalGroupIDP ==
                                                                      "5"
                                                                  ? title2
                                                                  : title)),
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${listVital2[index].value} (${widget.unit2})",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      listVital2[index].byWhom!,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              deleteTheVitalFromTheList(
                                                  listVital2[index]);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )))));
              })
          : widget.emptyMessageWidget!,
    ];

    listVitalsTabsWidgets = [
      listVital.length > 0
          ? ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: kFloatingActionButtonMargin + 60),
              itemCount: listVital.length,
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
                                    width: 1.0, color: Color(0xFF636F7B)),
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
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  /*decoration: BoxDecoration(
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        borderRadius: BorderRadius.circular(35),
                                      ),*/
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${listVital[index].date} (",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                              Text(
                                                "${listVital[index].time})",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    0.8,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: <Widget>[
                                                    Text(
                                                      widget.vitalGroupIDP ==
                                                              "2"
                                                          ? "Pulse"
                                                          : widget.vitalGroupIDP ==
                                                                  "3"
                                                              ? "FBS"
                                                              : (widget.vitalGroupIDP ==
                                                                      "1"
                                                                  ? "BP Systolic"
                                                                  : title1),
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${listVital[index].value} (${widget.unit})",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      listVital[index].byWhom!,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              deleteTheVitalFromTheList(
                                                  listVital[index]);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )))));
              })
          : widget.emptyMessageWidget!,
      listVital2.length > 0
          ? ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: kFloatingActionButtonMargin + 60),
              itemCount: listVital2.length,
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
                                    width: 1.0, color: Color(0xFF636F7B)),
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
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  /*decoration: BoxDecoration(
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        borderRadius: BorderRadius.circular(35),
                                      ),*/
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${listVital2[index].date} (",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                              Text(
                                                "${listVital2[index].time})",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    0.8,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: <Widget>[
                                                    Text(
                                                      widget.vitalGroupIDP ==
                                                              "2"
                                                          ? "Temperature"
                                                          : widget.vitalGroupIDP ==
                                                                  "3"
                                                              ? "PPBS"
                                                              : "BP Diastolic",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${listVital2[index].value} (${widget.unit2})",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      listVital2[index].byWhom!,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              deleteTheVitalFromTheList(
                                                  listVital2[index]);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )))));
              })
          : widget.emptyMessageWidget!,
      listVital3.length > 0
          ? ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: kFloatingActionButtonMargin + 60),
              itemCount: listVital3.length,
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
                                    width: 1.0, color: Color(0xFF636F7B)),
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
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  /*decoration: BoxDecoration(
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        borderRadius: BorderRadius.circular(35),
                                      ),*/
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${listVital3[index].date} (",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                              Text(
                                                "${listVital3[index].time})",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    0.8,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: <Widget>[
                                                    Text(
                                                      title3,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${listVital3[index].value} (${widget.unit3})",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      listVital3[index].byWhom!,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              deleteTheVitalFromTheList(
                                                  listVital3[index]);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )))));
              })
          : widget.emptyMessageWidget!,
      listVital4.length > 0
          ? ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: kFloatingActionButtonMargin + 60),
              itemCount: listVital4.length,
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
                                    width: 1.0, color: Color(0xFF636F7B)),
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
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  /*decoration: BoxDecoration(
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        borderRadius: BorderRadius.circular(35),
                                      ),*/
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${listVital4[index].date} (",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                              Text(
                                                "${listVital4[index].time})",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    0.8,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: <Widget>[
                                                    Text(
                                                      title4,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${listVital4[index].value} (${widget.unit4})",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      listVital4[index].byWhom!,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              deleteTheVitalFromTheList(
                                                  listVital4[index]);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )))));
              })
          : widget.emptyMessageWidget!,
    ];

    listThyroidTabsWidgets = [
      listVital.length > 0
          ? ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: kFloatingActionButtonMargin + 60),
              itemCount: listVital.length,
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
                                    width: 1.0, color: Color(0xFF636F7B)),
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
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  /*decoration: BoxDecoration(
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        borderRadius: BorderRadius.circular(35),
                                      ),*/
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${listVital[index].date} (",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                              Text(
                                                "${listVital[index].time})",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    0.8,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: <Widget>[
                                                    Text(
                                                      widget.vitalGroupIDP ==
                                                              "2"
                                                          ? "Pulse"
                                                          : widget.vitalGroupIDP ==
                                                                  "3"
                                                              ? "RBS"
                                                              : (widget.vitalGroupIDP ==
                                                                      "2"
                                                                  ? "BP Systolic"
                                                                  : title1),
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      " -  ${listVital[index].value} (${widget.unit})",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: <Widget>[
                                                    Text(
                                                      "Entry By",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      listVital[index].byWhom!,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              deleteTheVitalFromTheList(
                                                  listVital[index]);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )))));
              })
          : widget.emptyMessageWidget!,
      listVital2.length > 0
          ? ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: kFloatingActionButtonMargin + 60),
              itemCount: listVital2.length,
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
                                    width: 1.0, color: Color(0xFF636F7B)),
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
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  /*decoration: BoxDecoration(
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        borderRadius: BorderRadius.circular(35),
                                      ),*/
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${listVital2[index].date} (",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                              Text(
                                                "${listVital2[index].time})",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    0.8,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: <Widget>[
                                                    Text(
                                                      widget.vitalGroupIDP ==
                                                              "2"
                                                          ? "Temperature"
                                                          : widget.vitalGroupIDP ==
                                                                  "3"
                                                              ? "HbA1C"
                                                              : title2,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${listVital2[index].value} (${widget.unit2})",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      listVital2[index].byWhom!,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              deleteTheVitalFromTheList(
                                                  listVital2[index]);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )))));
              })
          : widget.emptyMessageWidget!,
      listVital3.length > 0
          ? ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: kFloatingActionButtonMargin + 60),
              itemCount: listVital3.length,
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
                                    width: 1.0, color: Color(0xFF636F7B)),
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
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  /*decoration: BoxDecoration(
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        borderRadius: BorderRadius.circular(35),
                                      ),*/
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${listVital3[index].date} (",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                              Text(
                                                "${listVital3[index].time})",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    0.8,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: <Widget>[
                                                    Text(
                                                      "T4",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${listVital3[index].value} (${widget.unit3})",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      listVital3[index].byWhom!,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              deleteTheVitalFromTheList(
                                                  listVital3[index]);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )))));
              })
          : widget.emptyMessageWidget!,
      listVital4.length > 0
          ? ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: kFloatingActionButtonMargin + 60),
              itemCount: listVital4.length,
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
                                    width: 1.0, color: Color(0xFF636F7B)),
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
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  /*decoration: BoxDecoration(
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        borderRadius: BorderRadius.circular(35),
                                      ),*/
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${listVital4[index].date} (",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                              Text(
                                                "${listVital4[index].time})",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    0.8,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: <Widget>[
                                                    Text(
                                                      "Free T3",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${listVital4[index].value} (${widget.unit4})",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      listVital4[index].byWhom!,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              deleteTheVitalFromTheList(
                                                  listVital4[index]);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )))));
              })
          : widget.emptyMessageWidget!,
      listVital5.length > 0
          ? ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: kFloatingActionButtonMargin + 60),
              itemCount: listVital5.length,
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
                                    width: 1.0, color: Color(0xFF636F7B)),
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
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  /*decoration: BoxDecoration(
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        borderRadius: BorderRadius.circular(35),
                                      ),*/
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${listVital5[index].date} (",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                              Text(
                                                "${listVital5[index].time})",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    0.8,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: <Widget>[
                                                    Text(
                                                      "$title5",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      " -  ${listVital5[index].value} (${widget.unit5})",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      listVital5[index].byWhom!,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              deleteTheVitalFromTheList(
                                                  listVital5[index]);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )))));
              })
          : widget.emptyMessageWidget!,
    ];

    listWeightHeightTabsWidgets = [
      listVital.length > 0
          ? ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: kFloatingActionButtonMargin + 60),
              itemCount: listVital.length,
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
                                    width: 1.0, color: Color(0xFF636F7B)),
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
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  /*decoration: BoxDecoration(
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        borderRadius: BorderRadius.circular(35),
                                      ),*/
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${listVital[index].date} (",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                              Text(
                                                "${listVital[index].time})",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    0.8,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: <Widget>[
                                                    Text(
                                                      "Weight",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${listVital[index].value} (${widget.unit})",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      listVital[index].byWhom!,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              deleteTheVitalFromTheList(
                                                  listVital[index]);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )))));
              })
          : widget.emptyMessageWidget!,
      listVital2.length > 0
          ? ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: kFloatingActionButtonMargin + 60),
              itemCount: listVital2.length,
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
                                    width: 1.0, color: Color(0xFF636F7B)),
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
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  /*decoration: BoxDecoration(
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        borderRadius: BorderRadius.circular(35),
                                      ),*/
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${listVital2[index].date} (",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                              Text(
                                                "${listVital2[index].time})",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    0.8,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: <Widget>[
                                                    Text(
                                                      "Height",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${listVital2[index].value} (${widget.unit2})",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: <Widget>[
                                                    Text(
                                                      "Entry By",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      listVital2[index].byWhom!,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              deleteTheVitalFromTheList(
                                                  listVital2[index]);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )))));
              })
          : widget.emptyMessageWidget!,
      listVital3.length > 0
          ? ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: kFloatingActionButtonMargin + 60),
              itemCount: listVital3.length,
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
                                    width: 1.0, color: Color(0xFF636F7B)),
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
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  /*decoration: BoxDecoration(
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                        borderRadius: BorderRadius.circular(35),
                                      ),*/
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${listVital3[index].date} (",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                              Text(
                                                "${listVital2[index].time})",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: SizeConfig
                                                          .blockSizeVertical! *
                                                      2.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    0.8,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: <Widget>[
                                                    Text(
                                                      "BMI",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${listVital3[index].value} (${widget.unit3})",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
                                                            2.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      listVital3[index].byWhom!,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF636F7B),
                                                        fontSize: SizeConfig
                                                                .blockSizeVertical! *
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
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              deleteTheVitalFromTheList(
                                                  listVital3[index]);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )))));
              })
          : widget.emptyMessageWidget!,
    ];
  }

  @override
  void initState() {
    super.initState();
    keyForChart = GlobalKey();
    keyForChart2 = GlobalKey();
    keyForChart3 = GlobalKey();
    keyForChart4 = GlobalKey();
    keyForChart5 = GlobalKey();
    listVitalIDPs = [];
    vitalsAPICount = 0;
    switch (widget.vitalGroupIDP) {
      case "1":
        listVitalIDPs.add("1");
        listVitalIDPs.add("2");
        title = "Blood Pressure";
        title1 = "Blood Pressure";
        widget.emptyMessage =
            "${widget.emptyTextBP1}\n\n${widget.emptyTextBP2}\n\n${widget.emptyTextBP3}\n\n${widget.emptyTextBP4}";
        widget.unit = "mm of hg";
        widget.unit2 = "mm of hg";
        break;
      case "2":
        listVitalIDPs.add("3");
        listVitalIDPs.add("4");
        listVitalIDPs.add("5");
        listVitalIDPs.add("10");
        title = "Vitals";
        title1 = "Pulse";
        title2 = "Temperature";
        title3 = "SPO2";
        title4 = "Respiratory Rate";
        widget.unit = "per min.";
        widget.unit2 = "\u2109";
        widget.unit3 = "%";
        widget.unit4 = "per min.";
        widget.emptyMessage =
            "${widget.emptyTextVitals1}\n\n${widget.emptyTextVitals2}";
        break;
      case "3":
        listVitalIDPs.add("6");
        listVitalIDPs.add("7");
        listVitalIDPs.add("8");
        listVitalIDPs.add("9");
        title = "Sugar";
        title1 = "FBS";
        title2 = "PPBS";
        title3 = "RBS";
        title4 = "HbA1C";
        widget.unit = "mg/dl";
        widget.unit2 = "mg/dl";
        widget.unit3 = "mg/dl";
        widget.unit4 = "mg/dl";
        widget.emptyMessage =
            "${widget.emptyTextSugar1}\n\n${widget.emptyTextSugar2}\n\n${widget.emptyTextSugar3}\n\n${widget.emptyTextSugar4}";
        break;
      case "4":
        listVitalIDPs.add("11");
        listVitalIDPs.add("21");
        listVitalIDPs.add("12");
        widget.unit = "Kg";
        widget.unit2 = "cm";
        widget.unit3 = "Kg/m\u00B2";
        title = "Weight Measurement";
        title1 = "Weight Measurement";
        widget.emptyMessage = "${widget.emptyTextWeight}";
        break;
      case "5":
        listVitalIDPs.add("13");
        listVitalIDPs.add("14");
        listVitalIDPs.add("23");
        listVitalIDPs.add("24");
        widget.unit = "Mins.";
        widget.unit2 = "Steps";
        widget.unit3 = "cm";
        widget.unit4 = "cm";
        title = "Health Exercise";
        title1 = "Exercise";
        title2 = "Walking";
        title3 = "Waist";
        title4 = "Hip";
        widget.emptyMessage = "${widget.emptyTextExercise}";
        break;
      case "6":
        listVitalIDPs.add("15");
        listVitalIDPs.add("16");
        listVitalIDPs.add("17");
        listVitalIDPs.add("18");
        listVitalIDPs.add("19");
        widget.unit = "uIU/mL";
        widget.unit2 = "ng/dL";
        widget.unit3 = "ug/dL";
        widget.unit4 = "pg/mL";
        widget.unit5 = "ng/dL";
        title = "Thyroid";
        title1 = "TSH";
        title2 = "T3";
        title3 = "T4";
        title4 = "FreeT3";
        title5 = "FreeT4";
        widget.emptyMessage = "${widget.emptyTextThyroid}";
        break;
      case "7":
        listVitalIDPs.add("20");
        widget.unit = "ml";
        title = "Water" /*Intake*/;
        title1 = "Water" /*Intake*/;
        widget.emptyMessage = "${widget.emptyTextWaterIntake}";
        break;
      case "8":
        listVitalIDPs.add("22");
        widget.unit = "Hours";
        title = "Sleep";
        title1 = "Sleep";
        widget.emptyMessage = "${widget.emptyTextSleep}";
        break;
    }
    /*if (widget.vitalIDP == "1") {
      widget.vitalIDP2 = "2";
      title = "Blood Pressure";
      title1 = "Blood Pressure";
      widget.emptyMessage =
          "${widget.emptyTextBP1}\n\n${widget.emptyTextBP2}\n\n${widget.emptyTextBP3}";
      widget.unit = "mm of hg";
      widget.unit2 = "mm of hg";
    } else if (widget.vitalIDP == "2")
      title = "BP Diastolic";
    else if (widget.vitalIDP == "3") {
      widget.vitalIDP2 = "4";
      widget.vitalIDP3 = "5";
      widget.vitalIDP4 = "10";
      title = "Vitals";
      title1 = "Vitals";
      widget.unit = "per min.";
      widget.unit2 = "\u2109";
      widget.unit3 = "%";
      widget.unit4 = "per min.";
      widget.emptyMessage =
          "${widget.emptyTextVitals1}\n\n${widget.emptyTextVitals2}";
    } else {
      widget.emptyMessage =
          "${widget.emptyTextSugar1}\n\n${widget.emptyTextSugar2}\n\n${widget.emptyTextSugar3}";
      if (widget.vitalIDP == "4") {
        title = "Temperature";
        title1 = "Temperature";
      } else if (widget.vitalIDP == "5") {
        title = "SPO2";
        title1 = "SPO2";
      } else if (widget.vitalIDP == "6") {
        title = "FBS";
        title1 = "FBS";
        widget.unit = "mg/dl";
      } else if (widget.vitalIDP == "7") {
        title = "PPBS";
        title1 = "PPBS";
        widget.unit = "mg/dl";
      } else if (widget.vitalIDP == "8") {
        title = "RBS";
        title1 = "RBS";
        widget.unit = "mg/dl";
      } else if (widget.vitalIDP == "9") {
        title = "HbA1C";
        title1 = "HbA1C";
        widget.unit = "mg/dl";
      } else if (widget.vitalIDP == "11") {
        widget.vitalIDP2 = "12";
        widget.unit = "Kg";
        widget.unit2 = "Kg/m\u00B2";
        title = "Weight Measurement";
        title1 = "Weight Measurement";
        widget.emptyMessage = "${widget.emptyTextWeight}";
      } else if (widget.vitalIDP == "13") {
        widget.vitalIDP2 = "14";
        widget.unit = "Mins.";
        widget.unit2 = "Steps";
        title = "Health Exercise";
        title1 = "Exercise";
        title2 = "Walking";
        widget.emptyMessage = "${widget.emptyTextExercise}";
      } else if (widget.vitalIDP == "15") {
        widget.vitalIDP2 = "16";
        widget.vitalIDP3 = "17";
        widget.vitalIDP4 = "18";
        widget.vitalIDP5 = "19";
        widget.unit = "uIU/mL";
        widget.unit2 = "ng/dL";
        widget.unit3 = "ug/dL";
        widget.unit4 = "pg/mL";
        widget.unit5 = "ng/dL";
        title = "Thyroid";
        title1 = "TSH";
        title2 = "T3";
        title3 = "T4";
        title4 = "FreeT3";
        title5 = "FreeT4";
        widget.emptyMessage = "${widget.emptyTextThyroid}";
      } else if (widget.vitalIDP == "20") {
        widget.unit = "ml";
        title = "Water Intake";
        title1 = "Water Intake";
        widget.emptyMessage = "${widget.emptyTextWaterIntake}";
      }
    }*/

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

    widget.emptyMessageWidgetFBS = SizedBox(
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
              "${widget.emptyTextSugar1}",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
    widget.emptyMessageWidgetPPBS = SizedBox(
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
              "${widget.emptyTextSugar2}",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
    widget.emptyMessageWidgetRBS = SizedBox(
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
              "${widget.emptyTextSugar3}",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
    widget.emptyMessageWidgetHbA1C = SizedBox(
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
              "${widget.emptyTextSugar4}",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );

    setListsForTabs();

    // var formatter = new DateFormat('dd-MM-yyyy');
    /*widget.fromDateString = formatter.format(widget.fromDate);
    widget.toDateString = formatter.format(widget.toDate);*/
    widget.dateString = "Select Date Range";
    listChartType = [];
    listChartType.add("Pulse");
    listChartType.add("BP Systolic");
    listChartType.add("BP Diastolic");
    listChartType.add("Temperature");
    listChartType.add("SPO2");
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
            print("**** $isFABVisible down"); //Move IO away from setState
            setState(() {
              isFABVisible = true;
            });
          }
        }
      }
    });
    dateRange = DateTimeRange(start: fromDate!, end: toDate!);
    getVitalsList();
  }

  @override
  Widget build(BuildContext context) {
    final start = dateRange.start;
    final end = dateRange.end;
    SizeConfig().init(context);
    return DefaultTabController(
      length: getVitalTabsLength(),
      child: Scaffold(
        /*key: navigatorKey,*/
        appBar: AppBar(
          title: Text(title, style: TextStyle(color: Colorsblack)),
          centerTitle: true,
          bottom:
              /*widget.vitalIDP == "1" && widget.mainType == "list"
              ? TabBar(
                  tabs: <Widget>[
                    Tab(
                      child: Text("BP Systolic"),
                    ),
                    Tab(
                      child: Text("BP Diastolic"),
                    ),
                  ],
                )
              : (*/
              (widget.vitalGroupIDP == "2" || widget.vitalGroupIDP == "3") &&
                      widget.mainType == "list"
                  ? TabBar(
                      tabs: <Widget>[
                        Tab(
                          child: Text(
                              widget.vitalGroupIDP == "2" ? "Pulse" : "FBS",
                              style: CustomTextStyle.nameOfTextStyle),
                        ),
                        Tab(
                          child: Text(
                              widget.vitalGroupIDP == "2"
                                  ? "Temperature"
                                  : "PPBS",
                              style: CustomTextStyle.nameOfTextStyle),
                        ),
                        Tab(
                          child: Text(
                              widget.vitalGroupIDP == "2" ? "SPO2" : "RBS",
                              style: CustomTextStyle.nameOfTextStyle),
                        ),
                        Tab(
                          child: Text(
                              widget.vitalGroupIDP == "2"
                                  ? "Respiratory Rate"
                                  : "HbA1C",
                              style: CustomTextStyle.nameOfTextStyle),
                        ),
                      ],
                    )
                  : (widget.vitalGroupIDP == "4" && widget.mainType == "list"
                      ? TabBar(
                          tabs: <Widget>[
                            Tab(
                              child: Text("Weight",
                                  style: CustomTextStyle.nameOfTextStyle),
                            ),
                            Tab(
                              child: Text("Height",
                                  style: CustomTextStyle.nameOfTextStyle),
                            ),
                            Tab(
                              child: Text("BMI",
                                  style: CustomTextStyle.nameOfTextStyle),
                            ),
                          ],
                        )
                      : (widget.vitalGroupIDP == "5" &&
                              widget.mainType == "list"
                          ? TabBar(
                              tabs: <Widget>[
                                Tab(
                                  child: Text("Exercise",
                                      style: CustomTextStyle.nameOfTextStyle),
                                ),
                                Tab(
                                  child: Text("Walking",
                                      style: CustomTextStyle.nameOfTextStyle),
                                ),
                                Tab(
                                  child: Text("Waist",
                                      style: CustomTextStyle.nameOfTextStyle),
                                ),
                                Tab(
                                  child: Text("Hip",
                                      style: CustomTextStyle.nameOfTextStyle),
                                ),
                              ],
                            )
                          : (widget.vitalGroupIDP == "6" &&
                                  widget.mainType == "list"
                              ? TabBar(
                                  tabs: <Widget>[
                                    Tab(
                                      child: Text("TSH",
                                          style:
                                              CustomTextStyle.nameOfTextStyle),
                                    ),
                                    Tab(
                                      child: Text("T3",
                                          style:
                                              CustomTextStyle.nameOfTextStyle),
                                    ),
                                    Tab(
                                      child: Text("T4",
                                          style:
                                              CustomTextStyle.nameOfTextStyle),
                                    ),
                                    Tab(
                                      child: Text("FreeT3",
                                          style:
                                              CustomTextStyle.nameOfTextStyle),
                                    ),
                                    Tab(
                                      child: Text("FreeT4",
                                          style:
                                              CustomTextStyle.nameOfTextStyle),
                                    ),
                                  ],
                                )
                              : PreferredSize(
                                  child: Container(),
                                  preferredSize:
                                      Size(SizeConfig.screenWidth!, 0),
                                )))) /*)*/,
          backgroundColor: Color(0xFFFFFFFF),
          actions: <Widget>[
            InkWell(
              onTap: () {
                setState(() {
                  setListsForTabs();
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
                  color: Colorsblack,
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
          iconTheme: IconThemeData(
              color: Colorsblack, size: SizeConfig.blockSizeVertical! * 2.5),
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
              if (widget.vitalGroupIDP == "7") {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                WaterIntakeScreen(widget.patientIDP!)))
                    .then((value) {
                  getVitalsList();
                });
              } else {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddVitalsScreen(
                                widget.patientIDP!, widget.vitalIDP!)))
                    .then((value) {
                  getVitalsList();
                });
              }
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.black,
          ),
        ),
        body: RefreshIndicator(
          child: ListView(
            shrinkWrap: true,
            controller: hideFABController,
            children: <Widget>[
              //DateTimeComboLinePointChart.withSampleData(),
              //LineChartSample1(),
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
                          // showDateRangePickerDialog();
                        },
                        child: Row(
                          children: <Widget>[
                            // Expanded(
                            //   child: Text(
                            //     widget.dateString,
                            //     textAlign: TextAlign.center,
                            //     style: TextStyle(
                            //         fontSize:
                            //         SizeConfig.blockSizeVertical !* 2.6,
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
                              child:
                                  Text('${end.day}/${end.month}/${end.year}'),
                              onPressed: pickDateRange,
                            )),
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
              SizedBox(
                height: 5.0,
              ),
              showCategoryTabs() && listCategories.length > 0
                  ? Container(
                      height: SizeConfig.blockSizeVertical! * 10,
                      width: SizeConfig.blockSizeHorizontal! * 100,
                      color: Color(0xFFF0F0F0),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: SizeConfig.blockSizeHorizontal! * 2,
                            right: SizeConfig.blockSizeHorizontal! * 2),
                        child: Center(
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
                                        listCategories[index].idp;
                                    selectedCategory =
                                        listCategories[index].value;
                                  });
                                },
                                child: Chip(
                                  padding: EdgeInsets.all(
                                      SizeConfig.blockSizeHorizontal! * 3),
                                  label: Text(
                                    listCategories[index].value.trim(),
                                    style: TextStyle(
                                      color: listCategories[index].idp ==
                                              selectedCategoryIDP
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  backgroundColor: listCategories[index].idp ==
                                          selectedCategoryIDP
                                      ? Color(0xFF06A759)
                                      : Colors.grey,
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 5,
                              );
                            },
                          ),
                        ),
                      ))
                  : Container(),
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 2,
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 0.5,
              ),
              getMainWidget(),
            ],
          ),
          onRefresh: () {
            return getVitalsList();
          },
        ),
      ),
    );
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
  //   //   "${widget.fromDateString}  to  ${widget.toDateString}";
  //   //   setState(() {
  //   //     setListsForTabs();
  //   //     getVitalsList();
  //   //   });
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
  //   //       setListsForTabs();
  //   //       getVitalsList();
  //   //       //print(picked);
  //   //     });
  //   //   },
  //   //   onCancelClick: () {
  //   //     setState(() {
  //   //       widget.fromDate = DateTime.now().subtract(Duration(days: 7));
  //   //       widget.toDate = DateTime.now();
  //   //       setListsForTabs();
  //   //       getVitalsList();
  //   //     });
  //   //   },
  //   // );
  // }

  getVitalsList() async {
    switch (widget.vitalGroupIDP) {
      /*case "1":
        widget.shouldShowEmptyMessageWidget = true;
        getVitalsListForBP();
        break;*/
      default:
        vitalsAPICount = 0;
        widget.shouldShowEmptyMessageWidget = true;
        Future.delayed(Duration.zero, () {
          widget.pr = ProgressDialog(context);
          widget.pr!.show();
        });
        listCategories = [];
        for (int i = 0; i < listVitalIDPs.length; i++) {
          debugPrint("calling api with Vital idp - ${listVitalIDPs[i]}");
          getVitalsListWithVitalIDP(listVitalIDPs[i], i + 1);
          debugPrint(
              "Categories list length inside for loop - ${listCategories.length}");
        }
        break;
    }
    /*if (widget.vitalIDP == "1") {
      return getVitalsListForBP();
    } else {
      getVitalsListActual();
      if (widget.vitalIDP == "3" || widget.vitalIDP == "15") {
        Future.delayed(Duration(seconds: 1), () {
          return getVitalsListActual2();
        });
        Future.delayed(Duration(seconds: 2), () {
          return getVitalsListActual3();
        });
      } else if (widget.vitalIDP == "11" || widget.vitalIDP == "13") {
        Future.delayed(Duration(seconds: 1), () {
          return getVitalsListActual2();
        });
      }
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
      getVitalsList();
    }
  }

  void deleteTheVitalFromTheListForBP1(
      ModelGraphValues modelVitalList, ModelGraphValues modelVitalList2) async {
    String loginUrl = "${baseURL}patientVitalDelete.php";
    Future.delayed(Duration.zero, () {
      widget.pr = ProgressDialog(context);
      widget.pr!.show();
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
    widget.pr!.hide();
    if (model.status == "OK") {
      getVitalsList();
    }
  }

  // void getImageAndShare() async {
  //   RenderRepaintBoundary? boundary =
  //   globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  //   if(boundary ==null){
  //     debugPrint("got null boundary");
  //     return;
  //   }
  //   var image =
  //   await boundary.toImage(pixelRatio: vitalIDPGlobal == "3" ? 2.0 : 2.0);
  //   ByteData? pngBytes = await image.toByteData(format: ImageByteFormat.png);
  //   Directory tempDir = await getTemporaryDirectory();
  //   String tempPath = tempDir.path;
  //   String imgName = "sharechart_${DateTime.now().millisecondsSinceEpoch}.png";
  //   imgFile = File('$tempPath/imgName');
  //   imgFile!.writeAsBytesSync(pngBytes!.buffer.asUint8List());
  //   //setState(() {});
  //   //ShareExtend.share(imgFile.path, "file");
  //   //SimpleShare.share(uri: uri.toString());
  //   shareFiles(context,imgName);
  //   // WcFlutterShare.share(
  //   //   sharePopupTitle: "Share Chart via",
  //   //   mimeType: 'image/png',
  //   //   fileName: "$imgName",
  //   //   bytesOfFile: pngBytes.buffer.asUint8List(),
  //   // );
  // }

  Future<String?>? getVitalsListWithVitalIDP(
      String vitalIDP, int vitalSerialNo) async {
    String loginUrl = "${baseURL}patientVitalsData.php";
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
        "VitalIDP" +
        "\"" +
        ":" +
        "\"" +
        vitalIDP +
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

    vitalsAPICount++;

    switch (vitalSerialNo) {
      case 1:
        widget.listVitals = [];
        listVital = [];
        listVitalOnlyString = [];
        listVitalOnlyStringDate = [];
        listVitalByWhom = [];
        break;
      case 2:
        widget.listVitals = [];
        listVital2 = [];
        listVitalOnlyString2 = [];
        listVitalOnlyStringDate2 = [];
        listVital2ByWhom = [];
        break;
      case 3:
        widget.listVitals = [];
        listVital3 = [];
        listVitalOnlyString3 = [];
        listVitalOnlyStringDate3 = [];
        listVital3ByWhom = [];
        break;
      case 4:
        widget.listVitals = [];
        listVital4 = [];
        listVitalOnlyString4 = [];
        listVitalOnlyStringDate4 = [];
        listVital4ByWhom = [];
        break;
      case 5:
        widget.listVitals = [];
        listVital5 = [];
        listVitalOnlyString5 = [];
        listVitalOnlyStringDate5 = [];
        listVital5ByWhom = [];
        break;
      default:
    }

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
        if (!getWidgetVitalsList(vitalSerialNo)!.contains(model))
          getWidgetVitalsList(vitalSerialNo)!.add(model);
        String byWhom = "";
        if (jo['doctorentrystatus'] == "0")
          byWhom = "Patient";
        else if (jo['doctorentrystatus'] == "1") byWhom = "Doctor";
        getChartVitalsList(vitalSerialNo).add(ModelGraphValues(
          jo['VitalEntryDate'],
          jo['VitalEntryTime'],
          jo['VitalValue'],
          jo['VitalIDP'],
          byWhom: byWhom,
        ));
        getVitalOnlyStringList(vitalSerialNo).add(jo['VitalValue']);
        getVitalByWhomList(vitalSerialNo).add(byWhom);
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
        getVitalOnlyStringDateList(vitalSerialNo)
            .add("${formatter.format(current)}");
      }
      if (getChartVitalsList(vitalSerialNo).length > 0)
        widget.shouldShowEmptyMessageWidget = false;
      if (getChartVitalsList(vitalSerialNo).length > 0 && showCategoryTabs()) {
        listCategories
            .add(DropDownItem(vitalIDP, getVitalNameFromIDP(vitalIDP)));
      }
      debugPrint("Vitals list response, for Vital IDP - $vitalIDP");
      debugPrint(getChartVitalsList(vitalSerialNo).length.toString());
      if (vitalsAPICount == listVitalIDPs.length && listVitalIDPs.length > 0) {
        widget.pr!.hide();
        debugPrint("Categories list length - ${listCategories.length}");
        if (listCategories.length > 0 && showCategoryTabs()) {
          debugPrint(
              "Let's check categories first list - ${listCategories[0].idp}");
          setState(() {
            selectedCategoryIDP = listCategories[0].idp;
          });
        }
      }
      setState(() {
        setStateOfTheEChartWidget();
        setListsForTabs();
      });
    }
    return null;
  }

  Future<String?>? getVitalsListActual() async {
    String loginUrl = "${baseURL}patientVitalsData.php";
    Future.delayed(Duration.zero, () {
      widget.pr = ProgressDialog(context);
      widget.pr!.show();
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
        "VitalIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.vitalIDP! +
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
    if (widget.vitalIDP != "1" && widget.vitalIDP != "3") widget.pr!.hide();
    widget.listVitals = [];
    listVital = [];
    listPulse = [];
    listBPSystolic = [];
    listBPDiastolic = [];
    listTemperature = [];
    listSPO2 = [];

    listVitalOnlyString = [];
    listVitalOnlyStringDate = [];

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
          /*jo['FBS'],
          jo['RBS'],
          jo['PPBS'],*/
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
        if (!widget.listVitals!.contains(model)) widget.listVitals!.add(model);
        String byWhom = "";
        if (jo['doctorentrystatus'] == "0")
          byWhom = "Patient";
        else
          byWhom = "Doctor";
        listVital.add(ModelGraphValues(
          jo['VitalEntryDate'],
          jo['VitalEntryTime'],
          jo['VitalValue'],
          jo['VitalIDP'],
          byWhom: byWhom,
        ));
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
      if (widget.listVitals!.length > 0)
        widget.shouldShowEmptyMessageWidget = false;
      else
        widget.shouldShowEmptyMessageWidget = true;
      debugPrint("Vitals list");
      debugPrint(listVital.length.toString());
      if (widget.vitalIDP != "1" && widget.vitalIDP != "3") {
        //keyForChart.currentState.setStateInsideTheChart();
        setState(() {
          setStateOfTheEChartWidget();
          setListsForTabs();
        });
      }
    }
    return null;
  }

  getVitalsListForBP() async {
    String loginUrl = "${baseURL}patientVitalsDataBP.php";
    Future.delayed(Duration.zero, () {
      widget.pr = ProgressDialog(context);
      widget.pr!.show();
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
        "VitalIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.vitalIDP2! +
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
    debugPrint("Actual 2");
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    if (widget.vitalIDP != "3") widget.pr!.hide();
    listVital = [];
    listVital2 = [];
    widget.listVitals = [];
    listVitalOnlyString = [];
    listVitalOnlyStringDate = [];
    listVitalOnlyString2 = [];
    listVitalOnlyStringDate2 = [];
    listVitalByWhom = [];

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
        if (!widget.listVitals!.contains(model)) widget.listVitals!.add(model);
        String byWhom = "";
        if (jo['doctorentrystatus'] == "0")
          byWhom = "Patient";
        else
          byWhom = "Doctor";
        listVital.add(ModelGraphValues(
          jo['VitalEntryDate'],
          jo['VitalEntryTime'],
          jo['VitalValue1'],
          jo['VitalIDP1'],
          byWhom: byWhom,
        ));
        listVital2.add(ModelGraphValues(
          jo['VitalEntryDate'],
          jo['VitalEntryTime'],
          jo['VitalValue2'],
          jo['VitalIDP2'],
          byWhom: byWhom,
        ));

        listVitalByWhom.add(byWhom);
        listVitalOnlyString.add(jo['VitalValue1']);
        listVitalOnlyString2.add(jo['VitalValue2']);
        /*debugPrint(
            "Entry date :- ${jo["VitalValue1"]} ${jo["VitalValue2"]} ${jo['VitalEntryDate']}");*/
        debugPrint(jo.toString());
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
      if (widget.listVitals!.length > 0)
        widget.shouldShowEmptyMessageWidget = false;
      else
        widget.shouldShowEmptyMessageWidget = true;
      debugPrint("Vitals list");
      debugPrint(listVital2.length.toString());
      widget.pr!.hide();
      setState(() {
        setStateOfTheEChartWidget();
        setListsForTabs();
      });
      return 'success';
    }
  }

  void setStateOfTheEChartWidget() {
    if (widget.vitalGroupIDP == "2" || widget.vitalGroupIDP == "3") {
      if (keyForChart == null)
        debugPrint("key null- chart 1 idp - 3");
      else if (keyForChart?.currentState == null)
        debugPrint("currentState null- chart 1 idp - 3");
      else {
        debugPrint("nothing null, setting state of chart - chart 1 idp - 3");
        keyForChart?.currentState?.setStateInsideTheChart();
      }
      if (keyForChart2 == null)
        debugPrint("key null- chart 2 idp - 3");
      else if (keyForChart2?.currentState == null)
        debugPrint("currentState null- chart 2 idp - 3");
      else {
        debugPrint("nothing null, setting state of chart- chart 2 idp - 3");
        keyForChart2?.currentState?.setStateInsideTheChart();
      }
      if (keyForChart3 == null)
        debugPrint("key null");
      else if (keyForChart3?.currentState == null)
        debugPrint("currentState null");
      else {
        debugPrint("nothing null, setting state of chart - chart 3 idp - 3");
        keyForChart3?.currentState?.setStateInsideTheChart();
      }
      if (keyForChart4 == null)
        debugPrint("key null 4");
      else if (keyForChart4?.currentState == null)
        debugPrint("currentState null 4");
      else {
        debugPrint("nothing null, setting state of chart - chart 4 idp - 4");
        keyForChart4?.currentState?.setStateInsideTheChart();
      }
    } else if (widget.vitalGroupIDP == "6") {
      if (keyForChart == null)
        debugPrint("key null- chart 1 idp - 3");
      else if (keyForChart?.currentState == null)
        debugPrint("currentState null- chart 1 idp - 3");
      else {
        debugPrint("nothing null, setting state of chart - chart 1 idp - 3");
        keyForChart?.currentState?.setStateInsideTheChart();
      }
      if (keyForChart2 == null)
        debugPrint("key null- chart 2 idp - 3");
      else if (keyForChart2?.currentState == null)
        debugPrint("currentState null- chart 2 idp - 3");
      else {
        debugPrint("nothing null, setting state of chart- chart 2 idp - 3");
        keyForChart2?.currentState?.setStateInsideTheChart();
      }
      if (keyForChart3 == null)
        debugPrint("key null");
      else if (keyForChart3?.currentState == null)
        debugPrint("currentState null");
      else {
        debugPrint("nothing null, setting state of chart - chart 3 idp - 3");
        keyForChart3?.currentState?.setStateInsideTheChart();
      }
      if (keyForChart4 == null)
        debugPrint("key null 4");
      else if (keyForChart4?.currentState == null)
        debugPrint("currentState null 4");
      else {
        debugPrint("nothing null, setting state of chart - chart 4 idp - 4");
        keyForChart4?.currentState?.setStateInsideTheChart();
      }
      if (keyForChart5 == null)
        debugPrint("key null 5");
      else if (keyForChart5?.currentState == null)
        debugPrint("currentState null 5");
      else {
        debugPrint("nothing null, setting state of chart - chart 5 idp - 5");
        keyForChart5?.currentState?.setStateInsideTheChart();
      }
    } else if (widget.vitalGroupIDP == "1") {
      if (keyForChart == null)
        debugPrint("key null");
      else if (keyForChart?.currentState == null)
        debugPrint("currentState null");
      else {
        debugPrint("nothing null, setting state of chart - chart 1 idp - 1");
        keyForChart?.currentState?.setStateInsideTheChart();
      }
    } else if (widget.vitalGroupIDP == "4") {
      if (keyForChart == null)
        debugPrint("key null- chart 1 idp - 3");
      else if (keyForChart?.currentState == null)
        debugPrint("currentState null- chart 1 idp - 3");
      else {
        debugPrint("nothing null, setting state of chart - chart 1 idp - 3");
        keyForChart?.currentState?.setStateInsideTheChart();
      }
      if (keyForChart2 == null)
        debugPrint("key null- chart 2 idp - 3");
      else if (keyForChart2?.currentState == null)
        debugPrint("currentState null- chart 2 idp - 3");
      else {
        debugPrint("nothing null, setting state of chart- chart 2 idp - 3");
        keyForChart2?.currentState?.setStateInsideTheChart();
      }
    } else {
      if (keyForChart == null)
        debugPrint("key null");
      else if (keyForChart?.currentState == null)
        debugPrint("currentState null");
      else {
        debugPrint(
            "nothing null, setting state of chart  - chart 1 idp - x, title - $title");
        keyForChart?.currentState?.setStateInsideTheChart();
      }
    }
  }

  Widget getChartsWidgets() {
    switch (widget.vitalGroupIDP) {
      case "1":
        return getBPCharts();
        break;
      case "2":
        return getVitalsCharts();
        break;
      case "3":
        return getSugarCharts();
        break;
      case "4":
        return getWeightMeasurementCharts();
        break;
      case "5":
        return getHealthExercisesCharts();
        break;
      case "6":
        return getThyroidCharts();
        break;
      case "7":
        return getWaterIntakeCharts();
        break;
      case "8":
        return getSleepCharts();
        break;
      default:
        return Container();
    }
  }

  Widget getBPCharts() {
    return !widget.shouldShowEmptyMessageWidget!
        ? Column(
            children: [
              MyEChart(
                key: keyForChart!,
                chartTypeID: "1",
                titleOfChart: "BP Systolic",
                value: bpSystolicValue.toDouble(),
              ),
              MyEChart(
                key: keyForChart2!,
                chartTypeID: "2",
                titleOfChart: "BP Diastolic",
                value: bpDiastolicValue.toDouble(),
              )
            ],
          )
        : Container();
  }

  Widget getSleepCharts() {
    return !widget.shouldShowEmptyMessageWidget!
        ? MyEChart(
            key: keyForChart!,
            chartTypeID: "1",
            titleOfChart: "Sleep (Hours)",
            value: sleepValue.toDouble(),
          )
        : Container();
  }

  Widget getVitalsCharts() {
    return !widget.shouldShowEmptyMessageWidget!
        ? getParticularVitalChart()
        : Container();
  }

  Widget getSugarCharts() {
    return !widget.shouldShowEmptyMessageWidget!
        ? Column(
            children: [
              MyEChart(
                key: keyForChart!,
                chartTypeID: "1",
                titleOfChart: "FBS (mg/dl)",
                value: fbsValue.toDouble(),
              ),
              MyEChart(
                key: keyForChart2!,
                chartTypeID: "2",
                titleOfChart: "PPBS (mg/dl)",
                value: ppbsValue.toDouble(),
              ),
              MyEChart(
                key: keyForChart3!,
                chartTypeID: "3",
                titleOfChart: "RBS (mg/dl)",
                value: rbsValue.toDouble(),
              ),
              MyEChart(
                key: keyForChart4!,
                chartTypeID: "4",
                titleOfChart: "HbA1C (mg/dl)",
                value: hba1cValue.toDouble(),
              ),
            ],
          )
        : Container();
  }

  Widget getWeightMeasurementCharts() {
    return !widget.shouldShowEmptyMessageWidget!
        ? getParticularWeightChart()
        : Container();
  }

  Widget getHealthExercisesCharts() {
    return !widget.shouldShowEmptyMessageWidget!
        ? getParticularExerciseChart()
        : Container();
  }

  Widget getThyroidCharts() {
    return !widget.shouldShowEmptyMessageWidget!
        ? getParticularThyroidChart()
        : Container();
  }

  Widget getWaterIntakeCharts() {
    return !widget.shouldShowEmptyMessageWidget!
        ? MyEChart(
            key: keyForChart,
            chartTypeID: "1",
            titleOfChart: "Water Intake (ml)",
            value: 0,
          )
        : Container();
  }

  List<ModelVitalsList?>? getWidgetVitalsList(int i) {
    switch (i) {
      case 1:
        return widget.listVitals;
        break;
      case 2:
        return widget.listVitals;
        break;
      case 3:
        return widget.listVitals;
        break;
      case 4:
        return widget.listVitals;
        break;
      case 5:
        return widget.listVitals;
        break;
      default:
        return [];
    }
  }

  List<ModelGraphValues> getChartVitalsList(int i) {
    switch (i) {
      case 1:
        return listVital;
        break;
      case 2:
        return listVital2;
        break;
      case 3:
        return listVital3;
        break;
      case 4:
        return listVital4;
        break;
      case 5:
        return listVital5;
        break;
      default:
        return [];
    }
  }

  List<String> getVitalOnlyStringList(int i) {
    switch (i) {
      case 1:
        return listVitalOnlyString;
        break;
      case 2:
        return listVitalOnlyString2;
        break;
      case 3:
        return listVitalOnlyString3;
        break;
      case 4:
        return listVitalOnlyString4;
        break;
      case 5:
        return listVitalOnlyString5;
        break;
      default:
        return [];
    }
  }

  List<String> getVitalByWhomList(int i) {
    switch (i) {
      case 1:
        return listVitalByWhom;
        break;
      case 2:
        return listVital2ByWhom;
        break;
      case 3:
        return listVital3ByWhom;
        break;
      case 4:
        return listVital4ByWhom;
        break;
      case 5:
        return listVital5ByWhom;
        break;
      default:
        return [];
    }
  }

  List<String> getVitalOnlyStringDateList(int i) {
    switch (i) {
      case 1:
        return listVitalOnlyStringDate;
        break;
      case 2:
        return listVitalOnlyStringDate2;
        break;
      case 3:
        return listVitalOnlyStringDate3;
        break;
      case 4:
        return listVitalOnlyStringDate4;
        break;
      case 5:
        return listVitalOnlyStringDate5;
        break;
      default:
        return [];
    }
  }

  int getVitalTabsLength() {
    if ((widget.vitalGroupIDP == "2" ||
            widget.vitalGroupIDP == "3" ||
            widget.vitalGroupIDP == "5") &&
        widget.mainType == "list") {
      return 4;
    } else if (widget.vitalGroupIDP == "6" && widget.mainType == "list") {
      return 5;
    } else if (widget.vitalGroupIDP == "4" && widget.mainType == "list") {
      return 3;
    }
    return 2;
    /*widget.vitalGroupIDP == "2" ||
        widget.vitalGroupIDP == "3" && widget.mainType == "list"
        ? 4
        : (widget.vitalGroupIDP == "6" && widget.mainType == "list" ? 5 : (widget.vitalGroupIDP == "4" && widget.mainType == "list" ? 3 : 2))*/
  }

  Widget getMainWidget() {
    return widget.mainType == "chart"
        ? //DateTimeComboLinePointChart.withSampleData()
        RepaintBoundary(
            key: globalKey,
            child: Container(
                width: SizeConfig.screenWidth,
                color: Colors.white,
                child: Padding(
                    padding:
                        EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 3),
                    child: Column(
                      children: <Widget>[
                        /*InkWell(
                          child: Icon(
                            Icons.share,
                            color: Colors.black,
                          ),
                        ),*/
                        /*Visibility(
                                      visible: widget.mainType == "chart" &&
                                          listVital != null &&
                                          listVital.length > 0,
                                      child: Column(
                                        children: <Widget>[],
                                      )),
                                  SizedBox(
                                    height: SizeConfig.blockSizeVertical * 1,
                                  ),*/
                        widget.shouldShowEmptyMessageWidget!
                            ? widget.emptyMessageWidget!
                            : Container(),
                        getChartsWidgets(),
                        /*!widget.shouldShowEmptyMessageWidget
                                      ? (widget.vitalIDP == "1"
                                          ? MyEChart(
                                              key: keyForChart,
                                              chartTypeID: "5",
                                              titleOfChart: title,
                                            )
                                          : (widget.vitalIDP != "11"
                                              ? (widget.vitalIDP == "3"
                                                  ? MyEChart(
                                                      key: keyForChart,
                                                      chartTypeID: "1",
                                                      titleOfChart:
                                                          "Pulse (${widget.unit})")
                                                  : MyEChart(
                                                      key: keyForChart,
                                                      chartTypeID: "1",
                                                      titleOfChart:
                                                          "$title1 (${widget.unit})"))
                                              : Container()))
                                      : Container(),
                                  //MyAnimatedChart("1"),
                                  !widget.shouldShowEmptyMessageWidget
                                      ? (widget.vitalIDP == "13"
                                          ? MyEChart(
                                              key: keyForChart2,
                                              chartTypeID: "2",
                                              titleOfChart: "Walking (Steps)",
                                            )
                                          : Container())
                                      : Container(),
                                  !widget.shouldShowEmptyMessageWidget
                                      ? (widget.vitalIDP == "3"
                                          ? MyEChart(
                                              key: keyForChart2,
                                              chartTypeID: "2",
                                              titleOfChart:
                                                  "Temperature (\u2109)",
                                            )
                                          : Container())
                                      : Container(),
                                  !widget.shouldShowEmptyMessageWidget
                                      ? (widget.vitalIDP == "15"
                                          ? MyEChart(
                                              key: keyForChart2,
                                              chartTypeID: "2",
                                              titleOfChart: "T3",
                                            )
                                          : Container())
                                      : Container(),
                                  !widget.shouldShowEmptyMessageWidget
                                      ? (widget.vitalIDP == "15"
                                          ? MyEChart(
                                              key: keyForChart3,
                                              chartTypeID: "3",
                                              titleOfChart: "T4",
                                            )
                                          : Container())
                                      : Container(),
                                  !widget.shouldShowEmptyMessageWidget
                                      ? (widget.vitalIDP == "15"
                                          ? MyEChart(
                                              key: keyForChart4,
                                              chartTypeID: "4",
                                              titleOfChart: "FreeT3",
                                            )
                                          : Container())
                                      : Container(),
                                  !widget.shouldShowEmptyMessageWidget
                                      ? (widget.vitalIDP == "15"
                                          ? MyEChart(
                                              key: keyForChart5,
                                              chartTypeID: "6",
                                              titleOfChart: "FreeT4",
                                            )
                                          : Container())
                                      : Container(),
                                  !widget.shouldShowEmptyMessageWidget
                                      ? (widget.vitalIDP == "3"
                                          ? MyEChart(
                                              key: keyForChart4,
                                              chartTypeID: "3",
                                              titleOfChart: "SPO2 (%)",
                                            )
                                          : Container())
                                      : Container(),
                                  !widget.shouldShowEmptyMessageWidget
                                      ? (widget.vitalIDP == "3"
                                          ? MyEChart(
                                              key: keyForChart3,
                                              chartTypeID: "4",
                                              titleOfChart:
                                                  "Respiratory Rate (per min.)",
                                            )
                                          : Container())
                                      : Container(),
                                  !widget.shouldShowEmptyMessageWidget
                                      ? (widget.vitalIDP == "11"
                                          ? MyEChart(
                                              key: keyForChart,
                                              chartTypeID: "1",
                                              titleOfChart:
                                                  "Weight (${widget.unit})",
                                            )
                                          : Container())
                                      : Container(),

                                  !widget.shouldShowEmptyMessageWidget
                                      ? (widget.vitalIDP == "11"
                                          ? MyEChart(
                                              key: keyForChart2,
                                              chartTypeID: "2",
                                              titleOfChart:
                                                  "BMI (${widget.unit2})",
                                            )
                                          : Container())
                                      : Container(),*/
                      ],
                    ))))
        : (widget.listVitals!.length > 0
            ? SizedBox(
                height: double.maxFinite,
                child: TabBarView(
                  children: widgetListForTabs(),
                ))
            : widget.emptyMessageWidget!);
  }

  List<Widget> widgetListForTabs() {
    if (widget.vitalGroupIDP == "2" ||
        widget.vitalGroupIDP == "3" ||
        widget.vitalGroupIDP == "5") {
      return listVitalsTabsWidgets;
    }

    if (widget.vitalGroupIDP == "4") {
      return listWeightHeightTabsWidgets;
    }

    if (widget.vitalGroupIDP == "6") {
      return listThyroidTabsWidgets;
    }

    return listBPTabsWidgets;
  }

  bool showCategoryTabs() {
    if ((widget.vitalIDP == "2" ||
            widget.vitalIDP == "4" ||
            widget.vitalIDP == "5" ||
            widget.vitalIDP == "6") &&
        widget.mainType == "chart") return true;
    return false;
  }

  String getVitalNameFromIDP(String vitalIDP) {
    switch (vitalIDP) {
      case "3":
        return "Pulse";
      case "4":
        return "Temperature";
      case "5":
        return "SPO2";
      case "10":
        return "Respiratory Rate";
      case "11":
        return "Weight";
      case "21":
        return "Height";
      case "12":
        return "BMI";
      case "13":
        return "Exercise";
      case "14":
        return "Walking";
      case "23":
        return "Waist";
      case "24":
        return "Hip";
      case "15":
        return "TSH";
      case "16":
        return "T3";
      case "17":
        return "T4";
      case "18":
        return "FreeT3";
      case "19":
        return "FreeT4";
      default:
        return "";
    }
  }

  Widget getParticularVitalChart() {
    switch (selectedCategoryIDP) {
      case "3":
        return MyEChart(
          key: keyForChart,
          chartTypeID: "1",
          titleOfChart: "Pulse (${widget.unit})",
          value: pulseValue.toDouble(),
        );
      case "4":
        return MyEChart(
          key: keyForChart,
          chartTypeID: "2",
          titleOfChart: "Temperature (\u2109)",
          value: tempValue.toDouble(),
        );
      case "5":
        return MyEChart(
          key: keyForChart,
          chartTypeID: "3",
          titleOfChart: "SPO2 (%)",
          value: spo2Value.toDouble(),
        );
      case "10":
        return MyEChart(
          key: keyForChart,
          chartTypeID: "4",
          titleOfChart: "RR (per min.)",
          value: rrValue.toDouble(),
        );
      default:
        return Container();
    }
    /*Column(
      children: [
        MyEChart(
          key: keyForChart,
          chartTypeID: "1",
          titleOfChart: "Pulse (${widget.unit})",
          value: pulseValue.toDouble(),
        ),
        MyEChart(
          key: keyForChart2,
          chartTypeID: "2",
          titleOfChart: "Temperature (\u2109)",
          value: tempValue.toDouble(),
        ),
        MyEChart(
          key: keyForChart3,
          chartTypeID: "3",
          titleOfChart: "SPO2 (%)",
          value: spo2Value.toDouble(),
        ),
        MyEChart(
          key: keyForChart4,
          chartTypeID: "4",
          titleOfChart: "RR (per min.)",
          value: rrValue.toDouble(),
        ),
      ],
    )*/
  }

  Widget getParticularWeightChart() {
    switch (selectedCategoryIDP) {
      case "11":
        return MyEChart(
          key: keyForChart!,
          chartTypeID: "1",
          titleOfChart: "Weight (${widget.unit})",
          value: weightValue.toDouble(),
        );
      case "21":
        return MyEChart(
          key: keyForChart!,
          chartTypeID: "2",
          titleOfChart: "Height (${widget.unit2})",
          value: heightValue.toDouble(),
        );
      case "12":
        return MyEChart(
          key: keyForChart!,
          chartTypeID: "3",
          titleOfChart: "BMI (${widget.unit3})",
          value: 0,
        );
      default:
        return Container();
    }
    /*Column(
      children: [
        MyEChart(
          key: keyForChart,
          chartTypeID: "1",
          titleOfChart: "Weight (${widget.unit})",
          value: weightValue.toDouble(),
        ),
        MyEChart(
          key: keyForChart2,
          chartTypeID: "2",
          titleOfChart: "Height (${widget.unit2})",
          value: heightValue.toDouble(),
        ),
        MyEChart(
          key: keyForChart3,
          chartTypeID: "3",
          titleOfChart: "BMI (${widget.unit3})",
          value: 0,
        ),
      ],
    )*/
  }

  Widget getParticularExerciseChart() {
    switch (selectedCategoryIDP) {
      case "13":
        return MyEChart(
          key: keyForChart,
          chartTypeID: "1",
          titleOfChart: "Exercise (Mins.)",
          value: exerciseValue.toDouble(),
        );
      case "14":
        return MyEChart(
          key: keyForChart,
          chartTypeID: "2",
          titleOfChart: "Walking (Steps)",
          value: walkingStepsValue.toDouble(),
        );
      case "23":
        return MyEChart(
          key: keyForChart,
          chartTypeID: "3",
          titleOfChart: "Waist (cm)",
          value: walkingStepsValue.toDouble(),
        );
      case "24":
        return MyEChart(
          key: keyForChart,
          chartTypeID: "4",
          titleOfChart: "Hip (cm)",
          value: walkingStepsValue.toDouble(),
        );
      default:
        return Container();
    }
    /*Column(
      children: [
        MyEChart(
          key: keyForChart,
          chartTypeID: "1",
          titleOfChart: "Exercise (Mins.)",
          value: exerciseValue.toDouble(),
        ),
        MyEChart(
          key: keyForChart2,
          chartTypeID: "2",
          titleOfChart: "Walking (Steps)",
          value: walkingStepsValue.toDouble(),
        ),
        MyEChart(
          key: keyForChart3,
          chartTypeID: "3",
          titleOfChart: "Waist (cm)",
          value: walkingStepsValue.toDouble(),
        ),
        MyEChart(
          key: keyForChart4,
          chartTypeID: "4",
          titleOfChart: "Hip (cm)",
          value: walkingStepsValue.toDouble(),
        )
      ],
    )*/
  }

  Widget getParticularThyroidChart() {
    switch (selectedCategoryIDP) {
      case "15":
        return MyEChart(
          key: keyForChart,
          chartTypeID: "1",
          titleOfChart: "TSH (uIU/mL)",
          value: 0,
        );
      case "16":
        return MyEChart(
          key: keyForChart2,
          chartTypeID: "2",
          titleOfChart: "T3 (ng/dL)",
          value: 0,
        );
      case "17":
        return MyEChart(
          key: keyForChart3,
          chartTypeID: "3",
          titleOfChart: "T4 (ug/dL)",
          value: 0,
        );
      case "18":
        return MyEChart(
          key: keyForChart4!,
          chartTypeID: "4",
          titleOfChart: "FreeT3 (pg/mL)",
          value: 0,
        );
      case "19":
        return MyEChart(
          key: keyForChart5!,
          chartTypeID: "6",
          titleOfChart: "FreeT4 (ng/dL)",
          value: 0,
        );
      default:
        return Container();
    }
    /*Column(
      children: [
        MyEChart(
          key: keyForChart,
          chartTypeID: "1",
          titleOfChart: "TSH (uIU/mL)",
          value: 0,
        ),
        MyEChart(
          key: keyForChart2,
          chartTypeID: "2",
          titleOfChart: "T3 (ng/dL)",
          value: 0,
        ),
        MyEChart(
          key: keyForChart3,
          chartTypeID: "3",
          titleOfChart: "T4 (ug/dL)",
          value: 0,
        ),
        MyEChart(
          key: keyForChart4,
          chartTypeID: "4",
          titleOfChart: "FreeT3 (pg/mL)",
          value: 0,
        ),
        MyEChart(
          key: keyForChart5,
          chartTypeID: "6",
          titleOfChart: "FreeT4 (ng/dL)",
          value: 0,
        ),
      ],
    )*/
  }
}

class MyEChart extends StatefulWidget {
  String? chartTypeID, titleOfChart;
  double? value;

  MyEChart({Key? key, this.chartTypeID, this.titleOfChart, this.value})
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

  var listOnlyString, listOnlyDate, listOnlyByWhom;
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
    } else if (widget.chartTypeID == "6") {
      color = "'rgb(75, 0, 130)'";
      colorRGB = Color.fromRGBO(75, 0, 130, 1);
    }

    series =
        "[{data: $yAxisData,type: 'line',symbol: 'circle',symbolSize: 8,symbol: 'circle',symbolSize: 8,smooth: true,itemStyle: {color: $color},},]";

    if (widget.chartTypeID == "1" || widget.chartTypeID == "5") {
      listOnlyString = listVitalOnlyString;
      listOnlyDate = listVitalOnlyStringDate;
      listOnlyByWhom = listVitalByWhom;
    } else if (widget.chartTypeID == "2") {
      listOnlyString = listVitalOnlyString2;
      listOnlyDate = listVitalOnlyStringDate2;
      listOnlyByWhom = listVital2ByWhom;
    } else if (widget.chartTypeID == "3") {
      listOnlyString = listVitalOnlyString3;
      listOnlyDate = listVitalOnlyStringDate3;
      listOnlyByWhom = listVital3ByWhom;
    } else if (widget.chartTypeID == "4") {
      listOnlyString = listVitalOnlyString4;
      listOnlyDate = listVitalOnlyStringDate4;
      listOnlyByWhom = listVital4ByWhom;
    } else if (widget.chartTypeID == "6") {
      listOnlyString = listVitalOnlyString5;
      listOnlyDate = listVitalOnlyStringDate5;
      listOnlyByWhom = listVital5ByWhom;
    }

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
              "[{value:${double.parse(listOnlyString[i]).round().toInt()},name:'${listOnlyByWhom[i]}'},");
        else if (i == listOnlyString.length - 1)
          yAxisData.write(
              "{value:${double.parse(listOnlyString[i]).round().toInt()},name:'${listOnlyByWhom[i]}'}]");
        else
          yAxisData.write(
              "{value:${double.parse(listOnlyString[i]).round().toInt()},name:'${listOnlyByWhom[i]}'},");

        if (i == 0)
          xAxisDatesData.write("['${listOnlyDate[i]}',");
        else if (i == listOnlyDate.length - 1)
          xAxisDatesData.write("'${listOnlyDate[i]}']");
        else
          xAxisDatesData.write("'${listOnlyDate[i]}',");
      }
    } else if (listOnlyString.length == 1) {
      yAxisData.write(
          "[{value:${double.parse(listOnlyString[0]).round().toInt()},name:'${listOnlyByWhom[0]}'}]");
      xAxisDatesData.write("['${listOnlyDate[0]}']");
    }
    debugPrint("y axis series data");
    debugPrint(yAxisData.toString());

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
                "[{value:${double.parse(listVitalOnlyString2[i]).round().toInt()},name:'${listOnlyByWhom[i]}'},");
          else if (i == listVitalOnlyString2.length - 1)
            yAxisData2.write(
                "{value:${double.parse(listVitalOnlyString2[i]).round().toInt()},name:'${listOnlyByWhom[i]}'}]");
          else
            yAxisData2.write(
                "{value:${double.parse(listVitalOnlyString2[i]).round().toInt()},name:'${listOnlyByWhom[i]}'},");
        }
      } else if (listOnlyString.length == 1) {
        yAxisData2.write(
            "[{value:${double.parse(listVitalOnlyString2[0]).round().toInt()},name:'${listOnlyByWhom[0]}'}]");
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
    print('yAxisData ${yAxisData}');
    print('widget.chartTypeID');
    return listOnlyString.length > 0
        ? /*Column(
      children: [
        Text("Share button here"),
        SizedBox(height: 10,),*/
        Container(
            width: SizeConfig.screenWidth,
            height: SizeConfig.blockSizeVertical! * 60,
            child: widget.chartTypeID != "5"
                ? EchartsCustom(
                    option:
                        '''
                        {
                          grid: {
                                 right: '12%',
                                 left: '12%',
                              },
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
                            lineOverflow: 'none',
                            min: $minValueStr,
                          },
                          legend: {
                            show: true,
                            data: [{name: '${widget.titleOfChart}', icon: 'square', textStyle: {color: $color}}]
                          },
                          series: [
                          {data: $yAxisData,
                          type: 'line',symbol: 'circle',symbolSize: 8,symbol: 'circle',symbolSize: 8,smooth: true,itemStyle: {color: $color},
                          name:'${widget.titleOfChart}'}
                          ]
                        }
                        ''',
/*                          min: 200,
                            max: 250,*/
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
                          grid: {
                                 right: '12%',
                                 left: '12%',
                              },
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
                                    var xx = colorSpan(item.color) + ' ' + item.seriesName + ': ' + item.data.value + '</br>';
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
                          series: [
                          {data: $yAxisData,type: 'line',symbol: 'circle',symbolSize: 8,smooth: true,itemStyle: {color: 'rgb(255, 0, 0)'},
                           name:'Systolic (mm of hg)'},
                          {data: $yAxisData2,type: 'line',symbol: 'circle',symbolSize: 8,smooth: true,itemStyle: {color: 'rgb(0, 145, 234)'}, name:'Diastolic (mm of hg)'}]
                        }
                        ''',
                  ),
          )
        : Container();
  }
}
