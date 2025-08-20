// Products
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Stock/hive_location_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Stock/hive_product_stock.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Stock/hive_supplier_model.dart';
import 'package:simple/ModelClass/StockIn/get_add_product_model.dart'
    as product;
import 'package:simple/ModelClass/StockIn/getLocationModel.dart' as location;
import 'package:simple/ModelClass/StockIn/getSupplierLocationModel.dart'
    as supplier;

Future<void> saveProductsToHive(List<product.Data> products) async {
  final box = await Hive.openBox<HiveProductStock>('products');
  await box.clear();
  for (var product in products) {
    await box.put(
        product.id,
        HiveProductStock(
          id: product.id,
          name: product.name,
        ));
  }
}

// Suppliers
Future<void> saveSuppliersToHive(List<supplier.Data> suppliers) async {
  final box = await Hive.openBox<HiveSupplier>('suppliers');
  await box.clear();
  for (var supplier in suppliers) {
    await box.put(
        supplier.id,
        HiveSupplier(
          id: supplier.id,
          name: supplier.name,
        ));
  }
}

// Locations
Future<void> saveLocationToHive(location.Data apiData) async {
  final box = Hive.box<HiveLocation>('location');
  final hiveLocation = HiveLocation(
    id: apiData.id,
    locationId: apiData.locationId,
    locationName: apiData.locationName,
  );
  await box.put('current_location', hiveLocation);
}

Future<List<HiveProductStock>> loadProductsFromHive() async {
  try {
    if (!Hive.isBoxOpen('products')) {
      await Hive.openBox<HiveProductStock>('products');
    }

    final box = Hive.box<HiveProductStock>('products');
    final products = box.values.toList();
    debugPrint("🔍 Loaded ${products.length} products from Hive");
    return products;
  } catch (e) {
    debugPrint("❌ Error loading products from Hive: $e");
    return [];
  }
}

Future<List<HiveSupplier>> loadSuppliersFromHive() async {
  try {
    if (!Hive.isBoxOpen('suppliers')) {
      await Hive.openBox<HiveSupplier>('suppliers');
    }

    final box = Hive.box<HiveSupplier>('suppliers');
    final suppliers = box.values.toList();
    debugPrint("🔍 Loaded ${suppliers.length} suppliers from Hive");
    return suppliers;
  } catch (e) {
    debugPrint("❌ Error loading suppliers from Hive: $e");
    return [];
  }
}

Future<HiveLocation?> loadLocationFromHive() async {
  try {
    // Ensure box is opened
    if (!Hive.isBoxOpen('location')) {
      await Hive.openBox<HiveLocation>('location');
    }

    final box = Hive.box<HiveLocation>('location');
    final location = box.get('current_location');
    debugPrint("🔍 Loading from Hive: ${location?.locationName}");
    return location;
  } catch (e) {
    debugPrint("❌ Error loading from Hive: $e");
    return null;
  }
}
