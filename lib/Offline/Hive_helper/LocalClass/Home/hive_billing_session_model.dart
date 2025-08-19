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

  HiveBillingSession({
    this.items,
    this.isDiscountApplied,
    this.subtotal,
    this.totalTax,
    this.total,
    this.totalDiscount,
    this.lastUpdated,
  });
}
