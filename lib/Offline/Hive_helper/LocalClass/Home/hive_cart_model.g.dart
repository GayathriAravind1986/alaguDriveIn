// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_cart_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveCartItemAdapter extends TypeAdapter<HiveCartItem> {
  @override
  final int typeId = 2;

  @override
  HiveCartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveCartItem(
      id: fields[0] as String?,
      name: fields[1] as String?,
      image: fields[2] as String?,
      basePrice: fields[3] as double?,
      qty: fields[4] as int?,
      availableQuantity: fields[5] as int?,
      selectedAddons: (fields[6] as List?)?.cast<HiveSelectedAddon>(),
      createdAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveCartItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.image)
      ..writeByte(3)
      ..write(obj.basePrice)
      ..writeByte(4)
      ..write(obj.qty)
      ..writeByte(5)
      ..write(obj.availableQuantity)
      ..writeByte(6)
      ..write(obj.selectedAddons)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveCartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
