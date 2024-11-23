part of 'folder_bloc.dart';


abstract class FolderState extends Equatable{

 const FolderState();
 @override
 // TODO: implement props
 List<Object?> get props =>[] ;
}
// Initial state when the app starts or the folder list is not loaded

class FolderInitial extends FolderState {}

// State when folders are loading (e.g., fetching from the database)
class FolderLoading extends FolderState{

}

// State when folders are successfully loaded
class FolderLoaded extends FolderState{
  final List<Map<String, dynamic>> folders;

  const FolderLoaded(this.folders);
  @override
  // TODO: implement props
  List<Object?> get props =>[folders] ;
}
// State when there is an error loading folders
class FolderError extends FolderState {
  final String message;

  const FolderError(this.message);

  @override
  List<Object> get props => [message];
}