import 'package:flutter/material.dart';
import 'package:inner_peace/components/reg_card.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicCard extends StatefulWidget {
  const MusicCard({Key? key}) : super(key: key);

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard> {
  @override
  Widget build(BuildContext context) {
    return RegCard(
      title: Row(
        children: [
          ...const [
            Icon(Icons.face_retouching_natural_sharp),
            SizedBox(width: 10),
            Text("沉浸"),
            Spacer(),
          ],
          ButtonBar(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.shuffle),
              )
            ],
          )
        ],
      ),
      child: MusicCardBody(),
    );
  }
}

class Music {
  final String name;
  final String assetPath;
  final IconData icon;

  Music({required this.name, required this.assetPath, required this.icon});
}

class MusicCardBody extends StatefulWidget {
  const MusicCardBody({super.key});

  @override
  State<MusicCardBody> createState() => _MusicCardBodyState();
}

class _MusicCardBodyState extends State<MusicCardBody> {
  final _player = AudioPlayer();

  final List<Music> musicList = [
    Music(name: '朝露', assetPath: 'audio/2.mp3', icon: Icons.water_drop_rounded),
    Music(name: '晨曦', assetPath: 'audio/3.mp3', icon: Icons.sunny),
    Music(name: '晚霞', assetPath: 'audio/4.mp3', icon: Icons.nights_stay),
    // Add more songs as needed
  ];

  List<bool> isPlay = List<bool>.generate(3, (index) => false);

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((event) {
      if (event == AudioEventType.complete) {
        setState(() {
          isPlay = List<bool>.generate(3, (index) => false);
          isStop = true;
        });
      }
    });
  }

  bool isStop = false;

  @override
  Widget build(BuildContext context) {
    //only shuffle for no music playing
    if (isPlay.where((element) => element).isEmpty && !isStop) {
      musicList.shuffle();
    } else {
      isStop = false;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: List<Widget>.generate(musicList.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Divider(indent: 16, endIndent: 16, height: 0);
          } else {
            final musicIndex = index ~/ 2;
            Music music = musicList[musicIndex];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(music.icon, size: 20),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    music.name,
                    style: TextStyle(
                      fontSize: 16,
                      height: 0.8,
                    ),
                  ),
                ),
                trailing: isPlay[musicIndex]
                    ? IconButton(
                        icon: Icon(Icons.stop),
                        onPressed: () {
                          // Pause music logic
                          _player.stop();
                          isPlay[musicIndex] = false;
                          setState(() {
                            isStop = true;
                          });
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () {
                          // Play music logic
                          playMusic(music.assetPath);
                          isPlay[musicIndex] = true;
                          setState(() {
                          });
                        },
                      ),
              ),
            );
          }
        }),
      ),
    );
  }

  void playMusic(String assetPath) async {
    await _player.play(AssetSource(assetPath));
  }
}
