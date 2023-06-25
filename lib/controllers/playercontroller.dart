import 'dart:math';

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
  int count = 0;
  var mode = true.obs; //Mode true then normal false then shuffle

  final playedSongs = <dynamic>[];
  final playedSongsIndex = <dynamic>[];
  @override
  void onInit() {
    checkPermission();
    super.onInit();
  }

  void changeMode() {
    mode.value = !mode.value;
  }

  // ignore: non_constant_identifier_names
  void eventListener(index, List<SongModel> SongsList) {
    _AudioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        wasPaused = false;
        if (mode.value) {
          int newSong = index + 1;
          playIndex.value = newSong;
          playSong(SongsList[playIndex.value].uri, playIndex.value, SongsList);
        } else {
          final random = Random();
          playIndex.value = random.nextInt(SongsList.length);
          playSong(SongsList[playIndex.value].uri, playIndex.value, SongsList);
        }
      }
    });
  }

//IF ID is 0 Then play previous song if ID is 1 then play next Song
  void playPreviousOrNextSong(List<SongModel> SongsList, int ID) {
    if (ID == 0) {
      if (mode.value) {
        playIndex.value = playIndex.value - 1;
        playSong(SongsList[playIndex.value].uri, playIndex.value, SongsList);
      } else {
        var uri = playedSongs.last;
        int index = playedSongsIndex.last;
        print(index);
        print(playedSongsIndex.length);
        print(playedSongsIndex);
        playIndex.value = index;
        print(playIndex.value);
        playSong(uri, index, SongsList);
        playedSongs.removeLast();
        playedSongsIndex.removeLast();
      }
      wasPaused = false;
    }
    if (ID == 1) {
      if (mode.value) {
        playIndex.value = playIndex.value + 1;
        playSong(SongsList[playIndex.value].uri, playIndex.value, SongsList);
        wasPaused = false;
      } else {
        //Choosing the Index or Song at random
        final random = Random();
        playIndex.value = random.nextInt(SongsList.length);
        playSong(SongsList[playIndex.value].uri, playIndex.value, SongsList);
        wasPaused = false;
      }
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
        playedSongs.add(uri);
        playedSongsIndex.add(index);
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
