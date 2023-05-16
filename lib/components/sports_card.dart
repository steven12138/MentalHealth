import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inner_peace/components/sport_data_card.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SportsRecordCard extends StatefulWidget {
  const SportsRecordCard({super.key});

  @override
  _SportsRecordCardState createState() => _SportsRecordCardState();
}

class _SportsRecordCardState extends State<SportsRecordCard> {
  double totalDistance = 0.0;
  UserAccelerometerEvent? previousEvent;
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
  }

  bool _isRecording = false;
  int _timeCount = 0;
  Timer? _timer;

  @override
  void dispose() {
    if (_timer != null) _timer!.cancel();
    super.dispose();
  }

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?';
  bool first = true;
  int base = 0;
  int _steps = 0;

  void onStepCount(StepCount event) {
    if (first) {
      base = event.steps;
      first = false;
    }
    setState(() {
      _steps = event.steps - base;
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = -1;
    });
  }

  void initPlatformState() async {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = await Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
    print("get");
    if (!mounted) return;
  }

  void _startRecording() {
    initPlatformState();
    totalDistance = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _timeCount++;
      });
    });
  }

  void _notice() {
    Provider.of<SportSaveState>(context, listen: false).update();
  }

  void _stopRecording() {
    _timer!.cancel();
    first = true;
    var time = _timeCount;
    var step = _steps;
    setState(() {
      _timeCount = 0;
    });
    //save check dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('保存记录'),
          content: Text('时间: ${_formatTime(time)}\n步数: ${step}步\n是否保存记录？'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                var sportKey =
                    "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}SPORT";
                var prefs = await SharedPreferences.getInstance();
                await prefs.setStringList(
                    sportKey,
                    prefs.getStringList(sportKey) ?? <String>[]
                      ..add(
                          "${DateTime.now().toIso8601String()}|${_formatTime(time)}|$step"));
                await prefs.setStringList(
                    "sportRecord",
                    prefs.getStringList("sportRecord") ?? <String>[]
                      ..add(sportKey));
                if (!mounted) return;
                _notice();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('记录已保存'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds ~/ 60) % 60;
    int remainingSeconds = seconds % 60;

    String hoursStr = (hours % 24).toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      child: Card(
        margin: EdgeInsets.all(20.0),
        color: Colors.white,
        elevation: 3.0,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '记录运动',
                style: TextStyle(
                  fontSize: 24.0, // Increase the font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Time: ${_formatTime(_timeCount)}',
                style: TextStyle(fontSize: 18.0, color: Colors.black87),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  primary: _isRecording
                      ? Colors.red
                      : Theme.of(context).primaryColor,
                  padding: EdgeInsets.all(15.0),
                  shadowColor: Colors.black54,
                ),
                onPressed: () {
                  if (!_isRecording) {
                    _startRecording();
                  } else {
                    _stopRecording();
                  }
                  setState(() {
                    _isRecording = !_isRecording;
                  });
                },
                child: Icon(
                  _isRecording ? Icons.stop : Icons.play_arrow,
                  size: 30.0,
                ),
              ),
              if (_isRecording) ...[
                Text(
                  'Steps taken:',
                  style: TextStyle(fontSize: 30),
                ),
                Text(
                  _steps.toString(),
                  style: TextStyle(fontSize: 60),
                ),
                Divider(
                  height: 100,
                  thickness: 0,
                  color: Colors.white,
                ),
                Text(
                  'Pedestrian status:',
                  style: TextStyle(fontSize: 30),
                ),
                Icon(
                  _status == 'walking'
                      ? Icons.directions_walk
                      : _status == 'stopped'
                          ? Icons.accessibility_new
                          : Icons.error,
                  size: 100,
                ),
                Center(
                  child: Text(
                    _status,
                    style: _status == 'walking' || _status == 'stopped'
                        ? TextStyle(fontSize: 30)
                        : TextStyle(fontSize: 20, color: Colors.red),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
