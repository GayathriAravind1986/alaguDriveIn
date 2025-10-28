import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
// import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_addon_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/product_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/category_model.dart'; // Add this import
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart'
as product;

// Helper method to get all category IDs from categories box
Future<List<String>> _getAllCategoryIds() async {
  try {
    final categoriesBox = await Hive.openBox<HiveCategory>('categories');
    final allCategories = categoriesBox.values.toList();

    // Extract category IDs and filter out null values
    final categoryIds = allCategories
        .map((category) => category.id)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toList();

    debugPrint("📂 Found ${categoryIds.length} categories in categories box");
    for (var categoryId in categoryIds) {
      debugPrint("   📁 Category ID: $categoryId");
    }

    return categoryIds;
  } catch (e) {
    debugPrint('❌ Error getting category IDs: $e');
    // Fallback to common categories if categories box is empty or has error
    return ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  }
}

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

      // 🧩 Merge prices from existing if API doesn't have them
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
          '✅ Saved product ${hiveProduct.name} — Qty: ${hiveProduct.availableQuantity} in category $categoryId');
    }

    debugPrint('✅ Saved ${products.length} products for category: $categoryId');

    // Also save to master products box for easy access
    await _saveToMasterBox(products);
  } catch (e, stack) {
    debugPrint('❌ Error saving products to Hive: $e');
    debugPrint(stack.toString());
  }
}

// Helper method to save to master box
Future<void> _saveToMasterBox(List<product.Rows> products) async {
  try {
    final masterBox = await Hive.openBox<HiveProduct>('master_products');

    for (var item in products) {
      final hiveProduct = HiveProduct(
        id: item.id,
        name: item.name,
        image: item.image,
        basePrice: item.basePrice?.toDouble() ?? 0.0,
        availableQuantity: item.availableQuantity?.toInt() ?? 0,
        isStock: item.isStock ?? false,
        shortCode: item.shortCode,
        parcelPrice: item.parcelPrice?.toDouble() ?? 0.0,
        acPrice: item.acPrice?.toDouble() ?? 0.0,
        swiggyPrice: item.swiggyPrice?.toDouble() ?? 0.0,
        hdPrice: item.hdPrice?.toDouble() ?? 0.0,
        addons: item.addons
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

      await masterBox.put(hiveProduct.id, hiveProduct);
    }

    debugPrint('✅ Saved ${products.length} products to master box');
  } catch (e) {
    debugPrint('❌ Error saving to master box: $e');
  }
}

// CORRECTED: Load products from category boxes or master box
Future<List<HiveProduct>> loadProductsFromHive(
    String categoryId, {
      String searchKey = "",
      String searchCode = "",
    }) async {
  try {
    // Determine which box to use
    final boxName = categoryId.isEmpty ? 'master_products' : 'products_$categoryId';
    final box = await Hive.openBox<HiveProduct>(boxName);
    List<HiveProduct> products = box.values.toList();

    debugPrint("📦 Loading from ${categoryId.isEmpty ? 'MASTER' : 'CATEGORY $categoryId'} box - Total products: ${products.length}");

    // Apply search filter if needed
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

    // Debug: Show quantities of loaded products
    debugPrint("🎯 Products loaded from ${categoryId.isEmpty ? 'MASTER' : 'CATEGORY $categoryId'}:");
    for (var product in products) {
      debugPrint("   📦 ${product.name} - Available Qty: ${product.availableQuantity}");
    }

    return products;
  } catch (e) {
    debugPrint('❌ Error loading products from Hive: $e');
    return [];
  }
}

// UPDATED METHOD: Direct quantity update for a specific product - Uses actual category IDs
Future<bool> updateProductQuantityDirectly(String productId, int quantityToDeduct) async {
  try {
    debugPrint("🔄 Direct quantity update for: $productId, deduct: $quantityToDeduct");

    bool updated = false;

    // Try master box first
    final masterBox = await Hive.openBox<HiveProduct>('master_products');
    final masterProduct = masterBox.get(productId);
    if (masterProduct != null) {
      final currentQty = masterProduct.availableQuantity ?? 0;
      masterProduct.availableQuantity = (currentQty - quantityToDeduct) > 0 ? (currentQty - quantityToDeduct) : 0;
      await masterBox.put(productId, masterProduct);
      debugPrint("✅ Updated in master box: ${masterProduct.name} from $currentQty to ${masterProduct.availableQuantity}");
      updated = true;
    }

    // UPDATED: Get actual category IDs from categories box instead of hardcoded
    final categoryIds = await _getAllCategoryIds();
    debugPrint("🔍 Searching in ${categoryIds.length} actual categories...");

    for (var categoryId in categoryIds) {
      final boxName = 'products_$categoryId';
      try {
        final categoryBox = await Hive.openBox<HiveProduct>(boxName);
        final categoryProduct = categoryBox.get(productId);
        if (categoryProduct != null) {
          final currentQty = categoryProduct.availableQuantity ?? 0;
          categoryProduct.availableQuantity = (currentQty - quantityToDeduct) > 0 ? (currentQty - quantityToDeduct) : 0;
          await categoryBox.put(productId, categoryProduct);
          debugPrint("✅ Updated in $boxName: ${categoryProduct.name} from $currentQty to ${categoryProduct.availableQuantity}");
          updated = true;
        }
      } catch (e) {
        // Continue to next category
      }
    }

    return updated;
  } catch (e) {
    debugPrint('❌ Error in direct quantity update: $e');
    return false;
  }
}

// UPDATED METHOD: Get current quantity of a product - Uses actual category IDs
Future<int?> getProductQuantity(String productId) async {
  try {
    // Try master box first
    final masterBox = await Hive.openBox<HiveProduct>('master_products');
    final masterProduct = masterBox.get(productId);
    if (masterProduct != null) {
      return masterProduct.availableQuantity;
    }

    // UPDATED: Get actual category IDs from categories box instead of hardcoded
    final categoryIds = await _getAllCategoryIds();
    for (var categoryId in categoryIds) {
      try {
        final categoryBox = await Hive.openBox<HiveProduct>('products_$categoryId');
        final categoryProduct = categoryBox.get(productId);
        if (categoryProduct != null) {
          return categoryProduct.availableQuantity;
        }
      } catch (e) {
        // Continue to next category
      }
    }

    return null;
  } catch (e) {
    debugPrint('❌ Error getting product quantity: $e');
    return null;
  }
}

// NEW METHOD: Find which category a product belongs to using actual categories
Future<String?> findProductCategory(String productId) async {
  try {
    debugPrint("🔍 Finding actual category for product: $productId");

    // Get all actual category IDs
    final categoryIds = await _getAllCategoryIds();

    for (var categoryId in categoryIds) {
      final boxName = 'products_$categoryId';
      try {
        final categoryBox = await Hive.openBox<HiveProduct>(boxName);
        final categoryProduct = categoryBox.get(productId);
        if (categoryProduct != null) {
          // Also get category name from categories box for better logging
          final categoriesBox = await Hive.openBox<HiveCategory>('categories');
          final category = categoriesBox.values.firstWhere(
                (cat) => cat.id == categoryId,
            orElse: () => HiveCategory(name: 'Unknown', id: '', image: ''),
          );

          debugPrint("   ✅ Product found in category: $categoryId (${category.name})");
          return categoryId;
        }
      } catch (e) {
        // Category box might not exist, continue to next
        continue;
      }
    }

    debugPrint("   ❌ Product $productId not found in any category box");
    return null;
  } catch (e) {
    debugPrint('❌ Error finding product category: $e');
    return null;
  }
}

// NEW METHOD: Save products to master box
Future<void> saveProductsToMasterBox(List<product.Rows> products) async {
  try {
    final box = await Hive.openBox<HiveProduct>('master_products');

    for (var item in products) {
      final hiveProduct = HiveProduct(
        id: item.id,
        name: item.name,
        image: item.image,
        basePrice: item.basePrice?.toDouble() ?? 0.0,
        availableQuantity: item.availableQuantity?.toInt() ?? 0,
        isStock: item.isStock ?? false,
        shortCode: item.shortCode,
        parcelPrice: item.parcelPrice?.toDouble() ?? 0.0,
        acPrice: item.acPrice?.toDouble() ?? 0.0,
        swiggyPrice: item.swiggyPrice?.toDouble() ?? 0.0,
        hdPrice: item.hdPrice?.toDouble() ?? 0.0,
        addons: item.addons
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

      await box.put(hiveProduct.id, hiveProduct);
    }

    debugPrint('✅ Saved ${products.length} products to master box');
  } catch (e) {
    debugPrint('❌ Error saving products to master box: $e');
  }
}

// NEW METHOD: Get product by ID from master box
Future<HiveProduct?> getProductFromMasterBox(String productId) async {
  try {
    final box = await Hive.openBox<HiveProduct>('master_products');
    return box.get(productId);
  } catch (e) {
    debugPrint('❌ Error getting product from master box: $e');
    return null;
  }
}

// NEW METHOD: Update product quantity in master box
Future<void> updateProductQuantityInMasterBox(String productId, int newQuantity) async {
  try {
    final box = await Hive.openBox<HiveProduct>('master_products');
    final product = box.get(productId);

    if (product != null) {
      product.availableQuantity = newQuantity > 0 ? newQuantity : 0;
      await box.put(productId, product);
      debugPrint('✅ Updated quantity for ${product.name} to $newQuantity in master box');
    } else {
      debugPrint('❌ Product $productId not found in master box');
    }
  } catch (e) {
    debugPrint('❌ Error updating product quantity in master box: $e');
  }
}

// NEW METHOD: Decrease product quantity in master box
Future<void> decreaseProductQuantityInMasterBox(String productId, int quantityToDecrease) async {
  try {
    final box = await Hive.openBox<HiveProduct>('master_products');
    final product = box.get(productId);

    if (product != null) {
      final currentQuantity = product.availableQuantity ?? 0;
      final newQuantity = currentQuantity - quantityToDecrease;
      product.availableQuantity = newQuantity > 0 ? newQuantity : 0;
      await box.put(productId, product);
      debugPrint('✅ Decreased quantity for ${product.name} from $currentQuantity to ${product.availableQuantity} in master box');
    } else {
      debugPrint('❌ Product $productId not found in master box');
    }
  } catch (e) {
    debugPrint('❌ Error decreasing product quantity in master box: $e');
  }
}

// NEW METHOD: Get all products from master box
Future<List<HiveProduct>> getAllProductsFromMasterBox() async {
  try {
    final box = await Hive.openBox<HiveProduct>('master_products');
    return box.values.toList();
  } catch (e) {
    debugPrint('❌ Error getting all products from master box: $e');
    return [];
  }
}

// NEW METHOD: Search products in master box
Future<List<HiveProduct>> searchProductsInMasterBox(String searchQuery) async {
  try {
    final box = await Hive.openBox<HiveProduct>('master_products');
    final allProducts = box.values.toList();

    if (searchQuery.isEmpty)
    {
      return allProducts;
    }

    final query = searchQuery.toLowerCase();
    return allProducts.where((product) {
      final name = product.name?.toLowerCase() ?? "";
      final code = product.shortCode?.toLowerCase() ?? "";
      return name.contains(query) || code.contains(query);
    }).toList();
  } catch (e) {
    debugPrint('❌ Error searching products in master box: $e');
    return [];
  }
}