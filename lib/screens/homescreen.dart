import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              colors: [
            Colors.deepPurple.shade800.withOpacity(0.8),
            Colors.deepPurple.shade200.withOpacity(0.8)
          ])),
      child: Scaffold(
          appBar: _customAppBar(),
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Welcome"),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text("Enjoy your Music!"),
                      ),
                    ],
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
                Text("Songs list"),
                ClipRRect(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height * .7,
                      child: ListSongs()),
                )
              ],
            ),
          )),
    );
  }

  FutureBuilder<List<SongModel>> ListSongs() {
    return FutureBuilder<List<SongModel>>(
      future: controller.AudioQueryx.querySongs(
        ignoreCase: true,
        orderType: OrderType.ASC_OR_SMALLER,
        sortType: null,
        uriType: UriType.EXTERNAL,
      ),
      builder: (context, snapshot) {
        print(snapshot.data);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
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
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width * 0.6,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: ListTile(
                          onTap: () {
                            // Play Song
                            controller.playSong(snapshot.data![index].uri);
                          },
                          tileColor: Colors.purple.shade800,
                          leading: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.music_note_outlined),
                          ),
                          trailing: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.abc),
                          ),
                          title: Text(snapshot.data![index].displayNameWOExt),
                          subtitle: Text("${snapshot.data![index].artist}"),
                        ),
                      );
                    },
                  ),
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
