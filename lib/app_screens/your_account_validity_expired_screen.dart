import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swasthyasetu/app_screens/apply_couponcode_or_pay_screen.dart';
import 'package:swasthyasetu/enums/expiry_state.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';

class YourAccountValidityExpiredScreen extends StatelessWidget {
  final ExpiryState expiryState;

  YourAccountValidityExpiredScreen(this.expiryState);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: new Icon(
                Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
                color: Colors.black),
            onPressed: () {
              //if (Platform.isAndroid)
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              /*else
                Navigator.of(context).pop();*/
            }),
        iconTheme: IconThemeData(
          color: Colors.black,
          size: SizeConfig.blockSizeVertical !* 3.0,
        ),
        elevation: 0, toolbarTextStyle: TextTheme(
          titleMedium: TextStyle(
              color: Colors.white,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.3),
        ).bodyMedium, titleTextStyle: TextTheme(
          titleMedium: TextStyle(
              color: Colors.white,
              fontFamily: "Ubuntu",
              fontSize: SizeConfig.blockSizeVertical !* 2.3),
        ).titleLarge,
      ),
      body: Container(
        width: double.maxFinite,
        padding: EdgeInsets.all(
          SizeConfig.blockSizeHorizontal !* 3.0,
        ),
        color: Colors.white,
        child: Column(
          children: [
            Image(
              width: SizeConfig.blockSizeHorizontal !* 20,
              height: SizeConfig.blockSizeHorizontal !* 20,
              //height: 80,
              image: AssetImage("images/swasthya_setu_logo.jpeg"),
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical !* 2.0,
            ),
            /*Text(
              expiryState == ExpiryState.Expired
                  ? "Your Account validity is expired, proceed for Renewal."
                  : "Kindly proceed to pay \u20B9118 (including GST), to continue the subscription",
              softWrap: true,
              style: TextStyle(
                color: Colors.red,
                fontSize: SizeConfig.blockSizeHorizontal * 5.0,
                letterSpacing: 1.0,
                height: 1.6,
              ),
            ),*/
            Visibility(
              child: Text(
                "Your Swasthya Setu subscription is expired, kindly proceed for Renewal.",
                softWrap: true,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: SizeConfig.blockSizeHorizontal !* 5.0,
                  letterSpacing: 1.0,
                  height: 1.6,
                ),
              ),
              visible: expiryState == ExpiryState.NotPaid,
            ),
            Visibility(
              child: Text(
                "Kindly proceed to pay",
                softWrap: true,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: SizeConfig.blockSizeHorizontal !* 5.0,
                  letterSpacing: 1.0,
                  height: 1.6,
                ),
              ),
              visible: expiryState == ExpiryState.NotPaid,
            ),
            Visibility(
              child: Text(
                "\u20B9118 (including GST)",
                softWrap: true,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: SizeConfig.blockSizeHorizontal !* 5.0,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
              visible: expiryState == ExpiryState.NotPaid,
            ),
            Visibility(
              child: Text(
                "to continue the subscription",
                softWrap: true,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: SizeConfig.blockSizeHorizontal !* 5.0,
                  letterSpacing: 1.0,
                  height: 1.6,
                ),
              ),
              visible: expiryState == ExpiryState.NotPaid,
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical !* 2.0,
            ),
            MaterialButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ApplyCouponCodeOrPayScreen("")),
                    (Route<dynamic> route) => false);
              },
              color: Colors.blue,
              child: Text(
                "Proceed",
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
