import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/metric_item.dart';
import '../models/metric_model.dart';
import '../repositories/metrics_repository.dart';
import '../repositories/user_preferences_repository.dart';
import 'dart:async';

class FirebaseMetricsProvider extends ChangeNotifier {
  final MetricsRepository _metricsRepository = MetricsRepository();
  final UserPreferencesRepository _preferencesRepository = UserPreferencesRepository();
  
  bool _isLoading = false;
  String? _error;
  List<MetricItem> _metrics = [];
  DateTime _selectedDate = DateTime.now();
  Map<String, MetricEntry> _todayMetrics = {};
  bool disposed = false;
  
  // Streams
  StreamSubscription? _metricsStreamSubscription;
  StreamSubscription? _preferencesStreamSubscription;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MetricItem> get metrics => _metrics;
  DateTime get selectedDate => _selectedDate;
  
  List<MetricItem> get selectedMetrics {
    return _metrics.where((metric) => metric.isSelected).toList();
  }

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // ========== INITIALIZATION ==========
  
  Future<void> initialize() async {
    if (currentUserId == null) {
      _error = 'User not authenticated';
      if (!disposed) {
        notifyListeners();
      }
      return;
    }

    _isLoading = true;
    _error = null;
    if (!disposed) {
      notifyListeners();
    }

    try {
      print('Initializing FirebaseMetricsProvider for user: $currentUserId');
      
      // Перевірка чи існують налаштування
      bool prefsExist = await _preferencesRepository.preferencesExist(currentUserId!);
      
      if (!prefsExist) {
        // Створити початкові налаштування
        await _preferencesRepository.createDefaultPreferences(currentUserId!);
      }

      // Завантажити налаштування та метрики
      await loadUserPreferences();
      await loadMetricsForDate(_selectedDate);

      // Підписатися на real-time оновлення
      _subscribeToRealtimeUpdates();
      
      _isLoading = false;
      print('Initialization complete');
      if (!disposed) {
        notifyListeners();
      }
    } catch (e, stackTrace) {
      _isLoading = false;
      _error = 'Failed to initialize: $e';
      print('Initialization error: $e');
      print('Stack trace: $stackTrace');
      if (!disposed) {
        notifyListeners();
      }
    }
  }

  // ========== REAL-TIME SUBSCRIPTIONS ==========
  
  void _subscribeToRealtimeUpdates() {
    if (currentUserId == null) return;

    print('Setting up real-time subscriptions for user: $currentUserId');

    // Підписка на зміни налаштувань
    _preferencesStreamSubscription = _preferencesRepository
        .streamUserPreferences(currentUserId!)
        .listen((preferences) {
      if (disposed) {
        print('Ignoring preferences update: provider disposed');
        return;
      }
      
      if (preferences != null) {
        print('Preferences stream update received: ${preferences.selectedMetrics}');
        _updateMetricsFromPreferences(preferences);
        if (!disposed) {
          notifyListeners();
        }
      }
    }, onError: (error) {
      print('Preferences stream error: $error');
    }, onDone: () {
      print('Preferences stream done');
    });

    // Підписка на зміни метрик за обрану дату
    _subscribeToMetricsStream(_selectedDate);
  }

  void _subscribeToMetricsStream(DateTime date) {
    if (currentUserId == null) return;

    _metricsStreamSubscription?.cancel();
    
    print('Setting up metrics stream for date: ${date.year}-${date.month}-${date.day}');
    
    _metricsStreamSubscription = _metricsRepository
        .streamMetricsByDate(currentUserId!, date)
        .listen((entries) {
      if (disposed) {
        print('Ignoring metrics update: provider disposed');
        return;
      }
      
      print('Metrics stream update received: ${entries.length} entries');
      _updateTodayMetrics(entries);
      _updateMetricValues();
      if (!disposed) {
        notifyListeners();
      }
    }, onError: (error) {
      print('Metrics stream error: $error');
    }, onDone: () {
      print('Metrics stream done');
    });
  }

  // ========== LOAD DATA ==========
  
  Future<void> loadUserPreferences() async {
    if (currentUserId == null) {
      print('Cannot load preferences: currentUserId is null');
      return;
    }

    try {
      print('Loading preferences for user: $currentUserId from collection: user_preferences');
      UserPreferences? preferences = await _preferencesRepository
          .getUserPreferences(currentUserId!);

      if (preferences != null) {
        print('✓ Preferences loaded successfully');
        print('  - selectedMetrics: ${preferences.selectedMetrics}');
        print('  - metricSettings: ${preferences.metricSettings}');
        print('  - updatedAt: ${preferences.updatedAt}');
        _updateMetricsFromPreferences(preferences);
        print('✓ Metrics updated from preferences');
      } else {
        print('✗ No preferences found in Firestore, using defaults');
        _metrics = _getDefaultMetrics();
      }
      
      if (!disposed) {
        notifyListeners();
      }
    } catch (e, stackTrace) {
      print('✗ Error loading preferences: $e');
      print('Stack trace: $stackTrace');
      _metrics = _getDefaultMetrics();
      if (!disposed) {
        notifyListeners();
      }
    }
  }

  Future<void> loadMetricsForDate(DateTime date) async {
    if (currentUserId == null) return;

    _selectedDate = date;
    
    try {
      List<MetricEntry> entries = await _metricsRepository
          .getMetricsByDate(currentUserId!, date);
      
      _updateTodayMetrics(entries);
      _updateMetricValues();
      
      // Оновити stream для нової дати
      _subscribeToMetricsStream(date);
      
      if (!disposed) {
        notifyListeners();
      }
    } catch (e) {
      print('Error loading metrics for date: $e');
      _error = 'Failed to load metrics: $e';
      if (!disposed) {
        notifyListeners();
      }
    }
  }

  void _updateTodayMetrics(List<MetricEntry> entries) {
    _todayMetrics.clear();
    for (var entry in entries) {
      _todayMetrics[entry.metricType] = entry;
    }
  }

  void _updateMetricsFromPreferences(UserPreferences preferences) {
    _metrics = _getDefaultMetrics().map((metric) {
      final isSelected = preferences.selectedMetrics.contains(metric.title);
      return metric.copyWith(isSelected: isSelected);
    }).toList();
  }

  void _updateMetricValues() {
    print('[FirebaseMetricsProvider] _updateMetricValues called');
    print('[FirebaseMetricsProvider] Total entries in _todayMetrics: ${_todayMetrics.length}');
    print('[FirebaseMetricsProvider] Entries: ${_todayMetrics.keys.toList()}');
    
    _metrics = _metrics.map((metric) {
      final metricType = _getMetricTypeFromTitle(metric.title);
      print('[FirebaseMetricsProvider] Checking metric "${metric.title}" (type: $metricType)');
      
      final entry = _todayMetrics[metricType];
      
      if (entry != null) {
        print('[FirebaseMetricsProvider] ✓ Found entry for $metricType: ${entry.data}');
        return _updateMetricFromEntry(metric, entry);
      }
      
      print('[FirebaseMetricsProvider] ✗ No entry found for $metricType - resetting to default');
      // Reset to default value when no entry exists for this date
      return _resetMetricToDefault(metric);
    }).toList();
    
    print('[FirebaseMetricsProvider] Metrics updated. Current values:');
    for (var m in _metrics) {
      print('[FirebaseMetricsProvider]   ${m.title}: ${m.value} (${m.subtitle})');
    }
  }

  MetricItem _resetMetricToDefault(MetricItem metric) {
    switch (metric.title) {
      case 'Mood':
        return metric.copyWith(value: '---', subtitle: '---');
      
      case 'Steps':
        return metric.copyWith(value: '0', subtitle: '0 km • 0 Cal');
      
      case 'Sleep':
        return metric.copyWith(value: '0 h 0 min', subtitle: 'Deep sleep: 0h 0min');
      
      case 'Heart rate':
        return metric.copyWith(value: '0 BPM', subtitle: 'Resting heart rate');
      
      case 'Water intake':
        return metric.copyWith(value: '0/2,000 ml', subtitle: '');
      
      case 'Supplements':
        return metric.copyWith(value: 'No supplements', subtitle: '');
      
      case 'Blood glucose':
        return metric.copyWith(value: '0 mmol/L', subtitle: 'Normal range');
      
      case 'Blood pressure':
        return metric.copyWith(value: '0/0 mmHg', subtitle: 'Normal');
      
      default:
        return metric;
    }
  }

  MetricItem _updateMetricFromEntry(MetricItem metric, MetricEntry entry) {
    switch (entry.metricType) {
      case 'steps':
        final data = StepsData.fromMap(entry.data);
        return metric.copyWith(
          value: data.steps.toString(),
          subtitle: '${data.distanceKm} km • ${data.calories.toInt()} Cal',
        );
      
      case 'sleep':
        final data = SleepData.fromMap(entry.data);
        return metric.copyWith(
          value: data.formattedDuration,
          subtitle: 'Deep sleep: ${(data.deepSleepMinutes ~/ 60)}h ${data.deepSleepMinutes % 60}min',
        );
      
      case 'mood':
        final data = MoodData.fromMap(entry.data);
        return metric.copyWith(
          value: data.level,
          subtitle: data.status,
        );
      
      case 'heartRate':
        final data = HeartRateData.fromMap(entry.data);
        return metric.copyWith(
          value: '${data.bpm} BPM',
          subtitle: 'Resting heart rate',
        );
      
      case 'waterIntake':
        final data = WaterIntakeData.fromMap(entry.data);
        return metric.copyWith(
          value: '${data.totalMl}/${data.goalMl} ml',
          subtitle: '',
        );
      
      case 'supplements':
        final data = SupplementsData.fromMap(entry.data);
        final taken = data.doses.where((d) => d.taken).length;
        final total = data.doses.length;
        return metric.copyWith(
          value: data.doses.isNotEmpty ? data.doses.first.name : 'No supplements',
          subtitle: data.doses.isNotEmpty 
              ? (data.doses.first.note ?? 'Take as prescribed')
              : '',
        );
      
      default:
        return metric;
    }
  }

  // ========== TOGGLE METRICS ==========
  
  void toggleMetric(int index) async {
    if (_metrics[index].isRequired || currentUserId == null) {
      return;
    }

    final updatedMetrics = List<MetricItem>.from(_metrics);
    updatedMetrics[index] = updatedMetrics[index].copyWith(
      isSelected: !updatedMetrics[index].isSelected,
    );

    _metrics = updatedMetrics;
    if (!disposed) {
      notifyListeners();
    }

    await _saveSelectedMetrics();
  }

  Future<void> _saveSelectedMetrics() async {
    if (currentUserId == null) return;

    try {
      final selectedTitles = selectedMetrics.map((m) => m.title).toList();
      print('Saving selected metrics: $selectedTitles for user: $currentUserId');
      await _preferencesRepository.updateSelectedMetrics(
        currentUserId!,
        selectedTitles,
      );
      print('Successfully saved selected metrics to Firestore');
    } catch (e) {
      print('Error saving selected metrics: $e');
      _error = 'Failed to save preferences: $e';
      if (!disposed) {
        notifyListeners();
      }
    }
  }

  // ========== CREATE / UPDATE METRICS ==========
  
  /// Створення нового запису Steps
  Future<void> addStepsEntry(int steps, double distanceKm, double calories) async {
    print('[FirebaseMetricsProvider] addStepsEntry called with steps=$steps, distance=$distanceKm, calories=$calories');
    print('[FirebaseMetricsProvider] currentUserId=$currentUserId, disposed=$disposed');
    
    if (currentUserId == null) {
      print('Cannot add steps entry: User not authenticated');
      return;
    }

    try {
      print('Creating steps entry: steps=$steps, distance=$distanceKm, calories=$calories');
      
      final entry = MetricEntry(
        id: '',
        userId: currentUserId!,
        metricType: 'steps',
        date: _selectedDate,
        data: StepsData(
          steps: steps,
          distanceKm: distanceKm,
          calories: calories,
        ).toMap(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('Firestore entry prepared: ${entry.toFirestore()}');
      
      final entryId = await _metricsRepository.createMetricEntry(entry);
      print('Steps entry created successfully with ID: $entryId');
      
      // Clear error on success
      _error = null;
      if (!disposed) {
        notifyListeners();
      }
    } catch (e, stackTrace) {
      print('Error creating steps entry: $e');
      print('Stack trace: $stackTrace');
      _error = 'Failed to add steps entry: $e';
      if (!disposed) {
        notifyListeners();
      }
    }
  }

  /// Створення нового запису Sleep
  Future<void> addSleepEntry({
    required int durationMinutes,
    required int deepSleepMinutes,
    required DateTime sleepTime,
    required DateTime wakeTime,
    required int quality,
  }) async {
    if (currentUserId == null) return;

    try {
      final entry = MetricEntry(
        id: '',
        userId: currentUserId!,
        metricType: 'sleep',
        date: _selectedDate,
        data: SleepData(
          durationMinutes: durationMinutes,
          deepSleepMinutes: deepSleepMinutes,
          lightSleepMinutes: (durationMinutes - deepSleepMinutes) ~/ 2,
          remSleepMinutes: (durationMinutes - deepSleepMinutes) ~/ 2,
          sleepTime: sleepTime,
          wakeTime: wakeTime,
          quality: quality,
        ).toMap(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _metricsRepository.createMetricEntry(entry);
    } catch (e) {
      _error = 'Failed to add sleep entry: $e';
      notifyListeners();
    }
  }

  /// Створення нового запису Mood
  Future<void> addMoodEntry({
    required String level,
    required String status,
    required int rating,
    List<String>? tags,
    String? notes,
  }) async {
    if (currentUserId == null) return;

    try {
      final entry = MetricEntry(
        id: '',
        userId: currentUserId!,
        metricType: 'mood',
        date: _selectedDate,
        data: MoodData(
          level: level,
          status: status,
          tags: tags ?? [],
          notes: notes,
          rating: rating,
        ).toMap(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _metricsRepository.createMetricEntry(entry);
    } catch (e) {
      _error = 'Failed to add mood entry: $e';
      notifyListeners();
    }
  }

  /// Додавання води
  Future<void> addWater(int amountMl) async {
    if (currentUserId == null) return;

    try {
      final existingEntry = _todayMetrics['waterIntake'];
      
      if (existingEntry != null) {
        // Оновити існуючий запис
        final data = WaterIntakeData.fromMap(existingEntry.data);
        final updatedLogs = List<WaterLog>.from(data.logs)
          ..add(WaterLog(amountMl: amountMl, time: DateTime.now()));
        
        final updatedData = WaterIntakeData(
          totalMl: data.totalMl + amountMl,
          goalMl: data.goalMl,
          logs: updatedLogs,
        ).toMap();

        await _metricsRepository.updateMetricData(existingEntry.id, updatedData);
      } else {
        // Створити новий запис
        final entry = MetricEntry(
          id: '',
          userId: currentUserId!,
          metricType: 'waterIntake',
          date: _selectedDate,
          data: WaterIntakeData(
            totalMl: amountMl,
            goalMl: 2000,
            logs: [WaterLog(amountMl: amountMl, time: DateTime.now())],
          ).toMap(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _metricsRepository.createMetricEntry(entry);
      }
    } catch (e) {
      _error = 'Failed to add water: $e';
      notifyListeners();
    }
  }

  /// Додавання Heart Rate
  Future<void> addHeartRateEntry(int bpm, {int? variability}) async {
    if (currentUserId == null) return;

    try {
      final entry = MetricEntry(
        id: '',
        userId: currentUserId!,
        metricType: 'heartRate',
        date: _selectedDate,
        data: HeartRateData(
          bpm: bpm,
          type: 'resting',
          measurementTime: DateTime.now(),
          variability: variability,
        ).toMap(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _metricsRepository.createMetricEntry(entry);
    } catch (e) {
      _error = 'Failed to add heart rate entry: $e';
      notifyListeners();
    }
  }

  // ========== UTILITY ==========
  
  Future<void> resetToDefaults() async {
    if (currentUserId == null) return;
    
    _metrics = _getDefaultMetrics();
    if (!disposed) {
      notifyListeners();
    }
    
    await _saveSelectedMetrics();
  }

  void clearError() {
    _error = null;
    if (!disposed) {
      notifyListeners();
    }
  }

  void changeDate(DateTime newDate) {
    _selectedDate = newDate;
    if (!disposed) {
      loadMetricsForDate(newDate);
    }
  }

  String _getMetricTypeFromTitle(String title) {
    switch (title) {
      case 'Steps': return 'steps';
      case 'Sleep': return 'sleep';
      case 'Mood': return 'mood';
      case 'Heart rate': return 'heartRate';
      case 'Water intake': return 'waterIntake';
      case 'Supplements': return 'supplements';
      case 'Blood glucose': return 'bloodGlucose';
      case 'Blood pressure': return 'bloodPressure';
      default: return title.toLowerCase();
    }
  }

  static List<MetricItem> _getDefaultMetrics() {
    return [
      MetricItem(
        title: 'Mood',
        value: 'Good',
        subtitle: 'Relieved',
        icon: Icons.emoji_emotions,
        type: MetricType.defaultType,
        isSelected: true,
        isRequired: true,
      ),
      MetricItem(
        title: 'Steps',
        value: '0',
        subtitle: '0 km • 0 Cal',
        icon: Icons.directions_walk,
        type: MetricType.defaultType,
        isSelected: true,
        isRequired: true,
      ),
      MetricItem(
        title: 'Sleep',
        value: '0 h 0 min',
        subtitle: 'Deep sleep: 0h 0min',
        icon: Icons.nightlight_round,
        type: MetricType.withTime,
        isSelected: false,
        isRequired: false,
      ),
      MetricItem(
        title: 'Heart rate',
        value: '0 BPM',
        subtitle: 'Resting heart rate',
        icon: Icons.favorite,
        type: MetricType.withTime,
        isSelected: false,
        isRequired: false,
      ),
      MetricItem(
        title: 'Water intake',
        value: '0/2,000 ml',
        subtitle: '',
        icon: Icons.water_drop,
        type: MetricType.water,
        isSelected: false,
        isRequired: false,
      ),
      MetricItem(
        title: 'Supplements',
        value: 'No supplements',
        subtitle: '',
        icon: Icons.medication,
        type: MetricType.pills,
        isSelected: false,
        isRequired: false,
      ),
      MetricItem(
        title: 'Blood glucose',
        value: '0 mmol/L',
        subtitle: 'Normal range',
        icon: Icons.monitor_heart,
        type: MetricType.defaultType,
        isSelected: false,
        isRequired: false,
      ),
      MetricItem(
        title: 'Blood pressure',
        value: '0/0 mmHg',
        subtitle: 'Normal',
        icon: Icons.speed,
        type: MetricType.defaultType,
        isSelected: false,
        isRequired: false,
      ),
    ];
  }

  @override
  void dispose() {
    disposed = true;
    _metricsStreamSubscription?.cancel();
    _preferencesStreamSubscription?.cancel();
    super.dispose();
  }
}