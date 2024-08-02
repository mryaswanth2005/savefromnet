import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadFile(String url, String fileName) async {
  Dio dio = Dio();

  try {
    // Get the application documents directory
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    // Construct the full path to the file
    String fullPath = '$appDocPath/$fileName';

    // Start the download
    await dio.download(
      url,
      fullPath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          print('Progress: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      },
    );

    print('File downloaded to $fullPath');
  } catch (e) {
    print('Error downloading file: $e');
  }
}
