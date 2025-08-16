import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NoMouseApp extends StatelessWidget {
  final Widget child;
  const NoMouseApp({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: (_) {}, // absorb hover events
      child: child,
    );
  }
}
