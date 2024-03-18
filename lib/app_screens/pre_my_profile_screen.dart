import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swasthyasetu/app_screens/view_profile_details_patient.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';

import 'landing_screen.dart';

class PreMyProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PreMyProfileScreenState();
  }
}

class PreMyProfileScreenState extends State<PreMyProfileScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        /*key: navigatorKey,*/
        appBar: AppBar(
          title: Text("My Profile"),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
              color: Color(0xFF06A759),
              size: SizeConfig.blockSizeVertical !* 2.5), toolbarTextStyle: TextTheme(
              titleMedium: TextStyle(
                  color: Colors.white,
                  fontFamily: "Ubuntu",
                  fontSize: SizeConfig.blockSizeVertical !* 2.5)).bodyMedium, titleTextStyle: TextTheme(
              titleMedium: TextStyle(
                  color: Colors.white,
                  fontFamily: "Ubuntu",
                  fontSize: SizeConfig.blockSizeVertical !* 2.5)).titleLarge,
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 0,
          selectedItemColor: Color(0xFF06A759),
          unselectedItemColor: Colors.black,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          currentIndex: 3,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              activeIcon: Image(
                image: AssetImage(
                  "images/ic_home_footer.png",
                ),
                color: Color(0xFF06A759),
                width: SizeConfig.blockSizeHorizontal !* 6,
              ),
              icon: Image(
                image: AssetImage(
                  "images/ic_home_footer.png",
                ),
                width: SizeConfig.blockSizeHorizontal !* 6,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
                icon: Image(
                  image: AssetImage(
                    "images/ic_scan_and_pay_footer.png",
                  ),
                  width: SizeConfig.blockSizeHorizontal !* 6,
                ),
                label: "Scan & Pay"),
            BottomNavigationBarItem(
                icon: Image(
                  image: AssetImage(
                    "images/ic_document_footer.png",
                  ),
                  width: SizeConfig.blockSizeHorizontal !* 6,
                ),
                label: "Documents"),
            BottomNavigationBarItem(
                activeIcon: Image(
                  image: AssetImage(
                    "images/ic_my_profile_footer.png",
                  ),
                  width: SizeConfig.blockSizeHorizontal !* 6,
                ),
                icon: Image(
                  image: AssetImage(
                    "images/ic_my_profile_footer.png",
                  ),
                  width: SizeConfig.blockSizeHorizontal !* 6,
                ),
                label: "My Profile"),
          ],
        ),
        body: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: MaterialButton(
                    onPressed: () {
                      /*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ComingSoonScreen()));*/
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewProfileDetails()));
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.blockSizeHorizontal !* 5,
                          top: SizeConfig.blockSizeVertical !* 2,
                          bottom: SizeConfig.blockSizeVertical !* 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Image(
                              width: SizeConfig.blockSizeHorizontal !* 10,
                              image: AssetImage(
                                  'images/ic_hospital_dashboard.png')),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal !* 6,
                          ),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal !* 38,
                            child: Text("View Profile",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                )),
                          ),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal !* 8,
                          ),
                          Image(
                            color: Colors.greenAccent,
                            width: SizeConfig.blockSizeHorizontal !* 6,
                            //height: 80,
                            image: AssetImage("images/ic_right_arrow.png"),
                          ),
                        ],
                      ),
                    ),
                    textColor: Colors.white,
                    color: Color(0xFF06A759),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical !* 5,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MaterialButton(
                  onPressed: () {},
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: SizeConfig.blockSizeHorizontal !* 5,
                        top: SizeConfig.blockSizeVertical !* 2,
                        bottom: SizeConfig.blockSizeVertical !* 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Image(
                            width: SizeConfig.blockSizeHorizontal !* 10,
                            image: AssetImage(
                                'images/ic_education_dashboard.png')),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal !* 6,
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal !* 38,
                          child: Text("Log Out",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                              )),
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal !* 8,
                        ),
                        Image(
                          color: Colors.greenAccent,
                          width: SizeConfig.blockSizeHorizontal !* 6,
                          //height: 80,
                          image: AssetImage("images/ic_right_arrow.png"),
                        ),
                      ],
                    ),
                  ),
                  textColor: Colors.white,
                  color: Color(0xFF06A759),
                ),
              ],
            ),
          ],
        ));

    /*YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: 'iLnmTe5Q2Qw',
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: true,
      ),
    );*/
  }

  showConfirmationDialog(BuildContext context, String exitOrLogout) {
    var title = "Do you really want to Logout?";
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No")),
              TextButton(
                  onPressed: () {
                    logOut(context);
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LandingScreen()));
                  },
                  child: Text("Yes"))
            ],
          );
        });
  }

  logOut(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (mContext) => LandingScreen()),
    );
    Navigator.pop(context);
  }
}
