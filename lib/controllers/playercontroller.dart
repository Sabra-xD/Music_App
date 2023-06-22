import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayxController extends GetxController {
  final AudioQueryx = OnAudioQuery();

  @override
  void onInit() {
    //Triggered when initialized
    checkPermission();
    super.onInit();
  }

  void checkPermission() async {
    // var perm = await Permission.storage.request();

    print("Checking permission");
    // AudioQueryx.permissionsStatus();
    print(kIsWeb);
    if (!kIsWeb) {
      print(AudioQueryx.permissionsStatus());
      bool permissionStatus = await AudioQueryx.permissionsRequest();

      print(permissionStatus);
      if (!permissionStatus) {
        await AudioQueryx.permissionsRequest();
      }
    }

    Future.delayed(Duration(seconds: 10));
  }
}
