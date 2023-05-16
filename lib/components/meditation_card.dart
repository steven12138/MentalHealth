import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reg_card.dart';

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
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await _endMeditation();
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
      value.setStringList(
          "medRecord",
          value.getStringList("medRecord") ?? <String>[]
            ..remove(medKey));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("已清除冥想记录！"),
        backgroundColor: Colors.red,
      ));
    });
    setState(() {
      start = null;
    });
  }

  Future<void> _endMeditation() async {
    if (start != null) {
      timer?.cancel();
      DateTime end = DateTime.now();
      int time = end.difference(start!).inMinutes;
      await SharedPreferences.getInstance().then((prefs) async {
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
        await prefs.setInt(medKey, time);
        await prefs.setStringList(
          "medRecord",
          prefs.getStringList("medRecord") ?? <String>[]
            ..add(medKey),
        );
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
