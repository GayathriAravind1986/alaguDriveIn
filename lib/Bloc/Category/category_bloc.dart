import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/Bloc/Response/errorResponse.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart'
    as category;
import 'package:simple/UI/Home_screen/home_screen.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart'
    as product;
import 'package:simple/ModelClass/Cart/Post_Add_to_billing_model.dart'
    as billing;
import 'package:simple/ModelClass/Order/Post_generate_order_model.dart'
    as generate;
import 'package:simple/ModelClass/Order/Update_generate_order_model.dart'
    as update;
import 'package:simple/ModelClass/ShopDetails/getStockMaintanencesModel.dart';
import 'package:simple/ModelClass/Table/Get_table_model.dart';
import 'package:simple/ModelClass/Waiter/getWaiterModel.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service_table_stock.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_waiter_service.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/local_storage_helper.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/local_storage_product.dart';
import 'package:simple/UI/Home_screen/home_screen.dart';

import '../../ModelClass/Order/Post_generate_order_model.dart';

// Add this helper method at the top of your CategoryBloc class, before any other methods
double _safeToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  if (value is num) return value.toDouble();
  return 0.0;
}

abstract class FoodCategoryEvent {}

class FoodCategory extends FoodCategoryEvent {}

class FoodCategoryOffline extends FoodCategoryEvent {
  final category.GetCategoryModel offlineData;

  FoodCategoryOffline(this.offlineData);
}

class FoodProductItem extends FoodCategoryEvent {
  String catId;
  String searchKey;
  String searchCode;
  FoodProductItem(this.catId, this.searchKey, this.searchCode);
}

class FoodProductItemOffline extends FoodCategoryEvent {
  final product.GetProductByCatIdModel offlineData;
  FoodProductItemOffline(this.offlineData);
}

class AddToBilling extends FoodCategoryEvent {
  List<Map<String, dynamic>> billingItems;
  bool? isDiscount;
  final OrderType? orderType;
  AddToBilling(this.billingItems, this.isDiscount, this.orderType);
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

class WaiterDine extends FoodCategoryEvent {}

class StockDetails extends FoodCategoryEvent {}

class SyncPendingOrders extends FoodCategoryEvent {}

class LoadOfflineCart extends FoodCategoryEvent {}

// Add new states
class SyncCompleteState {
  final bool success;
  final String? error;

  SyncCompleteState({required this.success, this.error});
}

class FoodCategoryBloc extends Bloc<FoodCategoryEvent, dynamic> {
  FoodCategoryBloc() : super(null) {
    on<FoodCategory>((event, emit) async {
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        bool hasConnection = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        if (hasConnection) {
          // FIXED: Don't emit loading state if we already have local data
          final localData = await loadCategoriesFromHive();

          // Emit local data first if available (for immediate UI update)
          if (localData.isNotEmpty) {
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
          } else {
            // Only show loading if no local data
            emit(GetCategoryModel(
                success: false, data: [], errorResponse: null));
          }

          try {
            final value = await ApiProvider().getCategoryAPI();

            if (value.success == true && value.data != null) {
              // FIXED: Check if data actually changed before saving/emitting
              final currentData = localData.map((cat) => cat.id).toSet();
              final newData = value.data!.map((cat) => cat.id).toSet();

              if (!setEquals(currentData, newData)) {
                // Save categories to Hive only if data changed
                await saveCategoriesToHive(value.data!);
              }
            }

            // Always emit the latest API response
            emit(value);
          } catch (error) {
            debugPrint('API error, keeping local data: $error');
            // Don't emit error if we already have local data displayed
            if (localData.isEmpty) {
              emit(GetCategoryModel(
                success: false,
                data: [],
                errorResponse:
                    ErrorResponse(message: error.toString(), statusCode: 500),
              ));
            }
          }
        } else {
          // Offline: load from Hive directly
          final localData = await loadCategoriesFromHive();
          debugPrint('Offline data count: ${localData.length}');

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
      } catch (e) {
        debugPrint('Error in FoodCategory event: $e');
        // Fallback logic remains the same
        final localData = await loadCategoriesFromHive();
        if (localData.isNotEmpty) {
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
      }
    });
    on<FoodCategoryOffline>((event, emit) async {
      emit(event.offlineData);
    });

    on<FoodProductItem>((event, emit) async {
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        final hasConnection = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        if (hasConnection) {
          final value = await ApiProvider().getProductItemAPI(
              event.catId, event.searchKey, event.searchCode);

          if (value.success == true && value.rows != null) {
            await saveProductsToHive(event.catId, value.rows!);
          }
          emit(value);
        } else {
          final localProducts = await loadProductsFromHive(event.catId);
          final offlineProducts = localProducts
              .map((p) => product.Rows(
                    id: p.id,
                    name: p.name,
                    image: p.image,
                    basePrice: p.basePrice,
                    availableQuantity: p.availableQuantity,
                    isStock: p.isStock ?? false,
                    addons: p.addons
                            ?.map((a) => product.Addons(
                                  id: a.id,
                                  name: a.name,
                                  price: a.price,
                                  isFree: a.isFree,
                                  maxQuantity: a.maxQuantity,
                                  isAvailable: a.isAvailable,
                                  quantity: 0,
                                  isSelected: false,
                                ))
                            .toList() ??
                        [],
                    counter: 0,
                  ))
              .toList();

          emit(product.GetProductByCatIdModel(
            success: true,
            rows: offlineProducts,
            stockMaintenance: true,
            errorResponse: null,
          ));
        }
      } catch (e) {
        emit(product.GetProductByCatIdModel(
          success: false,
          rows: [],
          stockMaintenance: false,
          errorResponse: ErrorResponse(message: e.toString(), statusCode: 500),
        ));
      }
    });

    on<AddToBilling>((event, emit) async {
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        bool hasConnection = false;

        hasConnection = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        if (hasConnection) {
          // Online: Try API first
          try {
            final value = await ApiProvider().postAddToBillingAPI(
              event.billingItems,
              event.isDiscount,
              event.orderType?.apiValue,
            );

            // Save to Hive for offline access
            await HiveService.saveCartItems(event.billingItems);

            final billingSession = HiveService.calculateBillingTotals(
                event.billingItems, event.isDiscount ?? false);
            await HiveService.saveBillingSession(billingSession);
            await HiveService.saveLastOnlineTimestamp();

            emit(value);
          } catch (error) {
            // API failed, fall back to offline calculation
            await _handleOfflineBilling(event, emit);
          }
        } else {
          // Offline: Use Hive
          await _handleOfflineBilling(event, emit);
        }
      } catch (e) {
        // Connectivity check failed, try offline
        await _handleOfflineBilling(event, emit);
      }
    });

    on<GenerateOrder>((event, emit) async {
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        bool hasConnection = false;

        hasConnection = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        if (hasConnection) {
          // Online: Try API
          try {
            final value = await ApiProvider()
                .postGenerateOrderAPI(event.orderPayloadJson);

            // Clear cart after successful order
            await HiveService.clearCart();
            await HiveService.clearBillingSession();
            await HiveService.saveLastOnlineTimestamp();

            emit(value);
          } catch (error) {
            // API failed, save for later sync
            await _handleOfflineOrderCreation(event, emit);
          }
        } else {
          // Offline: Save for later sync
          await _handleOfflineOrderCreation(event, emit);
        }
      } catch (e) {
        await _handleOfflineOrderCreation(event, emit);
      }
    });

    on<UpdateOrder>((event, emit) async {
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        bool hasConnection = false;

        hasConnection = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        if (hasConnection) {
          // Online: Try API
          try {
            final value = await ApiProvider()
                .updateGenerateOrderAPI(event.orderPayloadJson, event.orderId);

            await HiveService.clearCart();
            await HiveService.clearBillingSession();
            await HiveService.saveLastOnlineTimestamp();

            emit(value);
          } catch (error) {
            // API failed, save for later sync
            await _handleOfflineOrderUpdate(event, emit);
          }
        } else {
          // Offline: Save for later sync
          await _handleOfflineOrderUpdate(event, emit);
        }
      } catch (e) {
        await _handleOfflineOrderUpdate(event, emit);
      }
    });

    // Add sync event
    on<SyncPendingOrders>((event, emit) async {
      try {
        await HiveService.syncPendingOrders(ApiProvider());
        emit(SyncCompleteState(success: true));
      } catch (e) {
        emit(SyncCompleteState(success: false, error: e.toString()));
      }
    });

    on<TableDine>((event, emit) async {
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        bool hasConnection = false;

        hasConnection = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        if (hasConnection) {
          // Online: Try to fetch from API first
          try {
            final value = await ApiProvider().getTableAPI();

            if (value.success == true && value.data != null) {
              // Save tables to Hive for offline use
              await HiveStockTableService.saveTables(value.data!);
            }

            emit(value);
          } catch (error) {
            // API failed, try to load from Hive as fallback
            final offlineTables =
                await HiveStockTableService.getTablesAsApiFormat();
            if (offlineTables.isNotEmpty) {
              // Create offline response matching your API model structure
              final offlineResponse = GetTableModel(
                // Replace with your actual table model
                success: true,
                data: offlineTables,
                errorResponse: null,
              );
              emit(offlineResponse);
            } else {
              emit(GetTableModel(
                success: false,
                errorResponse: ErrorResponse(
                  message: error.toString(),
                  statusCode: 500,
                ),
              ));
            }
          }
        } else {
          // Offline: Load from Hive directly
          final offlineTables =
              await HiveStockTableService.getTablesAsApiFormat();
          if (offlineTables.isNotEmpty) {
            debugPrint(
                'Loading ${offlineTables.length} tables from offline storage');
            final offlineResponse = GetTableModel(
              success: true,
              data: offlineTables,
              errorResponse: null,
            );
            emit(offlineResponse);
          } else {
            // No offline data available
            emit(GetTableModel(
              success: false,
              data: [],
              errorResponse: ErrorResponse(
                message: 'No offline table data available',
                statusCode: 503,
              ),
            ));
          }
        }
      } catch (e) {
        debugPrint('Error in TableDine event: $e');
        // Fallback to offline data
        final offlineTables =
            await HiveStockTableService.getTablesAsApiFormat();
        if (offlineTables.isNotEmpty) {
          final offlineResponse = GetTableModel(
            success: true,
            data: offlineTables,
            errorResponse: null,
          );
          emit(offlineResponse);
        } else {
          emit(GetTableModel(
            success: false,
            data: [],
            errorResponse: ErrorResponse(
              message: e.toString(),
              statusCode: 500,
            ),
          ));
        }
      }
    });
    on<WaiterDine>((event, emit) async {
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        bool hasConnection = connectivityResult != ConnectivityResult.none;

        debugPrint('🌐 Connectivity: $hasConnection');

        if (hasConnection) {
          // Online: Try API first
          try {
            debugPrint('📡 Fetching waiters from API...');
            final value = await ApiProvider().getWaiterAPI();
            debugPrint(
                '✅ API response - success: ${value.success}, data count: ${value.data?.length ?? 0}');

            if (value.success == true && value.data != null) {
              debugPrint('💾 Saving ${value.data!.length} waiters to Hive...');
              await HiveWaiterService.saveWaiters(value.data!);
              debugPrint('✅ Waiters saved to Hive successfully');
            }

            emit(value);
          } catch (error) {
            debugPrint('❌ API failed: $error');
            // API failed, load from Hive
            final offlineWaiters =
                await HiveWaiterService.getWaitersAsApiFormat();
            debugPrint('📂 Offline waiters found: ${offlineWaiters.length}');

            if (offlineWaiters.isNotEmpty) {
              debugPrint('🔄 Loading from offline storage');
              final offlineResponse = GetWaiterModel(
                success: true,
                data: offlineWaiters,
                totalCount: offlineWaiters.length,
                errorResponse: null, // ← ADD THIS to match table pattern
              );
              emit(offlineResponse);
            } else {
              debugPrint('❌ No offline data available');
              emit(GetWaiterModel(
                success: false,
                data: [], // ← Make sure this is empty array, not null
                totalCount: 0,
                errorResponse: ErrorResponse(
                  // ← ADD errorResponse like table
                  message: error.toString(),
                  statusCode: 500,
                ),
              ));
            }
          }
        } else {
          // Offline: Load from Hive directly
          debugPrint('📶 Offline mode - loading from Hive');
          final offlineWaiters =
              await HiveWaiterService.getWaitersAsApiFormat();
          debugPrint('📂 Offline waiters found: ${offlineWaiters.length}');

          if (offlineWaiters.isNotEmpty) {
            debugPrint(
                '✅ Loading ${offlineWaiters.length} waiters from offline storage');
            final offlineResponse = GetWaiterModel(
              success: true,
              data: offlineWaiters,
              totalCount: offlineWaiters.length,
              errorResponse: null, // ← ADD THIS
            );
            emit(offlineResponse);
          } else {
            debugPrint('❌ No offline waiter data available');
            emit(GetWaiterModel(
              success: false,
              data: [], // ← Empty array, not null
              totalCount: 0,
              errorResponse: ErrorResponse(
                // ← ADD errorResponse like table
                message: 'No offline waiter data available',
                statusCode: 503,
              ),
            ));
          }
        }
      } catch (e) {
        debugPrint('💥 Error in WaiterDine event: $e');
        final offlineWaiters = await HiveWaiterService.getWaitersAsApiFormat();
        debugPrint('📂 Fallback offline waiters: ${offlineWaiters.length}');

        if (offlineWaiters.isNotEmpty) {
          final offlineResponse = GetWaiterModel(
            success: true,
            data: offlineWaiters,
            totalCount: offlineWaiters.length,
            errorResponse: null, // ← ADD THIS
          );
          emit(offlineResponse);
        } else {
          emit(GetWaiterModel(
            success: false,
            data: [], // ← Empty array, not null
            totalCount: 0,
            errorResponse: ErrorResponse(
              // ← ADD errorResponse like table
              message: e.toString(),
              statusCode: 500,
            ),
          ));
        }
      }
    });
    on<StockDetails>((event, emit) async {
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        bool hasConnection = false;

        hasConnection = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        if (hasConnection) {
          // Online: Try to fetch from API first
          try {
            final value = await ApiProvider().getStockDetailsAPI();

            if (value.success == true) {
              // Save to Hive for offline use
              await HiveStockTableService.saveStockMaintenance(value);
            }

            emit(value);
          } catch (error) {
            // API failed, try to load from Hive as fallback
            final offlineStock =
                await HiveStockTableService.getStockMaintenanceAsApiModel();
            if (offlineStock != null) {
              emit(offlineStock);
            } else {
              emit(GetStockMaintanencesModel(
                success: false,
                errorResponse: ErrorResponse(
                  message: error.toString(),
                  statusCode: 500,
                ),
              ));
            }
          }
        } else {
          // Offline: Load from Hive directly
          final offlineStock =
              await HiveStockTableService.getStockMaintenanceAsApiModel();
          if (offlineStock != null) {
            debugPrint('Loading stock maintenance from offline storage');
            emit(offlineStock);
          } else {
            // No offline data available
            emit(GetStockMaintanencesModel(
              success: false,
              errorResponse: ErrorResponse(
                message: 'No offline stock data available',
                statusCode: 503,
              ),
            ));
          }
        }
      } catch (e) {
        debugPrint('Error in StockDetails event: $e');
        // Fallback to offline data
        final offlineStock =
            await HiveStockTableService.getStockMaintenanceAsApiModel();
        if (offlineStock != null) {
          emit(offlineStock);
        } else {
          emit(GetStockMaintanencesModel(
            success: false,
            errorResponse: ErrorResponse(
              message: e.toString(),
              statusCode: 500,
            ),
          ));
        }
      }
    });
  }

  bool setEquals<T>(Set<T> set1, Set<T> set2) {
    return set1.length == set2.length && set1.containsAll(set2);
  }

  Future<void> _handleOfflineBilling(AddToBilling event, Emitter emit) async {
    try {
      // Calculate totals offline
      final billingSession = HiveService.calculateBillingTotals(
          event.billingItems, event.isDiscount ?? false);

      // Save to Hive
      await HiveService.saveCartItems(event.billingItems);
      await HiveService.saveBillingSession(billingSession);

      // Create offline response model
      final offlineResponse = billing.PostAddToBillingModel(
        // success: true,
        subtotal: double.parse(billingSession.subtotal!.toStringAsFixed(2)),
        totalTax: double.parse(billingSession.totalTax!.toStringAsFixed(2)),
        total: double.parse(billingSession.total!.toStringAsFixed(2)),
        totalDiscount: billingSession.totalDiscount,
        items: billingSession.items?.map((hiveItem) {
          // Convert selectedAddons from Map to proper objects
          List<billing.SelectedAddons>? convertedAddons;
          if (hiveItem.selectedAddons != null &&
              hiveItem.selectedAddons!.isNotEmpty) {
            convertedAddons = hiveItem.selectedAddons!
                .map((addon) => billing.SelectedAddons(
                      id: addon['id']?.toString(),
                      name: addon['name']?.toString(),
                      price: (addon['price'] ?? 0.0).toDouble(),
                      quantity: addon['quantity'] ?? 0,
                      isAvailable: addon['isAvailable'] ?? true,
                      isFree: addon['isFree'] ?? false,
                    ))
                .toList();
          }

          // Calculate addon total
          double addonTotal = 0.0;
          if (hiveItem.selectedAddons != null) {
            for (var addon in hiveItem.selectedAddons!) {
              if (!(addon['isFree'] ?? false)) {
                double addonPrice = (addon['price'] ?? 0.0).toDouble();
                int addonQty = addon['quantity'] ?? 0;
                addonTotal += (addonPrice * addonQty);
              }
            }
          }

          return billing.Items(
            id: hiveItem.product,
            // Use product as ID
            name: hiveItem.name,
            image: hiveItem.image,
            basePrice: hiveItem.basePrice ?? hiveItem.unitPrice,
            qty: hiveItem.quantity,
            availableQuantity: hiveItem.quantity,
            // Use same as qty for offline
            selectedAddons: convertedAddons,
            addonTotal: addonTotal,
          );
        }).toList(),
        errorResponse: null,
      );

      emit(offlineResponse);
    } catch (e, stackTrace) {
      print("❌ Error in _handleOfflineBilling: $e");
      print("❌ Stack trace: $stackTrace");

      emit(billing.PostAddToBillingModel(
        // success: false,
        errorResponse: ErrorResponse(
          message: 'Offline billing calculation failed: $e',
          statusCode: 500,
        ),
      ));
    }
  }

  Future<void> _handleOfflineOrderCreation(
      GenerateOrder event, Emitter emit) async {
    try {
      // Parse order payload to extract details
      final orderData = jsonDecode(event.orderPayloadJson);
      final billingSession = await HiveService.getBillingSession();

      if (billingSession == null) {
        throw Exception('No billing session found');
      }

      // Normalize items for offline payload with better null safety
      final normalizedItems = billingSession.items?.map((item) {
            final map = item.toMap();
            return {
              "product": map["_id"] ?? map["product"] ?? 'unknown_product',
              "name": map["name"]?.toString() ?? 'Unknown Item',
              "image": map["image"]?.toString() ?? '',
              "quantity": map["qty"] ?? map["quantity"] ?? 1,
              "unitPrice":
                  _safeToDouble(map["unitPrice"] ?? map["basePrice"] ?? 0),
              "subtotal": _safeToDouble(((map["qty"] ?? map["quantity"] ?? 1) *
                  (map["unitPrice"] ?? map["basePrice"] ?? 0))),
            };
          }).toList() ??
          [];

      // Generate order number for offline use
      final orderNumber = 'OFF-${DateTime.now().millisecondsSinceEpoch}';

      // Create KOT items from billing session with null safety
      final kotItems = billingSession.items?.map((item) {
            return {
              "name": item.name?.toString() ?? 'Unknown Item',
              "quantity": item.quantity ?? 1,
            };
          }).toList() ??
          [];

      // Create final taxes array with proper calculation
      final taxAmount = billingSession.totalTax ?? 0.0;
      final subtotal = billingSession.subtotal ?? 0.0;
      final taxPercentage = subtotal > 0 ? (taxAmount / subtotal) * 100 : 0.0;

      final finalTax = [
        {
          "name": "GST",
          "percentage": taxPercentage,
          "amt": taxAmount,
        }
      ];

      // Get current timestamp
      final currentTime = DateTime.now();
      final createdAt = currentTime.toIso8601String();
      final formattedDate =
          "${currentTime.day}/${currentTime.month}/${currentTime.year}, ${currentTime.hour}:${currentTime.minute}:${currentTime.second}";

      // Prepare order data for Hive
      final Map<String, dynamic> hiveOrderData = {
        ...orderData,
        "items": normalizedItems,
        "orderStatus": orderData['orderStatus'] ?? 'PENDING_SYNC',
        "orderType": orderData['orderType'] ?? 'DINE-IN',
        "tableId": orderData['tableId'],
        "tableNo": orderData['tableNo']?.toString() ?? "",
        "waiter": orderData['waiter']?.toString() ?? "",
        "payments": orderData['payments'] ??
            [
              {
                "method": orderData['payments']?[0]?['method'] ?? 'CASH',
                "amount": billingSession.total ?? 0.0
              }
            ],
      };

      // Save order for later sync with all required fields
      final orderId = await HiveService.saveOfflineOrder(
        orderPayloadJson: jsonEncode(hiveOrderData),
        orderStatus: orderData['orderStatus'] ?? 'PENDING_SYNC',
        orderType: orderData['orderType'] ?? 'DINE-IN',
        tableId: orderData['tableId'],
        total: billingSession.total ?? 0.0,
        items: normalizedItems,
        syncAction: 'CREATE',
        businessName: 'Alagu Drive In',
        address: 'Tenkasi main road, Alangualam, Tamil Nadu 627851',
        gst: '00000000000',
        taxPercent: taxPercentage,
        paymentMethod: orderData['payments']?[0]?['method'] ?? 'CASH',
        phone: '+91 0000000000',
        waiterName: orderData['waiter']?.toString() ?? "",
        // New fields for receipt generation
        orderNumber: orderNumber,
        subtotal: subtotal,
        taxAmount: taxAmount,
        discountAmount: billingSession.totalDiscount ?? 0.0,
        kotItems: kotItems,
        finalTaxes: finalTax,
        tableName: orderData['tableNo']?.toString() ?? "",
      );

      // Clear cart/session
      await HiveService.clearCart();
      await HiveService.clearBillingSession();

      // Create complete offline response that matches your model exactly
      final offlineResponse = PostGenerateOrderModel(
        message: 'Order saved offline. Will sync when connection is restored.',
        order: Order(
          id: orderId,
          orderNumber: orderNumber,
          items: normalizedItems
              .map((item) => Items(
                    product: item['product']?.toString() ?? 'unknown',
                    name: item['name']?.toString() ?? 'Unknown Item',
                    quantity: item['quantity'] ?? 1,
                    unitPrice: _safeToDouble(item['unitPrice']),
                    subtotal: _safeToDouble(item['subtotal']),
                    addons: [],
                    // Empty addons for offline
                    tax: 0,
                    id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
                  ))
              .toList(),
          finalTaxes: finalTax
              .map((tax) => FinalTaxes(
                    name: tax['name']?.toString() ?? 'Tax',
                    percentage: _safeToDouble(tax['percentage']),
                    amount: _safeToDouble(tax['amt']),
                  ))
              .toList(),
          subtotal: subtotal,
          orderType: orderData['orderType'] ?? 'DINE-IN',
          tax: taxAmount,
          total: billingSession.total ?? 0.0,
          createdAt: createdAt,
        ),
        invoice: Invoice(
          businessName: 'Alagu Drive In',
          address: 'Tenkasi main road, Alangualam, Tamil Nadu 627851',
          phone: '+91 0000000000',
          gstNumber: '00000000000',
          currencySymbol: '₹',
          printType: 'imin',
          thermalIp: "",
          subtotal: subtotal,
          finalTaxes: finalTax
              .map((tax) => FinalTaxes(
                    name: tax['name']?.toString() ?? 'Tax',
                    percentage: _safeToDouble(tax['percentage']),
                    amount: _safeToDouble(tax['amt']),
                  ))
              .toList(),
          salesTax: taxAmount,
          total: billingSession.total ?? 0.0,
          orderNumber: orderNumber,
          orderStatus: 'PENDING_SYNC',
          // kot: kotItems.map((kotItem) => Kot(
          //   name: kotItem['name']?.toString() ?? 'Unknown Item',
          //   quantity: kotItem['quantity'] ?? 1,
          // )).toList(),
          date: formattedDate,
          paidBy: orderData['payments']?[0]?['method'] ?? 'CASH',
          transactionId: 'TXN-OFF-${DateTime.now().millisecondsSinceEpoch}',
          tableNum: orderData['tableNo']?.toString() ?? "",
          tableName: orderData['tableNo']?.toString() ?? "",
          waiterName: orderData['waiter']?.toString() ?? "",
          orderType: orderData['orderType'] ?? 'DINE-IN',
          tipAmount: 0,
        ),
        payments: [
          Payments(
            order: orderId,
            paymentMethod: orderData['payments']?[0]?['method'] ?? 'CASH',
            amount: billingSession.total ?? 0.0,
            balanceAmount: 0.0,
            status: 'COMPLETED',
            createdAt: createdAt,
            id: 'pay_offline_${DateTime.now().millisecondsSinceEpoch}',
          )
        ],
      );

      print("✅ Offline order created successfully with ID: $orderId");
      print("📄 Order number: $orderNumber");
      print("💰 Total: ${billingSession.total}");
      print("📦 Items count: ${normalizedItems.length}");

      emit(offlineResponse);
    } catch (e, stackTrace) {
      print("❌ Failed to save offline order: $e");
      print("❌ Stack trace: $stackTrace");
      emit(PostGenerateOrderModel(
        errorResponse: ErrorResponse(
          message: 'Failed to save offline order: $e',
          statusCode: 500,
        ),
      ));
    }
  }

  Future<void> _handleOfflineOrderUpdate(
      UpdateOrder event, Emitter emit) async {
    try {
      // Parse order payload to extract details
      final orderData = jsonDecode(event.orderPayloadJson);
      final billingSession = await HiveService.getBillingSession();

      if (billingSession == null) {
        throw Exception('No billing session found');
      }

      // Normalize items for offline payload with better null safety
      final normalizedItems = billingSession.items?.map((item) {
            final map = item.toMap();
            return {
              "product": map["_id"] ?? map["product"] ?? 'unknown_product',
              "name": map["name"]?.toString() ?? 'Unknown Item',
              "image": map["image"]?.toString() ?? '',
              "quantity": map["qty"] ?? map["quantity"] ?? 1,
              "unitPrice":
                  _safeToDouble(map["unitPrice"] ?? map["basePrice"] ?? 0),
              "subtotal": _safeToDouble(((map["qty"] ?? map["quantity"] ?? 1) *
                  (map["unitPrice"] ?? map["basePrice"] ?? 0))),
            };
          }).toList() ??
          [];

      // Create KOT items from billing session with null safety
      final kotItems = billingSession.items?.map((item) {
            return {
              "name": item.name?.toString() ?? 'Unknown Item',
              "quantity": item.quantity ?? 1,
            };
          }).toList() ??
          [];

      // Create final taxes array with proper calculation
      final taxAmount = billingSession.totalTax ?? 0.0;
      final subtotal = billingSession.subtotal ?? 0.0;
      final taxPercentage = subtotal > 0 ? (taxAmount / subtotal) * 100 : 0.0;

      final finalTax = [
        {
          "name": "GST",
          "percentage": taxPercentage,
          "amt": taxAmount,
        }
      ];

      // Get current timestamp
      final currentTime = DateTime.now();
      final createdAt = currentTime.toIso8601String();
      final formattedDate =
          "${currentTime.day}/${currentTime.month}/${currentTime.year}, ${currentTime.hour}:${currentTime.minute}:${currentTime.second}";

      // Prepare order data for Hive
      final Map<String, dynamic> hiveOrderData = {
        ...orderData,
        "items": normalizedItems,
        "orderStatus": orderData['orderStatus'] ?? 'PENDING_SYNC',
        "orderType": orderData['orderType'] ?? 'DINE-IN',
        "tableId": orderData['tableId'],
        "tableNo": orderData['tableNo']?.toString() ?? "",
        "waiter": orderData['waiter']?.toString() ?? "",
        "payments": orderData['payments'] ??
            [
              {
                "method": orderData['payments']?[0]?['method'] ?? 'CASH',
                "amount": billingSession.total ?? 0.0
              }
            ],
      };

      // Save order update for later sync with all required fields
      final orderId = await HiveService.saveOfflineOrder(
        orderPayloadJson: jsonEncode(hiveOrderData),
        orderStatus: orderData['orderStatus'] ?? 'PENDING_SYNC',
        orderType: orderData['orderType'] ?? 'DINE-IN',
        tableId: orderData['tableId'],
        total: billingSession.total ?? 0.0,
        items: normalizedItems,
        syncAction: 'UPDATE',
        existingOrderId: event.orderId,
        businessName: 'Alagu Drive In',
        address: 'Tenkasi main road, Alangualam, Tamil Nadu 627851',
        gst: '00000000000',
        taxPercent: taxPercentage,
        paymentMethod: orderData['payments']?[0]?['method'] ?? 'CASH',
        phone: '+91 0000000000',
        waiterName: orderData['waiter']?.toString() ?? "",
        // New fields for receipt generation
        orderNumber: 'UPD-${DateTime.now().millisecondsSinceEpoch}',
        subtotal: subtotal,
        taxAmount: taxAmount,
        discountAmount: billingSession.totalDiscount ?? 0.0,
        kotItems: kotItems,
        finalTaxes: finalTax,
        tableName: orderData['tableNo']?.toString() ?? "",
      );

      // Clear cart/session
      await HiveService.clearCart();
      await HiveService.clearBillingSession();

      // Create complete offline response for update
      final offlineResponse = update.UpdateGenerateOrderModel(
        message:
            'Order update saved offline. Will sync when connection is restored.',
        order: update.Order(
          id: event.orderId,
          // Use the existing order ID
          orderNumber: orderData['orderNumber'] ??
              'UPD-${DateTime.now().millisecondsSinceEpoch}',
          items: normalizedItems
              .map((item) => update.Items(
                    product: item['product']?.toString() ?? 'unknown',
                    name: item['name']?.toString() ?? 'Unknown Item',
                    quantity: item['quantity'] ?? 1,
                    unitPrice: _safeToDouble(item['unitPrice']),
                    subtotal: _safeToDouble(item['subtotal']),
                    addons: [],
                    // Empty addons for offline
                    tax: 0,
                    id: 'update_offline_${DateTime.now().millisecondsSinceEpoch}',
                  ))
              .toList(),
          finalTaxes: finalTax
              .map((tax) => update.FinalTaxes(
                    name: tax['name']?.toString() ?? 'Tax',
                    percentage: _safeToDouble(tax['percentage']),
                    amount: _safeToDouble(tax['amt']),
                  ))
              .toList(),
          subtotal: subtotal,
          orderType: orderData['orderType'] ?? 'DINE-IN',
          tax: taxAmount,
          total: billingSession.total ?? 0.0,
          // createdAt: createdAt,
        ),
        invoice: update.Invoice(
          businessName: 'Alagu Drive In',
          address: 'Tenkasi main road, Alangualam, Tamil Nadu 627851',
          phone: '+91 0000000000',
          gstNumber: '00000000000',
          currencySymbol: '₹',
          printType: 'imin',
          thermalIp: "",
          subtotal: subtotal,
          finalTaxes: finalTax
              .map((tax) => update.FinalTaxes(
                    name: tax['name']?.toString() ?? 'Tax',
                    percentage: _safeToDouble(tax['percentage']),
                    amount: _safeToDouble(tax['amt']),
                  ))
              .toList(),
          salesTax: taxAmount,
          total: billingSession.total ?? 0.0,
          orderNumber: orderData['orderNumber'] ??
              'UPD-${DateTime.now().millisecondsSinceEpoch}',
          orderStatus: 'PENDING_SYNC',
          // kot: kotItems.map((kotItem) =>
          //     update.Kot(
          //       name: kotItem['name']?.toString() ?? 'Unknown Item',
          //       quantity: kotItem['quantity'] ?? 1,
          //     )).toList(),
          date: formattedDate,
          paidBy: orderData['payments']?[0]?['method'] ?? 'CASH',
          transactionId: 'TXN-UPD-OFF-${DateTime.now().millisecondsSinceEpoch}',
          // tableNum: orderData['tableNo']?.toString() ?? "",
          tableName: orderData['tableNo']?.toString() ?? "",
          waiterName: orderData['waiter']?.toString() ?? "",
          orderType: orderData['orderType'] ?? 'DINE-IN',
          tipAmount: 0,
        ),
        payments: [
          update.Payments(
            order: event.orderId,
            paymentMethod: orderData['payments']?[0]?['method'] ?? 'CASH',
            amount: billingSession.total ?? 0.0,
            balanceAmount: 0.0,
            status: 'COMPLETED',
            createdAt: createdAt,
            id: 'pay_update_offline_${DateTime.now().millisecondsSinceEpoch}',
          )
        ],
      );

      print(
          "✅ Offline order update saved successfully for order ID: ${event.orderId}");
      print("💰 Updated Total: ${billingSession.total}");
      print("📦 Updated Items count: ${normalizedItems.length}");

      emit(offlineResponse);
    } catch (e, stackTrace) {
      print("❌ Failed to save offline order update: $e");
      print("❌ Stack trace: $stackTrace");
      emit(update.UpdateGenerateOrderModel(
        errorResponse: ErrorResponse(
          message: 'Failed to save offline order update: $e',
          statusCode: 500,
        ),
      ));
    }
  }

  // Helper method to safely convert to double
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
