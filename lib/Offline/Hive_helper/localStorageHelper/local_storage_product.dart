import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
// import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_addon_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/product_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart'
    as product;

Future<void> saveProductsToHive(
    String categoryId, List<product.Rows> products) async {
  try {
    final box = await Hive.openBox<HiveProduct>('products_$categoryId');
    await box.clear();
    for (var product in products) {
      final hiveProduct = HiveProduct(
        id: product.id,
        name: product.name,
        image: product.image,
        basePrice: product.basePrice?.toDouble() ?? 0.0,
        availableQuantity: product.availableQuantity?.toInt() ?? 0,
        isStock: product.isStock ?? false,
        addons: product.addons
            ?.map((addon) => HiveAddon(
                  id: addon.id,
                  name: addon.name,
                  price: addon.price?.toDouble() ?? 0.0,
                  isFree: addon.isFree,
                  maxQuantity: addon.maxQuantity?.toInt() ?? 1,
                  isAvailable: addon.isAvailable,
                ))
            .toList(),
      );
      await box.add(hiveProduct);
    }
    debugPrint('✅ Saved ${products.length} products for category: $categoryId');
  } catch (e) {
    debugPrint('❌ Error saving products to Hive: $e');
  }
}

Future<List<HiveProduct>> loadProductsFromHive(String categoryId,
    {String searchKey = ""}) async {
  try {
    final box = await Hive.openBox<HiveProduct>('products_$categoryId');
    List<HiveProduct> products = box.values.toList();
    if (searchKey.isNotEmpty) {
      products = products
          .where((product) =>
              product.name?.toLowerCase().contains(searchKey.toLowerCase()) ??
              false)
          .toList();
    }

    debugPrint(
        '✅ Loaded ${products.length} products from Hive for category: $categoryId');
    return products;
  } catch (e) {
    debugPrint('❌ Error loading products from Hive: $e');
    return [];
  }
}
