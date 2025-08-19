// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_selected_addons_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveSelectedAddonAdapter extends TypeAdapter<HiveSelectedAddon> {
  @override
  final int typeId = 3;

  @override
  HiveSelectedAddon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSelectedAddon(
      id: fields[0] as String?,
      name: fields[1] as String?,
      price: fields[2] as double?,
      quantity: fields[3] as int?,
      isAvailable: fields[4] as bool?,
      maxQuantity: fields[5] as int?,
      isFree: fields[6] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSelectedAddon obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.isAvailable)
      ..writeByte(5)
      ..write(obj.maxQuantity)
      ..writeByte(6)
      ..write(obj.isFree);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveSelectedAddonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
