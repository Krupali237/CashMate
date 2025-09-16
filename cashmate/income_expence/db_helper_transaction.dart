import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/transaction_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), 'transaction.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL,
          note TEXT,
          category TEXT,
          subcategory TEXT, -- ✅ add this line
          type TEXT,
          date TEXT
        )

        ''');
      },
    );
  }

  Future<int> insert(TransactionModel model) async {
    final dbClient = await db;
    return await dbClient.insert('transactions', model.toMap());
  }

  Future<List<TransactionModel>> getAll() async {
    final dbClient = await db;
    final maps = await dbClient.query('transactions', orderBy: 'id DESC');
    return maps.map((e) => TransactionModel.fromMap(e)).toList();
  }

  Future<int> update(TransactionModel model) async {
    final dbClient = await db;
    return await dbClient.update(
      'transactions',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<int> delete(int id) async {
    final dbClient = await db;
    return await dbClient.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
