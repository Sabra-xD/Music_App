import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/screens/playerScreen.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../constants/textstyle.dart';
import '../controllers/playercontroller.dart';

// ignore: non_constant_identifier_names
FutureBuilder<List<SongModel>> ListSongs(
    PlayxController controller, onInitailize) {
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
              child: const CircularProgressIndicator()),
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
              if (onInitailize) {
                List<SongModel> Songs = snapshot.data!;
                controller.readSongsList.value = Songs;
                controller.savedSongsList.value = Songs;
                controller.removeRecordingandOrder(controller.readSongsList);
                onInitailize = false;
              }

              return Obx(
                () => ListView.builder(
                  itemCount: controller
                      .readSongsList.length, //Wee need this to change.
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: songListPadding(),
                      margin: const EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Card(
                        child: Obx(
                          () => ListTile(
                            onTap: () {
                              // Play Song & Navigate to PlayScreen
                              controller.playSong(
                                  controller.readSongsList[index].uri,
                                  index,
                                  controller.readSongsList);
                              Get.to(playerScreen(
                                Song: controller.readSongsList[index],
                                index: index,
                                SongsList: controller.readSongsList,
                              ));
                            },
                            tileColor: controller.playIndex.value == index &&
                                    controller.isPlaying.value
                                ? Colors.black45
                                : Color.fromARGB(255, 149, 122, 3),
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
                                      controller.readSongsList);
                                }
                              },
                              icon: controller.playIndex == index &&
                                      controller.isPlaying.value
                                  ? const Icon(
                                      Icons.pause,
                                      color: Colors.white,
                                    )
                                  : const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                            ),
                            title: Text(
                              controller.readSongsList[index].displayNameWOExt,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: SongStyle(),
                            ),
                            subtitle: (controller.readSongsList[index].artist ==
                                    "<unknown>")
                                ? null
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

BoxDecoration gradientBackground() {
  return BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
        Colors.yellow.shade700.withOpacity(0.8),
        Colors.grey.shade900.withOpacity(0.95),
      ]));
}
