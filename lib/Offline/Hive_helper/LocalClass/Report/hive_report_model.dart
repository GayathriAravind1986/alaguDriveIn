import 'package:hive/hive.dart';

part 'hive_report_model.g.dart';

@HiveType(typeId: 17)
class HiveReportModel extends HiveObject {
  @HiveField(0)
  String productName;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String tableNo;

  @HiveField(4)
  String waiterId;

  @HiveField(5)
  DateTime date;

  HiveReportModel({
    required this.productName,
    required this.quantity,
    required this.amount,
    required this.tableNo,
    required this.waiterId,
    required this.date,
  });

  /// ✅ Match API response keys directly
  factory HiveReportModel.fromJson(Map<String, dynamic> json) => HiveReportModel(
    productName: json['productName'] ?? '',
    quantity: json['totalQty'] ?? 0,
    amount: (json['totalAmount'] ?? 0).toDouble(),
    tableNo: json['tableNo'] ?? '',
    waiterId: json['waiter'] ?? '',
    date: DateTime.now(), // API doesn’t send date, so use current
  );

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'totalQty': quantity,
    'totalAmount': amount,
    'tableNo': tableNo,
    'waiter': waiterId,
    'date': date.toIso8601String(),
  };

}
