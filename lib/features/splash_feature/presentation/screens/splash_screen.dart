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

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _firstController;
  late AnimationController _secondController;
  late AnimationController _thirdController;
  late AnimationController _forthController;

  late Animation<Offset> _firstAnimation;
  late Animation<Offset> _secondAnimation;
  late Animation<Offset> _thirdAnimation;
  late Animation<Offset> _forthAnimation;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<SplashBloc>(context).add(StartSplash());

    // Initialize animation controllers
    _firstController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _secondController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _thirdController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _forthController = AnimationController(duration: const Duration(seconds: 2), vsync: this);

    // Define animations with offset values
    _firstAnimation = Tween<Offset>(begin: const Offset(0, -1.5), end: const Offset(0, 0.25)).animate(
      CurvedAnimation(parent: _firstController, curve: Curves.easeInOut),
    );
    _secondAnimation = Tween<Offset>(begin: const Offset(-2.5, 0), end: const Offset(0.2, 0)).animate(
      CurvedAnimation(parent: _secondController, curve: Curves.easeInOut),
    );
    _thirdAnimation = Tween<Offset>(begin: const Offset(2.5, 0), end: const Offset(0.3, 0)).animate(
      CurvedAnimation(parent: _thirdController, curve: Curves.easeInOut),
    );
    _forthAnimation = Tween<Offset>(begin: const Offset(-2.5, 0), end: const Offset(0.5, 0)).animate(
      CurvedAnimation(parent: _forthController, curve: Curves.easeInOut),
    );

    // Start all animations
    _firstController.forward();
    _secondController.forward();
    _thirdController.forward();
    _forthController.forward();
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    _thirdController.dispose();
    _forthController.dispose();
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



            // Second image sliding in from the left
            // Positioned(
            //   top: screenHeight * 0.15, // 15% from the top
            //   left: screenWidth * 0.53, // 5% from the left
            //   child: SlideTransition(
            //     position: _secondAnimation,
            //     child: SizedBox(
            //       height: screenHeight * 0.3, // 30% of screen height
            //       child: Image.asset('assets/images/first.png'),
            //     ),
            //   ),
            // ),


            // Fourth image sliding in from the left
            // Positioned(
            //   top: screenHeight * 0.32, // 40% from the top
            //   right: screenWidth * 0.66, // 10% from the right
            //   child: SlideTransition(
            //     position: _forthAnimation,
            //     child: SizedBox(
            //       height: screenHeight * 0.4, // 28% of screen height
            //       child: Image.asset('assets/images/third.png'),
            //     ),
            //   ),
            // ),

            // Third image sliding in from the right
            // Positioned(
            //   top: screenHeight * 0.6, // 60% from the top
            //   left: screenWidth * 0.49, // 20% from the left
            //   child: SlideTransition(
            //     position: _thirdAnimation,
            //     child: SizedBox(
            //       height: screenHeight * 0.3, // 30% of screen height
            //       child: Image.asset('assets/images/second.png'),
            //     ),
            //   ),
            // ),


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
