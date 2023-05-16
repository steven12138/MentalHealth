import 'package:flutter/cupertino.dart';
import 'package:inner_peace/components/emotion_calendar.dart';

import '../components/sport_calendar.dart';

var personalRouter = {
  '/emotion': (_) => const EmotionCalendarPage(),
  '/sport': (_) => const SportCalendarPage(),
  '/meditation': (_) => Placeholder(),
  '/setting': (_) => Placeholder(),
};
