import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greate_note_app/core/theme/theme_bloc.dart';
import 'package:greate_note_app/core/widgets/custom_floating_action_button.dart';
import 'package:greate_note_app/core/widgets/glossy_app_bar.dart';
import '../../../notes/data/data_sources/note_local_datasource.dart';
import '../../../notes/presentation/screens/note_page.dart';
import '../bloc/folder_bloc.dart';
import '../bloc/folder_event.dart';

class FolderPage extends StatelessWidget {
  final NoteLocalDataSource
      noteLocalDataSource; // Pass the data source to check notes
  const FolderPage({super.key, required this.noteLocalDataSource});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlossyAppBar(
        title:
          'Welcome to Folder Page',


        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              // Show moon icon for dark mode and sun icon for light mode
              return IconButton(
                icon: Icon(
                  state.themeMode == ThemeMode.dark
                      ? Icons.nights_stay_outlined // Moon icon for dark mode
                      : Icons.wb_sunny, // Sun icon for light mode
                ),
                onPressed: () {
                  // Toggle the theme when the button is pressed
                  context.read<ThemeBloc>().add(ToggleThemeEvent());
                },
              );
            },
          ),
        ],
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove shadow
      ),
      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          image: const DecorationImage(
            image: AssetImage('assets/images/pure_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: BlocBuilder<FolderBloc, FolderState>(
          builder: (context, state) {
            if (state is FolderLoading) {
              return const Center(
                  child: SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      )));
            } else if (state is FolderLoaded) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8),
                  itemCount: state.folders.length,
                  itemBuilder: (context, index) {
                    final folder = state.folders[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NotePage(
                                folderId: folder['id'],
                                folderName: folder['name']),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          // BackdropFilter to apply the blur effect
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                16), // Same border radius as the container
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                  sigmaX: 15.0, sigmaY: 15.0), // Blurry effect
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                    color: Colors.white.withOpacity(
                                        0.2), // Semi-transparent color overlay
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // The actual folder card content

                          buildCard(folder, context),
                        ],
                      ),
                    );
                  },
                ),
              );
            } else if (state is FolderError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text('No folders found'));
            }
          },
        ),
      ),
      floatingActionButton: GlossyRectangularButton(
        onPressed: () {
          _showAddFolderDialog(context);
        },
        icon: Icons.add,
      ),
    );
  }

  Card buildCard(Map<String, dynamic> folder, BuildContext context) {
    return Card(
      color: Color(int.parse(folder['color']))
          .withOpacity(0.2), // Semi-transparent folder color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  folder['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () async {
                    await _confirmAndDeleteFolder(
                        context, folder['id'], folder['name']);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(
                      0.2), // More transparency for the note container
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: noteLocalDataSource.getNotesForFolder(folder['id']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error loading notes');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'No notes',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      } else {
                        final notes = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true, // Prevents infinite height error
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return Text(
                              note['title'],
                              style: const TextStyle(color: Colors.white),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to confirm and delete the folder if empty
  Future<void> _confirmAndDeleteFolder(
      BuildContext context, int folderId, String folderName) async {
    // First check if the folder contains any notes
    final hasNotes = await noteLocalDataSource.hasNotesInFolder(folderId);

    if (hasNotes) {
      // If the folder contains notes, show a message and prevent deletion
      _showAlertDialog(context, 'Cannot Delete',
          'This folder contains notes and cannot be deleted.');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Folder'),
          content:
              Text('Are you sure you want to delete the folder "$folderName"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel the deletion
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm the deletion
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Proceed to delete the folder if confirmed
      context.read<FolderBloc>().add(DeleteFolder(id: folderId));
    }
  }

  // Helper method to show an alert dialog
  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}

// Method to show the Add Folder dialog
void _showAddFolderDialog(BuildContext context) {
  final _folderNameController = TextEditingController();
  Color _selectedColor = Colors.blue; // Default color

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Folder'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _folderNameController,
                  decoration: const InputDecoration(
                    labelText: 'Folder Name',
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Select Color:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _colorOption(Colors.red, _selectedColor, () {
                      setState(() {
                        _selectedColor = Colors.red;
                      });
                    }),
                    _colorOption(Colors.green, _selectedColor, () {
                      setState(() {
                        _selectedColor = Colors.green;
                      });
                    }),
                    _colorOption(Colors.blue, _selectedColor, () {
                      setState(() {
                        _selectedColor = Colors.blue;
                      });
                    }),
                    _colorOption(Colors.yellow, _selectedColor, () {
                      setState(() {
                        _selectedColor = Colors.yellow;
                      });
                    }),
                  ],
                ),
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
                  final folderName = _folderNameController.text.trim();
                  if (folderName.isNotEmpty) {
                    // Store the color as an integer value
                    context.read<FolderBloc>().add(
                          AddFolder(
                            name: folderName,
                            color: _selectedColor.value
                                .toString(), // Store color as int value string
                          ),
                        );
                    Navigator.of(context)
                        .pop(); // Close dialog after adding folder
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}

// Widget to display color options
Widget _colorOption(Color color, Color selectedColor, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: selectedColor == color
            ? Border.all(color: Colors.black, width: 3)
            : null,
      ),
    ),
  );
}
