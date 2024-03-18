import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

import '../podo/model_camp.dart';
import '../utils/cm.dart';
import '../utils/string_resource.dart';
import 'add_camp_screen.dart';
import 'opd_registration_screen.dart';

List<ModelCamp> listCampMasters = [];
List<ModelCamp> listCampUpcomingResults = [];
List<ModelCamp> listCampCompletedResults = [];

class CampScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CampScreenState();
  }
}

class CampScreenState extends State<CampScreen> {
  @override
  void initState() {
    super.initState();
    listCampMasters = [];
    listCampUpcomingResults = [];
    listCampCompletedResults = [];
    getCampList(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: str_upcoming_camp),
              Tab(
                text: str_completed_camp,
              ),
            ],
          ),
          title: Text(str_camp),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3),
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AddCamp()))
                      .then((value) {
                    getCampList(context);
                  });
                },
                child: Image(
                  image: AssetImage("images/ic_add_opd.png"),
                  color: Colors.black,
                  width: SizeConfig.blockSizeHorizontal !* 7,
                ),
              ),
            )
          ],
        ),
        body: TabBarView(
          children: [
            UpcomingScreen(),
            CompletedScreen(),
          ],
        ),
      ),
    );
  }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }

  void getCampList(BuildContext context) async {
    String loginUrl = "${baseURL}camplist.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);

    String jsonStr = "{" +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        /*"," +
        "\"MasterTypeData\":" +
        "$masterTypeData" +*/
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
    listCampMasters = [];
    listCampUpcomingResults = [];
    listCampCompletedResults = [];
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];

        if (jo['campdt'] != null) {
          var formatter = new DateFormat(YYYYMMDD);
          var converDate =
              formatter.format(new DateFormat(DDMMYYYY).parse(jo['campdt']));
          DateTime dateCurrent = DateTime.now();
          var dayNow = DateTime.utc(dateCurrent.year,dateCurrent.month,dateCurrent.day);
          DateTime dateCamp = DateTime.parse(converDate);
          var dayCamp = DateTime.utc(dateCamp.year,dateCamp.month,dateCamp.day);
          bool valDate = dayNow.difference(dayCamp).inDays > 0;

          if (!valDate) {
            listCampUpcomingResults.add(ModelCamp(
              jo['DoctorCampIDP'],
              jo['CampName'],
              jo['CampDetails'],
              jo['campdt'],
              jo['CampTime'],
              jo['CampDate'],
            ));
          } else {
            listCampCompletedResults.add(ModelCamp(
              jo['DoctorCampIDP'],
              jo['CampName'],
              jo['CampDetails'],
              jo['campdt'],
              jo['CampTime'],
              jo['CampDate'],
            ));
          }
        }

        listCampMasters.add(ModelCamp(
          jo['DoctorCampIDP'],
          jo['CampName'],
          jo['CampDetails'],
          jo['campdt'],
          jo['CampTime'],
          jo['CampDate'],
        ));
      }
      setState(() {});
    }
  }
}

class UpcomingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Builder(
          builder: (context) {
            return Container(
              width: SizeConfig.blockSizeHorizontal !* 100,
              color: Color(0xBBDCDCDC),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: listCampUpcomingResults.length > 0
                        ? ListView.builder(
                            //controller: hideFABController,
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: listCampUpcomingResults.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Get.to(OPDRegistrationScreen(
                                      campID: listCampUpcomingResults[index]
                                          .DoctorCampIDP,
                                      name: listCampUpcomingResults[index]
                                          .CampName,isCompleted: false));
                                },
                                child: Card(
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          SizeConfig.blockSizeHorizontal !* 3,
                                      vertical:
                                          SizeConfig.blockSizeHorizontal !* 2),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                SizeConfig.blockSizeHorizontal !*
                                                    3,
                                            vertical:
                                                SizeConfig.blockSizeHorizontal !*
                                                    2),
                                        child: Image(
                                          image:
                                              AssetImage('images/ic_camp.png'),
                                          width:
                                              SizeConfig.blockSizeHorizontal !*
                                                  8,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: SizeConfig
                                                        .blockSizeHorizontal !*
                                                    3,
                                                vertical: SizeConfig
                                                        .blockSizeHorizontal !*
                                                    2),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  listCampUpcomingResults[index]
                                                      .CampName,
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal !*
                                                        4,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: SizeConfig
                                                          .blockSizeVertical !*
                                                      1,
                                                ),
                                                Text(
                                                  CM.convertDateFormate(
                                                      context,
                                                      Dateformate.ddMMMyyyy,
                                                      listCampUpcomingResults[
                                                              index]
                                                          .CampDate
                                                          .toString()),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal !*
                                                        3,
                                                  ),
                                                )
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image(
                                image: AssetImage("images/ic_idea_new.png"),
                                width: 100,
                                height: 100,
                              ),
                              /*),*/
                              SizedBox(
                                height: 30.0,
                              ),
                              Text(
                                "No camp Added",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        )));
  }
}

class CompletedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Builder(
          builder: (context) {
            return Container(
              width: SizeConfig.blockSizeHorizontal !* 100,
              color: Color(0xBBDCDCDC),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: listCampCompletedResults.length > 0
                        ? ListView.builder(
                            //controller: hideFABController,
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: listCampCompletedResults.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Get.to(OPDRegistrationScreen(
                                      campID: listCampCompletedResults[index]
                                          .DoctorCampIDP,
                                      name: listCampCompletedResults[index]
                                          .CampName,isCompleted: true));
                                },
                                child: Card(
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          SizeConfig.blockSizeHorizontal !* 3,
                                      vertical:
                                          SizeConfig.blockSizeHorizontal !* 2),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                SizeConfig.blockSizeHorizontal !*
                                                    3,
                                            vertical:
                                                SizeConfig.blockSizeHorizontal !*
                                                    2),
                                        child: Image(
                                          image:
                                              AssetImage('images/ic_camp.png'),
                                          width:
                                              SizeConfig.blockSizeHorizontal !*
                                                  8,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: SizeConfig
                                                        .blockSizeHorizontal !*
                                                    3,
                                                vertical: SizeConfig
                                                        .blockSizeHorizontal !*
                                                    2),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  listCampCompletedResults[
                                                          index]
                                                      .CampName,
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal !*
                                                        4,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: SizeConfig
                                                          .blockSizeVertical !*
                                                      1,
                                                ),
                                                Text(
                                                  CM.convertDateFormate(
                                                      context,
                                                      Dateformate.ddMMMyyyy,
                                                      listCampCompletedResults[
                                                              index]
                                                          .CampDate
                                                          .toString()),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal !*
                                                        3,
                                                  ),
                                                )
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image(
                                image: AssetImage("images/ic_idea_new.png"),
                                width: 100,
                                height: 100,
                              ),
                              /*),*/
                              SizedBox(
                                height: 30.0,
                              ),
                              Text(
                                "No camp Added",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        )));
  }
}
