import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/utils/bloom_date_utils.dart';
import '../../data/models/period_entry.dart';
import '../../data/models/profile_settings.dart';
import '../../data/models/wellness_log.dart';
import '../../data/repositories/tracker_repository.dart';
import '../../data/services/calendar_service.dart';
import '../../data/services/notification_service.dart';

class AppViewModel extends ChangeNotifier {
  AppViewModel({
    required TrackerRepository repository,
    required NotificationService notificationService,
    required CalendarService calendarService,
  }) : _repository = repository,
       _notificationService = notificationService,
       _calendarService = calendarService;

  final TrackerRepository _repository;
  final NotificationService _notificationService;
  final CalendarService _calendarService;

  List<PeriodEntry> periods = const [];
  List<WellnessLog> wellnessLogs = const [];
  ProfileSettings profile = const ProfileSettings();
  bool isLoading = true;
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
    profile = await _repository.getProfile();
    periods = await _repository.getPeriods();
    wellnessLogs = await _repository.getWellnessLogs();
    isLoading = false;
    await _syncReminders();
    notifyListeners();
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
    await initialize();
  }

  Future<void> addWellnessLog(WellnessLog log) async {
    await _repository.addWellnessLog(log);
    await initialize();
  }

  Future<void> deletePeriod(int id) async {
    await _repository.deletePeriod(id);
    await initialize();
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

  Future<void> updateProfile({
    required String name,
    required DateTime? birthDate,
  }) async {
    profile = profile.copyWith(
      name: name.trim(),
      birthDate: birthDate == null ? null : BloomDateUtils.dateOnly(birthDate),
      clearBirthDate: birthDate == null,
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
