import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/Bloc/Response/errorResponse.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart';
import 'package:simple/ModelClass/Table/Get_table_model.dart';
import 'package:simple/ModelClass/User/getUserModel.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Order/hive_ordertoday_model.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service_orderstoday.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service_table_stock.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_user_service.dart';

abstract class OrderTodayEvent {}

class OrderTodayList extends OrderTodayEvent {
  String fromDate;
  String toDate;
  String tableId;
  String waiterId;
  String userId;
  OrderTodayList(
      this.fromDate, this.toDate, this.tableId, this.waiterId, this.userId);
}

class DeleteOrder extends OrderTodayEvent {
  String? orderId;
  DeleteOrder(this.orderId);
}

class ViewOrder extends OrderTodayEvent {
  String? orderId;
  ViewOrder(this.orderId);
}

class TableDine extends OrderTodayEvent {}

class WaiterDine extends OrderTodayEvent {}

class UserDetails extends OrderTodayEvent {}

class OrderTodayBloc extends Bloc<OrderTodayEvent, dynamic> {
  OrderTodayBloc() : super(dynamic) {
    on<OrderTodayList>((event, emit) async {
      final hiveService = HiveOrderTodayService();

      try {
        final connectivityResult = await Connectivity().checkConnectivity();

        ConnectivityResult result;
        if (connectivityResult is List) {
          // Web: handle edge case
          if (connectivityResult.isNotEmpty && connectivityResult.first is ConnectivityResult) {
            result = connectivityResult.first as ConnectivityResult;
          } else {
            result = ConnectivityResult.none;
          }
        } else if (connectivityResult is ConnectivityResult) {
          // Mobile / Desktop
          result = connectivityResult as ConnectivityResult;
        } else {
          // Unknown / unexpected type
          result = ConnectivityResult.none;
        }

        final hasConnection = result != ConnectivityResult.none;


        if (hasConnection) {
          // ✅ Online mode
          try {
            final value = await ApiProvider().getOrderTodayAPI(
              event.fromDate,
              event.toDate,
              event.tableId,
              event.waiterId,
              event.userId,
            );

            if (value.success == true && value.data != null) {
              // Save to Hive
              await hiveService.saveOrders(value);
            }

            emit(value);
          } catch (error) {
            debugPrint("❌ API failed, fallback to Hive: $error");
            final cached = await hiveService.getOrders();
            if (cached != null) {
              emit(cached);
            } else {
              emit(GetOrderListTodayModel(
                success: false,
                data: [],
                errorResponse: ErrorResponse(
                  message: error.toString(),
                  statusCode: 500,
                ),
              ));
            }
          }
        } else {
          // 📴 Offline mode
          final cached = await hiveService.getOrders();
          if (cached != null) {
            debugPrint('📴 Loaded ${cached.data?.length ?? 0} offline orders');
            emit(cached);
          } else {
            emit(GetOrderListTodayModel(
              success: false,
              data: [],
              errorResponse: ErrorResponse(
                message: 'No offline order data available',
                statusCode: 503,
              ),
            ));
          }
        }
      } catch (e) {
        debugPrint('❌ Bloc Error: $e');
        final cached = await hiveService.getOrders();
        if (cached != null) {
          emit(cached);
        } else {
          emit(GetOrderListTodayModel(
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
    on<DeleteOrder>((event, emit) async {
      await ApiProvider().deleteOrderAPI(event.orderId).then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<ViewOrder>((event, emit) async {
      await ApiProvider().viewOrderAPI(event.orderId).then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
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
      await ApiProvider().getWaiterAPI().then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<UserDetails>((event, emit) async {
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        bool hasConnection = connectivityResult != ConnectivityResult.none;

        debugPrint('🌐 User Connectivity: $hasConnection');

        if (hasConnection) {
          // Online: Try API first
          try {
            debugPrint('📡 Fetching users from API...');
            final value = await ApiProvider().getUserDetailsAPI(); // This now has offline support
            debugPrint('✅ API response - success: ${value.success}, data count: ${value.data?.length ?? 0}');

            if (value.success == true && value.data != null) {
              debugPrint('💾 Saving ${value.data!.length} users to Hive...');
              await HiveUserService.saveUsers(value.data!);
              debugPrint('✅ Users saved to Hive successfully');
            }

            emit(value);
          } catch (error) {
            debugPrint('❌ API failed: $error');
            // API failed, load from Hive
            final offlineUsers = await HiveUserService.getUsersAsApiFormat();
            debugPrint('📂 Offline users found: ${offlineUsers.length}');

            if (offlineUsers.isNotEmpty) {
              debugPrint('🔄 Loading from offline storage');
              final offlineResponse = GetUserModel(
                success: true,
                data: offlineUsers,
                totalCount: offlineUsers.length,
                errorResponse: null,
              );
              emit(offlineResponse);
            } else {
              debugPrint('❌ No offline data available');
              emit(GetUserModel(
                success: false,
                data: [],
                totalCount: 0,
                errorResponse: ErrorResponse(
                  message: error.toString(),
                  statusCode: 500,
                ),
              ));
            }
          }
        } else {
          // Offline: Load from Hive directly
          debugPrint('📶 Offline mode - loading users from Hive');
          final offlineUsers = await HiveUserService.getUsersAsApiFormat();
          debugPrint('📂 Offline users found: ${offlineUsers.length}');

          if (offlineUsers.isNotEmpty) {
            debugPrint('✅ Loading ${offlineUsers.length} users from offline storage');
            final offlineResponse = GetUserModel(
              success: true,
              data: offlineUsers,
              totalCount: offlineUsers.length,
              errorResponse: null,
            );
            emit(offlineResponse);
          } else {
            debugPrint('❌ No offline user data available');
            emit(GetUserModel(
              success: false,
              data: [],
              totalCount: 0,
              errorResponse: ErrorResponse(
                message: 'No offline user data available',
                statusCode: 503,
              ),
            ));
          }
        }
      } catch (e) {
        debugPrint('💥 Error in UserDetails event: $e');
        final offlineUsers = await HiveUserService.getUsersAsApiFormat();
        debugPrint('📂 Fallback offline users: ${offlineUsers.length}');

        if (offlineUsers.isNotEmpty) {
          final offlineResponse = GetUserModel(
            success: true,
            data: offlineUsers,
            totalCount: offlineUsers.length,
            errorResponse: null,
          );
          emit(offlineResponse);
        } else {
          emit(GetUserModel(
            success: false,
            data: [],
            totalCount: 0,
            errorResponse: ErrorResponse(
              message: e.toString(),
              statusCode: 500,
            ),
          ));
        }
      }
    });
  }
}
