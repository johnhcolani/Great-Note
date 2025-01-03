import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'app_database.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE folders(id INTEGER PRIMARY KEY, name TEXT, color TEXT,createdAt TEXT)',
        );
        await db.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY, folder_id INTEGER, title TEXT, description TEXT)',
        );
      },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < newVersion) {
            // Example migration: add new column or modify schema
            await db.execute('ALTER TABLE folders ADD COLUMN createdAt TEXT');
          }
        },
    );
  }
  void _createDatabase(Database db, int version) async {
    await db.execute('''
    CREATE TABLE backgrounds (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      image_path TEXT
    )
  ''');
  }
}
