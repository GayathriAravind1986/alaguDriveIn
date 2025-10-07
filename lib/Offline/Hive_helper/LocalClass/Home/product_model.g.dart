// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveProductAdapter extends TypeAdapter<HiveProduct> {
  @override
  final int typeId = 1;

  @override
  HiveProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveProduct(
      id: fields[0] as String?,
      name: fields[1] as String?,
      image: fields[2] as String?,
      basePrice: fields[3] as double?,
      availableQuantity: fields[4] as int?,
      addons: (fields[5] as List?)?.cast<HiveAddon>(),
      isStock: fields[6] as bool?,
      shortCode: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveProduct obj) {
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
      ..write(obj.availableQuantity)
      ..writeByte(5)
      ..write(obj.addons)
      ..writeByte(6)
      ..write(obj.isStock)
      ..writeByte(7)
      ..write(obj.shortCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveAddonAdapter extends TypeAdapter<HiveAddon> {
  @override
  final int typeId = 28;

  @override
  HiveAddon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveAddon(
      id: fields[0] as String?,
      name: fields[1] as String?,
      price: fields[2] as double?,
      isFree: fields[3] as bool?,
      maxQuantity: fields[4] as int?,
      isAvailable: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveAddon obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.isFree)
      ..writeByte(4)
      ..write(obj.maxQuantity)
      ..writeByte(5)
      ..write(obj.isAvailable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveAddonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
