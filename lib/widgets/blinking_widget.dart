import 'dart:async';

import 'package:flutter/material.dart';

class BlinkingWidget extends StatefulWidget {
  final Widget? child;

  BlinkingWidget({this.child});

  @override
  BlinkingWidgetState createState() => BlinkingWidgetState();
}

class BlinkingWidgetState extends State<BlinkingWidget> {
  bool _show = true;
  Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (_) {
      setState(() => _show = !_show);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity: _show ? 1 : 0,
        duration: Duration(milliseconds: 250),
        child: widget.child,
      );

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
