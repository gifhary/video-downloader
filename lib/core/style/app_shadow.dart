import 'package:flutter/material.dart';

class AppShadow {
  static List<BoxShadow> primary = [
    BoxShadow(
        color: Colors.black.withOpacity(0.2),
        offset: const Offset(0, 4),
        blurRadius: 10,
        spreadRadius: 1)
  ];
}
