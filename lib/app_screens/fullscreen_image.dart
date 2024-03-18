import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:silvertouch/controllers/full_screen_image_controller.dart';
import 'package:silvertouch/global/SizeConfig.dart';

import 'package:http/http.dart' show get;

class FullScreenImage extends StatelessWidget {
  String imgUrl;
  bool showCloseIcon = true;
  String? heroTag;
  bool showPlaceholder;

  FullScreenImage(this.imgUrl, {this.heroTag, this.showPlaceholder = false});

  @override
  Widget build(BuildContext context) {
    FullScreenImageController fullScreenController =
        Get.put(FullScreenImageController());
    SizeConfig().init(context);
    return Scaffold(body: Builder(
      builder: (context) {
        return SafeArea(
          child: Container(
            color: Colors.black,
            child: Stack(
              children: [
                /*Column(
                  children: <Widget>[
                    Expanded(
                      child: heroTag != null
                          ? Hero(
                              tag: heroTag,
                              child: PhotoView(
                                imageProvider: !showPlaceholder
                                    ? NetworkImage(imgUrl)
                                    : AssetImage(
                                        "images/ic_user_placeholder.png"),
                              ),
                            )
                          : PhotoView(
                              imageProvider: !showPlaceholder
                                  ? NetworkImage(imgUrl)
                                  : AssetImage(
                                      "images/ic_user_placeholder.png"),
                            ),
                    ),
                  ],
                ),*/
                InkWell(
                  onTap: () {
                    fullScreenController.showHeader.value =
                        !fullScreenController.showHeader.value;
                  },
                  child: heroTag != null
                      ? Hero(
                          tag: heroTag!,
                          child: PhotoView(imageProvider: NetworkImage(imgUrl)),
                        )
                      : PhotoView(imageProvider: NetworkImage(imgUrl)),
                ),
                Positioned(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 700),
                    child: Obx(() {
                      if (fullScreenController.showHeader.value) {
                        return Container(
                          width: SizeConfig.screenWidth,
                          height: SizeConfig.blockSizeVertical! * 8,
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
                          ),
                          color: Color(0xCC000000),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              /*FloatingActionButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        splashColor: Colors.grey,
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.keyboard_backspace,
                          color: Colors.white,
                          size: SizeConfig.blockSizeHorizontal * 8.0,
                        ),
                      ),*/
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  customBorder: CircleBorder(),
                                  splashColor: Colors.grey,
                                  child: Icon(
                                    Icons.keyboard_backspace,
                                    color: Colors.white,
                                    size: SizeConfig.blockSizeHorizontal! * 8.0,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        getAndShareImage(context);
                                      },
                                      customBorder: CircleBorder(),
                                      splashColor: Colors.grey,
                                      child: Icon(
                                        Icons.share,
                                        size: SizeConfig.blockSizeHorizontal! *
                                            8.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }),
                  ),
                )
              ],
            ),
          ),
        );
      },
    ));
  }

  void getAndShareImage(BuildContext context) async {
    var response = await get(Uri.parse(imgUrl));
    var bytes = response.bodyBytes;
    //  Directory tempDir = await getTemporaryDirectory();
    //  String tempPath = tempDir.path;
    //  var imgFile = File('$tempPath/sharechart.png');
    //  imgFile.writeAsBytesSync(response.bodyBytes);
    // shareFiles(context,imgFile.path);
    // WcFlutterShare.share(
    //   sharePopupTitle: "Share via",
    //   mimeType: 'image/jpg',
    //   fileName: "shareimg.jpg",
    //   bytesOfFile: bytes.buffer.asUint8List(),
    // );
    Uint8List list = bytes.buffer.asUint8List();
    ShareFilesAndScreenshotWidgets()
        .shareFile("Share via", "shareimg.jpg", list, "image/jpg", text: "");
  }

  getPhoto() {
    !showPlaceholder
        ? NetworkImage(imgUrl)
        : AssetImage("images/ic_user_placeholder.png");
  }
}
