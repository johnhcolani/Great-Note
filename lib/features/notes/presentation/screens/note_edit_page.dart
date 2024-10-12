import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../bloc/note_bloc.dart';
import 'dart:convert';

class NoteEditPage extends StatefulWidget {
  final int folderId;
  final int noteId;
  final String initialTitle;
  final String initialDescription; // This should be the Quill Delta JSON string

  NoteEditPage({
    required this.folderId,
    required this.noteId,
    required this.initialTitle,
    required this.initialDescription,
  });

  @override
  _NoteEditPageState createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late TextEditingController _titleController;
  late quill.QuillController _quillController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.initialTitle);

    // Load the initialDescription from Quill JSON if available
    if (widget.initialDescription.isNotEmpty) {
      try {
        final List<dynamic> content = jsonDecode(widget.initialDescription) as List<dynamic>;
        final doc = quill.Document.fromJson(content);  // Initialize document from decoded content
        _quillController = quill.QuillController(document: doc, selection: TextSelection.collapsed(offset: 0));
      } catch (e) {
        print("Error decoding Quill JSON: $e");
        _quillController = quill.QuillController.basic();  // Fallback to empty document if decoding fails
      }
    } else {
      _quillController = quill.QuillController.basic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote, // Save the note when pressed
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10),
            Expanded(
              child: quill.QuillEditor(
                controller: _quillController,
                scrollController: ScrollController(), // Manages scrolling within the editor

                focusNode: FocusNode(), // Focus on the editor

              ),
            ),
            quill.QuillToolbar.simple(controller: _quillController), // Toolbar still basic
          ],
        ),
      ),
    );
  }

  // Method to save the updated note
  void _saveNote() {
    final updatedTitle = _titleController.text.trim();

    // Serialize the Quill document into JSON (Delta format)
    final updatedDescription = jsonEncode(_quillController.document.toDelta().toJson());

    if (updatedTitle.isNotEmpty && updatedDescription.isNotEmpty) {
      context.read<NoteBloc>().add(
        UpdateNote(
          noteId: widget.noteId,
          folderId: widget.folderId,
          title: updatedTitle,
          description: updatedDescription, // Save Quill JSON format as a string
        ),
      );
      Navigator.of(context).pop(); // Go back after saving
    }
  }
}