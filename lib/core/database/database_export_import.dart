import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

class DatabaseExportImport {
  bool isFilePickerActive = false; // Add this flag
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

      // Use platform-specific directories for exporting
      Directory exportDir;
      if (Platform.isAndroid) {
        exportDir = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory(); // Fallback for Android
      } else if (Platform.isIOS) {
        exportDir = await getApplicationDocumentsDirectory(); // iOS path
      } else {
        throw UnsupportedError('Platform not supported');
      }

      // Copy the database to the export directory
      String exportPath = join(exportDir.path, 'app_database_export.db');
      await dbFile.copy(exportPath);

      // Share the exported file
      await Share.shareXFiles([XFile(exportPath)],
          text: 'Here is the exported database.');
      print('Database exported successfully: $exportPath');
    } catch (e) {
      print('Error exporting database: $e');
    }
  }

  Future<void> importDatabase() async {
    if (isFilePickerActive) {
      print('File Picker is already in progress.');
      return;
    }

    isFilePickerActive = true; // Set the flag to true
    try {
      // File picker for .db files
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'], // Restrict to .db files
      );

      if (result == null) {
        print('User canceled the file picker.');
        return;
      }

      final selectedFilePath = result.files.single.path;
      if (selectedFilePath == null) {
        print('Selected file path is null.');
        return;
      }

      final selectedFile = File(selectedFilePath);

      // Copy the selected file to the app's database directory
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String dbPath = join(appDocDir.path, 'app_database.db');
      await selectedFile.copy(dbPath);

      print('Database imported successfully to: $dbPath');
    } catch (e) {
      print('Error importing database: $e');
    } finally {
      isFilePickerActive = false; // Reset the flag in both success and failure cases
    }
  }
}
