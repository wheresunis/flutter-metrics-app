import 'package:flutter/material.dart';

enum MetricType {
  defaultType,
  withTime,
  water,
  pills,
}

class MetricItem {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final MetricType type;
  final bool isSelected;
  final bool isRequired;

  MetricItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.type,
    this.isSelected = false,
    this.isRequired = false
  });

  MetricItem copyWith({
    bool? isSelected,
    String? value,
    String? subtitle,
    bool? isRequired
  }) {
    return MetricItem(
      title: title,
      value: value ?? this.value,
      subtitle: subtitle ?? this.subtitle,
      icon: icon,
      type: type,
      isSelected: isSelected ?? this.isSelected,
      isRequired: isRequired ?? this.isRequired
    );
  }
}