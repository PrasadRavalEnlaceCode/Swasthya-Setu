import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swasthyasetu/app_screens/investigation_list_read_only_screen.dart';
import 'package:swasthyasetu/app_screens/select_opd_procedures_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/model_opd_reg.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/widgets/extensions.dart';

import '../utils/color.dart';
import '../utils/progress_dialog.dart';
import 'opd_registration_screen.dart';

int total = 0;
int netPrice = 0;
int? _radioValuePaymentMode = 0;
int? _radioValuePaymentStatus = 0;
TextEditingController paymentNarrationController = TextEditingController();

TextEditingController entryDateController = new TextEditingController();
TextEditingController totalDiscountController = TextEditingController();
var pickedDate = DateTime.now();
var pickedTime = TimeOfDay.now();

class AddOPDProcedures extends StatefulWidget {
  List<ModelOPDRegistration> listOPDRegistrationSelected;
  String patientIDP, consultationIDP, from;
  var campID;

  AddOPDProcedures(this.listOPDRegistrationSelected, this.patientIDP,
      this.consultationIDP, this.from,
      {this.campID});

  @override
  State<StatefulWidget> createState() {
    return AddOPDProceduresState();
  }
}

class AddOPDProceduresState extends State<AddOPDProcedures> {
  @override
  void initState() {
    super.initState();
    var pickedDate = DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(pickedDate);
    entryDateController = TextEditingController(text: formatted);
    totalDiscountController = TextEditingController();
    total = 0;
    netPrice = 0;
    for (int i = 0; i < widget.listOPDRegistrationSelected.length; i++) {
      total = total +
          double.parse(widget.listOPDRegistrationSelected[i].amount!).round();
    }
    netPrice = total;
  }

  @override
  void dispose() {
    widget.listOPDRegistrationSelected = [];
    total = 0;
    netPrice = 0;
    _radioValuePaymentMode = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Payment"),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(color: Colorsblack), toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(
          color: Colorsblack,
          fontFamily: "Ubuntu",
          fontSize: SizeConfig.blockSizeVertical !* 2.5,
        )).bodyMedium, titleTextStyle: TextTheme(
            titleMedium: TextStyle(
          color: Colorsblack,
          fontFamily: "Ubuntu",
          fontSize: SizeConfig.blockSizeVertical !* 2.5,
        )).titleLarge,
      ),
      body: Builder(
        builder: (context) {
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                    itemCount: widget.listOPDRegistrationSelected.length,
                    itemBuilder: (context, index) {
                      return OPDProcedureItem(index, callBackFn,
                          widget.listOPDRegistrationSelected[index]);
                    }),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 0.5,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  child: Padding(
                      padding: EdgeInsets.only(
                        left: SizeConfig.blockSizeHorizontal !* 2,
                        right: SizeConfig.blockSizeHorizontal !* 2,
                        top: SizeConfig.blockSizeVertical !* 1.0,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Total Price : ${total.toString()}/-",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                              ),
                            ).pO(
                              right: SizeConfig.blockSizeHorizontal !* 2.0,
                            ),
                            Container(
                              width: SizeConfig.blockSizeHorizontal !* 22,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                maxLength: 5,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: SizeConfig.blockSizeVertical !* 2.1),
                                controller: totalDiscountController,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.1),
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeVertical !* 2.1),
                                  labelText: "Discount",
                                  hintText: "",
                                  counterText: "",
                                ),
                                onChanged: (text) {
                                  textChangedTotalDiscount();
                                },
                              ),
                            ).pO(
                              right: SizeConfig.blockSizeHorizontal !* 2.0,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Net Total : ${netPrice.toString()}/-",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(width: 1.5, color: Colors.grey))),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 2),
                  child: InkWell(
                    onTap: () {
                      showDateSelectionDialog();
                    },
                    child: Container(
                      child: IgnorePointer(
                        child: TextField(
                          controller: entryDateController,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeVertical !* 2.1),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.1),
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeVertical !* 2.1),
                            labelText: "OPD Date",
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: SizeConfig.blockSizeHorizontal !* 2,
                    right: SizeConfig.blockSizeHorizontal !* 2),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Payment Status',
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal !* 4.3,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockSizeHorizontal !* 3),
                    child: Row(
                      children: <Widget>[
                        Radio(
                          value: 0,
                          groupValue: _radioValuePaymentStatus,
                          onChanged: _handleRadioValueChangePaymentStatus,
                        ),
                        Text('Paid'),
                        Radio(
                          value: 1,
                          groupValue: _radioValuePaymentStatus,
                          onChanged: _handleRadioValueChangePaymentStatus,
                        ),
                        Text('Pending'),
                      ],
                    )),
              ),
              _radioValuePaymentStatus == 0
                  ? Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.blockSizeHorizontal !* 2,
                          right: SizeConfig.blockSizeHorizontal !* 2),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Payment Mode',
                          style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal !* 4.3,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  : Container(),
              _radioValuePaymentStatus == 0
                  ? Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockSizeHorizontal !* 3),
                          child: Row(
                            children: <Widget>[
                              Radio(
                                value: 0,
                                groupValue: _radioValuePaymentMode,
                                onChanged: _handleRadioValueChangePaymentMode,
                              ),
                              Text('Cash'),
                              Radio(
                                value: 1,
                                groupValue: _radioValuePaymentMode,
                                onChanged: _handleRadioValueChangePaymentMode,
                              ),
                              Text('Cheque'),
                            ],
                          )),
                    )
                  : Container(),
              Padding(
                  padding:
                      EdgeInsets.only(left: SizeConfig.blockSizeHorizontal !* 2),
                  child: Visibility(
                    visible: _radioValuePaymentMode == 1,
                    child: TextField(
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: SizeConfig.blockSizeVertical !* 2.1),
                      controller: paymentNarrationController,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: SizeConfig.blockSizeVertical !* 2.1),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: SizeConfig.blockSizeVertical !* 2.1),
                        labelText: "Payment Narration",
                        hintText: "",
                        counterText: "",
                      ),
                    ),
                  )),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 2.0,
                  ),
                  child: RawMaterialButton(
                    onPressed: () {
                      submitAllTheData(context);
                    },
                    elevation: 2.0,
                    fillColor: Color(0xFF06A759),
                    child: Image(
                      width: SizeConfig.blockSizeHorizontal !* 5.5,
                      height: SizeConfig.blockSizeHorizontal !* 5.5,
                      //height: 80,
                      image: AssetImage("images/ic_right_arrow_triangular.png"),
                    ),
                    shape: CircleBorder(),
                  ),
                  /*),*/
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void textChangedTotalDiscount() {
    String priceString = total.toString();
    String discountString = totalDiscountController.text;

    double price = total.toDouble();
    double discount = 0;
    if (discountString != "") discount = double.parse(discountString);
    double totalLocal = price - discount;

    netPrice = totalLocal.round();
    setState(() {});
  }

  void showDateSelectionDialog() async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    DateTime firstDate = DateTime.now().subtract(Duration(days: 365 * 100));
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: pickedDate,
        firstDate: firstDate,
        lastDate: DateTime.now());

    if (date != null) {
      pickedDate = date;
      var formatter = new DateFormat('dd-MM-yyyy');
      String formatted = formatter.format(pickedDate);
      entryDateController = TextEditingController(text: formatted);
      setState(() {});
    }
  }

  _handleRadioValueChangePaymentMode(int? value) {
    setState(() {
      _radioValuePaymentMode = value!;
    });
  }

  _handleRadioValueChangePaymentStatus(int? value) {
    setState(() {
      _radioValuePaymentStatus = value!;
    });
  }

  void callBackFn() {
    total = 0;
    for (int i = 0; i < widget.listOPDRegistrationSelected.length; i++) {
      total = total +
          double.parse(widget.listOPDRegistrationSelected[i].amount!).round();
    }
    textChangedTotalDiscount();
    //setState(() {});
  }

  void submitAllTheData(BuildContext context) async {
    var jArrayOPDProcedures = "[";
    for (var i = 0; i < widget.listOPDRegistrationSelected.length; i++) {
      //if (listInvestigationMaster[i].isChecked) {
      jArrayOPDProcedures =
          "$jArrayOPDProcedures{\"HospitalOPDServcesIDF\":\"${listOPDRegistrationSelected[i].idp}\",\"Price\":\"${listOPDRegistrationSelected[i].amountBeforeDiscount}\",\"Discount\":\"${listOPDRegistrationSelected[i].discount}\",\"Total\":\"${listOPDRegistrationSelected[i].amount}\"},";
      //}
    }
    jArrayOPDProcedures = jArrayOPDProcedures + "]";
    jArrayOPDProcedures = jArrayOPDProcedures.replaceAll(",]", "]");

    String loginUrl = "";
    if (widget.from == "existing")
      loginUrl = "${baseURL}doctorOpdAdded.php";
    else if (widget.from == "notification")
      loginUrl = "${baseURL}appointmentacceptremove.php";
    else
      loginUrl = "${baseURL}doctorOpdSave.php";
    ProgressDialog pr;
    pr = ProgressDialog(context);
    pr.show();
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String paymentStatus = "";
    if (_radioValuePaymentStatus == 0)
      paymentStatus = "0";
    else
      paymentStatus = "1";
    String paymentMode = "";
    if (_radioValuePaymentMode == 0)
      paymentMode = "Cash";
    else
      paymentMode = "Cheque";

    String unCommonParameter = "";
    print('widget.from ${widget.from}');
    if (widget.from == "existing") {
      unCommonParameter = "," +
          "\"" +
          "HospitalConsultationIDF" +
          "\"" +
          ":" +
          "\"" +
          widget.consultationIDP +
          "\"";
    }
    // else if (widget.from == "notification") {
    //   unCommonParameter = "," +
    //       "\"OPDDate\":\"${entryDateController.text}\"," +
    //       "\"AppoinmentRequestIDP\":\"${widget.appointmentRequestIDP}\"," +
    //       "\"RemoveStatus\":\"0\"";
    // }
    else {
      unCommonParameter = "," +
          "\"" +
          "OPDDate" +
          "\"" +
          ":" +
          "\"" +
          entryDateController.text +
          "\"";
    }
    var campID = '';
    if (widget.campID != '') campID = widget.campID.toString();

    String totalDiscount = "";
    if (totalDiscountController.text.trim().isEmpty)
      totalDiscount = "0";
    else
      totalDiscount = totalDiscountController.text;


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
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP +
        "\"" +
        "," +
        "\"" +
        "PaymentStatus" +
        "\"" +
        ":" +
        "\"" +
        paymentStatus +
        "\"" +
        "," +
        "\"" +
        "PaymentMode" +
        "\"" +
        ":" +
        "\"" +
        paymentMode +
        "\"" +
        unCommonParameter +
        "," +
        "\"" +
        "PaymentDetails" +
        "\"" +
        ":" +
        "\"" +
        paymentNarrationController.text +
        "\"" +
        "," +
        "\"consultationdata" +
        "\"" +
        ":" +
        jArrayOPDProcedures +
        "," +
        "\"discount" +
        "\"" +
        ":" +
        "\"" +
        totalDiscount +
        "\"" +
        "," +
        "\"DoctorCampIDF" +
        "\"" +
        ":" +
        "\"" +
        campID +
        "\"" +
        "}";

    // String jsonStr = "{" +
    //       "\"" + "DoctorIDP" + "\"" + ":" + "1" + "," +
    //       "\"" + "PatientIDP" + "\"" + ":" + "736" + "," +
    //       "\"" + "PaymentStatus" + "\"" + ":" + "0" + "," +
    //       "\"" + "PaymentMode" + "\"" + ":" + "Cash" +
    //       "\"" + "HospitalConsultationIDF" + "\"" + ":" + "43741" +
    //       "\"" + "OPDDate" + ":" + "22-08-2023" + "," +
    //       "\"" + "PaymentDetails" + ":" + "" + "," +
    //       "\"" + "consultationdata" + "\"" + ":" + "[{\""+ "HospitalOPDServcesIDF" + "\"" + ":" +"1" + "," +
    //       "\"" + "Price" + "\"" + ":" + "250.00" + "," +
    //       "\"" + "Discount" + "\"" + ":" + "0" + "\"" + "," +
    //       "\"" + "Total" + "\"" + ":" + "250.00" + "}]," +
    //       "\"" + "discount" + "\"" + ":" + "0" + "," +
    //       "\"" + "DoctorCampIDF" + "\"" + ":" + "" +
    //       "}";

    print(loginUrl);
    print(jsonStr);
    String encodedJSONStr = encodeBase64(jsonStr);
    debugPrint(encodedJSONStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: loginUrl,
      //Uri.parse(loginUrl),
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
      /*var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      listInvestigationMaster = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listInvestigationMaster.add(ModelInvestigationMaster(
          jo['PreInvestTypeIDP'].toString(),
          jo['GroupType'],
          jo['GroupName'],
          jo['InvestigationType'],
          jo['RangeValue'],
          false,
        ));
      }*/
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(
          Duration(
            seconds: 1,
          ), () {
        if (widget.from == "selectedPatient") {
          /*print("go to opd reg screen with replacement");
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return OPDRegistrationScreen();
          }));*/
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => OPDRegistrationScreen()));
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => OPDRegistrationScreen()));
        }
      });
    } else if (model.status == "Error") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

class OPDProcedureItem extends StatefulWidget {
  int index;
  Function() callBackFn;
  ModelOPDRegistration modelOPDRegistration;

  OPDProcedureItem(this.index, this.callBackFn, this.modelOPDRegistration);

  @override
  State<StatefulWidget> createState() {
    return OPDProcedureItemState();
  }
}

class OPDProcedureItemState extends State<OPDProcedureItem> {
  TextEditingController priceController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController totalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint("init item");
    priceController = TextEditingController(
        text: double.parse(widget.modelOPDRegistration.amountBeforeDiscount!)
            .round()
            .toString());
    discountController = TextEditingController(
        text: double.parse(widget.modelOPDRegistration.discount!)
            .round()
            .toString());
    totalController = TextEditingController(
        text: double.parse(widget.modelOPDRegistration.amount!)
            .round()
            .toString());
  }

  @override
  void dispose() {
    debugPrint("dispose item");
    priceController.clear();
    discountController.clear();
    totalController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.blockSizeHorizontal !* 4,
            right: SizeConfig.blockSizeHorizontal !* 4,
            top: SizeConfig.blockSizeHorizontal !* 2,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "${widget.index + 1}. ${widget.modelOPDRegistration.name}",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal !* 4,
              right: SizeConfig.blockSizeHorizontal !* 4,
              top: SizeConfig.blockSizeHorizontal !* 2,
              bottom: SizeConfig.blockSizeHorizontal !* 2),
          child: Row(children: <Widget>[
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                maxLength: 5,
                style: TextStyle(
                    color: Colors.green,
                    fontSize: SizeConfig.blockSizeVertical !* 2.1),
                controller: priceController,
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.blockSizeVertical !* 2.1),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.blockSizeVertical !* 2.1),
                  labelText: "Price",
                  hintText: "",
                  counterText: "",
                ),
                onChanged: (text) {
                  textChanged(widget.index);
                },
              ),
            ),
            SizedBox(
              width: SizeConfig.blockSizeHorizontal !* 3,
            ),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                maxLength: 5,
                style: TextStyle(
                    color: Colors.green,
                    fontSize: SizeConfig.blockSizeVertical !* 2.1),
                controller: discountController,
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.blockSizeVertical !* 2.1),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.blockSizeVertical !* 2.1),
                  labelText: "Discount",
                  hintText: "",
                  counterText: "",
                ),
                onChanged: (text) {
                  textChanged(widget.index);
                },
              ),
            ),
            SizedBox(
              width: SizeConfig.blockSizeHorizontal !* 3,
            ),
            Expanded(
                child: IgnorePointer(
              child: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                maxLength: 5,
                style: TextStyle(
                    color: Colors.green,
                    fontSize: SizeConfig.blockSizeVertical !* 2.1),
                controller: totalController,
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.blockSizeVertical !* 2.1),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.blockSizeVertical !* 2.1),
                  labelText: "Total",
                  hintText: "",
                  counterText: "",
                ),
                onChanged: (text) {
                  textChanged(widget.index);
                },
              ),
            ))
          ]),
        )
      ],
    );
  }

  void textChanged(int index) {
    String priceString = priceController.text;
    String discountString = discountController.text;
    String totalString = totalController.text;

    double price = double.parse(priceString);
    double discount = double.parse(discountString);
    double totalOld = double.parse(totalString);
    double totalLocal = price - discount;

    //totalController = TextEditingController(text: totalLocal.toString());
    widget.modelOPDRegistration.amountBeforeDiscount = price.toString();
    widget.modelOPDRegistration.discount = discount.toString();
    widget.modelOPDRegistration.amount = totalLocal.toString();
    //priceController = TextEditingController(text: price.round().toString());
    /*discountController =
        TextEditingController(text: discount.round().toString());*/
    totalController =
        TextEditingController(text: totalLocal.round().toString());
    //total = (total - totalOld + totalLocal).round();
    setState(() {});
    widget.callBackFn();
  }
}
