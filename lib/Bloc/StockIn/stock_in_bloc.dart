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

      if (hasConnection) {
        // ✅ Online → API
        await ApiProvider().getLocationAPI().then((value) async {
          if (value.success == true) {
            if (value.data != null) {
              // Pass Data object directly - saveLocationToHive handles the conversion
              await saveLocationToHive(value.data!);
            }
          }
          emit(value);
        }).catchError((error) {
          emit(error);
        });
      } else {
        // ✅ Offline → Hive
        // final hiveLocation = await loadLocationFromHive();
        // final offlineLocationModel = location.GetLocationModel(
        //   success: hiveLocation != null,
        //   data: hiveLocation != null
        //       ? location.Data(
        //           id: hiveLocation.id,
        //           locationId: hiveLocation.locationId,
        //           locationName: hiveLocation.locationName,
        //         )
        //       : null,
        // );
        // emit(offlineLocationModel);
        final hiveLocation = await loadLocationFromHive();
        debugPrint("🔍 Offline - Loaded from Hive: $hiveLocation");
        debugPrint("🔍 Offline - HiveLocation id: ${hiveLocation?.id}");
        debugPrint(
            "🔍 Offline - HiveLocation locationId: ${hiveLocation?.locationId}");
        debugPrint(
            "🔍 Offline - HiveLocation locationName: ${hiveLocation?.locationName}");

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

        debugPrint(
            "🔍 Offline - Created Data object: ${offlineLocationModel.data}");
        debugPrint(
            "🔍 Offline - Data locationName: ${offlineLocationModel.data?.locationName}");
        emit(offlineLocationModel);
      }
    });
    // 🔹 Supplier
    on<StockInSupplier>((event, emit) async {
      final connectivity = await Connectivity().checkConnectivity();
      bool hasConnection = connectivity != ConnectivityResult.none;

      if (hasConnection) {
        await ApiProvider()
            .getSupplierAPI(event.locationId)
            .then((value) async {
          if (value.success == true) {
            await saveSuppliersToHive(value.data ?? []);
          }
          emit(value);
        }).catchError((error) {
          emit(error);
        });
      } else {
        final hiveSuppliers = await loadSuppliersFromHive();
        final offlineSupplierModel = supplier.GetSupplierLocationModel(
          success: hiveSuppliers.isNotEmpty,
          data: hiveSuppliers
              .map((e) => supplier.Data(id: e.id, name: e.name))
              .toList(),
        );
        emit(offlineSupplierModel); // FIXED: Emit the offline model
      }
    });

    // 🔹 Add Product
    on<StockInAddProduct>((event, emit) async {
      final connectivity = await Connectivity().checkConnectivity();
      bool hasConnection = connectivity != ConnectivityResult.none;

      if (hasConnection) {
        await ApiProvider()
            .getAddProductAPI(event.locationId)
            .then((value) async {
          if (value.success == true) {
            await saveProductsToHive(value.data ?? []);
          }
          emit(value);
        }).catchError((error) {
          emit(error);
        });
      } else {
        final hiveProducts = await loadProductsFromHive();
        final offlineProductModel = productModel.GetAddProductModel(
          success: hiveProducts.isNotEmpty,
          data: hiveProducts
              .map((e) => productModel.Data(id: e.id, name: e.name))
              .toList(),
        );
        emit(offlineProductModel); // FIXED: Emit the offline model
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
