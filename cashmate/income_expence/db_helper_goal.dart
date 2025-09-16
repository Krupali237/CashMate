import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/goal_model.dart';
class GoalDBHelper {
  static Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), 'cashmate.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount REAL,
            targetDate TEXT,
            description TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertGoal(GoalModel goal) async {
    final db = await initDb();
    await db.insert('goals', goal.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<GoalModel>> getAllGoals() async {
    final db = await initDb();
    final List<Map<String, dynamic>> maps = await db.query('goals');
    return maps.map((map) => GoalModel.fromMap(map)).toList();
  }

  static Future<void> deleteGoal(int id) async {
    final db = await initDb();
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateGoal(GoalModel goal) async {
    final db = await initDb();
    await db.update('goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
  }
}
