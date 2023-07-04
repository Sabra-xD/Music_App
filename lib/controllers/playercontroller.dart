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
  var searching = false.obs;

  int count = 0;
  var mode = true.obs; //Mode true then normal false then shuffle
  final readSongsList = <SongModel>[].obs;
  final filteredSongs = <SongModel>[].obs;
  final filteredSongsOriginalIndex = <dynamic>[].obs;

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
      } else {
        readSongs();
      }
    }
  }

//Read sogns after having access to.
  void readSongs() async {
    readSongsList.value = await AudioQueryx.querySongs(
      ignoreCase: true,
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: SongSortType.DATE_ADDED,
      uriType: UriType.values.first,
    );

    removeRecordingandOrder(readSongsList);
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
          playSong(readSongsList[playIndex.value].uri, playIndex.value);
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
        playSong(readSongsList[playIndex.value].uri, playIndex.value);
      } else {
        //The shuffle mode pop.
        playPreviousSongInShuffle();
      }
    }
    //Playing Next Song
    if (ID == 1) {
      if (mode.value) {
        if (playIndex.value != savedSongsList.length - 1) {
          playIndex.value = playIndex.value + 1;
        } else {
          playIndex.value = 0;
        }

        playSong(readSongsList[playIndex.value].uri, playIndex.value);
      } else {
        //Choosing the Index or Song at random
        final random = Random();
        playIndex.value = random.nextInt(savedSongsList
            .length); //This might cause an error of the index overflow.
        playSong(readSongsList[playIndex.value].uri, playIndex.value);
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

  void playSong(String? uri, int index) {
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

    savedSongsList.value = List.from(readSongsList);
  }

  bool checkPage(String page) {
    if (page == "HomeScreen") {
      return true;
    } else {
      return false;
    }
  }

  void search(List<SongModel> songs, String search) {
    filteredSongs.value = List.from(savedSongsList);
    if (search.isNotEmpty) {
      searching.value = true;

//Clearing the list before searching to avoid accumilation.
      filteredSongsOriginalIndex.value = [];
      filteredSongs.value = [];
      for (int i = 0; i < savedSongsList.length; i++) {
        SongModel song = savedSongsList[i];
        if (song.title.toLowerCase().contains(search.toLowerCase())) {
          filteredSongsOriginalIndex.add(i);
          filteredSongs.add(savedSongsList[i]);
        }
      }

      filteredSongs.sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
    } else {
      searching.value = false;
      readSongsList.value = List.from(savedSongsList);
    }
  }
}
