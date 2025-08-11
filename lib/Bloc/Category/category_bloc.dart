import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/Bloc/Response/errorResponse.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart'
    as category;
import 'package:simple/Offline/Hive_helper/localStorageHelper/local_storage_helper.dart';

abstract class FoodCategoryEvent {}

class FoodCategory extends FoodCategoryEvent {}

class FoodCategoryOffline extends FoodCategoryEvent {
  final category.GetCategoryModel offlineData;

  FoodCategoryOffline(this.offlineData);
}

class FoodProductItem extends FoodCategoryEvent {
  String catId;
  String searchKey;
  FoodProductItem(this.catId, this.searchKey);
}

class AddToBilling extends FoodCategoryEvent {
  List<Map<String, dynamic>> billingItems;
  bool? isDiscount;
  AddToBilling(this.billingItems, this.isDiscount);
}

class GenerateOrder extends FoodCategoryEvent {
  final String orderPayloadJson;
  GenerateOrder(this.orderPayloadJson);
}

class UpdateOrder extends FoodCategoryEvent {
  final String orderPayloadJson;
  String? orderId;
  UpdateOrder(this.orderPayloadJson, this.orderId);
}

class TableDine extends FoodCategoryEvent {}

class StockDetails extends FoodCategoryEvent {}

class FoodCategoryBloc extends Bloc<FoodCategoryEvent, dynamic> {
  FoodCategoryBloc() : super(dynamic) {
    // on<FoodCategory>((event, emit) async {
    //   await ApiProvider().getCategoryAPI().then((value) {
    //     emit(value);
    //   }).catchError((error) {
    //     emit(error);
    //   });
    // });
    on<FoodCategory>((event, emit) async {
      emit(GetCategoryModel(
          success: false, data: [], errorResponse: null)); // Loading

      final connection = await Connectivity().checkConnectivity();

      if (connection != ConnectivityResult.none) {
        // Online: fetch from API, save to Hive, then emit
        try {
          final value = await ApiProvider().getCategoryAPI();

          if (value.success == true && value.data != null) {
            await saveCategoriesToHive(value.data!); // Save to Hive
          }

          emit(value);
        } catch (error) {
          emit(GetCategoryModel(
            success: false,
            data: [],
            errorResponse:
                ErrorResponse(message: error.toString(), statusCode: 500),
          ));
        }
      } else {
        // Offline: load from Hive and emit
        final localData = await loadCategoriesFromHive();
        print('Offline data count: ${localData.length}');
        for (var d in localData) {
          print('Category: id=${d.id}, name=${d.name}, image=${d.image}');
        }
        emit(GetCategoryModel(
          success: true,
          data: localData
              .map((cat) => category.Data(
                    id: cat.id,
                    name: cat.name,
                    image: cat.image,
                  ))
              .toList(),
          errorResponse: null,
        ));
      }
    });
    on<FoodCategoryOffline>((event, emit) async {
      emit(event.offlineData);
    });
    on<FoodProductItem>((event, emit) async {
      await ApiProvider()
          .getProductItemAPI(event.catId, event.searchKey)
          .then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<AddToBilling>((event, emit) async {
      await ApiProvider()
          .postAddToBillingAPI(event.billingItems, event.isDiscount)
          .then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<GenerateOrder>((event, emit) async {
      await ApiProvider()
          .postGenerateOrderAPI(event.orderPayloadJson)
          .then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<UpdateOrder>((event, emit) async {
      await ApiProvider()
          .updateGenerateOrderAPI(event.orderPayloadJson, event.orderId)
          .then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<TableDine>((event, emit) async {
      await ApiProvider().getTableAPI().then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<StockDetails>((event, emit) async {
      await ApiProvider().getStockDetailsAPI().then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
  }
}

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:simple/Api/apiProvider.dart';
// import 'package:simple/Offline/Network_status/NetworkStatusService.dart';
// import 'package:simple/Offline/Offline_Service_API/Offline_API_Service.dart';
//
// abstract class FoodCategoryEvent {}
//
// class FoodCategory extends FoodCategoryEvent {
//   final bool forceRefresh;
//   FoodCategory({this.forceRefresh = false});
// }
//
// class FoodCategoryOffline extends FoodCategoryEvent {}
//
// class FoodProductItem extends FoodCategoryEvent {
//   String catId;
//   String searchKey;
//   final bool forceRefresh;
//   FoodProductItem(this.catId, this.searchKey, {this.forceRefresh = false});
// }
//
// class FoodProductItemOffline extends FoodCategoryEvent {
//   String catId;
//   String searchKey;
//   FoodProductItemOffline(this.catId, this.searchKey);
// }
//
// class AddToBilling extends FoodCategoryEvent {
//   List<Map<String, dynamic>> billingItems;
//   bool? isDiscount;
//   AddToBilling(this.billingItems, this.isDiscount);
// }
//
// class GenerateOrder extends FoodCategoryEvent {
//   final String orderPayloadJson;
//   GenerateOrder(this.orderPayloadJson);
// }
//
// class UpdateOrder extends FoodCategoryEvent {
//   final String orderPayloadJson;
//   String? orderId;
//   UpdateOrder(this.orderPayloadJson, this.orderId);
// }
//
// class TableDine extends FoodCategoryEvent {
//   final bool forceRefresh;
//   TableDine({this.forceRefresh = false});
// }
//
// class TableDineOffline extends FoodCategoryEvent {}
//
// class StockDetails extends FoodCategoryEvent {}
//
// class FoodCategoryBloc extends Bloc<FoodCategoryEvent, dynamic> {
//   final OfflineSyncService _syncService = OfflineSyncService();
//   final NetworkManager _networkManager = NetworkManager();
//
//   FoodCategoryBloc() : super(null) {
//     on<FoodCategory>(_onFoodCategory);
//     on<FoodCategoryOffline>(_onFoodCategoryOffline);
//     on<FoodProductItem>(_onFoodProductItem);
//     on<FoodProductItemOffline>(_onFoodProductItemOffline);
//     on<TableDine>(_onTableDine);
//     on<TableDineOffline>(_onTableDineOffline);
//
//     // Keep your existing handlers EXACTLY as they were
//     on<AddToBilling>((event, emit) async {
//       await ApiProvider()
//           .postAddToBillingAPI(event.billingItems, event.isDiscount)
//           .then((value) {
//         emit(value);
//       }).catchError((error) {
//         emit(error);
//       });
//     });
//
//     on<GenerateOrder>((event, emit) async {
//       await ApiProvider()
//           .postGenerateOrderAPI(event.orderPayloadJson)
//           .then((value) {
//         emit(value);
//       }).catchError((error) {
//         emit(error);
//       });
//     });
//
//     on<UpdateOrder>((event, emit) async {
//       await ApiProvider()
//           .updateGenerateOrderAPI(event.orderPayloadJson, event.orderId)
//           .then((value) {
//         emit(value);
//       }).catchError((error) {
//         emit(error);
//       });
//     });
//
//     on<StockDetails>((event, emit) async {
//       await ApiProvider().getStockDetailsAPI().then((value) {
//         emit(value);
//       }).catchError((error) {
//         emit(error);
//       });
//     });
//   }
//
//   Future<void> _onFoodCategory(
//       FoodCategory event, Emitter<dynamic> emit) async {
//     try {
//       if (_networkManager.isOnline || event.forceRefresh) {
//         // Get from API
//         final apiResponse = await ApiProvider().getCategoryAPI();
//
//         // Extract the list from the response and cache it
//         if (apiResponse != null) {
//           List<dynamic> categoriesList = _extractListFromResponse(apiResponse);
//
//           // Cache the extracted list
//           if (categoriesList.isNotEmpty) {
//             await _syncService.cacheCategories(categoriesList);
//           }
//         }
//
//         // Emit the original API response to maintain compatibility
//         emit(apiResponse);
//       } else {
//         // Load from cache when offline
//         final cachedCategories = await _syncService.getCachedCategories();
//
//         // Convert cached data back to your model format if needed
//         if (cachedCategories.isNotEmpty) {
//           emit(cachedCategories); // or create GetCategoryModel from cached data
//         } else {
//           emit(null);
//         }
//       }
//     } catch (error) {
//       // If API fails, try to load from cache
//       final cachedCategories = await _syncService.getCachedCategories();
//       if (cachedCategories.isNotEmpty) {
//         emit(cachedCategories);
//       } else {
//         emit(error);
//       }
//     }
//   }
//
//   Future<void> _onFoodCategoryOffline(
//       FoodCategoryOffline event, Emitter<dynamic> emit) async {
//     try {
//       final cachedCategories = await _syncService.getCachedCategories();
//       emit(cachedCategories);
//     } catch (error) {
//       emit(error);
//     }
//   }
//
//   Future<void> _onFoodProductItem(
//       FoodProductItem event, Emitter<dynamic> emit) async {
//     try {
//       if (_networkManager.isOnline || event.forceRefresh) {
//         // Get from API
//         final apiResponse =
//             await ApiProvider().getProductItemAPI(event.catId, event.searchKey);
//
//         // Extract the list from the response and cache it
//         if (apiResponse != null) {
//           List<dynamic> productsList = _extractListFromResponse(apiResponse);
//
//           // Cache the extracted list
//           if (productsList.isNotEmpty) {
//             await _syncService.cacheProducts(productsList,
//                 categoryId: event.catId);
//           }
//         }
//
//         // Emit the original API response to maintain compatibility
//         emit(apiResponse);
//       } else {
//         // Load from cache when offline
//         final cachedProducts =
//             await _syncService.getCachedProducts(event.catId);
//
//         // Filter by search key if provided
//         List<Map<String, dynamic>> filteredProducts = cachedProducts;
//         if (event.searchKey.isNotEmpty) {
//           filteredProducts = cachedProducts.where((product) {
//             final name = product['name']?.toString().toLowerCase() ?? '';
//             return name.contains(event.searchKey.toLowerCase());
//           }).toList();
//         }
//
//         emit(filteredProducts);
//       }
//     } catch (error) {
//       // If API fails, try to load from cache
//       final cachedProducts = await _syncService.getCachedProducts(event.catId);
//
//       if (cachedProducts.isNotEmpty) {
//         // Filter by search key if provided
//         List<Map<String, dynamic>> filteredProducts = cachedProducts;
//         if (event.searchKey.isNotEmpty) {
//           filteredProducts = cachedProducts.where((product) {
//             final name = product['name']?.toString().toLowerCase() ?? '';
//             return name.contains(event.searchKey.toLowerCase());
//           }).toList();
//         }
//         emit(filteredProducts);
//       } else {
//         emit(error);
//       }
//     }
//   }
//
//   Future<void> _onFoodProductItemOffline(
//       FoodProductItemOffline event, Emitter<dynamic> emit) async {
//     try {
//       final cachedProducts = await _syncService.getCachedProducts(event.catId);
//
//       // Filter by search key if provided
//       List<Map<String, dynamic>> filteredProducts = cachedProducts;
//       if (event.searchKey.isNotEmpty) {
//         filteredProducts = cachedProducts.where((product) {
//           final name = product['name']?.toString().toLowerCase() ?? '';
//           return name.contains(event.searchKey.toLowerCase());
//         }).toList();
//       }
//
//       emit(filteredProducts);
//     } catch (error) {
//       emit(error);
//     }
//   }
//
//   Future<void> _onTableDine(TableDine event, Emitter<dynamic> emit) async {
//     try {
//       if (_networkManager.isOnline || event.forceRefresh) {
//         // Get from API
//         final apiResponse = await ApiProvider().getTableAPI();
//
//         // Extract the list from the response and cache it
//         if (apiResponse != null) {
//           List<dynamic> tablesList = _extractListFromResponse(apiResponse);
//
//           // Cache the extracted list
//           if (tablesList.isNotEmpty) {
//             await _syncService.cacheTables(tablesList);
//           }
//         }
//
//         // Emit the original API response to maintain compatibility
//         emit(apiResponse);
//       } else {
//         // Load from cache when offline
//         final cachedTables = await _syncService.getCachedTables();
//         emit(cachedTables);
//       }
//     } catch (error) {
//       // If API fails, try to load from cache
//       final cachedTables = await _syncService.getCachedTables();
//       if (cachedTables.isNotEmpty) {
//         emit(cachedTables);
//       } else {
//         emit(error);
//       }
//     }
//   }
//
//   Future<void> _onTableDineOffline(
//       TableDineOffline event, Emitter<dynamic> emit) async {
//     try {
//       final cachedTables = await _syncService.getCachedTables();
//       emit(cachedTables);
//     } catch (error) {
//       emit(error);
//     }
//   }
//
//   // Helper method to extract list from any response type
//   List<dynamic> _extractListFromResponse(dynamic response) {
//     if (response == null) return [];
//
//     // If it's already a List, return it
//     if (response is List) {
//       return response;
//     }
//
//     // If it's a Map (JSON object), look for common list properties
//     if (response is Map<String, dynamic>) {
//       // Check common property names
//       if (response['data'] != null && response['data'] is List) {
//         return response['data'];
//       }
//       if (response['items'] != null && response['items'] is List) {
//         return response['items'];
//       }
//       if (response['result'] != null && response['result'] is List) {
//         return response['result'];
//       }
//       if (response['categories'] != null && response['categories'] is List) {
//         return response['categories'];
//       }
//       if (response['products'] != null && response['products'] is List) {
//         return response['products'];
//       }
//       if (response['tables'] != null && response['tables'] is List) {
//         return response['tables'];
//       }
//
//       // If no list property found, wrap the object itself in a list
//       return [response];
//     }
//
//     // If it's a custom object, try to convert to JSON first
//     try {
//       if (response.runtimeType.toString().contains('Model')) {
//         // Try to call toJson if it exists
//         final Map<String, dynamic> jsonResponse = response.toJson();
//         return _extractListFromResponse(jsonResponse); // Recursive call
//       }
//     } catch (e) {
//       // If toJson fails, just wrap in list
//       return [response];
//     }
//
//     // Fallback: wrap in list
//     return [response];
//   }
// }
