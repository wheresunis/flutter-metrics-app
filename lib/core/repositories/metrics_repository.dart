import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/metric_model.dart';

class MetricsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Назва колекції
  static const String _metricsCollection = 'metrics';

  // ========== CREATE ==========
  
  /// Створення нового запису метрики
  Future<String> createMetricEntry(MetricEntry entry) async {
    try {
      print('[MetricsRepo] Creating metric entry:');
      print('[MetricsRepo]   - userId: ${entry.userId}');
      print('[MetricsRepo]   - metricType: ${entry.metricType}');
      print('[MetricsRepo]   - date: ${entry.date}');
      print('[MetricsRepo]   - data: ${entry.data}');
      
      final firestoreData = entry.toFirestore();
      print('[MetricsRepo] Firestore data to be written: $firestoreData');
      
      DocumentReference docRef = await _firestore
          .collection(_metricsCollection)
          .add(firestoreData);
      
      print('[MetricsRepo] ✓ Metric entry created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      print('[MetricsRepo] ✗ Failed to create metric entry: $e');
      print('[MetricsRepo] Stack trace: $stackTrace');
      throw Exception('Failed to create metric entry: $e');
    }
  }

  // ========== READ ==========
  
  /// Отримання всіх метрик користувача за датою
  Future<List<MetricEntry>> getMetricsByDate(String userId, DateTime date) async {
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      print('[MetricsRepo] Getting metrics for userId: $userId, date: ${date.year}-${date.month}-${date.day}');

      QuerySnapshot snapshot = await _firestore
          .collection(_metricsCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('date', descending: true)
          .get();

      print('[MetricsRepo] ✓ Retrieved ${snapshot.docs.length} metrics from Firestore');
      
      return snapshot.docs
          .map((doc) => MetricEntry.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      print('[MetricsRepo] ✗ Error getting metrics: $e');
      print('[MetricsRepo] Stack trace: $stackTrace');
      throw Exception('Failed to get metrics by date: $e');
    }
  }

  /// Отримання метрик за діапазон дат
  Future<List<MetricEntry>> getMetricsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
    {String? metricType}
  ) async {
    try {
      Query query = _firestore
          .collection(_metricsCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (metricType != null) {
        query = query.where('metricType', isEqualTo: metricType);
      }

      QuerySnapshot snapshot = await query.orderBy('date', descending: true).get();

      return snapshot.docs
          .map((doc) => MetricEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get metrics by date range: $e');
    }
  }

  /// Отримання конкретної метрики за ID
  Future<MetricEntry?> getMetricById(String metricId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_metricsCollection)
          .doc(metricId)
          .get();

      if (doc.exists) {
        return MetricEntry.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get metric by ID: $e');
    }
  }

  /// Отримання останньої метрики певного типу
  Future<MetricEntry?> getLatestMetricByType(String userId, String metricType) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_metricsCollection)
          .where('userId', isEqualTo: userId)
          .where('metricType', isEqualTo: metricType)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return MetricEntry.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get latest metric: $e');
    }
  }

  // ========== STREAM (Real-time updates) ==========
  
  /// Stream метрик користувача за конкретну дату
  Stream<List<MetricEntry>> streamMetricsByDate(String userId, DateTime date) {
    DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    print('[MetricsRepo] Setting up stream for userId: $userId, date: ${date.year}-${date.month}-${date.day}');
    print('[MetricsRepo]   - Start: $startOfDay, End: $endOfDay');

    return _firestore
        .collection(_metricsCollection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          print('[MetricsRepo] Stream snapshot received: ${snapshot.docs.length} documents');
          
          for (var i = 0; i < snapshot.docs.length; i++) {
            final doc = snapshot.docs[i];
            print('[MetricsRepo]   Doc[$i]: id=${doc.id}, metricType=${doc['metricType']}, data=${doc['data']}');
          }
          
          return snapshot.docs
              .map((doc) => MetricEntry.fromFirestore(doc))
              .toList();
        });
  }

  /// Stream метрик за діапазон дат
  Stream<List<MetricEntry>> streamMetricsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
    {String? metricType}
  ) {
    Query query = _firestore
        .collection(_metricsCollection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

    if (metricType != null) {
      query = query.where('metricType', isEqualTo: metricType);
    }

    return query
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MetricEntry.fromFirestore(doc))
            .toList());
  }

  // ========== UPDATE ==========
  
  /// Оновлення запису метрики
  Future<void> updateMetricEntry(String metricId, MetricEntry entry) async {
    try {
      await _firestore
          .collection(_metricsCollection)
          .doc(metricId)
          .update(entry.toFirestore());
    } catch (e) {
      throw Exception('Failed to update metric entry: $e');
    }
  }

  /// Часткове оновлення даних метрики
  Future<void> updateMetricData(String metricId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(_metricsCollection)
          .doc(metricId)
          .update({
        'data': data,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update metric data: $e');
    }
  }

  // ========== DELETE ==========
  
  /// Видалення запису метрики
  Future<void> deleteMetricEntry(String metricId) async {
    try {
      await _firestore
          .collection(_metricsCollection)
          .doc(metricId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete metric entry: $e');
    }
  }

  /// Видалення всіх метрик користувача (використовувати обережно!)
  Future<void> deleteAllUserMetrics(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_metricsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all user metrics: $e');
    }
  }

  // ========== ANALYTICS & STATISTICS ==========
  
  /// Підрахунок кількості метрик за період
  Future<int> getMetricsCount(
    String userId,
    DateTime startDate,
    DateTime endDate,
    {String? metricType}
  ) async {
    try {
      Query query = _firestore
          .collection(_metricsCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (metricType != null) {
        query = query.where('metricType', isEqualTo: metricType);
      }

      AggregateQuerySnapshot snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get metrics count: $e');
    }
  }

  /// Отримання середнього значення для числових метрик
  Future<double?> getAverageValue(
    String userId,
    String metricType,
    String fieldName,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      List<MetricEntry> entries = await getMetricsByDateRange(
        userId,
        startDate,
        endDate,
        metricType: metricType,
      );

      if (entries.isEmpty) return null;

      double sum = 0;
      int count = 0;

      for (var entry in entries) {
        if (entry.data.containsKey(fieldName)) {
          var value = entry.data[fieldName];
          if (value is num) {
            sum += value.toDouble();
            count++;
          }
        }
      }

      return count > 0 ? sum / count : null;
    } catch (e) {
      throw Exception('Failed to calculate average: $e');
    }
  }

  // ========== BATCH OPERATIONS ==========
  
  /// Створення декількох записів одночасно
  Future<void> createMultipleEntries(List<MetricEntry> entries) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      for (var entry in entries) {
        DocumentReference docRef = _firestore.collection(_metricsCollection).doc();
        batch.set(docRef, entry.toFirestore());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create multiple entries: $e');
    }
  }
}