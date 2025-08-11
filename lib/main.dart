import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:simple/Bloc/observer/observer.dart';
import 'package:simple/Bloc/theme_cubit.dart';
import 'package:simple/Offline/Database_helper/DB_Service.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/category_model.dart';
import 'package:simple/Offline/Network_status/NetworkStatusService.dart';
import 'package:simple/Reusable/color.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:simple/UI/SplashScreen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // DatabaseFactoryHelper.init();
  await Hive.initFlutter();
  Hive.registerAdapter(HiveCategoryAdapter());
  await Hive.openBox<HiveCategory>('categories');
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
