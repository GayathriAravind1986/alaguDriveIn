import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:simple/Bloc/observer/observer.dart';
import 'package:simple/Bloc/theme_cubit.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/category_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_billing_session_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_cart_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_order_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_selected_addons_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_stock_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_table_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/product_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Stock/hive_location_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Stock/hive_product_stock.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Stock/hive_supplier_model.dart';
import 'package:simple/Offline/Network_status/NetworkStatusService.dart';
import 'package:simple/Reusable/color.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:simple/UI/SplashScreen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  try {
    Hive.registerAdapter(HiveCategoryAdapter());
    Hive.registerAdapter(HiveProductAdapter());
    Hive.registerAdapter(HiveCartItemAdapter());
    Hive.registerAdapter(HiveSelectedAddonAdapter());
    Hive.registerAdapter(HiveOrderAdapter());
    Hive.registerAdapter(HiveBillingSessionAdapter());
    Hive.registerAdapter(HiveStockMaintenanceAdapter());
    Hive.registerAdapter(HiveTableAdapter());
    Hive.registerAdapter(HiveLocationAdapter());
    Hive.registerAdapter(HiveSupplierAdapter());
    Hive.registerAdapter(HiveProductStockAdapter());
  } catch (e) {
    debugPrint("Hive adapter registration error: $e");
  }
  // Open all boxes
  try {
    await Hive.openBox<HiveCategory>('categories');
    await Hive.openBox<HiveCartItem>('cart_items');
    await Hive.openBox<HiveOrder>('orders');
    await Hive.openBox<HiveBillingSession>('billing_session');
    await Hive.openBox<HiveStockMaintenance>('stock_maintenance');
    await Hive.openBox<HiveTable>('tables');
    await Hive.openBox<HiveLocation>('location');
    await Hive.openBox<HiveSupplier>('suppliers');
    await Hive.openBox<HiveProductStock>('products');
    await Hive.openBox('app_state');
  } catch (e) {
    debugPrint("Hive openBox error: $e");
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Bloc.observer = AppBlocObserver();
  await NetworkManager().initialize();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (_, theme) {
        return OverlaySupport.global(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Alagu Drive In',
            theme: ThemeData(
              primaryColor: appPrimaryColor,
              unselectedWidgetColor: appPrimaryColor,
              fontFamily: "Poppins",
            ),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: child!,
                ),
              );
            },
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
