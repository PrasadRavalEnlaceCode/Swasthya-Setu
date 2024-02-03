import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/color.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:swasthyasetu/widgets/autocomplete_custom.dart';

import '../add_patient_screen_doctor.dart';

class BillingScreen extends StatefulWidget {


  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;

  BillingScreen({
    required this.patientindooridp,
    required this.PatientIDP,
    required this.doctoridp,
    required this.firstname,
    required this.lastName,
  });

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  ScrollController _scrollController = new ScrollController();
  String lastSelected = '';
  List<Map<String, dynamic>> listBillingServices1 = <Map<String, dynamic>>[];
  TextEditingController serviceNameController1 = TextEditingController();
  List<String> listBillingServices = [];
  List<TextEditingController> serviceControllers = [];

  @override
  void initState() {
    // selectedOrganizationName;
    getBillingList(context, widget.patientindooridp);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Billing"),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(
            color: Colorsblack, size: SizeConfig.blockSizeVertical ! * 2.2),
        toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(
                color: Colorsblack,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical ! * 2.5)).bodyMedium,
        titleTextStyle: TextTheme(
            titleMedium: TextStyle(
                color: Colorsblack,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical ! * 2.5)).titleLarge,
      ),
      body: Builder(builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                      "Patient Name:"
                  ),
                  Text(
                      "${widget.firstname} ${widget.lastName}"
                  ),
                ],
              ),
              Divider(),
              Container(
                  child: Row(
                    children: [
                      Text("Services:"),
                      // Expanded(
                      //     child:
                          // ListView.builder(
                          //       shrinkWrap: true,
                          //     itemCount: serviceControllers.length,
                          //       itemBuilder: (context,i){
                          //       return
                          Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Container(
                              width: SizeConfig.blockSizeVertical ! * 30,
                              child: CustomAutocompleteSearch(
                                  suggestions: listBillingServices,
                                  hint: "Add Services",
                                  controller: serviceNameController1,
                                  hideSuggestionsOnCreate: true,
                                  onSelected: (text) =>
                                      selectedFieldBillingServices(
                                          context, serviceNameController1, text),
                                  onTap: (String selected) {
                                    if (selected.isEmpty) {
                                      // Handle the case when no suggestion is selected
                                      print('No suggestion selected');
                                    } else {
                                      // Update the last selected suggestion
                                      lastSelected = selected;
                                      // Perform action when a suggestion is selected
                                      print('Selected: $selected');
                                    }
                                    if (onTapStatus != "Tapped") {
                                      _scrollController.animateTo(
                                          _scrollController
                                              .position.maxScrollExtent,
                                          duration:
                                          Duration(milliseconds: 500),
                                          curve: Curves.easeOut);
                                      onTapStatus = "Tapped";
                                    }
                                  }
                              ),
                            ),
                          ),
                      InkWell(
                        onTap: (){
                          TextEditingController newController = TextEditingController();
                          serviceControllers.add(newController);
                        },
                        child: Container(
                            color: Colors.black,
                            child: Icon(Icons.add)),
                      )
                        // }),
                      // ),
                    ],
                  )
              ),
            ],
          ),
        );
      },
      ),
    );
  }

// if (i == 0)
//     InkWell(
//       onTap: (){
//         TextEditingController newController = TextEditingController();
//         serviceControllers.add(newController);
//       },
//       child: Container(
//         color: Colors.black,
//           child: Icon(Icons.add)),
//     )
  // else
  //   InkWell(
  //     onTap: () {
  //       serviceControllers.removeAt(i);
  //       setState(() {});
  //     },
  //     child: Container(child: Icon(Icons.delete)),
  //   ),

  selectedFieldBillingServices(BuildContext context,
      TextEditingController anyController, text) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (listBillingServices.isNotEmpty) {
      int index = listBillingServices.indexOf(text);
      if (index != -1) {
        debugPrint(listBillingServices[index]);
        // Handle the logic related to the selected complaint

        // Assuming that getComplaintList is a function to fetch the details
        getBillingList(context, widget.patientindooridp);

        anyController.text = text;
        initialState = false;
      } else {
        debugPrint("Text not found in listDiagnosisDetails");
      }
    } else {
      debugPrint("List is empty");
    }
  }

  void getBillingList(BuildContext context,
      String patientindooridp) async {
    print('getBillingList');

    try {
      String loginUrl = "${baseURL}doctor_service_list.php";
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
          "," +
          "\"" +
          "PatientIndoorIDF" +
          "\"" +
          ":" +
          "\"" +
          patientindooridp +
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

        for (var i = 0; i < jsonData.length; i++) {
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
            "Price": price,
          };
          listBillingServices1.add(OrganizationMap);
          // debugPrint("Added to list: $complainName");

        }
        setState(() {});
      }
    } catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  void getAddedBillingSubmit(BuildContext context,
      String patientindooridp,
      String PatientIDF) async {
    print('getBillingList');


    try {
      String loginUrl = "${baseURL}doctor_add_billing_submit.php";
      ProgressDialog pr = ProgressDialog(context);
      Future.delayed(Duration.zero, () {
        pr.show();
      });

      List<String> serviceValues = serviceControllers.map((
          controller) => controller.text).toList();

      var jsonArrayServices = "[";
      for (var i = 0; i < serviceValues.length; i++) {
        jsonArrayServices += "\"${serviceValues[i]}\"";

        // Add a comma if it's not the last element
        if (i < serviceValues.length - 1) {
          jsonArrayServices += ",";
        }
      }
      jsonArrayServices += "]";


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
          "$jsonArrayServices" +
          "\"" +
          "}";

      // {"DoctorIDP":"1","PatientIndoorIDF":"1755","PatientIDF":"7","ipdservice":"1","servicecharge":"300"}

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

        for (var i = 0; i < jsonData.length; i++) {
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
            "Price": price,
          };
          listBillingServices1.add(OrganizationMap);
          // debugPrint("Added to list: $complainName");

        }
        setState(() {});
      }
    } catch (e) {
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
