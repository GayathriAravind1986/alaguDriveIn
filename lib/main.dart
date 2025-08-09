import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Bloc/observer/observer.dart';
import 'package:simple/Bloc/theme_cubit.dart';
import 'package:simple/Reusable/color.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:simple/UI/SplashScreen/splash_screen.dart';
import 'package:workmanager/workmanager.dart';

const syncTask = "syncDataTask";

// Background task entry point
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final now = DateTime.now();
    debugPrint("✅ Background task [$task] executed at $now");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("lastRunTime", now.toString());

    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Bloc.observer = AppBlocObserver();
  await Hive.initFlutter();
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  // Register periodic task
  await Workmanager().registerPeriodicTask(
    "offlineDataSync",
    syncTask,
    frequency: const Duration(seconds: 10),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
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
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(builder: (_, theme) {
      return OverlaySupport.global(
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Alagu Drive In',
            theme: ThemeData(
              primaryColor: appPrimaryColor,
              unselectedWidgetColor: appPrimaryColor,
              fontFamily: "Poppins",
            ),
            // darkTheme: ThemeData.light(),
            // themeMode: ThemeMode.light,
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
            home: const SplashScreen()),
      );
    });
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
