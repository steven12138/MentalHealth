import 'dart:async';

import 'package:flutter/material.dart';

class SportsRecordCard extends StatefulWidget {
  const SportsRecordCard({super.key});

  @override
  _SportsRecordCardState createState() => _SportsRecordCardState();
}

class _SportsRecordCardState extends State<SportsRecordCard> {
  bool _isRecording = false;
  int _timeCount = 0;
  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startRecording() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _timeCount++;
      });
    });
  }

  void _stopRecording() {
    _timer.cancel();
    setState(() {
      _timeCount = 0;
    });
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
    return Card(
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
                primary:
                    _isRecording ? Colors.red : Theme.of(context).primaryColor,
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
          ],
        ),
      ),
    );
  }
}
