import 'dart:async';
import 'package:flutter/material.dart';

class BlinkingCard extends StatefulWidget {
  final Widget child;
  final Duration blinkDuration;

  const BlinkingCard({
    required this.child,
    this.blinkDuration = const Duration(milliseconds: 700),
  });

  @override
  _BlinkingCardState createState() => _BlinkingCardState();
}

class _BlinkingCardState extends State<BlinkingCard> {
  bool _show = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.blinkDuration, (_) {
      setState(() => _show = !_show);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _show ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}