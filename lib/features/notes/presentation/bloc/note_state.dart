part of 'note_bloc.dart';



// Define base class for Note states
abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object> get props => [];
}

// Initial state when no notes are loaded
class NoteInitial extends NoteState {}

// State when notes are being loaded
class NoteLoading extends NoteState {}

// State when notes are successfully loaded
class NotesLoaded extends NoteState {
  final List<Map<String, dynamic>> notes;

  const NotesLoaded(this.notes);

  @override
  List<Object> get props => [notes];
}

// State when a single note is successfully loaded (e.g., for editing)
class NoteLoaded extends NoteState {
  final Map<String, dynamic> note;

  const NoteLoaded(this.note);

  @override
  List<Object> get props => [note];
}

// State when a note has been successfully added or updated
class NoteSaved extends NoteState {}

// State when an error occurs while handling notes
class NoteError extends NoteState {
  final String message;

  const NoteError(this.message);

  @override
  List<Object> get props => [message];
}
