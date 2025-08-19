// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveOrderAdapter extends TypeAdapter<HiveOrder> {
  @override
  final int typeId = 4;

  @override
  HiveOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveOrder(
      id: fields[0] as String?,
      orderPayloadJson: fields[1] as String?,
      orderStatus: fields[2] as String?,
      orderType: fields[3] as String?,
      tableId: fields[4] as String?,
      total: fields[5] as double?,
      createdAt: fields[6] as DateTime?,
      isSynced: fields[7] as bool?,
      items: (fields[8] as List?)?.cast<HiveCartItem>(),
      syncAction: fields[9] as String?,
      existingOrderId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveOrder obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderPayloadJson)
      ..writeByte(2)
      ..write(obj.orderStatus)
      ..writeByte(3)
      ..write(obj.orderType)
      ..writeByte(4)
      ..write(obj.tableId)
      ..writeByte(5)
      ..write(obj.total)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.isSynced)
      ..writeByte(8)
      ..write(obj.items)
      ..writeByte(9)
      ..write(obj.syncAction)
      ..writeByte(10)
      ..write(obj.existingOrderId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
