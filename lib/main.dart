import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';

import 'core/database/app_database.dart';
import 'features/folders/presentation/bloc/folder_bloc.dart';
import 'features/folders/presentation/bloc/folder_event.dart';
import 'features/folders/presentation/screens/folder_page.dart';
import 'features/notes/data/data_sources/note_local_datasource.dart';
import 'features/notes/presentation/bloc/note_bloc.dart';
import 'features/folders/data/datasources/folder_local_datasource.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  final Database db = await AppDatabase().database;

  // Create the data sources
  final FolderLocalDataSource folderLocalDataSource = FolderLocalDataSource(db);
  final NoteLocalDataSource noteLocalDataSource = NoteLocalDataSource(db);

  runApp(MyApp(
    folderLocalDataSource: folderLocalDataSource,
    noteLocalDataSource: noteLocalDataSource,
  ));
}

class MyApp extends StatelessWidget {
  final FolderLocalDataSource folderLocalDataSource;
  final NoteLocalDataSource noteLocalDataSource;

  const MyApp({
    Key? key,
    required this.folderLocalDataSource,
    required this.noteLocalDataSource,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FolderBloc(folderLocalDataSource)..add(LoadFolders()),
        ),
        BlocProvider(
          create: (context) => NoteBloc(noteLocalDataSource),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Folder and Notes App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FolderPage(noteLocalDataSource: noteLocalDataSource,),
      ),
    );
  }
}
