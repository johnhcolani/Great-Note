import 'package:sqflite/sqflite.dart';

class BackgroundLocalDataSource {
  final Database _db;

  BackgroundLocalDataSource(this._db);

  // Insert or update the background image
  Future<void> saveBackgroundImage(String imagePath) async {
    // Check if a background exists
    final result = await _db.query('backgrounds', limit: 1);
    if (result.isEmpty) {
      // Insert new background if not present
      await _db.insert('backgrounds', {'image_path': imagePath});
    } else {
      // Update the existing background
      await _db.update('backgrounds', {'image_path': imagePath},
          where: 'id = ?', whereArgs: [result.first['id']]);
    }
  }

  // Retrieve the saved background image path
  Future<String?> getBackgroundImage() async {
    final result = await _db.query('backgrounds', limit: 1);
    if (result.isNotEmpty) {
      return result.first['image_path'] as String;
    }
    return null; // Return null if no background image is found
  }
}
