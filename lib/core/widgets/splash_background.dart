import 'package:flutter/material.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:  Container(
          decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/splash_background.png'),
        fit: BoxFit.fill
        )
      )),
    );
  }
}
