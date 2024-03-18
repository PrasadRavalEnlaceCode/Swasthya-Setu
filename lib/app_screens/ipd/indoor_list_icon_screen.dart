import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:silvertouch/app_screens/PDFViewerCachedFromUrl.dart';
import 'package:silvertouch/app_screens/ipd/add_to_ot_screen.dart';
import 'package:silvertouch/app_screens/ipd/advise_investigation_screen.dart';
import 'package:silvertouch/app_screens/ipd/advise_investigation_table.dart';
import 'package:silvertouch/app_screens/ipd/billing_screen.dart';
import 'package:silvertouch/app_screens/ipd/indoor_list.dart';
import 'package:silvertouch/app_screens/ipd/input_chart_screen.dart';
import 'package:silvertouch/app_screens/ipd/mo_notes_screen.dart';
import 'package:silvertouch/app_screens/ipd/output_chart_Table_screen.dart';
import 'package:silvertouch/app_screens/ipd/pmr_table_screen.dart';
import 'package:silvertouch/app_screens/ipd/treatment_sheet_screen.dart';
import 'package:silvertouch/app_screens/ipd/vital_chart_table.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_login_icons_model.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/progress_dialog.dart';

class IndoorListIconScreen extends StatefulWidget {


  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;
  final String RoomBedIDP;
  final String allowFlag;
  final String PlanofManagement;


  IndoorListIconScreen({
    required this.patientindooridp,
    required this.PatientIDP,
    required this.doctoridp,
    required this.firstname,
    required this.lastName,
    required this.RoomBedIDP,
    required this.allowFlag,
    required this.PlanofManagement,
  });


  @override
  State<IndoorListIconScreen> createState() => _IndoorListIconScreenState();
}

class _IndoorListIconScreenState extends State<IndoorListIconScreen> {

  String selectedValue = 'Option 1';
  List<Map<String, dynamic>> listDropDownforSummary = <Map<String, dynamic>>[];
  List<String> listIconName = [];
  List<String> listImage = [];

  @override
  void initState() {

    listIconName.add("Vital\nChart");
    listIconName.add("Input\nChart");
    listIconName.add("Output\nChart");
    listIconName.add("PMR");
    listIconName.add("Billing");
    listIconName.add("Treatment\nSheet");
    listIconName.add("View Discharge\nsummary");
    listIconName.add("Investigation\nAdvice");
    listIconName.add("MO\nNotes");
    listIconName.add("Plan of\nManagement");
    listIconName.add("Add to\n OT");
    listIconName.add("Discharge");

    listImage.add("v-2-icn-add-patient.png");
    listImage.add("v-2-icn-my-patient.png");
    listImage.add("v-2-icn-my-appointment.png");
    listImage.add("v-2-icn-sent-notification.png");
    listImage.add("v-2-icn-my-library.png");
    listImage.add("v-2-icn-market-place.png");
    listImage.add("v-2-icn-add-patient.png");
    listImage.add("v-2-icn-my-patient.png");
    listImage.add("v-2-icn-my-appointment.png");
    listImage.add("v-2-icn-sent-notification.png");
    listImage.add("v-2-icn-my-library.png");
    listImage.add("v-2-icn-market-place.png");

    // selectedValue = widget.PlanofManagement ?? '0';



    // getOrganizations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( "${widget.firstname} ${widget.lastName}" ),
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
          child: Column(
            children: [
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 4.0,
              ),
              Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
                    vertical: SizeConfig.blockSizeHorizontal! * 3.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xfff0f1f5),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(
                        20,
                      ),
                      topLeft: Radius.circular(
                        20,
                      ),
                    ),
                  ),
                  child: Center(
                    child: GridView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: listIconName.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1.3, crossAxisCount: 3),
                        itemBuilder: (context, index) {
                          return IconCard(
                              IconModel(listIconName[index],
                                listImage[index], "",),
                              patientindooridp: widget.patientindooridp,
                              PatientIDP: widget.PatientIDP,
                              doctoridp: widget.doctoridp,
                              firstname: widget.firstname,
                              lastName: widget.lastName,
                              RoomBed: widget.RoomBedIDP,
                              allowFlag: widget.allowFlag,
                              PlanofManagement:widget.PlanofManagement
                          );
                          //: Container(),
                          /*);*/
                        }),
                  )),
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 1,
              ),
            ],
          ),
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

}

class IconCard extends StatefulWidget {
  IconModel? model;
  final String patientindooridp;
  final String PatientIDP;
  final String doctoridp;
  final String firstname;
  final String lastName;
  final String RoomBed;
  final String allowFlag;
  final String PlanofManagement;
  // Function? getDashBoardData;

  IconCard(IconModel model, {
    required this.patientindooridp,
    required this.PatientIDP,
    required this.doctoridp,
    required this.firstname,
    required this.lastName,
    required this.RoomBed,
    required this.allowFlag,
    required this.PlanofManagement,
  })
  { this.model = model; }

  @override
  State<IconCard> createState() => _IconCardState();
}

class _IconCardState extends State<IconCard> {


  Map<String, String> dropdownValueToString = {
    '0': 'Select Plan of Management',
    '1': 'Medical Management',
    '2': 'Surgical Management',
    '3': 'Medical + Surgical Management',
  };
  List<Map<String, dynamic>> listDropDownforSummary = <Map<String, dynamic>>[];
  late String _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = 'Select Plan of Management';
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return InkWell(
        highlightColor: Colors.green[200],
        customBorder: CircleBorder(),
        onTap: () async {
          if (widget.model!.iconName == "Vital\nChart") {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return VitalChartTableScreen(
                    patientindooridp: widget.patientindooridp,
                    PatientIDP: widget.PatientIDP,
                    doctoridp: widget.doctoridp,
                    firstname: widget.firstname,
                    lastName: widget.lastName,
                  );
                }));
          }
          else if (widget.model!.iconName == "Input\nChart") {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return InputChartScreen(
                    patientindooridp: widget.patientindooridp,
                    PatientIDP: widget.PatientIDP,
                    doctoridp: widget.doctoridp,
                    firstname: widget.firstname,
                    lastName: widget.lastName,
                  );
                }));
          }
          else if (widget.model!.iconName == "Output\nChart") {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return OutputChartTableScreen(
                    patientindooridp: widget.patientindooridp,
                    PatientIDP: widget.PatientIDP,
                    doctoridp: widget.doctoridp,
                    firstname: widget.firstname,
                    lastName: widget.lastName,
                  );
                }));
          }
          else if (widget.model!.iconName == "PMR") {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return PMRTableScreen(
                    patientindooridp: widget.patientindooridp,
                    PatientIDP: widget.PatientIDP,
                    doctoridp: widget.doctoridp,
                    firstname: widget.firstname,
                    lastName: widget.lastName,
                  );
                }));
          }
          else if (widget.model!.iconName == "Billing") {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return  BillingScreen(
                    patientindooridp: widget.patientindooridp,
                    PatientIDP: widget.PatientIDP,
                    doctoridp: widget.doctoridp,
                    firstname: widget.firstname,
                    lastName: widget.lastName,
                  );
                }));
          }
          else if (widget.model!.iconName == "View Discharge\nsummary") {
            getDischargeSummaryView(
                widget.patientindooridp,
                widget.PatientIDP

            );
          }
          else if (widget.model!.iconName == "Investigation\nAdvice") {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return  investigationTableScreen(
                    patientindooridp: widget.patientindooridp,
                    PatientIDP: widget.PatientIDP,
                    doctoridp: widget.doctoridp,
                    firstname: widget.firstname,
                    lastName: widget.lastName,
                  );
                }));
          }
          else if (widget.model!.iconName == "MO\nNotes") {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return MONotesScreen(
                    patientindooridp: widget.patientindooridp,
                    PatientIDP: widget.PatientIDP,
                    doctoridp: widget.doctoridp,
                    firstname: widget.firstname,
                    lastName: widget.lastName,
                  );
                }));
          }
          else if (widget.model!.iconName == "Add to\n OT") {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return AddToOTScreen(
                    patientindooridp: widget.patientindooridp,
                    PatientIDP: widget.PatientIDP,
                    doctoridp: widget.doctoridp,
                    firstname: widget.firstname,
                    lastName: widget.lastName,
                  );
                }));
          }
          else if (widget.model!.iconName == "Discharge") {
            getDischargeAllowSubmit(
              widget.patientindooridp,
              widget.PatientIDP,
              widget.allowFlag,
            );
          }
          else if (widget.model!.iconName == "Treatment\nSheet") {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return TreatmentSheetScreen();
                }));
          }
          else if (widget.model!.iconName == "Plan of\nManagement") {
            // showDialog(
            //   context: context,
            //   builder: (BuildContext context) {
            //     String selectedValue = widget.PlanofManagement == null ? '0' : widget.PlanofManagement ?? "0"; // Initial selected value
            //     String selectedStringValue = dropdownValueToString[selectedValue] ?? 'Select Plan of Management'; // Initial selected string value
            //
            //     return AlertDialog(
            //       title: Text('Select an option'),
            //       content: DropdownButton<String>(
            //         value: _selectedItem,
            //         items: <String>[
            //           'Select Plan of Management',
            //           'Medical Management',
            //           'Surgical Management',
            //           'Medical + Surgical Management'
            //         ].map((String value) {
            //           return DropdownMenuItem<String>(
            //             value: value,
            //             child: Text(value),
            //           );
            //         }).toList(),
            //         onChanged: (String? newValue) { // Changed the type to String?
            //           setState(() {
            //             _selectedItem = newValue!;
            //           });
            //         },
            //         hint: Text('Select Plan of Management'),
            //       ),
            //       actions: <Widget>[
            //         TextButton(
            //           onPressed: () {
            //             Navigator.of(context).pop(); // Close dialog
            //           },
            //           child: Text('Cancel'),
            //         ),
            //         ElevatedButton(
            //           onPressed: () {
            //             // Handle confirmation button click
            //             print('Selected option value: $selectedValue');
            //             PlanofManagementSend(selectedValue,widget.patientindooridp);
            //             Navigator.of(context).pop(); // Close dialog
            //           },
            //           child: Text('Confirm'),
            //         ),
            //       ],
            //
            //     );
            //   },
            // );

          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal! * 0.0),
          child: Container(
            child: Card(
              color: colorWhite,
              elevation: 2.0,
              margin: EdgeInsets.all(
                SizeConfig.blockSizeHorizontal! * 2.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  SizeConfig.blockSizeHorizontal! * 2.0,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image(
                        width: SizeConfig.blockSizeHorizontal! * 7,
                        height: SizeConfig.blockSizeHorizontal! * 7,
                        image: AssetImage(
                          'images/${widget.model!.image}',
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical! * 2,
                      ),
                      Flexible(
                        child: Text(widget.model!.iconName!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeHorizontal! * 2.8,
                            )),
                      ),
                    ]),
              ),
            ),
          ),
        ));
  }

  // showDialog(
  // context: context,
  // builder:(BuildContext context) {
  // String selectedValue = 'Select Plan of Management';
  // return AlertDialog(
  // title: Text('Select an option'),
  // content: DropdownButton<String>(
  // value: selectedValue,
  // onChanged: (String? newValue) {
  // // Update selected value when user selects an option
  // selectedValue = newValue!;
  // Navigator.of(context).pop(); // Close dialog
  // },
  // items: <String>[
  // 'Select Plan of Management',
  // 'Medical Management',
  // 'Surigcal Management',
  // 'Medical + Surigcal Management',
  // ].map<DropdownMenuItem<String>>((String value) {
  // return DropdownMenuItem<String>(
  // value: value,
  // child: Text(value),
  // );
  // }).toList(),
  // ),
  // actions: <Widget>[
  // TextButton(
  // onPressed: () {
  // Navigator.of(context).pop(); // Close dialog
  // },
  // child: Text('Cancel'),
  // ),
  // ElevatedButton(
  // onPressed: () {
  // // Handle confirmation button click
  // print('Selected option: $selectedValue');
  // Navigator.of(context).pop(); // Close dialog
  // },
  // child: Text('Confirm'),
  // ),
  // ],
  // );
  // }// Initial value for dropdown
  // );


  Future<void> PlanofManagementSend(String PlanofManagement,patientindooridp) async {
    print('getPlanofManagementSend');

    try{
      String loginUrl = "${baseURL}doctor_plan_of_management_submit.php";
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
      String jsonStr = "{" + "\"" + "planmanagement" + "\"" + ":" + "\"" + PlanofManagement + "\"," +
          "\"" + "patientindooridp" + "\"" + ":" + "\"" + patientindooridp + "\"" "}";

      // +
      // ","
      // "\"" + "RoomBedIDP" + "\"" + ":" + "\"" + RoomBedIDP + "\""


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

        final snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text("Plan OF Management has been Changed Successfully"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("There are Some Issue in Changing The Plan Try Again"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);


        setState(() {});
      }

    }catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  Future<void> getDischargeSummaryView( String PatientIndoorIDF,PatientIDP) async {
    print('getIndoorList');

    listDropDownforSummary.clear();

    try{
      String loginUrl = "${baseURL}doctor_discharge_summary_view.php";
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
          "\"" + "PatientIndoorIDF" + "\"" + ":" + "\"" + PatientIndoorIDF + "\"" + ","
          "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + ","
          "\"" + "PatientIDP" + "\"" + ":" + "\"" + PatientIDP + "\""
          + "}";

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

        // Parse the JSON string
        List<Map<String, dynamic>> file1List = List<Map<String, dynamic>>.from(json.decode(strData));

        // Check if the list is not empty
        if (file1List.isNotEmpty) {

          String baseDischargeSummaryViewURL = "https://www.swasthyasetu.com/ws/images/DischargeSummary/";
          // Extract the value of the "FileName" key
          String fileName = file1List[0]["FileName"];
          String downloadPdfUrl = baseDischargeSummaryViewURL + fileName;

          // Show PDF from the fileName using the flutter_pdfview package
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewerCachedFromUrl(url: downloadPdfUrl),
            ),
          );

        }
        setState(() {});
      }
    }catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  Future<void> getDischargeAllowSubmit( String PatientIndoorIDF,PatientIDP,allowFlag) async {
    print('getIndoorList');

    listDropDownforSummary.clear();

    try{
      String loginUrl = "${baseURL}doctor_discharge_allow_status_submit.php";
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
          "\"" + "PatientIndoorIDP" + "\"" + ":" + "\"" + PatientIndoorIDF + "\"" + ","
          "\"" + "PatientIDP" + "\"" + ":" + "\"" + PatientIDP + "\"" + ","
          "\"" + "allowflag" + "\"" + ":" + "\"" + allowFlag + "\""
          + "}";

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

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>
                IndoorListScreen()));

        // // Parse the JSON string
        // List<Map<String, dynamic>> file1List = List<Map<String, dynamic>>.from(json.decode(strData));
        //
        // // Check if the list is not empty
        // if (file1List.isNotEmpty) {
        //
        //   String baseDischargeSummaryViewURL = "${baseURL}";
        //   // Extract the value of the "FileName" key
        //   String fileName = file1List[0]["FileName"];
        //   String downloadPdfUrl = baseDischargeSummaryViewURL + fileName;
        //
        //   // Show PDF from the fileName using the flutter_pdfview package
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => PDFViewerCachedFromUrl(url: downloadPdfUrl),
        //     ),
        //   );
        //
        // }
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

