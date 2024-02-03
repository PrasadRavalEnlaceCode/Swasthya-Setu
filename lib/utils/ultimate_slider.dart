import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UltimateSlider extends StatefulWidget {
  final double minValue, maxValue;
  double value;

  final backgroundColor,
      bubbleColor,
      bubbleTextColor,
      indicatorColor,
      selectorColor,
      titleTextColor,
      unitTextColor;

  final ValueChangedCallback onValueChange;

  final double decimalInterval;

  final bool showDecimals;

  final String titleText, unitText;

  UltimateSlider({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onValueChange,
    this.backgroundColor = Colors.white,
    this.decimalInterval = 0.1,
    this.showDecimals = true,
    this.bubbleColor = Colors.amber,
    this.bubbleTextColor = Colors.black,
    this.indicatorColor = Colors.amber,
    this.selectorColor = Colors.black,
    this.unitTextColor = Colors.black,
    this.unitText = "",
    this.titleText = "",
    this.titleTextColor = Colors.black,
  });

  @override
  State<StatefulWidget> createState() {
    return UltimateSliderState();
  }
}

class UltimateSliderState extends State<UltimateSlider> {
  CarouselController carouselController = CarouselController();
  bool firstTime = true;

  @override
  void initState() {
    super.initState();
    /*debugPrint("init state called");
    debugPrint("min value - ${widget.minValue}");
    debugPrint("value - ${widget.value}");*/
    /*if (widget.value != widget.minValue) {
      int index;
      if (widget.showDecimals) {
        index =
            ((widget.value - widget.minValue) / widget.decimalInterval).toInt();
      } else
        index = (widget.value - widget.minValue).toInt();
      debugPrint("Got index ${index.toString()}");
      Future.delayed(Duration(milliseconds: 500), () {
        carouselController.animateToPage(index);
      });
    }*/
    /*else {
      Future.delayed(Duration(milliseconds: 1500), () {
        carouselController.jumpToPage(0);
        setState(() {});
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value != widget.minValue && firstTime) {
      //debugPrint("min value not there");
      int index;
      if (widget.showDecimals) {
        index =
            ((widget.value - widget.minValue) / widget.decimalInterval).toInt();
      } else
        index = (widget.value - widget.minValue).toInt();
      debugPrint("Got index ${index.toString()}");
      Future.delayed(Duration(milliseconds: 500), () {
        carouselController.animateToPage(index);
      });
      firstTime = false;
    }
    return
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: 5.0,
        ),
        color: widget.backgroundColor,
        child: Container(
          /*decoration: BoxDecoration(
              color: Colors.grey[200], border: Border.all(color: Colors.grey)),*/
          child: Stack(
            children: [
              Positioned(
                child: Column(
                  children: [
                    SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              widget.titleText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: widget.titleTextColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          widget.unitText,
                          style: TextStyle(
                            color: widget.unitTextColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                      ],
                    ),
                    /*SizedBox(height: 5.0,),
                    CustomPaint(
                      child: Container(
                        height: 60,
                        width: 60,
                        padding: EdgeInsets.only(
                          left: widget.showDecimals
                              ? 5.0
                              : widget.value.toInt().toString().length == 1
                              ? 20.0
                              : 15.0,
                          right: widget.showDecimals
                              ? 5.0
                              : widget.value.toInt().toString().length == 1
                              ? 20.0
                              : 15.0,
                          bottom: widget.showDecimals
                              ? 20
                              : widget.value.toInt().toString().length == 1
                              ? 20.0
                              : 15.0,
                        ),
                        child:
                        */ /*!widget.showDecimals &&
                      widget.value.toInt().toString().length == 1
                  ? Text(
                      widget.showDecimals
                          ? widget.value.toStringAsFixed(2)
                          : widget.value.toInt().toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        color: widget.bubbleTextColor,
                      ),
                    )
                  :*/ /*
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            widget.showDecimals
                                ? widget.value.toStringAsFixed(2)
                                : widget.value.toInt().toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                              color: widget.bubbleTextColor,
                            ),
                          ),
                        ),
                      ),
                      painter: BubblePainter(widget.bubbleColor),
                    ),*/
                  ],
                ),
              ),
              Positioned(
                bottom: 6,
                left: 0,
                right: 0,
                child: Center(
                  child:
                  CustomPaint(
                    child: Container(
                      height: 55,
                      width: 55,
                      padding: EdgeInsets.only(
                        left: widget.showDecimals
                            ? 5.0
                            : widget.value.toInt().toString().length == 1
                            ? 20.0
                            : 15.0,
                        right: widget.showDecimals
                            ? 5.0
                            : widget.value.toInt().toString().length == 1
                            ? 20.0
                            : 15.0,
                        top: widget.showDecimals
                            ? 20
                            : widget.value.toInt().toString().length == 1
                            ? 20.0
                            : 15.0,
                      ),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          widget.showDecimals
                              ? widget.value.toStringAsFixed(2)
                              : widget.value.toInt().toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                            color: widget.bubbleTextColor,
                          ),
                        ),
                      ),
                    ),
                    painter: BubblePainter(widget.bubbleColor),
                  ),
                ),
              ),
              CarouselSlider.builder(
                carouselController: carouselController,
                itemCount: widget.showDecimals
                    ? ((widget.maxValue - widget.minValue) /
                    widget.decimalInterval +
                    1)
                    .toInt()
                    : (widget.maxValue - widget.minValue).toInt() + 1,
                itemBuilder: (context, index, bla) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 50.0),
                    child: Container(
                        width: getWidgetWidthAndHeight(index),
                        height: getWidgetWidthAndHeight(index),
                        padding: EdgeInsets.symmetric(horizontal: 2.0),
                        decoration: BoxDecoration(
                          color: getIndicatorColor(index),
                          shape: BoxShape.circle,
                        )),
                  );
                },
                options: CarouselOptions(
                    height: /*200*/ 130,
                    viewportFraction: 0.05,
                    enableInfiniteScroll: false,
                    onPageChanged: (pageNo, reason) {
                      //debugPrint("Page changed to $pageNo");
                      setState(() {
                        if (widget.showDecimals)
                          widget.value =
                              widget.minValue + pageNo * widget.decimalInterval;
                        else
                          widget.value = widget.minValue + pageNo;
                      });
                       widget.onValueChange(widget.value);
                    }),
              ),
              Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      /*width: widget.showDecimals ? 22.0 : 35.0,
                          height: widget.showDecimals ? 22.0 : 35.0,*/
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.selectorColor,
                            width: 5.0,
                          ),
                        )),
                  )),
            ],
          ),
        ));
  }

  double getWidgetWidthAndHeight(int index) {
    if (widget.showDecimals) {
      if (index % 5 == 0)
        return 10.0;
      else
        return 4.0;
    } else {
      if ((widget.minValue + index) % 5 == 0)
        return 10.0;
      else
        return 4.0;
    }
  }

  Color getIndicatorColor(int index) {
    if (widget.showDecimals) {
      if (index % 5 != 0)
        return Colors.black;
      else
        return widget.indicatorColor;
    } else {
      if ((widget.minValue + index) % 5 == 0)
        return widget.indicatorColor;
      else
        return Colors.black;
    }

    /**/
  }
}

class BubblePainter extends CustomPainter {
  Color bubbleColor;

  BubblePainter(this.bubbleColor);

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    Paint paint = Paint();
    /*path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.3, size.height * 0.7);
    path.lineTo(size.width * 0.45, size.height);
    path.lineTo(size.width * 0.6, size.height * 0.7);
    path.lineTo(size.width, size.height * 0.7);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.lineTo(0, size.height * 0.7);*/
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.3);
    path.lineTo(size.width * 0.65, size.height * 0.3);
    path.lineTo(size.width * 0.5, 0);
    path.lineTo(size.width * 0.35, size.height * 0.3);
    path.lineTo(0, size.height * 0.3);
    path.lineTo(0, size.height);
    paint.color = bubbleColor;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

typedef void ValueChangedCallback(double value);
