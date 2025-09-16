import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/activity_model.dart';

class DBHelperActivity {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), "cashmate.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE activities(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            type TEXT,
            amount REAL,
            date TEXT,
            category TEXT,
            subCategory TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertActivity(ActivityModel activity) async {
    final db = await database;
    return await db.insert("activities", activity.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ActivityModel>> getAllActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query("activities", orderBy: "date DESC");
    return result.map((json) => ActivityModel.fromJson(json)).toList();
  }

  Future<int> updateActivity(ActivityModel activity) async {
    final db = await database;
    return await db.update(
      "activities",
      activity.toJson(),
      where: "id = ?",
      whereArgs: [activity.id],
    );
  }

  Future<int> deleteActivity(int id) async {
    final db = await database;
    return await db.delete("activities", where: "id = ?", whereArgs: [id]);
  }
}
