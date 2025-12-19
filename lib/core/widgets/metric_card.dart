import 'package:flutter/material.dart';
import '../models/metric_item.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;
  final MetricType type;
  final int? pillsCount;
  final int? totalPills;
  final VoidCallback? onAddWater;
  final VoidCallback? onTap; // ДОДАНО НОВИЙ ПАРАМЕТР

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle = '',
    required this.icon,
    this.iconColor = Colors.white,
    this.backgroundColor = const Color(0x30797979),
    this.textColor = const Color(0xFFFFFFFF),
    this.type = MetricType.defaultType,
    this.pillsCount,
    this.totalPills,
    this.onAddWater,
    this.onTap, // ДОДАНО ТУТ
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // ОБЕРНУТО В GestureDetector
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: iconColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  _buildRightElement(),
                ],
              ),
              const SizedBox(height: 8),
              
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  // Решта методів залишається НЕЗМІННОЮ
  Widget _buildRightElement() {
    switch (type) {
      case MetricType.withTime:
        return _buildTimeIndicator();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildContent() {
    switch (type) {
      case MetricType.water:
        return _buildWaterContent();
      case MetricType.pills:
        return _buildPillsContent();
      default:
        return _buildDefaultContent();
    }
  }

  Widget _buildTimeIndicator() {
    DateTime now = DateTime.now();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 4),
        Text(
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ',
          style: TextStyle(
            fontSize: 16,
            color: textColor,
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 20,
          color: textColor,
        ),
      ],
    );
  }

  Widget _buildPillsCircle() {
    if (pillsCount == null || totalPills == null) return const SizedBox.shrink();
    
    return Container(
      width: 35,
      height: 35,
      decoration: const BoxDecoration(
        color: Color(0xFFDFFBA7),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$pillsCount/$totalPills',
          style: const TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPillsContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              if (subtitle != '') ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        _buildPillsCircle(),
      ],
    );
  }

  Widget _buildWaterContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (subtitle != '') ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
        
        SizedBox(
          height: 32,
          child: ElevatedButton(
            onPressed: onAddWater,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              foregroundColor: const Color.fromARGB(255, 0, 0, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text(
              '+ 250 ml',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        subtitle != '' 
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
              ),
            )
          : const SizedBox.shrink(),
      ],
    );
  }
}