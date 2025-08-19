// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_table_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveTableAdapter extends TypeAdapter<HiveTable> {
  @override
  final int typeId = 11;

  @override
  HiveTable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveTable(
      id: fields[0] as String?,
      name: fields[1] as String?,
      isAvailable: fields[2] as bool?,
      createdBy: fields[3] as String?,
      createdAt: fields[4] as String?,
      updatedAt: fields[5] as String?,
      statusText: fields[6] as String?,
      status: fields[7] as String?,
      lastUpdated: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveTable obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isAvailable)
      ..writeByte(3)
      ..write(obj.createdBy)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.statusText)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveTableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
