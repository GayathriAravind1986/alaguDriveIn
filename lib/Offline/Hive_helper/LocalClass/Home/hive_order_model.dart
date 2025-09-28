import 'package:hive/hive.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_cart_model.dart';

part 'hive_order_model.g.dart';

@HiveType(typeId: 4)
class HiveOrder {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? orderPayloadJson;

  @HiveField(2)
  final String? orderStatus;

  @HiveField(3)
  final String? orderType;

  @HiveField(4)
  final String? tableId;

  @HiveField(5)
  final double? total;

  @HiveField(6)
  final DateTime? createdAt;

  @HiveField(7)
  bool? isSynced;

  @HiveField(8)
  final List<HiveCartItem>? items;

  @HiveField(9)
  final String? syncAction;

  @HiveField(10)
  final String? existingOrderId;

  @HiveField(11)
  final String? businessName;

  @HiveField(12)
  final String? address;

  @HiveField(13)
  final String? gst;

  @HiveField(14)
  final double? taxPercent;

  @HiveField(15)
  final String? paymentMethod;

  @HiveField(16)
  final String? phone;

  @HiveField(17)
  final String? waiterName;

  // New fields for receipt generation
  @HiveField(18)
  final String? orderNumber;

  @HiveField(19)
  final double? subtotal;

  @HiveField(20)
  final double? taxAmount;

  @HiveField(21)
  final double? discountAmount;

  @HiveField(22)
  final List<Map<String, dynamic>>? kotItems;

  @HiveField(23)
  final List<Map<String, dynamic>>? finalTaxes;

  @HiveField(24)
  final String? tableName;

  HiveOrder({
    this.id,
    this.orderPayloadJson,
    this.orderStatus,
    this.orderType,
    this.tableId,
    this.total,
    this.createdAt,
    this.isSynced = false,
    this.items,
    this.syncAction = 'CREATE',
    this.existingOrderId,
    this.businessName,
    this.address,
    this.gst,
    this.taxPercent,
    this.paymentMethod,
    this.phone,
    this.waiterName,
    this.orderNumber,
    this.subtotal,
    this.taxAmount,
    this.discountAmount,
    this.kotItems,
    this.finalTaxes,
    this.tableName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderPayloadJson': orderPayloadJson,
      'orderStatus': orderStatus,
      'orderType': orderType,
      'tableId': tableId,
      'total': total,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'isSynced': isSynced,
      'items': items?.map((item) => item.toMap()).toList(),
      'syncAction': syncAction,
      'existingOrderId': existingOrderId,
      'businessName': businessName,
      'address': address,
      'gst': gst,
      'taxPercent': taxPercent,
      'paymentMethod': paymentMethod,
      'phone': phone,
      'waiterName': waiterName,
      'orderNumber': orderNumber,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'kotItems': kotItems,
      'finalTaxes': finalTaxes,
      'tableName': tableName,
    };
  }

  factory HiveOrder.fromMap(Map<String, dynamic> map) {
    return HiveOrder(
      id: map['id'],
      orderPayloadJson: map['orderPayloadJson'],
      orderStatus: map['orderStatus'],
      orderType: map['orderType'],
      tableId: map['tableId'],
      total: map['total']?.toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
      isSynced: map['isSynced'],
      items: map['items'] != null
          ? (map['items'] as List).map((item) => HiveCartItem.fromMap(item)).toList()
          : null,
      syncAction: map['syncAction'],
      existingOrderId: map['existingOrderId'],
      businessName: map['businessName'],
      address: map['address'],
      gst: map['gst'],
      taxPercent: map['taxPercent']?.toDouble(),
      paymentMethod: map['paymentMethod'],
      phone: map['phone'],
      waiterName: map['waiterName'],
      orderNumber: map['orderNumber'],
      subtotal: map['subtotal']?.toDouble(),
      taxAmount: map['taxAmount']?.toDouble(),
      discountAmount: map['discountAmount']?.toDouble(),
      kotItems: map['kotItems'] != null
          ? List<Map<String, dynamic>>.from(map['kotItems'])
          : null,
      finalTaxes: map['finalTaxes'] != null
          ? List<Map<String, dynamic>>.from(map['finalTaxes'])
          : null,
      tableName: map['tableName'],
    );
  }
}