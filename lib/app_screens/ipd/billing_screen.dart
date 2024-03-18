import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:silvertouch/app_screens/ipd/indoor_list_icon_screen.dart';
import'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_services_send.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/widgets/autocomplete_custom.dart';

import '../add_patient_screen_doctor.dart';

List<String> listServices = [];
List<ServicesFormData> listservicesSend = [];
List<int> listServicesNumber = [];
List<int> listServicesCharge = [];

TextEditingController SelectServicesController = TextEditingController();
TextEditingController ServicesIDPController = TextEditingController();
TextEditingController AmountController = TextEditingController();


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
  // String lastSelected = '';
  // List<Map<String, dynamic>> listBillingServices1 = <Map<String, dynamic>>[];
  // TextEditingController serviceNameController1 = TextEditingController();
  // List<String> listBillingServices = [];
  // List<TextEditingController> serviceControllers = [];

  @override
  void initState() {
    // selectedOrganizationName;
    getBillingList(context, widget.patientindooridp);
    super.initState();
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

        // Clear the existing listPMR
        listServices.clear();

        listServicesNumber.clear();

        listServicesCharge.clear();

        for (var i = 0; i < jsonData.length; i++) {
          final jo = jsonData[i];

          int HospitalOPDServcesIDP = jo['HospitalOPDServcesIDP'];
          listServicesNumber.add(HospitalOPDServcesIDP);

          String OPDService = jo['OPDService'].toString();
          listServices.add(OPDService);

          // int Price = jo['Price'];
          // listServicesCharge.add(Price);

          String priceString = jo['Price']; // Parse the 'Price' field as a string
          int Price = int.parse(priceString); // Convert the string to an integer
          listServicesCharge.add(Price); // Add the parsed integer to the list

          // listBillingServices.add(OPDService);
          debugPrint("Added to list: ${listServicesNumber}");
          debugPrint("Added to list: ${listServices}");
          debugPrint("Added to list: ${listServicesCharge}");
          //
          //           {"HospitalOPDServcesIDP":3020,
          // "OPDService":"DRESSING MAJOR","Price":"400"},
        }
        setState(() {});
      }
    } catch (e) {
      print('Error decoding JSON: $e');
    }
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
      body: Builder(
        builder: (context) {
          // return Container();
          return Column(
            children: <Widget>[
              Row(
                children: [
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal !* 35,
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
                child: listservicesSend.length > 0
                    ? ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: listservicesSend.length,
                        itemBuilder: (context, index) {
                          TextEditingController SelectServicesController1 =
                          TextEditingController(
                              text: listservicesSend[index].services );
                          TextEditingController ServicesIDPController1 =
                          TextEditingController(
                              text: listservicesSend[index].servicesIDP );

                          // TextEditingController QtyController1 =
                          // TextEditingController(text: listservicesSend[index].quantity);

                          TextEditingController AmountController1 =
                          TextEditingController(
                              text: listservicesSend[index].servicecharge );
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
                                                        SelectServicesController1,
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
                                                          "Select Services",
                                                          hintText: "",
                                                        ),
                                                      ),
                                                    ))),
                                            // Expanded(
                                            //     child: Padding(
                                            //       padding: EdgeInsets.all(
                                            //           SizeConfig
                                            //               .blockSizeHorizontal !*
                                            //               2),
                                            //       child: IgnorePointer(
                                            //         child: TextField(
                                            //           controller:
                                            //           ServicesIDPController1,
                                            //
                                            //           style: TextStyle(
                                            //               color: black),
                                            //           keyboardType: TextInputType.number,
                                            //           decoration:
                                            //           InputDecoration(
                                            //             hintStyle: TextStyle(
                                            //                 color: darkgrey),
                                            //             labelStyle: TextStyle(
                                            //                 color: darkgrey),
                                            //             labelText:
                                            //             "Particular Name IDP",
                                            //             hintText: "",
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     )),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Expanded(
                                            //     child: Padding(
                                            //       padding: EdgeInsets.all(
                                            //           SizeConfig
                                            //               .blockSizeHorizontal !*
                                            //               2),
                                            //       child: IgnorePointer(
                                            //         child: TextField(
                                            //           controller:
                                            //           QtyController1,
                                            //           style: TextStyle(
                                            //               color: black),
                                            //           keyboardType: TextInputType.number,
                                            //           decoration:
                                            //           InputDecoration(
                                            //             hintStyle: TextStyle(
                                            //                 color: darkgrey),
                                            //             labelStyle: TextStyle(
                                            //                 color: darkgrey),
                                            //             labelText:
                                            //             "Requested Qty.",
                                            //             hintText: "",
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     )),
                                            Expanded(
                                                child: Padding(
                                                    padding: EdgeInsets
                                                        .all(SizeConfig
                                                        .blockSizeHorizontal !*
                                                        2),
                                                    child: IgnorePointer(
                                                      child: TextField(
                                                        controller:
                                                        AmountController1,
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
                                                          "Service Charges",
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
                                    setState(() {
                                      listservicesSend.removeAt(index);
                                    });
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
                      if (listservicesSend.isEmpty ) {
                        final snackBar = SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                              "Please enter Atleast one Services record"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Future.delayed(Duration(seconds: 2), () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        });
                      } else
                        // {
                        //   bool atleastOneIsAddedFromDevice = false;
                        //   for (int i = 0; i < listPMR.length; i++) {
                        //     if (!listPMR[i].fromServer) {
                        //       atleastOneIsAddedFromDevice = true;
                        //       break;
                        //     }
                        //   }
                        //   if (atleastOneIsAddedFromDevice) {
                        //     addPrescription(context);
                        //   } else
                          {
                        final snackBar = SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(
                              "Entered Services Added"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Future.delayed(Duration(seconds: 2), () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        });
                        getAddedBillingSubmit(
                          context,
                          widget.PatientIDP,
                          widget.patientindooridp,
                        );
                        Navigator.pop(context);
                      }
                    }
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void setStateOfParent() {
    setState(() {});
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
                                                listServices,
                                                listServicesNumber,
                                                listServicesCharge,
                                                setStateOfParent
                                            );
                                          },
                                          child: Container(
                                            width:
                                            SizeConfig.blockSizeHorizontal !* 90,
                                            padding: EdgeInsets.all(
                                                SizeConfig.blockSizeHorizontal !* 1),
                                            child: IgnorePointer(
                                              child: TextField(
                                                controller: SelectServicesController,
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
                                                  labelText: "Select Service Name",
                                                  hintText: "",
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                  // Flexible(
                                  //   child: Padding(
                                  //       padding: EdgeInsets.symmetric(
                                  //           horizontal:
                                  //           SizeConfig.blockSizeHorizontal !* 2),
                                  //       child: Container(
                                  //         width:
                                  //         SizeConfig.blockSizeHorizontal !* 90,
                                  //         padding: EdgeInsets.all(
                                  //             SizeConfig.blockSizeHorizontal !* 1),
                                  //         child: IgnorePointer(
                                  //           child: TextField(
                                  //             controller: pmrIDPController,
                                  //             style: TextStyle(
                                  //                 color: black,
                                  //                 fontSize: SizeConfig
                                  //                     .blockSizeVertical !*
                                  //                     2.3),
                                  //             decoration: InputDecoration(
                                  //               hintStyle: TextStyle(
                                  //                   color: darkgrey,
                                  //                   fontSize: SizeConfig
                                  //                       .blockSizeVertical !*
                                  //                       2.3),
                                  //               labelStyle: TextStyle(
                                  //                   color: darkgrey,
                                  //                   fontSize: SizeConfig
                                  //                       .blockSizeVertical !*
                                  //                       2.3),
                                  //               labelText: "Particular Name IDP",
                                  //               hintText: "",
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       )
                                  //   ),
                                  // ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  // Flexible(
                                  //   child: Padding(
                                  //     padding: EdgeInsets.symmetric(
                                  //         horizontal:
                                  //         SizeConfig.blockSizeHorizontal !* 2),
                                  //     child: IgnorePointer(
                                  //       child: TextField(
                                  //         controller: ServicesIDPController,
                                  //         // keyboardType: TextInputType.number,
                                  //         style: TextStyle(color: black),
                                  //         keyboardType: TextInputType.number,
                                  //         decoration: InputDecoration(
                                  //           hintStyle: TextStyle(color: darkgrey),
                                  //           labelStyle: TextStyle(color: darkgrey),
                                  //           labelText: "Idp",
                                  //           hintText: "",
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                          SizeConfig.blockSizeHorizontal !* 2),
                                      child: IgnorePointer(
                                        child: TextField(
                                          controller: AmountController,
                                          // keyboardType: TextInputType.number,
                                          style: TextStyle(color: black),
                                          decoration: InputDecoration(
                                            hintStyle: TextStyle(color: darkgrey),
                                            labelStyle: TextStyle(color: darkgrey),
                                            labelText: "Services Charges",
                                            hintText: "",
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Flexible(
                                  //   child: Padding(
                                  //       padding: EdgeInsets.symmetric(
                                  //           horizontal:
                                  //           SizeConfig.blockSizeHorizontal !* 2),
                                  //       child: InkWell(
                                  //         onTap: () {
                                  //           // showMasterSelectionDialog(
                                  //           //     listMastersAdviceTypeString,
                                  //           //     1,
                                  //           //     setStateOfParent);
                                  //         },
                                  //         child: Container(
                                  //           width:
                                  //           SizeConfig.blockSizeHorizontal !* 90,
                                  //           padding: EdgeInsets.all(
                                  //               SizeConfig.blockSizeHorizontal !* 1),
                                  //           child: IgnorePointer(
                                  //             child: TextField(
                                  //               controller: RemarksController,
                                  //               style: TextStyle(
                                  //                   color: black,
                                  //                   fontSize: SizeConfig
                                  //                       .blockSizeVertical !*
                                  //                       2.3),
                                  //               decoration: InputDecoration(
                                  //                 hintStyle: TextStyle(
                                  //                     color: darkgrey,
                                  //                     fontSize: SizeConfig
                                  //                         .blockSizeVertical !*
                                  //                         2.3),
                                  //                 labelStyle: TextStyle(
                                  //                     color: darkgrey,
                                  //                     fontSize: SizeConfig
                                  //                         .blockSizeVertical !*
                                  //                         2.3),
                                  //                 labelText: "Remarks",
                                  //                 hintText: "",
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       )
                                  //   ),
                                  // ),
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
                          if (SelectServicesController.text.trim() ==
                              "" /*||
                                    drugDosageController.text.trim() == ""*/
                          // ||
                          // AmountController.text.trim() ==
                          //     "" /*||
                          //       drugAdviceController.text.trim() == ""*/
                          ) {
                            debugPrint(SelectServicesController.text.trim());
                            debugPrint(ServicesIDPController.text.trim());
                            debugPrint(AmountController.text.trim());
                            final snackBar = SnackBar(
                              backgroundColor: Colors.red,
                              content: Text("Please enter the fields"),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            Future.delayed(Duration(seconds: 2), () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            });
                          } else {
                            listservicesSend.add(ServicesFormData(
                              services:SelectServicesController.text.toString(),
                              servicesIDP: ServicesIDPController.text.toString(),
                              servicecharge: AmountController.text.toString(),
                            ));
                            SelectServicesController = TextEditingController();
                            ServicesIDPController = TextEditingController();
                            AmountController = TextEditingController();
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
      List<String> listServices,
      List<int> idList,
      List<int> chargingList,
      VoidCallback setStateOfParent) {
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
          child: SelectPMRDialog(
            setStateOfParent: setStateOfParent,
            listServices: listServices,
            idList: idList,
            chargelist: chargingList,
          ),
        )
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

  // selectedFieldBillingServices(BuildContext context,
  //     TextEditingController anyController, text) {
  //   FocusScopeNode currentFocus = FocusScope.of(context);
  //   if (!currentFocus.hasPrimaryFocus) {
  //     currentFocus.unfocus();
  //   }
  //   if (listBillingServices.isNotEmpty) {
  //     int index = listBillingServices.indexOf(text);
  //     if (index != -1) {
  //       debugPrint(listBillingServices[index]);
  //       // Handle the logic related to the selected complaint
  //
  //       // Assuming that getComplaintList is a function to fetch the details
  //       getBillingList(context, widget.patientindooridp);
  //
  //       anyController.text = text;
  //       initialState = false;
  //     } else {
  //       debugPrint("Text not found in listDiagnosisDetails");
  //     }
  //   } else {
  //     debugPrint("List is empty");
  //   }
  // }
  //
  //

  void getAddedBillingSubmit(BuildContext context,
      String patientindooridp,
      String PatientIDF) async {
    print('getBillingList');


    try {
      String loginUrl = "${baseURL}doctor_add_pmr_submit.php";
      ProgressDialog pr = ProgressDialog(context);
      Future.delayed(Duration.zero, () {
        pr.show();
      });
      var jArrayBillingData = "[";
      for (var i = 0; i < listservicesSend.length; i++) {
        var formData = listservicesSend[i];

        jArrayBillingData +=
        "{\"service\":\"${formData.servicesIDP}\","
            "\"servicecharge\":\"${formData.servicecharge}\",";
        // "\"quantity\":\"${formData.quantity}\","
        // "\"remarks\":\"${formData.remarks}\"},";

      }
      // Remove the trailing comma if it exists
      if (listservicesSend.isNotEmpty) {
        jArrayBillingData = jArrayBillingData.substring(0, jArrayBillingData.length - 1);
      }
      jArrayBillingData += "]";
      print(jArrayBillingData);

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
          " " +
          patientindooridp +
          "\"" +
          "," +
          "\"" +
          "PMRData" +
          "\"" +
          ":" +
          "\"" +
          jArrayBillingData +
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

class SelectPMRDialog extends StatefulWidget {
  Function setStateOfParent;
  List<String> listServices;
  List<int> idList; // Add a list to store IDs
  List<int> chargelist;

  SelectPMRDialog({
    required this.setStateOfParent,
    required this.listServices,
    required this.idList,
    required this.chargelist, // Accept the ID list as a parameter
  });

  @override
  State<StatefulWidget> createState() {
    return SelectPMRDialogState();
  }
}

class SelectPMRDialogState extends State<SelectPMRDialog> {
  Icon? icon;
  Widget? titleWidget;
  var searchController = TextEditingController();
  var focusNode = FocusNode();
  bool firstTime = true;

  late List<String> filteredList;

  @override
  void initState() {
    super.initState();
    firstTime = true;
    searchController = TextEditingController(text: "");
    focusNode.requestFocus();
    icon = Icon(
      Icons.cancel,
      color: Colors.red,
    );
    titleWidget = TextField(
      controller: searchController,
      focusNode: focusNode,
      cursorColor: Colors.black,
      onChanged: (text) {
        setState(() {
          // Filter the list based on search text
          filteredList = _filterMedicines(text);
        });
      },
      decoration: InputDecoration(
        hintText: "Search Here",
      ),
    );
    filteredList = widget.listServices; // Initialize filteredList with the full list of services
  }

  List<String> _filterMedicines(String searchText) {
    return widget.listServices
        .where((medicine) => medicine.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              InkWell(
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.red,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(
                width: 20,
              ),
              Container(
                width: 200,
                child: Center(
                  child: titleWidget!,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: InkWell(
                      child: icon,
                      onTap: () {
                        setState(() {
                          if (icon?.icon == Icons.cancel) {
                            searchController.clear();
                            // filteredList = widget.listServices; // Reset to full list when canceling search
                          }
                        });
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: widget.listServices.isNotEmpty
              ? ListView.builder(
            itemCount: filteredList.length,
            itemBuilder: (contextFromList, index) {
              // Ensure index is valid
              if (index >= 0 && index < widget.listServices.length && index < widget.idList.length && index < widget.chargelist.length) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    // Update the controller's value
                    SelectServicesController.text = filteredList[index].toString();
                    ServicesIDPController.text = widget.idList[index].toString();
                    AmountController.text = widget.chargelist[index].toString();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        filteredList[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                // Handle the case where index is out of range
                return SizedBox.shrink(); // or any other fallback widget
              }
            },
          )
              : Center(
            child: Text('No services available'),
          ),
        )
      ],
    );
  }
}

