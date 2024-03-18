import 'package:flutter/material.dart';
import 'package:swasthyasetu/app_screens/vitals_list.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';

import '../utils/color.dart';

class SelectVitalsTypeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SelectVitalsTypeScreenState();
  }
}

class SelectVitalsTypeScreenState extends State<SelectVitalsTypeScreen> {
  String patientIDP = "";

  @override
  void initState() {
    getPatientOrDoctorIDP().then((pIdp) {
      patientIDP = pIdp;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: Text("Vitals"),
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
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return VitalsListScreen(patientIDP, "3");
                    }));
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
                                child: Text("Pulse"),
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
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return VitalsListScreen(patientIDP, "4");
                    }));
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
                                child: Text("Temperature"),
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
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return VitalsListScreen(patientIDP, "5");
                    }));
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
                                child: Text("SPO2"),
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
