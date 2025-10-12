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
      version: 3,
      onCreate: (db, version) async {
        // Create folders table with all columns
        await db.execute('''
          CREATE TABLE folders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            color TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');

        // Create notes table with foreign key constraint
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            folder_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE CASCADE
          )
        ''');

        // Create backgrounds table
        await db.execute('''
          CREATE TABLE backgrounds (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            image_path TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Migrate from version 1 to 2: Add createdAt column
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE folders ADD COLUMN createdAt TEXT');
        }

        // Migrate from version 2 to 3: Create backgrounds table
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS backgrounds (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              image_path TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }
}
