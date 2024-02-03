import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/color.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

class InputChartScreen extends StatefulWidget {

  String selectedOrganizationName = '';
  String imgUrl = "";
  // const SwitchOrganizationView({super.key});


  @override
  State<InputChartScreen> createState() => _InputChartScreenState();
}

class _InputChartScreenState extends State<InputChartScreen> {

  TextEditingController tempController = TextEditingController();
  TextEditingController PulseController = TextEditingController();
  TextEditingController RespController = TextEditingController();
  TextEditingController BpSystolicController = TextEditingController();
  TextEditingController BpDiastolicController = TextEditingController();
  TextEditingController SPO2Controller = TextEditingController();

  List<Map<String, dynamic>> listOrganizations = <Map<String, dynamic>>[];

  @override
  void initState() {
    // selectedOrganizationName;
    getOrganizations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Input Chart"),
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
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1.0, color: Colors.black),
                top: BorderSide(width: 1.0, color: Colors.black),
              ),
            ),
            child: DataTable(
              dataTextStyle: TextStyle(
                color: Colors.black,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical! * 2.5,
              ),
              columnSpacing: 25.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black), // Add your desired color and other properties
              ),
              columns: [
                DataColumn(
                    label:
                    Text('Time',

                  )),
                DataColumn(
                    label:
                Column(
                  children: [
                    Text("Input"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ORAL"),
                        Text("RT"),
                        Text("IV1"),
                        Text("IV2"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("SUB"),
                        Text("QUANTITY"),
                        Text("SUB"),
                        Text("QUANTITY"),
                        Text("DRUG"),
                        Text("QUANTITY"),
                        Text("DRUG"),
                        Text("QUANTITY"),
                      ],
                    ),
                  ],
                ))
                // DataColumn(label: Text('Pulse',
                //   style: TextStyle(
                //     color: Colors.black,
                //     fontFamily: "Ubuntu",
                //     fontSize: SizeConfig.blockSizeVertical! * 2.5,
                //   ),)),
                // DataColumn(label: Text('Resp',
                //   style: TextStyle(
                //     color: Colors.black,
                //     fontFamily: "Ubuntu",
                //     fontSize: SizeConfig.blockSizeVertical! * 2.5,
                //   ),)),
                // DataColumn(label: Text('BP Systolic',
                //   style: TextStyle(
                //     color: Colors.black,
                //     fontFamily: "Ubuntu",
                //     fontSize: SizeConfig.blockSizeVertical! * 2.5,
                //   ),)),
                // DataColumn(label: Text('BP Diastolic',
                //   style: TextStyle(
                //     color: Colors.black,
                //     fontFamily: "Ubuntu",
                //     fontSize: SizeConfig.blockSizeVertical! * 2.5,
                //   ),)),
                // DataColumn(label: Text('SPO2',
                //   style: TextStyle(
                //     color: Colors.black,
                //     fontFamily: "Ubuntu",
                //     fontSize: SizeConfig.blockSizeVertical! * 2.5,
                //   ),)),
              ],
              rows: listOrganizations.map((item) {
                return DataRow(
                  cells: [
                    DataCell(
                        TextField(
                          controller: tempController,
                        )

                      // // Example DropdownButton in the first DataCell
                      // DropdownButton<String>(
                      //   value: item. ?? '',
                      //   onChanged: (newValue) {
                      //     // Handle dropdown value change
                      //     // You might want to update the corresponding property in your data model
                      //   },
                      //   items: ['Option 1', 'Option 2', 'Option 3']
                      //       .map<DropdownMenuItem<String>>(
                      //         (String value) => DropdownMenuItem<String>(
                      //       value: value,
                      //       child: Text(value),
                      //     ),
                      //   )
                      //       .toList(),
                      // ),
                    ),
                    DataCell(
                        TextField(
                          controller: tempController,
                        )),
                    // DataCell(
                    //     TextField(
                    //       controller: PulseController,
                    //     )),
                    // DataCell(
                    //     TextField(
                    //       controller: RespController,
                    //     )),
                    // DataCell(
                    //     TextField(
                    //       controller: BpSystolicController,
                    //     )),
                    // DataCell(
                    //     TextField(
                    //       controller: BpDiastolicController,
                    //     )),
                    // DataCell(
                    //     TextField(
                    //       controller: SPO2Controller,
                    //     )),
                    // DataCell(Text(item.createdBy ?? '')),
                    // Add more DataCell widgets based on your requirements
                  ],
                );
              }).toList(),
            ),
          ),
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

}
