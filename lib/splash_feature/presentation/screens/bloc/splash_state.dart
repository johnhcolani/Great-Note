part of 'splash_bloc.dart';

abstract class SplashState extends Equatable {
  const SplashState();
}

class SplashInitial extends SplashState {
  @override
  List<Object> get props => [];
}
class SplashCompleted extends SplashState{
  @override
    List<Object?> get props => throw UnimplementedError();

}