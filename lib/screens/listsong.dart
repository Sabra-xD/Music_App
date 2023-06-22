import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';

void checkPermission(OnAudioQuery AudioQueryx) async {
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
}

class SongScreen extends StatelessWidget {
  const SongScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var controller = Get.put(PlayxController()); // Initializing the controller.
    final _audioQuery = OnAudioQuery();

    checkPermission(_audioQuery);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple.shade800.withOpacity(0.8),
            Colors.purple.shade200.withOpacity(0.8),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<List<SongModel>>(
          future: _audioQuery.querySongs(
            ignoreCase: true,
            orderType: OrderType.ASC_OR_SMALLER,
            sortType: null,
            uriType: UriType.EXTERNAL,
          ),
          builder: (context, snapshot) {
            print(snapshot.data);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                strokeWidth: 5,
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text("There is an error ${Error}");
              } else {
                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No songs found"),
                  );
                } else {
                  return ListView.builder(
                    itemCount: 3,
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
                          },
                          tileColor: Colors.purple.shade800,
                          leading: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.abc),
                          ),
                          trailing: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.abc),
                          ),
                          title: Text(snapshot.data![index].displayName),
                          subtitle:
                              Text(snapshot.data![index].artist.toString()),
                        ),
                      );
                    },
                  );
                }
              }
            } else {
              return Container(); // Return an empty container as a placeholder when the connection state is not waiting or done.
            }
          },
        ),
      ),
    );
  }
}

void playSong(String? uri, AudioPlayer _AudioPlayer) {
  try {
    //We play the Audio Here.
    _AudioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
    _AudioPlayer.play();
  } on Exception catch (e) {
    print(e.toString());
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _AudioPlayer = AudioPlayer();
  final AudioQueryx = OnAudioQuery();

  @override
  void initState() {
    super.initState();
    // Permission handler.
    checkPermission();
  }

  void checkPermission() async {
    final _audioQuery = OnAudioQuery();
    print("Checking permission");
    print(kIsWeb);
    if (!kIsWeb) {
      print(await _audioQuery.permissionsStatus());
      bool permissionStatus = await _audioQuery.permissionsRequest();
      var perm = await Permission.storage.request();
      print(permissionStatus);
      print(perm.isGranted);
      if (!permissionStatus && perm.isDenied) {
        await _audioQuery.permissionsRequest();
      }
    }

    await Future.delayed(Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple.shade800.withOpacity(0.8),
            Colors.purple.shade200.withOpacity(0.8),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<List<SongModel>>(
          future: AudioQueryx.querySongs(
            ignoreCase: true,
            orderType: OrderType.ASC_OR_SMALLER,
            sortType: null,
            uriType: UriType.EXTERNAL,
          ),
          builder: (context, snapshot) {
            print(snapshot.data);
            print("XXXXXXXXXXXXXXXX");
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
                    return ListView.builder(
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
                              playSong(snapshot.data![index].uri, _AudioPlayer);
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
                    );
                  }
                }
              }
            }
            return Text("Nothing");
          },
        ),
      ),
    );
  }
}
