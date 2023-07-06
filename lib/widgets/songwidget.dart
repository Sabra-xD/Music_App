import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/screens/playerScreen.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../constants/colors.dart';
import '../constants/textstyle.dart';
import '../controllers/playercontroller.dart';

// ignore: non_constant_identifier_names
FutureBuilder<List<SongModel>> ListSongs(PlayxController controller) {
  return FutureBuilder<List<SongModel>>(
    future: controller.AudioQueryx.querySongs(
      ignoreCase: true,
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: SongSortType.DATE_ADDED,
      uriType: UriType.values.first,
    ),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.height * 0.5,
              child: CircularProgressIndicator(
                color: progressIndicatorColor,
              )),
        );
      } else {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else {
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No Songs found"),
              );
            } else {
              return Obx(
                () => ListView.builder(
                  itemCount: controller.searching.value
                      ? controller.filteredSongs.length
                      : controller
                          .readSongsList.length, //Wee need this to change.
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: songListPadding(),
                      // margin: const EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Card(
                        child: Obx(
                          () => ListTile(
                            onTap: () {
                              checkPlayingSong(controller, index);

                              Get.to(playerScreen(
                                Song: controller.readSongsList[index],
                                index: index,
                                SongsList: controller.readSongsList,
                              ));
                            },
                            tileColor: tileColorController(controller, index)
                                ? Colors.black45
                                : controller.setColorDependingOnDay(),
                            leading: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.music_note_outlined,
                                color: Colors.white,
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                if (controller.isPlaying.value) {
                                  controller.pauseSong();
                                  controller.isPlaying.value = false;
                                } else {
                                  controller.playSong(
                                    controller.readSongsList[index].uri,
                                    index,
                                  );
                                }
                              },
                              icon: iconDisplayController(controller, index)
                                  ? const Icon(
                                      Icons.pause,
                                      color: Colors.white,
                                    )
                                  : const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                            ),
                            title: controller.searching.value
                                ? Text(
                                    controller
                                        .filteredSongs[index].displayNameWOExt,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: SongStyle(),
                                  )
                                : Text(
                                    controller
                                        .readSongsList[index].displayNameWOExt,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: SongStyle(),
                                  ),
                            subtitle: (controller.readSongsList[index].artist ==
                                    "<unknown>")
                                ? null
                                : controller.searching.value
                                    ? Text(
                                        "${controller.filteredSongs[index].artist}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: SongStyle(),
                                      )
                                    : Text(
                                        "${controller.readSongsList[index].artist}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: SongStyle(),
                                      ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          }
        }
      }
      return const Text("Nothing");
    },
  );
}

bool iconDisplayController(PlayxController controller, int index) {
  return controller.playIndex.value == index && controller.isPlaying.value;
}

bool tileColorController(PlayxController controller, int index) {
  return controller.playIndex.value == index && controller.isPlaying.value ||
      (controller.wasPaused && controller.playIndex.value == index);
}

void checkPlayingSong(PlayxController controller, int index) {
  if (controller.searching.value) {
    if (controller.isPlaying.value) {
      if (controller.playIndex.value ==
          controller.filteredSongsOriginalIndex[index]) {
        //Do nothing G
      } else {
        controller.playSong(
            controller
                .readSongsList[controller.filteredSongsOriginalIndex[index]]
                .uri,
            controller.filteredSongsOriginalIndex[index]);
      }
    } else {
      controller.playSong(controller.readSongsList[index].uri, index);
    }
  } else {
    if (controller.isPlaying.value) {
      if (controller.playIndex.value == index) {
        //Do nothing but navigate to the page.
      } else {
        controller.playSong(
          controller.readSongsList[index].uri,
          index,
        );
      }
    } else {
      controller.playSong(controller.readSongsList[index].uri, index);
    }
  }
}

BoxDecoration gradientBackground() {
  return BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
        gradientColor1,
        gradientColor2,
      ]));
}

Row controlButtons(String page, PlayxController controller) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      IconButton(
          onPressed: () {
            //Jump to previous song
            //ID is 0 so we play PREVIOUS SONG
            controller.playPreviousOrNextSong(0);
          },
          icon: Icon(
            Icons.skip_previous,
            color: Colors.white,
            size: controller.checkPage(page) ? 15 : 35,
          )),
      ClipOval(
        child: Container(
          width: controller.checkPage(page) ? 40 : 70,
          height: controller.checkPage(page) ? 40 : 70,
          color: Colors.white,
          child: IconButton(
              onPressed: () {
                if (controller.isPlaying.value) {
                  controller.pauseSong();
                } else {
                  controller.playSong(
                      controller.readSongsList[controller.playIndex.value].uri,
                      controller.playIndex.value);
                }
              },
              icon: controller.isPlaying.value
                  ? Icon(
                      Icons.pause,
                      color: controller.setColorDependingOnDay(),
                      size: controller.checkPage(page) ? 25 : 55,
                    )
                  : Icon(
                      Icons.play_arrow,
                      color: controller.setColorDependingOnDay(),
                      size: controller.checkPage(page) ? 25 : 55,
                    )),
        ),
      ),
      IconButton(
          onPressed: () {
            //Jump to next song
            //ID IS 1 to Play Next Song
            controller.playPreviousOrNextSong(1);
          },
          icon: Icon(
            Icons.skip_next,
            color: Colors.white,
            size: controller.checkPage(page) ? 15 : 35,
          )),
    ],
  );
}
