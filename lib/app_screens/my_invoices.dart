import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silvertouch/app_screens/PDFViewerCachedFromUrl.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/model_myinvoices.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';
import '../global/SizeConfig.dart';
import '../utils/color.dart';
import '../utils/progress_dialog.dart';

class MyInvoiceListScreen extends StatefulWidget {
  @override
  State<MyInvoiceListScreen> createState() => _MyInvoiceListScreenState();
}

class _MyInvoiceListScreenState extends State<MyInvoiceListScreen> {
  var fromDate = DateTime.now().subtract(Duration(days: 30));
  var toDate = DateTime.now();

  var fromDateString = "";
  var toDateString = "";
  var taskId;
  ProgressDialog? pr;
  late DateTimeRange dateRange;

  late String selectedOrganizationIDF;
  List<DoctorInvoice> allInvoices = [];
  int serialNumber =1;

  String baseInvoiceURL = "https://swasthyasetu.com/ws/images/myinvoice/";
  String baseInvoiceVoucherURL =
      "https://swasthyasetu.com/ws/images/myinvoicevoucher/";

  // List<String> DataFormat = ["Type","Date","Patient","Doctor","OPD/IPD","Investigation","Lab Status","Created By","Action"];

  final sizeBox = SizedBox(
    width: 30,
    height: 20,
  );

  @override
  void initState() {
    dateRange = DateTimeRange(start: fromDate, end: toDate);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = dateRange.start;
    final end = dateRange.end;
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("My Invoices"),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(
            color: Colorsblack, size: SizeConfig.blockSizeVertical! * 2.2),
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
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  SizedBox(
                    height: SizeConfig.blockSizeVertical! * 2,
                  ),
                  Container(
                    height: SizeConfig.blockSizeVertical! * 8,
                    child: Padding(
                      padding: EdgeInsets.only(left: 5.0, right: 5.0),
                      child: Container(
                        child: InkWell(
                            onTap: () {
                              // showDateRangePickerDialog();
                            },
                            child: Row(
                              children: <Widget>[
                                // Expanded(
                                //   child: Text(
                                //     fromDateString == ""
                                //         ? "Select Date Range"
                                //         : "$fromDateString  to  $toDateString",
                                //     textAlign: TextAlign.center,
                                //     style: TextStyle(
                                //         fontSize:
                                //             SizeConfig.blockSizeVertical !* 2.6,
                                //         fontWeight: FontWeight.w500,
                                //         color: Colors.black),
                                //   ),
                                // ),
                                // Container(
                                //   width: SizeConfig.blockSizeHorizontal !* 15,
                                //   child: Icon(
                                //     Icons.arrow_drop_down,
                                //     size: SizeConfig.blockSizeHorizontal !* 8,
                                //   ),
                                // ),
                                Expanded(
                                    child: ElevatedButton(
                                  child: Text(
                                      '${start.day}-${start.month}-${start.year}'),
                                  onPressed: pickDateRange,
                                )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: ElevatedButton(
                                  child: Text(
                                      '${end.day}-${end.month}-${end.year}'),
                                  onPressed: pickDateRange,
                                )),
                              ],
                            )),
                        padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical! * 2,
                  ),
                  MaterialButton(
                    onPressed: () {
                      if (fromDate == "" && toDate == "") {
                        final snackBar = SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Please select Date Range"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        return;
                      } else {
                        getMyInvoiceList();
                      }
                    },
                    color: Colors.blue,
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  sizeBox,
                  SizedBox(height: 16.0),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 1.0, color: Colors.black),
                          top: BorderSide(width: 1.0, color: Colors.black),
                        ),
                      ),
                      child: DataTable(
                        columnSpacing: 25.0,
                        columns: [
                          DataColumn(
                              label: Text(
                            'Sr No.',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Ubuntu",
                              fontSize: SizeConfig.blockSizeVertical! * 2.5,
                            ),
                          )),
                          DataColumn(
                              label: Text(
                            'Invoice Date',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Ubuntu",
                              fontSize: SizeConfig.blockSizeVertical! * 2.5,
                            ),
                          )),
                          DataColumn(
                              label: Text(
                            'Invoice Number',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Ubuntu",
                              fontSize: SizeConfig.blockSizeVertical! * 2.5,
                            ),
                          )),
                          DataColumn(
                              label: Text(
                            'Remarks',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Ubuntu",
                              fontSize: SizeConfig.blockSizeVertical! * 2.5,
                            ),
                          )),
                          DataColumn(
                              label: Text(
                            'Type',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Ubuntu",
                              fontSize: SizeConfig.blockSizeVertical! * 2.5,
                            ),
                          )),
                          DataColumn(
                              label: Text(
                            'Amount',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Ubuntu",
                              fontSize: SizeConfig.blockSizeVertical! * 2.5,
                            ),
                          )),
                          DataColumn(
                              label: Text(
                            'Status',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Ubuntu",
                              fontSize: SizeConfig.blockSizeVertical! * 2.5,
                            ),
                          )),
                          // DataColumn(label: Text('Created By',
                          //   style: TextStyle(
                          //     color: Colors.black,
                          //     fontFamily: "Ubuntu",
                          //     fontSize: SizeConfig.blockSizeVertical! * 2.5,
                          //   ),)),
                          DataColumn(
                              label: Text(
                            'Action',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Ubuntu",
                              fontSize: SizeConfig.blockSizeVertical! * 2.5,
                            ),
                          )),
                          // Add more DataColumn widgets based on your requirements
                        ],
                        rows: allInvoices.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  (serialNumber++).toString(),
                                ),
                              ),
                              DataCell(Text(item.invoiceDate ?? '')),
                              DataCell(Text(item.invoiceNumber ?? '')),
                              DataCell(Text(item.categoryName ?? '')),
                              DataCell(Text(item.type ?? '')),
                              DataCell(Text(item.payoutAmount ?? '')),
                              DataCell(Text(item.source ?? '')),
                              // DataCell(Text(item.createdBy ?? '')),
                              DataCell(
                                Row(
                                  children: [
                                    InkWell(
                                      child: Center(
                                          child: Icon(Icons.remove_red_eye)),
                                      onTap: () {
                                        getMyInvoice(
                                            item.doctorPayoutInvoiceIDP,
                                            item.doctorIDF,
                                            item.type == "IPD"
                                                ? "ipd"
                                                : item.type == "OPD"
                                                ? "opd"
                                                : "",
                                        ) ;
                                        // String downloadPdfUrl = baseInvoiceURL
                                        //     // + {item.id ?? ""}
                                        // ;
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute<dynamic>(
                                        //       builder: (_) => PDFViewerCachedFromUrl(
                                        //         url: downloadPdfUrl,
                                        //       ),
                                        //     ));

                                        // String path = baseImageURL + index["ReportImage"];
                                        //
                                        // // Encode the path to make it URL-safe
                                        // String encodedPath = Uri.encodeFull(path);
                                        //
                                        // // Launch the URL using url_launcher
                                        // launch(encodedPath);
                                      },
                                    ),
                                    // Divider(),
                                    Visibility(
                                      visible: item.source != 'Pending Invoice',
                                      child: InkWell(
                                        child: Center(
                                            child: Icon(Icons.remove_red_eye)),
                                        onTap: () {
                                          getMyInvoiceVoucher(
                                              item.doctorPayoutInvoiceIDP,
                                              item.doctorIDF,
                                            item.type == "IPD"
                                                ? "ipd"
                                                : item.type == "OPD"
                                                ? "opd"
                                                : "",);
                                          // String downloadPdfUrl = baseInvoiceVoucherURL
                                          // // + {item.id ?? ""}
                                          //     ;
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute<dynamic>(
                                          //       builder: (_) => PDFViewerCachedFromUrl(
                                          //         url: downloadPdfUrl,
                                          //       ),
                                          //     ));
                                          //
                                          // // String path = baseImageURL + index["ReportImage"];
                                          // //
                                          // // // Encode the path to make it URL-safe
                                          // // String encodedPath = Uri.encodeFull(path);
                                          // //
                                          // // // Launch the URL using url_launcher
                                          // // launch(encodedPath);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Add more DataCell widgets based on your requirements
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (newDateRange == null) return;

    setState(() {
      dateRange = newDateRange;
      fromDate = dateRange.start;
      toDate = dateRange.end;
      var formatter = new DateFormat('yyyy-MM-dd');
      fromDateString = formatter.format(fromDate);
      toDateString = formatter.format(toDate);
    });
  }

  void getMyInvoiceList() async {
    print('getDoctorInvoiceList');

    try {
      if (fromDateString.isEmpty && toDateString.isEmpty) {
        fromDate = DateTime.now().subtract(Duration(days: 30));
        toDate = DateTime.now();
        fromDateString = DateFormat('yyyy-MM-dd').format(fromDate);
        toDateString = DateFormat('yyyy-MM-dd').format(toDate);
      }

      String loginUrl = "${baseURL}doctor_my_invoice_list.php";
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
          "\"," +
          "\"" +
          "fromdate" +
          "\"" +
          ":" +
          "\"" +
          fromDateString +
          "\"" +
          ",\"" +
          "todate" +
          "\"" +
          ":" +
          "\"" +
          toDateString +
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

        // Replace '}' with '},'
        strData = strData.replaceAllMapped(
          RegExp('}{"DoctorPayoutInvoiceIDP":"'),
          (match) => '},{"DoctorPayoutInvoiceIDP":"',
        );

        debugPrint("Decoded Invoice Data List : " + strData);

        final jsonData = json.decode(strData);

        for (var i = 0; i < jsonData.length; i++) {
          final invoiceList = jsonData[i];

          if (invoiceList.containsKey("Pending Invoice") ||
              invoiceList.containsKey("Paid Invoice")) {
            final invoiceType = invoiceList.keys.first;
            final doctorInvoice = (invoiceList[invoiceType] as List<dynamic>?)
                ?.map(
                    (item) => DoctorInvoice.fromJson(item, source: invoiceType))
                .toList();
            if (doctorInvoice != null) {
              allInvoices.addAll(doctorInvoice);
            }
          }

          debugPrint("----------------------");
        }

        // Add this section to manually set serial numbers
        for (var i = 0; i < allInvoices.length; i++) {
          allInvoices[i].serialNumber = i + 1;
        }

        // Now you have the InvoiceResponse instance, and you can access the invoices as needed.
        // For example, opd invoices: invoiceResponse.invoices[0]['OPD']

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

  void getMyInvoice(String? DoctorPayoutInvoiceIDP, DoctorIDP, type) async {
    print('getDoctorInvoiceList');

    try {
      String loginUrl = "${baseURL}my_invoice_pdf.php";
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
          "DoctorPayoutInvoiceIDP" +
          "\"" +
          ":" +
          "\"" +
          DoctorPayoutInvoiceIDP! +
          "\"," +
          "\"" +
          "DoctorIDP" +
          "\"" +
          ":" +
          "\"" +
          DoctorIDP! +
          "\"" +
          ",\"" +
          "type" +
          "\"" +
          ":" +
          "\"" +
          type! +
          "\"" +
          "}";

      debugPrint(jsonStr);
      // {"DoctorPayoutInvoiceIDP":"959","DoctorIDP":"740","type":"ipd"}

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

        debugPrint("Decoded Invoice Data : " + strData);

        // Parse the JSON string
        List<Map<String, dynamic>> fileList =
            List<Map<String, dynamic>>.from(json.decode(strData));

        // Check if the list is not empty
        if (fileList.isNotEmpty) {
          // Extract the value of the "FileName" key
          String fileName = fileList[0]["FileName"];
          String downloadPdfUrl = baseInvoiceURL + fileName;

          // Show PDF from the fileName using the flutter_pdfview package
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => PdfViewerScreen(url: "https://swasthyasetu.com/ws/images/myinvoice/959.pdf"),
          //   ),
          // );
          debugPrint(downloadPdfUrl);

          Navigator.push(
              context,
              MaterialPageRoute<dynamic>(
                builder: (_) => PDFViewerCachedFromUrl(
                  url: downloadPdfUrl,
                ),
              ));

          // for (var i = 0; i < jsonData.length; i++) {
          //   final invoiceList = jsonData[i];
          //
          //   if (invoiceList.containsKey("Pending Invoice") || invoiceList.containsKey("Paid Invoice")) {
          //     final invoiceType = invoiceList.keys.first;
          //     final doctorInvoice = (invoiceList[invoiceType] as List<dynamic>?)
          //         ?.map((item) => DoctorInvoice.fromJson(item, source: invoiceType))
          //         .toList();
          //     if (doctorInvoice != null) {
          //       allInvoices.addAll(doctorInvoice);
          //     }
          //   }
          //
          //   debugPrint("----------------------");
          // }

          // Now you have the InvoiceResponse instance, and you can access the invoices as needed.
          // For example, opd invoices: invoiceResponse.invoices[0]['OPD']
        }
        setState(() {});
      }
    } catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  void getMyInvoiceVoucher(
      String? DoctorPayoutInvoiceIDP, DoctorIDP, type) async {
    print('getDoctorInvoiceList');

    try {
      String loginUrl = "${baseURL}my_invoice_pdf.php";
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
          "DoctorPayoutInvoiceIDP" +
          "\"" +
          ":" +
          "\"" +
          DoctorPayoutInvoiceIDP! +
          "\"," +
          "\"" +
          "DoctorIDP" +
          "\"" +
          ":" +
          "\"" +
          DoctorIDP! +
          "\"" +
          ",\"" +
          "type" +
          "\"" +
          ":" +
          "\"" +
          type! +
          "\"" +
          "}";

      debugPrint(jsonStr);
      // {"DoctorPayoutInvoiceIDP":"959","DoctorIDP":"740","type":"ipd"}

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

        debugPrint("Decoded Invoice Data : " + strData);

        // Parse the JSON string
        List<Map<String, dynamic>> file1List =
            List<Map<String, dynamic>>.from(json.decode(strData));

        // Check if the list is not empty
        if (file1List.isNotEmpty) {
          // Extract the value of the "FileName" key
          String fileName = file1List[0]["FileName"];
          String downloadPdfUrl = baseInvoiceVoucherURL + fileName;

          // Show PDF from the fileName using the flutter_pdfview package

          debugPrint(downloadPdfUrl);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewerCachedFromUrl(url: downloadPdfUrl),
            ),
          );
        }
        setState(() {});
      }
    } catch (e) {
      print('Error decoding JSON: $e');
    }
  }
}
