import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initHive() async {
  final dir = await getApplicationDocumentsDirectory();
  // final dir = await getApplicationSupportDirectory();
  Hive.init(dir.path);
  print('Hive initialized at: ${dir.path}');
}
