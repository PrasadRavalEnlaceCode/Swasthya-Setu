import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:swasthyasetu/app_screens/add_medicine_master.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_masters.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';

import '../utils/color.dart';
import '../utils/progress_dialog.dart';

TextEditingController itemNameController = TextEditingController();
TextEditingController genericController = TextEditingController();
TextEditingController formulationController = TextEditingController();
TextEditingController timingController = TextEditingController();
TextEditingController dossageController = TextEditingController();
TextEditingController durationInDaysController = TextEditingController();
TextEditingController minQuantityController = TextEditingController();
TextEditingController manufacturerController = TextEditingController();
TextEditingController notesController = TextEditingController();
TextEditingController itemGroupController = TextEditingController();
TextEditingController hsnController = TextEditingController();
TextEditingController marketerController = TextEditingController();
TextEditingController gstPlanController = TextEditingController();
//TextEditingController frequencyController = TextEditingController();
TextEditingController unitOfMeasurementController = TextEditingController();

List<ModelMasters> listMastersMedicineType = [];
List<ModelMasters> listMastersAdviceType = [];
List<ModelMasters> listMastersDosageScheduleType = [];
List<ModelMasters> listMastersUnitOfMeasurement = [];

List<String> listMastersMedicineTypeString = [];
List<String> listMastersAdviceTypeString = [];
List<String> listMastersDosageScheduleTypeString = [];
List<String> listMastersUnitOfMeasurementString = [];

ProgressDialog? pr;

class AddDrugScreen extends StatefulWidget {
  String from, hospitalMedicineIDP;

  AddDrugScreen(this.from, this.hospitalMedicineIDP);

  @override
  State<StatefulWidget> createState() {
    return AddDrugScreenState();
  }
}

class AddDrugScreenState extends State<AddDrugScreen> {
  var isFABVisible = true;
  ScrollController? hideFABController;
  String deleteflag = "0";

  @override
  void initState() {
    super.initState();
    itemNameController = TextEditingController();
    genericController = TextEditingController();
    formulationController = TextEditingController();
    timingController = TextEditingController();
    dossageController = TextEditingController();
    durationInDaysController = TextEditingController();
    minQuantityController = TextEditingController();
    manufacturerController = TextEditingController();
    notesController = TextEditingController();
    itemGroupController = TextEditingController();
    hsnController = TextEditingController();
    marketerController = TextEditingController();
    gstPlanController = TextEditingController();
    //frequencyController = TextEditingController();
    unitOfMeasurementController = TextEditingController();

    listMastersMedicineType = [];
    listMastersAdviceType = [];
    listMastersDosageScheduleType = [];

    listMastersMedicineTypeString = [];
    listMastersAdviceTypeString = [];
    listMastersDosageScheduleTypeString = [];
    if(widget.from=="add")
      {
        deleteflag = "0";
      }
    else if(widget.from=="update")
      {
        deleteflag = "1";
      }
    else
      {

      }
    getAllTheMasterListsForDrugScreen();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${widget.from[0].toUpperCase()}${widget.from.substring(1)} Drug"),
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
      body: Builder(
        builder: (context) {
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: itemNameController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: "Drug Name",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          showMasterSelectionDialog(
                              listMastersMedicineTypeString, 0);
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: formulationController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelText: "Formulation",
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: genericController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          /*minLines: 5,
                          maxLines: 5,
                          maxLength: 500,*/
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: "Generic",
                            hintText: "",
                            counterText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          showMasterSelectionDialog(
                              listMastersDosageScheduleTypeString, 2);
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: dossageController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelText: "Frequency",
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          showMasterSelectionDialog(
                              listMastersAdviceTypeString, 1);
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: timingController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelText: "Timing",
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: durationInDaysController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: "Duration (in days)",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: notesController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          minLines: 5,
                          maxLines: 5,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: "Notes",
                            hintText: "",
                            counterText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: itemGroupController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: "Item Group",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          showMasterSelectionDialog(
                              listMastersUnitOfMeasurementString, 3);
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: unitOfMeasurementController,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: SizeConfig.blockSizeVertical !* 2.3),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeVertical !* 2.3),
                                labelText: "Unit of Measurement",
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: manufacturerController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: "Manufacturer",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: hsnController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: "HSN",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: marketerController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: "Marketer",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 1),
                        child: TextField(
                          controller: gstPlanController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.3),
                            labelText: "GST Plan",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    /*Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal * 1),
                        child: TextField(
                          controller: frequencyController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical * 2.3),
                            labelText: "Frequency",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),*/
                    /*Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal * 1),
                        child: TextField(
                          controller: minQuantityController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical * 2.3),
                            labelText: "Minimum Quantity",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),*/
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 2),
                    child: Container(
                      width: SizeConfig.blockSizeHorizontal !* 12,
                      height: SizeConfig.blockSizeHorizontal !* 12,
                      child: RawMaterialButton(
                        onPressed: () {
                          addDrugToTheList(context);
                        },
                        elevation: 2.0,
                        fillColor: Color(0xFF06A759),
                        child: Image(
                          width: SizeConfig.blockSizeHorizontal !* 5.5,
                          height: SizeConfig.blockSizeHorizontal !* 5.5,
                          //height: 80,
                          image: AssetImage(
                              "images/ic_right_arrow_triangular.png"),
                        ),
                        shape: CircleBorder(),
                      ),
                    ),
                  ))
            ],
          );
        },
      ),
    );
  }

  String getMasterNameFromID(int id) {
    if (id == 0)
      return "Medicine Type";
    else if (id == 1)
      return "Timing";
    else if (id == 2)
      return "Frequency";
    else if (id == 3) return "Unit of Measurement";
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

  void showMasterSelectionDialog(List<String> list, int id) {
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
                            /*setState(() {
                          widget.type = "My type";
                        });*/
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
                              "Select ${getMasterNameFromID(id)}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal !* 4,
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
                Expanded(
                  child: Container(
                    child: ListView.builder(
                        itemCount: list.length,
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return InkWell(
                              onTap: () {
                                if (id == 0)
                                  formulationController =
                                      TextEditingController(text: list[index]);
                                else if (id == 1) {
                                  if (index == 0)
                                    timingController = TextEditingController();
                                  else
                                    timingController = TextEditingController(
                                        text: list[index]);
                                } else if (id == 2) {
                                  if (index == 0)
                                    dossageController = TextEditingController();
                                  else
                                    dossageController = TextEditingController(
                                        text: list[index]);
                                } else if (id == 3) {
                                  if (index == 0)
                                    unitOfMeasurementController =
                                        TextEditingController();
                                  else
                                    unitOfMeasurementController =
                                        TextEditingController(
                                            text: list[index]);
                                }
                                setState(() {});
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                  padding: EdgeInsets.all(0.0),
                                  child: Container(
                                      width:
                                          SizeConfig.blockSizeHorizontal !* 90,
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
                                          list[index],
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: (id == 1 ||
                                                        id == 2 ||
                                                        id == 3) &&
                                                    index == 0
                                                ? Colors.red
                                                : Colors.black,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ))));
                        }),
                  ),
                ),
                /*Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: MaterialButton(
                        color: Colors.red,
                        onPressed: () {
                          Navigator.of(context).pop(); // To close the dialog
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ))*/
              ],
            )));
  }

  void getAllTheMasterListsForDrugScreen() async {
    String loginUrl = "${baseURL}doctorMasterList.php";

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
    masterTypeData =
        "[{\"MasterType\":\"DrugType\"},{\"MasterType\":\"DrugAdvice\"},{\"MasterType\":\"DrugSchedule\"},{\"MasterType\":\"UnitofMeasurement\"}]";
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
    print('encodedJSONStr $encodedJSONStr');
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
    if (widget.from != "update") pr!.hide();
    listMastersMedicineType = [];
    listMastersAdviceType = [];
    listMastersDosageScheduleType = [];
    listMastersMedicineTypeString = [];
    listMastersAdviceTypeString = [];
    listMastersDosageScheduleTypeString = [];
    listMastersUnitOfMeasurement = [];
    listMastersUnitOfMeasurementString = [];
    listMastersAdviceTypeString.add("No Timing");
    listMastersDosageScheduleTypeString.add("No Frequency");
    listMastersUnitOfMeasurementString.add("No Unit of measurement");
    listMastersAdviceType.add(ModelMasters("", "No Timing", "DrugAdvice"));
    listMastersDosageScheduleType
        .add(ModelMasters("", "No Frequency", "DrugSchedule"));
    listMastersUnitOfMeasurement
        .add(ModelMasters("", "No Unit of measurement", "UnitofMeasurement"));
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
        } else if (jo['MasterType'] == "UnitofMeasurement") {
          listMastersUnitOfMeasurement.add(ModelMasters(
            jo['UnitOfMeasurementIDP'].toString(),
            jo['UnitOfMeasurementValue'],
            jo['MasterType'],
          ));
          listMastersUnitOfMeasurementString.add(jo['UnitOfMeasurementValue']);
        }
      }
      setState(() {});
    }
    if (widget.from == "update") getEditDrugData(context);
  }

  void addDrugToTheList(BuildContext context) async {
    if (itemNameController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please type Drug Name"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(seconds: 2), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
      return;
    }
    if (formulationController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Formulation"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(seconds: 2), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
      return;
    }
    /*if (dossageController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Dossage"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(seconds: 2), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
      return;
    }
    if (timingController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Timing"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(seconds: 2), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
      return;
    }*/

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
    String hospitalMedicineIDP = "";
    if (widget.from == "update")
      hospitalMedicineIDP = widget.hospitalMedicineIDP;
    else if (widget.from == "add") hospitalMedicineIDP = "";
    String medicineTypeIDP = "";
    String dosageAdviceIDP = "";
    String drugDoseScheduleIDP = "";
    String unitOfMeasurementIDP = "";
    if (listMastersMedicineTypeString
        .contains(formulationController.text.trim()))
      medicineTypeIDP = listMastersMedicineType[listMastersMedicineTypeString
              .indexOf(formulationController.text.trim())]
          .masterIDP;
    if (listMastersAdviceTypeString.contains(timingController.text.trim()))
      dosageAdviceIDP = listMastersAdviceType[
              listMastersAdviceTypeString.indexOf(timingController.text.trim())]
          .masterIDP;
    if (listMastersDosageScheduleTypeString
        .contains(dossageController.text.trim()))
      drugDoseScheduleIDP = listMastersDosageScheduleType[
              listMastersDosageScheduleTypeString
                  .indexOf(dossageController.text.trim())]
          .masterIDP;
    if (listMastersUnitOfMeasurementString
        .contains(unitOfMeasurementController.text.trim()))
      unitOfMeasurementIDP = listMastersUnitOfMeasurement[
              listMastersUnitOfMeasurementString
                  .indexOf(unitOfMeasurementController.text.trim())]
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
        "\"" +
        "MedicineName" +
        "\"" +
        ":" +
        "\"" +
        itemNameController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "MedicineContent" +
        "\"" +
        ":" +
        "\"" +
        genericController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "MedicineTypeIDF" +
        "\"" +
        ":" +
        "\"" +
        medicineTypeIDP +
        "\"" +
        "," +
        "\"" +
        "DosageAdviceIDF" +
        "\"" +
        ":" +
        "\"" +
        dosageAdviceIDP +
        "\"" +
        "," +
        "\"" +
        "DrugDoseScheduleIDF" +
        "\"" +
        ":" +
        "\"" +
        drugDoseScheduleIDP +
        "\"" +
        "," +
        "\"" +
        "MedicineDays" +
        "\"" +
        ":" +
        "\"" +
        durationInDaysController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "MedicineManufacturer" +
        "\"" +
        ":" +
        "\"" +
        manufacturerController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "HospitalMedicineIDP" +
        "\"" +
        ":" +
        "\"" +
        "" +
        "\"" +
        "," +
        "\"" +
        "DeleteFlag" +
        "\"" +
        ":" +
        "\"" +
        "$deleteflag" +
        "\"" +
        "," +
        "\"" +
        "Notes" +
        "\"" +
        ":" +
        "\"" +
        notesController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "UnitofMeasurementIDF" +
        "\"" +
        ":" +
        "\"" +
        unitOfMeasurementIDP +
        "\"" +
        "," +
        "\"" +
        "HSN" +
        "\"" +
        ":" +
        "\"" +
        hsnController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "Marketer" +
        "\"" +
        ":" +
        "\"" +
        marketerController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "GSTPlan" +
        "\"" +
        ":" +
        "\"" +
        gstPlanController.text.trim() +
        "\"" +
        "," +
        "\"" +
        "ItemGroup" +
        "\"" +
        ":" +
        "\"" +
        itemGroupController.text.trim() +
        "\"" +
         "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    print('encodedJSONStr $encodedJSONStr');
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
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.of(context).pop();
      });
    }
  }

  void getEditDrugData(BuildContext context) async {
    String loginUrl = "${baseURL}doctorDrugDataSingle.php";
    /*ProgressDialog pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr.show();
    });*/
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
        "\"HospitalMedicineIDP\":" +
        "\"${widget.hospitalMedicineIDP}\"" +
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
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      var jo = jsonData[0];
      itemNameController = TextEditingController(text: jo['MedicineName']);
      genericController = TextEditingController(text: jo['MedicineContent']);
      formulationController = TextEditingController(text: jo['TypeName']);
      timingController = TextEditingController(text: jo['DosageAdvice']);
      dossageController = TextEditingController(text: jo['DoseSchedule']);
      durationInDaysController =
          TextEditingController(text: jo['MedicineDays']);
      minQuantityController =
          TextEditingController(text: jo['MinimumQuantity']);
      manufacturerController =
          TextEditingController(text: jo['MedicineManufacturer']);
      notesController = TextEditingController(text: jo['Remarks']);
      itemGroupController = TextEditingController(text: jo['MedicineGroup']);
      listMastersUnitOfMeasurement.forEach((element) {
        if (element.masterIDP == jo['UnitOfMeasurmentIDF']) {
          unitOfMeasurementController =
              TextEditingController(text: element.masterValue);
        }
      });
      hsnController = TextEditingController(text: jo['HSN']);
      marketerController = TextEditingController(text: jo['Marketor']);
      gstPlanController = TextEditingController(text: jo['GST_Plan']);
      //frequencyController = TextEditingController(text: jo['Frequnecy']);
      setState(() {});
    }
  }
}
