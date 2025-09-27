import 'package:hive/hive.dart';
import 'package:simple/ModelClass/ShopDetails/getStockMaintanencesModel.dart';

part 'hive_stock_model.g.dart';

@HiveType(typeId: 40)
class HiveStockMaintenance extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  bool? stockMaintenance;

  @HiveField(3)
  DateTime? lastUpdated;

  HiveStockMaintenance({
    this.id,
    this.name,
    this.stockMaintenance,
    this.lastUpdated,
  });

  /// ✅ Convert from API model to Hive model
  factory HiveStockMaintenance.fromApiModel(GetStockMaintanencesModel model) {
    return HiveStockMaintenance(
      id: model.data?.id?.toString(),
      name: model.data?.name,
      stockMaintenance: model.data?.stockMaintenance,
      lastUpdated: DateTime.now(),
    );
  }

  /// ✅ Convert back from Hive model to API model
  GetStockMaintanencesModel toApiModel() {
    return GetStockMaintanencesModel(
      success: true,
      data: Data(
        id: id,
        name: name,
        stockMaintenance: stockMaintenance,
      ),
      errorResponse: null,
    );
  }
}
