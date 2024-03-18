import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:silvertouch/app_screens/play_video_screen.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_login_icons_model.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

import '../utils/color.dart';

class AllVideosScreen extends StatefulWidget {
  /*String action;

  AllVideosScreen({this.action = "search"});*/

  @override
  State<StatefulWidget> createState() {
    return AllVideosScreenState();
  }
}

class AllVideosScreenState extends State<AllVideosScreen> {
  List<IconModel> listHealthVideos = [];
  List<IconModel> listHealthVideosSearchResults = [];
  int startIndex = 1;

  Icon icon = Icon(
    Icons.search,
    color: Colors.black,
  );
  Widget titleWidget = Text("All Health Videos");
  TextEditingController? searchController;
  var focusNode = new FocusNode();
  var isLoading = false;
  var cancelled = false;
  bool isLoadingListView = false;

  @override
  void initState() {
    super.initState();
    /*setState(() {
      searchController = TextEditingController(text: "");
      icon = Icon(
        Icons.arrow_forward,
        color: Colors.black,
      );
      titleWidget = Row(
        children: <Widget>[
          Expanded(
              child: TextField(
            controller: searchController,
            focusNode: focusNode,
            cursorColor: Colors.white,
            onChanged: (text) {},
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConfig.blockSizeHorizontal * 4.0,
            ),
            decoration: InputDecoration(
              hintText: "Search Health Videos",
            ),
          )),
          InkWell(
            onTap: () {
              getHealthVideos("");
              setState(() {
                icon = Icon(
                  Icons.search,
                  color: Colors.white,
                );
                titleWidget = Text("All Health Videos");
              });
            },
            child: Icon(
              Icons.cancel,
              color: Colors.white,
            ),
          )
        ],
      );
      focusNode.requestFocus();
    });*/
    getHealthVideos("", 0);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: titleWidget,
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(color: Colorsblack),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                setState(() {
                  if (icon.icon == Icons.search) {
                    searchController = TextEditingController(text: "");
                    focusNode.requestFocus();
                    icon = Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                    );
                    titleWidget = titleWidget = Row(
                      children: <Widget>[
                        Expanded(
                            child: TextField(
                          controller: searchController,
                          focusNode: focusNode,
                          cursorColor: Colors.black,
                          onChanged: (text) {},
                          onSubmitted: (value) {
                            // print('Search ${searchController!.text.toLowerCase().trim()}');
                            getHealthVideos(
                                searchController!.text.toLowerCase().trim(), 0);
                            setState(() {
                              icon = Icon(
                                Icons.search,
                                color: Colors.black,
                              );
                              titleWidget = Text("All Health Videos");
                            });
                          },
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search Health Videos",
                          ),
                        )),
                        InkWell(
                          onTap: () {
                            // print('Search ${searchController!.text.toLowerCase().trim()}');
                            getHealthVideos(
                                searchController!.text.toLowerCase().trim(), 0);
                            setState(() {
                              icon = Icon(
                                Icons.search,
                                color: Colors.black,
                              );
                              titleWidget = Text("All Health Videos");
                            });
                          },
                          child: Icon(
                            Icons.cancel,
                            color: Colors.white,
                          ),
                        )
                      ],
                    );
                  } else {
                    getHealthVideos(
                        searchController!.text.toLowerCase().trim(), 0);
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
            return Center(
              child: Column(
                children: <Widget>[
                  icon.icon == Icons.search
                      ? Container()
                      : SizedBox(
                          height: SizeConfig.blockSizeVertical! * 1.0,
                        ),
                  icon.icon == Icons.search
                      ? Container()
                      : InkWell(
                          child: Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 2.0),
                            margin: EdgeInsets.all(
                                SizeConfig.blockSizeHorizontal! * 2.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.0,
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: Text(
                              "All Videos",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      SizeConfig.blockSizeVertical! * 2.3),
                            ),
                          ),
                          onTap: () async {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return AllVideosScreen();
                            }));
                          }),
                  listHealthVideosSearchResults.length > 0 && !isLoading
                      ? Expanded(
                          child: _createListView(
                              context,
                              listHealthVideosSearchResults,
                              changeIsLoadingForListViewAndCallApi))
                      : Container(),
                  Visibility(
                      visible: isLoadingListView,
                      child: Container(
                          width: SizeConfig.blockSizeHorizontal! * 10,
                          height: SizeConfig.blockSizeHorizontal! * 10,
                          child: Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.grey,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blueGrey),
                            ),
                          ))),
                  Visibility(
                    visible:
                        listHealthVideosSearchResults.length == 0 && !isLoading,
                    child: Container(
                      height: SizeConfig.blockSizeVertical! * 100,
                      padding:
                          EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                            image: AssetImage("images/ic_search.png"),
                            width: 100,
                            height: 100,
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          Text(
                            "Type on Search box to search the Videos",
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                      visible: isLoading,
                      child: Container(
                          width: SizeConfig.blockSizeHorizontal! * 10,
                          height: SizeConfig.blockSizeHorizontal! * 10,
                          child: Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.grey,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blueGrey),
                            ),
                          ))),
                ],
              ),
            );
          },
        ));
  }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }

  void getHealthVideos(String keyword, int startIndexValue) async {
    //if (!isLoading) {
    //cancelled = false;
    actuallyGetHealthVideos(keyword, startIndexValue);
    //} else {
    //cancelled = true;
    /*Future.delayed(Duration(milliseconds: 1000), () {
        getHealthVideos(keyword);
      });*/
    //}
  }

  void actuallyGetHealthVideos(String keyword, int startIndex) async {
    print('actuallyGetHealthVideos $keyword');
    String loginUrl = "";
    if (keyword == "")
      loginUrl = "${baseURL}videosearchAll.php";
    else
      loginUrl = "${baseURL}videosearch.php";
    if (startIndex == 0) {
      listHealthVideos = [];
      listHealthVideosSearchResults = [];
      isLoading = true;
    } else
      isLoadingListView = true;
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
        "videokeyword" +
        "\"" +
        ":" +
        "\"" +
        keyword +
        "\"" +
        "," +
        "\"" +
        "start" +
        "\"" +
        ":" +
        "\"" +
        startIndex.toString() +
        "\"" +
        "}";

    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
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
    /*pr.hide();*/
    var androidVersion = jsonResponse['apiversion'];
    var iosVersion = jsonResponse['apiversionios'];
    if (!cancelled) {
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array Dashboard : " + strData);
        final jsonVideos = json.decode(strData);
        //final jsonVideos = jsonData['Videos'];
        //final jsonVideos = json.decode(videos);

        for (var i = 0; i < jsonVideos.length; i++) {
          var jsonVideoObj = jsonVideos[i];
          listHealthVideos.add(IconModel(
              jsonVideoObj["VideoTitle"],
              "https://img.youtube.com/vi/${jsonVideoObj["VideoID"].toString()}/hqdefault.jpg",
              jsonVideoObj["VideoURL"],
              jsonVideoObj["VideoDescription"]));
        }
        listHealthVideosSearchResults = listHealthVideos;
        setState(() {
          if (startIndex == 0)
            isLoading = false;
          else
            isLoadingListView = false;
        });
      }
    }
  }

  Function? changeIsLoadingForListViewAndCallApi() {
    setState(() {
      isLoadingListView = !isLoadingListView;
    });
    startIndex = startIndex + 10;
    getHealthVideos("", startIndex);
    return null;
  }
}

Widget _createListView(BuildContext context,
    List<IconModel> listHealthVideosSearchResults, Function changeState) {
  ScrollController _scrollController = ScrollController();
  debugPrint("before listener all videos");
  _scrollController.addListener(() {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      debugPrint("scrolled to end...");
      changeState();
      /*if (!isLoading) {
        getDashboardData();
      }*/
    }
  });
  return ListView.builder(
      shrinkWrap: true,
      controller: _scrollController,
      physics: ClampingScrollPhysics(),
      itemCount: listHealthVideosSearchResults.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            debugPrint("vid play");
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                        listHealthVideosSearchResults[index].webView!,
                        listHealthVideosSearchResults[index].iconName!,
                        listHealthVideosSearchResults[index].description!)))
                .then((value) {
              FocusScope.of(context).requestFocus(FocusNode()); //remove focus
            });
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
                      imageUrl: listHealthVideosSearchResults[index].image!,
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
                      child: Text(
                        listHealthVideosSearchResults[index].iconName!,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal! * 4.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )),
                SizedBox(
                  height: SizeConfig.blockSizeVertical! * 3,
                ),
              ],
            ),
          ),
        );
      });
}
