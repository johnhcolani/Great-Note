import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:greate_note_app/core/widgets/glossy_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/note_bloc.dart';
import 'dart:convert';

class NoteEditPage extends StatefulWidget {
  final int folderId;
  final int noteId;
  final String initialTitle;
  final String initialDescription; // This should be the Quill Delta JSON string

  const NoteEditPage({super.key, 
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
  QuillController _quillController = QuillController.basic();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Now safe to interact with the widget
    });
    _titleController = TextEditingController(text: widget.initialTitle);

    // Load the initialDescription from Quill JSON if available
    if (widget.initialDescription.isNotEmpty) {
      try {
        final List<dynamic> content =
            jsonDecode(widget.initialDescription) as List<dynamic>;
        final doc = quill.Document.fromJson(
            content); // Initialize document from decoded content
        _quillController = quill.QuillController(
            document: doc, selection: const TextSelection.collapsed(offset: 0));
      } catch (e) {
        print("Error decoding Quill JSON: $e");
        _quillController = quill.QuillController
            .basic(); // Fallback to empty document if decoding fails
      }
    } else {
      _quillController = quill.QuillController.basic();
    }
  }
@override
  void dispose() {
    super.dispose();
    _quillController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlossyAppBar(
        title: 'Edit Note',
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote, // Save the note when pressed
          ),
        ],
        backgroundColor: Colors.brown.withOpacity(0.3),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: QuillEditor.basic(
                controller: _quillController,
configurations: const QuillEditorConfigurations(),
                scrollController:
                    ScrollController(), // Manages scrolling within the editor

                focusNode: FocusNode(), // Focus on the editor
              ),
            ),
            QuillToolbar.simple(
              controller: _quillController,
              configurations: const QuillSimpleToolbarConfigurations(
                showCenterAlignment: true,
                showJustifyAlignment: true,

              ),),

          ],
        ),
      ),
    );
  }
  Future<void> _onImagePickCallback() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _quillController.document.insert(_quillController.selection.baseOffset,
          quill.BlockEmbed.image(pickedFile.path));
    }
  }

  Future<void> _onVideoPickCallback() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _quillController.document.insert(_quillController.selection.baseOffset,
          quill.BlockEmbed.video(pickedFile.path));
    }
  }

  // Method to save the updated note
  void _saveNote() {
    final updatedTitle = _titleController.text.trim();

    // Serialize the Quill document into JSON (Delta format)
    final updatedDescription =
        jsonEncode(_quillController.document.toDelta().toJson());

    if (updatedTitle.isNotEmpty && updatedDescription.isNotEmpty) {
      context.read<NoteBloc>().add(
            UpdateNote(
              noteId: widget.noteId,
              folderId: widget.folderId,
              title: updatedTitle,
              description:
                  updatedDescription, // Save Quill JSON format as a string
            ),
          );
      Navigator.of(context).pop(); // Go back after saving
    }
  }
}
