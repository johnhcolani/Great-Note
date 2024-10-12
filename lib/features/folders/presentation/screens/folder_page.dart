import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../notes/data/data_sources/note_local_datasource.dart';
import '../../../notes/presentation/screens/note_page.dart';
import '../bloc/folder_bloc.dart';
import '../bloc/folder_event.dart';

class FolderPage extends StatelessWidget {
  final NoteLocalDataSource noteLocalDataSource; // Pass the data source to check notes
  FolderPage({required this.noteLocalDataSource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Folders')),
      body: BlocBuilder<FolderBloc, FolderState>(
        builder: (context, state) {
          if (state is FolderLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is FolderLoaded) {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: state.folders.length,
              itemBuilder: (context, index) {
                final folder = state.folders[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NotePage(folderId: folder['id']),
                      ),
                    );
                  },
                  child: Card(
                    color: Color(int.parse(folder['color'])), // Use color from folder
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(folder['name']),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await _confirmAndDeleteFolder(context, folder['id'], folder['name']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is FolderError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text('No folders found'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddFolderDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
  // Method to confirm and delete the folder if empty
  Future<void> _confirmAndDeleteFolder(BuildContext context, int folderId, String folderName) async {
    // First check if the folder contains any notes
    final hasNotes = await noteLocalDataSource.hasNotesInFolder(folderId);

    if (hasNotes) {
      // If the folder contains notes, show a message and prevent deletion
      _showAlertDialog(context, 'Cannot Delete', 'This folder contains notes and cannot be deleted.');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Folder'),
          content: Text('Are you sure you want to delete the folder "$folderName"?'),
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
              child: Text('OK'),
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
              title: Text('Add Folder'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _folderNameController,
                    decoration: InputDecoration(
                      labelText: 'Folder Name',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Select Color:'),
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
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Add'),
                  onPressed: () {
                    final folderName = _folderNameController.text.trim();
                    if (folderName.isNotEmpty) {
                      // Store the color as an integer value
                      context.read<FolderBloc>().add(
                        AddFolder(
                          name: folderName,
                          color: _selectedColor.value.toString(), // Store color as int value string
                        ),
                      );
                      Navigator.of(context).pop(); // Close dialog after adding folder
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

