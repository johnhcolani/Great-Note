import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/background_bloc.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    // Dispatch the load event when the widget is built
    context.read<BackgroundBloc>().add(LoadBackgroundEvent());

    return BlocBuilder<BackgroundBloc, BackgroundState>(
      builder: (context, state) {
        if (state is BackgroundLoaded) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(state.imagePath)),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pure_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      },
    );
  }
}
