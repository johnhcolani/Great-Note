import 'package:sqflite/sqflite.dart';

class NoteLocalDataSource {
  final Database db;

  NoteLocalDataSource(this.db);
// Method to check if a folder has any notes
  Future<bool> hasNotesInFolder(int folderId) async {
    final notes = await db.query('notes', where: 'folder_id = ?', whereArgs: [folderId]);
    return notes.isNotEmpty; // Return true if there are notes in the folder
  }

  // Fetch all notes for a specific folder
  Future<List<Map<String, dynamic>>> getNotes(int folderId) async {
    return await db.query('notes', where: 'folder_id = ?', whereArgs: [folderId]);
  }

  // Insert a new note into the database
  Future<int> insertNote(Map<String, dynamic> note) async {
    return await db.insert('notes', note);
  }

  // Update an existing note in the database
  Future<int> updateNote(int noteId, Map<String, dynamic> note) async {
    return await db.update(
      'notes',
      note,
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }
// Fetch notes for a specific folder
  Future<List<Map<String, dynamic>>> getNotesForFolder(int folderId) async {
    return await db.query(
      'notes',
      where: 'folder_id = ?',
      whereArgs: [folderId],
    );
  }
  // Delete a note from the database
  Future<int> deleteNote(int noteId) async {
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }
}
