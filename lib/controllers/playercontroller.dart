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

  var duration = ''.obs;
  var position = ''.obs;

  var maxDuration = 0.0.obs;
  var value = 0.0.obs;
  @override
  void onInit() {
    //Triggered when initialized
    checkPermission();
    super.onInit();
  }

  void eventListener(index, List<SongModel> SongsList) {
    _AudioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        int newSong = index + 1;
        playIndex.value = newSong;
        playSong(SongsList[playIndex.value].uri, playIndex.value, SongsList);
      }
    });
  }

  void changePosition(seconds) {
    var newPositon = Duration(seconds: seconds);
    _AudioPlayer.seek(newPositon);
  }

  void updatePositon() {
    _AudioPlayer.durationStream.listen((d) {
      duration.value = d.toString().split(".")[0];
      maxDuration.value = d!.inSeconds.toDouble();
    });
    _AudioPlayer.positionStream.listen((p) {
      position.value = p.toString().split(".")[0];
      value.value = p.inSeconds.toDouble();
    });
  }

  void checkPermission() async {
    if (!kIsWeb) {
      bool permissionStatus = await AudioQueryx.permissionsRequest();
      if (!permissionStatus) {
        await AudioQueryx.permissionsRequest();
      }
    }
  }

  void playSong(String? uri, index, List<SongModel> SongsList) {
    try {
      _AudioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
      _AudioPlayer.play();
      playIndex.value = index;
      isPlaying(true);
      updatePositon();
      eventListener(index, SongsList);
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<void> pauseSong() async {
    if (isPlaying.value) {
      await _AudioPlayer.pause();
      isPlaying.value = false;
    }
  }

  void removeRecordingandOrder(List<SongModel> Songs) {
    Songs.removeWhere((Song) => Song.displayNameWOExt.startsWith("AUD"));
    Songs.sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
  }
}
