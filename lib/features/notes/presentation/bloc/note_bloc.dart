import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../data/data_sources/note_local_datasource.dart';

part 'note_event.dart';
part 'note_state.dart';


class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteLocalDataSource localDataSource;

  NoteBloc(this.localDataSource) : super(NoteLoading()) {
    // Event to load notes for a folder
    on<LoadNotes>((event, emit) async {
      emit(NoteLoading());
      try {
        // Fetch notes from the database
        final notes = await localDataSource.getNotes(event.folderId);

        // Make a mutable copy of the notes
        final mutableNotes = List<Map<String, dynamic>>.from(notes);

        // Sort the notes alphabetically by title with null safety
        mutableNotes.sort((a, b) {
          final titleA = (a['title'] ?? '').toString().toLowerCase();
          final titleB = (b['title'] ?? '').toString().toLowerCase();
          return titleA.compareTo(titleB);
        });

        emit(NotesLoaded(mutableNotes));
      } catch (e) {
        debugPrint('Error loading notes: $e');
        emit(NoteError('Failed to load notes: ${e.toString()}'));
      }
    });


    // Event to add a note
    on<AddNote>((event, emit) async {
      try {
        await localDataSource.insertNote({
          'folder_id': event.folderId,
          'title': event.title,
          'description': event.description, // Store Quill JSON format here
        });
        add(LoadNotes(folderId: event.folderId)); // Reload notes after adding
      } catch (e) {
        debugPrint('Error adding note: $e');
        emit(const NoteError('Failed to add note'));
      }
    });

    // Event to delete a note
    on<DeleteNote>((event, emit) async {
      try {
        await localDataSource.deleteNote(event.noteId);
        add(LoadNotes(folderId: event.folderId)); // Reload notes after deleting
      } catch (e) {
        debugPrint('Error deleting note: $e');
        emit(const NoteError('Failed to delete note'));
      }
    });

    // Event to update a note
    on<UpdateNote>((event, emit) async {
      try {
        await localDataSource.updateNote(event.noteId, {
          'title': event.title,
          'description': event.description, // Store Quill JSON format here
        });
        add(LoadNotes(folderId: event.folderId)); // Reload notes after updating
      } catch (e) {
        debugPrint('Error updating note: $e');
        emit(const NoteError('Failed to update note'));
      }
    });
  }
}
