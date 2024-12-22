import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:greate_note_app/core/widgets/glossy_app_bar.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app_background/app_background.dart';
import '../../../folders/presentation/bloc/folder_bloc.dart';
import '../../../folders/presentation/bloc/folder_event.dart';
import '../../../../core/widgets/custom_floating_action_button.dart';
import '../bloc/note_bloc.dart';
import 'note_edit_page.dart';

class NotePage extends StatefulWidget {
  final int folderId;
  final String folderName;

  const NotePage({super.key, required this.folderId, required this.folderName});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  late String _folderName;
  final Set<int> _expandedNotes = {};
  @override
  void initState() {
    super.initState();
    _folderName = widget.folderName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    context.read<NoteBloc>().add(LoadNotes(folderId: widget.folderId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlossyAppBar(
        backgroundColor: Colors.transparent,
        title: _folderName,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditFolderDialog(context);
            },
          ),

        ], elevation: 0,
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Container(
            color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.1),
          ),
          BlocBuilder<NoteBloc, NoteState>(
            builder: (context, state) {
              if (state is NoteLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is NotesLoaded) {
                return ListView.builder(
                  itemCount: state.notes.length,
                  itemBuilder: (context, index) {
                    final note = state.notes[index];
                    final isExpanded = _expandedNotes.contains(note['id']);
                    return Card(
                      color: theme.cardColor,
                      elevation: 10,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              note['title'],
                              style: theme.textTheme.bodyLarge,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: theme.iconTheme.color),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => NoteEditPage(
                                          folderId: widget.folderId,
                                          noteId: note['id'],
                                          initialTitle: note['title'],
                                          initialDescription: note['description'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: theme.iconTheme.color,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedNotes.remove(note['id']);
                                      } else {
                                        _expandedNotes.add(note['id']);
                                      }
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: theme.iconTheme.color),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(context, note['id']);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Theme.of(context).platform == TargetPlatform.iOS
                                        ? CupertinoIcons.share
                                        : Icons.share,
                                    color: theme.iconTheme.color,
                                  ),
                                  onPressed: () async {
                                    try {
                                      // Debug the raw description
                                      print("Note Description Raw: ${note['description']}");
                                      print("Note Description Type: ${note['description'].runtimeType}");

                                      // Check if description is JSON or a plain string
                                      String contentToShare;
                                      if (note['description'] != null && note['description'].isNotEmpty) {
                                        if (note['description'].startsWith('{')) {
                                          // Try to decode JSON
                                          final decodedDescription = jsonDecode(note['description']);
                                          if (decodedDescription is Map<String, dynamic> &&
                                              decodedDescription['ops'] is List<dynamic>) {
                                            contentToShare = (decodedDescription['ops'] as List<dynamic>)
                                                .map((op) => op['insert']?.toString() ?? "")
                                                .join();
                                          } else {
                                            // Fallback if 'ops' is missing or not a list
                                            contentToShare = "No valid content available.";
                                          }
                                        } else {
                                          // If it's plain text
                                          contentToShare = note['description'];
                                        }
                                      } else {
                                        // Default content if description is null or empty
                                        contentToShare = "No description available.";
                                      }

                                      // Fallback for note title
                                      final noteTitle = note['title'] ?? "Untitled Note";

                                      // Debug content to share
                                      print("Content to Share: $contentToShare");

                                      // Share the content
                                      await Share.share(contentToShare, subject: noteTitle);
                                    } catch (e) {
                                      // Log and handle errors gracefully
                                      print("Error during sharing: $e");
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Unable to share the note. Please try again.")),
                                      );
                                    }
                                  },
                                ),

                              ],
                            ),
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Description:", style: theme.textTheme.bodyMedium),
                                  const SizedBox(height: 8),
                                  if (note['description'] != null && note['description'].isNotEmpty)
                                    quill.QuillEditor(
                                      controller: quill.QuillController(
                                        document: quill.Document.fromJson(
                                          jsonDecode(note['description']),
                                        ),
                                        selection: const TextSelection.collapsed(offset: 0),
                                      ),
                                      focusNode: FocusNode(),
                                      scrollController: ScrollController(),
                                    )
                                  else
                                    Text('No description available.', style: theme.textTheme.bodyMedium),





                              ],
                            ),

                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Description:",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  if (note['description'] != null &&
                                      note['description'].isNotEmpty)
                                  quill.QuillEditor(
                                    controller: quill.QuillController(
                                      document: quill.Document.fromJson(
                                        jsonDecode(note['description']),
                                      ),
                                      selection: const TextSelection.collapsed(offset: 0),
                                    ),
                                    focusNode: FocusNode(),
                                    scrollController: ScrollController(),
                    )else Text('No description available.',style: theme.textTheme.bodyMedium,

                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              } else if (state is NoteError) {
                return Center(
                  child: Text(state.message, style: theme.textTheme.bodyLarge),
                );
              } else {
                return const Center(child: Text('No notes found'));
              }
            },
          ),
        ],
      ),
      floatingActionButton: GlossyRectangularButton(
        onPressed: () {
          _showAddNoteDialog(context);
        },
        icon: Icons.add,
      ),
    );
  }


  // Method to show a dialog for editing the folder name
  void _showEditFolderDialog(BuildContext context) {
    final folderNameController = TextEditingController(text: _folderName);

    showDialog(

      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
backgroundColor: const Color(0xFDEFEEEA),
          title: const Text('Edit Folder Name'),
          content: TextFormField(
            controller: folderNameController,
            decoration: const InputDecoration(labelText: 'Folder Name'),

          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                String newFolderName = folderNameController.text.trim();
                if (newFolderName.isNotEmpty) {
                  // Capitalize the first letter of the folder name
                  newFolderName = newFolderName[0].toUpperCase() + newFolderName.substring(1);
                  // Update the folder name in the Bloc
                  context.read<FolderBloc>().add(UpdateFolderName(
                    folderId: widget.folderId,
                    newName: newFolderName,
                  ));
                  setState(() {
                    _folderName = newFolderName; // Update the folder name locally
                  });
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context, int noteId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Delete'),
              onPressed: () {
                context.read<NoteBloc>().add(DeleteNote(
                  noteId: noteId,
                  folderId: widget.folderId,
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
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFDEFEEEA),

          title: const Text('Add Note',style: TextStyle(color: Colors.blueGrey),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration:  InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blueGrey, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelText: 'Title',labelStyle: TextStyle(color: Colors.grey.shade500)),

              ),
              // TextFormField(
              //   controller: descriptionController,
              //   decoration: const InputDecoration(labelText: 'Description'),
              // ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                String title = titleController.text.trim();
                title = title[0].toUpperCase()+title.substring(1);

                final description = descriptionController.text.trim();
                if (title.isNotEmpty
                   // && description.isNotEmpty
                ) {
                  context.read<NoteBloc>().add(
                    AddNote(
                      folderId: widget.folderId,
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
