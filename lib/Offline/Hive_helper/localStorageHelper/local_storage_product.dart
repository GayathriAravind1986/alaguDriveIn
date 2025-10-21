import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
// import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_addon_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/product_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart'
    as product;

// Future<void> saveProductsToHive(
//     String categoryId, List<product.Rows> products) async {
//   try {
//     final box = await Hive.openBox<HiveProduct>('products_$categoryId');
//     await box.clear();
//     for (var product in products) {
//       final hiveProduct = HiveProduct(
//         id: product.id,
//         name: product.name,
//         image: product.image,
//         basePrice: product.basePrice?.toDouble() ?? 0.0,
//         availableQuantity: product.availableQuantity?.toInt() ?? 0,
//         isStock: product.isStock ?? false,
//         shortCode: product.shortCode,
//         parcelPrice: product.parcelPrice?.toDouble() ?? 0.0,
//         acPrice: product.acPrice?.toDouble() ?? 0.0,
//         swiggyPrice: product.swiggyPrice?.toDouble() ?? 0.0,
//         hdPrice: product.hdPrice?.toDouble() ?? 0.0,
//         addons: product.addons
//             ?.map((addon) => HiveAddon(
//                   id: addon.id,
//                   name: addon.name,
//                   price: addon.price?.toDouble() ?? 0.0,
//                   isFree: addon.isFree,
//                   maxQuantity: addon.maxQuantity?.toInt() ?? 1,
//                   isAvailable: addon.isAvailable,
//                 ))
//             .toList(),
//       );
//
//       await box.add(hiveProduct);
//       debugPrint('✅ Saved HiveOffline value:${product.parcelPrice}');
//     }
//     debugPrint('✅ Saved ${products.length} products for category: $categoryId');
//   } catch (e) {
//     debugPrint('❌ Error saving products to Hive: $e');
//   }
// }
Future<void> saveProductsToHive(
  String categoryId,
  List<product.Rows> products,
) async {
  try {
    final box = await Hive.openBox<HiveProduct>('products_$categoryId');

    for (var item in products) {
      // 🔍 Try to find existing product in Hive
      final existing = box.values.firstWhere(
        (p) => p.id == item.id,
        orElse: () => HiveProduct(),
      );

      // 🧩 Merge prices from existing if API doesn’t have them
      final hiveProduct = HiveProduct(
        id: item.id,
        name: item.name,
        image: item.image,
        basePrice: item.basePrice?.toDouble() ?? existing.basePrice ?? 0.0,
        availableQuantity:
            item.availableQuantity?.toInt() ?? existing.availableQuantity ?? 0,
        isStock: item.isStock ?? existing.isStock ?? false,
        shortCode: item.shortCode ?? existing.shortCode,
        parcelPrice:
            item.parcelPrice?.toDouble() ?? existing.parcelPrice ?? 0.0,
        acPrice: item.acPrice?.toDouble() ?? existing.acPrice ?? 0.0,
        swiggyPrice:
            item.swiggyPrice?.toDouble() ?? existing.swiggyPrice ?? 0.0,
        hdPrice: item.hdPrice?.toDouble() ?? existing.hdPrice ?? 0.0,
        addons: item.addons
                ?.map((addon) => HiveAddon(
                      id: addon.id,
                      name: addon.name,
                      price: addon.price?.toDouble() ?? 0.0,
                      isFree: addon.isFree,
                      maxQuantity: addon.maxQuantity?.toInt() ?? 1,
                      isAvailable: addon.isAvailable,
                    ))
                .toList() ??
            existing.addons,
      );

      // 🧠 Save or update by ID (not by index)
      await box.put(hiveProduct.id, hiveProduct);

      debugPrint(
          '✅ Saved product ${hiveProduct.name} — AC: ${hiveProduct.acPrice}, Parcel: ${hiveProduct.parcelPrice}');
    }

    debugPrint('✅ Saved ${products.length} products for category: $categoryId');
  } catch (e, stack) {
    debugPrint('❌ Error saving products to Hive: $e');
    debugPrint(stack.toString());
  }
}

Future<List<HiveProduct>> loadProductsFromHive(
  String categoryId, {
  String searchKey = "",
  String searchCode = "",
}) async {
  try {
    final box = await Hive.openBox<HiveProduct>('products_$categoryId');
    List<HiveProduct> products = box.values.toList();

    if (searchKey.isNotEmpty || searchCode.isNotEmpty) {
      products = products.where((product) {
        final name = product.name?.toLowerCase() ?? "";
        final code = product.shortCode?.toLowerCase() ?? "";
        final key = searchKey.toLowerCase();
        final codeKey = searchCode.toLowerCase();
        final matchesName = key.isEmpty ? false : name.contains(key);
        final matchesCode = codeKey.isEmpty ? false : code.contains(codeKey);

        return matchesName || matchesCode;
      }).toList();
    }

    return products;
  } catch (e) {
    debugPrint('❌ Error loading products from Hive: $e');
    return [];
  }
}
