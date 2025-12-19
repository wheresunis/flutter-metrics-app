import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<bool> saveSelectedMetrics(List<String> metricTitles) async {
    if (_preferences == null) await init();
    return await _preferences!.setStringList('selected_metrics', metricTitles);
  }

  static List<String> getSelectedMetrics() {
    if (_preferences == null) {
      throw Exception('LocalStorageService not initialized');
    }
    return _preferences!.getStringList('selected_metrics') ?? [];
  }

  static Future<bool> saveMetricsSettings(Map<String, dynamic> settings) async {
    if (_preferences == null) await init();
    return await _preferences!.setString('metrics_settings', settings.toString());
  }

  static String getMetricsSettings() {
    if (_preferences == null) {
      throw Exception('LocalStorageService not initialized');
    }
    return _preferences!.getString('metrics_settings') ?? '';
  }

  static Future<bool> clearAllData() async {
    if (_preferences == null) await init();
    return await _preferences!.clear();
  }

  static bool hasSavedMetrics() {
    if (_preferences == null) return false;
    return _preferences!.containsKey('selected_metrics');
  }
}