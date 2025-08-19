// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_stock_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveStockMaintenanceAdapter extends TypeAdapter<HiveStockMaintenance> {
  @override
  final int typeId = 10;

  @override
  HiveStockMaintenance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveStockMaintenance(
      id: fields[0] as String?,
      name: fields[1] as String?,
      stockMaintenance: fields[2] as bool?,
      lastUpdated: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveStockMaintenance obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.stockMaintenance)
      ..writeByte(3)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveStockMaintenanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
