import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:netflix/screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open boxes for your services
  try {
    await Hive.openBox('myListBox'); // For MyListService
    await Hive.openBox('seriesFavoritesBox'); // For SeriesFavoritesService
  } catch (e) {
    debugPrint('Error opening Hive boxes: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    DevicePreview(
      backgroundColor: Colors.grey[500],
      enabled: !kReleaseMode && kIsWeb,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        useInheritedMediaQuery: true,
        debugShowCheckedModeBanner: false,
        title: 'Flutflix',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.red,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        home: const SplashScreen(),
      ),
    );
  }
}
