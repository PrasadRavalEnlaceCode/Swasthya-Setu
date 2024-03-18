import 'package:flutter/material.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/color.dart';

class WebViewContainer extends StatefulWidget {
  final url;
  WebViewContainer(this.url);
  @override
  createState() => _WebViewContainerState(this.url);
}
class _WebViewContainerState extends State<WebViewContainer> {
  var _url;
  final _key = UniqueKey();

  _WebViewContainerState(this._url);

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
                      backgroundColor: Colors.white,
                      title: new Text("Poster"),
                      leading: new IconButton(
                          icon: new Icon(Icons.arrow_back_ios, color: Colorsblack),
                          onPressed: () => {
                                Navigator.of(context).pop(),
                              }),
                      iconTheme: IconThemeData(
                          color: Colorsblack,
                          size: SizeConfig.blockSizeVertical !* 2.2), toolbarTextStyle: TextTheme(
                          subtitle1: TextStyle(
                              color: Colorsblack,
                              fontFamily: "Ubuntu",
                              fontSize: SizeConfig.blockSizeVertical !* 2.3)).bodyText2, titleTextStyle: TextTheme(
                          subtitle1: TextStyle(
                              color: Colorsblack,
                              fontFamily: "Ubuntu",
                              fontSize: SizeConfig.blockSizeVertical !* 2.3)).headline6,
                    ),
        body: Column(
          children: [
            Expanded(
                child: WebView(
                    key: _key,
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: _url))
          ],
        ));
  }
}