import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/playercontroller.dart';
import 'package:music_app/widgets/songwidget.dart';

// ignore: camel_case_types
class playerScreen extends StatelessWidget {
  playerScreen({super.key});
  //Finding the Controller
  // PlayxController controller = Get.find<PlayxController>();

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
            Row(
              children: [
                Text(
                  "0:0",
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
                      value: 0.1,
                      onChanged: (double value) {},
                    ),
                  ),
                ),
                Text("4:00")
              ],
            )
          ],
        ),
      ),
    );
  }
}
