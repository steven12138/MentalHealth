import 'package:hive/hive.dart';

import 'emotion_dao.dart';

part 'emotion.g.dart';

@HiveType(typeId: 0)
class EmotionStorage extends HiveObject {
  @HiveField(0)
  Emotion emotion;
  @HiveField(1)
  DateTime dateTime = DateTime.now();

  EmotionStorage(this.emotion);
}

