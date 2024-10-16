import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greate_note_app/core/widgets/splash_background.dart';
import 'package:greate_note_app/features/folders/presentation/screens/folder_page.dart';
import '../../../notes/data/data_sources/note_local_datasource.dart';
import 'bloc/splash_bloc.dart';

class SplashScreen extends StatefulWidget {
  final NoteLocalDataSource noteLocalDataSource;
  const SplashScreen({super.key, required this.noteLocalDataSource});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;


  @override
  void initState() {
    super.initState();

    // Dispatch StartSplash event
    BlocProvider.of<SplashBloc>(context).add(StartSplash());

    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // The time it takes for the image to move
      vsync: this,
    );

    // Define the animation curve and range
    _animation = Tween<double>(begin: -1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashCompleted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) =>   FolderPage(
                    noteLocalDataSource: widget.noteLocalDataSource)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const SplashBackground(),
            // Animated widget for moving the image from top to center
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned(
                  top: MediaQuery.of(context).size.height * _animation.value, // Moves the image based on animation
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      height: 220,
                      child: Image.asset('assets/images/quill.png'), // Your image asset
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
