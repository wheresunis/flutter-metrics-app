import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/metric_details.dart';
import '../../core/providers/firebase_metrics_provider.dart';
import '../../core/widgets/add_metric_dialogs.dart';

class UpdatedMetricDetailsScreen extends StatefulWidget {
  final String metric;

  const UpdatedMetricDetailsScreen({
    super.key,
    required this.metric,
  });

  @override
  _UpdatedMetricDetailsScreenState createState() => _UpdatedMetricDetailsScreenState();
}

class _UpdatedMetricDetailsScreenState extends State<UpdatedMetricDetailsScreen> {
  TimePeriod _selectedPeriod = TimePeriod.week;
  late MetricDetails _metricDetails;

  @override
  void initState() {
    super.initState();
    _metricDetails = _getMetricDetails(widget.metric);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/grad2.png',
              fit: BoxFit.cover,
            ),
          ),

          // Content
          Consumer<FirebaseMetricsProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(25, 55, 25, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button, title and Add Data button
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _metricDetails.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 32,
                            ),
                          ),
                        ),
                        // Add Data button
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () {
                              showAddMetricDialog(context, widget.metric);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDFFBA7),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: const Text(
                              'Add Data',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Period selector
                    _buildPeriodSelector(),
                    const SizedBox(height: 30),

                    // Scrollable content area
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Total value from Firebase
                            _buildTotalSection(provider),
                            const SizedBox(height: 30),

                            // Chart placeholder
                            _buildChartPlaceholder(),
                            const SizedBox(height: 30),

                            // Highlights
                            _buildHighlightsSection(),
                            const SizedBox(height: 20),

                            // Recent entries
                            _buildRecentEntries(provider),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 181,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xA00E0E0E),
                    Color(0xFF000000),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x86242424),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPeriodButton('D', TimePeriod.day),
          _buildPeriodButton('W', TimePeriod.week),
          _buildPeriodButton('M', TimePeriod.month),
          _buildPeriodButton('Y', TimePeriod.year),
        ],
      ),
    );
  }

  Widget _buildRecentEntries(FirebaseMetricsProvider provider) {
    final metricType = _convertMetricTitleToType(widget.metric);
    
    // В provider немає поля todayMetrics, тому потрібно отримати дані по-іншому
    // Отримати метрики з Firebase або з локального кешу
    // Для початку використаємо порожній список
    final recentMetrics = <dynamic>[]; // Тут мають бути реальні дані
    
    if (recentMetrics.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      children: recentMetrics.map((entry) {
        return _buildEntryCard(entry);
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x30797979),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox,
            color: Colors.white.withOpacity(0.5),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'No entries yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first ${widget.metric.toLowerCase()} entry',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(dynamic entry) {
    // Створюємо картку для запису метрики
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x30797979),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForMetric(widget.metric),
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getEntryTitle(entry),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getEntrySubtitle(entry),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _getEntryValue(entry),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, TimePeriod period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x18FFFFFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSection(FirebaseMetricsProvider provider) {
    // Отримати актуальне значення з provider
    final metric = provider.metrics.firstWhere(
      (m) => m.title == widget.metric,
      orElse: () => provider.metrics.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          metric.value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getDateText(_selectedPeriod),
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 369,
      decoration: BoxDecoration(
        color: const Color(0xFBFFFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          'Chart for ${_metricDetails.title} (${_selectedPeriod.name})',
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Highlights',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        // Metric-specific highlights
        ..._metricDetails.highlights.map((highlight) => _buildHighlightCard(highlight)),
      ],
    );
  }

  Widget _buildHighlightCard(MetricHighlight highlight) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x30797979),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            highlight.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          if (highlight.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              highlight.subtitle!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            highlight.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getDateText(TimePeriod period) {
    final now = DateTime.now();
    switch (period) {
      case TimePeriod.day:
        return '${now.day} ${_getMonthAbbreviation(now.month)}, ${now.year}';
      case TimePeriod.week:
        return 'Week of ${_getMonthAbbreviation(now.month)} ${now.day}';
      case TimePeriod.month:
        return '${_getMonthAbbreviation(now.month)} ${now.year}';
      case TimePeriod.year:
        return '${now.year}';
    }
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }

  // Допоміжні методи для обробки записів метрик
  String _convertMetricTitleToType(String title) {
    switch (title) {
      case 'Steps': return 'steps';
      case 'Sleep': return 'sleep';
      case 'Mood': return 'mood';
      case 'Heart rate': return 'heartRate';
      case 'Water intake': return 'waterIntake';
      case 'Supplements': return 'supplements';
      default: return title.toLowerCase();
    }
  }

  IconData _getIconForMetric(String metric) {
    switch (metric) {
      case 'Steps': return Icons.directions_walk;
      case 'Sleep': return Icons.nightlight_round;
      case 'Mood': return Icons.emoji_emotions;
      case 'Heart rate': return Icons.favorite;
      case 'Water intake': return Icons.water_drop;
      case 'Supplements': return Icons.medication;
      default: return Icons.analytics;
    }
  }

  String _getEntryTitle(dynamic entry) {
    // Реалізація залежить від структури запису
    return 'Entry';
  }

  String _getEntrySubtitle(dynamic entry) {
    // Реалізація залежить від структури запису
    return 'Time';
  }

  String _getEntryValue(dynamic entry) {
    // Реалізація залежить від структури запису
    return 'Value';
  }

  MetricDetails _getMetricDetails(String metricTitle) {
    switch (metricTitle) {
      case 'Steps':
        return MetricDetails(
          type: MetricType.steps,
          title: 'Steps',
          currentValue: '15,215',
          unit: 'steps',
          chartData: [],
          highlights: [
            MetricHighlight(
              title: 'Steps',
              value: 'Your step count on average:\n3,234 steps/day',
              subtitle: 'As of week of September 28',
            ),
            MetricHighlight(
              title: 'Calories',
              value: 'Calories burnt this week',
              subtitle: null,
            ),
          ],
        );
      
      case 'Sleep':
        return MetricDetails(
          type: MetricType.sleep,
          title: 'Sleep',
          currentValue: '7h 30min',
          unit: '',
          chartData: [],
          highlights: [
            MetricHighlight(
              title: 'Sleep Quality',
              value: 'Average: 85%',
              subtitle: 'Deep sleep: 2h 15min',
            ),
            MetricHighlight(
              title: 'Consistency',
              value: '6/7 days this week',
              subtitle: 'Best streak: 12 days',
            ),
          ],
        );
      
      case 'Mood':
        return MetricDetails(
          type: MetricType.mood,
          title: 'Mood',
          currentValue: 'Good',
          unit: '',
          chartData: [],
          highlights: [
            MetricHighlight(
              title: 'Average Mood',
              value: '7.2/10',
              subtitle: 'This week',
            ),
            MetricHighlight(
              title: 'Most Common',
              value: 'Relieved',
              subtitle: 'Your frequent mood',
            ),
          ],
        );
      
      case 'Heart rate':
        return MetricDetails(
          type: MetricType.heartRate,
          title: 'Heart Rate',
          currentValue: '68',
          unit: 'BPM',
          chartData: [],
          highlights: [
            MetricHighlight(
              title: 'Resting Heart Rate',
              value: '64 BPM',
              subtitle: 'Healthy range',
            ),
            MetricHighlight(
              title: 'Variability',
              value: '42 ms',
              subtitle: 'Good level',
            ),
          ],
        );
      
      case 'Water intake':
        return MetricDetails(
          type: MetricType.water,
          title: 'Water Intake',
          currentValue: '1,200',
          unit: 'ml',
          chartData: [],
          highlights: [
            MetricHighlight(
              title: 'Daily Average',
              value: '1,800 ml',
              subtitle: 'Goal: 2,000 ml',
            ),
            MetricHighlight(
              title: 'Consistency',
              value: '5/7 days this week',
              subtitle: 'Met daily goal',
            ),
          ],
        );
      
      case 'Supplements':
        return MetricDetails(
          type: MetricType.supplements,
          title: 'Supplements',
          currentValue: 'Paracetamol',
          unit: '',
          chartData: [],
          highlights: [
            MetricHighlight(
              title: 'Today',
              value: '1/2 doses taken',
              subtitle: 'Next dose: 8:00 PM',
            ),
            MetricHighlight(
              title: 'This Week',
              value: '6/14 doses taken',
              subtitle: 'On track',
            ),
          ],
        );
      
      default:
        return MetricDetails(
          type: MetricType.steps,
          title: metricTitle,
          currentValue: '--',
          unit: '',
          chartData: [],
          highlights: [],
        );
    }
  }
}

enum TimePeriod {
  day,
  week,
  month,
  year,
}