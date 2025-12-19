import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../services/auth_service.dart';
import '../../services/analytics_service.dart';
import '../../services/crashlytics_service.dart';
import '../auth/login_screen.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/steps_card.dart';
import '../../core/widgets/mood_card.dart';
import '../../core/widgets/calendar_widget.dart';
import '../../core/widgets/metrics_selection_menu.dart';
import '../../core/providers/firebase_metrics_provider.dart';  // ЗМІНЕНО
import '../home/metric_details_screen.dart';  // ЗМІНЕНО

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final metricsProvider = Provider.of<FirebaseMetricsProvider>(
        context,
        listen: false,
      );
      
      await metricsProvider.initialize();
      
      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      print('Error initializing app: $e');
      setState(() {
        _isInitializing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize app: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _onDateSelected(DateTime date) {
    final provider = Provider.of<FirebaseMetricsProvider>(
      context,
      listen: false,
    );
    
    provider.changeDate(date);
    
    print('Selected date: ${date.day}/${date.month}/${date.year}');
  }

  void _showMetricsSelectionMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      enableDrag: true,
      isDismissible: true,
      builder: (context) {
        return const MetricsSelectionMenu();
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/grad4.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDFFBA7)),
                ),
                const SizedBox(height: 20),
                Text(
                  'Initializing Health Diary...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Loading from Firebase',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsList() {
    return Consumer<FirebaseMetricsProvider>(
      builder: (context, metricsProvider, child) {
        if (metricsProvider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDFFBA7)),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading your metrics...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        
        if (metricsProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  metricsProvider.error!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    metricsProvider.initialize();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDFFBA7),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    metricsProvider.resetToDefaults();
                  },
                  child: Text(
                    'Reset to Defaults',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        final selectedMetrics = metricsProvider.selectedMetrics;
        
        // Отримати метрики Mood та Steps для відображення
        final moodMetric = selectedMetrics.firstWhere(
          (m) => m.title == 'Mood',
          orElse: () => selectedMetrics.first,
        );
        final stepsMetric = selectedMetrics.firstWhere(
          (m) => m.title == 'Steps',
          orElse: () => selectedMetrics.first,
        );
        
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Mood and Steps cards
            if (selectedMetrics.any((m) => m.title == 'Mood') && 
                selectedMetrics.any((m) => m.title == 'Steps'))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (selectedMetrics.any((m) => m.title == 'Mood'))
                    Expanded(
                      child: MoodMetricCard(
                        moodLevel: moodMetric.value,
                        moodStatus: moodMetric.subtitle,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => 
                                  UpdatedMetricDetailsScreen(metric: 'Mood'),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(width: 2),
                  if (selectedMetrics.any((m) => m.title == 'Steps'))
                    Expanded(
                      child: StepsMetricCard(
                        stepsCount: stepsMetric.value,
                        distanceKm: _extractDistance(stepsMetric.subtitle),
                        calories: _extractCalories(stepsMetric.subtitle),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => 
                                  UpdatedMetricDetailsScreen(metric: 'Steps'),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),

            // Other metrics
            for (final metric in selectedMetrics)
              if (metric.title != 'Mood' && metric.title != 'Steps')
                MetricCard(
                  title: metric.title,
                  value: metric.value,
                  subtitle: metric.subtitle,
                  icon: metric.icon,
                  type: metric.type,
                  pillsCount: metric.title == 'Supplements' ? 1 : null,
                  totalPills: metric.title == 'Supplements' ? 2 : null,
                  onAddWater: metric.title == 'Water intake' ? () {
                    _addWater();
                  } : null,
                  onTap: () {
                    _openMetricDetails(metric.title);
                  },
                ),

            const SizedBox(height: 15),
            
            // Add metrics button
            Container(
              margin: const EdgeInsets.fromLTRB(10,0,10,0),
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  strokeWidth: 2,
                  dashPattern: const [10,10,10,10],
                  color: Colors.white,
                  radius: const Radius.circular(20),
                  padding: EdgeInsets.zero,
                ),                              
                child: ClipRRect(
                  child: SizedBox(
                    height: 60,  
                    width: 352,
                    child: ElevatedButton(
                      onPressed: _showMetricsSelectionMenu,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        '+',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper для витягування дистанції з subtitle
  String _extractDistance(String subtitle) {
    try {
      final parts = subtitle.split('•');
      if (parts.isNotEmpty) {
        return parts[0].trim().replaceAll('km', '').trim();
      }
    } catch (e) {
      print('Error extracting distance: $e');
    }
    return '0';
  }

  // Helper для витягування калорій з subtitle
  double _extractCalories(String subtitle) {
    try {
      final parts = subtitle.split('•');
      if (parts.length > 1) {
        return double.parse(
          parts[1].trim().replaceAll('Cal', '').trim(),
        );
      }
    } catch (e) {
      print('Error extracting calories: $e');
    }
    return 0.0;
  }

  Future<void> _addWater() async {
    final provider = Provider.of<FirebaseMetricsProvider>(
      context,
      listen: false,
    );
    
    try {
      // Додати 250мл води до Firebase
      await provider.addWater(250);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added 250ml of water'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add water: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openMetricDetails(String metricTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdatedMetricDetailsScreen(metric: metricTitle),
      ),
    );
  }

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      AnalyticsService.logButtonTap('logout');
      
      // Відписатись від Firebase streams перед виходом
      final provider = Provider.of<FirebaseMetricsProvider>(
        context,
        listen: false,
      );
      provider.dispose();
      
      await _authService.signOut();
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
      
      AnalyticsService.logEvent('logout_successful', null);
    } catch (e, stack) {
      await CrashlyticsService.recordError(e, stack, reason: 'Logout error');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to logout. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDFFBA7),
                foregroundColor: Colors.black,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/grad4.png',
              fit: BoxFit.cover,
            ),
          ),
          
          if (_isLoggingOut)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Logging out...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Consumer<FirebaseMetricsProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(25, 55, 25, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: _isLoggingOut
                                ? null
                                : _showLogoutConfirmationDialog,
                            child: Image.asset(
                              'assets/icons/settings_icon.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _getDateHeader(provider.selectedDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 34,
                            ),
                          ),
                        ),
                        //Container(width: 44),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Calendar
                    CalendarWidget(
                      onDateSelected: _onDateSelected,
                    ),
                    const SizedBox(height: 10),
                    
                    // Metrics list
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildMetricsList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && 
                    date.month == now.month && 
                    date.day == now.day;
    
    if (isToday) {
      return 'Today, ${date.day} ${_getMonthAbbreviation(date.month)}';
    } else {
      return '${_getDayName(date.weekday)}, ${date.day} ${_getMonthAbbreviation(date.month)}';
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
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
}