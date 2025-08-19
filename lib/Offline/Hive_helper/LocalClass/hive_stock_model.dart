import 'package:hive/hive.dart';
import 'package:simple/ModelClass/ShopDetails/getStockMaintanencesModel.dart';

part 'hive_stock_model.g.dart';

// Stock Maintenance Model
@HiveType(typeId: 10)
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

  factory HiveStockMaintenance.fromApiModel(GetStockMaintanencesModel model) {
    return HiveStockMaintenance(
      id: model.data?.id?.toString(),
      name: model.data?.name,
      stockMaintenance: model.data?.stockMaintenance,
      lastUpdated: DateTime.now(),
    );
  }

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
