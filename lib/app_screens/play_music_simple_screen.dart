/*
import 'package:flutter/material.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';

class PlayMusicSimpleScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PlayMusicSimpleScreenState();
  }
}

class PlayMusicSimpleScreenState extends State<PlayMusicSimpleScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Play"),
          backgroundColor: Color(0xFF06A759),
          iconTheme: IconThemeData(color: Colors.white),
          textTheme: TextTheme(
              subtitle1: TextStyle(
            color: Colors.white,
            fontFamily: "Ubuntu",
            fontSize: SizeConfig.blockSizeVertical * 2.5,
          )),
        ),
        body: Builder(
          builder: (context) {
            return Column(
              children: <Widget>[

              ],
            );
          },
        ));
  }
}
*/

/*import 'package:audio_service/audio_service.dart';*/
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/podo/media_item.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:swasthyasetu/utils/progress_dialog_with_percentage.dart';

class PlayMusicSimpleScreen extends StatefulWidget {
  MediaItem mediaItem;
  List<MediaItem> listMedia;
  int index;

  PlayMusicSimpleScreen(
    this.mediaItem,
    this.listMedia,
    this.index,
  );

  @override
  _PlayMusicSimpleScreenState createState() => _PlayMusicSimpleScreenState();
}

class _PlayMusicSimpleScreenState extends State<PlayMusicSimpleScreen> {
  final _volumeSubject = BehaviorSubject.seeded(1.0);
  final _speedSubject = BehaviorSubject.seeded(1.0);
  AudioPlayer? _player;
  int currentIndex = 0;
  MediaItem? currentMediaItem;
  ProgressDialog? pr;
  GlobalKey<ProgressDialogWithPercentageState> progressKey = GlobalKey();
  String saveFilePath = "";

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    currentIndex = widget.index;
    currentMediaItem = widget.mediaItem;
    /*AudioPlayer.setIosCategory(IosCategory.playback);*/
    setPlayerUrl(widget.mediaItem.id!);
  }

  @override
  void dispose() {
    _player!.dispose();
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void downloadAndOpenTheFile(String url, String fileName) async {
    var tempDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    //await tempDir.create(recursive: true);
    saveFilePath = tempDir!.path + "/Swasthya Setu/Meditation";
    debugPrint("full path");
    debugPrint(saveFilePath);
    Dio dio = Dio();
    downloadFileAndOpenActually(dio, url, saveFilePath, fileName);
  }

  Future downloadFileAndOpenActually(
      Dio dio, String url, String savePath, String fileName) async {
    try {
      /*pr = ProgressDialog(context);
      pr.show();*/
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return ProgressDialogWithPercentage(
              key: progressKey,
              title: "Downloading",
            );
          });

      final savedDir = Directory(savePath);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        await savedDir.create(recursive: true);
      }
      /*taskId =*/
      await FlutterDownloader.enqueue(
        url: url,
        savedDir: savePath,
        showNotification: false,
        fileName: fileName,
        // show download progress in status bar (for Android)
        openFileFromNotification:
            false, // click on notification to open downloaded file (for Android)
      ) /*.then((value) {
        taskId = value;
      })*/
          ;
      var tasks = await FlutterDownloader.loadTasks();
      debugPrint("File path");
    } catch (e) {
      print("Error downloading");
      print(e.toString());
    }
  }

  void _bindBackgroundIsolate() {
    ReceivePort _port = ReceivePort();
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      debugPrint("download progress : $progress");
      progressKey.currentState!.setProgress(progress / 100);
      if (/*status == DownloadTaskStatus.complete*/ status.toString() ==
              "DownloadTaskStatus(3)" &&
          progress == 100) {
        debugPrint("Successfully downloaded");
        final snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text("Successfully downloaded to Path\n$saveFilePath"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context).pop();
        //pr.hide();
        /*String query = "SELECT * FROM task WHERE task_id='" + id + "'";
        var tasks = FlutterDownloader.loadTasksWithRawQuery(query: query);
        if (tasks != null) FlutterDownloader.open(taskId: id);*/
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ), toolbarTextStyle: TextTheme(
            titleMedium: TextStyle(
                color: Colors.white,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical !* 2.5)).bodyMedium, titleTextStyle: TextTheme(
            titleMedium: TextStyle(
                color: Colors.white,
                fontFamily: "Ubuntu",
                fontSize: SizeConfig.blockSizeVertical !* 2.5)).titleLarge,
      ),
      body:
          /*Text(widget.mediaItem.title),
              Text(widget.mediaItem.artist),*/
          StreamBuilder<PlayerState>(
        stream: _player!.playerStateStream,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          final state = playerState?.processingState;
          final processingState = playerState?.processingState;
          final playing = playerState?.playing;
          //final buffering = state?.;
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible:
                          playing! && processingState == ProcessingState.ready,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 60,
                        height: SizeConfig.blockSizeHorizontal !* 60,
                        child: IconButton(
                          icon: Icon(Icons.music_note, color: Colors.blueAccent),
                          onPressed: () => (){},
                        )
                        // Lottie.asset(
                        //   'assets/json/lottie_visualizer.json',
                        //   width: SizeConfig.blockSizeHorizontal !* 60,
                        //   height: SizeConfig.blockSizeHorizontal !* 60,
                        //   fit: BoxFit.fill,
                        // )
                      ),
                    ),
                    Visibility(
                      visible:
                          !playing || processingState != ProcessingState.ready,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal !* 60,
                        height: SizeConfig.blockSizeHorizontal !* 60,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 20),
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal !* 60,
                          height: SizeConfig.blockSizeHorizontal !* 60,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.grey),
                        ),
                      ),
                    ),
                    Text(
                      currentMediaItem!.title!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.blockSizeHorizontal !* 6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical !* 1.5,
                    ),
                    Text(
                      currentMediaItem!.artist!,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: SizeConfig.blockSizeHorizontal !* 4.5,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical !* 3,
                    )
                  ],
                )),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currentIndex > 0)
                      IconButton(
                        icon: Icon(Icons.skip_previous),
                        iconSize: SizeConfig.blockSizeHorizontal !* 16,
                        onPressed: () {
                          previousNext("prev");
                        },
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.skip_previous),
                        iconSize: SizeConfig.blockSizeHorizontal !* 16,
                        color: Colors.grey,
                        onPressed: null,
                      ),
                    if (playerState?.processingState ==
                            ProcessingState.loading ||
                        playerState?.processingState ==
                            ProcessingState.buffering)
                      Container(
                        margin: EdgeInsets.all(8.0),
                        width: SizeConfig.blockSizeHorizontal !* 16,
                        height: SizeConfig.blockSizeHorizontal !* 16,
                        child: CircularProgressIndicator(),
                      )
                    else if (playerState!.playing)
                      IconButton(
                        icon: Icon(Icons.pause),
                        iconSize: SizeConfig.blockSizeHorizontal !* 16,
                        onPressed: _player!.pause,
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        iconSize: SizeConfig.blockSizeHorizontal !* 16,
                        onPressed: _player!.play,
                      ),
                    if (currentIndex < widget.listMedia.length - 1)
                      IconButton(
                        icon: Icon(Icons.skip_next),
                        iconSize: SizeConfig.blockSizeHorizontal !* 16,
                        onPressed: () {
                          previousNext("next");
                        },
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.skip_next),
                        iconSize: SizeConfig.blockSizeHorizontal !* 16,
                        color: Colors.grey,
                        onPressed: null,
                      ),
                    /*SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 10,
                    ),*/
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.stop,
                    color: Colors.red,
                  ),
                  iconSize: SizeConfig.blockSizeHorizontal !* 16,
                  onPressed: !playerState!.playing ? null : _player!.stop,
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 2.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        downloadAndOpenTheFile(
                            currentMediaItem!.id!, currentMediaItem!.title!);
                      },
                      shape: CircleBorder(
                          side: BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      )),
                      padding:
                          EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3.2),
                      child: Image.asset(
                        "images/ic_download_meditation.png",
                        width: SizeConfig.blockSizeHorizontal !* 6.8,
                        fit: BoxFit.fill,
                        color: Colors.blue,
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {},
                      shape: CircleBorder(
                          side: BorderSide(
                        color: Colors.teal,
                        width: 2.0,
                      )),
                      padding:
                          EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 3.5),
                      child: Image.asset(
                        "images/ic_share_meditation.png",
                        width: SizeConfig.blockSizeHorizontal !* 6.0,
                        fit: BoxFit.fill,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 1.0,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  setPlayerUrl(String url) {
    _player = AudioPlayer();
    _player!.setUrl(url).then((value) {
      _player!.play();
    });
  }

  void previousNext(String type) {
    _player!.stop();
    if (type == "prev") {
      currentIndex = currentIndex - 1;
      currentMediaItem = widget.listMedia[currentIndex];
      _player = AudioPlayer();
      _player!.setUrl(currentMediaItem!.id!).then((value) {
        _player!.play();
      });
    } else {
      if (type == "next") {
        currentIndex = currentIndex + 1;
        currentMediaItem = widget.listMedia[currentIndex];
        _player = AudioPlayer();
        _player!.setUrl(currentMediaItem!.id!).then((value) {
          _player!.play();
        });
      }
    }
    setState(() {});
  }
}

class SeekBar extends StatefulWidget {
  final Duration? duration;
  final Duration? position;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  SeekBar({
    @required this.duration,
    @required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: 0.0,
      max: widget.duration!.inMilliseconds.toDouble(),
      value: _dragValue ?? widget.position!.inMilliseconds.toDouble(),
      onChanged: (value) {
        setState(() {
          _dragValue = value;
        });
        if (widget.onChanged != null) {
          widget.onChanged!(Duration(milliseconds: value.round()));
        }
      },
      onChangeEnd: (value) {
        _dragValue = null;
        if (widget.onChangeEnd != null) {
          widget.onChangeEnd!(Duration(milliseconds: value.round()));
        }
      },
    );
  }
}
