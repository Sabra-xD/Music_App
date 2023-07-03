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
  void onInit() async {
    checkPermission();

    super.onInit();
  }

  void checkPermission() async {
    if (!kIsWeb) {
      bool permissionStatus = await AudioQueryx.permissionsRequest();

      if (!permissionStatus) {
        await AudioQueryx.permissionsRequest();
      }
      readSongs();
    }
  }

  void readSongs() async {
    savedSongsList.value = await AudioQueryx.querySongs(
      ignoreCase: true,
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: SongSortType.DATE_ADDED,
      uriType: UriType.values.first,
    );
    // readSongsList.value = savedSongsList;
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
          playRandomSong();
        }
      }
    });
  }

  void playRandomSong() {
    final random = Random();
    playIndex.value = random.nextInt(readSongsList.length);
    playPreviousSong(readSongsList[playIndex.value].uri, playIndex.value);
  }

//IF ID is 0 Then play previous song if ID is 1 then play next Song
  void playPreviousOrNextSong(int ID) {
    if (ID == 0) {
      if (mode.value) {
        if (playIndex.value > 0) {
          //Play previous song or start from the bottom.
          playIndex.value = playIndex.value - 1;
        } else {
          playIndex.value = readSongsList.length - 1;
        }
        playSong(
            readSongsList[playIndex.value].uri, playIndex.value, readSongsList);
      } else {
        //The shuffle mode pop.
        playPreviousSongInShuffle();
      }
    }
    if (ID == 1) {
      if (mode.value) {
        if (playIndex.value != savedSongsList.length) {
          playIndex.value = playIndex.value + 1;
        } else {
          playIndex.value = 0;
        }

        playSong(
            readSongsList[playIndex.value].uri, playIndex.value, readSongsList);
      } else {
        //Choosing the Index or Song at random
        final random = Random();
        playIndex.value = random.nextInt(readSongsList.length);
        playSong(
            readSongsList[playIndex.value].uri, playIndex.value, readSongsList);
      }
    }
    wasPaused = false;
  }

  void playPreviousSongInShuffle() {
    //The shuffle mode pop.
    if (playedSongs.isNotEmpty && playedSongsIndex.isNotEmpty) {
      playedSongs.removeLast();
      playedSongsIndex.removeLast();

      playIndex.value = playedSongsIndex.last;

      //We are picking from the playedSongs List. And updated the screen using the Song's GLOBAL index. Since we're using a local index within its list.
      playPreviousSong(playedSongs[playedSongs.length - 1], playIndex.value);
    } else {
      playRandomSong();
    }
  }

  void changePosition(seconds) {
    var newPositon = Duration(seconds: seconds);
    _AudioPlayer.seek(newPositon);
  }

//This function runs when we jump in songs.
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

  void playPreviousSong(String? uri, int index) {
    try {
      if (!wasPaused || playIndex.value != index) {
        _AudioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
        isPlaying(true);
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
    Songs = savedSongsList;
    if (search != '') {
      //Here we should find the songs that start with certain words.
      print("SEARCHING .....");
      Songs = Songs.where((str) => str.title.toLowerCase().contains(search))
          .toList();

      print("Searched songs list: ${Songs.length}");
      Songs.sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
      readSongsList.value = Songs;
    } else {
      print("NOT SEARCHING!.....");
      savedSongsList
          .removeWhere((Song) => Song.displayNameWOExt.startsWith("AUD"));
      Songs = savedSongsList;
      print("Saved Songs list: ${Songs.length}");
      Songs.sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
      readSongsList.value = savedSongsList;
    }
  }
}
