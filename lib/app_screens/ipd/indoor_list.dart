import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swasthyasetu/app_screens/add_patient_screen.dart';
import 'package:swasthyasetu/app_screens/ipd/indoor_list_icon_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_indoorlist.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/color.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';

class IndoorListScreen extends StatefulWidget {

  String selectedOrganizationName = '';
  String imgUrl = "";
  // const SwitchOrganizationView({super.key});


  @override
  State<IndoorListScreen> createState() => _IndoorListScreenState();
}

class _IndoorListScreenState extends State<IndoorListScreen> {

  List<PatientDetails> listForIndoorPatient = [];

  @override
  void initState() {
    // selectedOrganizationName;
    getIndoorList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IPD List"),
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
          child:
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1.0, color: Colors.black),
                top: BorderSide(width: 1.0, color: Colors.black),
              ),
            ),
            child: DataTable(
              columnSpacing: 25.0,
              columns: [
                DataColumn(label: Text('Room No.',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                  ),)),
                DataColumn(label: Text('Bed No.',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                  ),)),
                DataColumn(label: Text('Charge Category',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                  ),)),
                DataColumn(label: Text('Admission Date',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                  ),)),
                DataColumn(label: Text('Patient Name',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                  ),)),
                DataColumn(label: Text('Doctor Name',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                  ),)),
                DataColumn(label: Text('Referring Doctor Name',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                  ),)),
                DataColumn(label: Text('Referring Patient Name',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                  ),)),
                DataColumn(label: Text('Balance Amount',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                  ),)),
                DataColumn(label: Text('Status',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                  ),)),
                DataColumn(label: Text('',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Ubuntu",
                    fontSize: SizeConfig.blockSizeVertical! * 2.5,
                  ),)),
                // Add more DataColumn widgets based on your requirements
              ],
              rows: listForIndoorPatient.map((patient) {
                return DataRow(
                  cells: [
                    DataCell(
                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => IndoorListIconScreen(
                                  patientindooridp: patient.patientIndoorIDP.toString(),
                                  PatientIDP: patient.patientIDF.toString(),
                                  doctoridp: patient.doctorIDF.toString(),
                                  firstname: patient.firstName.toString(),
                                  lastName: patient.lastName.toString(),
                                  // patientindooridp: patient['InvoiceAmount'].toString(),
                                ),
                              ),
                            );
                          },
                            child: Text(patient.roomNumber.toString()))),
                    DataCell(
                        GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => IndoorListIconScreen(
                                    patientindooridp: patient.patientIndoorIDP.toString(),
                                    PatientIDP: patient.patientIDF.toString(),
                                    doctoridp: patient.doctorIDF.toString(),
                                    firstname: patient.firstName.toString(),
                                    lastName: patient.lastName.toString(),
                                    // patientindooridp: patient['InvoiceAmount'].toString(),
                                  ),
                                ),
                              );
                            },
                            child: Text(patient.roomBed.toString()))),
                    DataCell(
                        GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => IndoorListIconScreen(
                                    patientindooridp: patient.patientIndoorIDP.toString(),
                                    PatientIDP: patient.patientIDF.toString(),
                                    doctoridp: patient.doctorIDF.toString(),
                                    firstname: patient.firstName.toString(),
                                    lastName: patient.lastName.toString(),
                                    // patientindooridp: patient['InvoiceAmount'].toString(),
                                  ),
                                ),
                              );
                            },
                            child: Text(patient.patientCategoryName.toString()))),
                    DataCell(
                        GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => IndoorListIconScreen(
                                    patientindooridp: patient.patientIndoorIDP.toString(),
                                    PatientIDP: patient.patientIDF.toString(),
                                    doctoridp: patient.doctorIDF.toString(),
                                    firstname: patient.firstName.toString(),
                                    lastName: patient.lastName.toString(),
                                    // patientindooridp: patient['InvoiceAmount'].toString(),
                                  ),
                                ),
                              );
                            },
                            child: Text(patient.admitDt.toString()))),
                    DataCell(
                        GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => IndoorListIconScreen(
                                    patientindooridp: patient.patientIndoorIDP.toString(),
                                    PatientIDP: patient.patientIDF.toString(),
                                    doctoridp: patient.doctorIDF.toString(),
                                    firstname: patient.firstName.toString(),
                                    lastName: patient.lastName.toString(),
                                    // patientindooridp: patient['InvoiceAmount'].toString(),
                                  ),
                                ),
                              );
                            },
                            child: Text('${patient.firstName} ${patient.lastName}'))),
                    DataCell(
                        GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => IndoorListIconScreen(
                                    patientindooridp: patient.patientIndoorIDP.toString(),
                                    PatientIDP: patient.patientIDF.toString(),
                                    doctoridp: patient.doctorIDF.toString(),
                                    firstname: patient.firstName.toString(),
                                    lastName: patient.lastName.toString(),
                                    // patientindooridp: patient['InvoiceAmount'].toString(),
                                  ),
                                ),
                              );
                            },
                            child: Text('${patient.doctorFirstName} ${patient.doctorMiddleName} ${patient.doctorLastName}'))),
                    // DataCell(Text(patient['doctorfirstname'].toString() +
                    //     patient['doctormiddlename'].toString() + patient['doctorlastname'].toString())),
                    DataCell(
                        GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => IndoorListIconScreen(
                                    patientindooridp: patient.patientIndoorIDP.toString(),
                                    PatientIDP: patient.patientIDF.toString(),
                                    doctoridp: patient.doctorIDF.toString(),
                                    firstname: patient.firstName.toString(),
                                    lastName: patient.lastName.toString(),
                                    // patientindooridp: patient['InvoiceAmount'].toString(),
                                  ),
                                ),
                              );
                            },
                            child: Text(patient.reffDoctorName.toString()))),
                    DataCell(
                        GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => IndoorListIconScreen(
                                    patientindooridp: patient.patientIndoorIDP.toString(),
                                    PatientIDP: patient.patientIDF.toString(),
                                    doctoridp: patient.doctorIDF.toString(),
                                    firstname: patient.firstName.toString(),
                                    lastName: patient.lastName.toString(),
                                    // patientindooridp: patient['InvoiceAmount'].toString(),
                                  ),
                                ),
                              );
                            },
                            child: Text(patient.refferPatient.toString()))),
                    DataCell(
                        GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => IndoorListIconScreen(
                                    patientindooridp: patient.patientIndoorIDP.toString(),
                                    PatientIDP: patient.patientIDF.toString(),
                                    doctoridp: patient.doctorIDF.toString(),
                                    firstname: patient.firstName.toString(),
                                    lastName: patient.lastName.toString(),
                                    // patientindooridp: patient['InvoiceAmount'].toString(),
                                  ),
                                ),
                              );
                            },
                            child: Text(patient.invoiceAmount.toString()))),
                    DataCell(
                        GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => IndoorListIconScreen(
                                    patientindooridp: patient.patientIndoorIDP.toString(),
                                    PatientIDP: patient.patientIDF.toString(),
                                    doctoridp: patient.doctorIDF.toString(),
                                    firstname: patient.firstName.toString(),
                                    lastName: patient.lastName.toString(),
                                    // patientindooridp: patient['InvoiceAmount'].toString(),
                                  ),
                                ),
                              );
                            },
                            child: Text(patient.roomNumber.toString()))),
                    // DataCell(Text(item.createdBy ?? '')),
                    DataCell(
                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => IndoorListIconScreen(
                                  patientindooridp: patient.patientIndoorIDP.toString(),
                                  PatientIDP: patient.patientIDF.toString(),
                                  doctoridp: patient.doctorIDF.toString(),
                                  firstname: patient.firstName.toString(),
                                  lastName: patient.lastName.toString(),
                                  // patientindooridp: patient['InvoiceAmount'].toString(),
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Center(
                                  child: Icon(Icons.navigate_next)),
                            ],
                          ),
                        )),
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

  void getIndoorList() async {
    print('getIndoorList');

    try{
      String loginUrl = "${baseURL}doctor_ipd_indoor_list.php";
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

        // Replace '}' with '},'
        strData = strData.replaceAllMapped(
          RegExp('}{"Firstname":"'),
              (match) => '},{"Firstname":"',
        );

        debugPrint("Decoded Data List : " + strData);
        final jsonData = json.decode(strData);

        for (var i = 0; i < jsonData.length; i++) {
          final roomOccupied = RoomOccupied.fromJson(jsonData[i]);

          if (roomOccupied.nullList != null || roomOccupied.occupiedList != null) {
            if (roomOccupied.nullList != null) {
              listForIndoorPatient.addAll(roomOccupied.nullList!);
            }

            if (roomOccupied.occupiedList != null) {
              listForIndoorPatient.addAll(roomOccupied.occupiedList!);
            }
          }

          debugPrint("----------------------");


          for (var patientDetails in listForIndoorPatient) {
            debugPrint("Patient Details:");
            debugPrint("First Name: ${patientDetails.firstName}");
            debugPrint("Last Name: ${patientDetails.lastName}");
            debugPrint("Doctor First Name: ${patientDetails.doctorFirstName}");

            debugPrint("----------------------");
          }
        }
        // Add this section to manually set serial numbers
        // for (var i = 0; i < listForIndoorPatient.length; i++) {
        //   listForIndoorPatient[i].serialNumber = i + 1;
        // }

        //   final jo = jsonData[i];
        //   String roomBed = jo['RoomBed'].toString();
        //   String roomNumber = jo['RoomNumber'].toString();
        //   String roomBedIDP = jo['RoomBedIDP'].toString();
        //   String roomMasterIDP = jo['RoomMasterIDP'].toString();
        //   String PatientCategoryName = jo['PatientCategoryName'].toString();
        //   // String patientName = jo['Firstname'].toString() + jo['LastName'].toString();
        //   // String doctorName = jo['doctorfirstname'].toString() +jo['doctormiddlename'].toString() + jo['doctorlastname'].toString();
        //   String firstname = jo['Firstname'].toString();
        //   String lastName = jo['LastName'].toString();
        //   String doctorfirstname = jo['doctorfirstname'].toString();
        //   String doctorlastname = jo['doctorlastname'].toString();
        //   String doctormiddlename = jo['doctormiddlename'].toString();
        //   String admitDt = jo['AdmitDt'].toString();
        //   String planofManagement = jo['PlanofManagement'].toString();
        //   String summaryStatus = jo['SummaryStatus'].toString();
        //   String invoiceNumber = jo['InvoiceNumber'].toString();
        //   String paymentMode = jo['PaymentMode'].toString();
        //   String invoiceAmount = jo['InvoiceAmount'].toString();
        //   String paymentNarration = jo['PaymentNarration'].toString();
        //   String amount = jo['amount'].toString();
        //   String reffDoctorName = jo['ReffDoctorName'].toString();
        //   String allowflag = jo['allowflag'].toString();
        //   String RefferPatient = jo['RefferPatient'].toString();
        //
        //   Map<String, dynamic> OrganizationMap = {
        //     "RoomBed": roomBed,
        //     "RoomNumber": roomNumber,
        //     "RoomBedIDP" : roomBedIDP,
        //     "RoomMasterIDP" : roomMasterIDP,
        //     "PatientCategoryName" : PatientCategoryName,
        //     // "PatientName" : patientName,
        //     // "DoctorName" : doctorName,
        //     "Firstname": firstname,
        //     "LastName": lastName,
        //     "doctorfirstname": doctorfirstname,
        //     "doctorlastname": doctorlastname,
        //     "doctormiddlename": doctormiddlename,
        //     "AdmitDt": admitDt,
        //     "PlanofManagement": planofManagement,
        //     "SummaryStatus": summaryStatus,
        //     "InvoiceNumber": invoiceNumber,
        //     "PaymentMode": paymentMode,
        //     "InvoiceAmount": invoiceAmount,
        //     "PaymentNarration": paymentNarration,
        //     "amount": amount,
        //     "ReffDoctorName": reffDoctorName,
        //     "allowflag": allowflag,
        //     "RefferPatient": RefferPatient,
        //   };
        //   listForIndoorPatient.add(OrganizationMap);
        //   // debugPrint("Added to list: $complainName");
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


