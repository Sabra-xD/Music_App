import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/constants/textstyle.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../controllers/playercontroller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(PlayxController());
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.purple.shade900, Colors.purple.shade200])),
      child: Scaffold(
          appBar: _customAppBar(),
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome",
                        style: OurStyle(),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Text("Enjoy your Music!",
                            style: OurStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white),
                child: TextField(
                  style: const TextStyle(color: Colors.grey),
                  controller: controller.SearchController,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search",
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                      )),
                ),
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "Songs list",
                      style: OurStyle(fontSize: 18),
                    ),
                  )),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Expanded(
                child: ListSongs(),
              )
            ],
          )),
    );
  }

  FutureBuilder<List<SongModel>> ListSongs() {
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
                      padding: const EdgeInsets.all(5),
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
                              controller.playSong(Songs[index].uri, index);
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
                              onPressed: () {},
                              icon: const Icon(
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
}

AppBar _customAppBar() {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    leading: IconButton(
      onPressed: () {},
      icon: Icon(Icons.grid_view_rounded),
    ),
  );
}
