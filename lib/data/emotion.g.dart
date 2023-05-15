// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emotion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmotionStorageAdapter extends TypeAdapter<EmotionStorage> {
  @override
  final int typeId = 0;

  @override
  EmotionStorage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmotionStorage(
      fields[0] as Emotion,
    )..dateTime = fields[1] as DateTime;
  }

  @override
  void write(BinaryWriter writer, EmotionStorage obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.emotion)
      ..writeByte(1)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmotionStorageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
