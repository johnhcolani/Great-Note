part of 'folder_bloc.dart';

abstract class FolderState extends Equatable {
  const FolderState();

  @override
  List<Object?> get props => [];
}

class FolderLoading extends FolderState {}

class FolderLoaded extends FolderState {
  final List<Map<String, dynamic>> folders;
  final List<Map<String, dynamic>> notes;

  const FolderLoaded({required this.folders, required this.notes});

  @override
  List<Object?> get props => [folders, notes];
}

class FolderError extends FolderState {
  final String message;

  const FolderError(this.message);

  @override
  List<Object?> get props => [message];
}
