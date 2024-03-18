import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:silvertouch/global/SizeConfig.dart';

//import 'package:store_redirect/store_redirect.dart';

class PopUpDialogWithImage extends StatelessWidget {
  String? imgUrl;

  //final Image image;

  PopUpDialogWithImage({@required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    //ViewProfileDetailsState.image = "";
    /*ViewProfileDetailsState.stream = _controller.stream;
    ViewProfileDetailsState.stream.listen((image) {

    });*/
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context, imgUrl!),
    );
  }
}

dialogContent(BuildContext context, String imgUrl) {
  SizeConfig().init(context);

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    //var base64str =
    return base64.encode(bytes);
    //= Base64Encoder().convert()
  }

  String decodeBase64(String text) {
    //var bytes = utf8.encode(text);
    //var base64str =
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
    //= Base64Encoder().convert()
  }

  return Container(
    width: SizeConfig.blockSizeHorizontal! * 90,
    padding: EdgeInsets.only(
      top: Consts.padding / 2,
      bottom: Consts.padding / 2,
      left: Consts.padding / 2,
      right: Consts.padding / 2,
    ),
    decoration: new BoxDecoration(
      color: Colors.transparent,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(Consts.padding),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10.0,
          offset: const Offset(0.0, 10.0),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MaterialButton(
          color: Colors.transparent,
          padding: EdgeInsets.all(5.0),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: EdgeInsets.all(5.0),
                color: Colors.white,
                child: Icon(
                  Icons.close,
                  size: 35.0,
                  color: Colors.black,
                ),
              )),
        ),
        CachedNetworkImage(
          placeholder: (context, url) => Image(
            image: AssetImage('images/shimmer_effect.png'),
            fit: BoxFit.cover,
          ),
          /*imageUrl: "$baseURL${listViewPagerImages[i]}",*/
          imageUrl: "$imgUrl",
          fit: BoxFit.cover,
        ),
        /*MaterialButton(
              onPressed: () {},
              child: Image(
                width: 60,
                height: 60,
                //height: 80,
                image: AssetImage("images/ic_camera.png"),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            MaterialButton(
              onPressed: () {},
              child: Image(
                width: 60,
                height: 60,
                //height: 80,
                image: AssetImage("images/ic_gallery.png"),
              ),
            ),*/
      ],
    ),
  );
}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}
