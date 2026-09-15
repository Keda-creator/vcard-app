// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'physical_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhysicalCardAdapter extends TypeAdapter<PhysicalCard> {
  @override
  final int typeId = 0;

  @override
  PhysicalCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhysicalCard(
      id: fields[0] as String,
      name: fields[1] as String,
      frontImagePath: fields[2] as String,
      backImagePath: fields[3] as String?,
      notes: fields[4] as String?,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PhysicalCard obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.frontImagePath)
      ..writeByte(3)
      ..write(obj.backImagePath)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhysicalCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
