import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/bloom_date_utils.dart';
import '../viewmodels/app_scope.dart';
import '../widgets/common/animated_content.dart';
import '../widgets/common/adaptive_modal.dart';
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
        final profileHero = Center(
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
        );
        final personalCard = SoftCard(
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
                      if (vm.profile.name.trim().isNotEmpty) vm.profile.name,
                      if (vm.profile.birthDate != null)
                        BloomDateUtils.full(vm.profile.birthDate!),
                    ].join('  |  '),
            ),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => _showEditProfileSheet(context),
          ),
        );
        final preferencesCard = SoftCard(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08),
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
                title: const Text('Best conception day suggestions'),
                subtitle: const Text(
                  'Show highest-chance intimacy dates from your cycle',
                ),
                value: vm.profile.fertilitySuggestionsEnabled,
                onChanged: vm.toggleFertilitySuggestions,
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
        );
        final pregnancyCard = SoftCard(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              AppColors.mint.withValues(alpha: 0.10),
              AppColors.sky.withValues(alpha: 0.10),
            ],
          ),
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.child_friendly_outlined),
                title: const Text('Pregnancy tracking'),
                subtitle: Text(
                  vm.profile.pregnancyTrackingEnabled
                      ? vm.hasPregnancyTrackingDate
                            ? 'Week ${vm.pregnancyWeek} | Due ${BloomDateUtils.full(vm.estimatedDueDate!)}'
                            : 'Choose the first day of your last period'
                      : 'Track week, trimester, due date and milestones',
                ),
                value: vm.profile.pregnancyTrackingEnabled,
                onChanged: vm.togglePregnancyTracking,
              ),
              if (vm.profile.pregnancyTrackingEnabled) ...[
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Last period start date'),
                  subtitle: Text(
                    vm.pregnancyStartDate == null
                        ? 'Choose date'
                        : BloomDateUtils.full(vm.pregnancyStartDate!),
                  ),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () => _pickPregnancyStartDate(context),
                ),
                if (vm.hasPregnancyTrackingDate) ...[
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.flag_outlined),
                    title: Text(vm.pregnancyTrimester),
                    subtitle: Text(vm.pregnancyMilestone),
                  ),
                ],
              ],
            ],
          ),
        );
        final privacyCard = SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Privacy', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text(
                'Your cycle, mood, symptom, sleep, weight, temperature and intimacy details stay private on this device.',
              ),
            ],
          ),
        );
        final calendarCard = SoftCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: const Text('Add predicted period to Google Calendar'),
            subtitle: Text(BloomDateUtils.full(vm.nextPeriodStart)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => exportNextPeriodToCalendar(context),
          ),
        );
        return AnimatedPageList(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final details = Column(
                  children: [
                    personalCard,
                    const SizedBox(height: 14),
                    privacyCard,
                    const SizedBox(height: 14),
                    pregnancyCard,
                    const SizedBox(height: 14),
                    calendarCard,
                  ],
                );
                final preferences = Column(children: [preferencesCard]);

                if (constraints.maxWidth < 900) {
                  return Column(
                    children: [
                      profileHero,
                      const SizedBox(height: 20),
                      details,
                      const SizedBox(height: 14),
                      preferences,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 320,
                      child: Column(
                        children: [
                          SoftCard(child: profileHero),
                          const SizedBox(height: 14),
                          privacyCard,
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          personalCard,
                          const SizedBox(height: 14),
                          preferencesCard,
                          const SizedBox(height: 14),
                          pregnancyCard,
                          const SizedBox(height: 14),
                          calendarCard,
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

Future<void> _pickPregnancyStartDate(BuildContext context) async {
  final vm = AppScope.of(context);
  final today = DateTime.now();
  final initialDate =
      vm.pregnancyStartDate ??
      vm.latestPeriod?.startDate ??
      today.subtract(const Duration(days: 28));
  final selected = await showDatePicker(
    context: context,
    initialDate: initialDate.isAfter(today) ? today : initialDate,
    firstDate: today.subtract(const Duration(days: 294)),
    lastDate: today,
  );
  if (selected != null) {
    await vm.updatePregnancyStartDate(selected);
  }
}

Future<void> _showAppLockSetupSheet(BuildContext context) {
  return showAdaptiveModal<void>(
    context: context,
    webMaxWidth: 640,
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
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
      setState(() => _error = 'Use 4 to 6 digits.');
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
  return showAdaptiveModal<void>(
    context: context,
    isScrollControlled: true,
    webMaxWidth: 640,
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
