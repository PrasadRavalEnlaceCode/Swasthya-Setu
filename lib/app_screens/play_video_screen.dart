//import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:silvertouch/global/SizeConfig.dart';

//import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  String vidUrl;
  String vidTitle;
  String description;

  VideoPlayerScreen(this.vidUrl, this.vidTitle, this.description);

  @override
  State<StatefulWidget> createState() {
    return VideoPlayerScreenState();
  }
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _controller;
  var playerWidget;
  bool showAppBar = true;

  @override
  void initState() {
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.vidUrl)!,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        /*key: navigatorKey,*/
        appBar: showAppBar
            ? AppBar(
                title: Text(""),
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    SystemChrome.setPreferredOrientations(
                            [DeviceOrientation.portraitUp])
                        .then((value) => Navigator.of(context).pop());
                  },
                ),
                toolbarTextStyle: TextTheme(
                        titleMedium: TextStyle(
                            color: Colors.white,
                            fontFamily: "Ubuntu",
                            fontSize: SizeConfig.blockSizeVertical! * 2.5))
                    .bodyMedium,
                titleTextStyle: TextTheme(
                        titleMedium: TextStyle(
                            color: Colors.white,
                            fontFamily: "Ubuntu",
                            fontSize: SizeConfig.blockSizeVertical! * 2.5))
                    .titleLarge,
              )
            : PreferredSize(
                child: Container(),
                preferredSize: Size(SizeConfig.screenWidth!, 0),
              ),
        body: WillPopScope(
            onWillPop: () {
              SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp])
                  .then((value) => Navigator.of(context).pop());
              return Future.value(true);
            },
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    /*width: SizeConfig.blockSizeHorizontal * 80,*/
                    child: Center(
                      child: YoutubePlayerBuilder(
                        onExitFullScreen: () {
                          setState(() {
                            showAppBar = true;
                          });
                          /*SystemChrome.setPreferredOrientations(
                        [DeviceOrientation.portraitUp]);*/
                        },
                        onEnterFullScreen: () {
                          setState(() {
                            showAppBar = false;
                          });
                          /*SystemChrome.setPreferredOrientations(
                        [DeviceOrientation.landscapeLeft]);*/
                        },
                        builder: (context, player) {
                          return player;
                        },
                        player: YoutubePlayer(
                          aspectRatio: showAppBar ? 2 : 16 / 9,
                          controller: _controller!,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.amber,
                          progressColors: ProgressBarColors(
                            playedColor: Colors.amber,
                            handleColor: Colors.amberAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  showAppBar
                      ? SizedBox(
                          height: SizeConfig.blockSizeVertical! * 1,
                        )
                      : Container(),
                  showAppBar
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: SizeConfig.blockSizeHorizontal! * 2,
                                right: SizeConfig.blockSizeHorizontal! * 2),
                            child: Text(
                              widget.vidTitle,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: SizeConfig.blockSizeHorizontal! * 4.2,
                              ),
                            ),
                          ))
                      : Container(),
                ],
              ),
            )));
  }
}
