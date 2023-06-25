import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/constants/textstyle.dart';
import 'package:music_app/controllers/playercontroller.dart';
import 'package:music_app/widgets/songwidget.dart';
import 'package:on_audio_query/on_audio_query.dart';

// ignore: camel_case_types
class playerScreen extends StatelessWidget {
  final SongModel Song;
  final int index;
  final List<SongModel> SongsList;
  playerScreen(
      {super.key,
      required this.Song,
      required this.index,
      required this.SongsList});
  //Finding the Controller

  PlayxController controller = Get.find<PlayxController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: gradientBackground(),
      child: Scaffold(
        body: Stack(
          children: [
            Image.network(
              "https://th.bing.com/th/id/OIP.kFl7NS4EWbzpiF0p2upUEAHaNK?pid=ImgDet&rs=1",
              fit: BoxFit.cover,
            ),
            ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.05)
                    ],
                    stops: const [
                      0.0,
                      0.4,
                      0.6
                    ]).createShader(rect);
              },
              blendMode: BlendMode.dstOut,
              child: Container(
                decoration: gradientBackground(),
              ),
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                controller.changeMode();
                              },
                              icon: controller.mode.value
                                  ? const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                    )
                                  : const Icon(
                                      Icons.shuffle,
                                      color: Colors.white70,
                                    ))
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            Text(
                              SongsList[controller.playIndex.value]
                                  .displayNameWOExt,
                              style: OurStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Song.artist == "<unknown>"
                                ? const Text('')
                                : Text(
                                    "${SongsList[controller.playIndex.value].artist}")
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.position.value,
                            style: OurStyle(),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    disabledThumbRadius: 4,
                                    enabledThumbRadius: 4,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 10,
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
                                onChanged: (double newValue) {
                                  controller.changePosition(newValue.toInt());
                                  newValue = newValue;
                                },
                              ),
                            ),
                          ),
                          Text(controller.duration.value),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                              onPressed: () {
                                //Jump to previous song
                                //ID is 0 so we play PREVIOUS SONG
                                controller.playPreviousOrNextSong(SongsList, 0);
                              },
                              icon: const Icon(
                                Icons.skip_previous,
                                color: Colors.white,
                                size: 35,
                              )),
                          ClipOval(
                            child: Container(
                              width: 70,
                              height: 70,
                              color: Colors.white,
                              child: IconButton(
                                  onPressed: () {
                                    if (controller.isPlaying.value == false) {
                                      controller.playSong(
                                          Song.uri, index, SongsList);
                                    } else {
                                      controller.pauseSong();
                                    }
                                  },
                                  icon: controller.isPlaying.value
                                      ? Icon(
                                          Icons.pause,
                                          color: Colors.purple.shade800
                                              .withOpacity(0.8),
                                          size: 55,
                                        )
                                      : Icon(
                                          Icons.play_arrow,
                                          color: Colors.purple.shade800
                                              .withOpacity(0.8),
                                          size: 55,
                                        )),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                //Jump to next song
                                //ID IS 1 to Play Next Song
                                controller.playPreviousOrNextSong(SongsList, 1);
                              },
                              icon: const Icon(
                                Icons.skip_next,
                                color: Colors.white,
                                size: 35,
                              )),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      )
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
