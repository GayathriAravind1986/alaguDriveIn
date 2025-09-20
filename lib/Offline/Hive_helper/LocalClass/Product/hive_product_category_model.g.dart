// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_product_category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataAdapter extends TypeAdapter<Data> {
  @override
  final int typeId = 80;

  @override
  Data read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Data()
      .._id = fields[0] as String?
      .._name = fields[1] as String?
      .._isAvailable = fields[2] as bool?
      .._image = fields[3] as String?
      .._sortOrder = fields[4] as num?
      .._createdBy = fields[5] as String?
      .._createdAt = fields[6] as String?
      .._updatedAt = fields[7] as String?
      .._statusText = fields[8] as String?
      .._productCount = fields[9] as num?;
  }

  @override
  void write(BinaryWriter writer, Data obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj._id)
      ..writeByte(1)
      ..write(obj._name)
      ..writeByte(2)
      ..write(obj._isAvailable)
      ..writeByte(3)
      ..write(obj._image)
      ..writeByte(4)
      ..write(obj._sortOrder)
      ..writeByte(5)
      ..write(obj._createdBy)
      ..writeByte(6)
      ..write(obj._createdAt)
      ..writeByte(7)
      ..write(obj._updatedAt)
      ..writeByte(8)
      ..write(obj._statusText)
      ..writeByte(9)
      ..write(obj._productCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
