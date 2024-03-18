import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_opd_reg.dart';
import 'package:silvertouch/podo/model_profile_patient.dart';
import 'package:silvertouch/podo/model_templates_advice_investigations.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/progress_dialog.dart';

import '../utils/color.dart';

List<ModelOPDRegistration> listOPDRegistration = [];
List<ModelOPDRegistration> listOPDRegistrationSelected = [];
List<ModelOPDRegistration> listOPDRegistrationSearchResults = [];
List<AdviceInvestigationTemplateModel> listTemplates = [];

class SelectAdviceInvestigationsScreen extends StatefulWidget {
  SelectAdviceInvestigationsScreen(
      List<ModelOPDRegistration> listInvestigationsResults) {
    listOPDRegistrationSelected = listInvestigationsResults;
  }

  @override
  State<StatefulWidget> createState() {
    return SelectAdviceInvestigationsScreenState();
  }
}

class SelectAdviceInvestigationsScreenState
    extends State<SelectAdviceInvestigationsScreen> {
  Icon icon = Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget titleWidget = Text("Select Advice Investigations");
  TextEditingController? searchController;
  var focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    getOPDProcedures();
  }

  @override
  void dispose() {
    listOPDRegistration = [];
    listOPDRegistrationSelected = [];
    listOPDRegistrationSearchResults = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: titleWidget,
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(
            color: Colorsblack, size: SizeConfig.blockSizeVertical! * 2.5),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                if (icon.icon == Icons.search) {
                  searchController = TextEditingController(text: "");
                  focusNode.requestFocus();
                  icon = Icon(
                    Icons.cancel,
                    color: Colorsblack,
                  );
                  titleWidget = TextField(
                    controller: searchController,
                    focusNode: focusNode,
                    cursorColor: Colorsblack,
                    onChanged: (text) {
                      setState(() {
                        listOPDRegistrationSearchResults = listOPDRegistration
                            .where((model) =>
                                model.name!
                                    .toLowerCase()
                                    .contains(text.toLowerCase()) ||
                                model.amount!
                                    .toLowerCase()
                                    .contains(text.toLowerCase()))
                            .toList();
                      });
                    },
                    style: TextStyle(
                      color: Colorsblack,
                      fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search Advice Investigations",
                    ),
                  );
                } else {
                  icon = Icon(
                    Icons.search,
                    color: Colorsblack,
                  );
                  titleWidget = Text("Select Advice Investigations");
                  listOPDRegistrationSearchResults = listOPDRegistration;
                }
              });
            },
            icon: icon,
          )
        ],
        toolbarTextStyle: TextTheme(
                titleMedium: TextStyle(
                    color: Colorsblack,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5))
            .bodyMedium,
        titleTextStyle: TextTheme(
                titleMedium: TextStyle(
                    color: Colorsblack,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5))
            .titleLarge,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
            ),
            child: MaterialButton(
              minWidth: SizeConfig.screenWidth,
              onPressed: () {
                showTemplateSelectionDialog(context);
              },
              color: Colors.green,
              splashColor: Colors.green[800],
              child: Text(
                "Select from Templates",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: listOPDRegistrationSearchResults.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.blockSizeHorizontal! * 2,
                          right: SizeConfig.blockSizeHorizontal! * 2,
                          top: SizeConfig.blockSizeHorizontal! * 2),
                      child: InkWell(
                        onTap: () {
                          listOPDRegistrationSearchResults[index].isChecked =
                              !listOPDRegistrationSearchResults[index]
                                  .isChecked!;
                          setState(() {});
                        },
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Card(
                                  child: Padding(
                                padding: EdgeInsets.all(
                                    SizeConfig.blockSizeHorizontal! * 2),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              listOPDRegistrationSearchResults[
                                                      index]
                                                  .name!,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      4,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          SizedBox(
                                            height: SizeConfig
                                                    .blockSizeHorizontal! *
                                                1,
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              listOPDRegistrationSearchResults[
                                                      index]
                                                  .amount!,
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      2.8,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          /*InkWell(
                                    child: Image(
                                      image: AssetImage(
                                          "images/ic_pdf_opd_reg.png"),
                                      width: SizeConfig.blockSizeHorizontal * 8,
                                    ),
                                  )*/
                                        ],
                                      ),
                                    ),
                                    Checkbox(
                                      value: listOPDRegistrationSearchResults[
                                              index]
                                          .isChecked,
                                      onChanged: (bool? value) {
                                        listOPDRegistrationSearchResults[index]
                                            .isChecked = value!;
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              )),
                            ),
                            /*SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 2,
                        ),*/
                            /*Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: SizeConfig.blockSizeHorizontal * 6,
                        ),*/
                          ],
                        ),
                      ));
                }),
          ),
          Align(
            alignment: Alignment.topRight,
            child: RawMaterialButton(
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 2.0),
              onPressed: () {
                getSelectedListAndGoToAddOPDProcedureScreen(context);
                /*Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PatientDashboardScreen()));*/
              },
              elevation: 2.0,
              fillColor: Color(0xFF06A759),
              child: Image(
                width: SizeConfig.blockSizeHorizontal! * 5.5,
                height: SizeConfig.blockSizeHorizontal! * 5.5,
                //height: 80,
                image: AssetImage("images/ic_right_arrow_triangular.png"),
              ),
              shape: CircleBorder(),
            ),
          )
        ],
      ),
    );
  }

  void getOPDProcedures() async {
    listOPDRegistration = [];
    listOPDRegistrationSearchResults = [];
    String loginUrl = "${baseURL}doctorInvestigationList.php";
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
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

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
    getTemplatesForAdviceInvestigations();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listOPDRegistration.add(ModelOPDRegistration(
          jo['PreInvestTypeIDP'].toString(),
          jo['InvestigationType'],
          jo['GroupName'].toString(),
          "",
          amountBeforeDiscount: jo['Price'].toString(),
          discount: "0",
        ));
      }
      listOPDRegistrationSearchResults = listOPDRegistration;
      setState(() {});

      if (listOPDRegistrationSelected.length > 0) {
        debugPrint("Inside for loop");
        for (int i = 0; i < listOPDRegistrationSearchResults.length; i++) {
          var modelNotSelected = listOPDRegistrationSearchResults[i];
          for (int j = 0; j < listOPDRegistrationSelected.length; j++) {
            var modelSelected = listOPDRegistrationSelected[j];
            if (modelSelected.idp == modelNotSelected.idp) {
              modelNotSelected.isChecked = true;
            }
          }
        }
        setState(() {});
      }
    }
  }

  void getTemplatesForAdviceInvestigations() async {
    String loginUrl = "${baseURL}doctorInvestigationTemplete.php";
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
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

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
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      listTemplates = adviceInvestigationTemplateModelFromJson(strData);
      setState(() {});
    }
  }

  void getInvestigationListFromTemplate(int templateIDP) async {
    listOPDRegistrationSelected = [];
    String loginUrl = "${baseURL}doctorInvestigationTempleteDetails.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
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
        "\"," +
        "\"" +
        "InvestTemplateIDP" +
        "\"" +
        ":" +
        "\"" +
        templateIDP.toString() +
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listOPDRegistrationSelected.add(ModelOPDRegistration(
          jo['PreInvestTypeIDP'].toString(),
          jo['InvestigationType'],
          jo['GroupName'].toString(),
          "",
          amountBeforeDiscount: jo['Price'].toString(),
          discount: "0",
        ));
      }
      if (listOPDRegistrationSelected.length > 0) {
        debugPrint("Inside for loop");
        for (int i = 0; i < listOPDRegistrationSearchResults.length; i++) {
          var modelNotSelected = listOPDRegistrationSearchResults[i];
          for (int j = 0; j < listOPDRegistrationSelected.length; j++) {
            var modelSelected = listOPDRegistrationSelected[j];
            if (modelSelected == modelNotSelected) {
              modelNotSelected.isChecked = true;
            }
            /*else {
              modelNotSelected.isChecked = false;
            }*/
          }
        }
        setState(() {});
      }
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

  void getSelectedListAndGoToAddOPDProcedureScreen(BuildContext context) {
    listOPDRegistrationSelected = [];
    listOPDRegistrationSearchResults.forEach((element) {
      if (element.isChecked!) {
        listOPDRegistrationSelected.add(element);
      }
    });
    Navigator.of(context).pop({'selection': listOPDRegistrationSelected});
  }

  void showTemplateSelectionDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: SizeConfig.blockSizeVertical! * 8,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal! * 6.2,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 6,
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal! * 50,
                          height: SizeConfig.blockSizeVertical! * 8,
                          child: Center(
                            child: Text(
                              "Select from templates",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4.8,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListView.builder(
                    itemCount: listTemplates.length,
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            getInvestigationListFromTemplate(
                                listTemplates[index].investTemplateIdp!);
                          },
                          child: Padding(
                              padding: EdgeInsets.all(0.0),
                              child: Container(
                                  width: SizeConfig.blockSizeHorizontal! * 90,
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
                                      listTemplates[index].investTemplateName!,
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

class SelectMasterDialog extends StatefulWidget {
  List<String> list;
  int id;
  Function setStateOfParent;

  SelectMasterDialog(this.list, this.id, this.setStateOfParent);

  @override
  State<StatefulWidget> createState() {
    return SelectMasterDialogState();
  }
}

class SelectMasterDialogState extends State<SelectMasterDialog> {
  Icon? icon;
  Widget? titleWidget;
  var searchController = TextEditingController();
  var focusNode = new FocusNode();

  String getMasterNameFromID(int id) {
    if (id == 0)
      return "Medicine Type";
    else if (id == 1)
      return "Dosage Advice";
    else if (id == 2)
      return "Dosage Schedule";
    else if (id == 3) return "Drug";
    return "";
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

  void getAllMastersFromDrug(BuildContext context, String drugName) async {
    String loginUrl = "${baseURL}doctorDrugDataSingle.php";
    ProgressDialog pr = ProgressDialog(context);
    pr.show();
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    /*final drugIDP =
        listMastersDrugsType[listMastersDrugsTypeString.indexOf(drugName)]
            .masterIDP;*/
    final drugIDP = "";
    String jsonStr = "{" +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"HospitalMedicineIDP\":" +
        "\"$drugIDP\"" +
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
    pr.hide();
    Navigator.of(context).pop();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      /*drugDosageController =
          TextEditingController(text: jsonData[0]['DoseSchedule']);
      durationController =
          TextEditingController(text: jsonData[0]['MedicineDays']);
      drugAdviceController =
          TextEditingController(text: jsonData[0]['DosageAdvice']);*/
      setState(() {});
    }
  }

  @override
  void initState() {
    icon = Icon(
      Icons.search,
      color: Colors.blue,
      size: SizeConfig.blockSizeHorizontal! * 6.2,
    );

    titleWidget = Text(
      "Select ${getMasterNameFromID(widget.id)}",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: SizeConfig.blockSizeHorizontal! * 4.8,
        fontWeight: FontWeight.bold,
        color: Colors.green,
        decoration: TextDecoration.none,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: SizeConfig.blockSizeVertical! * 8,
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.red,
                    size: SizeConfig.blockSizeHorizontal! * 6.2,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(
                  width: SizeConfig.blockSizeHorizontal! * 6,
                ),
                Container(
                  width: SizeConfig.blockSizeHorizontal! * 50,
                  height: SizeConfig.blockSizeVertical! * 8,
                  child: Center(
                    child:
                        titleWidget /*Text(
                      "Select ${getMasterNameFromID(widget.id)}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 4,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        decoration: TextDecoration.none,
                      ),
                    )*/
                    ,
                  ),
                ),
                Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: InkWell(
                          child: icon,
                          onTap: () {
                            setState(() {
                              if (icon!.icon == Icons.search) {
                                searchController =
                                    TextEditingController(text: "");
                                focusNode.requestFocus();
                                this.icon = Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: SizeConfig.blockSizeHorizontal! * 6.2,
                                );
                                this.titleWidget = TextField(
                                  controller: searchController,
                                  focusNode: focusNode,
                                  cursorColor: Colors.black,
                                  onChanged: (text) {
                                    /*setState(() {
                                      widget.list = getMasterListFromID(
                                          widget.id)
                                          .where((elementText) => elementText
                                          .toLowerCase()
                                          .contains(text.toLowerCase()))
                                          .toList();
                                    });*/
                                  },
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 4.0,
                                  ),
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            SizeConfig.blockSizeVertical! *
                                                2.1),
                                    labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            SizeConfig.blockSizeVertical! *
                                                2.1),
                                    //hintStyle: TextStyle(color: Colors.grey),
                                    hintText:
                                        "Search ${getMasterNameFromID(widget.id)}",
                                  ),
                                );
                              } else {
                                this.icon = Icon(
                                  Icons.search,
                                  color: Colors.blue,
                                  size: SizeConfig.blockSizeHorizontal! * 6.2,
                                );
                                this.titleWidget = Text(
                                  "Select ${getMasterNameFromID(widget.id)}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 4.8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    decoration: TextDecoration.none,
                                  ),
                                );
                                //widget.list = getMasterListFromID(widget.id);
                                setState(() {});
                              }
                            });
                            //Navigator.of(context).pop();
                          },
                        ),
                      )),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            child: ListView.builder(
                itemCount: widget.list.length,
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (contextFromList, index) {
                  return InkWell(
                      onTap: () {
                        /*if (widget.id == 1) {
                          drugAdviceController =
                              TextEditingController(text: widget.list[index]);
                          Navigator.of(context).pop();
                          widget.setStateOfParent();
                        } else if (widget.id == 2) {
                          drugDosageController =
                              TextEditingController(text: widget.list[index]);
                          Navigator.of(context).pop();
                          widget.setStateOfParent();
                        } else if (widget.id == 3) {
                          drugNameController =
                              TextEditingController(text: widget.list[index]);
                          getAllMastersFromDrug(context, widget.list[index]);
                        }*/
                        setState(() {});
                      },
                      child: Padding(
                          padding: EdgeInsets.all(0.0),
                          child: Container(
                              width: SizeConfig.blockSizeHorizontal! * 90,
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
                                  widget.list[index],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ))));
                }),
          ),
        ),
      ],
    );
  }
}
