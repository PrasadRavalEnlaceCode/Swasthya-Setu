import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silvertouch/api/api_helper.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/model_opd_reg.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import '../utils/color.dart';

List<ModelOPDRegistration> listOPDRegistration = [];
List<ModelOPDRegistration> listOPDRegistrationSelected = [];
List<ModelOPDRegistration> listOPDRegistrationSearchResults = [];

class MakeAPaymentToDoctor extends StatefulWidget {
  final String doctorIDP, doctorImage, fullName, speciality, cityName;

  MakeAPaymentToDoctor(this.doctorIDP, this.doctorImage, this.fullName,
      this.speciality, this.cityName);

  @override
  State<StatefulWidget> createState() {
    return MakeAPaymentToDoctorState();
  }
}

class MakeAPaymentToDoctorState extends State<MakeAPaymentToDoctor> {
  double total = 0;
  String allServicesCommaSeparated = "";
  Icon icon = Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget titleWidget = Text("Select Services to Pay for");
  TextEditingController? searchController;
  var focusNode = new FocusNode();
  ApiHelper apiHelper = ApiHelper();
  bool apiCalled = false;

  @override
  void initState() {
    super.initState();
    getOPDServicesList();
  }

  @override
  void dispose() {
    listOPDRegistration = [];
    listOPDRegistrationSelected = [];
    listOPDRegistrationSearchResults = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: titleWidget,
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(
            color: Colorsblack, size: SizeConfig.blockSizeVertical! * 2.5),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                if (icon.icon == Icons.search) {
                  searchController = TextEditingController(text: "");
                  focusNode.requestFocus();
                  icon = Icon(
                    Icons.cancel,
                    color: Colors.black,
                  );
                  titleWidget = TextField(
                    controller: searchController,
                    focusNode: focusNode,
                    cursorColor: Colors.white,
                    onChanged: (text) {
                      setState(() {
                        listOPDRegistrationSearchResults = listOPDRegistration
                            .where((model) =>
                                model.name!
                                    .toLowerCase()
                                    .contains(text.toLowerCase()) ||
                                model.amount!
                                    .toLowerCase()
                                    .contains(text.toLowerCase()))
                            .toList();
                      });
                    },
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                    ),
                    decoration: InputDecoration(
                      /*hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize:
                          SizeConfig.blockSizeVertical * 2.1),
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize:
                          SizeConfig.blockSizeVertical * 2.1),*/
                      hintText: "Search OPD Procedures",
                    ),
                  );
                } else {
                  icon = Icon(
                    Icons.search,
                    color: Colors.black,
                  );
                  titleWidget = Text("Select Services");
                  listOPDRegistrationSearchResults = listOPDRegistration;
                }
              });
            },
            icon: icon,
          )
        ],
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      bottom: BorderSide(width: 1.0, color: Colors.grey))),
              child: Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 3),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          (widget.doctorImage != "" &&
                                  widget.doctorImage != "null")
                              ? CircleAvatar(
                                  radius: SizeConfig.blockSizeHorizontal! * 6,
                                  backgroundImage: NetworkImage(
                                      "$doctorImgUrl${widget.doctorImage}"))
                              : CircleAvatar(
                                  radius: SizeConfig.blockSizeHorizontal! * 6,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: AssetImage(
                                      "images/ic_user_placeholder.png")),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal! * 3,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.fullName,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 4.2,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical! * 0.5,
                                ),
                                Text(
                                  widget.speciality + " - " + widget.cityName,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 3.3,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ))),
          listOPDRegistration.length > 0 || !apiCalled
              ? Expanded(
                  child: ListView.builder(
                      itemCount: listOPDRegistrationSearchResults.length,
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: EdgeInsets.only(
                                left: SizeConfig.blockSizeHorizontal! * 2,
                                right: SizeConfig.blockSizeHorizontal! * 2,
                                top: SizeConfig.blockSizeHorizontal! * 2),
                            child: InkWell(
                              onTap: () {
                                listOPDRegistrationSearchResults[index]
                                        .isChecked =
                                    !listOPDRegistrationSearchResults[index]
                                        .isChecked!;
                                addOrRemoveData(
                                    listOPDRegistrationSearchResults[index],
                                    listOPDRegistrationSearchResults[index]
                                        .isChecked!);
                              },
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Card(
                                        child: Padding(
                                      padding: EdgeInsets.all(
                                          SizeConfig.blockSizeHorizontal! * 2),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              listOPDRegistrationSearchResults[
                                                      index]
                                                  .name!,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      4,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child: Text(
                                                "${listOPDRegistrationSearchResults[index].amount}/-",
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        3.5,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: SizeConfig
                                                    .blockSizeHorizontal! *
                                                3,
                                          ),
                                          Checkbox(
                                            value:
                                                listOPDRegistrationSearchResults[
                                                        index]
                                                    .isChecked,
                                            onChanged: (bool? isChecked) {
                                              listOPDRegistrationSearchResults[
                                                      index]
                                                  .isChecked = isChecked!;
                                              addOrRemoveData(
                                                  listOPDRegistrationSearchResults[
                                                      index],
                                                  isChecked);
                                            },
                                          ),
                                          /*InkWell(
                                    child: Image(
                                      image: AssetImage(
                                          "images/ic_pdf_opd_reg.png"),
                                      width: SizeConfig.blockSizeHorizontal * 8,
                                    ),
                                  )*/
                                        ],
                                      ),
                                    )),
                                  ),
                                  /*SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 2,
                        ),*/
                                  /*Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: SizeConfig.blockSizeHorizontal * 6,
                        ),*/
                                ],
                              ),
                            ));
                      }),
                )
              : Expanded(
                  child: Center(
                  child: Container(
                    padding:
                        EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage("images/ic_idea_new.png"),
                          width: 100,
                          height: 100,
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Text(
                          "No Services found.",
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                )),
          listOPDRegistrationSearchResults.length > 0 && total > 0
              ? Text(
                  "Total - \u20B9$total",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: SizeConfig.blockSizeHorizontal! * 6.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                )
              : Container(),
          SizedBox(
            height: SizeConfig.blockSizeVertical! * 0.2,
          ),
          listOPDRegistrationSearchResults.length > 0 && total > 0
              ? Text(
                  "additional 18% GST will be added on total upon payment",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                  ),
                )
              : Container(),
          SizedBox(
            height: SizeConfig.blockSizeVertical! * 1.0,
          ),
          listOPDRegistrationSearchResults.length > 0 && total > 0
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      startPayment();
                    },
                    minWidth: double.maxFinite,
                    color: Colors.green,
                    child: Text(
                      "Pay",
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                )
              : Container(),
          InkWell(
            onTap: () {
              startPayment(type: 1);
            },
            /*elevation: 0,
            minWidth: double.maxFinite,
            color: Colors.white,*/
            child: Container(
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 4.0),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                    color: Colors.black,
                    width: 0.8,
                  )),
              child: Text(
                "Pay Without Services",
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: SizeConfig.blockSizeHorizontal! * 3.6,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ).paddingSymmetric(
            vertical: SizeConfig.blockSizeVertical! * 1.5,
          ),
          /*Align(
            alignment: Alignment.topRight,
            child: RawMaterialButton(
              onPressed: () {
                getSelectedListAndGoToAddOPDProcedureScreen(context);
                */ /*Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PatientDashboardScreen()));*/ /*
              },
              elevation: 2.0,
              fillColor: Color(0xFF06A759),
              child: Image(
                width: SizeConfig.blockSizeHorizontal * 5.5,
                height: SizeConfig.blockSizeHorizontal * 5.5,
                //height: 80,
                image: AssetImage("images/ic_right_arrow_triangular.png"),
              ),
              shape: CircleBorder(),
            ),
          ),*/
        ],
      ),
    );
  }

  void getOPDServicesList() async {
    listOPDRegistration = [];
    listOPDRegistrationSearchResults = [];
    String loginUrl = "${baseURL}doctorOnlineOpdServiceList.php";
    ProgressDialog? pr;
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
    String jsonStr = "{" +
        "\"" +
        "DoctorIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.doctorIDP +
        "\"" +
        "," +
        "\"" +
        "PatientIDP" +
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
    apiCalled = true;
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listOPDRegistration.add(ModelOPDRegistration(
            jo['HospitalOPDServcesIDP'].toString(),
            jo['OPDService'],
            jo['Price'].toString(),
            "",
            amountBeforeDiscount: jo['Price'].toString(),
            discount: "0"));
      }
      listOPDRegistrationSearchResults = listOPDRegistration;
      setState(() {});
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

  void getSelectedListAndGoToAddOPDProcedureScreen(BuildContext context) {
    listOPDRegistrationSelected = [];
    listOPDRegistrationSearchResults.forEach((element) {
      if (element.isChecked!) {
        listOPDRegistrationSelected.add(element);
      }
    });
    /*Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddOPDProcedures(
        listOPDRegistrationSelected,
        widget.doctorIDP,
        widget.consultationIDP,
        widget.from,
        appointmentRequestIDP: widget.appointmentRequestIDP,
      );
    })).then((value) {
      Navigator.of(context).pop();
    });*/
  }

  void addOrRemoveData(
      ModelOPDRegistration modelOPDRegistration, bool isChecked) {
    if (isChecked) {
      if (allServicesCommaSeparated == "") {
        allServicesCommaSeparated = modelOPDRegistration.name!;
        total = total + double.parse(modelOPDRegistration.amount!);
      } else {
        if (!allServicesCommaSeparated.contains(modelOPDRegistration.name!)) {
          allServicesCommaSeparated =
              "$allServicesCommaSeparated, ${modelOPDRegistration.name}";
          total = total + double.parse(modelOPDRegistration.amount!);
        }
      }
    } else {
      allServicesCommaSeparated = allServicesCommaSeparated
          .replaceAll(", ${modelOPDRegistration.name}", "")
          .replaceAll(modelOPDRegistration.name!, "");
      total = total - double.parse(modelOPDRegistration.amount!);
    }
    if (allServicesCommaSeparated.startsWith(","))
      allServicesCommaSeparated =
          allServicesCommaSeparated.replaceFirst(",", "");
    if (allServicesCommaSeparated.endsWith(","))
      allServicesCommaSeparated = allServicesCommaSeparated.replaceRange(
          allServicesCommaSeparated.length - 1, 1, "");
    allServicesCommaSeparated = allServicesCommaSeparated.trim();
    debugPrint("Total and Comma Seperated string");
    debugPrint(total.toString());
    debugPrint(allServicesCommaSeparated);
    setState(() {});
  }

  void startPayment({type = 0}) async {
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint(
        "${baseURL}paymentgatewayPaytoDoctor.php?amount=${total.toString()}&idp=${widget.doctorIDP}&idppt=$patientIDP&servicestring=$allServicesCommaSeparated");

    if (type == 0) {
      goToWebview(context, "",
          "${baseURL}paymentgatewayPaytoDoctor.php?amount=${total.toString()}&idp=${widget.doctorIDP}&idppt=$patientIDP&servicestring=$allServicesCommaSeparated");
    } else if (type == 1) {
      goToWebview(context, "",
          "${baseURL}paymentgatewayPaytoDoctorDirect.php?idp=${widget.doctorIDP}&idppt=$patientIDP");
    }
  }
}

goToWebview(BuildContext context, String iconName, String webView) {
  // PaymentWebViewController paymentWebViewController =
  //     Get.put(PaymentWebViewController());
  // String webViewUrl = Uri.encodeFull(webView);
  // paymentWebViewController.url.value = webViewUrl;
  // debugPrint("encoded url :- $webViewUrl");
  //
  // if (webView != "") {
  //   debugPrint(
  //       "swasthya setu failure url :- ${baseURL.replaceFirst("www", "")}failure.php");
  //   final flutterWebViewPlugin = FlutterWebviewPlugin();
  //   flutterWebViewPlugin.onUrlChanged.listen((url) {
  //     debugPrint(url);
  //     paymentWebViewController.url.value = url;
  //   });
  //   flutterWebViewPlugin.onDestroy.listen((_) {
  //     if (Navigator.canPop(context)) {
  //       Navigator.of(context).pop();
  //     }
  //   });
  //   Navigator.push(context, MaterialPageRoute(builder: (mContext) {
  //     return new MaterialApp(
  //       debugShowCheckedModeBanner: false,
  //       theme: ThemeData(fontFamily: "Ubuntu", primaryColor: Color(0xFF06A759)),
  //       routes: {
  //         "/": (_) => Obx(() => WebviewScaffold(
  //               withLocalStorage: true,
  //               withJavascript: true,
  //               url: webViewUrl,
  //               appBar:
  //                   paymentWebViewController.url.value.contains(
  //                               "swasthyasetu.com/ws/failurePaytoDoctor.php") ||
  //                           paymentWebViewController.url.value.contains(
  //                               "swasthyasetu.com/ws/successPaytoDoctor.php") ||
  //                           paymentWebViewController.url.value.contains(
  //                               "swasthyasetu.com/ws/paymentgatewayPaytoDoctorDirect.php") ||
  //                           paymentWebViewController.url.value.contains(
  //                               "swasthyasetu.com/ws/failurePayDuetoDoctor.php") ||
  //                           paymentWebViewController.url.value.contains(
  //                               "swasthyasetu.com/ws/successPayDuetoDoctor.php")
  //                       ? AppBar(
  //                           backgroundColor: Colors.white,
  //                           title: Text(iconName),
  //                           leading: IconButton(
  //                               icon: Icon(
  //                                 Platform.isAndroid
  //                                     ? Icons.arrow_back
  //                                     : Icons.arrow_back_ios,
  //                                 color: Colors.black,
  //                                 size: SizeConfig.blockSizeHorizontal * 8.0,
  //                               ),
  //                               onPressed: () {
  //                                 if (paymentWebViewController.url.value.contains(
  //                                         "swasthyasetu.com/ws/failurePaytoDoctor.php") ||
  //                                     paymentWebViewController.url.value.contains(
  //                                         "swasthyasetu.com/ws/failurePayDuetoDoctor.php"))
  //                                   Navigator.of(context).pop();
  //                                 else if (paymentWebViewController.url.value
  //                                         .contains(
  //                                             "swasthyasetu.com/ws/successPaytoDoctor.php") ||
  //                                     paymentWebViewController.url.value.contains(
  //                                         "swasthyasetu.com/ws/successPayDuetoDoctor.php")) {
  //                                   Navigator.of(context).pop();
  //                                   Navigator.of(context).pop();
  //                                 } else if (paymentWebViewController.url.value
  //                                     .contains(
  //                                         "swasthyasetu.com/ws/paymentgatewayPaytoDoctorDirect.php")) {
  //                                   Navigator.of(context).pop();
  //                                 }
  //                                 /*Navigator.pushAndRemoveUntil(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                     builder: (context) =>
  //                                         CheckExpiryBlankScreen(
  //                                             "", "coupon", false, null)),
  //                                 (Route<dynamic> route) => false);*/
  //                               }),
  //                           iconTheme: IconThemeData(
  //                               color: Colors.white,
  //                               size: SizeConfig.blockSizeVertical * 2.2),
  //                           textTheme: TextTheme(
  //                               subtitle1: TextStyle(
  //                                   color: Colors.white,
  //                                   fontFamily: "Ubuntu",
  //                                   fontSize:
  //                                       SizeConfig.blockSizeVertical * 2.3)),
  //                         )
  //                       : PreferredSize(
  //                           child: Container(),
  //                           preferredSize: Size(SizeConfig.screenWidth, 0),
  //                         ),
  //             )),
  //       },
  //     );
  //   }));
  // }
}
