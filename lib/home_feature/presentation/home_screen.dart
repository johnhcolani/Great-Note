import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:greate_note_app/core/theme/theme_provider.dart';
import 'package:greate_note_app/home_feature/widgets/glossy_appbar.dart';
import 'package:greate_note_app/home_feature/widgets/glossy_floating_action_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import for capitalizing the folder name
import '../data/sd_helper.dart';
import '../widgets/folder_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _backgroundImage;
  List<Map<String, dynamic>> _folders = [];
  Color selectedColor = Colors.blueAccent;

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
    _loadFolders();
  }

  // Load folders from database
  Future<void> _loadFolders() async {
    final data = await DBHelper.getFolders();
    setState(() {
      _folders = data;
    });
  }

  // Add folder to database
  Future<void> _addFolder(String folderName, String folderColor) async {
    await DBHelper.addFolder(folderName, folderColor);
    _loadFolders(); // Refresh the list after adding a folder
  }

  // Delete folder from database
  Future<void> _deleteFolder(int id) async {
    await DBHelper.deleteFolder(id);
    _loadFolders(); // Refresh the list after deleting a folder
  }

  Future<void> _loadBackgroundImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final backgroundImage = File('${directory.path}/background_image.png');
    if (backgroundImage.existsSync()) {
      setState(() {
        _backgroundImage = backgroundImage;
      });
    } else {
      setState(() {
        _backgroundImage = null;
      });
    }
  }

  Future<void> _pickBackgroundImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final newImage = File(pickedFile.path);
// Save the selected image to the app's documents directory
      final savedImage =
          await newImage.copy('${directory.path}/background_image.png');
      setState(() {
        _backgroundImage = savedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlossyAppBar(
        title: 'Home',
        actions: [
          IconButton(
              onPressed: _pickBackgroundImage,
              icon: const Icon(
                Icons.image,
                color: Colors.white,
              )),
          IconButton(
              onPressed: () {
                final provider =
                    Provider.of<ThemeProvider>(context, listen: false);
                provider.toggleTheme(!provider.isDarkMode);
              },
              icon: const Icon(
                Icons.brightness_6,
                color: Colors.white,
              ))
        ],
      ),
      body: Stack(
        children: [
          if (_backgroundImage != null)
            Positioned.fill(
              child: Image.file(
                _backgroundImage!,
                fit: BoxFit.cover,
              ),
            )
          else
            Positioned.fill(
                child: Image.asset(
              'assets/images/pure_background.png',
              fit: BoxFit.cover,
            )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _folders.length,
              itemBuilder: (context, index) {
                final folder = _folders[index];
                return FolderItem(
                  folderName: folder['name'],
                  color: Color(int.parse(folder['color'])),

                  onDelete: () {
                    // Show a confirmation dialog before deletion
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Folder'),
                          content: Text(
                            'Are you sure you want to delete the folder "${folder['name']}"?',
                            style: const TextStyle(fontSize: 16),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                _deleteFolder(folder['id']);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: GlossyFloatingActionButton(
        onPressed: () {
          _showAddFolderDialog(context);
        },
        icon: Icons.add,
      ),
    );
  }

  void _showAddFolderDialog(BuildContext context) {
    final TextEditingController folderNameController = TextEditingController();
    Color selectedDialogColor = selectedColor; // Initialize with default color

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Folder'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: folderNameController,
                    decoration: const InputDecoration(labelText: 'Folder Name'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showColorPicker(context, setState, (Color color) {
                        setState(() {
                          selectedDialogColor =
                              color; // Update the selected color
                        });
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedDialogColor, // Use updated color
                    ),
                    child: const Text('Pick Color'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    String folderName = folderNameController.text.trim();
                    if (folderName.isNotEmpty) {
                      folderName =
                          toBeginningOfSentenceCase(folderName) ?? folderName;
                      final folderColor = selectedDialogColor.value.toString();
                      _addFolder(folderName, folderColor);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showColorPicker(BuildContext context, StateSetter setState,
      Function(Color) onColorPicked) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                onColorPicked(color); // Pass the selected color back
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
