
import 'package:flutter/material.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';

class ProgressDialogWithPercentage extends StatefulWidget {
  final String title;
  ProgressDialogWithPercentage({Key? key, this.title = "Processing"}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ProgressDialogWithPercentageState();
  }
}

class ProgressDialogWithPercentageState
    extends State<ProgressDialogWithPercentage>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  setProgress(double progressValue) {
    setState(() {
      progress = progressValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Dialog(
        elevation: 0.0,
        backgroundColor: Colors.white,
        child: Container(
            width: SizeConfig.blockSizeVertical !* 18,
            height: SizeConfig.blockSizeVertical !* 18,
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal !* 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  (progress * 100).floor() != 100
                      ? "${widget.title}... ${(progress * 100).floor()}%"
                      : "${widget.title}... 99%",
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal !* 4.3,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical !* 3.0,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.all(
                      Radius.circular(SizeConfig.blockSizeVertical !* 1.0)),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.green[100],
                    valueColor: AlwaysStoppedAnimation(Colors.green[600]),
                    minHeight: SizeConfig.blockSizeVertical !* 1.0,
                  ),
                ),
              ],
            )));
  }
}
