import 'package:hive/hive.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/product_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart'
    as product;

Future<void> saveProductsToHive(
    List<product.Rows> products, String categoryId) async {
  try {
    final productBox = Hive.box<HiveProduct>('products');

    // Remove existing products for this category
    final existingKeys = productBox.keys
        .where((key) => productBox.get(key)?.categoryId == categoryId)
        .toList();

    for (var key in existingKeys) {
      await productBox.delete(key);
    }

    // Add new products
    for (var product in products) {
      final hiveProduct = HiveProduct(
        id: product.id,
        name: product.name,
        image: product.image,
        basePrice: product.basePrice?.toDouble(),
        availableQuantity: product.availableQuantity?.toInt(),
        categoryId: categoryId,
        addons: product.addons
            ?.map((addon) => HiveAddon(
                  id: addon.id,
                  name: addon.name,
                  price: addon.price?.toDouble(),
                  isFree: addon.isFree,
                  maxQuantity: addon.maxQuantity?.toInt(),
                  isAvailable: addon.isAvailable,
                ))
            .toList(),
      );
      await productBox.add(hiveProduct);
    }
    print('Saved ${products.length} products to Hive for category $categoryId');
  } catch (e) {
    print('Error saving products to Hive: $e');
  }
}

Future<List<HiveProduct>> loadProductsFromHive(String categoryId) async {
  try {
    final productBox = Hive.box<HiveProduct>('products');
    return productBox.values
        .where((product) => product.categoryId == categoryId)
        .toList();
  } catch (e) {
    print('Error loading products from Hive: $e');
    return [];
  }
}
