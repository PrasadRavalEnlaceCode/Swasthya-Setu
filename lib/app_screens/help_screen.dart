import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swasthyasetu/app_screens/patient_dashboard_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/color.dart';

class HelpScreen extends StatefulWidget {
  String patientIDP;

  HelpScreen(this.patientIDP);

  @override
  State<StatefulWidget> createState() {
    return HelpScreenState();
  }
}

class HelpScreenState extends State<HelpScreen> {
  TextEditingController queryController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Help ?"),
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        SizedBox(
                          height: SizeConfig.blockSizeVertical !* 2,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal !* 3,
                              right: SizeConfig.blockSizeHorizontal !* 3),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Send us Your Query. We will get back to you soon.",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        //Text("We will get back to you soon."),
                        Padding(
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal !* 3),
                          child: TextField(
                            controller: queryController,
                            textAlign: TextAlign.left,
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.green, width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.green, width: 2.0),
                              ),
                              hintText: 'Your query here...',
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: SizeConfig.blockSizeHorizontal !* 35,
                            child: MaterialButton(
                              onPressed: () {
                                submitQuery(patientIDP!, context);
                              },
                              color: Colors.green,
                              child: Text(
                                "Send",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical !* 3,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal !* 3,
                              right: SizeConfig.blockSizeHorizontal !* 3),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Feel free to contact us any time.",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical !* 1,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal !* 3,
                              right: SizeConfig.blockSizeHorizontal !* 3),
                          child: InkWell(
                            child: Container(
                              width: SizeConfig.screenWidth,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Image(
                                    width: SizeConfig.blockSizeHorizontal !* 6,
                                    image: AssetImage("images/ic_call.png"),
                                    color: Colors.green,
                                  ),
                                  SizedBox(
                                    width: SizeConfig.blockSizeHorizontal !* 4,
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      /*Text("Phone Number"),*/
                                      Text(
                                        "+917575033323",
                                        style: TextStyle(
                                            fontSize:
                                                SizeConfig.blockSizeHorizontal !*
                                                    4),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeVertical !* 1,
                                      ),
                                      Container(
                                        width:
                                            SizeConfig.blockSizeHorizontal !* 80,
                                        height: 1.0,
                                        color: Colors.grey,
                                      ),
                                      /* Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Expanded(
                                    child:
                                  )
                                ],
                              )*/
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: SizeConfig.blockSizeVertical !* 2,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal !* 3,
                              right: SizeConfig.blockSizeHorizontal !* 3),
                          child: InkWell(
                            onTap: () {
                              launchURL(
                                  'mailto:info@swasthyasetu.com?subject=&body=');
                            },
                            child: Container(
                              width: SizeConfig.screenWidth,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Image(
                                    width: SizeConfig.blockSizeHorizontal !* 6,
                                    image: AssetImage("images/ic_mail.png"),
                                    color: Colors.green,
                                  ),
                                  SizedBox(
                                    width: SizeConfig.blockSizeHorizontal !* 4,
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      //Text("Email"),
                                      Text(
                                        "info@swasthyasetu.com",
                                        style: TextStyle(
                                            fontSize:
                                                SizeConfig.blockSizeHorizontal !*
                                                    4),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeVertical !* 1,
                                      ),
                                      Container(
                                        width:
                                            SizeConfig.blockSizeHorizontal !* 80,
                                        height: 1.0,
                                        color: Colors.grey,
                                      ),
                                      /* Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Expanded(
                                    child:
                                  )
                                ],
                              )*/
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: SizeConfig.blockSizeVertical !* 2,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal !* 3,
                              right: SizeConfig.blockSizeHorizontal !* 3),
                          child: InkWell(
                            onTap: () {
                              launchURL("http://swasthyasetu.com/");
                            },
                            child: Container(
                              width: SizeConfig.screenWidth,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Image(
                                    width: SizeConfig.blockSizeHorizontal !* 6,
                                    image: AssetImage("images/ic_website.png"),
                                    color: Colors.green,
                                  ),
                                  SizedBox(
                                    width: SizeConfig.blockSizeHorizontal !* 4,
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      //Text("Website"),
                                      Text(
                                        "www.swasthyasetu.com",
                                        style: TextStyle(
                                            fontSize:
                                                SizeConfig.blockSizeHorizontal !*
                                                    4),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.blockSizeVertical !* 1,
                                      ),
                                      Container(
                                        width:
                                            SizeConfig.blockSizeHorizontal !* 80,
                                        height: 1.0,
                                        color: Colors.grey,
                                      ),
                                      /* Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Expanded(
                                    child:
                                  )
                                ],
                              )*/
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: SizeConfig.blockSizeVertical !* 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: SizeConfig.blockSizeVertical !* 12,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                            onPressed: () {
                              launchURL("tel:+917575033323");
                            },
                            color: Colors.green,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image(
                                  width: SizeConfig.blockSizeHorizontal !* 4,
                                  image: AssetImage("images/ic_call.png"),
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: SizeConfig.blockSizeHorizontal !* 2,
                                ),
                                Text(
                                  "Call Us",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )),
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal !* 2,
                      ),
                      Expanded(
                        child: MaterialButton(
                            onPressed: () async {
                              if (await canLaunch(
                                  "whatsapp://send?phone=917575033323&text=")) {
                                launchURL(
                                    "whatsapp://send?phone=917575033323&text=");
                              } else {
                                Fluttertoast.showToast(
                                    msg: "You need to Install Whatsapp!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            },
                            color: Colors.green,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image(
                                  width: SizeConfig.blockSizeHorizontal !* 4,
                                  image: AssetImage("images/ic_whatsapp.png"),
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: SizeConfig.blockSizeHorizontal !* 2,
                                ),
                                Text(
                                  "Whatsapp Us",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )),
                      )
                    ],
                  ),
                )
              ],
            );
          },
        )
        /*body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ListView.builder(
            itemCount: listInvestigationMaster.length,
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return MultiCard(listInvestigationMaster[index]);
            },
          ),
          */ /*Expanded(
            child: */ /*Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 25.0,
                    top: 10.0,
                  ),
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal * 12,
                    height: SizeConfig.blockSizeHorizontal * 12,
                    child: RawMaterialButton(
                      onPressed: () {
                        //submitImageForUpdate(context, widget.image);
                      },
                      elevation: 2.0,
                      fillColor: Color(0xFF06A759),
                      child: Image(
                        width: SizeConfig.blockSizeHorizontal * 5.5,
                        height: SizeConfig.blockSizeHorizontal * 5.5,
                        //height: 80,
                        image:
                            AssetImage("images/ic_right_arrow_triangular.png"),
                      ),
                      shape: CircleBorder(),
                    ),
                  ),
                ) */ /*),*/ /*
          ),
        ],
      ),*/
        );
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

  void submitQuery(String patientReportIDP, BuildContext context) async {
    if (queryController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Please Type your query first."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    String loginUrl = "${baseURL}helpquery.php";

    ProgressDialog pr = ProgressDialog(context);
    pr.show();
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String mobNo = await getMobNo();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        widget.patientIDP +
        "\"" +
        "," +
        "\"" +
        "MobileNo" +
        "\"" +
        ":" +
        "\"" +
        mobNo +
        "\"" +
        "," +
        "\"" +
        "YourQuery" +
        "\"" +
        ":" +
        "\"" +
        replaceNewLineBySlashN(queryController.text.trim()) +
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
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(milliseconds: 3000), () {
        Navigator.of(context).pop();
      });
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message!),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
