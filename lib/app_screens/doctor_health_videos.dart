import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:silvertouch/app_screens/play_video_screen.dart';
import 'package:silvertouch/app_screens/select_patients_for_share_video.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_login_icons_model.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';
import '../utils/color.dart';

class DoctorHealthVideos extends StatefulWidget {
  final String sourceScreen;

  DoctorHealthVideos({required this.sourceScreen});

  @override
  State<StatefulWidget> createState() {
    return DoctorHealthVideosState();
  }
}

class DoctorHealthVideosState extends State<DoctorHealthVideos> {
  List<IconModel> listHealthVideos = [];
  bool isLoading = false;
  String userName = "";

  @override
  void initState() {
    super.initState();
    getDoctorProfileDetails();
    getHealthVideos();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return !isLoading && listHealthVideos.length > 0
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: listHealthVideos.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  debugPrint("vid play");
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(
                          listHealthVideos[index].webView!,
                          listHealthVideos[index].iconName!,
                          listHealthVideos[index].description!)));
                },
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 2),
                  child: Column(
                    children: <Widget>[
                      Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          CachedNetworkImage(
                            placeholder: (context, url) => Image(
                              width: SizeConfig.blockSizeHorizontal! * 92,
                              height: SizeConfig.blockSizeVertical! * 32,
                              image: AssetImage('images/shimmer_effect.png'),
                              fit: BoxFit.contain,
                            ),
                            imageUrl:
                                "https://img.youtube.com/vi/${listHealthVideos[index].image}/hqdefault.jpg",
                            fit: BoxFit.fitWidth,
                            width: SizeConfig.blockSizeHorizontal! * 95,
                            height: SizeConfig.blockSizeVertical! * 33,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.green,
                              size: SizeConfig.blockSizeHorizontal! * 30,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical! * 1,
                      ),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: SizeConfig.blockSizeHorizontal! * 2,
                                right: SizeConfig.blockSizeHorizontal! * 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  listHealthVideos[index].iconName!,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 4.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical! * 1.5,
                                ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   crossAxisAlignment: CrossAxisAlignment.center,
                                //   children: [
                                //     Expanded(
                                //       child: Align(
                                //         alignment: Alignment.center,
                                //         child: InkWell(
                                //           customBorder:
                                //           RoundedRectangleBorder(
                                //             borderRadius:
                                //             BorderRadius.circular(
                                //               SizeConfig.blockSizeHorizontal !*
                                //                   10.0,
                                //             ),
                                //           ),
                                //           onTap: () {
                                //             Share.share(
                                //                 '$userName has referred you one Educational Video to watch, that may be useful to you.\nClick below link to view\n\n${listHealthVideos[index].webView}');
                                //           },
                                //           child: Container(
                                //             padding: EdgeInsets.all(
                                //               SizeConfig.blockSizeHorizontal !*
                                //                   2.0,
                                //             ),
                                //             decoration: BoxDecoration(
                                //               borderRadius:
                                //               BorderRadius.circular(
                                //                 SizeConfig
                                //                     .blockSizeHorizontal !*
                                //                     10.0,
                                //               ),
                                //               border: Border.all(
                                //                 color: Colors.black,
                                //                 width: 0.8,
                                //               ),
                                //             ),
                                //             child:
                                //             Row(
                                //               mainAxisSize: MainAxisSize.min,
                                //               children: [
                                //                 Image.asset(
                                //                   "images/ic_share_externally.png",
                                //                   width: SizeConfig
                                //                       .blockSizeHorizontal !*
                                //                       6.0,
                                //                   height: SizeConfig
                                //                       .blockSizeHorizontal !*
                                //                       5.0,
                                //                   color: Colors.blueGrey[600],
                                //                 ),
                                //                 SizedBox(
                                //                   width: SizeConfig
                                //                       .blockSizeHorizontal !*
                                //                       2.0,
                                //                 ),
                                //                 Text(
                                //                   "Share Externally",
                                //                   textAlign: TextAlign.left,
                                //                   style: TextStyle(
                                //                     color:
                                //                     Colors.blueGrey[600],
                                //                     fontSize: SizeConfig
                                //                         .blockSizeHorizontal !*
                                //                         4.0,
                                //                   ),
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: InkWell(
                                        onTap: () {
                                          onPressedFunction(index);
                                        },
                                        customBorder: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            SizeConfig.blockSizeHorizontal! *
                                                10.0,
                                          ),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal! *
                                                2.0,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              SizeConfig.blockSizeHorizontal! *
                                                  10.0,
                                            ),
                                            border: Border.all(
                                                color: Colors.black,
                                                width: 0.8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                "images/ic_notify_on_app.png",
                                                width: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    6.0,
                                                height: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    6.0,
                                                color: Colors.blueGrey[600],
                                              ),
                                              SizedBox(
                                                width: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    1.0,
                                              ),
                                              Text(
                                                "Notify on App",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.blueGrey[600],
                                                  fontSize: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      3.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: InkWell(
                                        customBorder: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            SizeConfig.blockSizeHorizontal! *
                                                10.0,
                                          ),
                                        ),
                                        onTap: () {
                                          Share.share(
                                              '$userName has referred you one Educational Video to watch, that may be useful to you.\nClick below link to view\n\n${listHealthVideos[index].webView}');
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(
                                            SizeConfig.blockSizeHorizontal! *
                                                2.0,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              SizeConfig.blockSizeHorizontal! *
                                                  10.0,
                                            ),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                "images/ic_share_externally.png",
                                                width: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    6.0,
                                                height: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    5.0,
                                                color: Colors.blueGrey[600],
                                              ),
                                              SizedBox(
                                                width: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    1.0,
                                              ),
                                              Text(
                                                "Share Externally",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.blueGrey[600],
                                                  fontSize: SizeConfig
                                                          .blockSizeHorizontal! *
                                                      3.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical! * 3,
                      ),
                    ],
                  ),
                ),
              );
            })
        : Center(
            child: Container(
              width: SizeConfig.blockSizeHorizontal! * 30,
              child: SizedBox(
                height: SizeConfig.blockSizeVertical! * 80,
                width: SizeConfig.blockSizeHorizontal! * 100,
                child: Container(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image(
                        image: AssetImage("images/ic_idea_new.png"),
                        width: 200,
                        height: 100,
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Text(
                        "No Patient Resources Found.",
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  void onPressedFunction(int index) {
    if (widget.sourceScreen == 'PatientResourcesScreen') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SelectPatientsForShareVideo(listHealthVideos[index], userName)),
      );
      print('Button pressed from DoctorDashboardScreen');
    } else if (widget.sourceScreen == 'PatientResourcesFromProfileScreen') {
      // Functionality for AddConsultationScreen
      print('Button pressed from AddConsultationScreen');
    }
  }

  void getDoctorProfileDetails() async {
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: "${baseURL}doctorProfileData.php",
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
    /*pr.hide();*/
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array : " + strData);
      debugPrint("Decoded Data Array : " + strData);
      final jsonData = json.decode(strData);
      String firstName = jsonData[0]['FirstName'];
      String middleName = jsonData[0]['MiddleName'];
      String lastName = jsonData[0]['LastName'];
      userName =
          (firstName.trim() + " " + middleName.trim() + " " + lastName.trim())
              .trim();
      setState(() {});
    } else {
      /*final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(model.message),
      );
      ScaffoldMessenger.of(navigationService.navigatorKey.currentState)
          .showSnackBar(snackBar);*/
    }
  }

  void getHealthVideos() async {
    setState(() {
      isLoading = true;
    });
    String loginUrl = "${baseURL}doctorVideosList.php";
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    String patientIDP = await getPatientOrDoctorIDP();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);
    String jsonStr =
        "{" + "\"" + "DoctorIDP" + "\"" + ":" + "\"" + patientIDP + "\"" + "}";

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
    listHealthVideos = [];
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      final jsonVideos = jsonData['Videos'];
      //final jsonVideos = json.decode(videos);

      for (var i = 0; i < jsonVideos.length; i++) {
        var jsonVideoObj = jsonVideos[i];
        listHealthVideos.add(IconModel(
            jsonVideoObj["VideoTitle"],
            "${jsonVideoObj["VideoID"].toString()}",
            jsonVideoObj["VideoURL"],
            jsonVideoObj["VideoDescription"]));
      }
      setState(() {
        isLoading = false;
      });
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
