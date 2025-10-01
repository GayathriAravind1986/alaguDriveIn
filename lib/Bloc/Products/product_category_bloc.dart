import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/ModelClass/Products/get_products_cat_model.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service_productlistitem.dart';
import 'package:simple/UI/Home_screen/home_screen.dart';

import '../../ModelClass/HomeScreen/Category&Product/Get_category_model.dart';

abstract class ProductCategoryEvent {}

class ProductCategory extends ProductCategoryEvent {}

class ProductItem extends ProductCategoryEvent {
  String catId;
  ProductItem(this.catId);
}

class ProductCategoryBloc extends Bloc<ProductCategoryEvent, dynamic> {
  ProductCategoryBloc() : super(null) {
    final ProductCacheService cacheService = ProductCacheService();

    on<ProductCategory>((event, emit) async {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        try {
          final GetCategoryModel response = await ApiProvider.getCategoryAPI();
          // Check if response is valid and successful
          if (response.success == true && response.data != null) {
            emit(response);
            await ProductCacheService.saveCategories(response);
            print("Categories saved to cache");
          }
          else
          {
            final cachedData = await cacheService.getCategories();
            if (cachedData != null)
            {
              print("Using cached categories due to API error");
              emit(cachedData);
            }
            else
            {
              emit("API error and no cached data available");
            }
          }
        } catch (error) {
          print("API call failed: $error");
          // If API fails, fallback to cache
          final cachedData = await cacheService.getCategories();
          if (cachedData != null) {
            print("Using cached categories due to API exception");
            emit(cachedData);
          } else {
            emit("Network error: $error");
          }
        }
      } else {
        // Offline: return cached categories
        print("Offline mode - loading cached categories");
        final cachedData = await cacheService.getCategories();
        if (cachedData != null) {
          print("Found cached categories");
          emit(cachedData);
        } else {
          print("No cached categories found");
          emit("No internet and no cached data available");
        }
      }
    });

    on<ProductItem>((event, emit) async {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        try {
          final GetProductsCatModel response = await ApiProvider.getProductsCatAPI(event.catId);

          // Check if response is valid and successful
          if (response.success == true && response.data != null) {
            emit(response);
            await ProductCacheService.saveProductsCat(event.catId, response);
            print("Products saved to cache for category: ${event.catId}");
          }
          else
          {
            // API returned unsuccessful, try cache
            final cachedData = await cacheService.getProductsCat(event.catId);
            if (cachedData != null) {
              print("Using cached products due to API error");
              emit(cachedData);
            }
            else
            {
              emit("API error and no cached products available");
            }
          }
        } catch (error) {
          print("Products API call failed: $error");
          // If API fails, fallback to cache
          final cachedData = await cacheService.getProductsCat(event.catId);
          if (cachedData != null) {
            print("Using cached products due to API exception");
            emit(cachedData);
          } else {
            emit("Network error: $error");
          }
        }
      } else {
        // Offline: return cached products
        print("Offline mode - loading cached products for category: ${event.catId}");
        final cachedData = await cacheService.getProductsCat(event.catId);
        if (cachedData != null) {
          print("Found cached products for category: ${event.catId}");
          emit(cachedData);
        } else {
          print("No cached products found for category: ${event.catId}");
          emit("No internet and no cached products available");
        }
      }
    });
  }
}