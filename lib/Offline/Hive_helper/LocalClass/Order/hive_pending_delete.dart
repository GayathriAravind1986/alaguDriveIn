import 'package:hive/hive.dart';

part 'hive_pending_delete.g.dart';

@HiveType(typeId: 65)
class PendingDelete extends HiveObject {
  @HiveField(0)
  String orderId;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  String status; // 'pending', 'failed', 'completed'

  @HiveField(3)
  int retryCount;

  PendingDelete({
    required this.orderId,
    required this.timestamp,
    this.status = 'pending',
    this.retryCount = 0,
  });

  @override
  String toString() {
    return 'PendingDelete{orderId: $orderId, timestamp: $timestamp, status: $status, retryCount: $retryCount}';
  }
}
