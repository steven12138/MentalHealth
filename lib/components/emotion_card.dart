import 'package:flutter/material.dart';
import 'package:inner_peace/components/reg_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

import '../data/emotion.dart';

import '../data/emotion_dao.dart';

class EmotionCard extends StatefulWidget {
  const EmotionCard({super.key});

  @override
  _EmotionCardState createState() => _EmotionCardState();
}

class _EmotionCardState extends State<EmotionCard> {
  int? currentEmotion;
  bool emotionLoaded = false;
  String emoKey =
      "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}EMO";

  void _loadEmotion() async {
    setState(() {
      emotionLoaded = false;
    });
    var pref = await SharedPreferences.getInstance();
    currentEmotion = pref.getInt(emoKey);
    print(currentEmotion);
    setState(() {
      emotionLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadEmotion();
  }

  final List<Emotion> _emotionList = [
    Emotion('😃', 1),
    Emotion('😔', 2),
    Emotion('😢', 3),
    Emotion('😡', 5),
    Emotion('😭', 6),
    Emotion('🥰', 7),
    Emotion('😊', 8),
    Emotion('😎', 9),
    Emotion('😍', 10),
    Emotion('🤩', 11),
    Emotion('😴', 12)
  ];

  void _clearEmotion() async {
    setState(() {
      emotionLoaded = false;
    });
    var pref = await SharedPreferences.getInstance();
    pref.remove(emoKey);
    await pref.setStringList(
        "emotionRecord",
        pref.getStringList("emotionRecord") ?? []
          ..remove(emoKey));
    setState(() {
      currentEmotion = null;
      emotionLoaded = true;
    });
  }

  void _recordEmotion(int emotion) async {
    setState(() {
      emotionLoaded = false;
    });
    var pref = await SharedPreferences.getInstance();
    await pref.setInt(emoKey, emotion);
    await pref.setStringList(
        "emotionRecord",
        pref.getStringList("emotionRecord") ?? []
          ..add(emoKey));

    var box = await Hive.openBox<EmotionStorage>('emotion');
    box.add(EmotionStorage(
        _emotionList.firstWhere((element) => element.id == emotion)));

    setState(() {
      currentEmotion = emotion;
      emotionLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RegCard(
      title: Row(
        children: [
          Icon(Icons.mood),
          SizedBox(width: 10),
          !emotionLoaded || currentEmotion != null
              ? const Text('每日心情')
              : const Text('选择你今天的心情'),
        ],
      ),
      child: SizedBox(
        height: 100,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: !emotionLoaded
              ? const SizedBox(
                  child: Center(
                    child: RefreshProgressIndicator(),
                  ),
                )
              : currentEmotion != null
                  ? Row(
                      children: [
                        Text(
                          "我今天感觉很 ${_emotionList.firstWhere((element) => element.id == currentEmotion).emoji}",
                          style: const TextStyle(fontSize: 23),
                        ),
                        const Spacer(),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor: Colors.lightBlue,
                            ),
                            onPressed: _clearEmotion,
                            child: const Icon(Icons.restore_from_trash))
                      ],
                    )
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: _emotionList
                          .map(
                            (e) => SizedBox(
                              height: 70,
                              width: 70,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () => _recordEmotion(e.id),
                                  child: Text(
                                    e.emoji,
                                    style: const TextStyle(fontSize: 32.0),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList()),
        ),
      ),
    );
  }
}
