import 'package:flutter/material.dart';
import 'package:swasthyasetu/app_screens/add_vital_screen.dart';
import 'package:swasthyasetu/app_screens/fullscreen_image.dart';
import 'package:swasthyasetu/app_screens/investigations_list_for_doctors_patient.dart';
import 'package:swasthyasetu/app_screens/report_list_for_doctors_patient.dart';
import 'package:swasthyasetu/app_screens/select_sugar_vital_type_screen.dart';
import 'package:swasthyasetu/app_screens/vitals_list_for_doctors_patient.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';

class ShowVitalsInvestigationPatientWise extends StatefulWidget {
  final String patientIDP,
      fullName,
      gender,
      age,
      cityName,
      imgUrl,
      heroTag,
      patientID;

  ShowVitalsInvestigationPatientWise(
      this.patientIDP,
      this.fullName,
      this.gender,
      this.age,
      this.cityName,
      this.imgUrl,
      this.patientID,
      this.heroTag);

  @override
  State<StatefulWidget> createState() {
    return SelectedPatientInDoctorsState();
  }
}

class SelectedPatientInDoctorsState
    extends State<ShowVitalsInvestigationPatientWise> {
  List<Map<String, String>> listCategories = [];
  List<Map<String, String>> listVitals = [];
  var selectedCategoryIDP = "1";

  @override
  void initState() {
    super.initState();
    listCategories = [];
    listVitals = [];
    listCategories.add({"Name": "Vitals", "IDP": "1"});
    listCategories.add({"Name": "Investigation", "IDP": "2"});
    listCategories.add({"Name": "Report", "IDP": "3"});

    listVitals.add({"Name": "Blood Pressure", "IDP": "1"});
    listVitals.add({"Name": "Vitals", "IDP": "3"});
    listVitals.add({"Name": "Sugar", "IDP": ""});
    listVitals.add({"Name": "Weight Measurement", "IDP": "11"});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      /*appBar: AppBar(
          title: Text(""),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          */ /*iconTheme: IconThemeData(
            color: Color(0xFF06A759), size: SizeConfig.blockSizeVertical * 2.5),*/ /*
          textTheme: TextTheme(
              subtitle1: TextStyle(
                  color: Colors.white,
                  fontFamily: "Ubuntu",
                  fontSize: SizeConfig.blockSizeVertical * 2.5)),
        ),*/
      body: SafeArea(
        child: Container(
          width: SizeConfig.blockSizeHorizontal !* 100,
          height: SizeConfig.blockSizeVertical !* 100,
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal !* 1,
                              right: SizeConfig.blockSizeHorizontal !* 1),
                          child: InkWell(
                            focusColor: Colors.white,
                            highlightColor: Colors.white,
                            hoverColor: Colors.white,
                            splashColor: Colors.white,
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(Icons.arrow_back),
                          ),
                        )),
                    Expanded(
                      child: Hero(
                        tag: widget.heroTag,
                        child: Card(
                          elevation: 0,
                          child:
                              /*IntrinsicHeight(
                      child: */
                              Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              VerticalDivider(
                                width: SizeConfig.blockSizeHorizontal !* 2,
                                thickness: SizeConfig.blockSizeHorizontal !* 2,
                                color: Colors.green,
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal !* 3,
                              ),
                              /*CircleAvatar(
                                radius: SizeConfig.blockSizeHorizontal * 6,
                                backgroundColor: Colors.grey,
                                backgroundImage: AssetImage(
                                    "images/ic_user_placeholder.png") */ /*),*/ /*
                                ),*/
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return FullScreenImage(
                                        "$userImgUrl${widget.imgUrl}");
                                  }));
                                },
                                child: CircleAvatar(
                                    radius: SizeConfig.blockSizeHorizontal !* 6,
                                    backgroundColor: Colors.grey,
                                    backgroundImage: getBackgroundImage(widget.imgUrl) /*),*/
                                    ),
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal !* 5,
                              ),
                              Expanded(
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical:
                                            SizeConfig.blockSizeHorizontal !* 3),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          widget.fullName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal !*
                                                  4),
                                        ),
                                        SizedBox(
                                          height:
                                              SizeConfig.blockSizeVertical !* 1,
                                        ),
                                        Row(children: <Widget>[
                                          Text(
                                            "ID - ${widget.patientID}",
                                            style: TextStyle(
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal !*
                                                  3.5,
                                              color: Colors.green,
                                            ),
                                          ),
                                          SizedBox(
                                            width:
                                                SizeConfig.blockSizeHorizontal !*
                                                    5,
                                          ),
                                          Text(
                                            "${widget.gender}/${widget.age}",
                                            style: TextStyle(
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal !*
                                                  3.5,
                                              color: Colors.blue[900],
                                            ),
                                          ),
                                          /*VerticalDivider(
                                  color: Colors.grey,
                                ),*/
                                          SizedBox(
                                            width:
                                                SizeConfig.blockSizeHorizontal !*
                                                    5,
                                          ),
                                          Text(
                                            widget.cityName,
                                            style: TextStyle(
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal !*
                                                    3.5,
                                                color: Colors.blue[600]),
                                          ),
                                        ]),
                                      ],
                                    )),
                              )
                            ],
                          ) /*)*/,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 1,
              ),
              Padding(
                  padding: EdgeInsets.only(
                      left: SizeConfig.blockSizeHorizontal !* 2,
                      right: SizeConfig.blockSizeHorizontal !* 2),
                  child: Container(
                    /*decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1)),*/
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedCategoryIDP = "1";
                              });
                            },
                            child: Container(
                                /*color: selectedCategoryIDP == "1"
                                  ? Colors.black
                                  : Colors.white,*/
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: selectedCategoryIDP == "1"
                                                ? Color(0xFF06A759)
                                                : Colors.white,
                                            width: 4.0))),
                                child: Center(
                                    child: Padding(
                                  padding: EdgeInsets.all(
                                      SizeConfig.blockSizeHorizontal !* 1),
                                  child: Text(
                                    "Vitals",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ))),
                          ),
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal !* 2,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedCategoryIDP = "2";
                              });
                            },
                            child: Container(
                              /*color: selectedCategoryIDP == "2"
                                ? Colors.black
                                : Colors.white,*/
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: selectedCategoryIDP == "2"
                                              ? Color(0xFF06A759)
                                              : Colors.white,
                                          width: 4.0))),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      SizeConfig.blockSizeHorizontal !* 1),
                                  child: Text(
                                    "Investigations",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500
                                        /*color: selectedCategoryIDP == "2"
                                          ? Colors.white
                                          : Colors.black*/
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal !* 2,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedCategoryIDP = "3";
                              });
                            },
                            child: Container(
                              /*color: selectedCategoryIDP == "3"
                                ? Colors.black
                                : Colors.white,*/
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: selectedCategoryIDP == "3"
                                              ? Color(0xFF06A759)
                                              : Colors.white,
                                          width: 4.0))),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      SizeConfig.blockSizeHorizontal !* 1),
                                  child: Text(
                                    "Documents",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500
                                        /*color: selectedCategoryIDP == "3"
                                          ? Colors.white
                                          : Colors.black*/
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 3,
              ),
              selectedCategoryIDP == "1"
                  ? Expanded(
                      child: VitalsListForDoctorsPatientScreen(
                          widget.patientIDP, ""))
                  : Container(),
              selectedCategoryIDP == "2"
                  ? Expanded(
                      child: InvestigationsListForDoctorsPatientScreen(
                          widget.patientIDP))
                  : Container(),
              selectedCategoryIDP == "3"
                  ? Expanded(
                      child: ReportListForDoctorsPatientScreen(
                          widget.patientIDP, ""))
                  : Container(),
            ],
          ),
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedCategoryIDP == "1") {
            showAddVitalSelectionDialog();
            */ /*Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddVitalsScreen(
                        widget.patientIDP, selectedCategoryIDP))).then((value) {
              get(context);
            });*/ /*
          } else if (selectedCategoryIDP == "2") {
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
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),*/
    );
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
                          size: SizeConfig.blockSizeHorizontal !* 6.2,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal !* 6,
                      ),
                      Text(
                        "Select Vitals to Add",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.8,
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
                    itemCount: listVitals.length,
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            if (listVitals[index]["IDP"] != "") {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return AddVitalsScreen(
                                  widget.patientIDP,
                                  listVitals[index]["IDP"]!,
                                );
                              })).then((value) {
                                if (selectedCategoryIDP == "1") {
                                  selectedCategoryIDP = "2";
                                  setState(() {});
                                  selectedCategoryIDP = "1";
                                  setState(() {});
                                } else if (selectedCategoryIDP == "2") {
                                  selectedCategoryIDP = "3";
                                  setState(() {});
                                  selectedCategoryIDP = "2";
                                  setState(() {});
                                } else if (selectedCategoryIDP == "3") {
                                  selectedCategoryIDP = "2";
                                  setState(() {});
                                  selectedCategoryIDP = "3";
                                  setState(() {});
                                }

                                /*String temp = selectedCategoryIDP;
                                selectedCategoryIDP = "";
                                setState(() {});
                                selectedCategoryIDP = temp;
                                setState(() {});*/
                              });
                            } else {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return SelectSugarTypeScreen(widget.patientIDP);
                              })).then((value) {
                                if (selectedCategoryIDP == "1") {
                                  selectedCategoryIDP = "2";
                                  setState(() {});
                                  Future.delayed(Duration(milliseconds: 500),
                                      () {
                                    selectedCategoryIDP = "1";
                                    setState(() {});
                                  });
                                } else if (selectedCategoryIDP == "2") {
                                  selectedCategoryIDP = "3";
                                  setState(() {});
                                  Future.delayed(Duration(milliseconds: 500),
                                      () {
                                    selectedCategoryIDP = "2";
                                    setState(() {});
                                  });
                                  /*selectedCategoryIDP = "2";
                                  setState(() {});*/
                                } else if (selectedCategoryIDP == "3") {
                                  selectedCategoryIDP = "2";
                                  setState(() {});
                                  Future.delayed(Duration(milliseconds: 500),
                                      () {
                                    selectedCategoryIDP = "3";
                                    setState(() {});
                                  });
                                  /*selectedCategoryIDP = "3";
                                  setState(() {});*/
                                }
                              });
                            }
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
                                      listVitals[index]["Name"]!,
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
}

getBackgroundImage(String imgUrl) {
  (imgUrl != "")
      ? NetworkImage(
      "$userImgUrl${imgUrl}")
      : AssetImage(
      "images/ic_user_placeholder.png");
}
