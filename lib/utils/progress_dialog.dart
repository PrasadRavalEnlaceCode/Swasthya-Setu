import 'package:flutter/material.dart';
import 'package:silvertouch/global/SizeConfig.dart';

class ProgressDialog {
  BuildContext context;
  bool isShowing = false;

  ProgressDialog(this.context) {
    hide();
  }

  show() {
    if (!isShowing) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CustomProgressDialog(hide),
      );
      isShowing = true;
    }
  }

  hide() {
    if (isShowing) {
      Navigator.of(context).pop();
      isShowing = false;
    }
  }

  setProgress(int progressLocal) {
    if (progressLocal <= 100) {
      /*hide();
      progress = progressLocal;
      show();*/
    }
  }
}

class CustomProgressDialog extends StatefulWidget {
  final Function hideFn;

  CustomProgressDialog(this.hideFn);

  @override
  State<StatefulWidget> createState() {
    return CustomProgressDialogState();
  }
}

class CustomProgressDialogState extends State<CustomProgressDialog>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1500))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  /*setProgress(int progressLocal) {
    setState(() {
      widget.progress = progressLocal;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Dialog(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: /*Stack(
        alignment: Alignment.center,
        children: [*/
            WillPopScope(
          child: Center(
            child: FadeTransition(
              opacity: animationController!,
              child: Container(
                width: SizeConfig.blockSizeHorizontal! * 23,
                height: SizeConfig.blockSizeHorizontal! * 23,
                decoration: BoxDecoration(
                  /*shape: BoxShape.circle,*/
                  borderRadius: BorderRadius.circular(
                      SizeConfig.blockSizeHorizontal! * 6.0),
                  color: Color(0xFFFFFFFF),
                ),
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 2),
                child: Image(
                  /*image: AssetImage("images/ic_doctor_loading.png"),*/
                  image: AssetImage("images/logo_silver_touch.jpg"),
                  width: SizeConfig.blockSizeHorizontal! * 23,
                  height: SizeConfig.blockSizeHorizontal! * 23,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          onWillPop: _onWillPop,
          /*Container(
            width: SizeConfig.blockSizeHorizontal * 24,
            height: SizeConfig.blockSizeHorizontal * 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                Colors.black,
              ),
            ),
          ),*/
          /*],
      ),*/
        ));
  }

  Future<bool> _onWillPop() {
    return (widget.hideFn()!) ?? false;
  }
}
