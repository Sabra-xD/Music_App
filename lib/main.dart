import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/screens/homescreen.dart';
import 'package:music_app/screens/listsong.dart';
import 'package:music_app/screens/playerScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // is not restarted.
          textTheme: Theme.of(context)
              .textTheme
              .apply(bodyColor: Colors.white, displayColor: Colors.white)),
      home: playerScreen(),
    );
  }
}
