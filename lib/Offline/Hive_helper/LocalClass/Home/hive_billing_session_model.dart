// import 'package:hive/hive.dart';
// import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_cart_model.dart';
//
// part 'hive_billing_session_model.g.dart';
//
// @HiveType(typeId: 5)
// class HiveBillingSession extends HiveObject {
//   @HiveField(0)
//   List<HiveCartItem>? items;
//
//   @HiveField(1)
//   bool? isDiscountApplied;
//
//   @HiveField(2)
//   double? subtotal;
//
//   @HiveField(3)
//   double? totalTax;
//
//   @HiveField(4)
//   double? total;
//
//   @HiveField(5)
//   double? totalDiscount;
//
//   @HiveField(6)
//   DateTime? lastUpdated;
//
//   HiveBillingSession({
//     this.items,
//     this.isDiscountApplied,
//     this.subtotal,
//     this.totalTax,
//     this.total,
//     this.totalDiscount,
//     this.lastUpdated,
//   });
// }
import 'package:hive/hive.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_cart_model.dart';

part 'hive_billing_session_model.g.dart';

@HiveType(typeId: 5)
class HiveBillingSession extends HiveObject {
  @HiveField(0)
  List<HiveCartItem>? items;

  @HiveField(1)
  bool? isDiscountApplied;

  @HiveField(2)
  double? subtotal;

  @HiveField(3)
  double? totalTax;

  @HiveField(4)
  double? total;

  @HiveField(5)
  double? totalDiscount;

  @HiveField(6)
  DateTime? lastUpdated;

  @HiveField(7)
  String? orderType; // New field for order type

  HiveBillingSession({
    this.items,
    this.isDiscountApplied,
    this.subtotal,
    this.totalTax,
    this.total,
    this.totalDiscount,
    this.lastUpdated,
    this.orderType,
  });

  /// Convert to Map for easy serialization
  Map<String, dynamic> toMap() {
    return {
      'items': items?.map((item) => item.toMap()).toList(),
      'isDiscountApplied': isDiscountApplied,
      'subtotal': subtotal,
      'totalTax': totalTax,
      'total': total,
      'totalDiscount': totalDiscount,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'orderType': orderType,
    };
  }

  /// Create from Map
  factory HiveBillingSession.fromMap(Map<String, dynamic> map) {
    return HiveBillingSession(
      items: (map['items'] as List?)
          ?.map((item) => HiveCartItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      isDiscountApplied: map['isDiscountApplied'] as bool?,
      subtotal: (map['subtotal'] as num?)?.toDouble(),
      totalTax: (map['totalTax'] as num?)?.toDouble(),
      total: (map['total'] as num?)?.toDouble(),
      totalDiscount: (map['totalDiscount'] as num?)?.toDouble(),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'] as String)
          : null,
      orderType: map['orderType'] as String?,
    );
  }

  /// Copy with method for easy updates
  HiveBillingSession copyWith({
    List<HiveCartItem>? items,
    bool? isDiscountApplied,
    double? subtotal,
    double? totalTax,
    double? total,
    double? totalDiscount,
    DateTime? lastUpdated,
    String? orderType,
  }) {
    return HiveBillingSession(
      items: items ?? this.items,
      isDiscountApplied: isDiscountApplied ?? this.isDiscountApplied,
      subtotal: subtotal ?? this.subtotal,
      totalTax: totalTax ?? this.totalTax,
      total: total ?? this.total,
      totalDiscount: totalDiscount ?? this.totalDiscount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      orderType: orderType ?? this.orderType,
    );
  }

  @override
  String toString() {
    return 'HiveBillingSession(items: ${items?.length}, orderType: $orderType, subtotal: $subtotal, total: $total, lastUpdated: $lastUpdated)';
  }
}
