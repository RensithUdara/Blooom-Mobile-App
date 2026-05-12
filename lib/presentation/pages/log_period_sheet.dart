import 'package:flutter/material.dart';

import '../viewmodels/app_scope.dart';

Future<void> showLogPeriodSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _LogPeriodSheet(),
  );
}

class _LogPeriodSheet extends StatefulWidget {
  const _LogPeriodSheet();

  @override
  State<_LogPeriodSheet> createState() => _LogPeriodSheetState();
}

class _LogPeriodSheetState extends State<_LogPeriodSheet> {
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 4));
  double _flow = 3;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, bottom + 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Text('Log period', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Start',
                  date: _start,
                  onSelected: (date) => setState(() {
                    _start = date;
                    if (_end.isBefore(date)) _end = date;
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateButton(
                  label: 'End',
                  date: _end,
                  onSelected: (date) => setState(() => _end = date),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Flow intensity ${_flow.round()}/5'),
          Slider(
            value: _flow,
            min: 1,
            max: 5,
            divisions: 4,
            label: _flow.round().toString(),
            onChanged: (value) => setState(() => _flow = value),
          ),
          TextField(
            controller: _notes,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Notes, cramps, medication, anything useful',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                await AppScope.of(context).addPeriod(
                  start: _start,
                  end: _end,
                  flowIntensity: _flow.round(),
                  notes: _notes.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save period'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.onSelected,
  });

  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final today = DateTime.now();
        final selected = await showDatePicker(
          context: context,
          firstDate: DateTime(today.year - 20, today.month, today.day),
          lastDate: DateTime(today.year + 1, today.month, today.day),
          initialDate: date,
        );
        if (selected != null) onSelected(selected);
      },
      icon: const Icon(Icons.calendar_month),
      label: Text(
        '$label\n${date.month}/${date.day}/${date.year}',
        textAlign: TextAlign.center,
      ),
    );
  }
}
