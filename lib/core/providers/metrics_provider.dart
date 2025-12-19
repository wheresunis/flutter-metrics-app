import 'package:flutter/material.dart';
import '../models/metric_item.dart';
import '../../services/local_storage_service.dart';

class MetricsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<MetricItem> _metrics = [];
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MetricItem> get metrics => _metrics;
  
  List<MetricItem> get selectedMetrics {
    return _metrics.where((metric) => metric.isSelected).toList();
  }

  Future<void> initialize() async {
    await LocalStorageService.init();
  }

  Future<void> loadMetrics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final savedMetricTitles = LocalStorageService.getSelectedMetrics();
      
      if (savedMetricTitles.isNotEmpty) {
        _metrics = _getDefaultMetrics().map((metric) {
          final isSelected = savedMetricTitles.contains(metric.title);
          return metric.copyWith(isSelected: isSelected);
        }).toList();
      } else {
        _metrics = _getDefaultMetrics();
        await _saveSelectedMetrics();
      }
      
      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load metrics: $e';
      notifyListeners();
    }
  }

  void toggleMetric(int index) {
    if (_metrics[index].isRequired) {
      return;
    }

    final updatedMetrics = List<MetricItem>.from(_metrics);
    updatedMetrics[index] = updatedMetrics[index].copyWith(
      isSelected: !updatedMetrics[index].isSelected,
    );

    _metrics = updatedMetrics;
    notifyListeners();

    _saveSelectedMetrics();
  }

  // Додаємо цей метод для збереження
  Future<void> _saveSelectedMetrics() async {
    try {
      final selectedTitles = selectedMetrics.map((metric) => metric.title).toList();
      await LocalStorageService.saveSelectedMetrics(selectedTitles);
      print('Saved metrics to localStorage: $selectedTitles'); // Для дебагу
    } catch (e) {
      print('Error saving metrics: $e');
    }
  }

  void updateAllMetrics(List<MetricItem> metrics) {
    _metrics = metrics;
    notifyListeners();
    
    _saveSelectedMetrics();
  }

  Future<void> resetToDefaults() async {
    _metrics = _getDefaultMetrics();
    notifyListeners();
    
    await _saveSelectedMetrics();
  }

  void clearError() {
    _error = null;
    notifyListeners();
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
        value: '12,106',
        subtitle: '12.1 km • 600 Cal',
        icon: Icons.directions_walk,
        type: MetricType.defaultType,
        isSelected: true,
        isRequired: true,
      ),
      MetricItem(
        title: 'Sleep',
        value: '7 h 30 min',
        subtitle: 'Deep sleep: 2h 15min',
        icon: Icons.nightlight_round,
        type: MetricType.withTime,
        isSelected: true,
        isRequired: false,
      ),
      MetricItem(
        title: 'Heart rate',
        value: '68 BPM',
        subtitle: 'Resting heart rate',
        icon: Icons.favorite,
        type: MetricType.withTime,
        isSelected: true,
        isRequired: false,
      ),
      MetricItem(
        title: 'Water intake',
        value: '200/2,000 ml',
        subtitle: '',
        icon: Icons.water_drop,
        type: MetricType.water,
        isSelected: true,
        isRequired: false,
      ),
      MetricItem(
        title: 'Supplements',
        value: 'Paracetamol',
        subtitle: 'Take after meal',
        icon: Icons.medication,
        type: MetricType.pills,
        isSelected: true,
        isRequired: false,
      ),
      MetricItem(
        title: 'Blood glucose',
        value: '5.2 mmol/L',
        subtitle: 'Normal range',
        icon: Icons.monitor_heart,
        type: MetricType.defaultType,
        isSelected: false,
        isRequired: false,
      ),
      MetricItem(
        title: 'Blood pressure',
        value: '120/80 mmHg',
        subtitle: 'Normal',
        icon: Icons.speed,
        type: MetricType.defaultType,
        isSelected: false,
        isRequired: false,
      ),
    ];
  }
}