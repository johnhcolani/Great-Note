import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BackgroundLocalDataSource {
  Database? _db;

  // Initialize the database
  Future<void> init() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'backgrounds.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''CREATE TABLE backgrounds (
               id INTEGER PRIMARY KEY AUTOINCREMENT,
               image_path TEXT
             )''',
        );
      },
    );
  }

  // Insert or update the background image
  Future<void> saveBackgroundImage(String imagePath) async {
    final db = _db;

    if (db == null) {
      throw Exception('Database not initialized');
    }

    // Check if a background exists
    final result = await db.query('backgrounds', limit: 1);
    if (result.isEmpty) {
      // Insert new background if not present
      await db.insert('backgrounds', {'image_path': imagePath});
    } else {
      // Update the existing background
      await db.update('backgrounds', {'image_path': imagePath},
          where: 'id = ?', whereArgs: [result.first['id']]);
    }
  }

  // Retrieve the saved background image path
  Future<String?> getBackgroundImage() async {
    final db = _db;

    if (db == null) {
      throw Exception('Database not initialized');
    }

    final result = await db.query('backgrounds', limit: 1);
    if (result.isNotEmpty) {
      return result.first['image_path'] as String;
    }
    return null; // Return null if no background image is found
  }
}
