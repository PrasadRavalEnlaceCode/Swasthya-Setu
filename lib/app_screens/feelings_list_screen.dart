import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:swasthyasetu/app_screens/add_feelings_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_feelings.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:swasthyasetu/widgets/date_range_picker_custom.dart'
    as DateRagePicker;

import '../utils/color.dart';

class FeelingsListScreen extends StatefulWidget {
  String patientIDP;
  var fromDate = DateTime.now().subtract(Duration(days: 7));
  var toDate = DateTime.now();

  var fromDateString = "";
  var toDateString = "";
  var dateString = "Select Date Range";

  FeelingsListScreen(this.patientIDP);

  @override
  State<StatefulWidget> createState() {
    return FeelingsListScreenState();
  }
}

class FeelingsListScreenState extends State<FeelingsListScreen> {
  List<ModelFeelings> listFeelings = [];
  ScrollController? hideFABController;
  var isFABVisible = true;

  var veryHappyColor = 0xFFE7993B;
  var happyColor = 0xFFCE5717;
  var neutralColor = 0xFF51BDEF;
  var worriedColor = 0xFF030AFF;
  var sadColor = 0xFF5D56F7;
  var angryColor = 0xFFFF0000;

  var veryHappyColorBgd = 0x13E7993B;
  var happyColorBgd = 0x13CE5717;
  var neutralColorBgd = 0x13BDEF;
  var worriedColorBgd = 0x10030AFF;
  var sadColorBgd = 0x135D56F7;
  var angryColorBgd = 0x13FF0000;
  DateTime? fromDate;
  DateTime? toDate;
  var fromDateString = "";
  var toDateString = "";
  late DateTimeRange dateRange;

  @override
  void dispose() {
    widget.patientIDP = "";
    widget.fromDate = DateTime.now().subtract(Duration(days: 7));
    widget.toDate = DateTime.now();
    widget.fromDateString = "";
    widget.toDateString = "";
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // var formatter = new DateFormat('dd-MM-yyyy');
    /*widget.fromDateString = formatter.format(widget.fromDate);
    widget.toDateString = formatter.format(widget.toDate);*/
    widget.dateString = "Select Date Range";
    var formatter = new DateFormat('dd-MM-yyyy');
    fromDate = DateTime.now().subtract(const Duration(days: 30));
    toDate = DateTime.now();
    fromDateString = formatter.format(fromDate!);
    toDateString = formatter.format(toDate!);
    dateRange = DateTimeRange(
        start: fromDate!,
        end: toDate!
    );
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
    getFeelingsList(context);
  }

  int getFeelingColor(String feelingName) {
    if (feelingName == "Very Happy")
      return veryHappyColor;
    else if (feelingName == "Happy")
      return happyColor;
    else if (feelingName == "Neutral")
      return neutralColor;
    else if (feelingName == "Worried")
      return worriedColor;
    else if (feelingName == "Sad")
      return sadColor;
    else if (feelingName == "Angry") return angryColor;
    return 0;
  }

  int getBgdColor(String feelingName) {
    if (feelingName == "Very Happy")
      return veryHappyColorBgd;
    else if (feelingName == "Happy")
      return happyColorBgd;
    else if (feelingName == "Neutral")
      return neutralColorBgd;
    else if (feelingName == "Worried")
      return worriedColorBgd;
    else if (feelingName == "Sad")
      return sadColorBgd;
    else if (feelingName == "Angry") return angryColorBgd;
    return 0;
  }

  String getFeelingImagePath(String feelingName) {
    if (feelingName == "Very Happy")
      return "images/ic_emoji_very_happy_only_lines.png";
    else if (feelingName == "Happy")
      return "images/ic_emoji_happy_only_lines.png";
    else if (feelingName == "Neutral")
      return "images/ic_emoji_neutral_only_lines.png";
    else if (feelingName == "Worried")
      return "images/ic_emoji_worried_only_lines.png";
    else if (feelingName == "Sad")
      return "images/ic_emoji_sad_only_lines.png";
    else if (feelingName == "Angry")
      return "images/ic_emoji_angry_only_lines.png";
    return "";
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
        floatingActionButton: Visibility(
          visible: isFABVisible,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddFeelingsScreen(widget.patientIDP))).then((value) {
                getFeelingsList(context);
              });
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.black,
          ),
        ),
        body: Builder(
          builder: (context) {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 1,
                ),
                Container(
                  height: SizeConfig.blockSizeVertical !* 8,
                  child: Padding(
                    padding: EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Container(
                      child: InkWell(
                          onTap: () {
                            pickDateRange();
                          },
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  widget.dateString,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: SizeConfig.blockSizeVertical !* 2.0,
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
                  height: SizeConfig.blockSizeVertical !* 1,
                ),
                listFeelings.length > 0
                    ? Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            controller: hideFABController,
                            itemCount: listFeelings.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: new BoxDecoration(
                                  boxShadow: [
                                    new BoxShadow(
                                      color: Color(getBgdColor(
                                        listFeelings[index].feelingName,
                                      )),
                                      blurRadius: 10.0,
                                    ),
                                  ],
                                ),
                                child: Card(
                                  margin: EdgeInsets.all(
                                      SizeConfig.blockSizeHorizontal !* 2),
                                  /*color: Colors.white,*/
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                          margin: EdgeInsets.zero,
                                          color: Color(getFeelingColor(
                                              listFeelings[index].feelingName)),
                                          width:
                                              SizeConfig.blockSizeHorizontal !*
                                                  23,
                                          height:
                                              SizeConfig.blockSizeHorizontal !*
                                                  23,
                                          child: Column(
                                            children: <Widget>[
                                              Image(
                                                width: SizeConfig
                                                        .blockSizeHorizontal !*
                                                    15,
                                                height: SizeConfig
                                                        .blockSizeHorizontal !*
                                                    15,
                                                image: AssetImage(
                                                    getFeelingImagePath(
                                                  listFeelings[index]
                                                      .feelingName,
                                                )),
                                              ),
                                              Text(
                                                listFeelings[index].feelingName,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal !*
                                                        3.2),
                                              ),
                                            ],
                                          )),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              SizeConfig.blockSizeHorizontal !*
                                                  3),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    listFeelings[index].date,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: SizeConfig
                                                              .blockSizeHorizontal !*
                                                          3.6,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal !*
                                                        5,
                                                  ),
                                                  Text(
                                                    listFeelings[index].time,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: SizeConfig
                                                              .blockSizeHorizontal !*
                                                          3.6,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: SizeConfig
                                                        .blockSizeVertical !*
                                                    1,
                                              ),
                                              Text(
                                                listFeelings[index]
                                                    .feelingDescription,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: SizeConfig
                                                          .blockSizeHorizontal !*
                                                      3.6,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: InkWell(
                                          onTap: () {
                                            deleteFeelingFromTheList(
                                                listFeelings[index]);
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            size:
                                                SizeConfig.blockSizeHorizontal !*
                                                    7,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            SizeConfig.blockSizeHorizontal !* 3,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      )
                    : Expanded(
                        child: SizedBox(
                          height: SizeConfig.blockSizeVertical !* 80,
                          child: Container(
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal !* 5),
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
                                  "No Feelings Records found.",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  void getFeelingsList(BuildContext context) async {
    String loginUrl = "${baseURL}patientFeelingsData.php";
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
        "\"FromDate\":" +
        "\"${widget.fromDateString}\"" +
        "," +
        "\"ToDate\":" +
        "\"${widget.toDateString}\"" +
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
    listFeelings = [];
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listFeelings.add(ModelFeelings(
          jo['PatientFeelingsIDP'].toString(),
          jo['FeelingsValue'],
          jo['FeelingsDescription'] != "" ? jo['FeelingsDescription'] : "-",
          jo['FeelingsDate'],
          jo['FeelingsTime'],
        ));
      }
      setState(() {});
    }
  }

  Future pickDateRange() async
  {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if(newDateRange == null) return;

    setState(() {
      dateRange = newDateRange;
      fromDate = dateRange.start;
      toDate = dateRange.end;
      var formatter = new DateFormat('dd-MM-yyyy');
      fromDateString = formatter.format(fromDate!);
      toDateString = formatter.format(toDate!);
      widget.dateString = "${fromDateString}  to  ${toDateString}";
      getFeelingsList(context);
    });
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
  //   //     getFeelingsList(context);
  //   //   });
  //   //   //print(picked);
  //   // }
  //   showCustomDateRangePicker(
  //     context,
  //     dismissible: true,
  //     minimumDate: DateTime.now().subtract(Duration(days: 365 * 100)),
  //     maximumDate: DateTime.now(),
  //     endDate: widget.toDate,
  //     startDate: widget.fromDate,
  //     backgroundColor: Colors.white,
  //     primaryColor: Colors.blue,
  //     onApplyClick: (start, end) {
  //       setState(() {
  //         widget.fromDate = start;
  //         widget.toDate = end;
  //         var formatter = new DateFormat('dd-MM-yyyy');
  //         widget.fromDateString = formatter.format(widget.fromDate);
  //         widget.toDateString = formatter.format(widget.toDate);
  //         widget.dateString =
  //         "${widget.fromDateString}  to  ${widget.toDateString}";
  //         getFeelingsList(context);
  //         //print(picked);
  //       });
  //     },
  //     onCancelClick: () {
  //       setState(() {
  //         widget.fromDate = DateTime.now().subtract(Duration(days: 7));
  //         widget.toDate = DateTime.now();
  //         getFeelingsList(context);
  //       });
  //     },
  //   );
  // }

  void deleteFeelingFromTheList(ModelFeelings modelFeeling) async {
    String loginUrl = "${baseURL}patientFeelingDelete.php";
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
        "PatientFeelingsIDP" +
        "\"" +
        ":" +
        "\"" +
        modelFeeling.feelingIDP +
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
      getFeelingsList(context);
    }
  }
}
