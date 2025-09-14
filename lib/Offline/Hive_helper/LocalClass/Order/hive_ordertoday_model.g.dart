// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_ordertoday_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveGetOrderListTodayModelAdapter
    extends TypeAdapter<HiveGetOrderListTodayModel> {
  @override
  final int typeId = 10;

  @override
  HiveGetOrderListTodayModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveGetOrderListTodayModel(
      success: fields[0] as bool?,
      data: (fields[1] as List?)?.cast<HiveOrderData>(),
      total: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveGetOrderListTodayModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.success)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.total);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveGetOrderListTodayModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveOrderDataAdapter extends TypeAdapter<HiveOrderData> {
  @override
  final int typeId = 11;

  @override
  HiveOrderData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveOrderData(
      id: fields[0] as String?,
      orderNumber: fields[1] as String?,
      total: fields[2] as double?,
      tableNo: fields[3] as String?,
      orderType: fields[4] as String?,
      orderStatus: fields[5] as String?,
      createdAt: fields[6] as String?,
      payments: (fields[7] as List?)?.cast<HivePayment>(),
      tableName: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveOrderData obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderNumber)
      ..writeByte(2)
      ..write(obj.total)
      ..writeByte(3)
      ..write(obj.tableNo)
      ..writeByte(4)
      ..write(obj.orderType)
      ..writeByte(5)
      ..write(obj.orderStatus)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.payments)
      ..writeByte(8)
      ..write(obj.tableName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveOrderDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HivePaymentAdapter extends TypeAdapter<HivePayment> {
  @override
  final int typeId = 12;

  @override
  HivePayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HivePayment(
      paymentMethod: fields[0] as String?,
      amount: fields[1] as double?,
      status: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HivePayment obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.paymentMethod)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HivePaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
