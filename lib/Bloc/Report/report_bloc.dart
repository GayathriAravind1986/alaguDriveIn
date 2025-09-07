import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/Bloc/Response/errorResponse.dart';
import 'package:simple/ModelClass/Table/Get_table_model.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service_table_stock.dart';

abstract class ReportTodayEvent {}

class ReportTodayList extends ReportTodayEvent {
  String fromDate;
  String toDate;
  String tableId;
  String waiterId;
  String operatorId;
  ReportTodayList(
      this.fromDate, this.toDate, this.tableId, this.waiterId, this.operatorId);
}

class TableDine extends ReportTodayEvent {}

class WaiterDine extends ReportTodayEvent {}

class UserDetails extends ReportTodayEvent {}

class ReportTodayBloc extends Bloc<ReportTodayEvent, dynamic> {
  ReportTodayBloc() : super(dynamic) {
    on<ReportTodayList>((event, emit) async {
      await ApiProvider()
          .getReportTodayAPI(event.fromDate, event.toDate, event.tableId,
              event.waiterId, event.operatorId)
          .then((value) {
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
      await ApiProvider().getUserDetailsAPI().then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
  }
}
