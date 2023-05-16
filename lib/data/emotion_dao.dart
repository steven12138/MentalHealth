
import 'package:hive/hive.dart';

import 'emotion.dart';

class Emotion {
  String emoji;

  int id;

  Emotion(this.emoji, this.id);
}

final List<Emotion> emotionList = [
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

class EmotionBox {
  static const String boxName = "emotionBox";

  static Future<void> init() async {
    await Hive.openBox<EmotionStorage>(boxName);
  }

  static Future<void> addEmotion(Emotion emotion) async {
    var box = Hive.box<EmotionStorage>(boxName);
    await box.add(EmotionStorage(emotion));
  }

  static Future<Emotion> searchEmotion(DateTime date) async {
    var box = Hive.box<EmotionStorage>(boxName);
    var emotion = box.values.firstWhere((element) => element.dateTime == date);
    return emotion.emotion;
  }

  static Future<DateTime?> getFirstDate() async {
    var box = Hive.box<EmotionStorage>(boxName);
    if (box.isNotEmpty) {
      DateTime? minDateTime;
      for (var emotion in box.values) {
        if (minDateTime == null || emotion.dateTime.isBefore(minDateTime)) {
          minDateTime = emotion.dateTime;
        }
      }
      return minDateTime;
    }
    return null;
  }

  static Future<List<Emotion>> getMonthEmotion(DateTime month){
    var box = Hive.box<EmotionStorage>(boxName);
    var emotionList = box.values.where((element) => element.dateTime.month == month.month && element.dateTime.year == month.year).map((e) => e.emotion).toList();
    return Future.value(emotionList);
  }
}
