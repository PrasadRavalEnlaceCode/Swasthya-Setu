import 'dart:convert';

/*import 'package:audio_service/audio_service.dart';*/
import 'package:flutter/material.dart';
import 'package:silvertouch/app_screens/play_music_simple_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/media_item.dart';
import 'package:silvertouch/podo/model_investigation_list_doctor.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import '../utils/color.dart';

class MusicListScreen extends StatefulWidget {
  String patientIDP;

  MusicListScreen(this.patientIDP);

  @override
  State<StatefulWidget> createState() {
    return MusicListScreenState();
  }
}

class MusicListScreenState extends State<MusicListScreen> {
  List<MediaItem> listMedia = [];

  @override
  void initState() {
    super.initState();
    getMeditationMusicList();
  }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }

  void getMeditationMusicList() async {
    String loginUrl = "${baseURL}musiclist.php";
    ProgressDialog? pr;
    Future.delayed(Duration.zero, () {
      pr = ProgressDialog(context);
      pr!.show();
    });
    //listIcon = new List();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
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
    pr!.hide();
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Investigation Masters list : " + strData);
      final jsonData = json.decode(strData);
      listMedia = [];
      for (var i = 0; i < jsonData.length; i++) {
        var jo = jsonData[i];
        listMedia.add(MediaItem(
          id: "${baseURL}images/music/${jo['FileName']}",
          album: jo['MusicDescription'],
          title: jo['MusicTitle'],
          artist: jo['MusicDescription'],
          artUri: "",
        ));
      }

      /*if (listInvestigationMasterSelected.length > 0) {
        debugPrint("Inside for loop");
        debugPrint(listInvestigationMasterSelected.toString());
        for (int i = 0; i < listInvestigationsList.length; i++) {
          var modelNotSelected = listInvestigationsList[i];
          for (int j = 0; j < listInvestigationMasterSelected.length; j++) {
            var modelSelected = listInvestigationMasterSelected[j];
            if (modelSelected.preInvestTypeIDP ==
                modelNotSelected.preInvestTypeIDP) {
              modelNotSelected.isChecked = true;
            }
          }
        }
      }*/
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Meditation"),
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(color: Colorsblack),
          toolbarTextStyle: TextTheme(
              titleMedium: TextStyle(
            color: Colorsblack,
            fontFamily: "Ubuntu",
            fontSize: SizeConfig.blockSizeVertical! * 2.5,
          )).bodyMedium,
          titleTextStyle: TextTheme(
              titleMedium: TextStyle(
            color: Colorsblack,
            fontFamily: "Ubuntu",
            fontSize: SizeConfig.blockSizeVertical! * 2.5,
          )).titleLarge,
        ),
        body: Builder(
          builder: (context) {
            return Column(
              children: <Widget>[
                listMedia.length > 0
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: listMedia.length,
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return /*AudioServiceWidget(
                                              child:*/
                                      PlayMusicSimpleScreen(
                                    listMedia[index],
                                    listMedia,
                                    index,
                                  ) /*)*/;
                                }));
                              },
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      SizeConfig.blockSizeHorizontal! * 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      /*Image.network(listMedia[index].artUri,
                                      width:
                                          SizeConfig.blockSizeHorizontal * 25,
                                      height:
                                          SizeConfig.blockSizeHorizontal * 25),*/
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              listMedia[index].title!,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    4.5,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(
                                              height: SizeConfig
                                                      .blockSizeVertical! *
                                                  1.5,
                                            ),
                                            Text(
                                              listMedia[index].artist!,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    4.0,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return /*AudioServiceWidget(
                                              child:*/
                                                PlayMusicSimpleScreen(
                                              listMedia[index],
                                              listMedia,
                                              index,
                                            ) /*)*/;
                                          }));
                                        },
                                        icon: Icon(
                                          Icons.play_arrow,
                                          size:
                                              SizeConfig.blockSizeHorizontal! *
                                                  10,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(),
              ],
            );
          },
        ));
  }
}
