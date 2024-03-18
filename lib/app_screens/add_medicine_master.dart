import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_masters.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import '../utils/color.dart';
import '../utils/progress_dialog.dart';

TextEditingController medicineNameController = TextEditingController();
TextEditingController medicineTypeController = TextEditingController();
TextEditingController medicineScheduleController = TextEditingController();
TextEditingController medicineAdviceController = TextEditingController();
TextEditingController medicineDaysController = TextEditingController();
TextEditingController medicineQuantityController = TextEditingController();
TextEditingController medicineCompanyController = TextEditingController();

List<ModelMasters> listMastersMedicineType = [];
List<ModelMasters> listMastersAdviceType = [];
List<ModelMasters> listMastersDosageScheduleType = [];

List<String> listMastersMedicineTypeString = [];
List<String> listMastersAdviceTypeString = [];
List<String> listMastersDosageScheduleTypeString = [];

ProgressDialog? pr;

class AddMedicineMaster extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddMedicineMasterState();
  }
}

class AddMedicineMasterState extends State<AddMedicineMaster> {
  @override
  void initState() {
    super.initState();
    medicineNameController = TextEditingController();
    medicineTypeController = TextEditingController();
    medicineScheduleController = TextEditingController();
    medicineAdviceController = TextEditingController();
    medicineDaysController = TextEditingController();
    medicineQuantityController = TextEditingController();
    medicineCompanyController = TextEditingController();

    listMastersMedicineType = [];
    listMastersAdviceType = [];
    listMastersDosageScheduleType = [];
    listMastersMedicineTypeString = [];
    listMastersAdviceTypeString = [];
    listMastersDosageScheduleTypeString = [];
    getMedicineMasters();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Medicine"),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(
            color: Colorsblack, size: SizeConfig.blockSizeVertical! * 2.3),
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
      body: Builder(
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: false,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: medicineNameController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Medicine Name",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 1,
                    ),
                    InkWell(
                      onTap: () {
                        showMasterSelectionDialog(
                            listMastersMedicineTypeString, 0);
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal! * 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal! * 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: medicineTypeController,
                              style: TextStyle(color: Colors.green),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: Colors.black),
                                labelStyle: TextStyle(color: Colors.black),
                                labelText: "Medicine Type",
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 1,
                    ),
                    InkWell(
                      onTap: () {
                        showMasterSelectionDialog(
                            listMastersDosageScheduleTypeString, 2);
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal! * 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal! * 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: medicineScheduleController,
                              style: TextStyle(color: Colors.green),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: Colors.black),
                                labelStyle: TextStyle(color: Colors.black),
                                labelText: "Medicine Schedule",
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 1,
                    ),
                    InkWell(
                      onTap: () {
                        showMasterSelectionDialog(
                            listMastersAdviceTypeString, 1);
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal! * 90,
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal! * 1),
                          child: IgnorePointer(
                            child: TextField(
                              controller: medicineAdviceController,
                              style: TextStyle(color: Colors.green),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: Colors.black),
                                labelStyle: TextStyle(color: Colors.black),
                                labelText: "Medicine Advice",
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 1,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: medicineDaysController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Medicine Days",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 1,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: medicineQuantityController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Medicine Quantity",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 1,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 1),
                        child: TextField(
                          controller: medicineCompanyController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical! * 2.3),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical! * 2.3),
                            labelText: "Medicine Company",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(
                      right: SizeConfig.blockSizeHorizontal! * 3,
                      top: SizeConfig.blockSizeHorizontal! * 3,
                      bottom: SizeConfig.blockSizeHorizontal! * 3),
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal! * 12,
                    height: SizeConfig.blockSizeHorizontal! * 12,
                    child: RawMaterialButton(
                      onPressed: () {
                        submitNewMedicine(context);
                      },
                      elevation: 2.0,
                      fillColor: Color(0xFF06A759),
                      child: Image(
                        width: SizeConfig.blockSizeHorizontal! * 5.5,
                        height: SizeConfig.blockSizeHorizontal! * 5.5,
                        //height: 80,
                        image:
                            AssetImage("images/ic_right_arrow_triangular.png"),
                      ),
                      shape: CircleBorder(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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

  void getMedicineMasters() async {
    String mastersListUrl = "${baseURL}doctorMasterList.php";
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
      url: mastersListUrl,
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
    listMastersMedicineType = [];
    listMastersAdviceType = [];
    listMastersDosageScheduleType = [];
    listMastersMedicineTypeString = [];
    listMastersAdviceTypeString = [];
    listMastersDosageScheduleTypeString = [];
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
        }
        /*else if (jo['MasterType'] == "Drug") {
          listMastersDrugsType.add(ModelMasters(
            jo['MasterIDP'].toString(),
            jo['MasterValue'],
            jo['MasterType'],
          ));
          listMastersDrugsTypeString.add(jo['MasterValue']);
        }*/
      }
      setState(() {});
    }
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
                            /*setState(() {
                          widget.type = "My type";
                        });*/
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
                              "Select ${getMasterNameFromID(id)}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4,
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
                                  medicineTypeController =
                                      TextEditingController(text: list[index]);
                                else if (id == 1)
                                  medicineAdviceController =
                                      TextEditingController(text: list[index]);
                                else if (id == 2)
                                  medicineScheduleController =
                                      TextEditingController(text: list[index]);
                                /*else if (id == 3) {
                                  drugNameController =
                                      TextEditingController(text: list[index]);
                                  getAllMastersFromDrug(context, list[index]);
                                }*/
                                Navigator.of(context).pop();
                                setState(() {});
                              },
                              child: Padding(
                                  padding: EdgeInsets.all(0.0),
                                  child: Container(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 90,
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
                                            color: Colors.black,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ))));
                        }),
                  ),
                ),
              ],
            )));
  }

  void submitNewMedicine(BuildContext context) async {
    if (medicineNameController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please enter Medicine Name"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (medicineTypeController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Medicine Type"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (medicineScheduleController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Medicine Schedule"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (medicineAdviceController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please select Medicine Advice"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (medicineDaysController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please enter Medicine Days"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (medicineQuantityController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please enter Medicine Quantity"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (medicineCompanyController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please enter Medicine Company"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    String addMedicineUrl = "${baseURL}doctorMedicineAdd.php";

    pr = ProgressDialog(context);

    pr!.show();

    String patientIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();

    debugPrint("Key and type");

    debugPrint(patientUniqueKey);

    debugPrint(userType);

    final drugTypeIDP = listMastersMedicineType[listMastersMedicineTypeString
            .indexOf(medicineTypeController.text.trim())]
        .masterIDP;
    final drugDosageIDP = listMastersDosageScheduleType[
            listMastersDosageScheduleTypeString
                .indexOf(medicineScheduleController.text.trim())]
        .masterIDP;
    final drugAdviceIDP = listMastersAdviceType[listMastersAdviceTypeString
            .indexOf(medicineAdviceController.text.trim())]
        .masterIDP;

    print(medicineTypeController.text.trim());
    print(medicineScheduleController.text.trim());
    print(medicineAdviceController.text.trim());

    /*print(listMastersDrugsType);*/

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
        medicineNameController.text +
        "\"" +
        "," +
        "\"" +
        "MedicineTypeIDF" +
        "\"" +
        ":" +
        "\"" +
        drugTypeIDP +
        "\"" +
        "," +
        "\"" +
        "DrugDoseScheduleIDF" +
        "\"" +
        ":" +
        "\"" +
        drugDosageIDP +
        "\"" +
        "," +
        "\"" +
        "DosageAdviceIDF" +
        "\"" +
        ":" +
        "\"" +
        drugAdviceIDP +
        "\"" +
        "," +
        "\"MedicineDays\":\"${medicineDaysController.text.trim()}\"," +
        "\"MinimumQuantity\":\"${medicineQuantityController.text.trim()}\"," +
        "\"MedicineManufacturer\":\"${medicineCompanyController.text.trim()}\"" +
        "}";

    //String jsonStr = "";

    debugPrint("Vital value");

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: addMedicineUrl,
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

    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pr!.hide();
      Future.delayed(Duration(milliseconds: 300), () {
        Navigator.of(context).pop();
      });
      setState(() {});
    }
  }
}
