import 'package:app/cashmate/settings/reminder_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ReminderDBHelper {
  static final ReminderDBHelper _instance = ReminderDBHelper._internal();
  factory ReminderDBHelper() => _instance;
  ReminderDBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "reminders.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reminders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            dateTime TEXT,
            isActive INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertReminder(Reminder reminder) async {
    final db = await database;
    return await db.insert("reminders", reminder.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Reminder>> getReminders() async {
    final db = await database;
    final res = await db.query("reminders", orderBy: "dateTime ASC");
    return res.map((e) => Reminder.fromMap(e)).toList();
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete("reminders", where: "id = ?", whereArgs: [id]);
  }
}
