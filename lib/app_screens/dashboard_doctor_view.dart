import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class DashBoardDoctorWebView extends StatefulWidget {
  final String url;

  DashBoardDoctorWebView({required this.url});

  @override
  _DashBoardDoctorWebViewState createState() => _DashBoardDoctorWebViewState();
}

class _DashBoardDoctorWebViewState extends State<DashBoardDoctorWebView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("WebView Example"),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(13.0),
        child: WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
