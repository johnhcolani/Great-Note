part of 'background_bloc.dart';


abstract class BackgroundEvent {}

class LoadBackgroundEvent extends BackgroundEvent {}

class ChangeBackgroundEvent extends BackgroundEvent {}