import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:silvertouch/api/api_helper.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/model_investigation_master_list.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import '../utils/color.dart';

List<ModelInvestigationMaster> listInvestigationMaster = [];
List<ModelInvestigationMaster> listInvestigationMasterSelected = [];

class InvestigationMasterListScreen extends StatefulWidget {
  String? patientIDP;

  @override
  State<StatefulWidget> createState() {
    return InvestigationMasterListScreenState();
  }

  InvestigationMasterListScreen(String patientIDP,
      List<ModelInvestigationMaster> listInvestigationMasterSelectedLocal) {
    this.patientIDP = patientIDP;
    listInvestigationMasterSelected = listInvestigationMasterSelectedLocal;
  }
}

class InvestigationMasterListScreenState
    extends State<InvestigationMasterListScreen> {
  bool apiCalled = false;
  ApiHelper apiHelper = ApiHelper();

  @override
  void initState() {
    super.initState();
    getInvestigationList();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Investigation Masters"),
          backgroundColor: Color(0xFFFFFFFF),
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
            return Column(
              children: <Widget>[
                listInvestigationMaster.length > 0
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: listInvestigationMaster.length,
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return MultiCard(
                                listInvestigationMaster[index], index);
                          },
                        ),
                      )
                    : (apiCalled
                        ? Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image(
                                  image: AssetImage(
                                      "images/ic_no_result_found.png"),
                                  width: 200,
                                  height: 200,
                                ),
                                SizedBox(
                                  height: 12.0,
                                ),
                                Text(
                                  "All Masters Added.",
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ],
                            ),
                          )
                        : Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          )),
                listInvestigationMaster.length > 0
                    ? Container(
                        height: 80.0,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: 25.0,
                              top: 10.0,
                            ),
                            child:
                                /*Container(
                        width: SizeConfig.blockSizeHorizontal * 12,
                        height: SizeConfig.blockSizeHorizontal * 12,
                        child: */
                                RawMaterialButton(
                              onPressed: () {
                                // 3 uncomment the commented and vice versa
                                //submitToInvestigationMasterList(context);
                                goToInvestigationSubmitScreen(context);
                              },
                              elevation: 2.0,
                              fillColor: Color(0xFF06A759),
                              child: Image(
                                width: SizeConfig.blockSizeHorizontal! * 5.5,
                                height: SizeConfig.blockSizeHorizontal! * 5.5,
                                //height: 80,
                                image: AssetImage(
                                    "images/ic_right_arrow_triangular.png"),
                              ),
                              shape: CircleBorder(),
                            ),
                            /*),*/
                          ),
                        ),
                      )
                    : Container(),
              ],
            );
          },
        )
        /*body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ListView.builder(
            itemCount: listInvestigationMaster.length,
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return MultiCard(listInvestigationMaster[index]);
            },
          ),
          */ /*Expanded(
            child: */ /*Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 25.0,
                    top: 10.0,
                  ),
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal * 12,
                    height: SizeConfig.blockSizeHorizontal * 12,
                    child: RawMaterialButton(
                      onPressed: () {
                        //submitImageForUpdate(context, widget.image);
                      },
                      elevation: 2.0,
                      fillColor: Color(0xFF06A759),
                      child: Image(
                        width: SizeConfig.blockSizeHorizontal * 5.5,
                        height: SizeConfig.blockSizeHorizontal * 5.5,
                        //height: 80,
                        image:
                            AssetImage("images/ic_right_arrow_triangular.png"),
                      ),
                      shape: CircleBorder(),
                    ),
                  ),
                ) */ /*),*/ /*
          ),
        ],
      ),*/
        );
  }

  void getInvestigationList() async {
    String loginUrl = "${baseURL}patientInvestNotSelected.php";
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
        widget.patientIDP! +
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
    apiCalled = true;
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      listInvestigationMaster = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listInvestigationMaster.add(ModelInvestigationMaster(
          jo['PreInvestTypeIDP'].toString(),
          jo['GroupType'],
          jo['GroupName'],
          jo['InvestigationType'],
          jo['RangeValue'],
          false,
        ));
      }
      /*if (listInvestigationMasterSelected.length == 0) {
        for (var i = 0; i < jsonData.length; i++) {
          var jo = jsonData[i];
          listInvestigationMaster.add(ModelInvestigationMaster(
            jo['PreInvestTypeIDP'].toString(),
            jo['GroupType'],
            jo['GroupName'],
            jo['InvestigationType'],
            jo['RangeValue'],
            false,
          ));
        }
      } else {
        for (var i = 0; i < jsonData.length; i++) {
          for (var j = 0; j < listInvestigationMasterSelected.length; j++) {
            var modelSelected = listInvestigationMasterSelected[j];
            var jo = jsonData[i];
            if (modelSelected.preInvestTypeIDP ==
                jo['PreInvestTypeIDP'].toString()) {
              listInvestigationMaster.add(ModelInvestigationMaster(
                jo['PreInvestTypeIDP'].toString(),
                jo['GroupType'],
                jo['GroupName'],
                jo['InvestigationType'],
                jo['RangeValue'],
                true,
              ));
            } else {
              listInvestigationMaster.add(ModelInvestigationMaster(
                jo['PreInvestTypeIDP'].toString(),
                jo['GroupType'],
                jo['GroupName'],
                jo['InvestigationType'],
                jo['RangeValue'],
                false,
              ));
            }
          }
        }
      }*/
      /*listInvestigationMaster.any((model) => listInvestigationMasterSelected.contains(model){

      });*/

      if (listInvestigationMasterSelected.length > 0) {
        debugPrint("Inside for loop");
        debugPrint(listInvestigationMasterSelected.toString());
        for (int i = 0; i < listInvestigationMaster.length; i++) {
          var modelNotSelected = listInvestigationMaster[i];
          for (int j = 0; j < listInvestigationMasterSelected.length; j++) {
            var modelSelected = listInvestigationMasterSelected[j];
            if (modelSelected.preInvestTypeIDP ==
                modelNotSelected.preInvestTypeIDP) {
              modelNotSelected.isChecked = true;
            }
          }
          //var modelInvestigationMaster = listInvestigationMasterSelected[i];
          /*if (listInvestigationMaster
              .contains(modelInvestigationMaster)) {
            int index =
            listInvestigationMaster.indexOf(modelInvestigationMaster);
            debugPrint("Index is - " + index.toString());
            listInvestigationMaster.remove(modelInvestigationMaster);
            modelInvestigationMaster.isChecked = true;
            listInvestigationMaster.insert(index, modelInvestigationMaster);
          }*/
        }
      }
      setState(() {});
    }
  }

  void submitToInvestigationMasterList(BuildContext context) async {
    /*var jArrayInvestigationMaster = json.decode("");
    jArrayInvestigationMaster.pu*/

    var jArrayInvestigationMaster = "[";
    for (var i = 0; i < listInvestigationMaster.length; i++) {
      if (listInvestigationMaster[i].isChecked) {
        jArrayInvestigationMaster =
            "$jArrayInvestigationMaster{\"PreInvestTypeIDP\":\"${listInvestigationMaster[i].preInvestTypeIDP}\"},";
      }
    }
    jArrayInvestigationMaster = jArrayInvestigationMaster + "]";
    jArrayInvestigationMaster = jArrayInvestigationMaster.replaceAll(",]", "]");
    debugPrint("Final Array");
    debugPrint(jArrayInvestigationMaster);

    String loginUrl = "${baseURL}patientInvestData.php";
    ProgressDialog pr;
    pr = ProgressDialog(context);
    pr.show();
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = /*[*/ "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP! +
        "\"" +
        /*}*/ "," +
        /*{*/ "\"InvestigationDataObj" +
        "\"" +
        ":" +
        jArrayInvestigationMaster +
        "}"; /*]*/

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
    pr.hide();
    if (model.status == "OK") {
      /*var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      listInvestigationMaster = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listInvestigationMaster.add(ModelInvestigationMaster(
          jo['PreInvestTypeIDP'].toString(),
          jo['GroupType'],
          jo['GroupName'],
          jo['InvestigationType'],
          jo['RangeValue'],
          false,
        ));
      }*/
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text("Investigation successfully Added"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.of(context).pop();
    }
  }

  void goToInvestigationSubmitScreen(BuildContext context) {
    List<ModelInvestigationMaster> listInvestigationMasterOnlySelectedOnes =
        null as List<ModelInvestigationMaster>;
    for (var i = 0; i < listInvestigationMaster.length; i++) {
      if (listInvestigationMaster[i].isChecked) {
        listInvestigationMasterOnlySelectedOnes.add(listInvestigationMaster[i]);
      }
    }
    /*Navigator.push(context, MaterialPageRoute(builder: (context) {
      return InvestigationListScreen(
          widget.patientIDP, listInvestigationMasterOnlySelectedOnes);
    }));*/
    Navigator.of(context)
        .pop({'selection': listInvestigationMasterOnlySelectedOnes});
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

class MultiCard extends StatefulWidget {
  ModelInvestigationMaster modelInvestigationMaster;
  int index;

  MultiCard(this.modelInvestigationMaster, this.index);

  @override
  MultiCardState createState() => new MultiCardState();
}

class MultiCardState extends State<MultiCard> {
  var mycolor = Colors.white;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: mycolor,
      child: new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        ListTile(
            selected: widget.modelInvestigationMaster.isChecked,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.modelInvestigationMaster.groupName!
                          .replaceAll("\n", "")
                          .replaceAll("\r", "") +
                      " -> " +
                      widget.modelInvestigationMaster.investigationType!,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: SizeConfig.blockSizeVertical! * 2.3,
                  ),
                ),
                SizedBox(
                  height: 0,
                ),
                Text(
                  widget.modelInvestigationMaster.groupType!,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: SizeConfig.blockSizeVertical! * 2.1,
                  ),
                ),
              ],
            ),
            /*subtitle: new Text(
              widget.modelInvestigationMaster.groupType,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15.0,
              ),
            ),*/
            leading: Checkbox(
              onChanged: (isChecked) {
                toggleSelection();
              },
              value: widget.modelInvestigationMaster.isChecked,
            ),
            onTap: toggleSelection // what should I put here,
            )
      ]),
    );
  }

  void toggleSelection() {
    int index =
        listInvestigationMaster.indexOf(widget.modelInvestigationMaster);
    debugPrint("Index - " + index.toString());
    debugPrint("Before");
    debugPrint(listInvestigationMaster[index].isChecked.toString());
    setState(() {
      if (widget.modelInvestigationMaster.isChecked) {
        mycolor = Colors.white;
        widget.modelInvestigationMaster.isChecked = false;
        /*listInvestigationMaster.remove(widget.modelInvestigationMaster);
        listInvestigationMaster.insert(index, widget.modelInvestigationMaster);
        debugPrint("Index - " + index.toString());
        debugPrint("After");
        debugPrint(listInvestigationMaster[index].isChecked.toString());*/
      } else {
        //mycolor = Colors.grey[300];
        mycolor = Colors.white;
        widget.modelInvestigationMaster.isChecked = true;
        /*listInvestigationMaster.remove(widget.modelInvestigationMaster);
        listInvestigationMaster.insert(index, widget.modelInvestigationMaster);
        debugPrint("Index - " + index.toString());
        debugPrint("After");
        debugPrint(listInvestigationMaster[index].isChecked.toString());*/
      }
    });
  }
}
