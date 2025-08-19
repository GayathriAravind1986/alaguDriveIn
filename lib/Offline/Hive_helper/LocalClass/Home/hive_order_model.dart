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
  });
}
