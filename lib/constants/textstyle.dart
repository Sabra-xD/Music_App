import 'package:flutter/material.dart';

OurStyle({double? fontSize = 14, Color? textColor = Colors.white}) {
  return TextStyle(
    fontSize: fontSize,
    color: textColor,
  );
}

SongStyle() {
  return const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
