import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

class DatabaseExportImport {
  Future<void> exportDatabase() async {
    try {
      // Get the app's database path
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String dbPath = join(appDocDir.path, 'app_database.db');

      // Check if the database file exists
      File dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        throw Exception('Database file not found.');
      }

      // Copy the database to the Downloads directory
      Directory? downloadsDir = await getExternalStorageDirectory();
      String exportPath = join(downloadsDir!.path, 'app_database_export.db');
      await dbFile.copy(exportPath);

      // Share the exported file
      Share.shareFiles([exportPath], text: 'Here is the exported database.');
      print('Database exported to: $exportPath');
    } catch (e) {
      print('Error exporting database: $e');
    }
  }

  Future<void> importDatabase() async {
    try {
      // Let the user pick a database file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'], // Restrict to .db files
      );

      if (result != null) {
        File selectedFile = File(result.files.single.path!);

        // Get the app's database directory
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String dbPath = join(appDocDir.path, 'app_database.db');

        // Replace the existing database with the selected file
        await selectedFile.copy(dbPath);
        print('Database imported and saved to: $dbPath');
      } else {
        print('No file selected.');
      }
    } catch (e) {
      print('Error importing database: $e');
    }
  }
}
