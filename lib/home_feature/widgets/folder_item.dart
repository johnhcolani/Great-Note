import 'dart:ui';
import 'package:flutter/material.dart';

class FolderItem extends StatelessWidget {
  final String folderName;
  final Color color;
  final VoidCallback? onDelete; // Optional callback for deletion
  final VoidCallback? onAddNote; // New callback for adding a note
  final VoidCallback? onTap;     // Callback for tapping the folder
  const FolderItem({
    Key? key,
    required this.folderName,
    required this.color,
    this.onDelete,
    this.onAddNote,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Blurry background
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.6), color.withOpacity(0.4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              children: [
                Text(
                  folderName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: onAddNote, // Trigger the add note callback
                ),
              ],
            ),
          ),
          // Delete icon in the top right corner
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.delete_outline,
                color: Colors.pink,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
