import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/screens/playerScreen.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../constants/textstyle.dart';

FutureBuilder<List<SongModel>> ListSongs(controller) {
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
              List<SongModel> Songs = snapshot.data!;

              controller.removeRecordingandOrder(Songs);

              return ListView.builder(
                itemCount: Songs.length,
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
                            // Play Song
                            // controller.playSong(Songs[index].uri, index);
                            Get.to(playerScreen(
                              Song: Songs[index],
                              index: index,
                              SongsList: Songs,
                            ));
                          },
                          // ignore: unrelated_type_equality_checks
                          tileColor: controller.playIndex == index &&
                                  controller.isPlaying.value
                              ? Colors.indigo.shade400
                              : Colors.purple.shade800,
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
                                controller.playSong(Songs[index].uri, index);
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
                            Songs[index].displayNameWOExt,
                            style: SongStyle(),
                          ),
                          subtitle: (Songs[index].artist == "<unknown>")
                              ? null
                              : Text(
                                  "${Songs[index].artist}",
                                  style: SongStyle(),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }
        }
      }
      return Text("Nothing");
    },
  );
}

BoxDecoration gradientBackground() {
  return BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
        Colors.purple.shade200,
        Colors.purple.shade900,
      ]));
}
