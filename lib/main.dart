import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:health_diary/services/firebase_options.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../screens/auth/welcome_screen.dart';
import 'core/providers/metrics_provider.dart';
import 'core/repositories/metrics_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const AppRoot(enableFirebase: true));
}
class AppRoot extends StatelessWidget {
  final bool enableFirebase;
  const AppRoot({super.key, required this.enableFirebase});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MetricsProvider(),
        ),
      ],
      child: MyApp(enableFirebase: enableFirebase),
    );
  }
}

class MyApp extends StatelessWidget {
  final bool enableFirebase;

  const MyApp({super.key, this.enableFirebase = true});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,

      navigatorObservers: const [],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomeScreen(),
    );
  }
}
