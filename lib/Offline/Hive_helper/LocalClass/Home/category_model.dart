import 'package:hive/hive.dart';

import '../../../../ModelClass/HomeScreen/Category&Product/Get_category_model.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
class HiveCategory extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String image;

  HiveCategory({
    required this.id,
    required this.name,
    required this.image,
  });

  factory HiveCategory.fromApiData(Data data) {
    return HiveCategory(
      id: data.id ?? '',
      name: data.name ?? '',
      image: data.image ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}
