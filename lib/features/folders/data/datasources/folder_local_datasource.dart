import 'package:sqflite/sqflite.dart';


class FolderLocalDataSource {
  final Database db;

  FolderLocalDataSource(this.db);

  Future<List<Map<String, dynamic>>> getFolders() async {
    return await db.query('folders');
  }

  Future<int> insertFolder(Map<String, dynamic> folder) async {
    return await db.insert('folders', folder);
  }

  Future<int> deleteFolder(int id) async {
    return await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }
  // Update the folder name in the database
  Future<void> updateFolderName(int folderId, String newName) async {
    await db.update(
      'folders',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [folderId],
    );
  }
}
