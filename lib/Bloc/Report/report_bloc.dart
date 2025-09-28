import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/Bloc/Response/errorResponse.dart';
import 'package:simple/ModelClass/Report/Get_report_model.dart';
import 'package:simple/ModelClass/Table/Get_table_model.dart' hide Data;
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_report_service.dart';
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
      try {
        final result = await ApiProvider().getReportTodayAPI(
          event.fromDate,
          event.toDate,
          event.tableId,
          event.waiterId,
          event.operatorId,
        );

        if (result.errorResponse == null) {
          // ✅ Online data
          emit(result);
        } else {
          // ✅ Offline fallback
          final offlineReports = await HiveReportService.getReports(
            fromDate: event.fromDate != null ? DateTime.parse(event.fromDate!) : DateTime.now(),
            toDate: event.toDate != null ? DateTime.parse(event.toDate!) : null,
            tableNo: event.tableId,
            waiterId: event.waiterId,
          );

          on<ReportTodayList>((event, emit) async {
            try {
              final result = await ApiProvider().getReportTodayAPI(
                event.fromDate,
                event.toDate,
                event.tableId,
                event.waiterId,
                event.operatorId,
              );

              if (result.errorResponse == null) {
                // ✅ Online data
                emit(result);
              } else {
                // ✅ Offline fallback
                final offlineReports = await HiveReportService.getReports(
                  fromDate: event.fromDate != null ? DateTime.parse(event.fromDate!) : DateTime.now(),
                  toDate: event.toDate != null ? DateTime.parse(event.toDate!) : DateTime.now(),
                  tableNo: event.tableId,
                  waiterId: event.waiterId,
                );

                emit(GetReportModel(
                  success: true,
                  data: offlineReports.map((e) => Data(
                    productId: null, // not available offline
                    productName: e.productName ?? "Unknown",
                    unitPrice: (e.quantity ?? 0) > 0 ? (e.amount ?? 0) / (e.quantity ?? 1) : 0,
                    totalQty: e.quantity ?? 0,
                    totalTax: 0,
                    totalAmount: e.amount ?? 0,
                  )).toList(),
                  totalRecords: offlineReports.length,
                  finalAmount: offlineReports.fold<num>(0, (sum, r) => sum + (r.amount ?? 0)),
                  finalQty: offlineReports.fold<num>(0, (sum, r) => sum + (r.quantity ?? 0)),
                ));
              }
            } catch (e) {
              // ✅ Last fallback if API fails
              final offlineReports = await HiveReportService.getReports();
              emit(GetReportModel(
                success: true,
                data: offlineReports.map((e) => Data(
                  productId: null,
                  productName: e.productName,
                  unitPrice: e.amount / (e.quantity > 0 ? e.quantity : 1),
                  totalQty: e.quantity,
                  totalTax: 0,
                  totalAmount: e.amount,
                )).toList(),
                totalRecords: offlineReports.length,
                finalAmount: offlineReports.fold<num>(0, (sum, r) => sum + (r.amount ?? 0)),
                finalQty: offlineReports.fold<num>(0, (sum, r) => sum + (r.quantity ?? 0)),
              ));
            }
          });

        }
      } catch (e) {
        // ✅ Last fallback if API fails
        final offlineReports = await HiveReportService.getReports();
        emit(GetReportModel(
          success: true,
          data: offlineReports.map((e) => Data(
            productId: null,
            productName: e.productName,
            unitPrice: e.amount / (e.quantity > 0 ? e.quantity : 1),
            totalQty: e.quantity,
            totalTax: 0,
            totalAmount: e.amount,
          )).toList(),
          totalRecords: offlineReports.length,
          finalAmount: offlineReports.fold(0, (sum, r) => sum! + r.amount),
          finalQty: offlineReports.fold(0, (sum, r) => sum! + r.quantity),
        ));
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
