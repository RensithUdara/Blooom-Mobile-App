import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sheetMaxHeight = MediaQuery.sizeOf(context).height * 0.78;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: sheetMaxHeight),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18, 8, 18, bottom + 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.rose400,
                        AppColors.lavender.withValues(alpha: 0.82),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.rose400.withValues(alpha: 0.24),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.spa_outlined, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Daily wellness',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _WellnessSection(
              title: 'Mood',
              icon: Icons.mood_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _moods
                    .map(
                      (mood) => _WellnessChip(
                        label: mood,
                        selected: _mood == mood,
                        onSelected: (_) => setState(() => _mood = mood),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            _WellnessSection(
              title: 'Symptoms',
              icon: Icons.healing_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _symptoms
                    .map(
                      (symptom) => _WellnessChip(
                        label: symptom,
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
            ),
            const SizedBox(height: 12),
            _WellnessSection(
              title: 'Energy',
              icon: Icons.bolt_outlined,
              trailing: _ValuePill(value: '${_energy.round()}/5'),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.rose400,
                  inactiveTrackColor: AppColors.rose100,
                  thumbColor: AppColors.rose400,
                  overlayColor: AppColors.rose400.withValues(alpha: 0.12),
                  trackHeight: 5,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                ),
                child: Slider(
                  value: _energy,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (value) => setState(() => _energy = value),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ResponsiveFieldGrid(
              children: [
                _NumberField(
                  controller: _weight,
                  label: 'Weight kg',
                  icon: Icons.monitor_weight_outlined,
                ),
                _NumberField(
                  controller: _temperature,
                  label: 'Temp C',
                  icon: Icons.thermostat_outlined,
                ),
                _NumberField(
                  controller: _sleep,
                  label: 'Sleep hours',
                  icon: Icons.bedtime_outlined,
                ),
                _NumberField(
                  controller: _water,
                  label: 'Water glasses',
                  icon: Icons.water_drop_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.56),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.36),
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.favorite_outline),
                    title: const Text('Sex or intimacy'),
                    value: _hadSex,
                    onChanged: (value) => setState(() => _hadSex = value),
                  ),
                  if (_hadSex) ...[
                    Divider(
                      color: scheme.outlineVariant.withValues(alpha: 0.42),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.verified_user_outlined),
                      title: const Text('Protected'),
                      value: _protectedSex,
                      onChanged: (value) =>
                          setState(() => _protectedSex = value),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              minLines: 3,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Extra notes',
                prefixIcon: Icon(Icons.notes_outlined, color: scheme.primary),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rose400.withValues(alpha: 0.22),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
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
                  icon: const Icon(Icons.check),
                  label: const Text('Save wellness log'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WellnessSection extends StatelessWidget {
  const _WellnessSection({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _WellnessChip extends StatelessWidget {
  const _WellnessChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: true,
      checkmarkColor: selected ? Colors.white : scheme.primary,
      selectedColor: AppColors.rose400,
      backgroundColor: scheme.surface,
      side: BorderSide(
        color: selected
            ? AppColors.rose400
            : scheme.outlineVariant.withValues(alpha: 0.72),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: TextStyle(
        color: selected ? Colors.white : scheme.onSurface,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.rose400.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ResponsiveFieldGrid extends StatelessWidget {
  const _ResponsiveFieldGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth < 360
            ? constraints.maxWidth
            : (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: scheme.primary),
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.64),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.16),
          ),
        ),
      ),
    );
  }
}
