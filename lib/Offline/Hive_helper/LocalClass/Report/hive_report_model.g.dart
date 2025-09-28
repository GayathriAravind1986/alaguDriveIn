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
      userName: fields[6] as String?,
      businessName: fields[7] as String?,
      address: fields[8] as String?,
      phone: fields[9] as String?,
      location: fields[10] as String?,
      fromDate: fields[11] as String?,
      toDate: fields[12] as String?,
      gstNumber: fields[13] as String?,
      currencySymbol: fields[14] as String?,
      printType: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveReportModel obj) {
    writer
      ..writeByte(16)
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
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.userName)
      ..writeByte(7)
      ..write(obj.businessName)
      ..writeByte(8)
      ..write(obj.address)
      ..writeByte(9)
      ..write(obj.phone)
      ..writeByte(10)
      ..write(obj.location)
      ..writeByte(11)
      ..write(obj.fromDate)
      ..writeByte(12)
      ..write(obj.toDate)
      ..writeByte(13)
      ..write(obj.gstNumber)
      ..writeByte(14)
      ..write(obj.currencySymbol)
      ..writeByte(15)
      ..write(obj.printType);
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
