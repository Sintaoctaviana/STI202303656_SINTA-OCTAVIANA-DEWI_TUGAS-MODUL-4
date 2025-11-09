// BAB 3 File Storage

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static const _dbName = 'tasks.db';
  static const _dbVersion = 1;
  static const table = 'tasks';

  static Database? _database;

  static Future<Database> _open() async {
    // Menggunakan singleton: jika sudah ada, kembalikan instance yang ada
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, v) async {
        // Query DDL untuk membuat tabel tasks
        await db.execute('''
          CREATE TABLE $table(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            isCompleted INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
    return _database!;
  }

  static Future<int> insert(Map<String, dynamic> task) async {
    final db = await _open();
    return db.insert(table, task);
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _open();
    // Mengurutkan berdasarkan ID terbaru (DESC)
    return db.query(table, orderBy: 'id DESC');
  }

  static Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await _open();
    return db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> delete(int id) async {
    final db = await _open();
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}