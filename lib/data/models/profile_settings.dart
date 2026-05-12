class ProfileSettings {
  const ProfileSettings({
    this.name = '',
    this.birthDate,
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
    this.remindersEnabled = true,
    this.darkMode = false,
    this.onboardingCompleted = false,
    this.lockMethod = 'none',
    this.appPinHash,
  });

  final String name;
  final DateTime? birthDate;
  final int averageCycleLength;
  final int averagePeriodLength;
  final bool remindersEnabled;
  final bool darkMode;
  final bool onboardingCompleted;
  final String lockMethod;
  final String? appPinHash;

  bool get appLockEnabled => lockMethod != 'none';
  bool get usesDeviceLock => lockMethod == 'device';
  bool get usesPinLock => lockMethod == 'pin';

  int? get age {
    final birthday = birthDate;
    if (birthday == null) return null;

    final today = DateTime.now();
    var years = today.year - birthday.year;
    final hasHadBirthdayThisYear =
        today.month > birthday.month ||
        (today.month == birthday.month && today.day >= birthday.day);
    if (!hasHadBirthdayThisYear) years--;
    return years < 0 ? null : years;
  }

  ProfileSettings copyWith({
    String? name,
    DateTime? birthDate,
    bool clearBirthDate = false,
    int? averageCycleLength,
    int? averagePeriodLength,
    bool? remindersEnabled,
    bool? darkMode,
    bool? onboardingCompleted,
    String? lockMethod,
    String? appPinHash,
    bool clearPinHash = false,
  }) {
    return ProfileSettings(
      name: name ?? this.name,
      birthDate: clearBirthDate ? null : birthDate ?? this.birthDate,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodLength: averagePeriodLength ?? this.averagePeriodLength,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      darkMode: darkMode ?? this.darkMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      lockMethod: lockMethod ?? this.lockMethod,
      appPinHash: clearPinHash ? null : appPinHash ?? this.appPinHash,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': 1,
      'name': name,
      'birth_date': birthDate?.toIso8601String(),
      'average_cycle_length': averageCycleLength,
      'average_period_length': averagePeriodLength,
      'reminders_enabled': remindersEnabled ? 1 : 0,
      'dark_mode': darkMode ? 1 : 0,
      'onboarding_completed': onboardingCompleted ? 1 : 0,
      'app_lock_enabled': appLockEnabled ? 1 : 0,
      'lock_method': lockMethod,
      'app_pin_hash': appPinHash,
    };
  }

  factory ProfileSettings.fromMap(Map<String, Object?> map) {
    final birthDateText = map['birth_date'] as String?;
    return ProfileSettings(
      name: map['name'] as String? ?? '',
      birthDate: birthDateText == null
          ? null
          : DateTime.tryParse(birthDateText),
      averageCycleLength: map['average_cycle_length'] as int? ?? 28,
      averagePeriodLength: map['average_period_length'] as int? ?? 5,
      remindersEnabled: (map['reminders_enabled'] as int? ?? 1) == 1,
      darkMode: (map['dark_mode'] as int? ?? 0) == 1,
      onboardingCompleted: (map['onboarding_completed'] as int? ?? 0) == 1,
      lockMethod:
          map['lock_method'] as String? ??
          ((map['app_lock_enabled'] as int? ?? 0) == 1 ? 'device' : 'none'),
      appPinHash: map['app_pin_hash'] as String?,
    );
  }
}
