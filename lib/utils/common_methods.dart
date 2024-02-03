
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:share_plus/share_plus.dart';

// shareFiles(BuildContext context,String imgName) async {
//   final box = context.findRenderObject() as RenderBox?;
//   final file = <XFile>[];
//   file.add(XFile(imgName, name: imgName));
//   await Share.shareXFiles(file,
//       text: 'Share Chart via',
//       subject: '$imgName',
//       sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
// }

void shareImage(GlobalKey globalKey) async {
  ShareFilesAndScreenshotWidgets().shareScreenshot(
      globalKey,
      800,
      "Share Via",
      "shareimg.png",
      "image/png",
      text: "");
}

void downloadAndOpenTheFile(String url,String fileName) async {
  // var tempDir = Platform.isAndroid
  //     ? await getTemporaryDirectory()
  //     : await getApplicationDocumentsDirectory();
  // await tempDir.create(recursive: true);
  // String fullPath = tempDir!.path + "/$fileName";
  print('url $url fileName $fileName');
  var fullPath = '/storage/emulated/0/Download/$fileName';
  debugPrint("full path");
  debugPrint(fullPath);
  Dio dio = Dio();
  downloadFileAndOpenActually(dio,url,fullPath);
}

Future downloadFileAndOpenActually(Dio dio, String url,String savePath) async {
  print('downloadFileAndOpenActually $savePath');
  try {
    Response response = await dio.get(
      url,
      onReceiveProgress: showDownloadProgress,
      //Received data with List<int>
      options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          }),
    );
    print(response.headers);
    File file = File(savePath);
    var raf = file.openSync(mode: FileMode.write);
    // response.data is List<int> type
    raf.writeFromSync(response.data);
    await raf.close();
    await openFile(savePath);
  } catch (e) {
    print('Error downloading');
    print(e);
  }
}

void showDownloadProgress(received, total) {
  if (total != -1) {
    print((received / total * 100).toStringAsFixed(0) + "%");
  }
}

var _openResult = 'Unknown';
Future<void> openFile(filePath) async
{
  print('filePath $filePath');
  final result = await OpenFilex.open(filePath);
  // setState(() {
  //   _openResult = "type=${result.type}  message=${result.message}";
  // });
}