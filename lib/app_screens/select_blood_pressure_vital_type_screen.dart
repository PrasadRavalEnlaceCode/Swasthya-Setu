import 'package:flutter/material.dart';
import 'package:silvertouch/app_screens/vitals_list.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_profile_patient.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/progress_dialog.dart';

import '../utils/color.dart';

class SelectBloodPressureTypeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SelectBloodPressureTypeScreenState();
  }
}

class SelectBloodPressureTypeScreenState
    extends State<SelectBloodPressureTypeScreen> {
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
        title: Text("Blood Pressure"),
        iconTheme: IconThemeData(color: Colorsblack),
        toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(
          color: Colorsblack,
          fontFamily: "Ubuntu",
          fontSize: SizeConfig.blockSizeVertical! * 2.5,
        )).bodyMedium,
        titleTextStyle: TextTheme(
            titleMedium: TextStyle(
          color: Colorsblack,
          fontFamily: "Ubuntu",
          fontSize: SizeConfig.blockSizeVertical! * 2.5,
        )).titleLarge,
      ),
      body: Builder(
        builder: (context) {
          return Container(
            height: SizeConfig.blockSizeVertical! * 100,
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
                      return VitalsListScreen(patientIDP, "1");
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
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 5),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Text("BP Systolic"),
                              ),
                              Container(
                                  width: SizeConfig.blockSizeHorizontal! * 12,
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
                      return VitalsListScreen(patientIDP, "2");
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
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 5),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Text("BP Diastolic"),
                              ),
                              Container(
                                  width: SizeConfig.blockSizeHorizontal! * 12,
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
