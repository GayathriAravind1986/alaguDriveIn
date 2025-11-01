import 'dart:io' show Platform;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/Bloc/observer/observer.dart';
import 'package:simple/Bloc/theme_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:simple/Offline/HiveIntializer/hive_init.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Order/hive_pending_delete.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Report/hive_report_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/category_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_billing_session_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_cart_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_order_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_selected_addons_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_stock_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_table_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_user_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_waiter_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/product_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Stock/hive_location_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Stock/hive_pending_stock_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Stock/hive_supplier_model.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/Stock/hive_serive_stock.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive-pending_delete_service.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service.dart';
import 'package:simple/Offline/Network_status/NetworkStatusService.dart';
import 'package:simple/Reusable/color.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:simple/UI/SplashScreen/splash_screen.dart';
import 'Offline/Hive_helper/localStorageHelper/connection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Hive.initFlutter();
  await initHive();

  try {
    Hive.registerAdapter(HiveCategoryAdapter());
    Hive.registerAdapter(HiveProductAdapter());
    Hive.registerAdapter(HiveAddonAdapter());
    Hive.registerAdapter(HiveCartItemAdapter());
    Hive.registerAdapter(HiveSelectedAddonAdapter());
    Hive.registerAdapter(HiveOrderAdapter());
    Hive.registerAdapter(HiveBillingSessionAdapter());
    Hive.registerAdapter(HiveStockMaintenanceAdapter());
    Hive.registerAdapter(HiveTableAdapter());
    Hive.registerAdapter(PendingDeleteAdapter());
    Hive.registerAdapter(HiveLocationAdapter());
    Hive.registerAdapter(HiveSupplierAdapter());
    Hive.registerAdapter(HiveWaiterAdapter());
    Hive.registerAdapter(HiveUserAdapter());
    Hive.registerAdapter(HiveReportModelAdapter());
    Hive.registerAdapter(HivePendingStockAdapter());
  } catch (e) {
    debugPrint("Hive adapter registration error: $e");
  }

  try {
    await Hive.openBox('appConfigBox');
    await Hive.openBox<HiveCategory>('categories');
    await Hive.openBox<HiveCartItem>('cart_items');
    await Hive.openBox<HiveOrder>('orders');
    await Hive.openBox<HiveBillingSession>('billing_session');
    await Hive.openBox<HiveStockMaintenance>('stock_maintenance');
    await Hive.openBox<HiveTable>('tables');
    await Hive.openBox<HiveLocation>('location');
    await Hive.openBox<HiveSupplier>('suppliers');
    await Hive.openBox<HiveProduct>('products_box');
    await Hive.openBox('app_state');
    await Hive.openBox<HiveWaiter>('waiters_box');
    await Hive.openBox<HiveUser>('users_box');
    await Hive.openBox<HivePendingStock>('pending_stock');
  } catch (e) {
    debugPrint("Hive openBox error: $e");
  }
  final apiProvider = ApiProvider();
  initConnectivityListener(apiProvider);
  await HiveServicedelete.initDeleteBox();
  Connectivity().onConnectivityChanged.listen((result) async {
    if (result != ConnectivityResult.none) {
      await HiveService.syncPendingOrders(ApiProvider());
      await HiveStockService.syncPendingStock(ApiProvider());
      await HiveServicedelete.syncPendingDeletes(ApiProvider());
    }
  });

  await SystemChrome.setPreferredOrientations([
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
