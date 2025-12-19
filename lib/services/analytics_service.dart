import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logLogin({String? method}) async {
    await _analytics.logLogin(loginMethod: method); 
    
    await _analytics.logEvent(
      name: 'login',
      parameters: {
        'method': method ?? 'unknown', 
      },
    );
  }

  static Future<void> logSignUp({String? method}) async {
    final String signUpMethodValue = method ?? 'unknown';
    
    await _analytics.logSignUp(signUpMethod: signUpMethodValue); 
    
    await _analytics.logEvent(
      name: 'sign_up',
      parameters: {
        'method': signUpMethodValue,
      },
    );
  }

  static Future<void> logScreenView(String screenName) async {
    await _analytics.logEvent(
      name: 'screen_view',
      parameters: {
        'screen_name': screenName,
      },
    );
  }

  static Future<void> logButtonTap(String buttonName) async {
    await _analytics.logEvent(
      name: 'button_tap',
      parameters: {
        'button_name': buttonName,
      },
    );
  }

  static Future<void> setUserProperties(String? userId) async {
    if (userId != null && userId != 'unknown') {
      await _analytics.setUserId(id: userId); 
    } else {
      await _analytics.setUserId(id: null);
    }
    await _analytics.setUserProperty(name: 'user_type', value: 'registered'); 
  }


  static Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    if (parameters == null) {
      await _analytics.logEvent(name: name);
      return;
    }

    final Map<String, Object> filteredParameters = Map.fromEntries(
      parameters.entries
          .where((e) => e.value != null) 
          .map((e) => MapEntry(e.key, e.value as Object)), 
    );

    await _analytics.logEvent(
      name: name,
      parameters: filteredParameters,
    );
  }
}