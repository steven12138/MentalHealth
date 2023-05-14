import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/emotion_card.dart';
import '../components/meditation_card.dart';

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
              const MeditationCard(),
            ],
          ),
        ),
      ),
    );
  }
}
