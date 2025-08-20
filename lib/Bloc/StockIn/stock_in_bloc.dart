import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/ModelClass/StockIn/getLocationModel.dart' as location;
import 'package:simple/ModelClass/StockIn/getSupplierLocationModel.dart'
    as supplier;
import 'package:simple/Offline/Hive_helper/LocalClass/Stock/hive_location_model.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/Stock/hive_stock_service.dart';
import 'package:simple/ModelClass/StockIn/get_add_product_model.dart'
    as productModel;

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
  StockInBloc() : super(null) {
    // 🔹 Location
    on<StockInLocation>((event, emit) async {
      final connectivity = await Connectivity().checkConnectivity();
      bool hasConnection = connectivity != ConnectivityResult.none;

      debugPrint("🔍 StockInLocation - hasConnection: $hasConnection");

      if (hasConnection) {
        // ✅ Online → API
        await ApiProvider().getLocationAPI().then((value) async {
          if (value.success == true && value.data != null) {
            await saveLocationToHive(value.data!);
          }
          emit(value);
        }).catchError((error) {
          debugPrint("❌ Location API Error: $error");
          emit(error);
        });
      } else {
        // 📱 Offline → Hive
        try {
          final hiveLocation = await loadLocationFromHive();
          debugPrint(
              "🔍 Offline - Loaded from Hive: ${hiveLocation?.locationName}");

          final offlineLocationModel = location.GetLocationModel(
            success: hiveLocation != null,
            data: hiveLocation != null
                ? location.Data(
                    id: hiveLocation.id,
                    locationId: hiveLocation.locationId,
                    locationName: hiveLocation.locationName,
                  )
                : null,
          );

          emit(offlineLocationModel);
        } catch (e) {
          debugPrint("❌ Error loading offline location: $e");
          emit(location.GetLocationModel(success: false, data: null));
        }
      }
    });

// 5. Fix supplier and product bloc events
    on<StockInSupplier>((event, emit) async {
      final connectivity = await Connectivity().checkConnectivity();
      bool hasConnection = connectivity != ConnectivityResult.none;

      debugPrint(
          "🔍 StockInSupplier - hasConnection: $hasConnection, locationId: ${event.locationId}");

      if (hasConnection) {
        await ApiProvider()
            .getSupplierAPI(event.locationId)
            .then((value) async {
          if (value.success == true) {
            await saveSuppliersToHive(value.data ?? []);
          }
          emit(value);
        }).catchError((error) {
          debugPrint("❌ Supplier API Error: $error");
          emit(error);
        });
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
          emit(supplier.GetSupplierLocationModel(success: false, data: []));
        }
      }
    });

    on<StockInAddProduct>((event, emit) async {
      final connectivity = await Connectivity().checkConnectivity();
      bool hasConnection = connectivity != ConnectivityResult.none;

      debugPrint(
          "🔍 StockInAddProduct - hasConnection: $hasConnection, locationId: ${event.locationId}");

      if (hasConnection) {
        await ApiProvider()
            .getAddProductAPI(event.locationId)
            .then((value) async {
          if (value.success == true) {
            await saveProductsToHive(value.data ?? []);
          }
          emit(value);
        }).catchError((error) {
          debugPrint("❌ Product API Error: $error");
          emit(error);
        });
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
          emit(productModel.GetAddProductModel(success: false, data: []));
        }
      }
    });

    // 🔹 Save Stock In
    on<SaveStockIn>((event, emit) async {
      final connectivity = await Connectivity().checkConnectivity();
      bool hasConnection = connectivity != ConnectivityResult.none;

      if (hasConnection) {
        await ApiProvider()
            .postSaveStockInAPI(event.orderPayloadJson)
            .then((value) {
          emit(value);
        }).catchError((error) {
          emit(error);
        });
      } else {
        // FIXED: Create a proper offline response model
        emit({
          "success": false,
          "message": "No internet connection. Stock will be saved when online."
        });
      }
    });
  }
}
