import 'package:hive/hive.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart'
    as category;
import 'package:simple/Offline/Hive_helper/LocalClass/Home/category_model.dart';

Future<void> saveCategoriesToHive(List<category.Data> categories) async {
  final box = await Hive.openBox<HiveCategory>('categories');
  print('Hive box length: ${box.length}');
  await box.clear();
  await box.addAll(
    categories.map((cat) => HiveCategory.fromApiData(cat)).toList(),
  );
}

Future<List<HiveCategory>> loadCategoriesFromHive() async {
  final box = await Hive.openBox<HiveCategory>('categories');
  print('Hive box length load: ${box.length}');
  return box.values.toList();
}
