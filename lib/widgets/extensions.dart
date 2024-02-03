import 'package:flutter/widgets.dart';

extension WidgetExtension on Widget {
  Widget pA(double x) => Padding(
        padding: EdgeInsets.all(x),
        child: this,
      );

  Widget pS({double horizontal = 0, double vertical = 0}) => Padding(
        padding:
            EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        child: this,
      );

  Widget pO(
          {double left = 0,
          double right = 0,
          double top = 0,
          double bottom = 0}) =>
      Padding(
        padding: EdgeInsets.only(
          left: left,
          right: right,
          top: top,
          bottom: bottom,
        ),
        child: this,
      );

  Widget expanded() => Expanded(
        child: this,
      );
}
