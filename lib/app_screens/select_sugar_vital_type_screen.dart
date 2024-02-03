import 'package:flutter/material.dart';
import 'package:swasthyasetu/app_screens/add_vital_screen.dart';
import 'package:swasthyasetu/app_screens/vitals_list.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';

import '../utils/color.dart';

class SelectSugarTypeScreen extends StatefulWidget {
  String patientIDP;

  SelectSugarTypeScreen(this.patientIDP);

  @override
  State<StatefulWidget> createState() {
    return SelectSugarTypeScreenState();
  }
}

class SelectSugarTypeScreenState extends State<SelectSugarTypeScreen> {
  @override
  void initState() {
    /*getPatientIDP().then((pIdp) {
      patientIDP = pIdp;
    });*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: Text("Sugar"),
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
          return Container(
            height: SizeConfig.blockSizeVertical !* 100,
            color: Color(0xFFEFEEF3),
            child: Column(
              children: <Widget>[
                /*SizedBox(
                  height: SizeConfig.blockSizeVertical * 2,
                ),*/
                InkWell(
                  onTap: () async {
                    String userType = await getUserType();
                    if (userType == "patient") {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return VitalsListScreen(widget.patientIDP, "6");
                      }));
                    } else if (userType == "doctor") {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return AddVitalsScreen(widget.patientIDP, "6");
                      }));
                    }
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom:
                                  BorderSide(width: 1.0, color: Colors.grey))),
                      child: Padding(
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Text("FBS"),
                              ),
                              Container(
                                  width: SizeConfig.blockSizeHorizontal !* 12,
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                    ),
                                  )),
                            ]),
                      )),
                ),
                InkWell(
                  onTap: () async {
                    String userType = await getUserType();
                    if (userType == "patient") {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return VitalsListScreen(widget.patientIDP, "7");
                      }));
                    } else if (userType == "doctor") {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return AddVitalsScreen(widget.patientIDP, "7");
                      }));
                    }
                    /*Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return VitalsListScreen(patientIDP, "7");
                    }));*/
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom:
                                  BorderSide(width: 1.0, color: Colors.grey))),
                      child: Padding(
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Text("PPBS"),
                              ),
                              Container(
                                  width: SizeConfig.blockSizeHorizontal !* 12,
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                    ),
                                  )),
                            ]),
                      )),
                ),
                InkWell(
                  onTap: () async {
                    String userType = await getUserType();
                    if (userType == "patient") {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return VitalsListScreen(widget.patientIDP, "8");
                      }));
                    } else if (userType == "doctor") {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return AddVitalsScreen(widget.patientIDP, "8");
                      }));
                    }

                    /*Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return VitalsListScreen(patientIDP, "8");
                    }));*/
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom:
                                  BorderSide(width: 1.0, color: Colors.grey))),
                      child: Padding(
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Text("RBS"),
                              ),
                              Container(
                                  width: SizeConfig.blockSizeHorizontal !* 12,
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                    ),
                                  )),
                            ]),
                      )),
                ),
                InkWell(
                  onTap: () async {
                    String userType = await getUserType();
                    if (userType == "patient") {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return VitalsListScreen(widget.patientIDP, "9");
                      }));
                    } else if (userType == "doctor") {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return AddVitalsScreen(widget.patientIDP, "9");
                      }));
                    }
                    /*Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return VitalsListScreen(patientIDP, "9");
                    }));*/
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom:
                                  BorderSide(width: 1.0, color: Colors.grey))),
                      child: Padding(
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Text("HbA1C"),
                              ),
                              Container(
                                  width: SizeConfig.blockSizeHorizontal !* 12,
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                    ),
                                  )),
                            ]),
                      )),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
