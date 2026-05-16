import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

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
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        final displayName = vm.profile.name.trim().isEmpty
            ? AppConstants.appName
            : vm.profile.name.trim();
        final profileCaption = vm.profile.birthDate == null
            ? AppConstants.tagline
            : '${BloomDateUtils.full(vm.profile.birthDate!)}'
                  '${vm.profile.age == null ? '' : ' | ${vm.profile.age} years'}';
        final personalSubtitle =
            [
              if (vm.profile.name.trim().isNotEmpty) vm.profile.name.trim(),
              if (vm.profile.birthDate != null)
                BloomDateUtils.full(vm.profile.birthDate!),
            ].isEmpty
            ? 'Add name and birthday'
            : [
                if (vm.profile.name.trim().isNotEmpty) vm.profile.name.trim(),
                if (vm.profile.birthDate != null)
                  BloomDateUtils.full(vm.profile.birthDate!),
              ].join(' | ');

        final profileHero = _ProfileHero(
          name: displayName,
          caption: profileCaption,
          imageBase64: vm.profile.profileImageBase64,
          onChangePhoto: () => _showProfileImageSheet(context),
        );
        final personalCard = _ProfileActionCard(
          icon: Icons.badge_outlined,
          title: 'Personal details',
          subtitle: personalSubtitle,
          trailing: Icons.edit_outlined,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              AppColors.rose200.withValues(alpha: 0.64),
              AppColors.rose300.withValues(alpha: 0.42),
            ],
          ),
          onTap: () => _showEditProfileSheet(context),
        );
        final privacyCard = const _PrivacyCard();
        final pregnancyCard = _PregnancyCard(
          enabled: vm.profile.pregnancyTrackingEnabled,
          subtitle: vm.profile.pregnancyTrackingEnabled
              ? vm.hasPregnancyTrackingDate
                    ? 'Week ${vm.pregnancyWeek} | Due ${BloomDateUtils.full(vm.estimatedDueDate!)}'
                    : 'Choose the first day of your last period'
              : 'Track week, trimester, due date and milestones',
          startDateText: vm.pregnancyStartDate == null
              ? 'Choose date'
              : BloomDateUtils.full(vm.pregnancyStartDate!),
          trimester: vm.pregnancyTrimester,
          milestone: vm.pregnancyMilestone,
          hasTrackingDate: vm.hasPregnancyTrackingDate,
          onChanged: vm.togglePregnancyTracking,
          onPickStartDate: () => _pickPregnancyStartDate(context),
        );
        final calendarCard = _ProfileActionCard(
          icon: Icons.calendar_today_outlined,
          title: 'Add predicted period to Google Calendar',
          subtitle: BloomDateUtils.full(vm.nextPeriodStart),
          trailing: Icons.chevron_right,
          onTap: () => exportNextPeriodToCalendar(context),
        );
        final preferencesCard = _PreferencesCard(
          darkMode: vm.profile.darkMode,
          remindersEnabled: vm.profile.remindersEnabled,
          fertilitySuggestionsEnabled: vm.profile.fertilitySuggestionsEnabled,
          appLockEnabled: vm.profile.appLockEnabled,
          appLockSubtitle: vm.profile.usesPinLock
              ? 'PIN is required before opening Blooom'
              : vm.profile.usesDeviceLock
              ? 'Device lock or biometrics are required'
              : 'Add Face ID, fingerprint, device lock, or PIN',
          onDarkModeChanged: vm.toggleDarkMode,
          onRemindersChanged: vm.toggleReminders,
          onFertilityChanged: vm.toggleFertilitySuggestions,
          onAppLockChanged: (enabled) async {
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
        );
        return AnimatedPageList(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.caption,
    required this.onChangePhoto,
    this.imageBase64,
  });

  final String name;
  final String caption;
  final String? imageBase64;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          _ProfilePhoto(imageBase64: imageBase64, onTap: onChangePhoto),
          const SizedBox(height: 10),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.onTap, this.imageBase64});

  final String? imageBase64;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageBytes = _decodeProfileImage(imageBase64);

    return Semantics(
      button: true,
      label: imageBytes == null ? 'Add profile photo' : 'Change profile photo',
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              padding: imageBytes == null ? const EdgeInsets.all(12) : null,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface.withValues(alpha: 0.78),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipOval(
                child: imageBytes == null
                    ? Image.asset(AppConstants.logoAsset)
                    : Image.memory(
                        imageBytes,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: 2,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.rose400,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionCard extends StatelessWidget {
  const _ProfileActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.gradient,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final IconData trailing;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      gradient: gradient,
      child: _ProfileSettingRow(
        icon: icon,
        title: title,
        subtitle: subtitle,
        trailing: Icon(trailing),
        onTap: onTap,
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Your cycle, mood, symptom, sleep, weight, temperature and intimacy details stay private on this device.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.34),
          ),
        ],
      ),
    );
  }
}

class _PregnancyCard extends StatelessWidget {
  const _PregnancyCard({
    required this.enabled,
    required this.subtitle,
    required this.startDateText,
    required this.trimester,
    required this.milestone,
    required this.hasTrackingDate,
    required this.onChanged,
    required this.onPickStartDate,
  });

  final bool enabled;
  final String subtitle;
  final String startDateText;
  final String trimester;
  final String milestone;
  final bool hasTrackingDate;
  final ValueChanged<bool> onChanged;
  final VoidCallback onPickStartDate;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.mint.withValues(alpha: 0.26),
          Theme.of(context).colorScheme.surface.withValues(alpha: 0.56),
          AppColors.rose200.withValues(alpha: 0.36),
        ],
      ),
      child: Column(
        children: [
          _ProfileSettingRow(
            icon: Icons.child_friendly_outlined,
            title: 'Pregnancy tracking',
            subtitle: subtitle,
            trailing: _ProfileSwitch(value: enabled, onChanged: onChanged),
          ),
          if (enabled) ...[
            const _ProfileDivider(),
            _ProfileSettingRow(
              icon: Icons.event_outlined,
              title: 'Last period start date',
              subtitle: startDateText,
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: onPickStartDate,
            ),
            if (hasTrackingDate) ...[
              const _ProfileDivider(),
              _ProfileSettingRow(
                icon: Icons.flag_outlined,
                title: trimester,
                subtitle: milestone,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({
    required this.darkMode,
    required this.remindersEnabled,
    required this.fertilitySuggestionsEnabled,
    required this.appLockEnabled,
    required this.appLockSubtitle,
    required this.onDarkModeChanged,
    required this.onRemindersChanged,
    required this.onFertilityChanged,
    required this.onAppLockChanged,
  });

  final bool darkMode;
  final bool remindersEnabled;
  final bool fertilitySuggestionsEnabled;
  final bool appLockEnabled;
  final String appLockSubtitle;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onRemindersChanged;
  final ValueChanged<bool> onFertilityChanged;
  final ValueChanged<bool> onAppLockChanged;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.rose50.withValues(alpha: 0.88),
          AppColors.lavender.withValues(alpha: 0.30),
          AppColors.rose200.withValues(alpha: 0.30),
        ],
      ),
      child: Column(
        children: [
          _PreferenceSwitchRow(
            title: 'Dark theme',
            subtitle: 'Rose night mode for low light',
            value: darkMode,
            onChanged: onDarkModeChanged,
          ),
          const _ProfileDivider(),
          _PreferenceSwitchRow(
            title: 'In-app notifications',
            subtitle: 'Predicted period reminders on this device',
            value: remindersEnabled,
            onChanged: onRemindersChanged,
          ),
          const _ProfileDivider(),
          _PreferenceSwitchRow(
            title: 'Best conception day suggestions',
            subtitle: 'Show highest-chance intimacy dates from your cycle',
            value: fertilitySuggestionsEnabled,
            onChanged: onFertilityChanged,
          ),
          const _ProfileDivider(),
          _PreferenceSwitchRow(
            title: 'App lock',
            subtitle: appLockSubtitle,
            value: appLockEnabled,
            onChanged: onAppLockChanged,
          ),
        ],
      ),
    );
  }
}

class _ProfileSettingRow extends StatelessWidget {
  const _ProfileSettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 28,
          child: Icon(
            icon,
            size: 22,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.24,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          IconTheme(
            data: IconThemeData(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
              size: 23,
            ),
            child: trailing!,
          ),
        ],
      ],
    );

    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: content,
      ),
    );
  }
}

class _PreferenceSwitchRow extends StatelessWidget {
  const _PreferenceSwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _ProfileSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ProfileSwitch extends StatelessWidget {
  const _ProfileSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.rose400,
      inactiveThumbColor: scheme.onSurfaceVariant.withValues(alpha: 0.72),
      inactiveTrackColor: scheme.surface.withValues(alpha: 0.72),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.transparent
            : scheme.onSurfaceVariant.withValues(alpha: 0.62),
      ),
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  const _ProfileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 24,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

Uint8List? _decodeProfileImage(String? imageBase64) {
  if (imageBase64 == null || imageBase64.isEmpty) return null;
  try {
    return base64Decode(imageBase64);
  } on FormatException {
    return null;
  }
}

Future<void> _showProfileImageSheet(BuildContext context) {
  final hasPhoto = AppScope.of(context).profile.profileImageBase64 != null;
  return showAdaptiveModal<void>(
    context: context,
    webMaxWidth: 520,
    builder: (_) =>
        _ProfileImageSheet(parentContext: context, hasPhoto: hasPhoto),
  );
}

class _ProfileImageSheet extends StatelessWidget {
  const _ProfileImageSheet({
    required this.parentContext,
    required this.hasPhoto,
  });

  final BuildContext parentContext;
  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile photo', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Choose a photo for your Profile page.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _ProfileImageOption(
            icon: Icons.photo_library_outlined,
            title: 'Choose from gallery',
            subtitle: 'Pick a saved photo from this device',
            onTap: () => _pickProfileImage(context, parentContext),
          ),
          if (hasPhoto)
            _ProfileImageOption(
              icon: Icons.delete_outline,
              title: 'Remove photo',
              subtitle: 'Use the Blooom logo again',
              onTap: () => _removeProfileImage(context, parentContext),
            ),
        ],
      ),
    );
  }
}

class _ProfileImageOption extends StatelessWidget {
  const _ProfileImageOption({
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

Future<void> _pickProfileImage(
  BuildContext sheetContext,
  BuildContext parentContext,
) async {
  final navigator = Navigator.of(sheetContext);
  final messenger = ScaffoldMessenger.of(parentContext);
  final picker = ImagePicker();
  final image = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 720,
    maxHeight: 720,
    imageQuality: 82,
  );
  if (image == null) return;

  final bytes = await image.readAsBytes();
  if (!parentContext.mounted || !sheetContext.mounted) return;
  await AppScope.of(parentContext).updateProfile(
    name: AppScope.of(parentContext).profile.name,
    birthDate: AppScope.of(parentContext).profile.birthDate,
    profileImageBase64: base64Encode(bytes),
  );
  if (!parentContext.mounted || !sheetContext.mounted) return;
  navigator.pop();
  messenger.showSnackBar(
    const SnackBar(content: Text('Profile photo updated.')),
  );
}

Future<void> _removeProfileImage(
  BuildContext sheetContext,
  BuildContext parentContext,
) async {
  final navigator = Navigator.of(sheetContext);
  final messenger = ScaffoldMessenger.of(parentContext);
  final profile = AppScope.of(parentContext).profile;
  await AppScope.of(parentContext).updateProfile(
    name: profile.name,
    birthDate: profile.birthDate,
    clearProfileImage: true,
  );
  if (!parentContext.mounted || !sheetContext.mounted) return;
  navigator.pop();
  messenger.showSnackBar(
    const SnackBar(content: Text('Profile photo removed.')),
  );
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
  bool _saving = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.18),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.pin_outlined,
                          color: scheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Set Blooom PIN',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use 4 to 6 digits to unlock your private health data.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.32,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _PinTextField(
                    controller: _pinController,
                    label: 'PIN',
                    autofocus: true,
                    onSubmitted: (_) => _savePin(),
                  ),
                  const SizedBox(height: 12),
                  _PinTextField(
                    controller: _confirmController,
                    label: 'Confirm PIN',
                    errorText: _error,
                    onSubmitted: (_) => _savePin(),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _saving ? null : _savePin,
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save PIN'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _savePin() async {
    if (_saving) return;
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
    setState(() {
      _saving = true;
      _error = null;
    });
    await AppScope.of(context).enablePinAppLock(pin);
    if (!mounted) return;
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('PIN app lock enabled.')),
    );
  }
}

class _PinTextField extends StatelessWidget {
  const _PinTextField({
    required this.controller,
    required this.label,
    required this.onSubmitted,
    this.autofocus = false,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onSubmitted;
  final bool autofocus;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      obscureText: true,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        counterText: '',
        prefixIcon: const Icon(Icons.lock_outline),
        filled: true,
      ),
      onSubmitted: onSubmitted,
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
