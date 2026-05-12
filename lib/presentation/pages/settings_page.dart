import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/bloom_date_utils.dart';
import '../viewmodels/app_scope.dart';
import '../widgets/common/animated_content.dart';
import '../widgets/common/calendar_export.dart';
import '../widgets/common/soft_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = AppScope.of(context);
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        return AnimatedPageList(
          children: [
            Center(
              child: Column(
                children: [
                  Hero(
                    tag: 'blooom-logo',
                    child: Image.asset(
                      AppConstants.logoAsset,
                      width: 92,
                      height: 92,
                    ),
                  ),
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                ],
              ),
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.08),
                ],
              ),
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
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('App lock'),
                    subtitle: Text(
                      vm.profile.usesPinLock
                          ? 'PIN is required before opening Blooom'
                          : vm.profile.usesDeviceLock
                          ? 'Device lock or biometrics are required'
                          : 'Add Face ID, fingerprint, device lock, or PIN',
                    ),
                    value: vm.profile.appLockEnabled,
                    onChanged: (enabled) async {
                      if (enabled) {
                        await _showAppLockSetupSheet(context);
                      } else {
                        await vm.disableAppLock();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('App lock disabled.')),
                        );
                      }
                    },
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
                onTap: () => exportNextPeriodToCalendar(context),
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _showAppLockSetupSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (_) => _AppLockSetupSheet(parentContext: context),
  );
}

class _AppLockSetupSheet extends StatelessWidget {
  const _AppLockSetupSheet({required this.parentContext});

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose app lock',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Blooom will ask for this before showing your dashboard.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _LockOptionTile(
            icon: Icons.face,
            title: 'Face ID',
            subtitle: 'Use device face unlock when available',
            onTap: () => _enableDeviceLock(context, parentContext),
          ),
          _LockOptionTile(
            icon: Icons.fingerprint,
            title: 'Fingerprint',
            subtitle: 'Use device fingerprint unlock when available',
            onTap: () => _enableDeviceLock(context, parentContext),
          ),
          _LockOptionTile(
            icon: Icons.pin_outlined,
            title: 'Blooom PIN',
            subtitle: 'Create a private PIN saved on this device',
            onTap: () async {
              Navigator.pop(context);
              await _showSetPinDialog(parentContext);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _enableDeviceLock(
    BuildContext sheetContext,
    BuildContext parentContext,
  ) async {
    final messenger = ScaffoldMessenger.of(parentContext);
    final navigator = Navigator.of(sheetContext);
    final enabled = await AppScope.of(parentContext).enableDeviceAppLock();
    if (!parentContext.mounted || !sheetContext.mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? 'Device app lock enabled.'
              : 'Device lock or biometrics are not available.',
        ),
      ),
    );
  }
}

class _LockOptionTile extends StatelessWidget {
  const _LockOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

Future<void> _showSetPinDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _SetPinDialog(),
  );
}

class _SetPinDialog extends StatefulWidget {
  const _SetPinDialog();

  @override
  State<_SetPinDialog> createState() => _SetPinDialogState();
}

class _SetPinDialogState extends State<_SetPinDialog> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Blooom PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinController,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'PIN',
              counterText: '',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _confirmController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'Confirm PIN',
              counterText: '',
              errorText: _error,
            ),
            onSubmitted: (_) => _savePin(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _savePin, child: const Text('Save PIN')),
      ],
    );
  }

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    final confirm = _confirmController.text.trim();
    if (pin.length < 4) {
      setState(() => _error = 'Use at least 4 digits.');
      return;
    }
    if (pin != confirm) {
      setState(() => _error = 'PIN does not match.');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    await AppScope.of(context).enablePinAppLock(pin);
    if (!mounted) return;
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('PIN app lock enabled.')),
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
