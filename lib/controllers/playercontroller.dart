import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayxController extends GetxController {
  final AudioQueryx = OnAudioQuery();
  final _AudioPlayer = AudioPlayer();
  final SearchController = TextEditingController();

  @override
  void onInit() {
    //Triggered when initialized
    checkPermission();
    super.onInit();
  }

  void checkPermission() async {
    // var perm = await Permission.storage.request();

    print("Checking permission");
    // AudioQueryx.permissionsStatus();
    print(kIsWeb);
    if (!kIsWeb) {
      print(AudioQueryx.permissionsStatus());
      bool permissionStatus = await AudioQueryx.permissionsRequest();

      print(permissionStatus);
      if (!permissionStatus) {
        await AudioQueryx.permissionsRequest();
      }
    }
  }

  void playSong(String? uri) {
    try {
      //We play the Audio Here.
      _AudioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
      _AudioPlayer.play();
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}
