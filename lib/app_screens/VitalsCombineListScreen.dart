import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:swasthyasetu/api/api_helper.dart';

//import 'package:share_extend/share_extend.dart';
import 'package:swasthyasetu/app_screens/add_vital_screen.dart';
import 'package:swasthyasetu/app_screens/water_intake_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/dropdown_item.dart';
import 'package:swasthyasetu/podo/model_graph_values.dart';
import 'package:swasthyasetu/podo/model_vitals_list.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/common_methods.dart';
import 'package:swasthyasetu/utils/flutter_echarts_custom.dart';

//import 'package:progress_dialog/progress_dialog.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:swasthyasetu/widgets/date_range_picker_custom.dart'
as DateRagePicker;
import 'package:syncfusion_flutter_charts/charts.dart';
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

List<ModelGraphValues> listBPSystolic = [];
List<ModelGraphValues> listBPDiastolic = [];

List<ModelGraphValues> listVital = [];

//  Continue from here
List<ModelGraphValues> listVital2 = [];
List<String> listVitalByWhom = [];
List<String> listVital2ByWhom = [];

List<String> listChartType = [];

List<double> listVitalOnlyString = [];
List<double> listVitalOnlyString2 = [];

List<String> listVitalOnlyStringDate = [];
List<String> listVitalOnlyStringDate2 = [];

var chartType = "";

int bpSystolicValue = 30,
    bpDiastolicValue = 10;


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

class VitalsCombineListScreen extends StatefulWidget {
  List<ModelVitalsList> listVitals = [];
  String? patientIDP = "";
  String? vitalIDP = "",
      vitalIDP2 = "";
  String? vitalGroupIDP = "";
  String unit = "", unit2 = "", unit3 = "", unit4 = "", unit5 = "";
  DropDownItem selectedCountry = DropDownItem("", "");
  DropDownItem selectedState = DropDownItem("", "");
  DropDownItem selectedCity = DropDownItem("", "");

  var fromDate = DateTime.now().subtract(Duration(days: 7));
  var toDate = DateTime.now();

  var fromDateString = "";
  var toDateString = "";
  var dateString = "Select Date Range";

  var mainType = "chart";

  ProgressDialog? pr;

  String emptyTextBP1 = "Sit up right";
  String emptyTextBP2 = "Back supported";
  String emptyTextBP3 = "Bp instrument at the level of heart";
  String emptyTextBP4 = "It is important to Measure regularly.";

  /*String emptyTextSugar1 =
      "Blood sugar monitoring is very necessery to maintain your health.";
  String emptyTextSugar2 =
      "Monitor your Blood sugar level regularly and share to your doctor very easily.";
  String emptyTextSugar3 =
      "Monitor and record your Blood Sugar values as Fasting Sugar (FBS), Sugar after Lunch (PPBS), RBS, HbA1C by selecting PLUS button from the bottom od screen.";*/


  String emptyMessage = "";

  Widget? emptyMessageWidget;

  bool shouldShowEmptyMessageWidget = true;

  VitalsCombineListScreen(String patientIDP, String vitalIDP) {
    this.patientIDP = patientIDP;
    this.vitalIDP = vitalIDP;
    this.vitalGroupIDP = vitalIDP;
    vitalIDPGlobal = vitalIDP;
  }

  @override
  State<StatefulWidget> createState() {
    return VitalsCombineListScreenState();
  }
}

String encodeBase64(String text) {
  var bytes = utf8.encode(text);
  //var base64str =
  return base64.encode(bytes);
  //= Base64Encoder
  // ().convert()
}

String decodeBase64(String text) {
  //var bytes = utf8.encode(text);
  //var base64str =
  var bytes = base64.decode(text);
  return String.fromCharCodes(bytes);
  //= Base64Encoder().convert()
}

class VitalsCombineListScreenState extends State<VitalsCombineListScreen> {
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

  int vitalsAPICount = 0;
  ApiHelper apiHelper = ApiHelper();

  List<DropDownItem> listCategories = [];
  String selectedCategoryIDP = "0";
  String selectedCategory = "";
  int originalSize = 800;
  bool isDraw = false;
  late DateTimeRange dateRange;

  @override
  void dispose()
  {
    keyForChart = null;
    keyForChart2 = null;
    listVital = [];
    listVital2 = [];
    widget.listVitals = [];
    listVitalOnlyString = [];
    listVitalOnlyString2 = [];
    listVitalOnlyStringDate = [];
    listVitalOnlyStringDate2 = [];
    super.dispose();
  }

  void setListsForTabs() {
    listBPTabsWidgets = [
      widget.vitalGroupIDP == "1"
          ? widget.listVitals.length > 0
          ?
      ListView.builder(
          padding: const EdgeInsets.only(
              bottom: kFloatingActionButtonMargin + 60),
          itemCount: widget.listVitals.length,
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return InkWell(
                onTap: () {},
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
                                  // Container(
                                  //   margin: EdgeInsets.all(5.0),
                                  //   padding: EdgeInsets.all(5.0),
                                  //   decoration: BoxDecoration(
                                  //       shape: BoxShape.circle,
                                  //       gradient: LinearGradient(
                                  //           begin: Alignment.topLeft,
                                  //           end: Alignment.bottomRight,
                                  //           colors: [
                                  //             Colors.white,
                                  //             Color(0xFF636F7B),
                                  //             Colors.black,
                                  //           ]),
                                  //       color: Color(0xFF636F7B)),
                                  //   child: Text(
                                  //     "${index + 1}",
                                  //     style: TextStyle(
                                  //         color: Colors.white,
                                  //         fontSize: SizeConfig
                                  //             .blockSizeVertical *
                                  //             2.3),
                                  //   ),
                                  // ),
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
                                            "${widget.listVitals[index].vitalEntryDate}",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: SizeConfig
                                                  .blockSizeVertical !*
                                                  2.3,
                                            ),
                                          ),
                                          Text(
                                            ' (${widget.listVitals[index].vitalEntryTime})',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: SizeConfig
                                                  .blockSizeVertical !*
                                                  2.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: SizeConfig
                                            .blockSizeVertical !*
                                            0.8,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  widget.vitalGroupIDP ==
                                                      "2"
                                                      ? "Pulse"
                                                      : (widget.vitalGroupIDP ==
                                                      "1"
                                                      ? "Systolic"
                                                      : title1),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color:
                                                    Color(0xFF636F7B),
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    fontSize: SizeConfig
                                                        .blockSizeVertical !*
                                                        2.2,
                                                  ),
                                                ),
                                                Text(
                                                  // "${listVital[index].value} (${widget.unit})",
                                                  "${listVital[index].value}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color:
                                                    Color(0xFF636F7B),
                                                    fontSize: SizeConfig
                                                        .blockSizeVertical !*
                                                        2.2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 20,height: 20,),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  widget.vitalGroupIDP ==
                                                      "1"
                                                      ? "Diastolic"
                                                      : "$title2 (${widget.unit2}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color:
                                                    Color(0xFF636F7B),
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    fontSize: SizeConfig
                                                        .blockSizeVertical !*
                                                        2.2,
                                                  ),
                                                ),
                                                Text(
                                                  // "${listVital2[index].value} (${widget.unit2})",
                                                  "${listVital2[index].value})",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color:
                                                    Color(0xFF636F7B),
                                                    fontSize: SizeConfig
                                                        .blockSizeVertical !*
                                                        2.1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 20,height: 20,),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("Entry By",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color:
                                                    Color(0xFF636F7B),
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    fontSize: SizeConfig
                                                        .blockSizeVertical !*
                                                        2.2,
                                                  ),
                                                ),
                                                Text(
                                                  // "${listVital2[index].value} (${widget.unit2})",
                                                  "${listVital2[index].byWhom}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color:
                                                    Color(0xFF636F7B),
                                                    fontSize: SizeConfig
                                                        .blockSizeVertical !*
                                                        2.1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
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
          : widget.listVitals.length > 0
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
                                  Container(
                                    margin: EdgeInsets.all(5.0),
                                    padding: EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              Color(0xFF636F7B),
                                              Colors.black,
                                            ]),
                                        color: Color(0xFF636F7B)),
                                    child: Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: SizeConfig
                                              .blockSizeVertical !*
                                              2.3),
                                    ),
                                  ),
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
                                            "${listVital[index].date} - ",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: SizeConfig
                                                  .blockSizeVertical !*
                                                  2.3,
                                            ),
                                          ),
                                          Text(
                                            "${listVital[index].time}",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: SizeConfig
                                                  .blockSizeVertical !*
                                                  2.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: SizeConfig
                                            .blockSizeVertical !*
                                            0.8,
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              widget.vitalGroupIDP ==
                                                  "2"
                                                  ? "Pulse"
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
                                                    .blockSizeVertical !*
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
                                                    .blockSizeVertical !*
                                                    2.1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text("---"),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                            listVital[index].byWhom!),
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
                                  Container(
                                    margin: EdgeInsets.all(5.0),
                                    padding: EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              Color(0xFF636F7B),
                                              Colors.black,
                                            ]),
                                        color: Color(0xFF636F7B)),
                                    child: Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                          SizeConfig.blockSizeVertical !*
                                              2.3),
                                    ),
                                  ),
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
                                            "${listVital2[index].date} - ",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: SizeConfig
                                                  .blockSizeVertical !*
                                                  2.3,
                                            ),
                                          ),
                                          Text(
                                            "${listVital2[index].time}",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: SizeConfig
                                                  .blockSizeVertical !*
                                                  2.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                        SizeConfig.blockSizeVertical !*
                                            0.8,
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              widget.vitalGroupIDP == "2"
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
                                                color: Color(0xFF636F7B),
                                                fontWeight: FontWeight.w500,
                                                fontSize: SizeConfig
                                                    .blockSizeVertical !*
                                                    2.1,
                                              ),
                                            ),
                                            Text(
                                              " -  ${listVital2[index].value} (${widget.unit2})",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Color(0xFF636F7B),
                                                fontSize: SizeConfig
                                                    .blockSizeVertical !*
                                                    2.1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text("---"),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child:
                                        Text(listVital2[index].byWhom!),
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
          ?
      ListView.builder(
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
                                  Container(
                                    margin: EdgeInsets.all(5.0),
                                    padding: EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              Color(0xFF636F7B),
                                              Colors.black,
                                            ]),
                                        color: Color(0xFF636F7B)),
                                    child: Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                          SizeConfig.blockSizeVertical !*
                                              2.3),
                                    ),
                                  ),
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
                                            "${listVital[index].date} - ",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: SizeConfig
                                                  .blockSizeVertical !*
                                                  2.3,
                                            ),
                                          ),
                                          Text(
                                            "${listVital[index].time}",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: SizeConfig
                                                  .blockSizeVertical !*
                                                  2.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                        SizeConfig.blockSizeVertical !*
                                            0.8,
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              widget.vitalGroupIDP == "2"
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
                                                color: Color(0xFF636F7B),
                                                fontWeight: FontWeight.w500,
                                                fontSize: SizeConfig
                                                    .blockSizeVertical !*
                                                    2.1,
                                              ),
                                            ),
                                            Text(
                                              " -  ${listVital[index].value} (${widget.unit})",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Color(0xFF636F7B),
                                                fontSize: SizeConfig
                                                    .blockSizeVertical !*
                                                    2.1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text("---"),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child:
                                        Text(listVital[index].byWhom!),
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
                                  Container(
                                    margin: EdgeInsets.all(5.0),
                                    padding: EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              Color(0xFF636F7B),
                                              Colors.black,
                                            ]),
                                        color: Color(0xFF636F7B)),
                                    child: Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                          SizeConfig.blockSizeVertical !*
                                              2.3),
                                    ),
                                  ),
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
                                            "${listVital2[index].date} - ",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: SizeConfig
                                                  .blockSizeVertical !*
                                                  2.3,
                                            ),
                                          ),
                                          Text(
                                            "${listVital2[index].time}",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: SizeConfig
                                                  .blockSizeVertical !*
                                                  2.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                        SizeConfig.blockSizeVertical !*
                                            0.8,
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              "BP Diastolic",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Color(0xFF636F7B),
                                                fontWeight: FontWeight.w500,
                                                fontSize: SizeConfig
                                                    .blockSizeVertical !*
                                                    2.1,
                                              ),
                                            ),
                                            Text(
                                              " -  ${listVital2[index].value} (${widget.unit2})",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Color(0xFF636F7B),
                                                fontSize: SizeConfig
                                                    .blockSizeVertical !*
                                                    2.1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text("---"),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child:
                                        Text(listVital2[index].byWhom!),
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
          : widget.emptyMessageWidget!
    ];
  }

  @override
  void initState() {
    super.initState();
    keyForChart = GlobalKey();
    keyForChart2 = GlobalKey();
    listVitalIDPs = [];
    vitalsAPICount = 0;
    listVitalIDPs.add("1");
    listVitalIDPs.add("2");
    title = "Blood Pressure";
    title1 = "Blood Pressure";
    widget.emptyMessage =
    "${widget.emptyTextBP1}\n\n${widget.emptyTextBP2}\n\n${widget.emptyTextBP3}\n\n${widget.emptyTextBP4}";
    widget.unit = "mm of hg";
    widget.unit2 = "mm of hg";

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

    setListsForTabs();

    // var formatter = new DateFormat('dd-MM-yyyy');
    /*widget.fromDateString = formatter.format(widget.fromDate);
    widget.toDateString = formatter.format(widget.toDate);*/
    widget.dateString = "Select Date Range";
    var formatter = new DateFormat('dd-MM-yyyy');
    widget.fromDate = DateTime.now().subtract(const Duration(days: 30));
    widget.toDate = DateTime.now();
    widget.fromDateString = formatter.format(widget.fromDate!);
    widget.toDateString = formatter.format(widget.toDate!);
    dateRange = DateTimeRange(
        start: widget.fromDate!,
        end: widget.toDate!
    );
    listChartType = [];
    listChartType.add("BP Systolic");
    listChartType.add("BP Diastolic");
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
    getVitalsList();
    // this is done as list data will come then graph will be plotted
    Future.delayed(const Duration(milliseconds: 2000), () {
      debugPrint("reload called");
      isDraw = true;
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return DefaultTabController(
      length: getVitalTabsLength(),
      child: Scaffold(
        /*key: navigatorKey,*/
        appBar: AppBar(
          title: Text(title, style: TextStyle(color: Colorsblack)),
          centerTitle: true,
          bottom:
          (widget.vitalGroupIDP == "4" && widget.mainType == "list"
              ? TabBar(
            tabs: <Widget>[
              Tab(
                child: Text("Weight"),
              ),
              Tab(
                child: Text("Height"),
              ),
              Tab(
                child: Text("BMI"),
              ),
            ],
          )
              : (widget.vitalGroupIDP == "5" &&
              widget.mainType == "list"
              ? TabBar(
            tabs: <Widget>[
              Tab(
                child: Text("Exercise"),
              ),
              Tab(
                child: Text("Walking"),
              ),
              Tab(
                child: Text("Waist"),
              ),
              Tab(
                child: Text("Hip"),
              ),
            ],
          )
              : (widget.vitalGroupIDP == "6" &&
              widget.mainType == "list"
              ? TabBar(
            tabs: <Widget>[
              Tab(
                child: Text("TSH"),
              ),
              Tab(
                child: Text("T3"),
              ),
              Tab(
                child: Text("T4"),
              ),
              Tab(
                child: Text("FreeT3"),
              ),
              Tab(
                child: Text("FreeT4"),
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
              color: Colorsblack, size: SizeConfig.blockSizeVertical !* 2.5), toolbarTextStyle: TextTheme(
              titleMedium: TextStyle(
                  color: Colorsblack,
                  fontFamily: "Ubuntu",
                  fontSize: SizeConfig.blockSizeVertical !* 2.5)).bodyMedium, titleTextStyle: TextTheme(
              titleMedium: TextStyle(
                  color: Colorsblack,
                  fontFamily: "Ubuntu",
                  fontSize: SizeConfig.blockSizeVertical !* 2.5)).titleLarge,
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
                            widget.patientIDP!, widget.vitalIDP!))).then((value) {
                  getVitalsList();
                });
              }
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.black,
          ),
        ),
        body: RefreshIndicator(
          child:
          ListView(
            shrinkWrap: true,
            controller: hideFABController,
            children: <Widget>[
              //DateTimeComboLinePointChart.withSampleData(),
              //LineChartSample1(),
              SizedBox(
                height: 5.0,
              ),
              Container(
                height: SizeConfig.blockSizeVertical !* 8,
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
                                    SizeConfig.blockSizeVertical !* 2.6,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                              ),
                            ),
                            Container(
                              width: SizeConfig.blockSizeHorizontal !* 15,
                              child: Icon(
                                Icons.arrow_drop_down,
                                size: SizeConfig.blockSizeHorizontal !* 8,
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
              SizedBox(
                height: 5.0,
              ),
              showCategoryTabs() && listCategories.length > 0
                  ? Container(
                  height: SizeConfig.blockSizeVertical !* 10,
                  width: SizeConfig.blockSizeHorizontal !* 100,
                  color: Color(0xFFF0F0F0),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: SizeConfig.blockSizeHorizontal !* 2,
                        right: SizeConfig.blockSizeHorizontal !* 2),
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
                                  SizeConfig.blockSizeHorizontal !* 3),
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
                            width: SizeConfig.blockSizeHorizontal !* 5,
                          );
                        },
                      ),
                    ),
                  ))
                  : Container(),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 2,
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 0.5,
              ),
              (isDraw == true) ? getMainWidget() : Container(),
            ],
          ),
          onRefresh: () {
            return getVitalsList();
          },
        ),
      ),
    );
  }

  Future<void> showDateRangePickerDialog() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if(newDateRange == null) return;

    setState(() {
      dateRange = newDateRange;
      widget.fromDate = dateRange.start;
      widget.toDate = dateRange.end;
      var formatter = new DateFormat('dd-MM-yyyy');
      widget.fromDateString = formatter.format(widget.fromDate!);
      widget.toDateString = formatter.format(widget.toDate!);
      setListsForTabs();
      getVitalsList();
    });
    // final List<DateTime?>? listPicked = await DateRagePicker.showDatePicker(
    //     context: context,
    //     initialFirstDate: widget.fromDate,
    //     initialLastDate: widget.toDate,
    //     firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
    //     lastDate: DateTime.now(),
    //     handleOk: () {},
    //     handleCancel: () {});
    // if (listPicked!.length == 2) {
    //   widget.fromDate = listPicked[0]!;
    //   widget.toDate = listPicked[1]!;
    //   var formatter = new DateFormat('dd-MM-yyyy');
    //   widget.fromDateString = formatter.format(widget.fromDate);
    //   widget.toDateString = formatter.format(widget.toDate);
    //   widget.dateString =
    //   "${widget.fromDateString}  to  ${widget.toDateString}";
    //   setState(() {
    //     setListsForTabs();
    //     getVitalsList();
    //   });
    // }
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
    //       widget.fromDate = start;
    //       widget.toDate = end;
    //       var formatter = new DateFormat('dd-MM-yyyy');
    //       widget.fromDateString = formatter.format(widget.fromDate);
    //       widget.toDateString = formatter.format(widget.toDate);
    //       widget.dateString =
    //       "${widget.fromDateString}  to  ${widget.toDateString}";
    //       setListsForTabs();
    //           getVitalsList();
    //       //print(picked);
    //     });
    //   },
    //   onCancelClick: () {
    //     setState(() {
    //       widget.fromDate = DateTime.now().subtract(Duration(days: 7));
    //       widget.toDate = DateTime.now();
    //       setListsForTabs();
    //           getVitalsList();
    //     });
    //   },
    // );
  }

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
        debugPrint("calling api with Vital idp - ${listVitalIDPs[0]} ${listVitalIDPs[1]}");
        getVitalsListWithVitalIDP(listVitalIDPs[0], 0 + 1);
        getVitalsListWithVitalIDP(listVitalIDPs[1], 1 + 1);
        debugPrint(
            "Categories list length inside for loop - ${listCategories.length}");
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
  //   if(boundary ==null)
  //   {
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

  Future<String?> getVitalsListWithVitalIDP(
      String vitalIDP, int vitalSerialNo) async {
    print('getVitalsListWithVitalIDP');
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

    debugPrint('jsonStr');
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
        if (!getWidgetVitalsList(vitalSerialNo).contains(model))
          getWidgetVitalsList(vitalSerialNo).add(model);
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
        getVitalOnlyStringList(vitalSerialNo).add(double.parse(jo['VitalValue']));
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
      if (vitalsAPICount == 2) {
        widget.pr!.hide();
        debugPrint('vitalsAPICount ${vitalsAPICount}');
        debugPrint("Categories list length - ${listCategories.length}");
        // if (listCategories.length > 0 && showCategoryTabs()) {
        //   debugPrint(
        //       "Let's check categories first list - ${listCategories[0].idp}");
        //   setState(() {
        //     selectedCategoryIDP = listCategories[0].idp;
        //   });
        // }
      }
      setState(() {
        setStateOfTheEChartWidget();
        setListsForTabs();
      });
    }
    return null;
  }

  Future<String?> getVitalsListActual() async {
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
    listBPSystolic = [];
    listBPDiastolic = [];

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
        if (!widget.listVitals.contains(model)) widget.listVitals.add(model);
        String byWhom = "";
        if (jo['doctorentrystatus'] == "0")
          byWhom = "Entry by - Patient";
        else
          byWhom = "Entry by - Doctor";
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
      if (widget.listVitals.length > 0)
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
        if (!widget.listVitals.contains(model)) widget.listVitals.add(model);
        String byWhom = "";
        if (jo['doctorentrystatus'] == "0")
          byWhom = "Entry by - Patient";
        else
          byWhom = "Entry by - Doctor";
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
      if (widget.listVitals.length > 0)
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
    if (keyForChart == null)
      debugPrint("key null");
    else if (keyForChart!.currentState == null)
      debugPrint("currentState null");
    else {
      debugPrint("nothing null, setting state of chart - chart 1 idp - 1");
      keyForChart!.currentState!.setStateInsideTheChart();
    }
  }

  Widget getChartsWidgets() {
    switch (widget.vitalGroupIDP) {
      case "1":
        return getBPCharts();
        break;
      default:
        return Container();
    }
  }

  Widget getBPCharts() {
    return !widget.shouldShowEmptyMessageWidget
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: ()
          {
            shareImage(globalKey);
          },
          child: Icon(
            Icons.share,
            color: Colors.lightGreen,
          ),
        ),
        RepaintBoundary(
         key: globalKey,
         child: MyEChart(
             key: keyForChart!,
             chartTypeID: "1",
             titleOfChart: "BP",
             value: bpSystolicValue.toDouble(),
             value2: bpDiastolicValue.toDouble()
         ),
        )
      ],
    )
        : Container();
  }

  List<ModelVitalsList> getWidgetVitalsList(int i) {
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
      default:
        return [];
    }
  }

  List<double> getVitalOnlyStringList(int i) {
    switch (i) {
      case 1:
        return listVitalOnlyString;
        break;
      case 2:
        return listVitalOnlyString2;
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

  void reloadInHalfASecond() {
    Future.delayed(const Duration(milliseconds: 500), () {
      debugPrint("reload called");
      /*var html = await */ //await _controller.clearCache();
    });
  }

  Widget getMainWidget() {
    return widget.mainType == "chart"
        ? //DateTimeComboLinePointChart.withSampleData()
        Container(
          width: SizeConfig.screenWidth,
          color: Colors.white,
          child: Padding(
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  // Visibility(
                  //                   visible: widget.mainType == "chart" &&
                  //                       listVital != null &&
                  //                       listVital.length > 0,
                  //                   child: Column(
                  //                     children: <Widget>[],
                  //                   )),
                  //               SizedBox(
                  //                 height: SizeConfig.blockSizeVertical !* 1,
                  //               ),
                  widget.shouldShowEmptyMessageWidget
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
              )))
        : (widget.listVitals.length > 0
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
}

class MyEChart extends StatefulWidget {
  String? chartTypeID, titleOfChart;
  double? value,value2;


  MyEChart({Key? key, this.chartTypeID, this.titleOfChart, this.value, this.value2})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyEChartState();
  }
}
class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}

class MyEChartState extends State<MyEChart> {
  List<double> yAxisData = [];
  List<String> xAxisDatesData = [];
  List<double> yAxisData2 = [];

  var color,color2;
  var colorRGB,colorRGB2;
  var series;

//  var listOnlyString, listOnlyDate, listOnlyByWhom;
//  var listOnlyString2, listOnlyDate2, listOnlyByWhom2;
  int minYValue = 0;
  String minValueStr = "0";
  List<_ChartData> data = [];
  List<_ChartData> data2 = [];
  late ZoomPanBehavior _zoomPanBehavior;
  TooltipBehavior? _tooltipBehaviour;

  void setStateInsideTheChart() {
    debugPrint("Let's set chart state");
    yAxisData = [];
    yAxisData2 = [];
    xAxisDatesData = [];
    data = [];
    color = "'rgb(255, 0, 0)'";
    colorRGB = Color.fromRGBO(255, 0, 0, 1);
    color2 = "'rgb(0, 145, 234)'";
    colorRGB2 = Color.fromRGBO(0, 0, 255, 1);

    series = "[{data: $yAxisData,type: 'line',symbol: 'circle',symbolSize: 8,symbol: 'circle',symbolSize: 8,smooth: true,itemStyle: {color: $color},},]";

    if (widget.chartTypeID == "1")
    {
      yAxisData = listVitalOnlyString;
      yAxisData2 = listVitalOnlyString2;
      xAxisDatesData = listVitalOnlyStringDate;
    }

    // List<int> listOnlyInt = [];
    // for (int i = 0; i < listOnlyString.length; i++) {
    //   listOnlyInt.add(double.parse(listOnlyString[i]).round().toInt());
    // }
    //
    // List<int> listOnlyInt2 = [];
    // for (int i = 0; i < listOnlyString2.length; i++)
    // {
    //   listOnlyInt2.add(double.parse(listOnlyString2[i]).round().toInt());
    // }

    // if (listOnlyInt.length > 0)
    //   minYValue = listOnlyInt.reduce((curr, next) => curr < next ? curr : next);

    // if (listOnlyString.length > 1)
    // {
    //   for (int i = 0; i < listOnlyString.length; i++) {
    //     if (i == 0)
    //       {
    //         yAxisData.add("[{value:${double.parse(listOnlyString[i]).round().toInt()}"
    //             ",name:'${listOnlyByWhom[i]}'},");
    //       }
    //     else if (i == listOnlyString.length - 1)
    //       {
    //         yAxisData.add(
    //             "{value:${double.parse(listOnlyString[i]).round().toInt()},name:'${listOnlyByWhom[i]}'}]");
    //       }
    //     else
    //       {
    //         yAxisData.add(
    //             "{value:${double.parse(listOnlyString[i]).round().toInt()},name:'${listOnlyByWhom[i]}'},");
    //       }
    //
    //     if (i == 0)
    //       xAxisDatesData.add(listOnlyDate[i]);
    //     else if (i == listOnlyDate.length - 1)
    //       xAxisDatesData.add(listOnlyDate[i]);
    //     else
    //       xAxisDatesData.add(listOnlyDate[i]);
    //
    //     data.add(new _ChartData(listOnlyDate[i],double.parse(listOnlyString[i]).round().toDouble()));
    //
    //     print("Values");
    //     print(listOnlyDate[i]);
    //     print(listOnlyString[i]);
    //     print("ChartData ${data[i].x} ${data[i].y}");
    //   }
    // } else if (listOnlyString.length == 1) {
    //   yAxisData.add(
    //       "[{value:${double.parse(listOnlyString[0]).round().toInt()},name:'${listOnlyByWhom[0]}'}]");
    //   xAxisDatesData.add(listOnlyDate[0]);
    //   data.add(new _ChartData(listOnlyDate[0],double.parse(listOnlyString[0]).round().toDouble()));
    //   print("ChartData ${data[0].x} ${data[0].y}");
    // }

    // if (listOnlyString2.length > 1) {
    //   for (int i = 0; i < listOnlyString2.length; i++) {
    //     if (i == 0)
    //       yAxisData2.add(
    //           "[{value:${double.parse(listOnlyString2[i]).round().toInt()},name:'${listOnlyByWhom2[i]}'},");
    //     else if (i == listOnlyString2.length - 1)
    //       yAxisData2.add(
    //           "{value:${double.parse(listOnlyString2[i]).round().toInt()},name:'${listOnlyByWhom2[i]}'}]");
    //     else
    //       yAxisData2.add(
    //           "{value:${double.parse(listOnlyString2[i]).round().toInt()},name:'${listOnlyByWhom2[i]}'},");
    //
    //     if (i == 0)
    //       xAxisDatesData.add(listOnlyDate2[i]);
    //     else if (i == listOnlyDate.length - 1)
    //       xAxisDatesData.add(listOnlyDate2[i]);
    //     else
    //       xAxisDatesData.add(listOnlyDate2[i]);
    //     data.add(new _ChartData(listOnlyDate2[i],double.parse(listOnlyString2[i]).round().toDouble()));
    //     print("ChartData ${data[i].x} ${data[i].y}");
    //   }
    // } else if (listOnlyString.length == 1) {
    //   yAxisData.add(
    //       "[{value:${double.parse(listOnlyString[0]).round().toInt()},name:'${listOnlyByWhom[0]}'}]");
    //   yAxisData2.add(
    //       "[{value:${double.parse(listOnlyString2[0]).round().toInt()},name:'${listOnlyByWhom2[0]}'}]");
    //   xAxisDatesData.add(listOnlyDate[0]);
    //   data.add(new _ChartData(listOnlyDate[0],double.parse(listOnlyString2[0]).round().toDouble()));
    //   print("ChartData ${data[0].x} ${data[0].y}");
    // }
    // debugPrint("y axis series data");
    // debugPrint(yAxisData.toString());
    // debugPrint(yAxisData2.toString());
    // print("ChartData ${data[0].x} ${data[0].y}");
    for(int i=0;i<yAxisData.length;i++)
      {
        data.add(new _ChartData(xAxisDatesData[i],yAxisData[i]));
      }
    for(int i=0;i<yAxisData.length;i++)
    {
      data2.add(new _ChartData(xAxisDatesData[i],yAxisData2[i]));
    }
    print("Values");
    print("ChartData ${data.toString()}");
    print("ChartData2 ${data2.toString()}");
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
    _zoomPanBehavior = ZoomPanBehavior(
      // Enables pinch zooming
        enablePinching: true
    );
    _tooltipBehaviour = TooltipBehavior(enable: true);
    // _tooltipBehaviour = TooltipBehavior(
    //     enable: true,
    //     format: 'point.y%'
    // );
    setStateInsideTheChart();
  }

  @override
  Widget build(BuildContext context) {
  //  minValueStr = widget.value.toString();
    return /*Column(
      children: [
        Text("Share button here"),
        SizedBox(height: 10,),*/
      (yAxisData.length) > 0 ?
      Container(
        color: Colors.white,
      width: SizeConfig.screenWidth,
      height: SizeConfig.blockSizeVertical !* 60,
      child:
      SfCartesianChart(
          zoomPanBehavior: _zoomPanBehavior,
          primaryXAxis: CategoryAxis(),
          legend: Legend(isVisible:true),
          tooltipBehavior: _tooltipBehaviour,
          series: <ChartSeries>[
            LineSeries<_ChartData, String>(
                name: 'BP Systolic',
                dataSource: data,
                enableTooltip: true,
                xValueMapper: (_ChartData data, _) => data.x,
                yValueMapper: (_ChartData data, _) => data.y,
                dataLabelSettings: DataLabelSettings(isVisible:true)
            ),
            LineSeries<_ChartData, String>(
                name: 'BP Diastolic',
                dataSource: data2,
                enableTooltip: true,
                xValueMapper: (_ChartData data2, _) => data2.x,
                yValueMapper: (_ChartData data2, _) => data2.y,
                dataLabelSettings: DataLabelSettings(isVisible:true)
            ),
          ]
      )
    )
        : Container()
    ;
  }
}
