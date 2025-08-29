import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/Bloc/Response/errorResponse.dart';
import 'package:simple/ModelClass/StockIn/getLocationModel.dart' as location;
import 'package:simple/ModelClass/StockIn/getSupplierLocationModel.dart'
as supplier;
import 'package:simple/Offline/Hive_helper/LocalClass/Stock/hive_location_model.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/Stock/hive_stock_service.dart';
import 'package:simple/ModelClass/StockIn/get_add_product_model.dart'
as productModel;

// Import the Hive model classes from their proper files
import 'package:simple/Offline/Hive_helper/LocalClass/Stock/hive_supplier_adapter.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Stock/hive_product_adapter.dart';

abstract class StockInEvent {}

class StockInLocation extends StockInEvent {}

class StockInSupplier extends StockInEvent {
  String locationId;
  StockInSupplier(this.locationId);
}

class StockInAddProduct extends StockInEvent {
  String locationId;
  StockInAddProduct(this.locationId);
}

class SaveStockIn extends StockInEvent {
  final String orderPayloadJson;
  SaveStockIn(this.orderPayloadJson);
}

class StockInBloc extends Bloc<StockInEvent, dynamic> {
  // Add box instances at class level to avoid multiple openings
  Box<HiveLocation>? _locationBox;
  Box<HiveSupplier>? _suppliersBox;
  Box<HiveProduct>? _productsBox;

  StockInBloc() : super(null) {
    // Add these helper functions at the top of the bloc class
    Future<void> saveLocationToHive(location.Data apiData) async {
      if (apiData == null) return;

      try {
        _locationBox ??= await Hive.openBox<HiveLocation>('location');
        final hiveLocation = HiveLocation(
          id: apiData.id!,
          locationName: apiData.locationName!,
          locationId: apiData.locationId!,
        );
        await _locationBox!.put('current_location', hiveLocation);
        debugPrint("✅ Saved to Hive: ${hiveLocation.locationName}");
      } catch (e) {
        debugPrint("❌ Error saving to Hive: $e");
      }
    }

    Future<HiveLocation?> loadLocationFromHive() async {
      try {
        _locationBox ??= await Hive.openBox<HiveLocation>('location');
        return _locationBox!.get('current_location');
      } catch (e) {
        debugPrint("❌ Error loading from Hive: $e");
        return null;
      }
    }

    Future<void> saveSuppliersToHive(List<supplier.Data> apiData) async {
      try {
        _suppliersBox ??= await Hive.openBox<HiveSupplier>('suppliers_box');
        await _suppliersBox!.clear(); // Clear old data first
        final hiveList = apiData.map((e) => HiveSupplier(id: e.id!, name: e.name!)).toList();
        await _suppliersBox!.addAll(hiveList);
        debugPrint("✅ Saved ${apiData.length} suppliers to Hive.");
      } catch (e) {
        debugPrint("❌ Error saving suppliers to Hive: $e");
      }
    }

    Future<List<HiveSupplier>> loadSuppliersFromHive() async {
      try {
        _suppliersBox ??= await Hive.openBox<HiveSupplier>('suppliers_box');
        return _suppliersBox!.values.toList();
      } catch (e) {
        debugPrint("❌ Error loading suppliers from Hive: $e");
        return [];
      }
    }

    Future<void> saveProductsToHive(List<productModel.Data> apiData) async {
      try {
        _productsBox ??= await Hive.openBox<HiveProduct>('products_box');
        await _productsBox!.clear(); // Clear old data first
        final hiveList = apiData.map((e) => HiveProduct(id: e.id!, name: e.name!)).toList();
        await _productsBox!.addAll(hiveList);
        debugPrint("✅ Saved ${apiData.length} products to Hive.");
      } catch (e) {
        debugPrint("❌ Error saving products to Hive: $e");
      }
    }

    Future<List<HiveProduct>> loadProductsFromHive() async {
      try {
        _productsBox ??= await Hive.openBox<HiveProduct>('products_box');
        return _productsBox!.values.toList();
      } catch (e) {
        debugPrint("❌ Error loading products from Hive: $e");
        return [];
      }
    }

    // Add a method to close boxes when done
    void closeBoxes() {
      _locationBox?.close();
      _suppliersBox?.close();
      _productsBox?.close();
    }

    // 🔹 Location
    on<StockInLocation>((event, emit) async {
      final connectivity = await Connectivity().checkConnectivity();
      bool hasConnection = connectivity != ConnectivityResult.none;

      debugPrint("🔍 StockInLocation - hasConnection: $hasConnection");

      if (hasConnection) {
        // ✅ Online → API
        try {
          final apiResult = await ApiProvider().getLocationAPI();
          if (apiResult.success == true && apiResult.data != null) {
            await saveLocationToHive(apiResult.data!);
          }
          emit(apiResult);
        } catch (error) {
          debugPrint("❌ Location API Error: $error");
          // If API fails, try offline data as fallback
          final hiveLocation = await loadLocationFromHive();
          if (hiveLocation != null) {
            final offlineLocationModel = location.GetLocationModel(
              success: true,
              data: location.Data(
                id: hiveLocation.id,
                locationId: hiveLocation.locationId,
                locationName: hiveLocation.locationName,
              ),
            );
            emit(offlineLocationModel);
          } else {
            emit(location.GetLocationModel(
              success: false,
              data: null,
              errorResponse: ErrorResponse(
                message: "Failed to load location",
                statusCode: 500,
              ),
            ));
          }
        }
      } else {
        // 📱 Offline → Hive
        try {
          final hiveLocation = await loadLocationFromHive();
          debugPrint("🔍 Offline - Loaded from Hive: ${hiveLocation?.locationName}");

          if (hiveLocation != null) {
            final offlineLocationModel = location.GetLocationModel(
              success: true,
              data: location.Data(
                id: hiveLocation.id,
                locationId: hiveLocation.locationId,
                locationName: hiveLocation.locationName,
              ),
            );
            emit(offlineLocationModel);
          } else {
            debugPrint("⚠️ No location found in Hive");
            emit(location.GetLocationModel(
              success: false,
              data: null,
              errorResponse: ErrorResponse(
                message: "No location data available offline",
                statusCode: 404,
              ),
            ));
          }
        } catch (e) {
          debugPrint("❌ Error loading offline location: $e");
          emit(location.GetLocationModel(
            success: false,
            data: null,
            errorResponse: ErrorResponse(
              message: "Error loading offline data",
              statusCode: 500,
            ),
          ));
        }
      }
    });

    // 🔹 Supplier
    on<StockInSupplier>((event, emit) async {
      final connectivity = await Connectivity().checkConnectivity();
      bool hasConnection = connectivity != ConnectivityResult.none;

      debugPrint("🔍 StockInSupplier - hasConnection: $hasConnection, locationId: ${event.locationId}");

      if (hasConnection) {
        try {
          final value = await ApiProvider().getSupplierAPI(event.locationId);
          if (value.success == true) {
            await saveSuppliersToHive(value.data ?? []);
          }
          emit(value);
        } catch (error) {
          debugPrint("❌ Supplier API Error: $error");
          // Fallback to offline data if API fails
          try {
            final hiveSuppliers = await loadSuppliersFromHive();
            debugPrint("🔍 API Failed - Loaded suppliers from Hive: ${hiveSuppliers.length}");

            final offlineSupplierModel = supplier.GetSupplierLocationModel(
              success: hiveSuppliers.isNotEmpty,
              data: hiveSuppliers
                  .map((e) => supplier.Data(id: e.id, name: e.name))
                  .toList(),
            );
            emit(offlineSupplierModel);
          } catch (e) {
            debugPrint("❌ Error loading fallback suppliers: $e");
            emit(supplier.GetSupplierLocationModel(
              success: false,
              data: [],
              errorResponse: ErrorResponse(
                message: "Failed to load suppliers",
                statusCode: 500,
              ),
            ));
          }
        }
      } else {
        try {
          final hiveSuppliers = await loadSuppliersFromHive();
          debugPrint("🔍 Offline - Loaded suppliers: ${hiveSuppliers.length}");

          final offlineSupplierModel = supplier.GetSupplierLocationModel(
            success: hiveSuppliers.isNotEmpty,
            data: hiveSuppliers
                .map((e) => supplier.Data(id: e.id, name: e.name))
                .toList(),
          );
          emit(offlineSupplierModel);
        } catch (e) {
          debugPrint("❌ Error loading offline suppliers: $e");
          emit(supplier.GetSupplierLocationModel(
            success: false,
            data: [],
            errorResponse: ErrorResponse(
              message: "No supplier data available offline",
              statusCode: 404,
            ),
          ));
        }
      }
    });

    // 🔹 Product
    on<StockInAddProduct>((event, emit) async {
      final connectivity = await Connectivity().checkConnectivity();
      bool hasConnection = connectivity != ConnectivityResult.none;

      debugPrint("🔍 StockInAddProduct - hasConnection: $hasConnection, locationId: ${event.locationId}");

      if (hasConnection) {
        try {
          final value = await ApiProvider().getAddProductAPI(event.locationId);
          if (value.success == true) {
            await saveProductsToHive(value.data ?? []);
          }
          emit(value);
        } catch (error) {
          debugPrint("❌ Product API Error: $error");
          // Fallback to offline data if API fails
          try {
            final hiveProducts = await loadProductsFromHive();
            debugPrint("🔍 API Failed - Loaded products from Hive: ${hiveProducts.length}");

            final offlineProductModel = productModel.GetAddProductModel(
              success: hiveProducts.isNotEmpty,
              data: hiveProducts
                  .map((e) => productModel.Data(id: e.id, name: e.name))
                  .toList(),
            );
            emit(offlineProductModel);
          } catch (e) {
            debugPrint("❌ Error loading fallback products: $e");
            emit(productModel.GetAddProductModel(
              success: false,
              data: [],
              errorResponse: ErrorResponse(
                message: "Failed to load products",
                statusCode: 500,
              ),
            ));
          }
        }
      } else {
        try {
          final hiveProducts = await loadProductsFromHive();
          debugPrint("🔍 Offline - Loaded products: ${hiveProducts.length}");

          final offlineProductModel = productModel.GetAddProductModel(
            success: hiveProducts.isNotEmpty,
            data: hiveProducts
                .map((e) => productModel.Data(id: e.id, name: e.name))
                .toList(),
          );
          emit(offlineProductModel);
        } catch (e) {
          debugPrint("❌ Error loading offline products: $e");
          emit(productModel.GetAddProductModel(
            success: false,
            data: [],
            errorResponse: ErrorResponse(
              message: "No product data available offline",
              statusCode: 404,
            ),
          ));
        }
      }
    });

    // 🔹 Save Stock In
    on<SaveStockIn>((event, emit) async {
      final connectivity = await Connectivity().checkConnectivity();
      bool hasConnection = connectivity != ConnectivityResult.none;

      if (hasConnection) {
        try {
          final value = await ApiProvider().postSaveStockInAPI(event.orderPayloadJson);
          emit(value);
        } catch (error) {
          debugPrint("❌ Save Stock API Error: $error");
          emit({
            "success": false,
            "message": "Failed to save stock: $error"
          });
        }
      } else {
        // For offline, you might want to save to a pending queue
        emit({
          "success": false,
          "message": "No internet connection. Stock will be saved when online."
        });
      }
    });
  }

  // @override
  // Future<void> close() {
  //   closeBoxes(); // Close boxes when bloc is closed
  //   return super.close();
  // }
}