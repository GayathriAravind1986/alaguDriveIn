import 'package:hive/hive.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_cart_model.dart';

part 'hive_order_model.g.dart';

@HiveType(typeId: 4)
class HiveOrder extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? orderPayloadJson;

  @HiveField(2)
  String? orderStatus; // 'PENDING_SYNC', 'WAITLIST', 'COMPLETED'

  @HiveField(3)
  String? orderType; // 'DINE-IN', 'TAKE-AWAY'

  @HiveField(4)
  String? tableId;

  @HiveField(5)
  double? total;

  @HiveField(6)
  DateTime? createdAt;

  @HiveField(7)
  bool? isSynced;

  @HiveField(8)
  List<HiveCartItem>? items;

  @HiveField(9)
  String? syncAction; // 'CREATE', 'UPDATE'

  @HiveField(10)
  String? existingOrderId; // For updates

  // Extra API fields
  @HiveField(11)
  String? businessName;

  @HiveField(12)
  String? address;

  @HiveField(13)
  String? gst;

  @HiveField(14)
  double? taxPercent;

  @HiveField(15)
  String? paymentMethod;

  @HiveField(16)
  String? phone;

  @HiveField(17)
  String? waiterName;

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
  });

  /// Convert API map -> HiveOrder safely
  factory HiveOrder.fromMap(Map<String, dynamic> map) {
    return HiveOrder(
      id: map["_id"]?.toString(),
      orderPayloadJson: map["orderPayloadJson"]?.toString(),
      orderStatus: map["orderStatus"]?.toString(),
      orderType: map["orderType"]?.toString(),
      tableId: map["tableId"]?.toString(),
      total: map["total"] != null
          ? (map["total"] is int
          ? (map["total"] as int).toDouble()
          : map["total"] as double)
          : 0.0,
      createdAt: map["createdAt"] != null
          ? DateTime.tryParse(map["createdAt"].toString())
          : DateTime.now(),
      isSynced: map["isSynced"] ?? false,
      items: (map["items"] as List<dynamic>?)
          ?.map((e) => HiveCartItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      syncAction: map["syncAction"]?.toString() ?? 'CREATE',
      existingOrderId: map["existingOrderId"]?.toString(),
      businessName: map["businessName"]?.toString(),
      address: map["address"]?.toString(),
      gst: map["gst"]?.toString(),
      taxPercent: map["taxPercent"] != null
          ? double.tryParse(map["taxPercent"].toString())
          : 0.0,
      paymentMethod: map["paymentMethod"]?.toString(),
      phone: map["phone"]?.toString(),
      waiterName: map["waiterName"]?.toString(),
    );
  }

  /// Convert HiveOrder -> Map (for API payloads)
  Map<String, dynamic> toMap() {
    return {
      "_id": id,
      "orderPayloadJson": orderPayloadJson,
      "orderStatus": orderStatus,
      "orderType": orderType,
      "tableId": tableId,
      "total": total,
      "createdAt": createdAt?.toIso8601String(),
      "isSynced": isSynced,
      "items": items?.map((e) => e.toMap()).toList(),
      "syncAction": syncAction,
      "existingOrderId": existingOrderId,
      "businessName": businessName,
      "address": address,
      "gst": gst,
      "taxPercent": taxPercent,
      "paymentMethod": paymentMethod,
      "phone": phone,
      "waiterName": waiterName,
    };
  }
}
