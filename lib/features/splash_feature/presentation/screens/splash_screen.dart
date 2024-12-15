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

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _firstController;

  late Animation<Offset> _firstAnimation;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<SplashBloc>(context).add(StartSplash());

    // Initialize animation controllers
    _firstController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);

    // Define animations with offset values
    _firstAnimation =
        Tween<Offset>(begin: const Offset(0, -1.5), end: const Offset(0, 0.25))
            .animate(
      CurvedAnimation(parent: _firstController, curve: Curves.easeInOut),
    );

    // Start all animations
    _firstController.forward();
  }

  @override
  void dispose() {
    _firstController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashCompleted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => FolderPage(
                noteLocalDataSource: widget.noteLocalDataSource,
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const SplashBackground(),

            // First image (quill) sliding down to the center
            SlideTransition(
              position: _firstAnimation,
              child: Center(
                child: SizedBox(
                  height: screenHeight * 0.25, // 25% of screen height
                  child: Image.asset('assets/images/quill.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
