import 'package:hive/hive.dart';

part 'product_model.g.dart'; // This will be generated

@HiveType(typeId: 1) // Use different typeId from categories
class HiveProduct extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? image;

  @HiveField(3)
  double? basePrice;

  @HiveField(4)
  int? availableQuantity;

  @HiveField(5)
  String? categoryId;

  @HiveField(6)
  List<HiveAddon>? addons;

  HiveProduct({
    this.id,
    this.name,
    this.image,
    this.basePrice,
    this.availableQuantity,
    this.categoryId,
    this.addons,
  });
}

@HiveType(typeId: 2)
class HiveAddon extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  double? price;

  @HiveField(3)
  bool? isFree;

  @HiveField(4)
  int? maxQuantity;

  @HiveField(5)
  bool? isAvailable;

  HiveAddon({
    this.id,
    this.name,
    this.price,
    this.isFree,
    this.maxQuantity,
    this.isAvailable,
  });
}
