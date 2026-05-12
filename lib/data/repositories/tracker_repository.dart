import 'package:sqflite/sqflite.dart';

import '../models/period_entry.dart';
import '../models/profile_settings.dart';
import '../models/wellness_log.dart';
import '../services/database_service.dart';

class TrackerRepository {
  TrackerRepository(this._databaseService);

  final DatabaseService _databaseService;

  Future<Database> get _db => _databaseService.database;

  Future<List<PeriodEntry>> getPeriods() async {
    final rows = await (await _db).query('periods', orderBy: 'start_date DESC');
    return rows.map(PeriodEntry.fromMap).toList();
  }

  Future<void> addPeriod(PeriodEntry entry) async {
    await (await _db).insert('periods', entry.toMap()..remove('id'));
  }

  Future<void> deletePeriod(int id) async {
    await (await _db).delete('periods', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<WellnessLog>> getWellnessLogs() async {
    final rows = await (await _db).query('wellness_logs', orderBy: 'date DESC');
    return rows.map(WellnessLog.fromMap).toList();
  }

  Future<void> addWellnessLog(WellnessLog log) async {
    await (await _db).insert('wellness_logs', log.toMap()..remove('id'));
  }

  Future<ProfileSettings> getProfile() async {
    final rows = await (await _db).query('profile_settings', limit: 1);
    if (rows.isEmpty) {
      const profile = ProfileSettings();
      await saveProfile(profile);
      return profile;
    }
    return ProfileSettings.fromMap(rows.first);
  }

  Future<void> saveProfile(ProfileSettings profile) async {
    await (await _db).insert(
      'profile_settings',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
