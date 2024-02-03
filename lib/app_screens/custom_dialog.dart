import 'package:flutter/material.dart';

//import 'package:store_redirect/store_redirect.dart';
import 'package:launch_review/launch_review.dart';

class CustomDialog extends StatelessWidget {
  final String? title, description, buttonText;
  final Image? image;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context, title!, description!, buttonText!, image!),
    );
  }
}

dialogContent(BuildContext context, String title, String description,
    String buttonText, Image image) {
  return Stack(
    children: <Widget>[
      //...bottom card part,
      Container(
        padding: EdgeInsets.only(
          top: Consts.avatarRadius + Consts.padding,
          bottom: Consts.padding,
          left: Consts.padding,
          right: Consts.padding,
        ),
        margin: EdgeInsets.only(top: Consts.avatarRadius),
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
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 24.0),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: MaterialButton(
                        color: Colors.red,
                        onPressed: () {
                          Navigator.of(context).pop(); // To close the dialog
                        },
                        child: Text(
                          "Skip",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    )),
                Flexible(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: MaterialButton(
                        color: Colors.green,
                        onPressed: () {
                          LaunchReview.launch(
                            androidAppId: "com.swasthyasetu.swasthyasetu",
                            iOSAppId: "1495973373",
                            writeReview: false,
                          );
                          /*StoreRedirect.redirect(androidAppId: "in.eventprime.isacon2020",
                              iOSAppId: "1495973373");*/
                          Navigator.of(context).pop(); // To close the dialog
                        },
                        child: Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    )),
              ],
            ),
            /*Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // To close the dialog
                },
                child: Text(buttonText),
              ),
            ),*/
          ],
        ),
      ),

      //...top circlular image part,
      Positioned(
        left: Consts.padding,
        right: Consts.padding,
        child: CircleAvatar(
          backgroundColor: Colors.deepOrangeAccent,
          radius: Consts.avatarRadius,
          child: image,
        ),
      ),
    ],
  );
}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}
