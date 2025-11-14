import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class InvoicePdfService {
  /// Download invoice file from URL
  static Future<String?> downloadInvoiceAsPdf({
    required String invoiceUrl,
    required String invoiceNumber,
  }) async {
    try {
      // Request storage permission for Android
      if (Platform.isAndroid) {
        final status = await _requestStoragePermission();
        if (!status) {
          throw Exception('Storage permission denied');
        }
      }

      // Fetch HTML content from URL
      debugPrint('Downloading invoice from: $invoiceUrl');
      final response = await http.get(Uri.parse(invoiceUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to download invoice: ${response.statusCode}');
      }

      // Get the file content
      final fileContent = response.bodyBytes;
      debugPrint(
        'Invoice downloaded successfully (${fileContent.length} bytes)',
      );

      // Save file to device (as HTML since backend provides HTML)
      final filePath = await _saveFile(
        fileData: fileContent,
        fileName:
            'Invoice_${invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.html',
      );

      return filePath;
    } catch (e) {
      debugPrint('Error downloading invoice: $e');
      rethrow;
    }
  }

  /// Request storage permission (for Android)
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+)
      if (await Permission.photos.request().isGranted) {
        return true;
      }

      // For older Android versions
      if (await Permission.storage.request().isGranted) {
        return true;
      }

      // Try requesting manage external storage for Android 11+
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }

      return false;
    }
    return true; // iOS doesn't need explicit storage permission
  }

  /// Save file to device storage
  static Future<String> _saveFile({
    required Uint8List fileData,
    required String fileName,
  }) async {
    Directory? directory;

    if (Platform.isAndroid) {
      // Try to save in Downloads folder
      directory = Directory('/storage/emulated/0/Download');

      if (!await directory.exists()) {
        // Fallback to app documents directory
        directory = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      // For iOS, use application documents directory
      directory = await getApplicationDocumentsDirectory();
    } else {
      // For other platforms
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      throw Exception('Could not access storage directory');
    }

    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    // Write file data
    await file.writeAsBytes(fileData);

    debugPrint('File saved to: $filePath');
    return filePath;
  }

  /// Open PDF file with system viewer
  static Future<void> openPdf(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('PDF file not found');
      }

      // Use url_launcher or platform-specific intent to open PDF
      // This is handled in the UI layer
    } catch (e) {
      debugPrint('Error opening PDF: $e');
      rethrow;
    }
  }

  /// Get readable file path for displaying to user
  static String getReadableFilePath(String filePath) {
    if (filePath.contains('/storage/emulated/0/Download')) {
      return 'Downloads/${filePath.split('/').last}';
    } else if (filePath.contains('Documents')) {
      return 'Documents/${filePath.split('/').last}';
    }
    return filePath.split('/').last;
  }
}
