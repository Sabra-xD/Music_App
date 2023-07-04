import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
OurStyle({double? fontSize = 14, Color? textColor = Colors.white}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.bold,
    color: textColor,
  );
}

// ignore: non_constant_identifier_names
SongStyle() {
  return const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

uniformPadding() {
  return const EdgeInsets.all(20);
}

songListPadding() {
  return const EdgeInsets.all(5);
}

Color progressIndicatorColor = Colors.purple.shade300;
