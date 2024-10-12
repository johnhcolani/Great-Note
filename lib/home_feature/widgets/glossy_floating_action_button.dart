import 'dart:ui';
import 'package:flutter/material.dart';

class GlossyFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const GlossyFloatingActionButton({
    Key? key,
    required this.onPressed,
    this.icon = Icons.add,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28.0), // Match the FAB border radius
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Apply blur
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28.0),
            gradient: LinearGradient(
              colors: [
                Colors.grey.withOpacity(0.2),
                Colors.grey.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.0,
            ),
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent, // Make FAB background transparent
            elevation: 0, // Remove shadow for better glossy effect
            onPressed: onPressed,
            child: Icon(icon),
          ),
        ),
      ),
    );
  }
}
