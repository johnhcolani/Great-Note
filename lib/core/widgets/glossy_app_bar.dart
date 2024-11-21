import 'dart:ui';
import 'package:flutter/material.dart';

class GlossyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final bool centerTitle;

  const GlossyAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.centerTitle = true, required Color backgroundColor, required int elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // BackdropFilter to apply the blur effect
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
           // bottom: Radius.circular(16), // Rounded bottom corners
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3), // Glossy effect with opacity
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(0), // Same rounded corners
                ),

              ),
            ),
          ),
        ),
        // The actual AppBar content
        AppBar(
          backgroundColor: Colors.transparent, // Transparent to show the blur effect
          elevation: 0, // No shadow
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white, // Ensure the title text is white
            ),
          ),
          actions: actions,
          centerTitle: centerTitle,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
