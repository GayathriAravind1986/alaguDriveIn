// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_billing_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveBillingSessionAdapter extends TypeAdapter<HiveBillingSession> {
  @override
  final int typeId = 5;

  @override
  HiveBillingSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveBillingSession(
      items: (fields[0] as List?)?.cast<HiveCartItem>(),
      isDiscountApplied: fields[1] as bool?,
      subtotal: fields[2] as double?,
      totalTax: fields[3] as double?,
      total: fields[4] as double?,
      totalDiscount: fields[5] as double?,
      lastUpdated: fields[6] as DateTime?,
      orderType: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveBillingSession obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.items)
      ..writeByte(1)
      ..write(obj.isDiscountApplied)
      ..writeByte(2)
      ..write(obj.subtotal)
      ..writeByte(3)
      ..write(obj.totalTax)
      ..writeByte(4)
      ..write(obj.total)
      ..writeByte(5)
      ..write(obj.totalDiscount)
      ..writeByte(6)
      ..write(obj.lastUpdated)
      ..writeByte(7)
      ..write(obj.orderType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveBillingSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
