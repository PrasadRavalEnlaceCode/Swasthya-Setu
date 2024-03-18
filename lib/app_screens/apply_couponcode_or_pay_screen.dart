import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:silvertouch/app_screens/patient_dashboard_screen.dart';
import 'package:silvertouch/controllers/apply_coupon_controller.dart';
import 'package:silvertouch/enums/coupon_code_states.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';
import 'package:http/http.dart' as http;

String PAYTM_MERCHANT_ID = "lXSUMo99907202227729";
String PAYTM_MERCHANT_KEY = "uEibltmh#q11O9es";
String website = "WEBSTAGING";
bool testing = true;

class ApplyCouponCodeOrPayScreen extends StatelessWidget {
  final String doctorIDP;
  final TextEditingController couponCodeController = TextEditingController();

  ApplyCouponCodeOrPayScreen(this.doctorIDP);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ApplyCouponController applyCouponController =
        Get.put(ApplyCouponController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
          size: SizeConfig.blockSizeVertical! * 2.2,
        ),
        elevation: 0,
        toolbarTextStyle: TextTheme(
          titleMedium: TextStyle(
              color: Colors.white,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical! * 2.3),
        ).bodyMedium,
        titleTextStyle: TextTheme(
          titleMedium: TextStyle(
              color: Colors.white,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical! * 2.3),
        ).titleLarge,
      ),
      body: Builder(
        builder: (context) {
          return ColoredBox(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      SizedBox(
                        height: SizeConfig.blockSizeVertical! * 1.0,
                      ),
                      Obx(
                        () => Text(
                          "Pay \u20B9${applyCouponController.netAmount.value}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: SizeConfig.blockSizeHorizontal! * 8.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.0,
                            height: 1.0,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical! * 0.5,
                      ),
                      Text(
                        "(Including GST)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                          letterSpacing: 2.0,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical! * 1.0,
                      ),
                      Text(
                        "to proceed",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal! * 5.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.0,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical! * 6.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
                        ),
                        child: Text(
                          "Do you have coupon code?",
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical! * 1.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Stack(
                              children: [
                                applyCouponController.couponCodeState.value ==
                                        CouponCodeStates.valid
                                    ? IgnorePointer(
                                        child: TextField(
                                        controller: couponCodeController,
                                        decoration: new InputDecoration(
                                          border: new OutlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Colors.teal)),
                                          labelText: "Coupon Code",
                                          hintText: "",
                                          helperText: "Coupon Code applied.",
                                          /*helperStyle: TextStyle(color: Colors.black, fontSize: SizeConfig.blockSizeHorizontal*3.0,),*/
                                          prefixIcon: Padding(
                                            padding: EdgeInsets.all(
                                              SizeConfig.blockSizeHorizontal! *
                                                  2.3,
                                            ),
                                            child: Image(
                                              image: AssetImage(
                                                  "images/ic_coupon_code.png"),
                                              width: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  2.0,
                                              height: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  2.0,
                                            ),
                                          ),
                                        ),
                                      ))
                                    : TextField(
                                        controller: couponCodeController,
                                        decoration: new InputDecoration(
                                          border: new OutlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Colors.teal)),
                                          labelText: "Coupon Code",
                                          hintText: "",
                                          helperText:
                                              "Enter coupon code to get instant discounts.",
                                          /*helperStyle: TextStyle(color: Colors.black, fontSize: SizeConfig.blockSizeHorizontal*3.0,),*/
                                          prefixIcon: Padding(
                                            padding: EdgeInsets.all(
                                              SizeConfig.blockSizeHorizontal! *
                                                  2.3,
                                            ),
                                            child: Image(
                                              image: AssetImage(
                                                  "images/ic_coupon_code.png"),
                                              width: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  2.0,
                                              height: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                applyCouponController.couponCodeState.value ==
                                        CouponCodeStates.valid
                                    ? Positioned(
                                        right: 0,
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal! *
                                                2.3,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              debugPrint("reset everything");
                                              applyCouponController
                                                  .resetEverything();
                                              couponCodeController.text = "";
                                              FocusScope.of(context).unfocus();
                                            },
                                            child: Image(
                                              image: AssetImage(
                                                  "images/ic_cancel.png"),
                                              color: Colors.red,
                                              width: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  8.0,
                                              height: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  8.0,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            )),
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal! * 3.0,
                            ),
                            Obx(
                              () => Align(
                                alignment: Alignment.centerRight,
                                child: Theme(
                                  data: ThemeData(
                                    splashColor: applyCouponController
                                                .couponCodeState.value !=
                                            CouponCodeStates.valid
                                        ? Colors.grey
                                        : Colors.transparent,
                                    highlightColor: applyCouponController
                                                .couponCodeState.value !=
                                            CouponCodeStates.valid
                                        ? Colors.grey
                                        : Colors.transparent,
                                  ),
                                  child: MaterialButton(
                                    onPressed: () {
                                      if (applyCouponController
                                              .couponCodeState.value !=
                                          CouponCodeStates.valid)
                                        validateCoupon(
                                            context, applyCouponController);
                                    },
                                    color: applyCouponController
                                                .couponCodeState.value !=
                                            CouponCodeStates.valid
                                        ? Colors.black
                                        : Colors.grey,
                                    child: Text(
                                      "Apply",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! *
                                                4.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: applyCouponController.discountAmount.value == 0
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "You Will Pay : ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! *
                                                5.0,
                                      ),
                                    ),
                                    Obx(
                                      () => Text(
                                        "${applyCouponController.amount} + ${applyCouponController.gst}% GST = ${applyCouponController.netAmount}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal! *
                                                  5.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Total Amount : ",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.0,
                                          ),
                                        ),
                                        Obx(
                                          () => Text(
                                            "\u20B9${applyCouponController.amount.value + applyCouponController.gst.value}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  4.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height:
                                          SizeConfig.blockSizeVertical! * 0.3,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "- Discount : ",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.0,
                                          ),
                                        ),
                                        Obx(
                                          () => Text(
                                            "\u20B9${applyCouponController.discountAmount}",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  4.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height:
                                          SizeConfig.blockSizeVertical! * 0.5,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        width: SizeConfig.blockSizeHorizontal! *
                                            50,
                                        height: 2.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          SizeConfig.blockSizeVertical! * 0.5,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "You Will Pay : ",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                5.0,
                                          ),
                                        ),
                                        Obx(
                                          () => Text(
                                            "${applyCouponController.netAmount}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  5.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 1.0,
                        ),
                        MaterialButton(
                            minWidth: SizeConfig.screenWidth,
                            onPressed: () {
                              if (applyCouponController.netAmount.value == 0) {
                                submitCoupon(context, applyCouponController);
                              } else {
                                openPayment(context, applyCouponController);
                              }
                            },
                            color: Colors.green,
                            child: Padding(
                              padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 3.0,
                              ),
                              child: Text(
                                "Proceed",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal! * 4.5,
                                ),
                              ),
                            )),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 1.0,
                        ),
                      ],
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  void validateCoupon(
      BuildContext context, ApplyCouponController applyCouponController) async {
    if (couponCodeController.text.trim().isEmpty) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please Enter Coupon Code to apply"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      /*Get.snackbar(
        "Please Enter Coupon Code to apply.",
        "",
        backgroundColor: Colors.red,
        titleText: null,
        colorText: Colors.white,
      );*/
      return;
    }
    String loginUrl = "${baseURL}patientCouponCheck.php";
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
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"" +
        "couponcode" +
        "\"" +
        ":" +
        "\"" +
        couponCodeController.text +
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      applyCouponController.discountAmount.value =
          int.parse(jsonData[0]['amount']) ?? 0;
      applyCouponController.countNetAmount();
    } else {
      applyCouponController.resetEverything();
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      /*Get.snackbar(
        model.message,
        "",
        backgroundColor: Colors.red,
        titleText: null,
        messageText: Text(""),
        colorText: Colors.white,
      );*/
    }
  }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    //var base64str =
    return base64.encode(bytes);
    //= Base64Encoder().convert()
  }

  String decodeBase64(String text) {
    //var bytes = utf8.encode(text);
    //var base64str =
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
    //= Base64Encoder().convert()
  }

  void submitCoupon(
      BuildContext context, ApplyCouponController applyCouponController) async {
    String loginUrl = "${baseURL}patientCouponSubmit.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDP +
        "\"" +
        "," +
        "\"" +
        "couponcode" +
        "\"" +
        ":" +
        "\"" +
        couponCodeController.text +
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
    debugPrint(response.body.toString());
    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);
    pr!.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return PatientDashboardScreen(doctorIDP);
      }), (Route<dynamic> route) => false).then((value) {
        Navigator.of(context).pop();
      });
      /*final jsonData = json.decode(strData);
      applyCouponController.discountAmount.value =
          int.parse(jsonData[0]['amount']) ?? 0;
      applyCouponController.countNetAmount();*/
    } else {
      //applyCouponController.resetEverything();
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void startPaymentProcess(int mode, int amount) async {
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    String callBackUrl = (testing
            ? 'https://securegw-stage.paytm.in'
            : 'https://securegw.paytm.in') +
        '/theia/paytmCallback?ORDER_ID=' +
        orderId;

    //Host the Server Side Code on your Server and use your URL here. The following URL may or may not work. Because hosted on free server.
    //Server Side code url: https://github.com/mrdishant/Paytm-Plugin-Server
    var url = '${baseURL}paytm_checksum.php';

    var body = json.encode({
      "mid": PAYTM_MERCHANT_ID,
      "key_secret": PAYTM_MERCHANT_KEY,
      "orderId": orderId,
      "website": website,
      "amount": amount.toString(),
      "callbackUrl": callBackUrl,
      "custId": "122",
      "mode": mode.toString(),
      "testing": testing ? 0 : 1
    });

    /*"key_secret": PAYTM_MERCHANT_KEY,
    "website": website,
    "amount": amount.toString(),
      "callbackUrl": callBackUrl,
      "custId": "122",
      "mode": mode.toString(),
      "testing": testing ? 0 : 1
    */

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
        headers: {'Content-type': "application/json"},
      );
      print("Response is");
      print(response.body);
      String txnToken = response.body;
      /*setState(() {
        payment_response = txnToken;
      });*/

      /*var paytmResponse = Paytm.payWithPaytm(
          mid, orderId, txnToken, amount.toString(), callBackUrl, testing);*/
      debugPrint("Printing everything...");
      debugPrint(PAYTM_MERCHANT_ID);
      debugPrint(orderId);
      debugPrint(txnToken);
      debugPrint(amount.toString());
      debugPrint(callBackUrl);
      debugPrint(testing.toString());
      try {
        var response = AllInOneSdk.startTransaction(PAYTM_MERCHANT_ID, orderId,
            amount.toString(), txnToken, null!, true, false);
      } catch (err) {
        debugPrint("Paytm general catch");
        // debugPrint(err.message);
        /*payment_response = err.message;*/
      }
    } catch (e) {
      //print(e);
      debugPrint("Paytm final catch");
      debugPrint(e.toString());
    }
  }

  void openPayment(
      BuildContext context, ApplyCouponController applyCouponController) async {
    String patientIDP = await getPatientOrDoctorIDP();
    /*Get.bottomSheet(Material(
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 5.0),
        child: Column(
          children: [
            Text(
              "Select Payment Method",
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: SizeConfig.blockSizeHorizontal * 4.5,
              ),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical * 2.0,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        startPaymentProcess(
                            0, applyCouponController.netAmount.value);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "images/ic_payment_wallet.png",
                            width: SizeConfig.blockSizeHorizontal * 15.0,
                            height: SizeConfig.blockSizeHorizontal * 15.0,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 2.0,
                          ),
                          Text(
                            "Paytm Wallet",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        startPaymentProcess(
                            1, applyCouponController.netAmount.value);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "images/ic_payment_net_banking.png",
                            width: SizeConfig.blockSizeHorizontal * 15.0,
                            height: SizeConfig.blockSizeHorizontal * 15.0,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 2.0,
                          ),
                          Text(
                            "Net Banking",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical * 5.0,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        startPaymentProcess(
                            2, applyCouponController.netAmount.value);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "images/ic_payment_upi.png",
                            width: SizeConfig.blockSizeHorizontal * 15.0,
                            height: SizeConfig.blockSizeHorizontal * 15.0,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 2.0,
                          ),
                          Text(
                            "UPI",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        startPaymentProcess(
                            3, applyCouponController.netAmount.value);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "images/ic_payment_credit_card.png",
                            width: SizeConfig.blockSizeHorizontal * 15.0,
                            height: SizeConfig.blockSizeHorizontal * 15.0,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 2.0,
                          ),
                          Text(
                            "Credit Card",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));*/
    goToWebview(context, "",
        "${baseURL}paymentgateway.php?amount=${applyCouponController.netAmount}&idp=$patientIDP&couponcode=${couponCodeController.text}");
  }
}

// commented by ashwini for library issues - flutter_webview_plugin
goToWebview(BuildContext context, String iconName, String webView) {
  // PaymentWebViewController paymentWebViewController =
  //     Get.put(PaymentWebViewController());
  // paymentWebViewController.url.value = webView;
  // if (webView != "") {
  //   debugPrint(
  //       "swasthya setu failure url :- ${baseURL.replaceFirst("www", "")}failure.php");
  //   final flutterWebViewPlugin = FlutterWebviewPlugin();
  //   flutterWebViewPlugin.onUrlChanged.listen((url) {
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
  //               url: webView,
  //               appBar: paymentWebViewController.url.value
  //                           .contains("swasthyasetu.com/ws/failure.php") ||
  //                       paymentWebViewController.url.value
  //                           .contains("swasthyasetu.com/ws/success.php")
  //                   ? AppBar(
  //                       backgroundColor: Colors.white,
  //                       title: Text(iconName),
  //                       leading: IconButton(
  //                           icon: Icon(
  //                             Platform.isAndroid
  //                                 ? Icons.arrow_back
  //                                 : Icons.arrow_back_ios,
  //                             color: Colors.black,
  //                             size: SizeConfig.blockSizeHorizontal * 8.0,
  //                           ),
  //                           onPressed: () {
  //                             Navigator.pushAndRemoveUntil(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                     builder: (context) =>
  //                                         CheckExpiryBlankScreen(
  //                                             "", "coupon", false, null)),
  //                                 (Route<dynamic> route) => false);
  //                             //Navigator.of(context).pop();
  //                           }),
  //                       iconTheme: IconThemeData(
  //                           color: Colors.white,
  //                           size: SizeConfig.blockSizeVertical * 2.2),
  //                       textTheme: TextTheme(
  //                           subtitle1: TextStyle(
  //                               color: Colors.white,
  //                               fontFamily: "Ubuntu",
  //                               fontSize: SizeConfig.blockSizeVertical * 2.3)),
  //                     )
  //                   : PreferredSize(
  //                       child: Container(),
  //                       preferredSize: Size(SizeConfig.screenWidth, 0),
  //                     ),
  //             )),
  //       },
  //     );
  //   }));
  // }
}
