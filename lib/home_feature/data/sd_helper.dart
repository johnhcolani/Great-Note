import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), ' folder.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          ''' CREATE TABLE folders( id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, color TEXT)''');
    });
  }
  // Insert folder into the database
  static Future<int> addFolder(String name, String color)async{
    final dbClient = await db;
    return await dbClient.insert('folders' , {
      'name': name,
      'color':color,
    });
  }
  // Retrieve all folders from the database
  static Future<List<Map<String, dynamic>>> getFolders() async {
    final dbClient = await db;
    return await dbClient.query('folders');
  }

  // Delete a folder from the database
  static Future<int> deleteFolder(int id) async{
    final dbClient = await db;
    return await dbClient.delete(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
