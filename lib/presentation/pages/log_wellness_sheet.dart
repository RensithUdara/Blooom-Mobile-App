import 'package:flutter/material.dart';

import '../../data/models/wellness_log.dart';
import '../viewmodels/app_scope.dart';
import '../widgets/common/adaptive_modal.dart';

Future<void> showLogWellnessSheet(BuildContext context) {
  return showAdaptiveModal<void>(
    context: context,
    isScrollControlled: true,
    webMaxWidth: 680,
    builder: (_) => const _LogWellnessSheet(),
  );
}

class _LogWellnessSheet extends StatefulWidget {
  const _LogWellnessSheet();

  @override
  State<_LogWellnessSheet> createState() => _LogWellnessSheetState();
}

class _LogWellnessSheetState extends State<_LogWellnessSheet> {
  static const _moods = [
    'Calm',
    'Happy',
    'Energetic',
    'Sad',
    'Anxious',
    'Irritated',
  ];
  static const _symptoms = [
    'Cramps',
    'Headache',
    'Bloating',
    'Acne',
    'Tender breasts',
    'Back pain',
    'Cravings',
    'Fatigue',
  ];

  String _mood = _moods.first;
  final Set<String> _selectedSymptoms = {};
  double _energy = 3;
  final _weight = TextEditingController();
  final _temperature = TextEditingController();
  final _sleep = TextEditingController();
  final _water = TextEditingController();
  final _notes = TextEditingController();
  bool _hadSex = false;
  bool _protectedSex = true;

  @override
  void dispose() {
    _weight.dispose();
    _temperature.dispose();
    _sleep.dispose();
    _water.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18, 18, 18, bottom + 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('Daily wellness', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Mood', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _moods
                .map(
                  (mood) => ChoiceChip(
                    label: Text(mood),
                    selected: _mood == mood,
                    onSelected: (_) => setState(() => _mood = mood),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text('Symptoms', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _symptoms
                .map(
                  (symptom) => FilterChip(
                    label: Text(symptom),
                    selected: _selectedSymptoms.contains(symptom),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    }),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text('Energy ${_energy.round()}/5'),
          Slider(
            value: _energy,
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (value) => setState(() => _energy = value),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _NumberField(controller: _weight, label: 'Weight kg'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NumberField(controller: _temperature, label: 'Temp C'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _NumberField(controller: _sleep, label: 'Sleep hours'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NumberField(controller: _water, label: 'Water glasses'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sex or intimacy'),
            value: _hadSex,
            onChanged: (value) => setState(() => _hadSex = value),
          ),
          if (_hadSex)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Protected'),
              value: _protectedSex,
              onChanged: (value) => setState(() => _protectedSex = value),
            ),
          TextField(
            controller: _notes,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Extra notes'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                await AppScope.of(context).addWellnessLog(
                  WellnessLog(
                    date: DateTime.now(),
                    mood: _mood,
                    symptoms: _selectedSymptoms.toList(),
                    weightKg: double.tryParse(_weight.text),
                    temperatureC: double.tryParse(_temperature.text),
                    sleepHours: double.tryParse(_sleep.text),
                    waterGlasses: int.tryParse(_water.text),
                    energyLevel: _energy.round(),
                    hadSex: _hadSex,
                    protectedSex: _protectedSex,
                    notes: _notes.text.trim(),
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save wellness log'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }
}
