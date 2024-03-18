import 'package:flutter/material.dart';
import 'package:silvertouch/app_screens/login_screen.dart';
import 'package:silvertouch/app_screens/login_screen_doctor.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/string_resource.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: blueThemeColor,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/s-v-2-backg.png.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: rowImageWithText(true),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: rowImageWithText(false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget rowImageWithText(bool isLoginFromUser) {
    return InkWell(
      onTap: () => isLoginFromUser
          ? gotoLoginScreen(context)
          : gotoLoginScreenDoctor(context),
      child: Container(
        decoration: BoxDecoration(
            color: colorBtnBackground,
            borderRadius: BorderRadius.all(Radius.circular(50))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(isLoginFromUser
                  ? 'images/v-2-icn-users.png'
                  : 'images/v-2-icn-professional.png'),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
                child: Text(
                    isLoginFromUser ? str_users : str_healthcare_professional,
                    textScaleFactor: 1.5))
          ],
        ),
      ),
    );
  }

  Future<dynamic> gotoLoginScreen(BuildContext context) {
    return Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreen('')));
  }

  Future<dynamic> gotoLoginScreenDoctor(BuildContext context) {
    return Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreenDoctor()));
  }
}
