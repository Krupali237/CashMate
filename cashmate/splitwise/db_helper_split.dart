// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class DBHelper {
//   static final DBHelper _instance = DBHelper._internal();
//   factory DBHelper() => _instance;
//   DBHelper._internal();
//
//   Database? _db;
//
//   Future<Database> get db async {
//     if (_db != null) return _db!;
//     _db = await _initDB();
//     return _db!;
//   }
//
//   Future<Database> _initDB() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, "trip_group.db");
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (d, v) async {
//         await d.execute('''
//           CREATE TABLE groups(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             name TEXT NOT NULL,
//             place TEXT,
//             created_at TEXT DEFAULT CURRENT_TIMESTAMP
//           )
//         ''');
//         await d.execute('''
//           CREATE TABLE members(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             group_id INTEGER NOT NULL,
//             name TEXT NOT NULL,
//             phone TEXT,
//             FOREIGN KEY(group_id) REFERENCES groups(id) ON DELETE CASCADE
//           )
//         ''');
//         await d.execute('''
//           CREATE TABLE txns(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             group_id INTEGER NOT NULL,
//             member_id INTEGER NOT NULL,
//             type TEXT CHECK(type IN ('income','expense')) NOT NULL,
//             amount REAL NOT NULL,
//             category TEXT NOT NULL,
//             note TEXT,
//             date TEXT NOT NULL,
//             FOREIGN KEY(group_id) REFERENCES groups(id) ON DELETE CASCADE,
//             FOREIGN KEY(member_id) REFERENCES members(id) ON DELETE CASCADE
//           )
//         ''');
//       },
//     );
//   }
//
//   // GROUPS
//   Future<int> insertGroup(Map<String, dynamic> data) async =>
//       (await db).insert('groups', data);
//   Future<List<Map<String, dynamic>>> fetchGroups() async =>
//       (await db).query('groups', orderBy: 'created_at DESC');
//
//   // MEMBERS
//   Future<int> insertMember(Map<String, dynamic> data) async =>
//       (await db).insert('members', data);
//   Future<List<Map<String, dynamic>>> fetchMembers(int groupId) async =>
//       (await db).query('members',
//           where: 'group_id=?', whereArgs: [groupId], orderBy: 'name ASC');
//
//   // TRANSACTIONS
//   Future<int> insertTxn(Map<String, dynamic> data) async =>
//       (await db).insert('txns', data);
//   Future<List<Map<String, dynamic>>> fetchMemberTxns(int memberId) async =>
//       (await db).query('txns',
//           where: 'member_id=?', whereArgs: [memberId], orderBy: 'date DESC');
//
//   Future<Map<String, double>> memberTotals(int memberId) async {
//     final dbClient = await db;
//
//     // Total Income
//     final incomeResult = await dbClient.rawQuery(
//       "SELECT SUM(amount) as total FROM txns WHERE member_id = ? AND type = ?",
//       [memberId, "income"],
//     );
//     double income = incomeResult.first["total"] != null
//         ? (incomeResult.first["total"] as num).toDouble()
//         : 0.0;
//
//     // Total Expense
//     final expenseResult = await dbClient.rawQuery(
//       "SELECT SUM(amount) as total FROM txns WHERE member_id = ? AND type = ?",
//       [memberId, "expense"],
//     );
//     double expense = expenseResult.first["total"] != null
//         ? (expenseResult.first["total"] as num).toDouble()
//         : 0.0;
//
//     return {"income": income, "expense": expense};
//   }
//
// }

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "splitwise.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (d, v) async {
        await d.execute('''
          CREATE TABLE groups(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            place TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await d.execute('''
          CREATE TABLE members(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            group_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            phone TEXT,
            FOREIGN KEY(group_id) REFERENCES groups(id) ON DELETE CASCADE
          )
        ''');

        await d.execute('''
          CREATE TABLE txns(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            group_id INTEGER NOT NULL,
            member_id INTEGER  NULL,
            type TEXT CHECK(type IN ('income','expense')) NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            note TEXT,
            date TEXT NOT NULL,
            FOREIGN KEY(group_id) REFERENCES groups(id) ON DELETE CASCADE,
            FOREIGN KEY(member_id) REFERENCES members(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // ---------------- GROUPS ----------------
  Future<int> insertGroup(Map<String, dynamic> data) async =>
      (await db).insert('groups', data);

  Future<List<Map<String, dynamic>>> fetchGroups() async =>
      (await db).query('groups', orderBy: 'created_at DESC');

  Future<int> updateGroup(int id, Map<String, dynamic> data) async =>
      (await db).update('groups', data, where: 'id=?', whereArgs: [id]);

  Future<int> deleteGroup(int id) async =>
      (await db).delete('groups', where: 'id=?', whereArgs: [id]);

  /// ✅ Group totals
  Future<Map<String, double>> groupTotals(int groupId) async {
    final dbClient = await db;
    final result = await dbClient.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) AS total_income,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) AS total_expense
      FROM txns
      WHERE group_id = ?
    ''', [groupId]);

    return {
      "income": (result.first["total_income"] as num?)?.toDouble() ?? 0.0,
      "expense": (result.first["total_expense"] as num?)?.toDouble() ?? 0.0
    };
  }


  // ---------------- MEMBERS ----------------
  Future<int> insertMember(Map<String, dynamic> data) async =>
      (await db).insert('members', data);

  Future<List<Map<String, dynamic>>> fetchMembers(int groupId) async =>
      (await db).query('members',
          where: 'group_id=?', whereArgs: [groupId], orderBy: 'name ASC');

  Future<int> updateMember(int id, Map<String, dynamic> data) async =>
      (await db).update('members', data, where: 'id=?', whereArgs: [id]);

  Future<int> deleteMember(int id) async =>
      (await db).delete('members', where: 'id=?', whereArgs: [id]);

  /// ✅ Member balance (income - expense)
  Future<Map<int, double>> memberBalances(int groupId) async {
    final dbClient = await db;
    final result = await dbClient.rawQuery('''
      SELECT m.id AS member_id,
        COALESCE(SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE 0 END), 0) -
        COALESCE(SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END), 0) 
        AS balance
      FROM members m
      LEFT JOIN txns t ON m.id = t.member_id
      WHERE m.group_id = ?
      GROUP BY m.id
    ''', [groupId]);

    return {
      for (var row in result)
        row['member_id'] as int: (row['balance'] as num?)?.toDouble() ?? 0.0
    };
  }

  // ---------------- TRANSACTIONS ----------------
  Future<int> insertTxn(Map<String, dynamic> data) async =>
      (await db).insert('txns', data);

  Future<List<Map<String, dynamic>>> fetchMemberTxns(int memberId) async =>
      (await db).query('txns',
          where: 'member_id=?', whereArgs: [memberId], orderBy: 'date DESC');

  Future<int> updateTxn(int id, Map<String, dynamic> data) async =>
      (await db).update('txns', data, where: 'id=?', whereArgs: [id]);

  Future<int> deleteTxn(int id) async =>
      (await db).delete('txns', where: 'id=?', whereArgs: [id]);

  /// ✅ Member totals
  Future<Map<String, double>> memberTotals(int memberId) async {
    final dbClient = await db;

    final incomeResult = await dbClient.rawQuery(
      "SELECT SUM(amount) as total FROM txns WHERE member_id = ? AND type = ?",
      [memberId, "income"],
    );
    final expenseResult = await dbClient.rawQuery(
      "SELECT SUM(amount) as total FROM txns WHERE member_id = ? AND type = ?",
      [memberId, "expense"],
    );

    return {
      "income": (incomeResult.first["total"] as num?)?.toDouble() ?? 0.0,
      "expense": (expenseResult.first["total"] as num?)?.toDouble() ?? 0.0
    };
  }
}
