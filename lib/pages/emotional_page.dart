import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmotionalPage extends StatefulWidget {
  const EmotionalPage({Key? key}) : super(key: key);

  @override
  State<EmotionalPage> createState() => _EmotionalPageState();
}

class _EmotionalPageState extends State<EmotionalPage> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgressState()),
        ChangeNotifierProvider(create: (_) => LengthState()),
      ],
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: ListView(
            children: [
              const SizedBox(
                height: 10,
              ),
              EmotionCard(),
              const SizedBox(height: 10),
              MeditationCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class MeditationCard extends StatefulWidget {
  const MeditationCard({Key? key}) : super(key: key);

  @override
  State<MeditationCard> createState() => _MeditationCardState();
}

class ProgressState extends ChangeNotifier {
  double _value = 0;

  double get value => _value;

  set value(double newValue) {
    _value = newValue;
    notifyListeners();
  }
}

class LengthState extends ChangeNotifier {
  int _value = 0;

  int get value => _value;

  set value(int newValue) {
    _value = newValue;
    notifyListeners();
  }
}

class _MeditationCardState extends State<MeditationCard> {
  DateTime? start;

  int limit = 30;

  String medKey =
      "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}MEDITATE";

  Future<int> getMeditationTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    limit = prefs.getInt("medLimit") ?? 30;
    return prefs.getInt(medKey) ?? 0;
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  Timer? timer;

  void _startMeditation() {
    setState(() {
      start = DateTime.now();
    });

    final progressState = Provider.of<ProgressState>(context, listen: false);
    progressState.value = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      final progressState = Provider.of<ProgressState>(context, listen: false);
      progressState.value =
          DateTime.now().difference(start!).inSeconds % 60 / 60;
      print(progressState.value);
      final lengthState = Provider.of<LengthState>(context, listen: false);
      lengthState.value = DateTime.now().difference(start!).inMinutes;
    });
  }

  void _clearMeditation() {
    var prefs = SharedPreferences.getInstance();
    prefs.then((value) {
      value.remove(medKey);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("已清除冥想记录！"),
        backgroundColor: Colors.red,
      ));
    });
    setState(() {
      start = null;
    });
  }

  void _endMeditation() {
    if (start != null) {
      timer?.cancel();
      DateTime end = DateTime.now();
      int time = end.difference(start!).inMinutes;
      SharedPreferences.getInstance().then((prefs) async {
        int? oldTime = prefs.getInt(medKey);

        if (oldTime != null && oldTime < limit && time + oldTime >= limit) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("恭喜你完成了今日的冥想目标！"),
            backgroundColor: Colors.green,
          ));
        } else {
          if (time == 0) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("冥想时间过短！"),
              backgroundColor: Colors.orange,
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("完成冥想，本次冥想$time分钟！"),
              backgroundColor: Colors.blue,
            ));
          }
        }
        if (oldTime != null) {
          time += oldTime;
        }
        prefs.setInt(medKey, time);
      });
    }
    setState(() {
      start = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      child: RegCard(
        title: Row(
          children: [
            ...const [
              Icon(Icons.accessibility_new),
              SizedBox(width: 10),
              Text("冥想"),
              Spacer(),
            ],
            ButtonBar(
              children: [
                IconButton(
                  onPressed: () {
                    //Confirm delete
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("确认清除冥想记录？"),
                        content: const Text("清除后将无法恢复！"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("取消"),
                          ),
                          TextButton(
                            onPressed: () {
                              _clearMeditation();
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "确认",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete),
                )
              ],
            )
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: start != null
              ? Column(
                  children: [
                    const Text("正在冥想"),
                    const SizedBox(height: 10),
                    Consumer<ProgressState>(
                      builder: (context, progressState, _) {
                        return TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          tween:
                              Tween<double>(begin: 0, end: progressState.value),
                          builder: (context, value, _) =>
                              LinearProgressIndicator(value: value),
                        );
                      },
                    ),
                    Consumer<LengthState>(
                      builder: (context, lengthState, _) {
                        return Text(
                          "${lengthState.value}分钟",
                          style: const TextStyle(fontSize: 30),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _endMeditation,
                      child: const Text("结束冥想"),
                    ),
                  ],
                )
              : FutureBuilder(
                  future: getMeditationTime(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          const Text("今日已冥想"),
                          const SizedBox(height: 10),
                          Text(
                            "${snapshot.data}分钟",
                            style: const TextStyle(fontSize: 30),
                          ),
                          const SizedBox(height: 10),
                          Text("目标：每日冥想$limit分钟"),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _startMeditation,
                            child: const Text("开始冥想"),
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
        ),
      ),
    );
  }
}

class Emotion {
  String emoji;
  int id;

  Emotion(this.emoji, this.id);
}

class RegCard extends StatelessWidget {
  final Widget title;
  final Widget child;

  const RegCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        child: Column(
          children: [
            AppBar(
              title: title,
              elevation: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class EmotionCard extends StatefulWidget {
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

  //TODO: finish get data from web
  void _clearEmotion() async {
    setState(() {
      emotionLoaded = false;
    });
    var pref = await SharedPreferences.getInstance();
    pref.remove(emoKey);
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
    setState(() {
      currentEmotion = emotion;
      emotionLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RegCard(
      title: !emotionLoaded || currentEmotion != null
          ? const Text('每日心情')
          : const Text('选择你今天的心情'),
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
