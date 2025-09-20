// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_product_list_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GetProductByCatIdModelAdapter
    extends TypeAdapter<GetProductByCatIdModel> {
  @override
  final int typeId = 90;

  @override
  GetProductByCatIdModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GetProductByCatIdModel(
      success: fields[0] as bool?,
      rows: (fields[1] as List?)?.cast<Product>(),
      count: fields[2] as num?,
      stockMaintenance: fields[3] as bool?,
      errorResponse: fields[4] as ErrorResponse?,
    );
  }

  @override
  void write(BinaryWriter writer, GetProductByCatIdModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.success)
      ..writeByte(1)
      ..write(obj.rows)
      ..writeByte(2)
      ..write(obj.count)
      ..writeByte(3)
      ..write(obj.stockMaintenance)
      ..writeByte(4)
      ..write(obj.errorResponse);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetProductByCatIdModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 91;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String?,
      name: fields[1] as String?,
      category: fields[2] as Category?,
      basePrice: fields[3] as num?,
      hasAddons: fields[4] as bool?,
      isAvailable: fields[5] as bool?,
      createdBy: fields[6] as String?,
      createdAt: fields[7] as String?,
      updatedAt: fields[8] as String?,
      v: fields[9] as num?,
      image: fields[10] as String?,
      addons: (fields[11] as List?)?.cast<Addon>(),
      counter: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.basePrice)
      ..writeByte(4)
      ..write(obj.hasAddons)
      ..writeByte(5)
      ..write(obj.isAvailable)
      ..writeByte(6)
      ..write(obj.createdBy)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.v)
      ..writeByte(10)
      ..write(obj.image)
      ..writeByte(11)
      ..write(obj.addons)
      ..writeByte(12)
      ..write(obj.counter);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AddonAdapter extends TypeAdapter<Addon> {
  @override
  final int typeId = 92;

  @override
  Addon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Addon(
      id: fields[0] as String?,
      name: fields[1] as String?,
      maxQuantity: fields[2] as num?,
      price: fields[3] as num?,
      isAvailable: fields[4] as bool?,
      isFree: fields[5] as bool?,
      products: (fields[6] as List?)?.cast<String>(),
      isSelected: fields[7] as bool,
      quantity: fields[8] as num,
    );
  }

  @override
  void write(BinaryWriter writer, Addon obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.maxQuantity)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.isAvailable)
      ..writeByte(5)
      ..write(obj.isFree)
      ..writeByte(6)
      ..write(obj.products)
      ..writeByte(7)
      ..write(obj.isSelected)
      ..writeByte(8)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 93;

  @override
  Category read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Category(
      id: fields[0] as String?,
      name: fields[1] as String?,
      isAvailable: fields[2] as bool?,
      image: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isAvailable)
      ..writeByte(3)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
