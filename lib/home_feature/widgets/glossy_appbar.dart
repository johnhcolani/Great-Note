import 'dart:ui';
import 'package:flutter/material.dart';

class GlossyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const GlossyAppBar({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurry background using BackdropFilter
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.withOpacity(0.6),
                    Colors.grey.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        // The actual AppBar content
        AppBar(
          backgroundColor: Colors.transparent, // Make AppBar background transparent
          elevation: 0, // Remove shadow
          title: Text(title,style:const TextStyle(color: Colors.white),),
          actions: actions,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
