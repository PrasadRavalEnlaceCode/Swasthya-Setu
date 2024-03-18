library flutter_echarts;

// --- FIX_BLINK ---
import 'dart:io';
// --- FIX_BLINK ---

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_echarts/echarts_script.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/utils/common_methods.dart';

/// <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0, target-densitydpi=device-dpi" /><style type="text/css">body,html,#chart{height: 100%;width: 100%;margin: 0px;}div {-webkit-tap-highlight-color:rgba(255,255,255,0);}</style></head><body><div id="chart" /></body></html>
/// 'data:text/html;base64,' + base64Encode(const Utf8Encoder().convert( /* STRING ABOVE */ ))
const htmlBase64 =
    'data:text/html;base64,PCFET0NUWVBFIGh0bWw+PGh0bWw+PGhlYWQ+PG1ldGEgY2hhcnNldD0idXRmLTgiPjxtZXRhIG5hbWU9InZpZXdwb3J0IiBjb250ZW50PSJ3aWR0aD1kZXZpY2Utd2lkdGgsIGluaXRpYWwtc2NhbGU9MS4wLCBtYXhpbXVtLXNjYWxlPTEuMCwgbWluaW11bS1zY2FsZT0xLjAsIHVzZXItc2NhbGFibGU9MCwgdGFyZ2V0LWRlbnNpdHlkcGk9ZGV2aWNlLWRwaSIgLz48c3R5bGUgdHlwZT0idGV4dC9jc3MiPmJvZHksaHRtbCwjY2hhcnR7aGVpZ2h0OiAxMDAlO3dpZHRoOiAxMDAlO21hcmdpbjogMHB4O31kaXYgey13ZWJraXQtdGFwLWhpZ2hsaWdodC1jb2xvcjpyZ2JhKDI1NSwyNTUsMjU1LDApO308L3N0eWxlPjwvaGVhZD48Ym9keT48ZGl2IGlkPSJjaGFydCIgLz48L2JvZHk+PC9odG1sPg==';

class EchartsCustom extends StatefulWidget {
  EchartsCustom(
      {Key? key,
      @required this.option,
      this.extraScript = '',
      this.onMessage,
      this.extensions = const [],
      this.theme,
      this.captureAllGestures = false,
      this.captureHorizontalGestures = false,
      this.captureVerticalGestures = false,
      this.onLoad,
      this.reloadAfterInit = true})
      : super(key: key);

  final String? option;

  final String extraScript;

  final void Function(String message)? onMessage;

  final List<String> extensions;

  final String? theme;

  final bool captureAllGestures;

  final bool captureHorizontalGestures;

  final bool captureVerticalGestures;

  final void Function()? onLoad;

  final bool reloadAfterInit;

  @override
  _EchartsCustomState createState() => _EchartsCustomState();
}

class _EchartsCustomState
    extends State<EchartsCustom> /*with SingleTickerProviderStateMixin*/ {
  InAppWebViewController? _controller;
  String? _currentOption;

  bool isShareVisible = false;

  GlobalKey globalKey = GlobalKey();
  // --- FIX_BLINK ---
  double _opacity = Platform.isAndroid ? 0.0 : 1.0;

  /*AnimationController animationController;
  Animation<Offset> offset;*/
  bool processingImg = false;

  // --- FIX_BLINK ---

  @override
  void initState() {
    super.initState();
    _currentOption = widget.option;
    isShareVisible = false;
    if (widget.reloadAfterInit) {
      debugPrint("Reload EChart");
      reloadInHalfASecond();
    }
    /*animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    offset = Tween<Offset>(begin: Offset(2.0, 0.0), end: Offset.zero)
        .animate(animationController);*/
    /*setState(() {
      processingImg = true;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        processingImg = false;
      });
    });*/
  }

  void reloadInHalfASecond() {
    Future.delayed(const Duration(milliseconds: 500), () {
      debugPrint("reload called");
      /*var html = await */ //await _controller.clearCache();
      if (_controller != null)
        _controller!.reload();
      else
        reloadInHalfASecond();
    });
  }

  void init() async {
    /*final extensionsStr = this.widget.extensions.length > 0
        ? this
            .widget
            .extensions
            .reduce((value, element) => (value ?? '') + '\n' + (element ?? ''))
        : '';
    final themeStr =
        this.widget.theme != null ? '\'${this.widget.theme}\'' : 'null';
    await _controller?.evaluateJavascript(source: '''
      $echartsScript
      $extensionsStr
      var chart = echarts.init(document.getElementById('chart'), $themeStr);
      ${this.widget.extraScript}
      chart.setOption($_currentOption, true);
    ''');
    if (widget.onLoad != null) {
      widget.onLoad();
    }*/
    final extensionsStr = this.widget.extensions.length > 0
        ? this
            .widget
            .extensions
            .reduce((value, element) => value + '\n' + element)
        : '';
    final themeStr =
        this.widget.theme != null ? '\'${this.widget.theme}\'' : 'null';
    await _controller?.evaluateJavascript(
        source:
            '''
      $echartsScript
      $extensionsStr
      var chart = echarts.init(document.getElementById('chart'), $themeStr);
      ${this.widget.extraScript}
      chart.setOption($_currentOption, true);
    ''');
    if (widget.onLoad != null) {
      widget.onLoad!();
    }

    //if (!isShareVisible)
    await Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        isShareVisible = true;
        //_controller.reload();
      });
    });

    /*await Future.delayed(const Duration(milliseconds: 1000));

    var screenshot = await _controller?.takeScreenshot();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Image.memory(screenshot),
        );
      },
    );*/
  }

  Set<Factory<OneSequenceGestureRecognizer>> getGestureRecognizers() {
    Set<Factory<OneSequenceGestureRecognizer>> set = Set();
    if (this.widget.captureAllGestures ||
        this.widget.captureHorizontalGestures) {
      set.add(Factory<HorizontalDragGestureRecognizer>(() {
        return HorizontalDragGestureRecognizer()
          ..onStart = (DragStartDetails details) {
            //_controller.reload();
          }
          ..onUpdate = (DragUpdateDetails details) {}
          ..onDown = (DragDownDetails details) {}
          ..onCancel = () {}
          ..onEnd = (DragEndDetails details) {};
      }));
    }
    if (this.widget.captureAllGestures || this.widget.captureVerticalGestures) {
      set.add(Factory<VerticalDragGestureRecognizer>(() {
        return VerticalDragGestureRecognizer()
          ..onStart = (DragStartDetails details) {
            //_controller.reload();
          }
          ..onUpdate = (DragUpdateDetails details) {}
          ..onDown = (DragDownDetails details) {}
          ..onCancel = () {}
          ..onEnd = (DragEndDetails details) {};
      }));
    }
    return set;
  }

  void update(String preOption) async {
    _currentOption = widget.option;
    if (_currentOption != preOption) {
      await _controller?.evaluateJavascript(
          source:
              '''
        try {
          chart.setOption($_currentOption, true);
        } catch(e) {
        }
      ''');
    }
  }

  @override
  void didUpdateWidget(EchartsCustom oldWidget) {
    super.didUpdateWidget(oldWidget);
    update(oldWidget.option!);
  }

  // --- FIX_IOS_LEAK ---
  @override
  void dispose() {
    if (Platform.isIOS) {
      _controller!.clearCache();
    }
    super.dispose();
  }

  // --- FIX_IOS_LEAK ---

  @override
  Widget build(BuildContext context) {
    // --- FIX_BLINK ---
    SizeConfig().init(context);
    // implement scrollable physics
    return !processingImg
        ? ListView(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            children: <Widget>[
              Align(
                  alignment: Alignment.topRight,
                  child: AnimatedOpacity(
                    duration: Duration(seconds: 1),
                    opacity: isShareVisible ? 1.0 : 0,
                    child: InkWell(
                        onTap: () {
                          // getImageAndShare();
                          shareImage(globalKey);
                        },
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          color: Colors.white,
                          child: Icon(
                            Icons.share,
                            size: 35.0,
                            color: Colors.green,
                          ),
                        )),
                  )),
              Visibility(
                visible: !isShareVisible,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
              RepaintBoundary(
                key: globalKey,
                child: Opacity(
                  opacity: _opacity,
                  // --- FIX_BLINK ---
                  /*child: SlideTransition(
                  position: offset,*/
                  child: Container(
                    height: SizeConfig.blockSizeVertical! * 50,
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(url: Uri.parse(htmlBase64)),
                      //initialUrl: 'https://www.google.com/',
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          useShouldOverrideUrlLoading: true,
                          useOnLoadResource: true,
                          javaScriptEnabled: true,
                          incognito: true,
                          mediaPlaybackRequiresUserGesture: false,
                          clearCache: true,
                          javaScriptCanOpenWindowsAutomatically: false,
                        ),
                        android: AndroidInAppWebViewOptions(
                            hardwareAcceleration: false),
                        ios: IOSInAppWebViewOptions(
                            allowsInlineMediaPlayback: true),
                      ),
                      /*javascriptMode: JavascriptMode.unrestricted,*/
                      onWebViewCreated:
                          (InAppWebViewController webViewController) {
                        _controller = webViewController;
                      },
                      onLoadError: (controller, url, code, message) {
                        debugPrint(
                            "Error in Loading EChart - ${message.toString()}");
                        _controller!.reload();
                      },
                      onLoadHttpError: (InAppWebViewController? controller,
                          Uri? url, int? code, String? error) {
                        debugPrint("Error in Loading EChart - $error");
                        _controller!.reload();
                      },
                      onLoadStop:
                          (InAppWebViewController? controller, Uri? url) async {
                        //if (Platform.isAndroid) {
                        setState(() {
                          _opacity = 1.0;
                        });
                        //}
                        init();
                      },
                      gestureRecognizers: getGestureRecognizers(),
                    ),
                  ),
                ),
              )
            ],
          )
        : Center(
            child: Text("Processing image, please wait...."),
          );
  }

  // void getImageAndShare() async {
  //   /*ProgressDialog pr = ProgressDialog(context);
  //   pr.show();*/
  //   setState(() {
  //     processingImg = true;
  //   });
  //   Uint8List screenshotBytes = await _controller.takeScreenshot();
  //   var tempDir = await getTemporaryDirectory();
  //   //await tempDir.create(recursive: true);
  //   String fullPath = tempDir.path + "/sharechart.png";
  //   /*File originalFile = File(fullPath);
  //   originalFile.writeAsBytesSync(screenshotBytes);
  //   */
  //   ByteData byteData;
  //   byteData = await rootBundle.load('images/swasthya_setu_watermark_logo.png');
  //   /*File waterMarkFile = File('${tempDir.path}/swasthya_setu_watermark_logo.png');
  //   waterMarkFile.writeAsBytesSync(byteData.buffer.asUint8List());*/
  //   image.Image originalImg = image.decodeImage(screenshotBytes);
  //   image.Image waterMarkImg = image.decodeImage(byteData.buffer.asUint8List());
  //   image.Image blankImg = image.Image(450, 450);
  //   image.drawImage(blankImg, waterMarkImg);
  //   image.copyInto(originalImg, blankImg,
  //       dstX: (originalImg.width / 2 - blankImg.width / 2)
  //           .round() /*originalImg.width - 160 - 25*/,
  //       dstY: (originalImg.height / 2 - blankImg.height / 2)
  //           .round() /*originalImg.height - 50 - 25*/);
  //   List<int> wmImage = image.encodePng(originalImg);
  //   File waterMarkedImg = File.fromRawPath(Uint8List.fromList(wmImage));
  //   /*rootBundle.load('images/swasthya_setu_logo.jpeg').then((value) => {
  //         byteData = value,
  //         getTemporaryDirectory().then((value) => {
  //               tempDir = value,
  //               file = File('${tempDir.path}/swasthya_setu_logo.jpeg'),
  //               file.writeAsBytes(byteData.buffer.asUint8List(
  //                   byteData.offsetInBytes, byteData.lengthInBytes)),
  //               waterMarkFile = file,
  //             })
  //       });*/
  //   //pr.hide();
  //   setState(() {
  //     processingImg = false;
  //   });
  //   if (screenshotBytes != null)
  //     WcFlutterShare.share(
  //       sharePopupTitle: "Share Chart via",
  //       mimeType: 'image/png',
  //       fileName: "sharechart.png",
  //       bytesOfFile: Uint8List.fromList(wmImage),
  //     );
  //   else {
  //     debugPrint("imgfile is null");
  //   }
  // }
}
