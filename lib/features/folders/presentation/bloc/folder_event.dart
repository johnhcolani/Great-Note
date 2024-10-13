import 'package:equatable/equatable.dart';

// Define base class for Folder events
abstract class FolderEvent extends Equatable {
  const FolderEvent();

  @override
  List<Object> get props => [];
}

// Event to load all folders
class LoadFolders extends FolderEvent {}

// Event to add a folder
class AddFolder extends FolderEvent {
  final String name;
  final String color;

  const AddFolder({required this.name, required this.color});

  @override
  List<Object> get props => [name, color];
}

// Event to delete a folder
class DeleteFolder extends FolderEvent {
  final int id;

  const DeleteFolder({required this.id});

  @override
  List<Object> get props => [id];
}
class UpdateFolderName extends FolderEvent {
  final int folderId;
  final String newName;

  UpdateFolderName({required this.folderId, required this.newName});
}