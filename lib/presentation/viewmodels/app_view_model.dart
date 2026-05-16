import 'dart:math' as math;
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../../core/utils/bloom_date_utils.dart';
import '../../data/models/period_entry.dart';
import '../../data/models/profile_settings.dart';
import '../../data/models/wellness_log.dart';
import '../../data/repositories/tracker_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/calendar_service.dart';
import '../../data/services/notification_service.dart';

class AppViewModel extends ChangeNotifier {
  AppViewModel({
    required TrackerRepository repository,
    required NotificationService notificationService,
    required CalendarService calendarService,
    required AuthService authService,
  }) : _repository = repository,
       _notificationService = notificationService,
       _calendarService = calendarService,
       _authService = authService;

  final TrackerRepository _repository;
  final NotificationService _notificationService;
  final CalendarService _calendarService;
  final AuthService _authService;

  List<PeriodEntry> periods = const [];
  List<WellnessLog> wellnessLogs = const [];
  ProfileSettings profile = const ProfileSettings();
  bool isLoading = true;
  bool isAppUnlocked = false;
  int selectedTab = 0;

  ThemeMode get themeMode =>
      profile.darkMode ? ThemeMode.dark : ThemeMode.light;

  PeriodEntry? get latestPeriod => periods.isEmpty ? null : periods.first;

  int get averagePeriodLength {
    if (periods.isEmpty) return profile.averagePeriodLength;
    final total = periods.fold<int>(
      0,
      (sum, period) => sum + period.periodLength,
    );
    return (total / periods.length).round().clamp(3, 9);
  }

  int get averageCycleLength {
    if (periods.length < 2) return profile.averageCycleLength;
    final sorted = [...periods]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final gaps = <int>[];
    for (var i = 1; i < sorted.length; i++) {
      gaps.add(sorted[i].startDate.difference(sorted[i - 1].startDate).inDays);
    }
    final average = gaps.fold<int>(0, (sum, gap) => sum + gap) / gaps.length;
    return average.round().clamp(21, 40);
  }

  DateTime get nextPeriodStart {
    final today = BloomDateUtils.dateOnly(DateTime.now());
    final latest = latestPeriod;
    if (latest == null) {
      return today.add(Duration(days: averageCycleLength));
    }

    var predicted = BloomDateUtils.dateOnly(
      latest.startDate,
    ).add(Duration(days: averageCycleLength));
    while (predicted.isBefore(today)) {
      predicted = predicted.add(Duration(days: averageCycleLength));
    }
    return predicted;
  }

  DateTime get ovulationDate =>
      nextPeriodStart.subtract(const Duration(days: 14));

  DateTime get fertileStart => ovulationDate.subtract(const Duration(days: 5));

  DateTime get fertileEnd => ovulationDate.add(const Duration(days: 1));

  DateTime get bestConceptionDay => ovulationDate;

  DateTime get intimacyWindowStart =>
      ovulationDate.subtract(const Duration(days: 2));

  DateTime get intimacyWindowEnd => ovulationDate;

  String get fertilitySuggestion {
    return 'Highest chance is around ${BloomDateUtils.full(bestConceptionDay)}, '
        'with a strong window from ${BloomDateUtils.dayMonth(intimacyWindowStart)} '
        'to ${BloomDateUtils.dayMonth(intimacyWindowEnd)}.';
  }

  DateTime? get pregnancyStartDate {
    return profile.pregnancyStartDate ?? latestPeriod?.startDate;
  }

  bool get hasPregnancyTrackingDate =>
      profile.pregnancyTrackingEnabled && pregnancyStartDate != null;

  DateTime? get estimatedDueDate {
    final start = pregnancyStartDate;
    if (!profile.pregnancyTrackingEnabled || start == null) return null;
    return start.add(const Duration(days: 280));
  }

  int? get pregnancyDay {
    final start = pregnancyStartDate;
    if (!profile.pregnancyTrackingEnabled || start == null) return null;
    return math.max(
      0,
      BloomDateUtils.dateOnly(
        DateTime.now(),
      ).difference(BloomDateUtils.dateOnly(start)).inDays,
    );
  }

  int? get pregnancyWeek {
    final day = pregnancyDay;
    if (day == null) return null;
    return ((day / 7).floor() + 1).clamp(1, 42).toInt();
  }

  int? get daysUntilDueDate {
    final due = estimatedDueDate;
    if (due == null) return null;
    return math.max(
      0,
      BloomDateUtils.dateOnly(
        due,
      ).difference(BloomDateUtils.dateOnly(DateTime.now())).inDays,
    );
  }

  String get pregnancyTrimester {
    final week = pregnancyWeek;
    if (week == null) return 'Not started';
    if (week < 14) return 'First trimester';
    if (week < 28) return 'Second trimester';
    return 'Third trimester';
  }

  String get pregnancyMilestone {
    final week = pregnancyWeek;
    if (week == null) {
      return 'Turn on tracking and choose the first day of your last period.';
    }
    if (week <= 4) return 'Early signs may begin around this time.';
    if (week <= 8) return 'A first prenatal visit is commonly planned soon.';
    if (week <= 12) return 'Early screening conversations often happen now.';
    if (week <= 20) return 'The anatomy scan window is getting close.';
    if (week <= 28) return 'Movement patterns may become easier to notice.';
    if (week <= 36) return 'Birth planning and hospital bag prep fit here.';
    return 'You are in the final stretch near the estimated due date.';
  }

  int get daysUntilNextPeriod {
    return math.max(
      0,
      nextPeriodStart
          .difference(BloomDateUtils.dateOnly(DateTime.now()))
          .inDays,
    );
  }

  int get currentCycleDay {
    final latest = latestPeriod;
    if (latest == null) return 1;
    return math.max(
      1,
      BloomDateUtils.dateOnly(
            DateTime.now(),
          ).difference(BloomDateUtils.dateOnly(latest.startDate)).inDays +
          1,
    );
  }

  String get currentPhase {
    final today = BloomDateUtils.dateOnly(DateTime.now());
    final latest = latestPeriod;
    if (latest != null &&
        BloomDateUtils.isBetween(today, latest.startDate, latest.endDate)) {
      return 'Period phase';
    }
    if (BloomDateUtils.isSameDay(today, ovulationDate)) return 'Ovulation day';
    if (BloomDateUtils.isBetween(today, fertileStart, fertileEnd)) {
      return 'Fertile window';
    }
    if (today.isBefore(ovulationDate)) return 'Follicular phase';
    return 'Luteal phase';
  }

  List<double> get recentCycleLengths {
    if (periods.length < 2) return const [];
    final sorted = [...periods]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final values = <double>[];
    for (var i = 1; i < sorted.length; i++) {
      values.add(
        sorted[i].startDate
            .difference(sorted[i - 1].startDate)
            .inDays
            .toDouble(),
      );
    }
    return values.length > 8 ? values.sublist(values.length - 8) : values;
  }

  Map<String, int> get symptomCounts {
    final counts = <String, int>{};
    for (final log in wellnessLogs.take(30)) {
      for (final symptom in log.symptoms) {
        counts[symptom] = (counts[symptom] ?? 0) + 1;
      }
    }
    return counts;
  }

  double get cycleRegularityScore {
    final lengths = recentCycleLengths;
    if (lengths.length < 2) return 0.72;
    final average = lengths.reduce((a, b) => a + b) / lengths.length;
    final variance =
        lengths
            .map((length) => math.pow(length - average, 2))
            .reduce((a, b) => a + b) /
        lengths.length;
    return (1 - (math.sqrt(variance) / 10)).clamp(0.1, 1.0);
  }

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();
    await _loadData();
    isLoading = false;
    await _syncReminders();
    notifyListeners();
  }

  Future<void> _refreshData() async {
    await _loadData();
    await _syncReminders();
    notifyListeners();
  }

  Future<void> _loadData() async {
    profile = await _repository.getProfile();
    periods = await _repository.getPeriods();
    wellnessLogs = await _repository.getWellnessLogs();
  }

  Future<void> addPeriod({
    required DateTime start,
    required DateTime end,
    required int flowIntensity,
    required String notes,
  }) async {
    await _repository.addPeriod(
      PeriodEntry(
        startDate: BloomDateUtils.dateOnly(start),
        endDate: BloomDateUtils.dateOnly(end),
        flowIntensity: flowIntensity,
        notes: notes,
      ),
    );
    await _refreshData();
  }

  Future<void> addWellnessLog(WellnessLog log) async {
    await _repository.addWellnessLog(log);
    await _refreshData();
  }

  Future<void> deletePeriod(int id) async {
    await _repository.deletePeriod(id);
    await _refreshData();
  }

  void setTab(int index) {
    selectedTab = index;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool enabled) async {
    profile = profile.copyWith(darkMode: enabled);
    await _repository.saveProfile(profile);
    notifyListeners();
  }

  Future<bool> authenticateAppLock() async {
    final unlocked = await _authService.authenticate();
    isAppUnlocked = unlocked;
    notifyListeners();
    return unlocked;
  }

  Future<bool> enableDeviceAppLock() async {
    final supported = await _authService.isDeviceLockAvailable();
    if (!supported) return false;

    final authenticated = await _authService.authenticate();
    if (!authenticated) return false;

    profile = profile.copyWith(lockMethod: 'device', clearPinHash: true);
    isAppUnlocked = true;
    await _repository.saveProfile(profile);
    notifyListeners();
    return true;
  }

  Future<void> enablePinAppLock(String pin) async {
    profile = profile.copyWith(lockMethod: 'pin', appPinHash: _hashPin(pin));
    isAppUnlocked = true;
    await _repository.saveProfile(profile);
    notifyListeners();
  }

  Future<void> disableAppLock() async {
    profile = profile.copyWith(lockMethod: 'none', clearPinHash: true);
    isAppUnlocked = false;
    await _repository.saveProfile(profile);
    notifyListeners();
  }

  Future<bool> unlockWithPin(String pin) async {
    final unlocked = profile.usesPinLock && profile.appPinHash == _hashPin(pin);
    isAppUnlocked = unlocked;
    notifyListeners();
    return unlocked;
  }

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode('blooom-local-pin:$pin')).toString();
  }

  Future<void> updateProfile({
    required String name,
    required DateTime? birthDate,
    String? profileImageBase64,
    bool clearProfileImage = false,
  }) async {
    profile = profile.copyWith(
      name: name.trim(),
      birthDate: birthDate == null ? null : BloomDateUtils.dateOnly(birthDate),
      clearBirthDate: birthDate == null,
      profileImageBase64: profileImageBase64,
      clearProfileImage: clearProfileImage,
    );
    await _repository.saveProfile(profile);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    profile = profile.copyWith(onboardingCompleted: true);
    await _repository.saveProfile(profile);
    notifyListeners();
  }

  Future<void> toggleReminders(bool enabled) async {
    profile = profile.copyWith(remindersEnabled: enabled);
    await _repository.saveProfile(profile);
    await _syncReminders();
    notifyListeners();
  }

  Future<void> toggleFertilitySuggestions(bool enabled) async {
    profile = profile.copyWith(fertilitySuggestionsEnabled: enabled);
    await _repository.saveProfile(profile);
    notifyListeners();
  }

  Future<void> togglePregnancyTracking(bool enabled) async {
    final startDate = profile.pregnancyStartDate ?? latestPeriod?.startDate;
    profile = profile.copyWith(
      pregnancyTrackingEnabled: enabled,
      pregnancyStartDate: enabled && startDate != null
          ? BloomDateUtils.dateOnly(startDate)
          : null,
      clearPregnancyStartDate: !enabled,
    );
    await _repository.saveProfile(profile);
    notifyListeners();
  }

  Future<void> updatePregnancyStartDate(DateTime? startDate) async {
    profile = profile.copyWith(
      pregnancyTrackingEnabled: startDate != null,
      pregnancyStartDate: startDate == null
          ? null
          : BloomDateUtils.dateOnly(startDate),
      clearPregnancyStartDate: startDate == null,
    );
    await _repository.saveProfile(profile);
    notifyListeners();
  }

  Future<bool> addNextPeriodToCalendar() {
    return _calendarService.addPeriodReminder(
      startDate: nextPeriodStart,
      periodLength: averagePeriodLength,
    );
  }

  Future<void> _syncReminders() async {
    if (profile.remindersEnabled) {
      await _notificationService.schedulePeriodReminders(nextPeriodStart);
    }
  }
}
