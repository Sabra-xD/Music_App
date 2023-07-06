import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/constants/textstyle.dart';
import 'package:music_app/screens/playerScreen.dart';
import '../controllers/playercontroller.dart';
import '../widgets/songwidget.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(PlayxController());
  final _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

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
                  focusNode: _focusNode,
                  onChanged: (text) {
                    print("Search Text: ${text}");
                    controller.search(
                        controller.readSongsList, _searchController.text);
                  }, //Add the search function here so that it is
                  onEditingComplete: () {
                    controller.search(
                        controller.readSongsList, _searchController.text);
                    _focusNode.unfocus();
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
                child: ListSongs(controller),
              ),
              Obx(
                () => controller.isPlaying.value || controller.wasPaused
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              SlideUpPageRoute(
                                page: playerScreen(
                                  Song: controller.readSongsList[
                                      controller.playIndex.value],
                                  index: controller.playIndex.value,
                                  SongsList: controller.readSongsList,
                                ),
                              ));
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top: 5),
                          height: MediaQuery.of(context).size.height * 0.18,
                          width: double.infinity,
                          color: Colors.black,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  "Now Playing:   ${controller.readSongsList[controller.playIndex.value].title} ",
                                  style: OurStyle(fontSize: 12),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Expanded(
                                    child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                      trackHeight: 4,
                                      thumbShape: const RoundSliderThumbShape(
                                        disabledThumbRadius: 4,
                                        enabledThumbRadius: 4,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                        overlayRadius: 0,
                                      ),
                                      activeTrackColor:
                                          Colors.white.withOpacity(0.2),
                                      inactiveTrackColor: Colors.white,
                                      thumbColor: Colors.white,
                                      overlayColor: Colors.white),
                                  child: Slider(
                                      min: 0.0,
                                      max: controller.maxDuration.value,
                                      value: controller.value.value,
                                      onChanged: (value) {}),
                                )),
                              ),
                              controlButtons("HomeScreen", controller),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 0,
                      ),
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
      icon: const Icon(Icons.grid_view_rounded),
    ),
  );
}

class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpPageRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 2.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve:
                    Curves.easeIn, // Use a slower curve for a slower animation
              ),
            ),
            child: child,
          ),
          transitionDuration: const Duration(
              milliseconds: 400), // Increase the duration of the animation
        );
}
