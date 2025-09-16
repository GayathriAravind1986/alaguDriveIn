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
  final box = Hive.box<HiveProductStock>('products_box');
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
  final box = Hive.box<HiveSupplier>('suppliers');
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
  try {
    final box = Hive.box<HiveLocation>('location');
    final hiveLocation = HiveLocation(
      id: apiData.id,
      locationName: apiData.locationName,
      locationId: apiData.locationId,
    );
    await box.put('current_location', hiveLocation);
    debugPrint("✅ Saved to Hive: ${hiveLocation.locationName}");
  } catch (e) {
    debugPrint("❌ Error saving to Hive: $e");
  }
}

Future<HiveLocation?> loadLocationFromHive() async {
  try {
    Box<HiveLocation> box;

    if (!Hive.isBoxOpen('location')) {
      box = await Hive.openBox<HiveLocation>('location');
    } else {
      box = Hive.box<HiveLocation>('location');
    }

    final location = box.get('current_location');
    debugPrint(
        "🔍 Loading from Hive: ${location?.locationName} (ID: ${location?.locationId})");
    return location;
  } catch (e) {
    debugPrint("❌ Error loading location from Hive: $e");
    return null;
  }
}

Future<List<HiveSupplier>> loadSuppliersFromHive() async {
  try {
    Box<HiveSupplier> box;

    if (!Hive.isBoxOpen('suppliers')) {
      box = await Hive.openBox<HiveSupplier>('suppliers');
    } else {
      box = Hive.box<HiveSupplier>('suppliers');
    }

    final suppliers = box.values.toList();
    debugPrint("🔍 Loaded ${suppliers.length} suppliers from Hive");
    return suppliers;
  } catch (e) {
    debugPrint("❌ Error loading suppliers from Hive: $e");
    return [];
  }
}

Future<List<HiveProductStock>> loadProductsFromHive() async {
  try {
    Box<HiveProductStock> box;

    if (!Hive.isBoxOpen('products_box'))
    {
      box = await Hive.openBox<HiveProductStock>('products_box');
    }
    else {
      box = Hive.box<HiveProductStock>('products_box');
    }

    final products = box.values.toList();
    debugPrint("🔍 Loaded ${products.length} products from Hive");
    return products;
  } catch (e) {
    debugPrint("❌ Error loading products from Hive: $e");
    return [];
  }
}
