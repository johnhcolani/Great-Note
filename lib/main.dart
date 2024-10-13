import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greate_note_app/core/theme/theme_bloc.dart';
import 'package:greate_note_app/splash_feature/presentation/screens/bloc/splash_bloc.dart';
import 'package:greate_note_app/splash_feature/presentation/screens/splash_screen.dart';
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

  MyApp({
    super.key,
    required this.folderLocalDataSource,
    required this.noteLocalDataSource,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider(
          create: (context) => SplashBloc(),
        ),
        BlocProvider(
          create: (context) =>
          FolderBloc(folderLocalDataSource)
            ..add(LoadFolders()),
        ),
        BlocProvider(
          create: (context) => NoteBloc(noteLocalDataSource),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Folder and Notes App',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: state.themeMode,
            home: SplashScreen(noteLocalDataSource: noteLocalDataSource),
          );
        },
      ),
    );
  }

  final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black)
      ),
      appBarTheme: const AppBarTheme(
          color: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white)
      )
  );
  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blueGrey,
    scaffoldBackgroundColor: Colors.black,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.black,
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );
}
