// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_waiter_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveWaiterAdapter extends TypeAdapter<HiveWaiter> {
  @override
  final int typeId = 15;

  @override
  HiveWaiter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveWaiter(
      id: fields[0] as String?,
      name: fields[1] as String?,
      isAvailable: fields[2] as bool?,
      locationId: fields[3] as String?,
      locationName: fields[4] as String?,
      createdBy: fields[5] as String?,
      createdAt: fields[6] as String?,
      updatedAt: fields[7] as String?,
      statusText: fields[8] as String?,
      status: fields[9] as String?,
      lastUpdated: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveWaiter obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isAvailable)
      ..writeByte(3)
      ..write(obj.locationId)
      ..writeByte(4)
      ..write(obj.locationName)
      ..writeByte(5)
      ..write(obj.createdBy)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.statusText)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveWaiterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
