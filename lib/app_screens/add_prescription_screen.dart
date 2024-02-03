import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:swasthyasetu/app_screens/add_consultation_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_masters.dart';
import 'package:swasthyasetu/podo/model_prescription.dart';
import 'package:swasthyasetu/podo/model_templates_prescription.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';

import '../utils/color.dart';
import '../utils/progress_dialog.dart';

List<ModelPrescription> listPrescription = [];
/*List<String> listDrugDosageSuggestions = [];
List<String> listDrugAdviceSuggestions = [];

List<String> listDrugDosageIDP = [];
List<String> listDrugAdviceIDP = [];*/

var selectedDrugDosageIDP = "";
var selectedDrugAdviceIDP = "";
String onTapStatus = "";

TextEditingController drugNameController = TextEditingController();
TextEditingController drugDosageController = TextEditingController();
TextEditingController durationController = TextEditingController();
TextEditingController drugAdviceController = TextEditingController();
TextEditingController notesController = TextEditingController();

ScrollController _scrollController = new ScrollController();

List<ModelMasters> listMastersMedicineType = [];
List<ModelMasters> listMastersAdviceType = [];
List<ModelMasters> listMastersDosageScheduleType = [];
List<ModelMasters> listMastersDrugsType = [];

List<String> listMastersMedicineTypeString = [];
List<String> listMastersAdviceTypeString = [];
List<String> listMastersDosageScheduleTypeString = [];
List<String> listMastersDrugsTypeString = [];

ProgressDialog? pr;

bool isAddButtonEnabled = false;
List<PrescriptionTemplateModel> listTemplates = [];

class AddPrescriptionScreen extends StatefulWidget {
  String patientIDP, idp;
  String imgUrl, fullName, patientID, gender, age, cityName;

  AddPrescriptionScreen(
      this.patientIDP,
      this.idp,
      this.imgUrl,
      this.fullName,
      this.patientID,
      this.gender,
      this.age,
      this.cityName,
      );

  @override
  State<StatefulWidget> createState() {
    return AddPrescriptionScreenState();
  }
}

class AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  @override
  void initState() {
    super.initState();
    listPrescription = [];
    selectedDrugDosageIDP = "";
    selectedDrugAdviceIDP = "";
    onTapStatus = "";

    drugNameController = TextEditingController();
    drugDosageController = TextEditingController();
    durationController = TextEditingController();
    drugAdviceController = TextEditingController();

    _scrollController = new ScrollController();

    listMastersMedicineType = [];
    listMastersAdviceType = [];
    listMastersDosageScheduleType = [];
    listMastersDrugsType = [];

    listMastersMedicineTypeString = [];
    listMastersAdviceTypeString = [];
    listMastersDosageScheduleTypeString = [];
    listMastersDrugsType = [];
    getDrugDosageScheduleAndAdviceList();
    Future.delayed(Duration(microseconds: 300), () {
      getWholeList();
    });
  }

  void getDrugDosageScheduleAndAdviceList() async {
    String loginUrl = "${baseURL}doctorMasterList.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String masterTypeData = "";
    masterTypeData =
    "[{\"MasterType\":\"DrugType\"},{\"MasterType\":\"DrugAdvice\"},{\"MasterType\":\"DrugSchedule\"},{\"MasterType\":\"Drug\"}]";
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
    //pr.hide();
    listMastersMedicineType = [];
    listMastersAdviceType = [];
    listMastersDosageScheduleType = [];
    listMastersDrugsType = [];
    listMastersMedicineTypeString = [];
    listMastersAdviceTypeString = [];
    listMastersDosageScheduleTypeString = [];
    listMastersDrugsTypeString = [];
    listMastersAdviceTypeString.add("No Timing");
    listMastersDosageScheduleTypeString.add("No Frequency");
    listMastersAdviceType.add(ModelMasters("", "No Timing", "DrugAdvice"));
    listMastersDosageScheduleType
        .add(ModelMasters("", "No Frequency", "DrugSchedule"));
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        if (jo['MasterType'] == "DrugType") {
          listMastersMedicineType.add(ModelMasters(
            jo['MasterIDP'].toString(),
            jo['MasterValue'],
            jo['MasterType'],
          ));
          listMastersMedicineTypeString.add(jo['MasterValue']);
        } else if (jo['MasterType'] == "DrugAdvice") {
          listMastersAdviceType.add(ModelMasters(
            jo['MasterIDP'].toString(),
            jo['MasterValue'],
            jo['MasterType'],
          ));
          listMastersAdviceTypeString.add(jo['MasterValue']);
        } else if (jo['MasterType'] == "DrugSchedule") {
          listMastersDosageScheduleType.add(ModelMasters(
            jo['MasterIDP'].toString(),
            jo['MasterValue'],
            jo['MasterType'],
          ));
          listMastersDosageScheduleTypeString.add(jo['MasterValue']);
        } else if (jo['MasterType'] == "Drug") {
          listMastersDrugsType.add(ModelMasters(
            jo['MasterIDP'].toString(),
            jo['MasterValue'],
            jo['MasterType'],
          ));
          listMastersDrugsTypeString.add(jo['MasterValue']);
        }
      }
      //setState(() {});
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

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: colorGrayApp,
      appBar: AppBar(
        elevation: 0,
        title: Text("Add Prescription"),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(color: Colorsblack),
        toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5,
            )).bodyMedium,
        titleTextStyle: TextTheme(
            titleMedium: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5,
            )).titleLarge,
      ),
      body: Builder(
        builder: (context) {
          return Column(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockSizeHorizontal !* 9,
                      ),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22.0)),
                        onPressed: () {
                          showTemplateSelectionDialog(context);
                        },
                        color: colorBlueApp,
                        splashColor: Colors.green[800],
                        child: Text(
                          "Select from Templates",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal !* 3.0,
                    ),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0)),
                      onPressed: () {
                        showBottomSheetDialog();
                      },
                      color: Colors.green,
                      splashColor: Colors.green[800],
                      child: Text(
                        "ADD",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: listPrescription.length > 0
                    ? ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: listPrescription.length,
                        itemBuilder: (context, index) {
                          TextEditingController listDrugNameController =
                          TextEditingController(
                              text: listPrescription[index].drugName);
                          TextEditingController listDrugDosageController =
                          TextEditingController(
                              text:
                              listPrescription[index].drugDosage);
                          TextEditingController listDurationController =
                          TextEditingController(
                              text: listPrescription[index].duration);
                          TextEditingController listDrugAdviceController =
                          TextEditingController(
                              text:
                              listPrescription[index].drugAdvice);
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            margin: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal !* 2),
                            color: white,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width:
                                    SizeConfig.blockSizeHorizontal !*
                                        100,
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Expanded(
                                                child: Padding(
                                                    padding: EdgeInsets
                                                        .all(SizeConfig
                                                        .blockSizeHorizontal !*
                                                        2),
                                                    child: IgnorePointer(
                                                      child: TextField(
                                                        controller:
                                                        listDrugNameController,
                                                        style: TextStyle(
                                                            color: black),
                                                        keyboardType:
                                                        TextInputType
                                                            .phone,
                                                        decoration:
                                                        InputDecoration(
                                                          hintStyle:
                                                          TextStyle(
                                                              color:
                                                              darkgrey),
                                                          labelStyle:
                                                          TextStyle(
                                                              color:
                                                              darkgrey),
                                                          labelText:
                                                          "Drug Name",
                                                          hintText: "",
                                                        ),
                                                      ),
                                                    ))),
                                            Expanded(
                                                child: Padding(
                                                    padding: EdgeInsets
                                                        .all(SizeConfig
                                                        .blockSizeHorizontal !*
                                                        2),
                                                    child: IgnorePointer(
                                                      child: TextField(
                                                        controller:
                                                        listDrugDosageController,
                                                        style: TextStyle(
                                                            color: black),
                                                        keyboardType:
                                                        TextInputType
                                                            .phone,
                                                        decoration:
                                                        InputDecoration(
                                                          hintStyle:
                                                          TextStyle(
                                                              color:
                                                              darkgrey),
                                                          labelStyle:
                                                          TextStyle(
                                                              color:
                                                              darkgrey),
                                                          labelText:
                                                          "Frequency",
                                                          hintText: "",
                                                        ),
                                                      ),
                                                    )
                                                  /*CustomAutocompleteSearch(
                                                                  suggestions:
                                                                      listDrugDosageSuggestions,
                                                                  hint: "Dosage",
                                                                  controller:
                                                                      listDrugDosageController,
                                                                  hideSuggestionsOnCreate:
                                                                      true,
                                                                  onSelected: (text) =>
                                                                      selectedField(
                                                                          "Dosage",
                                                                          text,
                                                                          listDrugDosageController),
                                                                  onTap: () {
                                                                    if (onTapStatus !=
                                                                        "Tapped") {
                                                                      onTapStatus =
                                                                          "Tapped";
                                                                    }
                                                                  })*/
                                                )),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      SizeConfig
                                                          .blockSizeHorizontal !*
                                                          2),
                                                  child: IgnorePointer(
                                                    child: TextField(
                                                      controller:
                                                      listDurationController,
                                                      style: TextStyle(
                                                          color: black),
                                                      keyboardType:
                                                      TextInputType
                                                          .number,
                                                      decoration:
                                                      InputDecoration(
                                                        hintStyle: TextStyle(
                                                            color: darkgrey),
                                                        labelStyle: TextStyle(
                                                            color: darkgrey),
                                                        labelText:
                                                        "Duration(Days)",
                                                        hintText: "",
                                                      ),
                                                    ),
                                                  ),
                                                )),
                                            Expanded(
                                                child: Padding(
                                                    padding: EdgeInsets
                                                        .all(SizeConfig
                                                        .blockSizeHorizontal !*
                                                        2),
                                                    child: IgnorePointer(
                                                      child: TextField(
                                                        controller:
                                                        listDrugAdviceController,
                                                        style: TextStyle(
                                                            color: black),
                                                        keyboardType:
                                                        TextInputType
                                                            .phone,
                                                        decoration:
                                                        InputDecoration(
                                                          hintStyle:
                                                          TextStyle(
                                                              color:
                                                              darkgrey),
                                                          labelStyle:
                                                          TextStyle(
                                                              color:
                                                              darkgrey),
                                                          labelText:
                                                          "Timing",
                                                          hintText: "",
                                                        ),
                                                      ),
                                                    )
                                                  /*CustomAutocompleteSearch(
                                                                  suggestions:
                                                                      listDrugAdviceSuggestions,
                                                                  hint: "Advice",
                                                                  controller:
                                                                      listDrugAdviceController,
                                                                  hideSuggestionsOnCreate:
                                                                      true,
                                                                  onSelected: (text) =>
                                                                      selectedField(
                                                                          "Advice",
                                                                          text,
                                                                          listDrugAdviceController),
                                                                  onTap: () {
                                                                    if (onTapStatus !=
                                                                        "Tapped") {
                                                                      onTapStatus =
                                                                          "Tapped";
                                                                    }
                                                                  })*/
                                                ))
                                          ],
                                        )
                                        /*Row(
                                            children: <Widget>[
                                              Expanded(
                                                  child: Padding(
                                                padding: EdgeInsets.all(SizeConfig
                                                        .blockSizeHorizontal *
                                                    2),
                                                child: TextField(
                                                  controller:
                                                      listDurationController,
                                                  style: TextStyle(
                                                      color: Colors.green),
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  decoration: InputDecoration(
                                                    hintStyle: TextStyle(
                                                        color: Colors.black),
                                                    labelStyle: TextStyle(
                                                        color: Colors.black),
                                                    labelText: "Duration(Days)",
                                                    hintText: "",
                                                  ),
                                                ),
                                              )),
                                              Expanded(
                                                  child: Padding(
                                                      padding: EdgeInsets.all(
                                                          SizeConfig
                                                                  .blockSizeHorizontal *
                                                              2),
                                                      child:
                                                          CustomAutocompleteSearch(
                                                              suggestions:
                                                                  listDrugAdviceSuggestions,
                                                              hint: "Advice",
                                                              controller:
                                                                  listDrugAdviceController,
                                                              hideSuggestionsOnCreate:
                                                                  true,
                                                              onSelected: (text) =>
                                                                  selectedField(
                                                                      "Advice",
                                                                      text,
                                                                      listDrugAdviceController),
                                                              onTap: () {
                                                                if (onTapStatus !=
                                                                    "Tapped") {
                                                                  */ /*_scrollController.animateTo(
                                                        _scrollController.position
                                                            .maxScrollExtent,
                                                        duration: Duration(
                                                            milliseconds: 500),
                                                        curve: Curves.easeOut);*/ /*
                                                                  onTapStatus =
                                                                      "Tapped";
                                                                }
                                                              }))),
                                            ],
                                          ),*/
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (listPrescription[index]
                                        .fromServer) {
                                      deletePrescriptionFromServer(
                                          listPrescription[index]);
                                    } else {
                                      setState(() {
                                        listPrescription.removeAt(index);
                                      });
                                    }
                                  },
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Image(
                                      image: AssetImage(
                                          "images/icn-delete-medicine.png"),
                                      height: 25,
                                      width: 25,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                  SizeConfig.blockSizeHorizontal !* 2,
                                ),
                              ],
                            ),
                          );
                        })
                  ],
                )
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Image(
                        image: AssetImage("images/ic_idea_new.png"),
                        width: 100,
                        height: 100,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockSizeHorizontal !* 3),
                child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.0)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockSizeHorizontal !* 3),
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeConfig.blockSizeHorizontal !* 4.3),
                      ),
                    ),
                    color: colorBlueApp,
                    onPressed: () async {
                      if (listPrescription.length == 0) {
                        final snackBar = SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                              "Please enter atleast one Prescription record"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Future.delayed(Duration(seconds: 2), () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        });
                      } else {
                        bool atleastOneIsAddedFromDevice = false;
                        for (int i = 0; i < listPrescription.length; i++) {
                          if (!listPrescription[i].fromServer) {
                            atleastOneIsAddedFromDevice = true;
                            break;
                          }
                        }
                        if (atleastOneIsAddedFromDevice) {
                          addPrescription(context);
                          /*print(listPrescription.length);*/
                          /*final snackBar = SnackBar(
                            backgroundColor: Colors.green,
                            content: Text("Congrats! Now you can call API!"),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Future.delayed(Duration(seconds: 2), () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          });*/
                        } else {
                          final snackBar = SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                                "Please enter atleast one Prescription record"),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Future.delayed(Duration(seconds: 2), () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          });
                        }
                      }
                      /*var patientIDP = await getPatientIDP();
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return AddPrescriptionScreen(patientIDP);
                  }));*/
                    }),
              ),
            ],
          );
        },
      ),
    );
  }

  showBottomSheetDialog() {
    showModalBottomSheet<void>(
      // context and builder are
      // required properties in this widget
      context: context,
      builder: (BuildContext context) {
        // we set up a container inside which
        // we create center column and display text

        // Returning SizedBox instead of a Container
        return Wrap(
          children: [
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 100,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Flexible(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                            SizeConfig.blockSizeHorizontal !* 2),
                                        child: InkWell(
                                          onTap: () {
                                            showMasterSelectionDialog(
                                                listMastersDrugsTypeString,
                                                3,
                                                setStateOfParent);
                                          },
                                          child: Container(
                                            width:
                                            SizeConfig.blockSizeHorizontal !* 90,
                                            padding: EdgeInsets.all(
                                                SizeConfig.blockSizeHorizontal !* 1),
                                            child: IgnorePointer(
                                              child: TextField(
                                                controller: drugNameController,
                                                style: TextStyle(
                                                    color: black,
                                                    fontSize: SizeConfig
                                                        .blockSizeVertical !*
                                                        2.3),
                                                decoration: InputDecoration(
                                                  hintStyle: TextStyle(
                                                      color: darkgrey,
                                                      fontSize: SizeConfig
                                                          .blockSizeVertical !*
                                                          2.3),
                                                  labelStyle: TextStyle(
                                                      color: darkgrey,
                                                      fontSize: SizeConfig
                                                          .blockSizeVertical !*
                                                          2.3),
                                                  labelText: "Drug Name",
                                                  hintText: "",
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      /*TextField(
                                          controller: drugNameController,
                                          style: TextStyle(color: Colors.green),
                                          decoration: InputDecoration(
                                            hintStyle: TextStyle(color: Colors.black),
                                            labelStyle: TextStyle(color: Colors.black),
                                            labelText: "Drug Name",
                                            hintText: "",
                                          ),
                                        ),*/
                                    ),
                                  ),
                                  Flexible(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                            SizeConfig.blockSizeHorizontal !* 2),
                                        child: InkWell(
                                          onTap: () {
                                            showMasterSelectionDialog(
                                                listMastersDosageScheduleTypeString,
                                                2,
                                                setStateOfParent);
                                          },
                                          child: Container(
                                            width:
                                            SizeConfig.blockSizeHorizontal !* 90,
                                            padding: EdgeInsets.all(
                                                SizeConfig.blockSizeHorizontal !* 1),
                                            child: IgnorePointer(
                                              child: TextField(
                                                controller: drugDosageController,
                                                style: TextStyle(
                                                    color: black,
                                                    fontSize: SizeConfig
                                                        .blockSizeVertical !*
                                                        2.3),
                                                decoration: InputDecoration(
                                                  hintStyle: TextStyle(
                                                      color: darkgrey,
                                                      fontSize: SizeConfig
                                                          .blockSizeVertical !*
                                                          2.3),
                                                  labelStyle: TextStyle(
                                                      color: darkgrey,
                                                      fontSize: SizeConfig
                                                          .blockSizeVertical !*
                                                          2.3),
                                                  labelText: "Frequency",
                                                  hintText: "",
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      /*CustomAutocompleteSearch(
                                              suggestions: listDrugDosageSuggestions,
                                              hint: "Dosage",
                                              controller: drugDosageController,
                                              hideSuggestionsOnCreate: true,
                                              onSelected: (text) => selectedField(
                                                  "Dosage", text, drugDosageController),
                                              onTap: () {
                                                if (onTapStatus != "Tapped") {
                                                  */
                                      /*_scrollController.animateTo(
                                                  _scrollController
                                                      .position.maxScrollExtent,
                                                  duration: Duration(milliseconds: 500),
                                                  curve: Curves.easeOut);*/
                                      /*
                                                  onTapStatus = "Tapped";
                                                }
                                              })*/
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                          SizeConfig.blockSizeHorizontal !* 2),
                                      child: TextField(
                                        controller: durationController,
                                        keyboardType: TextInputType.number,
                                        onChanged: (text) {
                                          checkIfsAddButtonIsEnabled();
                                        },
                                        style: TextStyle(color: black),
                                        decoration: InputDecoration(
                                          hintStyle: TextStyle(color: darkgrey),
                                          labelStyle: TextStyle(color: darkgrey),
                                          labelText: "Duration(Days)",
                                          hintText: "",
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                            SizeConfig.blockSizeHorizontal !* 2),
                                        child: InkWell(
                                          onTap: () {
                                            showMasterSelectionDialog(
                                                listMastersAdviceTypeString,
                                                1,
                                                setStateOfParent);
                                          },
                                          child: Container(
                                            width:
                                            SizeConfig.blockSizeHorizontal !* 90,
                                            padding: EdgeInsets.all(
                                                SizeConfig.blockSizeHorizontal !* 1),
                                            child: IgnorePointer(
                                              child: TextField(
                                                controller: drugAdviceController,
                                                style: TextStyle(
                                                    color: black,
                                                    fontSize: SizeConfig
                                                        .blockSizeVertical !*
                                                        2.3),
                                                decoration: InputDecoration(
                                                  hintStyle: TextStyle(
                                                      color: darkgrey,
                                                      fontSize: SizeConfig
                                                          .blockSizeVertical !*
                                                          2.3),
                                                  labelStyle: TextStyle(
                                                      color: darkgrey,
                                                      fontSize: SizeConfig
                                                          .blockSizeVertical !*
                                                          2.3),
                                                  labelText: "Timing",
                                                  hintText: "",
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      /*CustomAutocompleteSearch(
                                              suggestions: listDrugAdviceSuggestions,
                                              hint: "Advice",
                                              controller: drugAdviceController,
                                              hideSuggestionsOnCreate: true,
                                              onSelected: (text) => selectedField(
                                                  "Advice", text, drugAdviceController),
                                              onTap: () {
                                                if (onTapStatus != "Tapped") {
                                                  */ /*_scrollController.animateTo(
                                                  _scrollController
                                                      .position.maxScrollExtent,
                                                  duration: Duration(milliseconds: 500),
                                                  curve: Curves.easeOut);*/ /*
                                                  onTapStatus = "Tapped";
                                                }
                                              })*/
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                          SizeConfig.blockSizeHorizontal !* 2),
                                      child: TextField(
                                        controller: notesController,
                                        /*keyboardType: TextInputType.number,*/
                                        /*onChanged: (text) {
                                            checkIfsAddButtonIsEnabled();
                                          },*/
                                        style: TextStyle(color: black),
                                        decoration: InputDecoration(
                                          hintStyle: TextStyle(color: darkgrey),
                                          labelStyle: TextStyle(color: darkgrey),
                                          labelText: "Notes",
                                          hintText: "",
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal !* 2,
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal !* 2,
                    ),
                  ],
                ),
                Wrap(
                  children: <Widget>[
                    MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22.0)),
                        child: Text(
                          "ADD",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeConfig.blockSizeVertical !* 2),
                        ),
                        color: colorBlueApp,
                        onPressed:
                        /*isAddButtonEnabled
                              ?*/
                            () {
                          Navigator.pop(context);
                          if (drugNameController.text.trim() ==
                              "" /*||
                                    drugDosageController.text.trim() == ""*/
                              ||
                              durationController.text.trim() ==
                                  "" /*||
                                    drugAdviceController.text.trim() == ""*/
                          ) {
                            debugPrint(drugNameController.text.trim());
                            debugPrint(drugDosageController.text.trim());
                            debugPrint(durationController.text.trim());
                            debugPrint(drugAdviceController.text.trim());
                            final snackBar = SnackBar(
                              backgroundColor: Colors.red,
                              content: Text("Please enter all the fields"),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            Future.delayed(Duration(seconds: 2), () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            });
                          } else {
                            listPrescription.add(ModelPrescription(
                                "",
                                drugNameController.text.toString(),
                                drugDosageController.text.toString(),
                                durationController.text.toString(),
                                drugAdviceController.text.toString(),
                                notesController.text.toString(),
                                false));
                            drugNameController = TextEditingController();
                            drugDosageController = TextEditingController();
                            durationController = TextEditingController();
                            drugAdviceController = TextEditingController();
                            notesController = TextEditingController();
                          }
                          setState(() {});
                        } /*: null*/),
                    /*InkWell(
                        onTap: () {},
                        child: Container(
                            color: Colors.green,
                            child: Padding(
                              padding: EdgeInsets.all(
                                  SizeConfig.blockSizeHorizontal * 5),
                              child: Text(
                                "Add",
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                      ),*/
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
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
                  height: SizeConfig.blockSizeVertical !* 8,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                        Container(
                          width: SizeConfig.blockSizeHorizontal !* 50,
                          height: SizeConfig.blockSizeVertical !* 8,
                          child: Center(
                            child: Text(
                              "Select from templates",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal !* 4.8,
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
                                listTemplates[index].templateIdp!);
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
                                      listTemplates[index].templateName!,
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

  void getInvestigationListFromTemplate(int templateIDP) async {
    String loginUrl = "${baseURL}doctorMedicineTemplateDetails.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    /*listPrescription.forEach((element) {
      if (!element.fromServer)
        listPrescription.removeAt(listPrescription.indexOf(element));
    });*/
    /*listPrescription.removeWhere((element) => !element.fromServer);*/
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
        "TemplateIDP" +
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
    pr?.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listPrescription.add(ModelPrescription(
          jo['HospitalMedicineIDP'],
          jo['MedicineName'],
          jo['DoseSchedule'],
          jo['Days'],
          jo['DosageAdvice'],
          '',
          false,
        ));
      }
      /*getWholeList();*/
      setState(() {});
    }
  }

  void setStateOfParent() {
    setState(() {});
  }

  String getMasterNameFromID(int id) {
    if (id == 0)
      return "Medicine Type";
    else if (id == 1)
      return "Timing";
    else if (id == 2)
      return "Frequency";
    else if (id == 3) return "Drug";
    return "";
  }

  void showMasterSelectionDialog(
      List<String> list, int id, Function setStateOfParent) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: SelectMasterDialog(list, id, setStateOfParent)));
  }

  checkIfsAddButtonIsEnabled() {
    if (drugNameController.text.trim() != "" &&
        drugDosageController.text.trim() != "" &&
        durationController.text.trim() != "" &&
        adviceController.text.trim() != "") {
      isAddButtonEnabled = true;
    } else {
      isAddButtonEnabled = false;
    }
    setState(() {});
  }

  void addPrescription(BuildContext context) async {
    var jArrayPrescription = "[";
    for (var i = 0; i < listPrescription.length; i++) {
      final model = listPrescription[i];
      if (!model.fromServer) {
        print("index for freq.");
        print(listMastersDosageScheduleTypeString.indexOf(model.drugDosage));
        print(listMastersDosageScheduleType[
        listMastersDosageScheduleTypeString.indexOf(model.drugDosage)]
            .masterIDP);
        final drugIDP = listMastersDrugsType[
        listMastersDrugsTypeString.indexOf(model.drugName)]
            .masterIDP;
        final drugDosageIDP = model.drugDosage != ""
            ? listMastersDosageScheduleType[listMastersDosageScheduleTypeString
            .indexOf(model.drugDosage)]
            .masterIDP
            : "";
        final drugAdviceIDP = model.drugAdvice != ""
            ? listMastersAdviceType[
        listMastersAdviceTypeString.indexOf(model.drugAdvice)]
            .masterIDP
            : "";
        jArrayPrescription =
        "$jArrayPrescription{\"HospitalMedicineIDF\":\"$drugIDP\",\"DrugDoseScheduleIDF\":\"$drugDosageIDP\",\"DosageAdviceIDF\":\"$drugAdviceIDP\",\"Days\":\"${model.duration}\",\"Notes\":\"${model.notes}\"},";
      }
    }
    jArrayPrescription = jArrayPrescription + "]";
    jArrayPrescription = jArrayPrescription.replaceAll(",]", "]");

    String loginUrl = "${baseURL}doctorPrescriptionAdd.php";
    ProgressDialog pr;
    pr = ProgressDialog(context);
    pr.show();
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP +
        "\"" +
        "," +
        "\"" +
        "HospitalConsultationIDF" +
        "\"" +
        ":" +
        "\"" +
        widget.idp +
        "\"" +
        "," +
        "\"DrugData" +
        "\"" +
        ":" +
        jArrayPrescription +
        "}";
    debugPrint("Prescription object");
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
    if (model.status == "OK") {
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(milliseconds: 300), () {
        Navigator.of(context).pop();
      });
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> getWholeList() async {
    String loginUrl = "${baseURL}doctorPrescriptionList.php";
    listPrescription = [];
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
        "\"" +
        "," +
        "\"HospitalConsultationIDF\":" +
        "\"${widget.idp}\"" +
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
    getTemplatesForPrescription();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data fetch whole prescription : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listPrescription.add(ModelPrescription(
          jo['HospitalOpthalmicExaminationMedicineIDP'],
          jo['MedicineName'],
          jo['DoseSchedule'],
          jo['Days'],
          jo['DosageAdvice'],
          '',
          true,
        ));
      }
      setState(() {});
    }
  }

  void deletePrescriptionFromServer(ModelPrescription modelPrescription) async {
    String loginUrl = "${baseURL}doctorPrescriptionDelete.php";

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
        "\"" +
        "," +
        "\"HospitalConsultationIDF\":" +
        "\"${widget.idp}\"" +
        "," +
        "\"HospitalOpthalmicExaminationMedicineIDP\":" +
        "\"${modelPrescription.drugIDP}\"" +
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
      getWholeList();
    }
  }

  void getTemplatesForPrescription() async {
    String loginUrl = "${baseURL}doctorMedicineTemplate.php";
    listPrescription = [];
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
        "\"" +
        "," +
        "\"HospitalConsultationIDF\":" +
        "\"${widget.idp}\"" +
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
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data fetch whole prescription : " + strData);
      listTemplates = prescriptionTemplateModelFromJson(strData);
      setStateOfParent();
    }
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
  bool firstTime = true;

  String getMasterNameFromID(int id) {
    if (id == 0)
      return "Medicine Type";
    else if (id == 1)
      return "Timing";
    else if (id == 2)
      return "Frequency";
    else if (id == 3) return "Drug";
    return "";
  }

  List<String> getMasterListFromID(int id) {
    if (id == 0)
      return listMastersMedicineTypeString;
    else if (id == 1)
      return listMastersAdviceTypeString;
    else if (id == 2)
      return listMastersDosageScheduleTypeString;
    else if (id == 3) return listMastersDrugsTypeString;
    return List<String>.empty();
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
    pr = ProgressDialog(context);
    pr!.show();
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    final drugIDP =
        listMastersDrugsType[listMastersDrugsTypeString.indexOf(drugName)]
            .masterIDP;
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
    pr!.hide();
    Navigator.of(context).pop();
    /*listMastersMedicineType = [];
    listMastersAdviceType = [];
    listMastersDosageScheduleType = [];
    listMastersDrugsType = [];
    listMastersMedicineTypeString = [];
    listMastersAdviceTypeString = [];
    listMastersDosageScheduleTypeString = [];
    listMastersDrugsTypeString = [];*/
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      if (strData != "[]") {
        final jsonData = json.decode(strData);
        drugDosageController =
            TextEditingController(text: jsonData[0]['DoseSchedule']);
        durationController =
            TextEditingController(text: jsonData[0]['MedicineDays']);
        drugAdviceController =
            TextEditingController(text: jsonData[0]['DosageAdvice']);
      } else {
        drugDosageController = TextEditingController();
        durationController = TextEditingController();
        drugAdviceController = TextEditingController();
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    firstTime = true;
    /*titleWidget = Text(
      "Select ${getMasterNameFromID(widget.id)}",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: SizeConfig.blockSizeHorizontal * 4.8,
        fontWeight: FontWeight.bold,
        color: Colors.green,
        decoration: TextDecoration.none,
      ),
    );*/

    /*icon = Icon(
      Icons.search,
      color: Colors.blue,
      size: SizeConfig.blockSizeHorizontal * 6.2,
    );*/
    if (widget.id == 3) {
      searchController = TextEditingController(text: "");
      focusNode.requestFocus();
      this.icon = Icon(
        Icons.cancel,
        color: Colors.red,
        size: SizeConfig.blockSizeHorizontal !* 6.2,
      );
      this.titleWidget = TextField(
        controller: searchController,
        focusNode: focusNode,
        cursorColor: Colors.black,
        onChanged: (text) {
          setState(() {
            widget.list = getMasterListFromID(widget.id)
                .where((elementText) =>
                elementText.toLowerCase().contains(text.toLowerCase()))
                .toList();
          });
          firstTime = false;
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
        ),
        decoration: InputDecoration(
          hintStyle: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.blockSizeVertical !* 2.1),
          labelStyle: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.blockSizeVertical !* 2.1),
          //hintStyle: TextStyle(color: Colors.grey),
          hintText: "Search ${getMasterNameFromID(widget.id)}",
        ),
      );
    }
    else {
      titleWidget = Text(
        "Select ${getMasterNameFromID(widget.id)}",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal !* 4.8,
          fontWeight: FontWeight.bold,
          color: Colors.green,
          decoration: TextDecoration.none,
        ),
      );

      icon = Icon(
        Icons.search,
        color: Colors.blue,
        size: SizeConfig.blockSizeHorizontal !* 6.2,
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: SizeConfig.blockSizeVertical !* 8,
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                Container(
                  width: SizeConfig.blockSizeHorizontal !* 50,
                  height: SizeConfig.blockSizeVertical !* 8,
                  child: Center(
                    child:
                    titleWidget,
                    /*Text(
                      "Select ${getMasterNameFromID(widget.id)}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 4,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        decoration: TextDecoration.none,
                      ),
                    )*/
                  ),
                ),
                Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:
                        EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: InkWell(
                          child: icon,
                          onTap: () {
                            setState(() {
                              if (icon?.icon == Icons.search) {
                                searchController =
                                    TextEditingController(text: "");
                                focusNode.requestFocus();
                                this.icon = Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: SizeConfig.blockSizeHorizontal !* 6.2,
                                );
                                this.titleWidget = TextField(
                                  controller: searchController,
                                  focusNode: focusNode,
                                  cursorColor: Colors.black,
                                  onChanged: (text) {
                                    setState(() {
                                      widget.list = getMasterListFromID(
                                          widget.id)
                                          .where((elementText) => elementText
                                          .toLowerCase()
                                          .contains(text.toLowerCase()))
                                          .toList();
                                      /*debugPrint(
                                          widget.list.toString());*/
                                    });
                                  },
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                    SizeConfig.blockSizeHorizontal !* 4.0,
                                  ),
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                        SizeConfig.blockSizeVertical !* 2.1),
                                    labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                        SizeConfig.blockSizeVertical !* 2.1),
                                    //hintStyle: TextStyle(color: Colors.grey),
                                    hintText:
                                    "Search ${getMasterNameFromID(widget.id)}",
                                  ),
                                );
                              } else {
                                this.icon = Icon(
                                  Icons.search,
                                  color: Colors.blue,
                                  size: SizeConfig.blockSizeHorizontal !* 6.2,
                                );
                                this.titleWidget = Text(
                                  "Select ${getMasterNameFromID(widget.id)}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                    SizeConfig.blockSizeHorizontal !* 4.8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    decoration: TextDecoration.none,
                                  ),
                                );
                                widget.list = getMasterListFromID(widget.id);
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
          child: widget.id != 3 || !firstTime
              ? ListView.builder(
              itemCount: widget.list.length,
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (contextFromList, index) {
                return InkWell(
                    onTap: () {
                      if (widget.id == 1) {
                        if (index == 0)
                          drugAdviceController = TextEditingController();
                        else
                          drugAdviceController = TextEditingController(
                              text: widget.list[index]);
                        Navigator.of(context).pop();
                        widget.setStateOfParent();
                      } else if (widget.id == 2) {
                        if (index == 0)
                          drugDosageController = TextEditingController();
                        else
                          drugDosageController = TextEditingController(
                              text: widget.list[index]);
                        Navigator.of(context).pop();
                        widget.setStateOfParent();
                      } else if (widget.id == 3) {
                        drugNameController =
                            TextEditingController(text: widget.list[index]);
                        getAllMastersFromDrug(context, widget.list[index]);
                      }
                      setState(() {});
                      //Navigator.of(contextFromList).pop();
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
                                widget.list[index],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 15,
                                  color:
                                  (widget.id == 1 || widget.id == 2) &&
                                      index == 0
                                      ? Colors.red
                                      : Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ))));
              })
              : Container(),
        ),
      ],
    );
  }
}

/*selectedField(String type, text, TextEditingController anyController) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (type == "Dosage") {
      debugPrint("dosage controller");
      selectedDrugDosageIDP =
          listDrugDosageIDP[listDrugDosageSuggestions.indexOf(text)];
    } else if (type == "Advice") {
      debugPrint("advice controller");
      selectedDrugAdviceIDP =
          listDrugAdviceIDP[listDrugAdviceSuggestions.indexOf(text)];
    }
    anyController = TextEditingController(text: text);
    setState(() {});
}*/
