// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entries.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EntriesAdapter extends TypeAdapter<Entries> {
  @override
  final int typeId = 1;

  @override
  Entries read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Entries(
      loadName: fields[0] as String,
      powerNeed: fields[1] as int,
      quantity: fields[2] as int,
      totalEnergy: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Entries obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.loadName)
      ..writeByte(1)
      ..write(obj.powerNeed)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.totalEnergy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntriesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
