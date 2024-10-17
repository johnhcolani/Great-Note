import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greate_note_app/core/theme/theme_bloc.dart';
import 'package:greate_note_app/core/widgets/custom_floating_action_button.dart';
import 'package:greate_note_app/core/widgets/glossy_app_bar.dart';
import 'package:greate_note_app/features/app_background/bloc/background_bloc.dart';
import '../../../app_background/app_background.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlossyAppBar(
        title:
          'Folder Page',
//'Folder Page $screenWidth',

        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              // Show moon icon for dark mode and sun icon for light mode
              return IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),

                  child: Icon(
                    state.themeMode == ThemeMode.dark
                        ? Icons.nights_stay_outlined // Moon icon for dark mode
                        : Icons.wb_sunny, // Sun icon for light mode
                    key: ValueKey(state.themeMode),
                  ),
                ),
                onPressed: () {
                  // Toggle the theme when the button is pressed
                  context.read<ThemeBloc>().add(ToggleThemeEvent());
                },
              );
            },
          ),
          IconButton(onPressed: (){
context.read<BackgroundBloc>().add(ChangeBackgroundEvent());
          }, icon: const Icon(Icons.image))
        ],
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove shadow
      ),
      body: Stack(
        children: [
          const AppBackground(),
            Container(
              color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.1),
            ),
            BlocBuilder<FolderBloc, FolderState>(
              builder: (context, state) {
                print('Screen width is : $screenWidth');
                if (state is FolderLoading) {
                  return const Center(
                      child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          )));
                } else if (state is FolderLoaded) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:getCrossAxisCount(screenWidth),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16),
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
                                            color: Colors.white, width: 2),
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

        ],
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
          .withOpacity(0.5), // Semi-transparent folder color
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
                Expanded(
                  child: Text(
                    folder['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
                        return Align(
                          alignment: Alignment.center,
                          child: const SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                              color: Colors.white,
                            ),
                          ),
                        );
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
  int getCrossAxisCount(double screenWidth) {
    if (screenWidth >= 1200) {
      return 4; // For very large screens (e.g., large tablets or desktop)
    } else if (screenWidth >= 700) {
      return 3; // For tablets and larger phones in landscape
    } else if (screenWidth >= 300) {
      return 2; // For regular phones in portrait or smaller tablets
    } else {
      return 1; // For small devices
    }
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
          title: const Text('Delete Folder'),
          content:
              Text('Are you sure you want to delete the folder "$folderName"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel the deletion
              },
            ),
            ElevatedButton(
              child: const Text('Delete'),
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
  final folderNameController = TextEditingController();
  Color selectedColor = Colors.blue; // Default color

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
                  controller: folderNameController,
                  decoration: const InputDecoration(
                    labelText: 'Folder Name',
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Select Color:'),
                // Scrollable color options
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _colorOption(Colors.red, selectedColor, () {
                        setState(() {
                          selectedColor = Colors.red;
                        });
                      }),
                      _colorOption(Colors.green, selectedColor, () {
                        setState(() {
                          selectedColor = Colors.green;
                        });
                      }),
                      _colorOption(Colors.blue, selectedColor, () {
                        setState(() {
                          selectedColor = Colors.blue;
                        });
                      }),
                      _colorOption(Colors.yellow, selectedColor, () {
                        setState(() {
                          selectedColor = Colors.yellow;
                        });
                      }),
                      _colorOption(Colors.purple, selectedColor, () {
                        setState(() {
                          selectedColor = Colors.purple;
                        });
                      }),
                      _colorOption(Colors.orange, selectedColor, () {
                        setState(() {
                          selectedColor = Colors.orange;
                        });
                      }),
                      _colorOption(Colors.pink, selectedColor, () {
                        setState(() {
                          selectedColor = Colors.pink;
                        });
                      }),
                      _colorOption(Colors.teal, selectedColor, () {
                        setState(() {
                          selectedColor = Colors.teal;
                        });
                      }),
                      _colorOption(Colors.brown, selectedColor, () {
                        setState(() {
                          selectedColor = Colors.brown;
                        });
                      }),
                      _colorOption(Colors.cyan, selectedColor, () {
                        setState(() {
                          selectedColor = Colors.cyan;
                        });
                      }),
                      _colorOption(Colors.indigo, selectedColor, () {
                        setState(() {
                          selectedColor = Colors.indigo;
                        });
                      }),
                    ],
                  ),
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
                  final folderName = folderNameController.text.trim();
                  if (folderName.isNotEmpty) {
                    // Store the color as an integer value
                    context.read<FolderBloc>().add(
                      AddFolder(
                        name: folderName,
                        color: selectedColor.value
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
