import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_metrics_provider.dart';
import '../models/metric_item.dart';

class MetricsSelectionMenu extends StatelessWidget {
  const MetricsSelectionMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        color: Colors.black54,
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          builder: (BuildContext context, ScrollController scrollController) {
            return Consumer<FirebaseMetricsProvider>(
              builder: (context, metricsProvider, child) {
                final List<MetricItem> metrics = metricsProvider.metrics;

                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragUpdate: (details) {
                            if (details.primaryDelta! > 10) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Select metrics to display',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          shrinkWrap: true,
                          itemCount: metrics.length,
                          itemBuilder: (context, index) {
                            final metric = metrics[index];
                            final isRequired = metric.isRequired;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                              child: Card(
                                color: const Color(0x30797979),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    metric.icon,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    metric.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: isRequired
                                      ? _buildRequiredIndicator()
                                      : _buildSwitch(metric, index, metricsProvider),
                                  onTap: isRequired
                                      ? null
                                      : () {
                                          metricsProvider.toggleMetric(index);
                                        },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDFFBA7),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSwitch(MetricItem metric, int index, FirebaseMetricsProvider provider) {
    return Transform.scale(
      scale: 0.8,
      child: Switch(
        value: metric.isSelected,
        onChanged: (bool value) {
          provider.toggleMetric(index);
        },
        activeTrackColor: const Color(0xFFDFFBA7),
        inactiveThumbColor: Colors.grey[400],
        inactiveTrackColor: Colors.grey[600],
        thumbColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFFDFFBA7);
            }
            return Colors.grey[400]!;
          },
        ),
        trackColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF465131);
            }
            return Colors.grey[600]!;
          },
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildRequiredIndicator() {
    return Transform.scale(
      scale: 0.8,
      child: Switch(
        value: true,
        onChanged: (bool value) {},
        activeTrackColor: const Color(0xFFDFFBA7),
        thumbColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.grey[400]!;
          },
        ),
        trackColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.grey[600]!;
          },
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
