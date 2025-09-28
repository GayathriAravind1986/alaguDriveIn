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
      product: fields[0] as String?,
      name: fields[1] as String?,
      image: fields[2] as String?,
      quantity: fields[3] as int?,
      unitPrice: fields[4] as double?,
      basePrice: fields[5] as double?,
      subtotal: fields[6] as double?,
      selectedAddons: (fields[7] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
      isFree: fields[8] as bool?,
      taxPrice: fields[9] as double?,
      totalPrice: fields[10] as double?,
      id: fields[11] as String?,
      qty: fields[12] as int?,
      availableQuantity: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveCartItem obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.product)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.image)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.unitPrice)
      ..writeByte(5)
      ..write(obj.basePrice)
      ..writeByte(6)
      ..write(obj.subtotal)
      ..writeByte(7)
      ..write(obj.selectedAddons)
      ..writeByte(8)
      ..write(obj.isFree)
      ..writeByte(9)
      ..write(obj.taxPrice)
      ..writeByte(10)
      ..write(obj.totalPrice)
      ..writeByte(11)
      ..write(obj.id)
      ..writeByte(12)
      ..write(obj.qty)
      ..writeByte(13)
      ..write(obj.availableQuantity);
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
