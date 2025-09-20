// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_pending_delete.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingDeleteAdapter extends TypeAdapter<PendingDelete> {
  @override
  final int typeId = 65;

  @override
  PendingDelete read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingDelete(
      orderId: fields[0] as String,
      timestamp: fields[1] as DateTime,
      status: fields[2] as String,
      retryCount: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PendingDelete obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.orderId)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.retryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingDeleteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
