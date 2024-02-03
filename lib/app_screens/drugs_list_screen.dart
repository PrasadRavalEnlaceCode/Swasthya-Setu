import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:swasthyasetu/app_screens/add_drug_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_masters.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';

import '../utils/color.dart';
import '../utils/progress_dialog.dart';

List<ModelMasters> listMasters = [];
List<ModelMasters> listMastersSearchResults = [];
String masterIconPath = "";

class DrugsListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DrugsListScreenState();
  }
}

class DrugsListScreenState extends State<DrugsListScreen> {
  var isFABVisible = true;
  ScrollController? hideFABController;

  Icon icon = Icon(
    Icons.search,
    color: Colors.black,
  );
  Widget titleWidget = Text("Drugs Master");
  TextEditingController? searchController;
  var focusNode = new FocusNode();

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
    listMastersSearchResults = [];
    getMastersList(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: titleWidget,
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(color: Colorsblack),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                setState(() {
                  if (icon.icon == Icons.search) {
                    searchController = TextEditingController(text: "");
                    focusNode.requestFocus();
                    icon = Icon(
                      Icons.cancel,
                      color: Colors.black,
                    );
                    titleWidget = TextField(
                      controller: searchController,
                      focusNode: focusNode,
                      cursorColor: Colors.white,
                      onChanged: (text) {
                        setState(() {
                          listMastersSearchResults = listMasters
                              .where((model) =>
                                  (model.masterValue.toLowerCase().trim())
                                      .replaceAll("  ", " ")
                                      .contains(text.toLowerCase()) ||
                                  (model.masterType.toLowerCase().trim())
                                      .replaceAll("  ", " ")
                                      .contains(text.toLowerCase()))
                              .toList();
                        });
                      },
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                      ),
                      decoration: InputDecoration(
                        /*hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize:
                          SizeConfig.blockSizeVertical * 2.1),
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize:
                          SizeConfig.blockSizeVertical * 2.1),*/
                        hintText: "Search Drugs",
                      ),
                    );
                  } else {
                    icon = Icon(
                      Icons.search,
                      color: Colors.black,
                    );
                    titleWidget = Text("Drugs Master");
                    listMastersSearchResults = listMasters;
                  }
                });
              },
              icon: icon,
            )
          ], toolbarTextStyle: TextTheme(
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
                          builder: (context) => AddDrugScreen("add", "")))
                  .then((value) {
                searchController = TextEditingController();
                getMastersList(context);
              });
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.black,
            /*),*/
          ),
        ),
        body: Builder(
          builder: (context) {
            return Container(
              width: SizeConfig.blockSizeHorizontal !* 100,
              color: Color(0xBBDCDCDC),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child:
                        /*ListView(
              controller: hideFABController,
              shrinkWrap: true,
              children: <Widget>[*/
                        listMastersSearchResults.length > 0
                            ? ListView.builder(
                                controller: hideFABController,
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: listMastersSearchResults.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            SizeConfig.blockSizeHorizontal !* 3,
                                        vertical:
                                            SizeConfig.blockSizeHorizontal !* 2),
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: SizeConfig
                                                      .blockSizeHorizontal !*
                                                  3,
                                              vertical: SizeConfig
                                                      .blockSizeHorizontal !*
                                                  2),
                                          child: Image(
                                            image: AssetImage(
                                                'images/ic_drugs.png'),
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
                                                    listMastersSearchResults[
                                                            index]
                                                        .masterValue,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                                    listMastersSearchResults[
                                                            index]
                                                        .masterType,
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
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return AddDrugScreen(
                                                  "update",
                                                  listMastersSearchResults[
                                                          index]
                                                      .masterIDP);
                                            })).then((value) {
                                              getMastersList(context);
                                            });
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.teal,
                                            size:
                                                SizeConfig.blockSizeHorizontal !*
                                                    7,
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              SizeConfig.blockSizeHorizontal !*
                                                  2,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            deleteDrug(
                                                listMastersSearchResults[index]
                                                    .masterIDP,
                                                context);
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size:
                                                SizeConfig.blockSizeHorizontal !*
                                                    7,
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              SizeConfig.blockSizeHorizontal !*
                                                  2,
                                        ),
                                      ],
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
                                    "No Drugs Added",
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

  void getMastersList(BuildContext context) async {
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
    String masterTypeData = "[{\"MasterType\":\"Drug\"}]";
    /*String jsonStr = "{" +
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
        "}";*/
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
    listMastersSearchResults = [];
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
          jo['MedicineManufacturer'],
          /*jo['MasterIDP'].toString(),
          jo['MasterValue'],
          jo['MasterType'],*/
        ));
      }
      listMastersSearchResults = listMasters;
      setState(() {});
    }
  }

  void deleteDrug(String masterIDP, BuildContext context) async {
    String loginUrl = "${baseURL}doctorDrugUpdate.php";
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
        "," +
        "\"MedicineName\":" +
        "\"\"" +
        "," +
        "\"MedicineContent\":" +
        "\"\"" +
        "," +
        "\"MedicineTypeIDF\":" +
        "\"\"" +
        "," +
        "\"DosageAdviceIDF\":" +
        "\"\"" +
        "," +
        "\"DrugDoseScheduleIDF\":" +
        "\"\"" +
        "," +
        "\"MedicineDays\":" +
        "\"\"" +
        "," +
        "\"MinimumQuantity\":" +
        "\"\"" +
        "," +
        "\"MedicineManufacturer\":" +
        "\"\"" +
        "," +
        "\"HospitalMedicineIDP\":" +
        "\"$masterIDP\"" +
        "," +
        "\"DeleteFlag\":" +
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr?.hide();
    if (model.status == "OK") {
      Future.delayed(Duration(milliseconds: 500), () {
        getMastersList(context);
      });
      /*final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.of(context).pop();
      });*/
    }
  }
}
