// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayxController extends GetxController {
  final onInitailize = true.obs;

  final AudioQueryx = OnAudioQuery();
  final _AudioPlayer = AudioPlayer();
  final SearchController = TextEditingController();
  var isPlaying = false.obs;
  var playIndex = 0.obs;

  late int currentlyPlaying;

  var duration = ''.obs;
  var position = ''.obs;

  var maxDuration = 0.0.obs;
  var value = 0.0.obs;
  bool wasPaused = false;

  int count = 0;
  var mode = true.obs; //Mode true then normal false then shuffle
  final readSongsList = <SongModel>[].obs;

  final savedSongsList = <SongModel>[].obs;
  // RxList<SongModel> readSongsList = <SongModel>[].obs;
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

  void eventListener(index) {
    _AudioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        wasPaused = false;
        if (mode.value) {
          int newSong = index + 1;
          playIndex.value = newSong;
          playSong(readSongsList[playIndex.value].uri, playIndex.value,
              readSongsList);
        } else {
          final random = Random();
          playIndex.value = random.nextInt(readSongsList.length);
          playSong(readSongsList[playIndex.value].uri, playIndex.value,
              readSongsList);
        }
      }
    });
  }

//IF ID is 0 Then play previous song if ID is 1 then play next Song
  void playPreviousOrNextSong(int ID) {
    if (ID == 0) {
      if (mode.value) {
        playIndex.value = playIndex.value - 1;
        playSong(
            readSongsList[playIndex.value].uri, playIndex.value, readSongsList);
      } else {
        int index = playedSongsIndex.last;

        playIndex.value = index;

        playedSongs.removeLast();
        playedSongsIndex.removeLast();
      }
      wasPaused = false;
    }
    if (ID == 1) {
      if (mode.value) {
        playIndex.value = playIndex.value + 1;
        playSong(
            readSongsList[playIndex.value].uri, playIndex.value, readSongsList);
        wasPaused = false;
      } else {
        //Choosing the Index or Song at random
        final random = Random();
        playIndex.value = random.nextInt(readSongsList.length);
        playSong(
            readSongsList[playIndex.value].uri, playIndex.value, readSongsList);
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

  void playSong(String? uri, int index, List<SongModel> SongsList) {
    try {
      if (!wasPaused || playIndex.value != index) {
        _AudioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
        playedSongs.add(uri);
        isPlaying(true);
        playedSongsIndex.add(index);
      }

      _AudioPlayer.play();
      playIndex.value = index;
      isPlaying(true);
      wasPaused = false;
      updatePositon();
      eventListener(index);
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

  int getSongsListCount(List<SongModel> Songs) {
    return Songs.length;
  }

  void removeRecordingandOrder(List<SongModel> Songs) {
    Songs.removeWhere((Song) => Song.displayNameWOExt.startsWith("AUD"));

    Songs.sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
    print("Returned Songs Length : ${Songs.length}");
  }

  bool checkPage(String page) {
    if (page == "HomeScreen") {
      return true;
    } else {
      return false;
    }
  }

  void search(List<SongModel> Songs, String search) {
    savedSongsList
        .removeWhere((Song) => Song.displayNameWOExt.startsWith("AUD"));
    Songs = savedSongsList;
    if (search != '') {
      //Here we should find the songs that start with certain words.

      print("SEARCHING .....");
      Songs = Songs.where((str) => str.title.toLowerCase().contains(search))
          .toList();

      print("Searched songs list: ${Songs.length}");
    } else {
      print("NOT SEARCHING!.....");
      savedSongsList
          .removeWhere((Song) => Song.displayNameWOExt.startsWith("AUD"));
      Songs = savedSongsList;
      print("Saved Songs list: ${Songs.length}");
    }
    Songs.sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
    readSongsList.value = Songs;
  }
}
