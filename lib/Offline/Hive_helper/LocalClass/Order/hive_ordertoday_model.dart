import 'package:hive/hive.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart' as api;

part 'hive_ordertoday_model.g.dart';

@HiveType(typeId: 10)
class HiveGetOrderListTodayModel extends HiveObject {
  @HiveField(0)
  bool? success;

  @HiveField(1)
  List<HiveOrderData>? data;

  @HiveField(2)
  int? total;

  HiveGetOrderListTodayModel({this.success, this.data, this.total});

  /// ✅ API → Hive
  factory HiveGetOrderListTodayModel.fromApi(api.GetOrderListTodayModel model) {
    return HiveGetOrderListTodayModel(
      success: model.success,
      total: model.total!.toInt(),
      data: model.data?.map((e) => HiveOrderData.fromApi(e)).toList(),
    );
  }

  /// ✅ Hive → API
  api.GetOrderListTodayModel toApi() {
    return api.GetOrderListTodayModel(
      success: success,
      total: total,
      data: data?.map((e) => e.toApi()).toList(),
    );
  }

  /// ✅ JSON → Hive
  factory HiveGetOrderListTodayModel.fromJson(Map<String, dynamic> json) {
    return HiveGetOrderListTodayModel(
      success: json['success'],
      total: json['total'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => HiveOrderData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// ✅ Hive → JSON
  Map<String, dynamic> toJson() => {
    'success': success,
    'total': total,
    'data': data?.map((e) => e.toJson()).toList(),
  };
}

@HiveType(typeId: 11)
class HiveOrderData extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? orderNumber;

  @HiveField(2)
  double? total;

  @HiveField(3)
  String? tableNo;

  @HiveField(4)
  String? orderType;

  @HiveField(5)
  String? orderStatus;

  @HiveField(6)
  String? createdAt;

  @HiveField(7)
  List<HivePayment>? payments;

  @HiveField(8)
  String? tableName;

  HiveOrderData({
    this.id,
    this.orderNumber,
    this.total,
    this.tableNo,
    this.orderType,
    this.orderStatus,
    this.createdAt,
    this.payments,
    this.tableName,
  });

  /// ✅ API → Hive
  factory HiveOrderData.fromApi(api.Data model) {
    return HiveOrderData(
      id: model.id,
      orderNumber: model.orderNumber,
      total: model.total!.toDouble(),
      tableNo: model.tableNo,
      orderType: model.orderType,
      orderStatus: model.orderStatus,
      createdAt: model.createdAt,
      tableName: model.tableName,
      payments: model.payments?.map((e) => HivePayment.fromApi(e)).toList(),
    );
  }

  /// ✅ Hive → API
  api.Data toApi() {
    return api.Data(
      id: id,
      orderNumber: orderNumber,
      total: total,
      tableNo: tableNo,
      orderType: orderType,
      orderStatus: orderStatus,
      createdAt: createdAt,
      tableName: tableName,
      payments: payments?.map((e) => e.toApi()).toList(),
    );
  }

  /// ✅ JSON → Hive
  factory HiveOrderData.fromJson(Map<String, dynamic> json) {
    return HiveOrderData(
      id: json['_id'],
      orderNumber: json['orderNumber'],
      total: (json['total'] as num?)?.toDouble(),
      tableNo: json['tableNo'],
      orderType: json['orderType'],
      orderStatus: json['orderStatus'],
      createdAt: json['createdAt'],
      tableName: json['tableName'],
      payments: (json['payments'] as List<dynamic>?)
          ?.map((e) => HivePayment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// ✅ Hive → JSON
  Map<String, dynamic> toJson() => {
    '_id': id,
    'orderNumber': orderNumber,
    'total': total,
    'tableNo': tableNo,
    'orderType': orderType,
    'orderStatus': orderStatus,
    'createdAt': createdAt,
    'tableName': tableName,
    'payments': payments?.map((e) => e.toJson()).toList(),
  };
}

@HiveType(typeId: 12)
class HivePayment extends HiveObject {
  @HiveField(0)
  String? paymentMethod;

  @HiveField(1)
  double? amount;

  @HiveField(2)
  String? status;

  HivePayment({this.paymentMethod, this.amount, this.status});

  /// ✅ API → Hive
  factory HivePayment.fromApi(api.Payments model) {
    return HivePayment(
      paymentMethod: model.paymentMethod,
      amount:model.amount!.toDouble(),
      status: model.status,
    );
  }

  /// ✅ Hive → API
  api.Payments toApi() {
    return api.Payments(
      paymentMethod: paymentMethod,
      amount: amount,
      status: status,
    );
  }

  /// ✅ JSON → Hive
  factory HivePayment.fromJson(Map<String, dynamic> json) {
    return HivePayment(
      paymentMethod: json['paymentMethod'],
      amount: (json['amount'] as num?)?.toDouble(),
      status: json['status'],
    );
  }

  /// ✅ Hive → JSON
  Map<String, dynamic> toJson() => {
    'paymentMethod': paymentMethod,
    'amount': amount,
    'status': status,
  };
}
