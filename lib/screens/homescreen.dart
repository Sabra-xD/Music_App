import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/constants/textstyle.dart';
import '../controllers/playercontroller.dart';
import '../widgets/songwidget.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(PlayxController());
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: gradientBackground(),
      child: Scaffold(
          appBar: _customAppBar(),
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: uniformPadding(),
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
                  onChanged: (text) {
                    print("Search Text: ${text}");
                    controller.search(
                        controller.readSongsList, _searchController.text);
                  }, //Add the search function here so that it is
                  onEditingComplete: () {
                    controller.search(
                        controller.readSongsList, _searchController.text);
                  },
                  style: const TextStyle(color: Colors.grey),
                  controller: _searchController,
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
                    padding: uniformPadding(),
                    child: Text(
                      "Songs List",
                      style: OurStyle(fontSize: 18),
                    ),
                  )),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Expanded(
                child: ListSongs(controller, _searchController),
              )
            ],
          )),
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
