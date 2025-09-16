// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_pending_stock_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HivePendingStockAdapter extends TypeAdapter<HivePendingStock> {
  @override
  final int typeId = 70;

  @override
  HivePendingStock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HivePendingStock()
      ..id = fields[0] as String?
      ..payload = fields[1] as String?
      ..synced = fields[2] as bool?
      ..createdAt = fields[3] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, HivePendingStock obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.payload)
      ..writeByte(2)
      ..write(obj.synced)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HivePendingStockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
