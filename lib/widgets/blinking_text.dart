import 'dart:async';
import 'package:flutter/material.dart';

class BlinkingText extends StatefulWidget {
  final String _target;
  final TextStyle textStyle;

  BlinkingText(this._target,
      {this.textStyle = const TextStyle(color: Colors.black)});

  @override
  BlinkingTextState createState() => BlinkingTextState();
}

class BlinkingTextState extends State<BlinkingText> {
  bool _show = true;
  Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(Duration(milliseconds: 700), (_) {
      setState(() => _show = !_show);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Text(widget._target,
      style: _show
          ? widget.textStyle
          : widget.textStyle.copyWith(
              color: Colors.transparent,
            ));

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
