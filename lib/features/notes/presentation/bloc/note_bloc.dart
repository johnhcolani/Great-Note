import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';


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
        final notes = await localDataSource.getNotes(event.folderId);
        emit(NotesLoaded(notes));
      } catch (e) {
        print('Error loading notes: $e');
        emit(const NoteError('Failed to load notes'));
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
        print('Error adding note: $e');
        emit(const NoteError('Failed to add note'));
      }
    });

    // Event to delete a note
    on<DeleteNote>((event, emit) async {
      try {
        await localDataSource.deleteNote(event.noteId);
        add(LoadNotes(folderId: event.folderId)); // Reload notes after deleting
      } catch (e) {
        print('Error deleting note: $e');
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
        print('Error updating note: $e');
        emit(const NoteError('Failed to update note'));
      }
    });
  }
}
