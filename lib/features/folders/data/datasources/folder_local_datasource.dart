import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';


class FolderLocalDataSource {
  final Database db;

  FolderLocalDataSource(this.db);

  Future<List<Map<String, dynamic>>> getFolders() async {
    try {
      final folders = await db.query('folders');
      return folders.map((folder) {
        return {
          ...folder,
          'createdAt': folder['createdAt'] != null
              ? DateTime.parse(folder['createdAt'] as String)
              : DateTime.now(), // Fallback to current time if null
        };
      }).toList();
    } catch (e) {
      debugPrint('Error loading folders: $e');
      throw Exception('Failed to load folders');
    }
  }

  Future<int> insertFolder(Map<String, dynamic> folder) async {
    // Ensure 'createdAt' is included in the folder data if not provided
    if (!folder.containsKey('createdAt')) {
      folder['createdAt'] = DateTime.now().toIso8601String();
    }
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
