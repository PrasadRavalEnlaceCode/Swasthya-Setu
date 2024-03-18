import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:silvertouch/app_screens/ipd/indoor_list_icon_screen.dart';
import 'package:silvertouch/app_screens/ipd/pmr_table_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_pmr_send.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/progress_dialog.dart';

import '../../podo/model_pmr.dart';

List<String> listPMR = [];
// List<PMRData> listPMRSend = [];
List<int> listPMRNumber = [];
List<String> listPMRSchedule = [];
// List<int> listPMRSchedule1 = [];




ScrollController _scrollController = new ScrollController();

TextEditingController SelectPMRController = TextEditingController();
TextEditingController SelectPMRController1 = TextEditingController();
TextEditingController SelectPMRController2 = TextEditingController();
TextEditingController SelectPMRController3 = TextEditingController();
TextEditingController SelectPMRController4 = TextEditingController();
TextEditingController pmrIDPController = TextEditingController();
TextEditingController pmrIDPController1 = TextEditingController();
TextEditingController pmrIDPController2 = TextEditingController();
TextEditingController pmrIDPController3 = TextEditingController();
TextEditingController pmrIDPController4 = TextEditingController();
TextEditingController QtyController = TextEditingController();
TextEditingController QtyController1 = TextEditingController();
TextEditingController QtyController2 = TextEditingController();
TextEditingController QtyController3 = TextEditingController();
TextEditingController QtyController4 = TextEditingController();
TextEditingController RemarksController = TextEditingController();
TextEditingController RemarksController1 = TextEditingController();
TextEditingController RemarksController2 = TextEditingController();
TextEditingController RemarksController3 = TextEditingController();
TextEditingController RemarksController4 = TextEditingController();


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


  List<Map<String, dynamic>> listPmrSend = <Map<String, dynamic>>[];
  // FocusNode _focusNode = FocusNode();
  // List<TextEditingController> controllers = [];

  @override
  void initState() {
    // selectedOrganizationName;
    getPMRList(context);
    SelectPMRController = TextEditingController();
    SelectPMRController1 = TextEditingController();
    SelectPMRController2 = TextEditingController();
    SelectPMRController3 = TextEditingController();
    SelectPMRController4 = TextEditingController();
    QtyController = TextEditingController();
    QtyController1 = TextEditingController();
    QtyController2 = TextEditingController();
    QtyController3 = TextEditingController();
    QtyController4 = TextEditingController();
    RemarksController = TextEditingController();
    RemarksController1 = TextEditingController();
    RemarksController2 = TextEditingController();
    RemarksController3 = TextEditingController();
    RemarksController4 = TextEditingController();
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

        // Clear the existing listPMR
        listPMR.clear();

        listPMRNumber.clear();

        listPMRSchedule.clear();

        // Populate the listPMR with the fetched medicineName values
        for (var medicineJson in jsonData) {

          String medicineName = medicineJson['MedicineName'];
          listPMR.add(medicineName);

          int medicineIDP = medicineJson['HospitalMedicineIDP'];
          listPMRNumber.add(medicineIDP);

          String schedule = medicineJson['DoseSchedule'].toString();
          listPMRSchedule.add(schedule);

        }

        print("ListPMR: " + "${listPMR}");
        print("ListPMRNumber: " + "${listPMRNumber}");
        print("listPMRSchedule: " + "${listPMRSchedule}");

        // Now you have the doctorMedicineList containing the fetched data.
        // You can use it as needed. For example, you can store it in a state variable.

        setState(() {});
      }
    }catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorGrayApp,
      appBar: AppBar(
        elevation: 0,
        title: Text("PMR"),
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
        builder: (BuildContext context) {
          // // Define controllers for each text field
          // List<TextEditingController> controllers = List.generate(15, (_) => TextEditingController());

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          "Patient Name:",
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Text(
                        "${widget.firstname} ${widget.lastName}",
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: SelectPMRController,
                            decoration: InputDecoration(
                              labelText: "Select Particular Name",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          suggestionsCallback: (pattern) async {
                            // Implement your logic to fetch suggestions based on the input pattern
                            // For example, you can filter the listPMR based on the input pattern
                            return listPMR.where((medicine) => medicine.toLowerCase().contains(pattern.toLowerCase()));
                          },
                          itemBuilder: (context, suggestion) {
                            // Customize how suggestions are displayed
                            return ListTile(
                              title: Text(suggestion as String),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            // Implement what to do when a suggestion is selected
                            SelectPMRController.text = suggestion as String;  // Set the selected suggestion to the text field

                            // Find the index of the selected suggestion in the listPMR
                            int selectedIndex = listPMR.indexOf(suggestion);

                            // Check if the index is valid and update the pmrIDPController
                            if (selectedIndex != -1 && selectedIndex < listPMRNumber.length) {
                              pmrIDPController.text = listPMRNumber[selectedIndex].toString();
                            }

                          },
                          noItemsFoundBuilder: (context) => Container(),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: TextField(
                                controller: QtyController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Requested Qty.",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: TextField(
                                controller: RemarksController,
                                decoration: InputDecoration(
                                  labelText: "Remarks",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: SelectPMRController1,
                            decoration: InputDecoration(
                              labelText: "Select Particular Name",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          suggestionsCallback: (pattern) async {
                            // Implement your logic to fetch suggestions based on the input pattern
                            // For example, you can filter the listPMR based on the input pattern
                            return listPMR.where((medicine) => medicine.toLowerCase().contains(pattern.toLowerCase()));
                          },
                          itemBuilder: (context, suggestion) {
                            // Customize how suggestions are displayed
                            return ListTile(
                              title: Text(suggestion as String),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            // Implement what to do when a suggestion is selected
                            SelectPMRController1.text = suggestion as String;  // Set the selected suggestion to the text field

                            // Find the index of the selected suggestion in the listPMR
                            int selectedIndex = listPMR.indexOf(suggestion);

                            // Check if the index is valid and update the pmrIDPController
                            if (selectedIndex != -1 && selectedIndex < listPMRNumber.length) {
                              pmrIDPController1.text = listPMRNumber[selectedIndex].toString();
                            }

                          },
                          noItemsFoundBuilder: (context) => Container(),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: TextField(
                                controller: QtyController1,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Requested Qty.",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: TextField(
                                controller: RemarksController1,
                                decoration: InputDecoration(
                                  labelText: "Remarks",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: SelectPMRController2,
                            decoration: InputDecoration(
                              labelText: "Select Particular Name",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          suggestionsCallback: (pattern) async {
                            // Implement your logic to fetch suggestions based on the input pattern
                            // For example, you can filter the listPMR based on the input pattern
                            return listPMR.where((medicine) => medicine.toLowerCase().contains(pattern.toLowerCase()));
                          },
                          itemBuilder: (context, suggestion) {
                            // Customize how suggestions are displayed
                            return ListTile(
                              title: Text(suggestion as String),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            // Implement what to do when a suggestion is selected
                            SelectPMRController2.text = suggestion as String;  // Set the selected suggestion to the text field

                            // Find the index of the selected suggestion in the listPMR
                            int selectedIndex = listPMR.indexOf(suggestion);

                            // Check if the index is valid and update the pmrIDPController
                            if (selectedIndex != -1 && selectedIndex < listPMRNumber.length) {
                              pmrIDPController2.text = listPMRNumber[selectedIndex].toString();
                            }
                          },
                          noItemsFoundBuilder: (context) => Container(),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: TextField(
                                controller: QtyController2,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Requested Qty.",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: TextField(
                                controller: RemarksController2,
                                decoration: InputDecoration(
                                  labelText: "Remarks",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: SelectPMRController3,
                            decoration: InputDecoration(
                              labelText: "Select Particular Name",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          suggestionsCallback: (pattern) async {
                            // Implement your logic to fetch suggestions based on the input pattern
                            // For example, you can filter the listPMR based on the input pattern
                            return listPMR.where((medicine) => medicine.toLowerCase().contains(pattern.toLowerCase()));
                          },
                          itemBuilder: (context, suggestion) {
                            // Customize how suggestions are displayed
                            return ListTile(
                              title: Text(suggestion as String),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            // Implement what to do when a suggestion is selected
                            SelectPMRController3.text = suggestion as String;  // Set the selected suggestion to the text field

                            // Find the index of the selected suggestion in the listPMR
                            int selectedIndex = listPMR.indexOf(suggestion);

                            // Check if the index is valid and update the pmrIDPController
                            if (selectedIndex != -1 && selectedIndex < listPMRNumber.length) {
                              pmrIDPController3.text = listPMRNumber[selectedIndex].toString();
                            }

                          },
                          noItemsFoundBuilder: (context) => Container(),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: TextField(
                                controller: QtyController3,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Requested Qty.",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: TextField(
                                controller: RemarksController3,
                                decoration: InputDecoration(
                                  labelText: "Remarks",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: SelectPMRController4,
                            decoration: InputDecoration(
                              labelText: "Select Particular Name",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          suggestionsCallback: (pattern) async {
                            // Implement your logic to fetch suggestions based on the input pattern
                            // For example, you can filter the listPMR based on the input pattern
                            return listPMR.where((medicine) => medicine.toLowerCase().contains(pattern.toLowerCase()));
                          },
                          itemBuilder: (context, suggestion) {
                            // Customize how suggestions are displayed
                            return ListTile(
                              title: Text(suggestion as String),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            // Implement what to do when a suggestion is selected
                            SelectPMRController4.text = suggestion as String;  // Set the selected suggestion to the text field

                            // Find the index of the selected suggestion in the listPMR
                            int selectedIndex = listPMR.indexOf(suggestion);

                            // Check if the index is valid and update the pmrIDPController
                            if (selectedIndex != -1 && selectedIndex < listPMRNumber.length) {
                              pmrIDPController4.text = listPMRNumber[selectedIndex].toString();
                            }
                          },
                          noItemsFoundBuilder: (context) => Container(),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: TextField(
                                controller: QtyController4,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Requested Qty.",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: TextField(
                                controller: RemarksController4,
                                decoration: InputDecoration(
                                  labelText: "Remarks",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Wrap(
                //   children: List.generate(5, (index) {
                //     // Generate controllers for auto field (index 0 to 4)
                //     return Padding(
                //       padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 2),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Padding(
                //             padding: EdgeInsets.only(bottom: 10),
                //             child: TypeAheadFormField(
                //               textFieldConfiguration: TextFieldConfiguration(
                //                 controller: controllers[index],
                //                 decoration: InputDecoration(
                //                   labelText: "Select Particular Name",
                //                   border: OutlineInputBorder(),
                //                 ),
                //               ),
                //               suggestionsCallback: (pattern) async {
                //                 // Implement your logic to fetch suggestions based on the input pattern
                //                 // For example, you can filter the listPMR based on the input pattern
                //                 return listPMR.where((medicine) => medicine.toLowerCase().contains(pattern.toLowerCase()));
                //               },
                //               itemBuilder: (context, suggestion) {
                //                 // Customize how suggestions are displayed
                //                 return ListTile(
                //                   title: Text(suggestion as String),
                //                 );
                //               },
                //               onSuggestionSelected: (suggestion) {
                //                 // Implement what to do when a suggestion is selected
                //                 controllers[index].text = suggestion as String;  // Set the selected suggestion to the text field
                //               },
                //               noItemsFoundBuilder: (context) => Container(),
                //             ),
                //           ),
                //           Row(
                //             children: [
                //               Expanded(
                //                 child: Padding(
                //                   padding: EdgeInsets.only(right: 10),
                //                   child: TextField(
                //                     controller: controllers[index + 5], // Adjust the index calculation
                //                     decoration: InputDecoration(
                //                       labelText: "Requested Qty.",
                //                       border: OutlineInputBorder(),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //               Expanded(
                //                 child: Padding(
                //                   padding: EdgeInsets.only(left: 10),
                //                   child: TextField(
                //                     controller: controllers[index + 10], // Adjust the index calculation
                //                     decoration: InputDecoration(
                //                       labelText: "Remarks",
                //                       border: OutlineInputBorder(),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //       ),
                //     );
                //   }),
                // ),

                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal !* 3),
                  child: Center(
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

                          if (SelectPMRController.text == "" && QtyController.text == "") {
                            final snackBar = SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                  "Please enter at least one auto field and one normal field in the same box"),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            Future.delayed(Duration(seconds: 2), () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            });
                            return;
                          } else {
                            // Populate listPMRSend
                            // List<MedicineFormData> listPMRSend = [];

                            // listPMRSend.clear();
                            //
                            // List<String> pmrControllers = [
                            //   SelectPMRController.text,
                            //   SelectPMRController1.text,
                            //   SelectPMRController2.text,
                            //   SelectPMRController3.text,
                            //   SelectPMRController4.text,
                            // ];
                            //
                            // List<String> qtyControllers = [
                            //   QtyController.text,
                            //   QtyController1.text,
                            //   QtyController2.text,
                            //   QtyController3.text,
                            //   QtyController4.text,
                            // ];
                            //
                            // List<String> remarksControllers = [
                            //   RemarksController.text,
                            //   RemarksController1.text,
                            //   RemarksController2.text,
                            //   RemarksController3.text,
                            //   RemarksController4.text,
                            // ];
                            //
                            // // Remove empty or null values from the data list
                            // List<String> filteredData = pmrControllers.where((element) => element != null && element.isNotEmpty).toList();
                            //
                            // // Remove empty or null values from the data list
                            // List<String> filteredData1 = qtyControllers.where((element) => element != null && element.isNotEmpty).toList();
                            //
                            // // Remove empty or null values from the data list
                            // List<String> filteredData2 = remarksControllers.where((element) => element != null && element.isNotEmpty).toList();
                            //
                            // print("----------------${filteredData}");
                            // print("----------------${filteredData1}");
                            // print("----------------${filteredData2}");
                            //
                            // // Loop through the controllers to extract data and populate listPMRSend
                            // for (int i = 0; i < pmrControllers.length; i++) {
                            //   String particularName = pmrControllers[i];
                            //   String requestedQty = qtyControllers[i];
                            //   String remarks = remarksControllers[i];
                            //
                            //   // Skip if any field is empty
                            //   if (particularName.isEmpty || requestedQty.isEmpty || remarks.isEmpty) {
                            //     continue;
                            //   }
                            //
                            //   // Create a new instance of MedicineFormData and add it to listPMRSend
                            //   PMRData formData = PMRData(
                            //     pmr: particularName,
                            //     quantity: requestedQty,
                            //     remarks: remarks,
                            //   );
                            //
                            //   listPMRSend.add(formData);
                            // }
                            //
                            // print("-----------------------${listPMRSend}");

                            // String data1 = SelectPMRController.text;
                            // String data2 = SelectPMRController1.text;
                            // String data3 = SelectPMRController2.text;
                            // String data4 = SelectPMRController1.text;
                            // String data5 = SelectPMRController.text;
                            // String data6 = SelectPMRController1.text;
                            // String data7 = SelectPMRController.text;
                            // String data8 = SelectPMRController1.text;
                            // String data9 = SelectPMRController.text;
                            // String data10 = SelectPMRController1.text;
                            // String data11 = SelectPMRController.text;
                            // String data12 = SelectPMRController1.text;
                            // String data13 = SelectPMRController.text;
                            // String data14 = SelectPMRController1.text;
                            // String data15 = SelectPMRController.text;
                            // // Collect data from more controllers as needed...
                            //
                            // // Construct the data to send to the API
                            // Map<String, dynamic> requestData = {
                            //   "field1": data1,
                            //   "field2": data2,
                            //   // Add more fields as needed...
                            // };

                            final snackBar = SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                  "Entered Services Added"),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            Future.delayed(Duration(seconds: 2), () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            });
                            sendPMRData(
                              context,
                              widget.patientindooridp,
                              widget.PatientIDP,
                              // listPMRSend,
                            );
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PMRTableScreen(
                                          patientindooridp:  widget.patientindooridp,
                                          PatientIDP:  widget.PatientIDP,
                                          doctoridp:  widget.doctoridp,
                                          firstname:  widget.firstname,
                                          lastName:  widget.lastName,
                                        )
                                )
                            );
                          }
                        }
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  void sendPMRData(
      BuildContext context,
      String patientindooridp,
      String PatientIDF,
      // List<PMRData> listPMRSend,
      ) async {
    print('sendPMRData');

    try {
      // Define the base URL for the API
      String loginUrl = "${baseURL}doctor_add_pmr_submit.php";

      // Show a progress dialog while the data is being sent
      ProgressDialog pr = ProgressDialog(context);
      Future.delayed(Duration.zero, () {
        pr.show();
      });

      // listPMRSend.clear();
      //
      // List<String> pmrControllers = [
      //   SelectPMRController.text,
      //   SelectPMRController1.text,
      //   SelectPMRController2.text,
      //   SelectPMRController3.text,
      //   SelectPMRController4.text,
      // ];
      //
      // List<String> qtyControllers = [
      //   QtyController.text,
      //   QtyController1.text,
      //   QtyController2.text,
      //   QtyController3.text,
      //   QtyController4.text,
      // ];
      //
      // List<String> remarksControllers = [
      //   RemarksController.text,
      //   RemarksController1.text,
      //   RemarksController2.text,
      //   RemarksController3.text,
      //   RemarksController4.text,
      // ];
      //
      //
      // // // Create an array to store the data for each set of fields
      // // List<Map<String, String>> formDataArray = [];
      // //
      // // // Loop through the controllers to extract data
      // // for (int i = 0; i < controllers.length; i += 3) {
      // //   String particularName = controllers[i].text;
      // //   String requestedQty = controllers[i + 1].text;
      // //   String remarks = controllers[i + 2].text;
      // //
      // //   // Skip if any field is empty
      // //   if (particularName.isEmpty || requestedQty.isEmpty || remarks.isEmpty) {
      // //     continue;
      // //   }
      // //
      // //   // Construct a map for the current set of fields
      // //   Map<String, String> formData = {
      // //     "pmr": particularName,
      // //     "quantity": requestedQty,
      // //     "remarks": remarks,
      // //   };
      // //
      // //   // Add the map to the array
      // //   formDataArray.add(formData);
      // // }
      // //
      // // print("jArrayPMRData: $jArrayPMRData");
      //
      //
      // // List<String> serviceValues = serviceControllers.map((controller) => controller.text).toList();
      //
      // // var jsonArrayServices = "[";
      // // for (var i = 0; i < serviceValues.length; i++) {
      // //   jsonArrayServices += "\"${serviceValues[i]}\"";
      // //
      // //   // Add a comma if it's not the last element
      // //   if (i < serviceValues.length - 1) {
      // //     jsonArrayServices += ",";
      // //   }
      // // }
      // // jsonArrayServices += "]";
      //
      // // Collect PMR data from text editing controllers
      // List<String> pmrList = [];
      // for (int i = 0; i < 5; i++) {
      //   pmrList.add(pmrControllers[i]);
      // }
      //
      // // Collect quantity data from text editing controllers
      // List<String> quantityList = [];
      // for (int i = 0; i < 5; i++) {
      //   quantityList.add(qtyControllers[i]);
      // }
      //
      // // Collect remarks data from text editing controllers
      // List<String> remarksList = [];
      // for (int i = 0; i < 5; i++) {
      //   remarksList.add(remarksControllers[i]);
      // }
      //
      // // Construct PMRData array
      // List<Map<String, String>> pmrDataArray = [];
      // for (int i = 0; i < 5; i++) {
      //   Map<String, String> pmrData = {
      //     "pmr": pmrList[i],
      //     "quantity": quantityList[i],
      //     "remarks": remarksList[i],
      //   };
      //   pmrDataArray.add(pmrData);
      // }

      var jArrayPMRData = "[";

      jArrayPMRData +=
      "{\"pmr\":\"${pmrIDPController.text}\","
      // "\"pmrID\":\"${formData.pmr}\","
          "\"quantity\":\"${QtyController.text}\","
          "\"remarks\":\"${RemarksController.text}\"},"
          "{\"pmr\":\"${pmrIDPController1.text}\","
      // "\"pmrID\":\"${formData.pmr}\","
          "\"quantity\":\"${QtyController1.text}\","
          "\"remarks\":\"${RemarksController1.text}\"},"
          "{\"pmr\":\"${pmrIDPController2.text}\","
      // "\"pmrID\":\"${formData.pmr}\","
          "\"quantity\":\"${QtyController2.text}\","
          "\"remarks\":\"${RemarksController2.text}\"},"
          "{\"pmr\":\"${pmrIDPController3.text}\","
      // "\"pmrID\":\"${formData.pmr}\","
          "\"quantity\":\"${QtyController3.text}\","
          "\"remarks\":\"${RemarksController3.text}\"},"
          "{\"pmr\":\"${pmrIDPController4.text}\","
      // "\"pmrID\":\"${formData.pmr}\","
          "\"quantity\":\"${QtyController4.text}\","
          "\"remarks\":\"${RemarksController4.text}\"}";


      // Remove the trailing comma if it exists
      // if (listPMRSend.isNotEmpty) {
      //   jArrayPMRData = jArrayPMRData.substring(0, jArrayPMRData.length - 1);
      // }

      jArrayPMRData += "]";

      print(jArrayPMRData);

      print("-------------------------------");

      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      String patientIDP = await getPatientOrDoctorIDP();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      String jsonStr = "{" +
          "\"" +
          "PatientIDF" +
          "\"" +
          ":" +
          "\"" +
          PatientIDF +
          "\"" +
          "," +
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
          "PMRData" +
          "\"" +
          ":" +
          jArrayPMRData +
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

      // if (model.status == "OK") {
      //   var data = jsonResponse['Data'];
      //   var strData = decodeBase64(data);
      //
      //   debugPrint("Decoded Data List : " + strData);
      //   final jsonData = json.decode(strData);
      //
      //   for (var i = 0; i < jsonData.length; i++)
      //   {
      //     final jo = jsonData[i];
      //     String OPDService = jo['OPDService'].toString();
      //     listBillingServices.add(OPDService);
      //     // debugPrint("Added to list: $diagnosisName");
      //   }
      //
      //
      //   setState(() {});
      // }
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


// Wrap(
//   children: List.generate(15, (index) {
//     // Check if the current index is a multiple of 4 (including 0)
//     if (index % 4 == 0) {
//       // If it's a multiple of 4, create an AutoCompleteTextField
//       final autoTextFieldIndex = index ~/ 4; // Calculate the index for the auto text fields
//       return Padding(
//         padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 2),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(bottom: 10),
//               child: TypeAheadFormField(
//
//                 textFieldConfiguration: TextFieldConfiguration(
//                   controller: controllers[autoTextFieldIndex],
//                   decoration: InputDecoration(
//                     labelText: "Select Particular Name",
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 suggestionsCallback: (pattern) async {
//                   // Implement your logic to fetch suggestions based on the input pattern
//                   // For example, you can filter the listPMR based on the input pattern
//                   return listPMR.where((medicine) => medicine.toLowerCase().contains(pattern.toLowerCase()));
//                 },
//                 itemBuilder: (context, suggestion) {
//                   // Customize how suggestions are displayed
//                   return ListTile(
//                     title: Text(suggestion as String),
//                   );
//                 },
//                 onSuggestionSelected: (suggestion) {
//                   // Implement what to do when a suggestion is selected
//                   controllers[autoTextFieldIndex].text = suggestion as String;  // Set the selected suggestion to the text field
//                 },
//                 noItemsFoundBuilder: (context) => Container(),
//               ),
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(right: 10),
//                     child: TextField(
//                       controller: controllers[autoTextFieldIndex * 4 + 1],
//                       decoration: InputDecoration(
//                         labelText: "Requested Oty.", // Set the label text for the first text field
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(left: 10),
//                     child: TextField(
//                       controller: controllers[autoTextFieldIndex * 4 + 2],
//                       decoration: InputDecoration(
//                         labelText: "Remarks", // Set the label text for the second text field
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10), // Add spacing between each group
//           ],
//         ),
//       );
//     } else {
//       // If it's not a multiple of 4, return an empty container
//       return Container();
//     }
//   }),
// ),




// Padding(
// padding: EdgeInsets.symmetric(
// horizontal: SizeConfig.blockSizeHorizontal !* 3),
// child: MaterialButton(
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(22.0)),
// child: Padding(
// padding: EdgeInsets.symmetric(
// horizontal: SizeConfig.blockSizeHorizontal !* 3),
// child: Text(
// "Submit",
// style: TextStyle(
// color: Colors.white,
// fontSize: SizeConfig.blockSizeHorizontal !* 4.3),
// ),
// ),
// color: colorBlueApp,
// onPressed: () async {
// if (listPMRSend.isEmpty ) {
// final snackBar = SnackBar(
// backgroundColor: Colors.red,
// content: Text(
// "Please enter Atleast one Services record"),
// );
// ScaffoldMessenger.of(context).showSnackBar(snackBar);
// Future.delayed(Duration(seconds: 2), () {
// ScaffoldMessenger.of(context).hideCurrentSnackBar();
// });
// } else
// // {
// //   bool atleastOneIsAddedFromDevice = false;
// //   for (int i = 0; i < listPMR.length; i++) {
// //     if (!listPMR[i].fromServer) {
// //       atleastOneIsAddedFromDevice = true;
// //       break;
// //     }
// //   }
// //   if (atleastOneIsAddedFromDevice) {
// //     addPrescription(context);
// //   } else
//     {
// final snackBar = SnackBar(
// backgroundColor: Colors.green,
// content: Text(
// "Entered Services Added"),
// );
// ScaffoldMessenger.of(context).showSnackBar(snackBar);
// Future.delayed(Duration(seconds: 2), () {
// ScaffoldMessenger.of(context).hideCurrentSnackBar();
// });
// sendPMRData(
// context,
// widget.patientindooridp,
// widget.PatientIDP,
// );
// Navigator.of(context).push(
// MaterialPageRoute(
// builder: (context) =>
// PMRTableScreen(
// patientindooridp:  widget.patientindooridp,
// PatientIDP:  widget.PatientIDP,
// doctoridp:  widget.doctoridp,
// firstname:  widget.firstname,
// lastName:  widget.lastName,)
// )
// );
// }
// }
// ),
// ),