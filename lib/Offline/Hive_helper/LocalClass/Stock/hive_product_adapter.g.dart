// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:hive/hive.dart';
import 'hive_product_stock.dart';

// part of 'hive_product_stock.dart';


class HiveProductStockAdapter extends TypeAdapter<HiveProductStock> {
  @override
  final int typeId = 13;

  @override
  HiveProductStock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveProductStock(
      id: fields[0] as String?,
      name: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveProductStock obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is HiveProductStockAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}