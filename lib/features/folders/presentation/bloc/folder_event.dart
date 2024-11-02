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
  final DateTime createdAt;

   AddFolder({
    required this.name,
    required this.color,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  List<Object> get props => [name, color,createdAt];
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

  const UpdateFolderName({required this.folderId, required this.newName});
  @override
  List<Object> get props => [folderId,newName];
}