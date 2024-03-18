import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:silvertouch/global/SizeConfig.dart';

//import 'package:store_redirect/store_redirect.dart';

class CustomDialogSelectImage extends StatelessWidget {
  String? title;
  Function? callback;
  StreamController<String> _controller = StreamController<String>.broadcast();
  final picker = ImagePicker();

  //final Image image;

  CustomDialogSelectImage({@required this.title, this.callback
      //this.image,
      });

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
      child: dialogContent(context, title!, _controller, callback),
    );
  }
}

dialogContent(BuildContext context, String title, _controller, callback) {
  SizeConfig().init(context);

  Future getImageFromCamera() async {
    /*PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
    File imgSelected = File(pickedFile.path);*/
  }

  Future getImageFromGallery() async {
    /*PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
    File imgSelected = File(pickedFile.path);*/
  }

  return Stack(
    children: <Widget>[
      //...bottom card part,
      Container(
        width: SizeConfig.blockSizeHorizontal! * 90,
        padding: EdgeInsets.only(
          top: Consts.padding / 2,
          bottom: Consts.padding / 2,
          left: Consts.padding / 2,
          right: Consts.padding / 2,
        ),
        decoration: new BoxDecoration(
          color: Colors.white,
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
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MaterialButton(
                  onPressed: () {
                    getImageFromCamera();
                  },
                  child: Image(
                    width: 70,
                    height: 70,
                    //height: 80,
                    image: AssetImage("images/ic_camera.png"),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                MaterialButton(
                  onPressed: () {
                    getImageFromGallery();
                  },
                  child: Image(
                    width: 70,
                    height: 70,
                    //height: 80,
                    image: AssetImage("images/ic_gallery.png"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      //...top circlular image part,
      /*Positioned(
        left: Consts.padding,
        right: Consts.padding,
        child: CircleAvatar(
          backgroundColor: Colors.deepOrangeAccent,
          radius: Consts.avatarRadius,
          child: image,
        ),
      ),*/
    ],
  );
}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}
