import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:swasthyasetu/app_screens/all_videos_screen.dart';
import 'package:swasthyasetu/app_screens/play_video_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_login_icons_model.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/utils/color.dart';

class SearchHealthVideosScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchHealthVideosScreenState();
  }
}

class SearchHealthVideosScreenState extends State<SearchHealthVideosScreen> {
  List<IconModel> listHealthVideos = [];
  List<IconModel> listHealthVideosSearchResults = [];

  Icon icon = Icon(
    Icons.search,
    color: Colors.black,
  );
  Widget titleWidget = Text("Health Videos");
  TextEditingController? searchController;
  var focusNode = new FocusNode();
  var isLoading = false;
  var cancelled = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      searchController = TextEditingController(text: "");
      icon = Icon(
        Icons.arrow_forward,
        color: Colors.black,
      );
      /*titleWidget = Container(
        width: SizeConfig.blockSizeHorizontal * 50,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
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
            ),
            Icon(
              Icons.cancel,
              color: Colors.white,
            ),
          ],
        ),
      );*/
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
              fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
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
                titleWidget = Text("Health Videos");
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
    });
    getHealthVideos("");
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
                      color: Colorsblack,
                    );
                    titleWidget = titleWidget = Row(
                      children: <Widget>[
                        Expanded(
                            child: TextField(
                          controller: searchController,
                          focusNode: focusNode,
                          cursorColor: Colors.white,
                          onChanged: (text) {},
                          style: TextStyle(
                            color: Colorsblack,
                            fontSize: SizeConfig.blockSizeHorizontal !* 4.0,
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
                                color: Colorsblack,
                              );
                              titleWidget = Text("Health Videos");
                            });
                          },
                          child: Icon(
                            Icons.cancel,
                            color: Colorsblack,
                          ),
                        )
                      ],
                    );
                  } else {
                  getHealthVideos(searchController!.text.toLowerCase().trim());
                  }
                });
              },
              icon: icon,
            )
          ], toolbarTextStyle: TextTheme(
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
            return Center(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: SizeConfig.blockSizeVertical !* 1.0,
                  ),
                  InkWell(
                      child: Container(
                        width: double.maxFinite,
                        padding: EdgeInsets.all(
                            SizeConfig.blockSizeHorizontal !* 2.0),
                        margin: EdgeInsets.all(
                            SizeConfig.blockSizeHorizontal !* 2.0),
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
                              fontSize: SizeConfig.blockSizeVertical !* 2.3),
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
                              context, listHealthVideosSearchResults))
                      : Container(),
                  /*listHealthVideosSearchResults.length > 0 && !isLoading
                      ? Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: listHealthVideosSearchResults.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    debugPrint("vid play");
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => VideoPlayerScreen(
                                                listHealthVideosSearchResults[
                                                        index]
                                                    .webView,
                                                listHealthVideosSearchResults[
                                                        index]
                                                    .iconName,
                                                listHealthVideosSearchResults[
                                                        index]
                                                    .description)))
                                        .then((value) {
                                      FocusScope.of(context).requestFocus(
                                          FocusNode()); //remove focus
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                        SizeConfig.blockSizeHorizontal * 2),
                                    child: Column(
                                      children: <Widget>[
                                        Stack(
                                          alignment: Alignment.center,
                                          children: <Widget>[
                                            CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Image(
                                                width: SizeConfig
                                                        .blockSizeHorizontal *
                                                    92,
                                                height: SizeConfig
                                                        .blockSizeVertical *
                                                    32,
                                                image: AssetImage(
                                                    'images/shimmer_effect.png'),
                                                fit: BoxFit.contain,
                                              ),
                                              imageUrl:
                                                  listHealthVideosSearchResults[
                                                          index]
                                                      .image,
                                              fit: BoxFit.fitWidth,
                                              width: SizeConfig
                                                      .blockSizeHorizontal *
                                                  95,
                                              height:
                                                  SizeConfig.blockSizeVertical *
                                                      33,
                                            ),
                                            Align(
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.play_arrow,
                                                color: Colors.green,
                                                size: SizeConfig
                                                        .blockSizeHorizontal *
                                                    30,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height:
                                              SizeConfig.blockSizeVertical * 1,
                                        ),
                                        Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: SizeConfig
                                                          .blockSizeHorizontal *
                                                      2,
                                                  right: SizeConfig
                                                          .blockSizeHorizontal *
                                                      2),
                                              child: Text(
                                                listHealthVideosSearchResults[
                                                        index]
                                                    .iconName,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: SizeConfig
                                                          .blockSizeHorizontal *
                                                      4.2,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            )),
                                        SizedBox(
                                          height:
                                              SizeConfig.blockSizeVertical * 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }))
                      : Container(),*/
                  Visibility(
                    visible:
                        listHealthVideosSearchResults.length == 0 && !isLoading,
                    child: Container(
                      height: SizeConfig.blockSizeVertical !* 100,
                      padding:
                          EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
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
                          width: SizeConfig.blockSizeHorizontal !* 10,
                          height: SizeConfig.blockSizeHorizontal !* 10,
                          child: Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.grey,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
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

  void getHealthVideos(String keyword) async {
    //if (!isLoading) {
    //cancelled = false;
    actuallyGetHealthVideos(keyword);
    //} else {
    //cancelled = true;
    /*Future.delayed(Duration(milliseconds: 1000), () {
        getHealthVideos(keyword);
      });*/
    //}
  }

  void actuallyGetHealthVideos(String keyword) async {
    String loginUrl = "${baseURL}videosearch.php";
    listHealthVideos = [];
    listHealthVideosSearchResults = [];
    isLoading = true;
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
          isLoading = false;
        });
      }
    }
  }
}

Widget _createListView(
    BuildContext context, List<IconModel> listHealthVideosSearchResults) {
  ScrollController _scrollController = ScrollController();
  debugPrint("before listener");
  _scrollController.addListener(() {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      debugPrint("scrolled to end...");
      /*if (!isLoading) {
        getDashboardData();
      }*/
    }
  });
  return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: listHealthVideosSearchResults.length,
      controller: _scrollController,
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
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 2),
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    CachedNetworkImage(
                      placeholder: (context, url) => Image(
                        width: SizeConfig.blockSizeHorizontal !* 92,
                        height: SizeConfig.blockSizeVertical !* 32,
                        image: AssetImage('images/shimmer_effect.png'),
                        fit: BoxFit.contain,
                      ),
                      imageUrl: listHealthVideosSearchResults[index].image!,
                      fit: BoxFit.fitWidth,
                      width: SizeConfig.blockSizeHorizontal !* 95,
                      height: SizeConfig.blockSizeVertical !* 33,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.green,
                        size: SizeConfig.blockSizeHorizontal !* 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 1,
                ),
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.blockSizeHorizontal !* 2,
                          right: SizeConfig.blockSizeHorizontal !* 2),
                      child: Text(
                        listHealthVideosSearchResults[index].iconName!,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal !* 4.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )),
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 3,
                ),
              ],
            ),
          ),
        );
      });
}
