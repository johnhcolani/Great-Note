import 'package:sqflite/sqflite.dart';

class NoteLocalDataSource {
  final Database db;

  NoteLocalDataSource(this.db);

  // Search notes by title or description
  Future<List<Map<String, dynamic>>> searchNotes(String query) async {
    try {
      final List<Map<String, dynamic>> notes = await db.query(
        'notes',
        where: 'title LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'], // Partial match for title and description
      );
      return notes;
    } catch (e) {
      print('Error searching notes: $e');
      return [];
    }
  }

  // Check if a folder has any notes
  Future<bool> hasNotesInFolder(int folderId) async {
    try {
      final notes = await db.query(
        'notes',
        where: 'folder_id = ?',
        whereArgs: [folderId],
      );
      return notes.isNotEmpty; // Return true if there are notes in the folder
    } catch (e) {
      print('Error checking notes in folder: $e');
      return false;
    }
  }

  // Fetch all notes for a specific folder
  Future<List<Map<String, dynamic>>> getNotes(int folderId) async {
    try {
      return await db.query(
        'notes',
        where: 'folder_id = ?',
        whereArgs: [folderId],
      );
    } catch (e) {
      print('Error fetching notes: $e');
      return [];
    }
  }

  // Insert a new note into the database
  Future<int> insertNote(Map<String, dynamic> note) async {
    try {
      return await db.insert('notes', note);
    } catch (e) {
      print('Error inserting note: $e');
      return -1; // Indicate failure
    }
  }

  // Update an existing note in the database
  Future<int> updateNote(int noteId, Map<String, dynamic> note) async {
    try {
      return await db.update(
        'notes',
        note,
        where: 'id = ?',
        whereArgs: [noteId],
      );
    } catch (e) {
      print('Error updating note: $e');
      return -1; // Indicate failure
    }
  }

  // Fetch notes for a specific folder (duplicate of `getNotes` method, kept for compatibility)
  Future<List<Map<String, dynamic>>> getNotesForFolder(int folderId) async {
    try {
      return await db.query(
        'notes',
        where: 'folder_id = ?',
        whereArgs: [folderId],
      );
    } catch (e) {
      print('Error fetching notes for folder: $e');
      return [];
    }
  }

  // Delete a note from the database
  Future<int> deleteNote(int noteId) async {
    try {
      return await db.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [noteId],
      );
    } catch (e) {
      print('Error deleting note: $e');
      return -1; // Indicate failure
    }
  }
}
