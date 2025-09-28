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

  // ✅ Keep fields nullable for compatibility
  @HiveField(6)
  String? userName;

  @HiveField(7)
  String? businessName;

  @HiveField(8)
  String? address;

  @HiveField(9)
  String? phone;

  @HiveField(10)
  String? location;

  @HiveField(11)
  String? fromDate;

  @HiveField(12)
  String? toDate;

  @HiveField(13)
  String? gstNumber;

  @HiveField(14)
  String? currencySymbol;

  @HiveField(15)
  String? printType;

  HiveReportModel({
    required this.productName,
    required this.quantity,
    required this.amount,
    required this.tableNo,
    required this.waiterId,
    required this.date,
    this.userName,
    this.businessName,
    this.address,
    this.phone,
    this.location,
    this.fromDate,
    this.toDate,
    this.gstNumber,
    this.currencySymbol,
    this.printType,
  });

  /// ✅ Convert API JSON → Hive with ALL business details
  factory HiveReportModel.fromJson(
      Map<String, dynamic> json, {
        String? userName,
        String? businessName,
        String? address,
        String? phone,
        String? location,
        String? fromDate,
        String? toDate,
        String? gstNumber,
        String? currencySymbol,
        String? printType,
      }) {
    return HiveReportModel(
      productName: json['productName'] ?? '',
      quantity: json['totalQty'] ?? 0,
      amount: (json['totalAmount'] ?? 0).toDouble(),
      tableNo: json['tableNo']?.toString() ?? '',
      waiterId: json['waiter']?.toString() ?? '',
      date: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      userName: userName,
      businessName: businessName,
      address: address,
      phone: phone,
      location: location,
      fromDate: fromDate,
      toDate: toDate,
      gstNumber: gstNumber,
      currencySymbol: currencySymbol,
      printType: printType,
    );
  }

  // ✅ Add getters with default values for non-null access
  String get userNameSafe => userName ?? 'Counter1';
  String get businessNameSafe => businessName ?? 'Alagu Drive In';
  String get addressSafe => address ?? 'Tenkasi main road, Alangualam, Tamil Nadu 627851';
  String get phoneSafe => phone ?? '+91 0000000000';
  String get locationSafe => location ?? 'ALANGULAM';
  String get fromDateSafe => fromDate ?? '';
  String get toDateSafe => toDate ?? '';
  String get currencySymbolSafe => currencySymbol ?? '₹';

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'totalQty': quantity,
    'totalAmount': amount,
    'tableNo': tableNo,
    'waiter': waiterId,
    'date': date.toIso8601String(),
    'userName': userName,
    'businessName': businessName,
    'address': address,
    'phone': phone,
    'location': location,
    'fromDate': fromDate,
    'toDate': toDate,
    'gstNumber': gstNumber,
    'currencySymbol': currencySymbol,
    'printType': printType,
  };
}