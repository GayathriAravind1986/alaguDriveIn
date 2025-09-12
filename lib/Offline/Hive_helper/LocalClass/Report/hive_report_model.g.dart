// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveReportModelAdapter extends TypeAdapter<HiveReportModel> {
  @override
  final int typeId = 17;

  @override
  HiveReportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveReportModel(
      productName: fields[0] as String,
      quantity: fields[1] as int,
      amount: fields[2] as double,
      tableNo: fields[3] as String,
      waiterId: fields[4] as String,
      date: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HiveReportModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.productName)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.tableNo)
      ..writeByte(4)
      ..write(obj.waiterId)
      ..writeByte(5)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveReportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
