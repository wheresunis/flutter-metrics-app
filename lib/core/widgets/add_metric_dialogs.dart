import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_metrics_provider.dart';

// ========== STEPS DIALOG ==========
class AddStepsDialog extends StatefulWidget {
  const AddStepsDialog({super.key});

  @override
  State<AddStepsDialog> createState() => _AddStepsDialogState();
}

class _AddStepsDialogState extends State<AddStepsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _stepsController = TextEditingController();
  final _distanceController = TextEditingController();
  final _caloriesController = TextEditingController();

  @override
  void dispose() {
    _stepsController.dispose();
    _distanceController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Steps', style: TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _stepsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Steps',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter steps';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _distanceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Distance (km)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter distance';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Calories',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter calories';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () async {
            print('[AddStepsDialog] ============ ADD BUTTON CLICKED ============');
            print('[AddStepsDialog] Form validation check...');
            
            if (_formKey.currentState!.validate()) {
              print('[AddStepsDialog] ✓ Form validated');
              print('[AddStepsDialog] Button pressed, validated, getting provider');
              
              final provider = Provider.of<FirebaseMetricsProvider>(
                context,
                listen: false,
              );

              print('[AddStepsDialog] ✓ Provider obtained');
              print('[AddStepsDialog] Calling addStepsEntry with: steps=${_stepsController.text}, distance=${_distanceController.text}, calories=${_caloriesController.text}');
              
              await provider.addStepsEntry(
                int.parse(_stepsController.text),
                double.parse(_distanceController.text),
                double.parse(_caloriesController.text),
              );

              print('[AddStepsDialog] ✓ addStepsEntry completed');

              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Steps added successfully!')),
              );
            } else {
              print('[AddStepsDialog] ✗ Form validation failed');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDFFBA7),
            foregroundColor: Colors.black,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// ========== SLEEP DIALOG ==========
class AddSleepDialog extends StatefulWidget {
  const AddSleepDialog({super.key});

  @override
  State<AddSleepDialog> createState() => _AddSleepDialogState();
}

class _AddSleepDialogState extends State<AddSleepDialog> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay _sleepTime = TimeOfDay.now();
  TimeOfDay _wakeTime = TimeOfDay.now();
  double _quality = 75;
  int _deepSleepMinutes = 120;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Sleep', style: TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sleep time
              ListTile(
                title: const Text('Sleep Time', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  _sleepTime.format(context),
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.access_time, color: Colors.white70),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _sleepTime,
                  );
                  if (time != null) {
                    setState(() => _sleepTime = time);
                  }
                },
              ),
              // Wake time
              ListTile(
                title: const Text('Wake Time', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  _wakeTime.format(context),
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.access_time, color: Colors.white70),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _wakeTime,
                  );
                  if (time != null) {
                    setState(() => _wakeTime = time);
                  }
                },
              ),
              const SizedBox(height: 16),
              // Quality slider
              Text('Sleep Quality: ${_quality.toInt()}%',
                  style: const TextStyle(color: Colors.white)),
              Slider(
                value: _quality,
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: const Color(0xFFDFFBA7),
                onChanged: (value) => setState(() => _quality = value),
              ),
              const SizedBox(height: 16),
              // Deep sleep
              Text('Deep Sleep: ${_deepSleepMinutes} min',
                  style: const TextStyle(color: Colors.white)),
              Slider(
                value: _deepSleepMinutes.toDouble(),
                min: 0,
                max: 480,
                divisions: 48,
                activeColor: const Color(0xFFDFFBA7),
                onChanged: (value) =>
                    setState(() => _deepSleepMinutes = value.toInt()),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () async {
            final now = DateTime.now();
            final sleepDateTime = DateTime(
              now.year,
              now.month,
              now.day - 1,
              _sleepTime.hour,
              _sleepTime.minute,
            );
            final wakeDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              _wakeTime.hour,
              _wakeTime.minute,
            );

            final duration = wakeDateTime.difference(sleepDateTime).inMinutes;

            final provider = Provider.of<FirebaseMetricsProvider>(
              context,
              listen: false,
            );

            await provider.addSleepEntry(
              durationMinutes: duration,
              deepSleepMinutes: _deepSleepMinutes,
              sleepTime: sleepDateTime,
              wakeTime: wakeDateTime,
              quality: _quality.toInt(),
            );

            Navigator.of(context).pop();
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sleep data added successfully!')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDFFBA7),
            foregroundColor: Colors.black,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// ========== MOOD DIALOG ==========
class AddMoodDialog extends StatefulWidget {
  const AddMoodDialog({super.key});

  @override
  State<AddMoodDialog> createState() => _AddMoodDialogState();
}

class _AddMoodDialogState extends State<AddMoodDialog> {
  String _selectedLevel = 'Good';
  String _selectedStatus = 'Relieved';
  double _rating = 7;
  final _notesController = TextEditingController();

  final List<String> _levels = ['Excellent', 'Good', 'Neutral', 'Bad', 'Terrible'];
  final List<String> _statuses = [
    'Relieved',
    'Happy',
    'Anxious',
    'Stressed',
    'Calm',
    'Energetic',
    'Tired',
    'Content'
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Mood', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mood Level', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              dropdownColor: const Color(0xFF2A2A2A),
              style: const TextStyle(color: Colors.white),
              items: _levels.map((level) {
                return DropdownMenuItem(value: level, child: Text(level));
              }).toList(),
              onChanged: (value) => setState(() => _selectedLevel = value!),
            ),
            const SizedBox(height: 16),
            const Text('Status', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              dropdownColor: const Color(0xFF2A2A2A),
              style: const TextStyle(color: Colors.white),
              items: _statuses.map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) => setState(() => _selectedStatus = value!),
            ),
            const SizedBox(height: 16),
            Text('Rating: ${_rating.toInt()}/10',
                style: const TextStyle(color: Colors.white)),
            Slider(
              value: _rating,
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: const Color(0xFFDFFBA7),
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () async {
            final provider = Provider.of<FirebaseMetricsProvider>(
              context,
              listen: false,
            );

            await provider.addMoodEntry(
              level: _selectedLevel,
              status: _selectedStatus,
              rating: _rating.toInt(),
              notes: _notesController.text.isEmpty ? null : _notesController.text,
            );

            Navigator.of(context).pop();
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mood added successfully!')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDFFBA7),
            foregroundColor: Colors.black,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// ========== HEART RATE DIALOG ==========
class AddHeartRateDialog extends StatefulWidget {
  const AddHeartRateDialog({super.key});

  @override
  State<AddHeartRateDialog> createState() => _AddHeartRateDialogState();
}

class _AddHeartRateDialogState extends State<AddHeartRateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _bpmController = TextEditingController();
  final _hrvController = TextEditingController();

  @override
  void dispose() {
    _bpmController.dispose();
    _hrvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Heart Rate', style: TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _bpmController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'BPM',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter heart rate';
                }
                final bpm = int.tryParse(value);
                if (bpm == null || bpm < 30 || bpm > 220) {
                  return 'Please enter a valid heart rate (30-220)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hrvController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'HRV (ms) - Optional',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final provider = Provider.of<FirebaseMetricsProvider>(
                context,
                listen: false,
              );

              await provider.addHeartRateEntry(
                int.parse(_bpmController.text),
                variability: _hrvController.text.isEmpty
                    ? null
                    : int.parse(_hrvController.text),
              );

              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Heart rate added successfully!')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDFFBA7),
            foregroundColor: Colors.black,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// ========== HELPER FUNCTION ==========
void showAddMetricDialog(BuildContext context, String metricType) {
  switch (metricType) {
    case 'Steps':
      showDialog(context: context, builder: (_) => const AddStepsDialog());
      break;
    case 'Sleep':
      showDialog(context: context, builder: (_) => const AddSleepDialog());
      break;
    case 'Mood':
      showDialog(context: context, builder: (_) => const AddMoodDialog());
      break;
    case 'Heart rate':
      showDialog(context: context, builder: (_) => const AddHeartRateDialog());
      break;
    default:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add dialog for $metricType not implemented yet')),
      );
  }
}