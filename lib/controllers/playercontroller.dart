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
  bool wasPaused = false;
  @override
  void onInit() {
    //Triggered when initialized
    checkPermission();
    super.onInit();
  }

  // ignore: non_constant_identifier_names
  void eventListener(index, List<SongModel> SongsList) {
    _AudioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        wasPaused = false;
        int newSong = index + 1;
        playIndex.value = newSong;
        playSong(SongsList[playIndex.value].uri, playIndex.value, SongsList);
      }
    });
  }

//IF ID is 0 Then play previous song if ID is 1 then play next Song
  void playPreviousOrNextSong(List<SongModel> SongsList, int ID) {
    if (ID == 0) {
      playIndex.value = playIndex.value - 1;
      playSong(SongsList[playIndex.value].uri, playIndex.value, SongsList);
    }
    if (ID == 1) {
      playIndex.value = playIndex.value + 1;
      playSong(SongsList[playIndex.value].uri, playIndex.value, SongsList);
    }
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

  // ignore: non_constant_identifier_names
  void playSong(String? uri, index, List<SongModel> SongsList) {
    try {
      if (!wasPaused) {
        _AudioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
      }

      _AudioPlayer.play();
      playIndex.value = index;
      isPlaying(true);
      wasPaused = false;
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
      wasPaused = true;
    }
  }

  void removeRecordingandOrder(List<SongModel> Songs) {
    Songs.removeWhere((Song) => Song.displayNameWOExt.startsWith("AUD"));
    Songs.sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
  }
}
