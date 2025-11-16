import 'dart:io';
import 'dart:developer' as developer;
import 'package:share_plus/share_plus.dart';

/// Service to handle opening files across platforms
class FileOpenerService {
  /// Open a file using the system's default application
  ///
  /// Uses share_plus to trigger the "Open with" dialog on Android/iOS
  static Future<bool> openFile(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        developer.log(
          'File does not exist: $filePath',
          name: 'FileOpenerService',
          level: 900,
        );
        return false;
      }

      // Use Share to open the file
      // This triggers "Open with" on Android and iOS
      final xFile = XFile(filePath);
      final result = await Share.shareXFiles([
        xFile,
      ], subject: _getFileName(filePath));

      developer.log(
        'File share result: ${result.status}',
        name: 'FileOpenerService',
      );

      // ShareResultStatus.success means user selected an app
      // ShareResultStatus.dismissed means user canceled
      // On Android, this will show "Open with" dialog
      return result.status != ShareResultStatus.unavailable;
    } catch (e, s) {
      developer.log(
        'Error opening file',
        name: 'FileOpenerService',
        level: 1000,
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }

  /// Get file name from path
  static String _getFileName(String filePath) {
    return filePath.split('/').last;
  }
}
