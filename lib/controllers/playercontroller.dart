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
  var isPlaying = false.obs;
  var playIndex = 0.obs;
  @override
  void onInit() {
    //Triggered when initialized
    checkPermission();
    super.onInit();
  }

  void checkPermission() async {
    if (!kIsWeb) {
      print(AudioQueryx.permissionsStatus());
      bool permissionStatus = await AudioQueryx.permissionsRequest();

      print(permissionStatus);
      if (!permissionStatus) {
        await AudioQueryx.permissionsRequest();
      }
    }
  }

  void playSong(String? uri, index) {
    try {
      _AudioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
      _AudioPlayer.play();
      playIndex.value = index;
      isPlaying(true);
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  void removeRecordingandOrder(List<SongModel> Songs) {
    Songs.removeWhere((Song) => Song.displayNameWOExt.startsWith("AUD"));
    Songs.sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
  }
}
