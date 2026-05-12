import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static const _databaseName = 'blooom_tracker.db';
  static const _databaseVersion = 5;

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    final databasePath = await getDatabasesPath();
    final db = await openDatabase(
      path.join(databasePath, _databaseName),
      version: _databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
    _database = db;
    return db;
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE periods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        flow_intensity INTEGER NOT NULL,
        notes TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE wellness_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        mood TEXT NOT NULL,
        symptoms TEXT NOT NULL DEFAULT '',
        weight_kg REAL,
        temperature_c REAL,
        sleep_hours REAL,
        water_glasses INTEGER,
        energy_level INTEGER NOT NULL DEFAULT 3,
        had_sex INTEGER NOT NULL DEFAULT 0,
        protected_sex INTEGER NOT NULL DEFAULT 1,
        notes TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE profile_settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        name TEXT NOT NULL,
        birth_date TEXT,
        average_cycle_length INTEGER NOT NULL,
        average_period_length INTEGER NOT NULL,
        reminders_enabled INTEGER NOT NULL,
        dark_mode INTEGER NOT NULL,
        onboarding_completed INTEGER NOT NULL DEFAULT 0,
        app_lock_enabled INTEGER NOT NULL DEFAULT 0,
        lock_method TEXT NOT NULL DEFAULT 'none',
        app_pin_hash TEXT
      )
    ''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _addColumnIfMissing(
        db,
        table: 'profile_settings',
        column: 'birth_date',
        definition: 'birth_date TEXT',
      );
    }
    if (oldVersion < 3) {
      await _addColumnIfMissing(
        db,
        table: 'profile_settings',
        column: 'onboarding_completed',
        definition: 'onboarding_completed INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 4) {
      await _addColumnIfMissing(
        db,
        table: 'profile_settings',
        column: 'app_lock_enabled',
        definition: 'app_lock_enabled INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 5) {
      await _addColumnIfMissing(
        db,
        table: 'profile_settings',
        column: 'lock_method',
        definition: "lock_method TEXT NOT NULL DEFAULT 'none'",
      );
      await _addColumnIfMissing(
        db,
        table: 'profile_settings',
        column: 'app_pin_hash',
        definition: 'app_pin_hash TEXT',
      );
      await db.update(
        'profile_settings',
        {'lock_method': 'device'},
        where: 'app_lock_enabled = ? AND lock_method = ?',
        whereArgs: [1, 'none'],
      );
    }
  }

  Future<void> _addColumnIfMissing(
    Database db, {
    required String table,
    required String column,
    required String definition,
  }) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $definition');
    }
  }
}
