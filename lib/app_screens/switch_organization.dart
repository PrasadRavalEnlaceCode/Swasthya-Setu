import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swasthyasetu/api/api_helper.dart';
import 'package:swasthyasetu/app_screens/doctor_dashboard_screen.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';

import '../global/SizeConfig.dart';
import '../utils/color.dart';
import '../utils/progress_dialog.dart';


class SwitchOrganizationScreen extends StatefulWidget {

  String selectedOrganizationName = '';
  String imgUrl = "";
  // const SwitchOrganizationView({super.key});


  @override
  State<SwitchOrganizationScreen> createState() => _SwitchOrganizationScreenState();
}

class _SwitchOrganizationScreenState extends State<SwitchOrganizationScreen> {

  late String selectedOrganizationIDF;
  late String selectedOrganizationName;
  // DashboardDoctorScreen DashboardDoctorScreen = DashboardDoctorScreen();
  List<Map<String, dynamic>> listOrganizations = <Map<String, dynamic>>[];
  String baseImageUrl = baseURL + "images/businesslogo/";
  late SharedPreferences prefs;

  @override
  void initState() {
    initializeSharedPreferences();
    // selectedOrganizationName;
    getOrganizations();
    super.initState();
  }

  // Function to initialize SharedPreferences
  void initializeSharedPreferences() async {
    print("Initializing SharedPreferences");
    prefs = await SharedPreferences.getInstance();
    loadSelectedOrganization(); // Load the saved value
  }

  // Function to load selected organization from shared preferences
  void loadSelectedOrganization() {
    print("Loading selected organization");
    setState(() {
      selectedOrganizationIDF = prefs.getString('selectedOrganizationIDF') ?? "1";
      selectedOrganizationName = prefs.getString('selectedOrganizationName') ?? "Swasthaya Setu";
    });
    // When the app starts, update the selected organization in DashboardDoctorScreen
    // Update headers and save selected organization
    updateAndSaveSelectedOrganization(selectedOrganizationIDF);
  }

  // Function to save selected organization to shared preferences
  void saveSelectedOrganization() {
    print("Saving selected organization");
    prefs.setString('selectedOrganizationIDF', selectedOrganizationIDF);
    prefs.setString('selectedOrganizationName', selectedOrganizationName);
  }

  // Function to update headers and save selected organization ID
  void updateAndSaveSelectedOrganization(String organizationIDF,) {
    print("Updating and saving selected organization");
    // Update the default headers
    ApiHelper.updateDefaultHeaders(organizationIDF);
    // updatepatientIDP(organizationIDF);

    // // Call the function to update patientIDP in DashboardDoctorScreen
    // widget.updatePatientIDP(organizationIDF);

    // Save the selected organization to shared preferences
    saveSelectedOrganization();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Switch Organization"),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(
            color: Colorsblack, size: SizeConfig.blockSizeVertical !* 2.2), toolbarTextStyle: TextTheme(
          titleMedium: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5)).bodyMedium, titleTextStyle: TextTheme(
          titleMedium: TextStyle(
              color: Colorsblack,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.5)).titleLarge,
      ),
      body: Builder(builder: (context) {

        return ListView.builder(
            itemCount: listOrganizations.length,
            itemBuilder: (context , index){
              return Padding(
                padding: const EdgeInsets.all(13.0),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(selectedOrganizationName),
                      // Divider(
                      //   thickness: 3,
                      // ),
                      Stack(
                        children : [
                          Container(
                            height: 170,
                            width: 270,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: selectedOrganizationIDF == listOrganizations[index]["OrganizationIDF"]
                                    ? Colors.green
                                    : Colors.transparent,
                                width: 5.0, // Adjust the width of the border as needed
                              ),
                            ),
                            child: CachedNetworkImage(
                            imageUrl: baseImageUrl + listOrganizations[index]["OrganizationLogoImage"],
                            fit: BoxFit.cover,
                                                    ),
                          ),
                          if (selectedOrganizationIDF == listOrganizations[index]["OrganizationIDF"])
                            Positioned(
                              bottom: 3.0,
                              right: 3.0,
                              child: Container(
                                width: 120.0,
                                height: 30.0,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                ),
                                child: Center(child: Text("Active")),
                              ),
                            ),
                        ]
                      ),
                      SizedBox(
                        height:20,
                      ),
                      Text(listOrganizations[index]['Unit'] ?? ""),
                      SizedBox(
                        height:10,
                      ),
                      InkWell(
                        onTap: () {

                          setState(() {
                            selectedOrganizationIDF = listOrganizations[index]["OrganizationIDF"];
                            selectedOrganizationName = listOrganizations[index]["OrganizationName"];
                          });

                          // Update headers and save selected organization
                          updateAndSaveSelectedOrganization(selectedOrganizationIDF);

                          // Save the new value to shared preferences
                          saveSelectedOrganization();

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Switch Organization"),
                                content: Text("Do you want to switch to ${listOrganizations[index]["OrganizationName"]}?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: Text("No"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Navigator.of(context).pop();
                                      getOrganizationChangeSubmit(listOrganizations[index]["OrganizationIDF"]);

                                    },
                                    child: Text("Yes"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: SizedBox(
                          child: Container(
                            width: 100.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0), color: Colors.blue),
                            child: Center(
                              child: Text(
                                "Click to Change",
                                style: TextStyle(
                                    fontFamily: "Ubuntu",
                                    color: Colors.black,
                                    fontSize: SizeConfig.blockSizeVertical! * 1.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height:10,
                      ),
                      Divider(
                        thickness: 3,
                      ),
                    ],
                  ),
                ),
              );
            },
        );
      },
      ),
    );
  }

  void getOrganizations() async {
    print('getdoctorswitchorganization');

    try{
    String loginUrl = "${baseURL}doctorswitchorganization_list.php";
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
    String jsonStr = "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

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
        String organizationLogoImage = jo['OrganizationLogoImage'].toString();
        String organizationIDF = jo['OrganizationIDF'].toString();
        String organizationName = jo['OrganizationName'].toString();
        String unit = jo['Unit'].toString();

        Map<String, dynamic> OrganizationMap = {
          "OrganizationLogoImage": organizationLogoImage,
          "OrganizationIDF": organizationIDF,
          "OrganizationName" : organizationName,
          "Unit" : unit,
        };
        listOrganizations.add(OrganizationMap);
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

  void getOrganizationChangeSubmit(String OrganizationIDF) async {
    print('getdoctorswitchorganization');

    try{
      String loginUrl = "${baseURL}switchorganization_submit.php";
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
          "OrganizationIDF" +
          "\"" +
          ":" +
          "\"" +
          OrganizationIDF +
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

        // var data = jsonResponse['Data'];
        // var strData = decodeBase64(data);
        // debugPrint("Decoded Data List : " + strData);

        final snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text("Organization Switched Successfully"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {});
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DoctorDashboardScreen(
              selectedOrganizationIDF: selectedOrganizationIDF,
                selectedOrganizationName: selectedOrganizationName)));
      }
      else {final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("There are Some Issue in Organization Switch PLease try Again"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {});}
    }catch (e) {
      print('Error decoding JSON: $e');
    }
  }

}
