import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../bloc/note_bloc.dart';

class NoteEditPage extends StatefulWidget {
  final int folderId;
  final int noteId;
  final String initialTitle;
  final String initialDescription;

  const NoteEditPage({
    super.key,
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
  final FocusNode _editorFocusNode = FocusNode();
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);

    if (widget.initialDescription.isNotEmpty) {
      try {
        final content = jsonDecode(widget.initialDescription);
        final doc = quill.Document.fromJson(content);
        _quillController = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        debugPrint("Error decoding Quill JSON: $e");
        _quillController = quill.QuillController.basic();
      }
    } else {
      _quillController = quill.QuillController.basic();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onImagePickCallback() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(pickedFile.path);
        final localPath = path.join(appDir.path, fileName);

        final File localImage = await File(pickedFile.path).copy(localPath);

        debugPrint("Inserting image at path: $localPath");

        setState(() {
          _quillController.document.insert(
            _quillController.selection.baseOffset,
            quill.BlockEmbed.image(localPath),
          );
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  void _saveNote() {
    final updatedTitle = _titleController.text.trim();
    final updatedDescription = jsonEncode(_quillController.document.toDelta().toJson());

    if (updatedTitle.isNotEmpty && updatedDescription.isNotEmpty) {
      context.read<NoteBloc>().add(
        UpdateNote(
          noteId: widget.noteId,
          folderId: widget.folderId,
          title: updatedTitle,
          description: updatedDescription,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
            ),
            Expanded(
              child: quill.QuillEditor.basic(
                controller: _quillController,

              ),
            ),
            Container(
              color: Colors.grey.shade200,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () async {
                      await _onImagePickCallback();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
