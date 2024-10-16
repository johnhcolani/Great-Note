part of 'background_bloc.dart';


abstract class BackgroundState {}

class BackgroundInitial extends BackgroundState {}

class BackgroundLoaded extends BackgroundState {
  final String imagePath; // Path to the selected image

  BackgroundLoaded(this.imagePath);
}

class BackgroundError extends BackgroundState {
  final String message;

  BackgroundError(this.message);
}