import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:swasthyasetu/app_screens/add_medicine_master.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_masters.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

import '../utils/color.dart';

List<ModelMasters> listMasters = [];
String masterIconPath = "";

class MastersListScreen extends StatefulWidget {
  String masterName;
  int masterId;

  MastersListScreen(this.masterName, this.masterId);

  @override
  State<StatefulWidget> createState() {
    return MastersListScreenState();
  }
}

class MastersListScreenState extends State<MastersListScreen> {
  var isFABVisible = true;
  ScrollController? hideFABController;

  @override
  void initState() {
    super.initState();
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
    listMasters = [];
    if (widget.masterId == 0) {
      masterIconPath = "images/ic_dosage_schedule.png";
      getMastersList(context);
    } else if (widget.masterId == 1) {
      masterIconPath = "images/ic_advice.png";
      getMastersList(context);
    } else if (widget.masterId == 2) {
      masterIconPath = "images/ic_drugs.png";
      getMedicinesList(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.masterName} List"),
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
            if (widget.masterId == 0 || widget.masterId == 1)
              showAddMasterDialog(context);
            else if (widget.masterId == 2)
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddMedicineMaster()));
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.black,
          /*),*/
        ),
      ),
      body: Container(
        width: SizeConfig.blockSizeHorizontal !* 100,
        color: Color(0xDDDCDCDC),
        child: Column(
          children: <Widget>[
            Expanded(
              child:
                  /*ListView(
              controller: hideFABController,
              shrinkWrap: true,
              children: <Widget>[*/
                  listMasters.length > 0
                      ? ListView.builder(
                          controller: hideFABController,
                          shrinkWrap: true,
                          itemCount: listMasters.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal:
                                      SizeConfig.blockSizeHorizontal !* 3,
                                  vertical: SizeConfig.blockSizeHorizontal !* 2),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            SizeConfig.blockSizeHorizontal !* 3,
                                        vertical:
                                            SizeConfig.blockSizeHorizontal !* 2),
                                    child: Image(
                                      image: AssetImage('$masterIconPath'),
                                      width: SizeConfig.blockSizeHorizontal !* 7,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                SizeConfig.blockSizeHorizontal !*
                                                    3,
                                            vertical:
                                                SizeConfig.blockSizeHorizontal !*
                                                    2),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              listMasters[index].masterValue,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal !*
                                                    4,
                                              ),
                                            ),
                                            /*SizedBox(
                                              height:
                                                  SizeConfig.blockSizeVertical *
                                                      1,
                                            ),
                                            Text(
                                              widget.masterId == 2
                                                  ? listMasters[index]
                                                      .masterType
                                                  : widget.masterName,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal *
                                                    3,
                                              ),
                                            ),*/
                                          ],
                                        )),
                                  )
                                ],
                              ),
                            );
                          })
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            /*Expanded(
                        child:*/
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
                              "No ${widget.masterName} Added",
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
              /*],
            ),*/
            )
          ],
        ),
      ),
    );
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

  showAddMasterDialog(BuildContext context) {
    TextEditingController masterController = TextEditingController();
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: _SystemPadding(
                  child: new AlertDialog(
                contentPadding: const EdgeInsets.all(16.0),
                content: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new TextField(
                        controller: masterController,
                        autofocus: true,
                        decoration: new InputDecoration(
                            labelText: widget.masterName, hintText: ''),
                      ),
                    )
                  ],
                ),
                actions: <Widget>[
                  new TextButton(
                      child: const Text('CANCEL'),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  new TextButton(
                      child: const Text('ADD'),
                      onPressed: () {
                        Navigator.pop(context);
                        addMasterToTheList(masterController.text.trim());
                      })
                ],
              )),

              /*child: dialogContent(context, "Select Image from"),*/
            ));
  }

  void getMastersList(BuildContext context) async {
    String loginUrl = "${baseURL}doctorMasterList.php";
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
    String masterTypeData = "";
    if (widget.masterId == 0)
      masterTypeData = "[{\"MasterType\":\"DrugSchedule\"}]";
    else if (widget.masterId == 1)
      masterTypeData = "[{\"MasterType\":\"DrugAdvice\"}]";
    String jsonStr = "{" +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"MasterTypeData\":" +
        "$masterTypeData" +
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
    listMasters = [];
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listMasters.add(ModelMasters(
          jo['MasterIDP'].toString(),
          jo['MasterValue'],
          jo['MasterType'],
        ));
        /*listMasters.add(ModelMasters(
          jo['MasterIDP'].toString(),
          jo['MasterValue'],
          jo['MasterType'],
        ));
        listMasters.add(ModelMasters(
          jo['MasterIDP'].toString(),
          jo['MasterValue'],
          jo['MasterType'],
        ));
        listMasters.add(ModelMasters(
          jo['MasterIDP'].toString(),
          jo['MasterValue'],
          jo['MasterType'],
        ));
        listMasters.add(ModelMasters(
          jo['MasterIDP'].toString(),
          jo['MasterValue'],
          jo['MasterType'],
        ));*/
      }
      setState(() {});
    }
  }

  void addMasterToTheList(String masterValueText) async {
    String loginUrl = "${baseURL}doctorMasterAdd.php";
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
    String masterType = "";
    if (widget.masterId == 0)
      masterType = "DrugSchedule";
    else if (widget.masterId == 1) masterType = "DrugAdvice";
    String jsonStr = "{" +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"MasterType\":" +
        "\"$masterType\"" +
        "," +
        "\"MasterValue\":" +
        "\"$masterValueText\"" +
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    listMasters = [];
    if (model.status == "OK") {
      Future.delayed(Duration(milliseconds: 500), () {
        getMastersList(context);
      });
    }
  }

  void getMedicinesList(BuildContext context) async {
    String loginUrl = "${baseURL}doctorMedicineList.php";
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
    /*String masterTypeData = "";
    if (widget.masterId == 0)
      masterTypeData = "[{\"MasterType\":\"DrugSchedule\"}]";
    else if (widget.masterId == 1)
      masterTypeData = "[{\"MasterType\":\"DrugAdvice\"}]";*/
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
    listMasters = [];
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listMasters.add(ModelMasters(
          jo['HospitalMedicineIDP'].toString(),
          jo['MedicineName'],
          jo['DoseSchedule'],
        ));
      }
      setState(() {});
    }
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget? child;

  _SystemPadding({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.viewInsets,
        curve: Curves.bounceIn,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
