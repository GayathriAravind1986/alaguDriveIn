import 'package:hive/hive.dart';

import '../../../../ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart';

part 'product_model.g.dart';

@HiveType(typeId: 1)
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
  List<HiveAddon>? addons;

  @HiveField(6)
  bool? isStock;

  HiveProduct({
    this.id,
    this.name,
    this.image,
    this.basePrice,
    this.availableQuantity,
    this.addons,
    this.isStock,
  });

  /// 🔑 Factory to create HiveProduct from API Rows
  factory HiveProduct.fromApi(Rows row) {
    return HiveProduct(
      id: row.id,
      name: row.name,
      image: row.image,
      basePrice: (row.basePrice ?? 0).toDouble(),
      availableQuantity: row.availableQuantity?.toInt() ?? 0,
      isStock: _toBool(row.isStock),
      addons: row.addons?.map((a) => HiveAddon.fromApi(a)).toList(),
    );
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1; // ✅ 1 => true, 0 => false
    if (value is String) return value == "true" || value == "1";
    return null;
  }
}

@HiveType(typeId: 28)
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

  /// 🔑 Factory to create HiveAddon from API Addons
  factory HiveAddon.fromApi(Addons addon) {
    return HiveAddon(
      id: addon.id,
      name: addon.name,
      price: (addon.price ?? 0).toDouble(),
      maxQuantity: addon.maxQuantity?.toInt() ?? 0,
      isFree: HiveProduct._toBool(addon.isFree),
      isAvailable: HiveProduct._toBool(addon.isAvailable),
    );
  }
}
