import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/period_entry.dart';
import '../models/profile_settings.dart';
import '../models/wellness_log.dart';
import '../services/database_service.dart';

class TrackerRepository {
  TrackerRepository(DatabaseService databaseService);

  static const _periodsKey = 'blooom_web_periods';
  static const _wellnessKey = 'blooom_web_wellness_logs';
  static const _profileKey = 'blooom_web_profile';

  Future<List<PeriodEntry>> getPeriods() async {
    final prefs = await SharedPreferences.getInstance();
    final rows = _decodeRows(prefs.getString(_periodsKey));
    final periods = rows.map(PeriodEntry.fromMap).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return periods;
  }

  Future<void> addPeriod(PeriodEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final rows = _decodeRows(prefs.getString(_periodsKey));
    final nextId = _nextId(rows);
    rows.add(entry.copyWith(id: nextId).toMap());
    await prefs.setString(_periodsKey, jsonEncode(rows));
  }

  Future<void> deletePeriod(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final rows = _decodeRows(prefs.getString(_periodsKey))
      ..removeWhere((row) => row['id'] == id);
    await prefs.setString(_periodsKey, jsonEncode(rows));
  }

  Future<List<WellnessLog>> getWellnessLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final rows = _decodeRows(prefs.getString(_wellnessKey));
    final logs = rows.map(WellnessLog.fromMap).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return logs;
  }

  Future<void> addWellnessLog(WellnessLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final rows = _decodeRows(prefs.getString(_wellnessKey));
    final nextId = _nextId(rows);
    rows.add(log.toMap()..['id'] = nextId);
    await prefs.setString(_wellnessKey, jsonEncode(rows));
  }

  Future<ProfileSettings> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(_profileKey);
    if (text == null) {
      const profile = ProfileSettings();
      await saveProfile(profile);
      return profile;
    }
    return ProfileSettings.fromMap(_decodeRow(text));
  }

  Future<void> saveProfile(ProfileSettings profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toMap()));
  }

  List<Map<String, Object?>> _decodeRows(String? text) {
    if (text == null || text.isEmpty) return [];
    final decoded = jsonDecode(text) as List<dynamic>;
    return decoded
        .map((item) => Map<String, Object?>.from(item as Map))
        .toList();
  }

  Map<String, Object?> _decodeRow(String text) {
    return Map<String, Object?>.from(jsonDecode(text) as Map);
  }

  int _nextId(List<Map<String, Object?>> rows) {
    final ids = rows.map((row) => row['id']).whereType<int>();
    return ids.isEmpty ? 1 : ids.reduce((a, b) => a > b ? a : b) + 1;
  }
}
