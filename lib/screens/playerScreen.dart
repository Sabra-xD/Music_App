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
              'https://th.bing.com/th/id/R.fa5042937e4631dc0611b1c61a826298?rik=oZSG%2bU67VYmxHw&riu=http%3a%2f%2fwallpapercave.com%2fwp%2f06TYEbJ.jpg&ehk=%2fqnCDek4ehvhUyMJl35lveaphIoww%2bI0XNXQ4zZsKhA%3d&risl=&pid=ImgRaw&r=0',
              fit: BoxFit.cover,
            ),
            ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.0)
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
                padding: EdgeInsets.all(5),
                child: Column(children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                  Row(
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
                              activeTrackColor: Colors.white.withOpacity(0.2),
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
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                      )
                    ],
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
