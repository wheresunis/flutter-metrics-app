import 'package:cloud_firestore/cloud_firestore.dart';

// Базова модель для всіх метрик
class MetricEntry {
  final String id;
  final String userId;
  final String metricType; // 'steps', 'sleep', 'mood', etc.
  final DateTime date;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime updatedAt;

  MetricEntry({
    required this.id,
    required this.userId,
    required this.metricType,
    required this.date,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  // Конвертація з Firestore
  factory MetricEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MetricEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      metricType: data['metricType'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      data: data['data'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Конвертація в Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'metricType': metricType,
      'date': Timestamp.fromDate(date),
      'data': data,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  MetricEntry copyWith({
    String? id,
    String? userId,
    String? metricType,
    DateTime? date,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MetricEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      metricType: metricType ?? this.metricType,
      date: date ?? this.date,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Специфічні моделі для кожного типу метрики
class StepsData {
  final int steps;
  final double distanceKm;
  final double calories;

  StepsData({
    required this.steps,
    required this.distanceKm,
    required this.calories,
  });

  factory StepsData.fromMap(Map<String, dynamic> map) {
    return StepsData(
      steps: map['steps'] ?? 0,
      distanceKm: (map['distanceKm'] ?? 0).toDouble(),
      calories: (map['calories'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'steps': steps,
      'distanceKm': distanceKm,
      'calories': calories,
    };
  }
}

class SleepData {
  final int durationMinutes; // Загальна тривалість сну в хвилинах
  final int deepSleepMinutes;
  final int lightSleepMinutes;
  final int remSleepMinutes;
  final DateTime sleepTime; // Час засинання
  final DateTime wakeTime; // Час пробудження
  final int quality; // 0-100

  SleepData({
    required this.durationMinutes,
    required this.deepSleepMinutes,
    required this.lightSleepMinutes,
    required this.remSleepMinutes,
    required this.sleepTime,
    required this.wakeTime,
    required this.quality,
  });

  factory SleepData.fromMap(Map<String, dynamic> map) {
    return SleepData(
      durationMinutes: map['durationMinutes'] ?? 0,
      deepSleepMinutes: map['deepSleepMinutes'] ?? 0,
      lightSleepMinutes: map['lightSleepMinutes'] ?? 0,
      remSleepMinutes: map['remSleepMinutes'] ?? 0,
      sleepTime: (map['sleepTime'] as Timestamp).toDate(),
      wakeTime: (map['wakeTime'] as Timestamp).toDate(),
      quality: map['quality'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'durationMinutes': durationMinutes,
      'deepSleepMinutes': deepSleepMinutes,
      'lightSleepMinutes': lightSleepMinutes,
      'remSleepMinutes': remSleepMinutes,
      'sleepTime': Timestamp.fromDate(sleepTime),
      'wakeTime': Timestamp.fromDate(wakeTime),
      'quality': quality,
    };
  }

  String get formattedDuration {
    int hours = durationMinutes ~/ 60;
    int minutes = durationMinutes % 60;
    return '$hours h $minutes min';
  }
}

class MoodData {
  final String level; // 'Excellent', 'Good', 'Neutral', 'Bad', 'Terrible'
  final String status; // 'Relieved', 'Happy', 'Anxious', etc.
  final List<String> tags; // ['work', 'exercise', 'social']
  final String? notes;
  final int rating; // 1-10

  MoodData({
    required this.level,
    required this.status,
    required this.tags,
    this.notes,
    required this.rating,
  });

  factory MoodData.fromMap(Map<String, dynamic> map) {
    return MoodData(
      level: map['level'] ?? '',
      status: map['status'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      notes: map['notes'],
      rating: map['rating'] ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'status': status,
      'tags': tags,
      'notes': notes,
      'rating': rating,
    };
  }
}

class HeartRateData {
  final int bpm;
  final String type; // 'resting', 'active', 'exercise'
  final DateTime measurementTime;
  final int? variability; // HRV in ms

  HeartRateData({
    required this.bpm,
    required this.type,
    required this.measurementTime,
    this.variability,
  });

  factory HeartRateData.fromMap(Map<String, dynamic> map) {
    return HeartRateData(
      bpm: map['bpm'] ?? 0,
      type: map['type'] ?? 'resting',
      measurementTime: (map['measurementTime'] as Timestamp).toDate(),
      variability: map['variability'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bpm': bpm,
      'type': type,
      'measurementTime': Timestamp.fromDate(measurementTime),
      'variability': variability,
    };
  }
}

class WaterIntakeData {
  final int totalMl;
  final int goalMl;
  final List<WaterLog> logs;

  WaterIntakeData({
    required this.totalMl,
    required this.goalMl,
    required this.logs,
  });

  factory WaterIntakeData.fromMap(Map<String, dynamic> map) {
    return WaterIntakeData(
      totalMl: map['totalMl'] ?? 0,
      goalMl: map['goalMl'] ?? 2000,
      logs: (map['logs'] as List<dynamic>?)
              ?.map((log) => WaterLog.fromMap(log as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalMl': totalMl,
      'goalMl': goalMl,
      'logs': logs.map((log) => log.toMap()).toList(),
    };
  }
}

class WaterLog {
  final int amountMl;
  final DateTime time;

  WaterLog({
    required this.amountMl,
    required this.time,
  });

  factory WaterLog.fromMap(Map<String, dynamic> map) {
    return WaterLog(
      amountMl: map['amountMl'] ?? 0,
      time: (map['time'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amountMl': amountMl,
      'time': Timestamp.fromDate(time),
    };
  }
}

class SupplementsData {
  final List<SupplementDose> doses;

  SupplementsData({required this.doses});

  factory SupplementsData.fromMap(Map<String, dynamic> map) {
    return SupplementsData(
      doses: (map['doses'] as List<dynamic>?)
              ?.map((dose) =>
                  SupplementDose.fromMap(dose as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doses': doses.map((dose) => dose.toMap()).toList(),
    };
  }
}

class SupplementDose {
  final String name;
  final String dosage;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final bool taken;
  final String? note; // 'Take after meal', etc.

  SupplementDose({
    required this.name,
    required this.dosage,
    required this.scheduledTime,
    this.takenTime,
    required this.taken,
    this.note,
  });

  factory SupplementDose.fromMap(Map<String, dynamic> map) {
    return SupplementDose(
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      scheduledTime: (map['scheduledTime'] as Timestamp).toDate(),
      takenTime: map['takenTime'] != null
          ? (map['takenTime'] as Timestamp).toDate()
          : null,
      taken: map['taken'] ?? false,
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'takenTime': takenTime != null ? Timestamp.fromDate(takenTime!) : null,
      'taken': taken,
      'note': note,
    };
  }
}

class BloodGlucoseData {
  final double mmolL;
  final String measurementType; // 'fasting', 'before_meal', 'after_meal', 'random'
  final DateTime measurementTime;

  BloodGlucoseData({
    required this.mmolL,
    required this.measurementType,
    required this.measurementTime,
  });

  factory BloodGlucoseData.fromMap(Map<String, dynamic> map) {
    return BloodGlucoseData(
      mmolL: (map['mmolL'] ?? 0).toDouble(),
      measurementType: map['measurementType'] ?? 'random',
      measurementTime: (map['measurementTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mmolL': mmolL,
      'measurementType': measurementType,
      'measurementTime': Timestamp.fromDate(measurementTime),
    };
  }
}

class BloodPressureData {
  final int systolic;
  final int diastolic;
  final int? pulse;
  final DateTime measurementTime;

  BloodPressureData({
    required this.systolic,
    required this.diastolic,
    this.pulse,
    required this.measurementTime,
  });

  factory BloodPressureData.fromMap(Map<String, dynamic> map) {
    return BloodPressureData(
      systolic: map['systolic'] ?? 0,
      diastolic: map['diastolic'] ?? 0,
      pulse: map['pulse'],
      measurementTime: (map['measurementTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'measurementTime': Timestamp.fromDate(measurementTime),
    };
  }

  String get formatted => '$systolic/$diastolic mmHg';
}

// Модель налаштувань користувача
class UserPreferences {
  final String userId;
  final List<String> selectedMetrics;
  final Map<String, dynamic> metricSettings;
  final DateTime updatedAt;

  UserPreferences({
    required this.userId,
    required this.selectedMetrics,
    required this.metricSettings,
    required this.updatedAt,
  });

  factory UserPreferences.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserPreferences(
      userId: doc.id,
      selectedMetrics: List<String>.from(data['selectedMetrics'] ?? []),
      metricSettings: data['metricSettings'] ?? {},
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'selectedMetrics': selectedMetrics,
      'metricSettings': metricSettings,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}