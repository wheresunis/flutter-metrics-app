enum MetricType {
  steps,
  sleep,
  mood,
  heartRate,
  water,
  supplements,
}

class MetricDetails {
  final MetricType type;
  final String title;
  final String currentValue;
  final String unit;
  final List<ChartData> chartData;
  final List<MetricHighlight> highlights;

  MetricDetails({
    required this.type,
    required this.title,
    required this.currentValue,
    required this.unit,
    required this.chartData,
    required this.highlights,
  });
}

class ChartData {
  final String label;
  final double value;
  final DateTime date;

  ChartData({
    required this.label,
    required this.value,
    required this.date,
  });
}

class MetricHighlight {
  final String title;
  final String value;
  final String? subtitle;

  MetricHighlight({
    required this.title,
    required this.value,
    required this.subtitle,
  });
}