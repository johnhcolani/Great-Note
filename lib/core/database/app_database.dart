import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';




  class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  Database? _database;

  AppDatabase._internal();

  factory AppDatabase() {
  return _instance;
  }

  Future<Database> getDatabase() async {
  if (_database == null) {
  _database = await openDatabase(
  'app_database.db',
  version: 1,
  onCreate: (db, version) async {
  // Create tables
  await db.execute('CREATE TABLE folders (id INTEGER PRIMARY KEY, name TEXT, color TEXT, createdAt TEXT)');
  await db.execute('CREATE TABLE notes (id INTEGER PRIMARY KEY, folderId INTEGER, title TEXT, content TEXT, createdAt TEXT)');
  },
  );
  }
  return _database!;
  }
  }
