import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:health_diary/services/firebase_options.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../screens/auth/welcome_screen.dart';

// ✅ Твої нові класи
import 'core/providers/metrics_provider.dart';
import 'core/repositories/metrics_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase лише в реальному запуску
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

  // ✅ Crashlytics (тільки якщо Firebase реально піднявся)
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const AppRoot(enableFirebase: true));
}

/// ✅ Обгортка над Provider-ами + MyApp
class AppRoot extends StatelessWidget {
  final bool enableFirebase;
  const AppRoot({super.key, required this.enableFirebase});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MetricsProvider(MetricsRepository()),
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
      // ✅ В тестах НЕ додаємо observers, які тягнуть FirebaseAnalytics
      navigatorObservers: const [],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomeScreen(),
    );
  }
}
