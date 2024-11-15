import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:greate_note_app/features/folders/data/datasources/folder_local_datasource.dart';
import '../../../notes/data/data_sources/note_local_datasource.dart';
import 'folder_event.dart';

part 'folder_state.dart';

class FolderBloc extends Bloc<FolderEvent, FolderState> {
  final FolderLocalDataSource folderDataSource;
  final NoteLocalDataSource noteDataSource;

  List<Map<String, dynamic>> _allFolders = [];

  FolderBloc({
    required this.folderDataSource,
    required this.noteDataSource,
  }) : super(FolderLoading()) {
    // Register event handlers
    on<LoadFolders>(_onLoadFolders);
    on<AddFolder>(_onAddFolder);
    on<DeleteFolder>(_onDeleteFolder);
    on<UpdateFolderName>(_onUpdateFolderName);
    on<SearchFolders>(_onSearchFolders);
    on<SearchNotes>(_onSearchNotes);
  }

  Future<void> _onLoadFolders(
      LoadFolders event,
      Emitter<FolderState> emit,
      ) async {
    emit(FolderLoading());
    try {
      final folders = await folderDataSource.getFolders();
      _allFolders = folders;
      emit(FolderLoaded(folders: folders, notes: []));
    } catch (e) {
      emit(FolderError('Failed to load folders'));
    }
  }

  Future<void> _onAddFolder(
      AddFolder event,
      Emitter<FolderState> emit,
      ) async {
    try {
      await folderDataSource.insertFolder({
        'name': event.name,
        'color': event.color,
        'createdAt': event.createdAt.toIso8601String(),
      });
      add(LoadFolders()); // Trigger reload
    } catch (e) {
      emit(FolderError('Failed to add folder'));
    }
  }

  Future<void> _onDeleteFolder(
      DeleteFolder event,
      Emitter<FolderState> emit,
      ) async {
    try {
      await folderDataSource.deleteFolder(event.id);
      add(LoadFolders()); // Trigger reload
    } catch (e) {
      emit(FolderError('Failed to delete folder'));
    }
  }

  Future<void> _onUpdateFolderName(
      UpdateFolderName event,
      Emitter<FolderState> emit,
      ) async {
    try {
      await folderDataSource.updateFolderName(event.folderId, event.newName);
      add(LoadFolders()); // Trigger reload
    } catch (e) {
      emit(FolderError('Failed to update folder name'));
    }
  }

  Future<void> _onSearchFolders(
      SearchFolders event,
      Emitter<FolderState> emit,
      ) async {
    try {
      final folders = _allFolders.where((folder) {
        return folder['name']
            .toLowerCase()
            .contains(event.query.toLowerCase());
      }).toList();
      emit(FolderLoaded(folders: folders, notes: []));
    } catch (e) {
      emit(FolderError('Failed to search folders'));
    }
  }

  Future<void> _onSearchNotes(
      SearchNotes event,
      Emitter<FolderState> emit,
      ) async {
    try {
      final notes = await noteDataSource.searchNotes(event.query);
      emit(FolderLoaded(folders: [], notes: notes));
    } catch (e) {
      emit(FolderError('Failed to search notes'));
    }
  }
}

