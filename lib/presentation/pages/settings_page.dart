import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/bloom_date_utils.dart';
import '../viewmodels/app_scope.dart';
import '../widgets/common/soft_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = AppScope.of(context);
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset(AppConstants.logoAsset, width: 92, height: 92),
                  Text(
                    vm.profile.name.trim().isEmpty
                        ? AppConstants.appName
                        : vm.profile.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    vm.profile.birthDate == null
                        ? AppConstants.tagline
                        : '${BloomDateUtils.full(vm.profile.birthDate!)}'
                              '${vm.profile.age == null ? '' : '  |  ${vm.profile.age} years'}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SoftCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Personal details'),
                subtitle: Text(
                  [
                        if (vm.profile.name.trim().isNotEmpty) vm.profile.name,
                        if (vm.profile.birthDate != null)
                          BloomDateUtils.full(vm.profile.birthDate!),
                      ].isEmpty
                      ? 'Add name and birthday'
                      : [
                          if (vm.profile.name.trim().isNotEmpty)
                            vm.profile.name,
                          if (vm.profile.birthDate != null)
                            BloomDateUtils.full(vm.profile.birthDate!),
                        ].join('  |  '),
                ),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => _showEditProfileSheet(context),
              ),
            ),
            const SizedBox(height: 14),
            SoftCard(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dark theme'),
                    subtitle: const Text('Rose night mode for low light'),
                    value: vm.profile.darkMode,
                    onChanged: vm.toggleDarkMode,
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('In-app notifications'),
                    subtitle: const Text(
                      'Predicted period reminders on this device',
                    ),
                    value: vm.profile.remindersEnabled,
                    onChanged: vm.toggleReminders,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'All cycle, mood, symptom, weight, sleep, temperature and intimacy data is stored only in the local SQLite database on this device.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SoftCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Add predicted period to Google Calendar'),
                subtitle: Text(BloomDateUtils.full(vm.nextPeriodStart)),
                trailing: const Icon(Icons.chevron_right),
                onTap: vm.addNextPeriodToCalendar,
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _showEditProfileSheet(BuildContext context) {
  final profile = AppScope.of(context).profile;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _EditProfileSheet(
      initialName: profile.name,
      initialBirthDate: profile.birthDate,
    ),
  );
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({
    required this.initialName,
    required this.initialBirthDate,
  });

  final String initialName;
  final DateTime? initialBirthDate;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _birthDate = widget.initialBirthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          Text(
            'Personal details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickBirthDate,
            icon: const Icon(Icons.cake_outlined),
            label: Text(
              _birthDate == null
                  ? 'Add birthday'
                  : 'Birthday: ${BloomDateUtils.full(_birthDate!)}',
            ),
          ),
          if (_birthDate != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _birthDate = null),
                icon: const Icon(Icons.close),
                label: const Text('Remove birthday'),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                await AppScope.of(context).updateProfile(
                  name: _nameController.text,
                  birthDate: _birthDate,
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save profile'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate:
          _birthDate ?? DateTime(today.year - 18, today.month, today.day),
      firstDate: DateTime(today.year - 120, today.month, today.day),
      lastDate: today,
    );
    if (selected != null) {
      setState(() => _birthDate = selected);
    }
  }
}
