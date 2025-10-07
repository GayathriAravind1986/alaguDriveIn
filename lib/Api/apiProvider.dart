import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Bloc/Response/errorResponse.dart';
import 'package:simple/ModelClass/Authentication/Post_login_model.dart';
import 'package:simple/ModelClass/Cart/Post_Add_to_billing_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart'
    hide Data;
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart';
import 'package:simple/ModelClass/Order/Delete_order_model.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart' hide Data;
import 'package:simple/ModelClass/Order/Post_generate_order_model.dart';
import 'package:simple/ModelClass/Order/Update_generate_order_model.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart'
    hide Data;
import 'package:simple/ModelClass/Products/get_products_cat_model.dart'
    hide Data;
import 'package:simple/ModelClass/Report/Get_report_model.dart';
import 'package:simple/ModelClass/ShopDetails/getStockMaintanencesModel.dart'
    hide Data;
import 'package:simple/ModelClass/StockIn/getLocationModel.dart' hide Data;
import 'package:simple/ModelClass/StockIn/getSupplierLocationModel.dart'
    hide Data;
import 'package:simple/ModelClass/StockIn/get_add_product_model.dart' hide Data;
import 'package:simple/ModelClass/StockIn/saveStockInModel.dart' hide Data;
import 'package:simple/ModelClass/User/getUserModel.dart' hide Data;
import 'package:simple/ModelClass/Waiter/getWaiterModel.dart' hide Data;
import 'package:simple/Offline/Hive_helper/LocalClass/Report/hive_report_model.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/connectivity_service.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive-pending_delete_service.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_report_service.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service_orderstoday.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_sync_service.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_user_service.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_waiter_service.dart';
import 'package:simple/Reusable/constant.dart';

import '../ModelClass/Table/Get_table_model.dart' hide Data;

/// All API Integration in ApiProvider
class ApiProvider {
  late Dio _dio;

  /// dio use ApiProvider
  ApiProvider() {
    final options = BaseOptions(
        connectTimeout: const Duration(milliseconds: 150000),
        receiveTimeout: const Duration(milliseconds: 100000));
    _dio = Dio(options);
  }

  /// LoginWithOTP API Integration
  Future<PostLoginModel> loginAPI(
    String email,
    String password,
  ) async {
    try {
      final dataMap = {"email": email, "password": password};
      var data = json.encode(dataMap);
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}auth/users/login'.trim(),
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          PostLoginModel postLoginResponse =
              PostLoginModel.fromJson(response.data);
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString(
            "token",
            postLoginResponse.token.toString(),
          );
          sharedPreferences.setString(
            "role",
            postLoginResponse.user!.role.toString(),
          );
          sharedPreferences.setString(
            "userId",
            postLoginResponse.user!.id.toString(),
          );
          return postLoginResponse;
        }
      }
      return PostLoginModel()
        ..errorResponse = ErrorResponse(message: "Unexpected error occurred.");
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return PostLoginModel()..errorResponse = errorResponse;
    } catch (error) {
      return PostLoginModel()..errorResponse = handleError(error);
    }
  }

  /// Category - Fetch API Integration
  static Future<GetCategoryModel> getCategoryAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("token:$token");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/categories/name',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetCategoryModel getCategoryResponse =
              GetCategoryModel.fromJson(response.data);
          debugPrint("categoryRespnse:$getCategoryResponse");
          return getCategoryResponse;
        }
      } else {
        return GetCategoryModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetCategoryModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetCategoryModel()..errorResponse = errorResponse;
    } catch (error) {
      final errorResponse = handleError(error);
      return GetCategoryModel()..errorResponse = errorResponse;
    }
  }

  /// product - Fetch API Integration
  static Future<GetProductByCatIdModel> getProductItemAPI(
      String? catId, String? searchKey, String? searchCode) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/products/pos/category-products?filter=false&categoryId=$catId&search=$searchKey&searchcode=$searchCode',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetProductByCatIdModel getProductByCatIdResponse =
              GetProductByCatIdModel.fromJson(response.data);
          return getProductByCatIdResponse;
        }
      } else {
        return GetProductByCatIdModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetProductByCatIdModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetProductByCatIdModel()..errorResponse = errorResponse;
    } catch (error) {
      return GetProductByCatIdModel()..errorResponse = handleError(error);
    }
  }

  /// Table - Fetch API Integration
  Future<GetTableModel> getTableAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/tables?isDefault=true',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetTableModel getTableResponse =
              GetTableModel.fromJson(response.data);
          return getTableResponse;
        }
      } else {
        return GetTableModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetTableModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetTableModel()..errorResponse = errorResponse;
    } catch (error) {
      return GetTableModel()..errorResponse = handleError(error);
    }
  }

  /// Waiter Details -Fetch API Integration
  Future<GetWaiterModel> getWaiterAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");

    try {
      debugPrint("Attempting to fetch waiters from network...");
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/waiter?isAvailable=true&isSupplier=false',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        debugPrint("API call successful! Saving data to Hive.");
        GetWaiterModel getWaiterResponse =
            GetWaiterModel.fromJson(response.data);
        if (getWaiterResponse.data != null) {
          // Save the new data to Hive on successful network response
          await HiveWaiterService.saveWaiters(getWaiterResponse.data!);
        }
        return getWaiterResponse;
      } else {
        // If the API returns a non-200 but not a network error, return the error
        return GetWaiterModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (dioError) {
      debugPrint(
          "DioException occurred! Attempting to load waiters from Hive as a fallback.");
      final offlineData = await HiveWaiterService.getWaitersAsApiFormat();
      if (offlineData.isNotEmpty) {
        debugPrint(
            "Successfully loaded ${offlineData.length} waiters from Hive.");
        return GetWaiterModel(
            data: offlineData, totalCount: offlineData.length);
      }

      debugPrint("No offline data found. Returning network error.");
      final errorResponse = handleError(dioError);
      return GetWaiterModel()..errorResponse = errorResponse;
    } catch (error) {
      debugPrint(
          "An unexpected error occurred. Attempting to load waiters from Hive.");
      final offlineData = await HiveWaiterService.getWaitersAsApiFormat();
      if (offlineData.isNotEmpty) {
        debugPrint(
            "Successfully loaded ${offlineData.length} waiters from Hive.");
        return GetWaiterModel(
            data: offlineData, totalCount: offlineData.length);
      }
      debugPrint("No offline data found. Returning generic error.");
      return GetWaiterModel()..errorResponse = handleError(error);
    }
  }

  /// userDetails - Fetch API Integration
  Future<GetUserModel> getUserDetailsAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");

    try {
      debugPrint("Attempting to fetch users from network...");
      final dio = Dio();
      final response = await dio.request(
        '${Constants.baseUrl}auth/users',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Check for a successful status code first
      if (response.statusCode == 200) {
        if (response.data != null && response.data['success'] == true) {
          debugPrint("API call successful! Saving data to Hive.");
          GetUserModel getUserResponse = GetUserModel.fromJson(response.data);
          if (getUserResponse.data != null) {
            // Save the new data to Hive on successful network response
            await HiveUserService.saveUsers(getUserResponse.data!);
          }
          return getUserResponse;
        } else {
          // Handle cases where the status code is 200 but the API returns success: false
          debugPrint("API returned success: false");
          // Try to load from Hive as fallback
          final offlineData = await HiveUserService.getUsersAsApiFormat();
          if (offlineData.isNotEmpty) {
            debugPrint("Using offline data as fallback");
            return GetUserModel(
                data: offlineData, totalCount: offlineData.length);
          }

          return GetUserModel()
            ..errorResponse = ErrorResponse(
              message:
                  response.data['message'] ?? 'API response indicates failure.',
              statusCode: 200,
            );
        }
      } else {
        // Handle non-200 status codes
        debugPrint("API returned status: ${response.statusCode}");
        // Try to load from Hive as fallback
        final offlineData = await HiveUserService.getUsersAsApiFormat();
        if (offlineData.isNotEmpty) {
          debugPrint(
              "Using offline data as fallback for status code ${response.statusCode}");
          return GetUserModel(
              data: offlineData, totalCount: offlineData.length);
        }

        return GetUserModel()
          ..errorResponse = ErrorResponse(
            message: response.statusMessage ??
                "Request failed with status code ${response.statusCode}",
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (dioError) {
      debugPrint(
          "DioException occurred! Attempting to load users from Hive as a fallback.");
      final offlineData = await HiveUserService.getUsersAsApiFormat();
      if (offlineData.isNotEmpty) {
        debugPrint(
            "Successfully loaded ${offlineData.length} users from Hive.");
        return GetUserModel(data: offlineData, totalCount: offlineData.length);
      }

      debugPrint("No offline data found. Returning network error.");
      final errorResponse = handleError(dioError);
      return GetUserModel()..errorResponse = errorResponse;
    } catch (error) {
      debugPrint(
          "An unexpected error occurred. Attempting to load users from Hive.");
      final offlineData = await HiveUserService.getUsersAsApiFormat();
      if (offlineData.isNotEmpty) {
        debugPrint(
            "Successfully loaded ${offlineData.length} users from Hive.");
        return GetUserModel(data: offlineData, totalCount: offlineData.length);
      }
      debugPrint("No offline data found. Returning generic error.");
      return GetUserModel()
        ..errorResponse = ErrorResponse(
          message: error.toString(),
          statusCode: 500,
        );
    }
  }

  /// Stock Details - Fetch API Integration
  Future<GetStockMaintanencesModel> getStockDetailsAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/shops',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetStockMaintanencesModel getShopDetailsResponse =
              GetStockMaintanencesModel.fromJson(response.data);
          return getShopDetailsResponse;
        }
      } else {
        return GetStockMaintanencesModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetStockMaintanencesModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetStockMaintanencesModel()..errorResponse = errorResponse;
    } catch (error) {
      return GetStockMaintanencesModel()..errorResponse = handleError(error);
    }
  }

  /// Add to Billing - Post API Integration
  Future<PostAddToBillingModel> postAddToBillingAPI(
      List<Map<String, dynamic>> billingItems,
      bool? isDiscount,
      String? orderType) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      final dataMap = {
        "items": billingItems,
        "isApplicableDiscount": isDiscount,
        "orderType": orderType
      };
      var data = json.encode(dataMap);
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/billing/calculate',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        try {
          PostAddToBillingModel postAddToBillingResponse =
              PostAddToBillingModel.fromJson(response.data);
          return postAddToBillingResponse;
        } catch (e) {
          return PostAddToBillingModel()
            ..errorResponse = ErrorResponse(
              message: "Failed to parse response: $e",
            );
        }
      } else {
        return PostAddToBillingModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return PostAddToBillingModel()..errorResponse = errorResponse;
    } catch (error) {
      return PostAddToBillingModel()..errorResponse = handleError(error);
    }
  }

  /// orderToday - Fetch API Integration
  Future<GetOrderListTodayModel> getOrderTodayAPI(
    String? fromDate,
    String? toDate,
    String? tableId,
    String? waiterId,
    String? operatorId,
  ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");

    try {
      debugPrint(
          "baseUrlOrder: ${Constants.baseUrl}api/generate-order?from_date=$fromDate&to_date=$toDate&tableNo=$tableId&waiter=$waiterId&operator=$operatorId");

      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order?from_date=$fromDate&to_date=$toDate&tableNo=$tableId&waiter=$waiterId&operator=$operatorId',
        options: Options(
          method: 'GET',
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return GetOrderListTodayModel.fromJson(response.data);
      } else {
        return GetOrderListTodayModel(
          success: false,
          data: [],
          errorResponse: ErrorResponse(
            message: response.statusMessage ?? "Unknown error",
            statusCode: response.statusCode ?? 500,
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ API Error: $e");
      return GetOrderListTodayModel(
        success: false,
        data: [],
        errorResponse: ErrorResponse(
          message: e.toString(),
          statusCode: 500,
        ),
      );
    }
  }

  /// ReportToday - Fetch API Integration
  Future<GetReportModel> getReportTodayAPI(
    String? fromDate,
    String? toDate,
    String? tableId,
    String? waiterId,
    String? operatorId,
  ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");

    // ✅ Clear old Hive data to avoid migration issues
    // await HiveReportService.clearReports();

    // ✅ Get business details from SharedPreferences for offline use
    String businessName =
        sharedPreferences.getString("businessName") ?? "Alagu Drive In";
    String userName = sharedPreferences.getString("userName") ?? "Counter1";
    String address = sharedPreferences.getString("address") ??
        "Tenkasi main road, Alangualam, Tamil Nadu 627851";
    String phone = sharedPreferences.getString("phone") ?? "+91 0000000000";
    String location = sharedPreferences.getString("location") ?? "ALANGULAM";
    String gstNumber =
        sharedPreferences.getString("gstNumber") ?? "00000000000";
    String currencySymbol =
        sharedPreferences.getString("currencySymbol") ?? "₹";

    debugPrint(
        "baseUrlReport:'${Constants.baseUrl}api/generate-order/sales-report?from_date=$fromDate&to_date=$toDate&limit=200&tableNo=$tableId&waiter=$waiterId&operator=$operatorId");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/sales-report?from_date=$fromDate&to_date=$toDate&limit=200&tableNo=$tableId&waiter=$waiterId&operator=$operatorId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          // ✅ API success → parse normally
          GetReportModel getReportListTodayResponse =
              GetReportModel.fromJson(response.data);

          // ✅ Extract business details from API response for saving
          String apiBusinessName =
              response.data['businessName'] ?? businessName;
          String apiUserName = response.data['UserName'] ?? userName;
          String apiAddress = response.data['address'] ?? address;
          String apiPhone = response.data['phone'] ?? phone;
          String apiLocation = response.data['location'] ?? location;
          String apiGstNumber = response.data['gstNumber'] ?? gstNumber;
          String apiCurrencySymbol =
              response.data['currencySymbol'] ?? currencySymbol;

          // ✅ Save business details to SharedPreferences for offline use
          await sharedPreferences.setString("businessName", apiBusinessName);
          await sharedPreferences.setString("userName", apiUserName);
          await sharedPreferences.setString("address", apiAddress);
          await sharedPreferences.setString("phone", apiPhone);
          await sharedPreferences.setString("location", apiLocation);
          await sharedPreferences.setString("gstNumber", apiGstNumber);
          await sharedPreferences.setString(
              "currencySymbol", apiCurrencySymbol);

          // ✅ Convert API reports to Hive models with ALL business details
          final List<HiveReportModel> hiveReports =
              (response.data['data'] as List).map((json) {
            return HiveReportModel.fromJson(
              json,
              userName: apiUserName,
              businessName: apiBusinessName,
              address: apiAddress,
              phone: apiPhone,
              location: apiLocation,
              fromDate:
                  fromDate ?? DateFormat('dd/MM/yyyy').format(DateTime.now()),
              toDate: toDate ?? DateFormat('dd/MM/yyyy').format(DateTime.now()),
              gstNumber: apiGstNumber,
              currencySymbol: apiCurrencySymbol,
            );
          }).toList();

          await HiveReportService.clearReports();
          // ✅ Save to Hive for offline use
          await HiveReportService.saveReports(hiveReports);

          return getReportListTodayResponse;
        }
      } else {
        return GetReportModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }

      return GetReportModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      // ✅ API failed → fallback to Hive with filtering
      final offlineReports = await HiveReportService.getReports(
        fromDate: fromDate != null
            ? DateTime.parse(fromDate)
            : DateTime.now().subtract(const Duration(days: 30)),
        toDate: toDate != null ? DateTime.parse(toDate) : DateTime.now(),
        tableNo: tableId,
        waiterId: waiterId,
      );

      if (offlineReports.isNotEmpty) {
        // ✅ Use the FIRST report's business details with SAFE GETTERS
        HiveReportModel firstReport = offlineReports.first;

        return GetReportModel(
          success: true,
          data: offlineReports
              .map((e) => Data(
                    productId: null,
                    productName: e.productName,
                    unitPrice: e.quantity > 0 ? e.amount / e.quantity : 0,
                    totalQty: e.quantity,
                    totalTax: 0,
                    totalAmount: e.amount,
                  ))
              .toList(),
          totalRecords: offlineReports.length,
          finalAmount: offlineReports.fold<num>(0, (sum, r) => sum + r.amount),
          finalQty: offlineReports.fold<num>(0, (sum, r) => sum + r.quantity),
          userName: firstReport.userNameSafe,
          businessName: firstReport.businessNameSafe,
          address: firstReport.addressSafe,
          phone: firstReport.phoneSafe,
          location: firstReport.locationSafe,
          fromDate: firstReport.fromDateSafe,
          toDate: firstReport.toDateSafe,
          gstNumber: firstReport.gstNumber ?? '',
          currencySymbol: firstReport.currencySymbolSafe,
        );
      }

      // If no offline data, return error
      final errorResponse = handleError(dioError);
      return GetReportModel()..errorResponse = errorResponse;
    } catch (error) {
      // Last safety fallback: Hive with filtering
      final offlineReports = await HiveReportService.getReports(
        fromDate: fromDate != null
            ? DateTime.parse(fromDate)
            : DateTime.now().subtract(const Duration(days: 30)),
        toDate: toDate != null ? DateTime.parse(toDate) : DateTime.now(),
        tableNo: tableId,
        waiterId: waiterId,
      );

      if (offlineReports.isNotEmpty) {
        HiveReportModel firstReport = offlineReports.first;

        return GetReportModel(
          success: true,
          data: offlineReports
              .map((e) => Data(
                    productId: null,
                    productName: e.productName,
                    unitPrice: e.quantity > 0 ? e.amount / e.quantity : 0,
                    totalQty: e.quantity,
                    totalTax: 0,
                    totalAmount: e.amount,
                  ))
              .toList(),
          totalRecords: offlineReports.length,
          finalAmount: offlineReports.fold<num>(0, (sum, r) => sum + r.amount),
          finalQty: offlineReports.fold<num>(0, (sum, r) => sum + r.quantity),
          userName: firstReport.userNameSafe,
          businessName: firstReport.businessNameSafe,
          address: firstReport.addressSafe,
          phone: firstReport.phoneSafe,
          location: firstReport.locationSafe,
          fromDate: firstReport.fromDateSafe,
          toDate: firstReport.toDateSafe,
          gstNumber: firstReport.gstNumber ?? '',
          currencySymbol: firstReport.currencySymbolSafe,
        );
      }
      return GetReportModel()..errorResponse = handleError(error);
    }
  }

  /// Generate Order - Post API Integration
  Future<PostGenerateOrderModel> postGenerateOrderAPI(
      final String orderPayloadJson) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("payload:$orderPayloadJson");
    try {
      var data = orderPayloadJson;
      debugPrint("data:$data");
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/order',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      if (response.statusCode == 201 && response.data != null) {
        try {
          PostGenerateOrderModel postGenerateOrderResponse =
              PostGenerateOrderModel.fromJson(response.data);
          return postGenerateOrderResponse;
        } catch (e) {
          return PostGenerateOrderModel()
            ..errorResponse = ErrorResponse(
              message: "Failed to parse response: $e",
            );
        }
      } else {
        return PostGenerateOrderModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return PostGenerateOrderModel()..errorResponse = errorResponse;
    } catch (error) {
      return PostGenerateOrderModel()..errorResponse = handleError(error);
    }
  }

  /// Delete Order - Fetch API Integration
  Future<DeleteOrderModel> deleteOrderAPI(String? orderId) async {
    if (orderId == null || orderId.isEmpty) {
      return DeleteOrderModel()
        ..errorResponse = ErrorResponse(
          message: "Invalid Order ID. Cannot delete.",
          statusCode: 400,
        );
    }

    // ✅ Check connectivity with proper handling
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      bool isConnected = false;
      if (connectivityResult is List) {
        isConnected = connectivityResult
            .any((result) => result != ConnectivityResult.none);
      } else if (connectivityResult is ConnectivityResult) {
        isConnected = connectivityResult != ConnectivityResult.none;
      }

      if (!isConnected) {
        // 📴 Offline: save for later sync
        print(
            "📴 Offline detected - saving delete request for order: $orderId");
        final success = await HiveServicedelete.addPendingDelete(orderId);

        // 🔧 FIXED: Use 503 status code consistently
        return DeleteOrderModel()
          ..errorResponse = ErrorResponse(
            message: success
                ? "No internet connection. Delete request saved for later sync."
                : "Delete request already saved offline.",
            statusCode: 503, // ✅ This triggers offline state in BLoC
          );
      }
    } catch (e) {
      print("❌ Connectivity check failed: $e");
      await HiveServicedelete.addPendingDelete(orderId);
      return DeleteOrderModel()
        ..errorResponse = ErrorResponse(
          message: "Connection check failed. Delete request saved offline.",
          statusCode: 503,
        );
    }

    // ✅ Online flow
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString("token");

    if (token == null || token.isEmpty) {
      return DeleteOrderModel()
        ..errorResponse = ErrorResponse(
          message: "Session expired. Please login again.",
          statusCode: 401,
        );
    }

    try {
      print("🌐 Attempting to delete order $orderId via API");

      final dio = Dio();
      final response = await dio.request(
        '${Constants.baseUrl}api/generate-order/order/$orderId',
        options: Options(
          method: 'DELETE',
          headers: {'Authorization': 'Bearer $token'},
          // connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print("📡 API Response - Status: ${response.statusCode}");

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          print("✅ Order $orderId deleted successfully");
          return DeleteOrderModel.fromJson(response.data);
        }
      }

      return DeleteOrderModel()
        ..errorResponse = ErrorResponse(
          message: response.data?['message'] ?? 'Failed to delete order',
          statusCode: response.statusCode ?? 503,
        );
    } on DioException catch (dioError) {
      print("❌ DioException: ${dioError.type}");

      // Handle network errors by saving offline
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.connectionError) {
        print("🔄 Network issue - saving for offline sync");
        await HiveServicedelete.addPendingDelete(orderId);

        return DeleteOrderModel()
          ..errorResponse = ErrorResponse(
            message: "Network timeout. Delete request saved for later sync.",
            statusCode: 503, // Triggers offline state
          );
      }

      return DeleteOrderModel()..errorResponse = handleError(dioError);
    } catch (error) {
      print("❌ Unexpected error: $error");
      // Save offline as fallback
      await HiveServicedelete.addPendingDelete(orderId);

      return DeleteOrderModel()
        ..errorResponse = ErrorResponse(
          message: "Error occurred. Delete request saved for later sync.",
          statusCode: 503,
        );
    }
  }

  /// products-Category - Fetch API Integration
  static Future<GetProductsCatModel> getProductsCatAPI(String? catId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/products/pos/category-products-with-category?filter=false&categoryId=$catId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetProductsCatModel getProductsCatResponse =
              GetProductsCatModel.fromJson(response.data);
          return getProductsCatResponse;
        }
      } else {
        return GetProductsCatModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetProductsCatModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetProductsCatModel()..errorResponse = errorResponse;
    } catch (error) {
      return GetProductsCatModel()..errorResponse = handleError(error);
    }
  }

  /// View Order - Fetch API Integration
  Future<GetViewOrderModel> viewOrderAPI(String? orderId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/$orderId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetViewOrderModel getViewOrderResponse =
              GetViewOrderModel.fromJson(response.data);
          return getViewOrderResponse;
        }
      } else {
        return GetViewOrderModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetViewOrderModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetViewOrderModel()..errorResponse = errorResponse;
    } catch (error) {
      return GetViewOrderModel()..errorResponse = handleError(error);
    }
  }

  /// Update Generate Order - Post API Integration
  Future<UpdateGenerateOrderModel> updateGenerateOrderAPI(
      final String orderPayloadJson, String? orderId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("payload:$orderPayloadJson");
    try {
      var data = orderPayloadJson;
      debugPrint("data:$data");
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/order/$orderId',
        options: Options(
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        try {
          UpdateGenerateOrderModel updateGenerateOrderResponse =
              UpdateGenerateOrderModel.fromJson(response.data);
          return updateGenerateOrderResponse;
        } catch (e) {
          return UpdateGenerateOrderModel()
            ..errorResponse = ErrorResponse(
              message: "Failed to parse response: $e",
            );
        }
      } else {
        return UpdateGenerateOrderModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return UpdateGenerateOrderModel()..errorResponse = errorResponse;
    } catch (error) {
      return UpdateGenerateOrderModel()..errorResponse = handleError(error);
    }
  }

  /***** Stock_In*****/
  /// Location - fetch API Integration
  Future<GetLocationModel> getLocationAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("token:$token");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}auth/users/bylocation',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetLocationModel getLocationResponse =
              GetLocationModel.fromJson(response.data);
          return getLocationResponse;
        }
      } else {
        return GetLocationModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetLocationModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetLocationModel()..errorResponse = errorResponse;
    } catch (error) {
      final errorResponse = handleError(error);
      return GetLocationModel()..errorResponse = errorResponse;
    }
  }

  /// Supplier - fetch API Integration
  Future<GetSupplierLocationModel> getSupplierAPI(String? locationId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("token:$token");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/supplier?isDefault=true&filter=false&locationId=$locationId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetSupplierLocationModel getSupplierResponse =
              GetSupplierLocationModel.fromJson(response.data);
          return getSupplierResponse;
        }
      } else {
        return GetSupplierLocationModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetSupplierLocationModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetSupplierLocationModel()..errorResponse = errorResponse;
    } catch (error) {
      final errorResponse = handleError(error);
      return GetSupplierLocationModel()..errorResponse = errorResponse;
    }
  }

  /// Add Product - fetch API Integration
  Future<GetAddProductModel> getAddProductAPI(String? locationId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("token:$token");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/products?locationId=$locationId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetAddProductModel getAddProductResponse =
              GetAddProductModel.fromJson(response.data);
          return getAddProductResponse;
        }
      } else {
        return GetAddProductModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetAddProductModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetAddProductModel()..errorResponse = errorResponse;
    } catch (error) {
      final errorResponse = handleError(error);
      return GetAddProductModel()..errorResponse = errorResponse;
    }
  }

  /// Save StockIn - Post API Integration
  Future<SaveStockInModel> postSaveStockInAPI(
      final String stockInPayloadJson) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("payload:$stockInPayloadJson");
    try {
      var data = stockInPayloadJson;
      debugPrint("data:$data");
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/stock',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      if (response.statusCode == 201 && response.data != null) {
        try {
          SaveStockInModel postGenerateOrderResponse =
              SaveStockInModel.fromJson(response.data);
          return postGenerateOrderResponse;
        } catch (e) {
          return SaveStockInModel()
            ..errorResponse = ErrorResponse(
              message: "Failed to parse response: $e",
            );
        }
      } else {
        return SaveStockInModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return SaveStockInModel()..errorResponse = errorResponse;
    } catch (error) {
      return SaveStockInModel()..errorResponse = handleError(error);
    }
  }

  /// handle Error Response
  static ErrorResponse handleError(Object error) {
    ErrorResponse errorResponse = ErrorResponse();
    Errors errorDescription = Errors();

    if (error is DioException) {
      DioException dioException = error;

      switch (dioException.type) {
        case DioExceptionType.cancel:
          errorDescription.code = "0";
          errorDescription.message = "Request Cancelled";
          errorResponse.statusCode = 0;
          break;

        case DioExceptionType.connectionTimeout:
          errorDescription.code = "522";
          errorDescription.message = "Connection Timeout";
          errorResponse.statusCode = 522;
          break;

        case DioExceptionType.sendTimeout:
          errorDescription.code = "408";
          errorDescription.message = "Send Timeout";
          errorResponse.statusCode = 408;
          break;

        case DioExceptionType.receiveTimeout:
          errorDescription.code = "408";
          errorDescription.message = "Receive Timeout";
          errorResponse.statusCode = 408;
          break;

        case DioExceptionType.badResponse:
          if (dioException.response != null) {
            final statusCode = dioException.response!.statusCode!;
            errorDescription.code = statusCode.toString();
            errorResponse.statusCode = statusCode;

            if (statusCode == 401) {
              try {
                final message = dioException.response!.data["message"] ??
                    dioException.response!.data["error"] ??
                    dioException.response!.data["errors"]?[0]?["message"];

                if (message != null &&
                    (message.toLowerCase().contains("token") ||
                        message.toLowerCase().contains("expired"))) {
                  errorDescription.message =
                      "Session expired. Please login again.";
                  errorResponse.message =
                      "Session expired. Please login again.";
                } else if (message != null &&
                    (message.toLowerCase().contains("invalid credentials") ||
                        message.toLowerCase().contains("unauthorized") ||
                        message.toLowerCase().contains("incorrect"))) {
                  errorDescription.message =
                      "Invalid credentials. Please try again.";
                  errorResponse.message =
                      "Invalid credentials. Please try again.";
                } else {
                  errorDescription.message = message;
                  errorResponse.message = message;
                }
              } catch (_) {
                errorDescription.message = "Unauthorized access";
                errorResponse.message = "Unauthorized access";
              }
            } else if (statusCode == 403) {
              errorDescription.message = "Access forbidden";
              errorResponse.message = "Access forbidden";
            } else if (statusCode == 404) {
              errorDescription.message = "Resource not found";
              errorResponse.message = "Resource not found";
            } else if (statusCode == 500) {
              errorDescription.message = "Internal Server Error";
              errorResponse.message = "Internal Server Error";
            } else if (statusCode >= 400 && statusCode < 500) {
              // Client errors - try to get API message
              try {
                final apiMessage = dioException.response!.data["message"] ??
                    dioException.response!.data["errors"]?[0]?["message"];
                errorDescription.message =
                    apiMessage ?? "Client error occurred";
                errorResponse.message = apiMessage ?? "Client error occurred";
              } catch (_) {
                errorDescription.message = "Client error occurred";
                errorResponse.message = "Client error occurred";
              }
            } else if (statusCode >= 500) {
              // Server errors
              errorDescription.message = "Server error occurred";
              errorResponse.message = "Server error occurred";
            } else {
              // Other status codes - fallback to API-provided message
              try {
                final message = dioException.response!.data["message"] ??
                    dioException.response!.data["errors"]?[0]?["message"];
                errorDescription.message = message ?? "Something went wrong";
                errorResponse.message = message ?? "Something went wrong";
              } catch (_) {
                errorDescription.message = "Unexpected error response";
                errorResponse.message = "Unexpected error response";
              }
            }
          } else {
            errorDescription.code = "500";
            errorDescription.message = "Internal Server Error";
            errorResponse.statusCode = 500;
            errorResponse.message = "Internal Server Error";
          }
          break;

        case DioExceptionType.unknown:
          errorDescription.code = "500";
          errorDescription.message = "Unknown error occurred";
          errorResponse.statusCode = 500;
          errorResponse.message = "Unknown error occurred";
          break;

        case DioExceptionType.badCertificate:
          errorDescription.code = "495";
          errorDescription.message = "Bad SSL Certificate";
          errorResponse.statusCode = 495;
          errorResponse.message = "Bad SSL Certificate";
          break;

        case DioExceptionType.connectionError:
          errorDescription.code = "500";
          errorDescription.message = "Connection error occurred";
          errorResponse.statusCode = 500;
          errorResponse.message = "Connection error occurred";
          break;
      }
    } else {
      errorDescription.code = "500";
      errorDescription.message = "An unexpected error occurred";
      errorResponse.statusCode = 500;
      errorResponse.message = "An unexpected error occurred";
    }

    errorResponse.errors = [errorDescription];
    return errorResponse;
  }
}
