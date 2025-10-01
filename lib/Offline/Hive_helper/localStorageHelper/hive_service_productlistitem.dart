import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart';
import 'package:simple/ModelClass/Products/get_products_cat_model.dart';

class ProductCacheService {
  static const String _boxName = "appCacheBox";

  /// Get cache box - use single box for all data
  static Future<Box> _getBox() async {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        return Hive.box(_boxName);
      }
      return await Hive.openBox(_boxName);
    } catch (e) {
      print("Error opening Hive box: $e");
      rethrow;
    }
  }

  /// Save categories
  static Future<void> saveCategories(GetCategoryModel model) async {
    try {
      final box = await _getBox();
      final jsonString = jsonEncode(model.toJson());
      await box.put("categories", jsonString);
      print("Categories cached successfully");
      print(jsonString);
    } catch (e) {
      print("Error saving categories to cache: $e");
    }
  }

  /// Get categories
  Future<GetCategoryModel?> getCategories() async {
    try {
      final box = await _getBox();
      final data = box.get("categories");

      if (data != null && data is String) {
        print("Found cached categories data");
        final Map<String, dynamic> decoded = jsonDecode(data);
        return GetCategoryModel.fromJson(decoded);
      } else {
        print("No cached categories data found");
        return null;
      }
    } catch (e) {
      print("Error getting categories from cache: $e");
      return null;
    }
  }

  /// Save products by category
  static Future<void> saveProductsCat(String catId, GetProductsCatModel model) async {
    try {
      final box = await _getBox();
      final key = "products_$catId";
      final jsonString = jsonEncode(model.toJson());
      await box.put(key, jsonString);
      print(key+" "+jsonString);
      print("Products for $catId cached successfully");
    } catch (e) {
      print("Error saving products to cache: $e");
    }
  }

  /// Get products by category
  Future<GetProductsCatModel?> getProductsCat(String catId) async {
    try {
      final box = await _getBox();
      final key = "products_$catId";
      final data = box.get(key);

      if (data != null && data is String) {
        print("Found cached products data for $catId");
        final Map<String, dynamic> decoded = jsonDecode(data);
        return GetProductsCatModel.fromJson(decoded);
      } else {
        print("No cached products data found for $catId");
        return null;
      }
    } catch (e) {
      print("Error getting products from cache: $e");
      return null;
    }
  }

  /// Clear products cache for a category
  Future<void> clearProductsCache(String catId) async {
    try {
      final box = await _getBox();
      final key = "products_$catId";
      await box.delete(key);
      print("Products cache cleared for $catId");
    } catch (e) {
      print("Error clearing products cache: $e");
    }
  }

  /// Clear all categories cache
  Future<void> clearAllCache() async {
    try {
      final box = await _getBox();
      await box.clear();
      print("All cache cleared");
    } catch (e) {
      print("Error clearing all cache: $e");
    }
  }

  /// Debug method to check what's in cache
  Future<void> debugCache() async {
    try {
      final box = await _getBox();
      print("=== CACHE DEBUG ===");
      print("Cache box keys: ${box.keys.toList()}");

      // Check categories
      final categoriesData = box.get("categories");
      print("Categories cached: ${categoriesData != null}");

      // Check all product keys
      for (var key in box.keys) {
        if (key.toString().startsWith('products_')) {
          print("Cached products key: $key");
        }
      }
      print("=== END DEBUG ===");
    } catch (e) {
      print("Error debugging cache: $e");
    }
  }
}