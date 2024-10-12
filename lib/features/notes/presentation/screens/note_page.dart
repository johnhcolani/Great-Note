import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../bloc/note_bloc.dart';
import 'note_edit_page.dart';

class NotePage extends StatelessWidget {
  final int folderId;

  NotePage({required this.folderId});

  @override
  Widget build(BuildContext context) {
    // Dispatch LoadNotes event when the page is opened
    context.read<NoteBloc>().add(LoadNotes(folderId: folderId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state is NoteLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is NotesLoaded) {
            return ListView.builder(
              itemCount: state.notes.length,
              itemBuilder: (context, index) {
                final note = state.notes[index];
                String plainText ='';
                try {
                  // Try to parse the description as JSON
                final List<dynamic> content = jsonDecode(note['description']) as List<dynamic>;

                final quill.Document doc = quill.Document.fromJson(content);
                 plainText = doc.toPlainText().trim(); // Convert Delta to plain text
                } catch (e) {
                  // Handle the error (e.g., if the description is not valid JSON)
                  print('Error parsing JSON: $e');
                  plainText = note['description']; // Fallback to displaying the raw description
                }

                return Card(
                  child: ListTile(
                    title: Text(note['title']),
                    //subtitle: Text(plainText),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        context.read<NoteBloc>().add(DeleteNote(
                          noteId: note['id'],
                          folderId: folderId,
                        ));
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NoteEditPage(
                            folderId: folderId,
                            noteId: note['id'],
                            initialTitle: note['title'],
                            initialDescription: note['description'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (state is NoteError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text('No notes found'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddNoteDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context, int noteId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Note'),
          content: Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () {
                context.read<NoteBloc>().add(DeleteNote(
                  noteId: noteId,
                  folderId: folderId,
                ));
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Show dialog to add a new note
  void _showAddNoteDialog(BuildContext context) {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                final title = _titleController.text.trim();
                final description = _descriptionController.text.trim();
                if (title.isNotEmpty && description.isNotEmpty) {
                  context.read<NoteBloc>().add(
                    AddNote(
                      folderId: folderId,
                      title: title,
                      description: description,
                    ),
                  );
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }
}
