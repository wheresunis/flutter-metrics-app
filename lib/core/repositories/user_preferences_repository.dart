import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/metric_model.dart';

class UserPreferencesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _preferencesCollection = 'user_preferences';

  // ========== CREATE / UPDATE ==========
  
  /// Збереження або оновлення налаштувань користувача
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    try {
      print('[UserPrefsRepo] Saving user preferences for userId: ${preferences.userId}');
      print('[UserPrefsRepo] Preferences data: selectedMetrics=${preferences.selectedMetrics}, metricSettings=${preferences.metricSettings}');
      
      await _firestore
          .collection(_preferencesCollection)
          .doc(preferences.userId)
          .set(preferences.toFirestore(), SetOptions(merge: true));
      
      print('[UserPrefsRepo] ✓ Successfully saved preferences to Firestore');
    } catch (e, stackTrace) {
      print('[UserPrefsRepo] ✗ Error saving preferences: $e');
      print('[UserPrefsRepo] Stack trace: $stackTrace');
      throw Exception('Failed to save user preferences: $e');
    }
  }

  /// Оновлення списку обраних метрик
  Future<void> updateSelectedMetrics(String userId, List<String> selectedMetrics) async {
    try {
      print('[UserPrefsRepo] Updating selected metrics for userId: $userId');
      print('[UserPrefsRepo] Selected metrics to save: $selectedMetrics');
      
      await _firestore
          .collection(_preferencesCollection)
          .doc(userId)
          .set({
        'selectedMetrics': selectedMetrics,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
      
      print('[UserPrefsRepo] ✓ Successfully updated selected metrics in Firestore');
    } catch (e, stackTrace) {
      print('[UserPrefsRepo] ✗ Error updating selected metrics: $e');
      print('[UserPrefsRepo] Stack trace: $stackTrace');
      throw Exception('Failed to update selected metrics: $e');
    }
  }

  /// Оновлення налаштувань конкретної метрики
  Future<void> updateMetricSettings(
    String userId,
    String metricType,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _firestore
          .collection(_preferencesCollection)
          .doc(userId)
          .set({
        'metricSettings.$metricType': settings,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update metric settings: $e');
    }
  }

  // ========== READ ==========
  
  /// Отримання налаштувань користувача
  Future<UserPreferences?> getUserPreferences(String userId) async {
    try {
      print('[UserPrefsRepo] Getting preferences for userId: $userId from collection: $_preferencesCollection');
      
      DocumentSnapshot doc = await _firestore
          .collection(_preferencesCollection)
          .doc(userId)
          .get();

      print('[UserPrefsRepo] Document exists: ${doc.exists}');
      
      if (doc.exists) {
        print('[UserPrefsRepo] Document data: ${doc.data()}');
        final prefs = UserPreferences.fromFirestore(doc);
        print('[UserPrefsRepo] Parsed preferences: selectedMetrics=${prefs.selectedMetrics}');
        return prefs;
      }
      
      print('[UserPrefsRepo] No document found for userId: $userId');
      return null;
    } catch (e, stackTrace) {
      print('[UserPrefsRepo] Error getting preferences: $e');
      print('[UserPrefsRepo] Stack trace: $stackTrace');
      throw Exception('Failed to get user preferences: $e');
    }
  }

  /// Stream налаштувань користувача (для real-time оновлень)
  Stream<UserPreferences?> streamUserPreferences(String userId) {
    print('[UserPrefsRepo] Setting up preferences stream for userId: $userId');
    
    return _firestore
        .collection(_preferencesCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      print('[UserPrefsRepo] Stream event - Document exists: ${doc.exists}');
      
      if (doc.exists) {
        print('[UserPrefsRepo] Stream data: ${doc.data()}');
        final prefs = UserPreferences.fromFirestore(doc);
        print('[UserPrefsRepo] Stream parsed preferences: selectedMetrics=${prefs.selectedMetrics}');
        return prefs;
      }
      
      print('[UserPrefsRepo] Stream - No document found');
      return null;
    });
  }

  // ========== DELETE ==========
  
  /// Видалення налаштувань користувача
  Future<void> deleteUserPreferences(String userId) async {
    try {
      await _firestore
          .collection(_preferencesCollection)
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user preferences: $e');
    }
  }

  // ========== HELPER METHODS ==========
  
  /// Створення початкових налаштувань для нового користувача
  Future<void> createDefaultPreferences(String userId) async {
    try {
      print('[UserPrefsRepo] Creating default preferences for userId: $userId');
      
      final defaultPreferences = UserPreferences(
        userId: userId,
        selectedMetrics: ['Mood', 'Steps'], // Обов'язкові метрики
        metricSettings: {
          'waterIntake': {'goalMl': 2000},
          'sleep': {'targetHours': 8},
          'steps': {'goalSteps': 10000},
        },
        updatedAt: DateTime.now(),
      );

      await saveUserPreferences(defaultPreferences);
      print('[UserPrefsRepo] ✓ Default preferences created with selectedMetrics: ${defaultPreferences.selectedMetrics}');
    } catch (e, stackTrace) {
      print('[UserPrefsRepo] ✗ Error creating default preferences: $e');
      print('[UserPrefsRepo] Stack trace: $stackTrace');
      throw Exception('Failed to create default preferences: $e');
    }
  }

  /// Перевірка чи існують налаштування користувача
  Future<bool> preferencesExist(String userId) async {
    try {
      print('[UserPrefsRepo] Checking if preferences exist for userId: $userId');
      
      DocumentSnapshot doc = await _firestore
          .collection(_preferencesCollection)
          .doc(userId)
          .get();
      
      final exists = doc.exists;
      print('[UserPrefsRepo] Preferences exist: $exists');
      return exists;
    } catch (e, stackTrace) {
      print('[UserPrefsRepo] ✗ Error checking preferences existence: $e');
      print('[UserPrefsRepo] Stack trace: $stackTrace');
      throw Exception('Failed to check preferences existence: $e');
    }
  }
}