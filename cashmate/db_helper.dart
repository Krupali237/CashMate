// import 'package:app/cashmate/user_model.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class DBHelper {
//   static Database? _db;
//
//   static Future<Database> get db async {
//     if (_db != null) return _db!;
//     _db = await initDb();
//     return _db!;
//   }
//
//   static Future<Database> initDb() async {
//     final path = join(await getDatabasesPath(), 'app.db');
//     return await openDatabase(path, version: 1, onCreate: (db, version) {
//       return db.execute('''
//         CREATE TABLE users(
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           name TEXT,
//           email TEXT UNIQUE,
//           password TEXT
//         )
//       ''');
//     });
//   }
//
//   static Future<void> insertUser(User user) async {
//     final dbClient = await db;
//     await dbClient.insert('users', user.toMap());
//   }
//
//   static Future<User?> getUserByEmail(String email) async {
//     final dbClient = await db;
//     final result = await dbClient.query('users', where: 'email = ?', whereArgs: [email]);
//     if (result.isNotEmpty) return User.fromMap(result.first);
//     return null;
//   }
// }
