import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/color.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

import '../../podo/model_pmr.dart';

List<MedicineModel> listPMR = [];


class PMRScreen extends StatefulWidget {


  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;

  PMRScreen({
    required this.patientindooridp,
    required this.PatientIDP,
    required this.doctoridp,
    required this.firstname,
    required this.lastName,
  });

  @override
  State<PMRScreen> createState() => _PMRScreenState();
}

class _PMRScreenState extends State<PMRScreen> {

  ScrollController _scrollController = new ScrollController();

  TextEditingController SelectPMRController = TextEditingController();
  TextEditingController PMRSchedulController = TextEditingController();
  TextEditingController QtyController = TextEditingController();
  TextEditingController RemarksController = TextEditingController();

  List<Map<String, dynamic>> listBillingServices1 = <Map<String, dynamic>>[];

  // List<String> listBillingServices = [];
  // List<TextEditingController> serviceControllers = [];
  // List<TextEditingController> serviceControllers1 = [];
  // List<TextEditingController> serviceControllers2 = [];


  @override
  void initState() {
    // selectedOrganizationName;
    getPMRList(context);
    super.initState();
  }

  void getPMRList(BuildContext context) async {
    print('getBillingList');

    try{
      String loginUrl = "${baseURL}doctor_particular_list.php";
      ProgressDialog pr = ProgressDialog(context);
      Future.delayed(Duration.zero, () {
        pr.show();
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

      pr.hide();

      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);

        debugPrint("Decoded Data List : " + strData);
        final jsonData = json.decode(strData);

        for (var i = 0; i < jsonData.length; i++)
        {
          final jo = jsonData[i];
          String OPDService = jo['OPDService'].toString();
          listBillingServices.add(OPDService);
          // debugPrint("Added to list: $diagnosisName");
        }

        for (var i = 0; i < jsonData.length; i++) {

          final jo = jsonData[i];
          String HospitalOPDServcesIDP = jo['HospitalOPDServcesIDP'].toString();
          String OPDService = jo['OPDService'].toString();
          String price = jo['Price'].toString();

          Map<String, dynamic> OrganizationMap = {
            "HospitalOPDServcesIDP": HospitalOPDServcesIDP,
            "OPDService": OPDService,
            "Price" : price,
          };
          listBillingServices1.add(OrganizationMap);
          // debugPrint("Added to list: $complainName");

        }
        setState(() {});
      }
    }catch (e) {
      print('Error decoding JSON: $e');
    }
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
          // return Container();
            return Column(
            children: <Widget>[
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
              Expanded(
                child: listPMR.length > 0
                    ? ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: listPMR.length,
                        itemBuilder: (context, index) {
                          TextEditingController SelectPMRController1 =
                          TextEditingController(
                              text: listPMR[index].medicineName);
                          TextEditingController listDrugDosageController1 =
                          TextEditingController(
                              text:
                              listPMR[index].doseSchedule);

                          TextEditingController QtyController1 =
                          TextEditingController(text: "");

                          TextEditingController RemarksController1 =
                          TextEditingController(
                              text: "");
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
                                                        SelectPMRController1,
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
                                                          "Select Particular Name",
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
                                                        listDrugDosageController1,
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
                                                      QtyController1,
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
                                                        "Requested Qty.",
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
                                                        RemarksController1,
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
                                                          "Remarks",
                                                          hintText: "",
                                                        ),
                                                      ),
                                                    )
                                                ))
                                          ],
                                        )

                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (listPMR[index]
                                        .fromServer) {
                                      deletePrescriptionFromServer(
                                          listPMR[index]);
                                    } else {
                                      setState(() {
                                        listPMR.removeAt(index);
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
                      if (listPMR.length == 0) {
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
                        for (int i = 0; i < listPMR.length; i++) {
                          if (!listPMR[i].fromServer) {
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
                                                controller: SelectPMRController,
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
                                                  labelText: "Select Particular Name",
                                                  hintText: "",
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
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
                                                controller: PMRSchedulController,
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
                                                  labelText: "Schedule",
                                                  hintText: "",
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
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
                                        controller: QtyController,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(color: black),
                                        decoration: InputDecoration(
                                          hintStyle: TextStyle(color: darkgrey),
                                          labelStyle: TextStyle(color: darkgrey),
                                          labelText: "Requested Qty.",
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
                                            // showMasterSelectionDialog(
                                            //     listMastersAdviceTypeString,
                                            //     1,
                                            //     setStateOfParent);
                                          },
                                          child: Container(
                                            width:
                                            SizeConfig.blockSizeHorizontal !* 90,
                                            padding: EdgeInsets.all(
                                                SizeConfig.blockSizeHorizontal !* 1),
                                            child: IgnorePointer(
                                              child: TextField(
                                                controller: RemarksController,
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
                                                  labelText: "Remarks",
                                                  hintText: "",
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
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
                          if (SelectPMRController.text.trim() ==
                              "" /*||
                                    drugDosageController.text.trim() == ""*/
                              ||
                              QtyController.text.trim() ==
                                  "" /*||
                                    drugAdviceController.text.trim() == ""*/
                          ) {
                            debugPrint(SelectPMRController.text.trim());
                            debugPrint(PMRSchedulController.text.trim());
                            debugPrint(QtyController.text.trim());
                            debugPrint(RemarksController.text.trim());
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
                            listPMR.add(MedicineModel(
                                SelectPMRController.text.toString(),
                                PMRSchedulController.text.toString(),
                                QtyController.text.toString(),
                                RemarksController.text.toString(),
                                false));
                            SelectPMRController = TextEditingController();
                            PMRSchedulController = TextEditingController();
                            QtyController = TextEditingController();
                            RemarksController = TextEditingController();
                          }
                          setState(() {});
                        }),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
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



  void getAddedBillingSubmit(
      BuildContext context,
      String patientindooridp,
      String PatientIDF
      ) async {
    print('getBillingList');



    try{
      String loginUrl = "${baseURL}doctor_add_pmr_submit.php";
      ProgressDialog pr = ProgressDialog(context);
      Future.delayed(Duration.zero, () {
        pr.show();
      });

      // List<String> serviceValues = serviceControllers.map((controller) => controller.text).toList();

      // var jsonArrayServices = "[";
      // for (var i = 0; i < serviceValues.length; i++) {
      //   jsonArrayServices += "\"${serviceValues[i]}\"";
      //
      //   // Add a comma if it's not the last element
      //   if (i < serviceValues.length - 1) {
      //     jsonArrayServices += ",";
      //   }
      // }
      // jsonArrayServices += "]";


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
          "\"" +
          "PatientIndoorIDF" +
          "\"" +
          ":" +
          "\"" +
          patientindooridp +
          "\"" +
          "," +
          "\"" +
          "PatientIDF" +
          "\"" +
          ":" +
          "\"" +
          PatientIDF +
          "\"" +
          "," +
          "\"" +
          "ipdservice" +
          "\"" +
          ":" +
          "\"" +
          " " +
          // "$jsonArrayServices" +
          "\"" +
          "}";

      // {"pmrlength":"1","particularname":"123",
      // "requestedqty":"1","remark":"hii hellorwerwerwerewrewr",
      // "PatientIDF":"736","DoctorIDP":"1","PatientIndoorIDF":"452"}

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
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);

        debugPrint("Decoded Data List : " + strData);
        final jsonData = json.decode(strData);

        for (var i = 0; i < jsonData.length; i++)
        {
          final jo = jsonData[i];
          String OPDService = jo['OPDService'].toString();
          listBillingServices.add(OPDService);
          // debugPrint("Added to list: $diagnosisName");
        }

        for (var i = 0; i < jsonData.length; i++) {

          final jo = jsonData[i];
          String HospitalOPDServcesIDP = jo['HospitalOPDServcesIDP'].toString();
          String OPDService = jo['OPDService'].toString();
          String price = jo['Price'].toString();

          Map<String, dynamic> OrganizationMap = {
            "HospitalOPDServcesIDP": HospitalOPDServcesIDP,
            "OPDService": OPDService,
            "Price" : price,
          };
          listBillingServices1.add(OrganizationMap);
          // debugPrint("Added to list: $complainName");

        }
        setState(() {});
      }
    }catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }

}
