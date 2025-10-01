import 'dart:math' as Math;

import 'package:flutter/foundation.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart' as product_model;
import 'package:simple/ModelClass/Products/get_products_cat_model.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service_productlistitem.dart';

import '../../../ModelClass/Products/get_products_cat_model.dart' as product_model;
import 'local_storage_product.dart';

class BulkDataService {
  static Future<void> fetchAllCategoriesWithProducts() async
  {
    debugPrint('🚀 Starting bulk data fetch...');

    try {
      final GetCategoryModel categoryResponse = await ApiProvider
          .getCategoryAPI();

      if (categoryResponse.errorResponse != null ||
          categoryResponse.data == null) {
        debugPrint(
            '❌ Failed to fetch categories: ${categoryResponse.errorResponse
                ?.message}');
        return;
      }

      final categories = categoryResponse.data!;
      debugPrint('📋 Found ${categories.length} categories');

      if (categories.isEmpty) {
        debugPrint('⚠️ No categories found');
        return;
      }

      for (final category in categories) {
        debugPrint('🏷️ Category: ${category.name} (ID: ${category
            .id}), Product Count: ${category.productCount}');
      }

      final List<Future<void>> futures = [];

      for (final category in categories) {
        if (category.id != null) {
          futures.add(_fetchAndSaveProductsForCategory(
              category.id!, category.name ?? 'Unknown'));

          await Future.delayed(Duration(milliseconds: 300));
        }
      }

      // Wait for all product fetches to complete
      await Future.wait(futures, eagerError: false);

      debugPrint('✅ Bulk data fetch completed! Processed ${categories
          .length} categories');
    } catch (e) {
      debugPrint('❌ Error in bulk data fetch: $e');
    }
  }


  static Future<void> _fetchAndSaveProductsForCategory(String categoryId,
      String categoryName) async {
    try {
      debugPrint(
          '🔄 Fetching products for category: $categoryName ($categoryId)');

      final product_model
          .GetProductByCatIdModel productResponse = await ApiProvider
          .getProductItemAPI(
        categoryId,
        "", // Use empty string instead of null
        "", // Use empty string instead of null
      );

      final product_model.GetProductsCatModel productRes = await ApiProvider
          .getProductsCatAPI(
        categoryId,
        // "", // Use empty string instead of null
        // "", // Use empty string instead of null
      );

      debugPrint(
          '📊 Response for $categoryName: success=${productResponse.success}');
      debugPrint('📊 Rows received: ${productResponse.rows?.length ?? 0}');
      debugPrint('📊 Total count from API: ${productResponse.count}');
      debugPrint('📊 Stock maintenance: ${productResponse.stockMaintenance}');

      if (productResponse.errorResponse != null) {
        debugPrint(
            '❌ API Error for $categoryName: ${productResponse.errorResponse
                ?.message}');
        return;
      }

      if (!(productResponse.success ?? false)) {
        debugPrint('❌ API returned success=false for $categoryName');
        return;
      }

      final products = productResponse.rows ?? [];
      final productbycat = productRes.data ?? [];

      if (products.isEmpty) {
        debugPrint('⚠️ No products found for category: $categoryName');

        // Check if the API indicates there should be products
        if (productResponse.count! > 0) {
          debugPrint('🤔 API inconsistency: count=${productResponse
              .count} but rows is empty');
        }
        return;
      }
      debugPrint(
          '📦 Found ${products.length} products for category: $categoryName');
      // Debug first few products
      if (products.isNotEmpty) {
        for (int i = 0; i < Math.min(products.length, 3); i++) {
          final product = products[i];
          debugPrint('🔍 Product ${i + 1}: ${product.name} (ID: ${product
              .id}) - Price: ${product.basePrice}');
        }
      }

      // Save to Hive using your existing method
      await saveProductsToHive(categoryId, products);


      debugPrint('💾 Successfully saved ${products
          .length} products for category: $categoryName');
    } catch (e) {
      debugPrint('❌ Error fetching products for category $categoryName: $e');
    }
  }

  static Future<void> fetchAndCacheAllCategoriesAndProducts() async {
    try {
      // Step 1: Get categories
      final GetCategoryModel categoryResponse = await ApiProvider
          .getCategoryAPI();

      if (categoryResponse.errorResponse != null) {
        debugPrint(
            "❌ Error fetching categories: ${categoryResponse.errorResponse
                ?.message}");
        return;
      }

      if (categoryResponse.data == null || categoryResponse.data!.isEmpty) {
        debugPrint("⚠️ No categories found.");
        return;
      }

      // ✅ Cache categories
      await ProductCacheService.saveCategories(categoryResponse);

      // Step 2: Loop through categories and fetch products
      for (var category in categoryResponse.data!) {
        final String? categoryId = category.id;
        final String? categoryName = category.name;

        if (categoryId == null) continue;

        debugPrint(
            "🔄 Fetching products for category: $categoryName ($categoryId)");

        final GetProductsCatModel productResponse =
        await ApiProvider.getProductsCatAPI(categoryId);

        if (productResponse.errorResponse != null) {
          debugPrint(
              "❌ Error fetching products for $categoryName: ${productResponse
                  .errorResponse?.message}");
        } else {
          // ✅ Cache in Hive
          await ProductCacheService.saveProductsCat(categoryId, productResponse);

          // debugPrint("✅ Cached ${productResponse.data?.length ??
          //     0} products for $categoryName");
        }
      }

      debugPrint("🎉 Completed fetching & caching all categories & products.");
    } catch (e, st) {
      debugPrint("🔥 Unexpected error: $e\n$st");
    }
  }
}