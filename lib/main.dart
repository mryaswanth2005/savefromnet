import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String> downloadFile(String url, String fileName) async {
  Dio dio = Dio();
  try {
    // Check storage permissions
    if (Platform.isAndroid) {
      await _requestPermission(Permission.storage);
    } else if (Platform.isIOS) {
      await _requestPermission(Permission.photos);
    }

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
    return fullPath;
  } catch (e) {
    print('Error downloading file: $e');
    return '';
  }
}

Future<void> _requestPermission(Permission permission) async {
  final status = await permission.request();
  if (status.isGranted) {
    print("Permission granted");
  } else if (status.isDenied) {
    print("Permission denied");
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DownloadPage(),
    );
  }
}

class DownloadPage extends StatefulWidget {
  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final TextEditingController _urlController = TextEditingController();
  String _downloadedFilePath = '';

  final String fileName = 'downloaded_file.pdf'; // Desired file name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download File'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Enter File URL',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String fileUrl = _urlController.text;
                  if (fileUrl.isNotEmpty) {
                    String downloadedFilePath =
                        await downloadFile(fileUrl, fileName);
                    if (downloadedFilePath.isNotEmpty) {
                      setState(() {
                        _downloadedFilePath = downloadedFilePath;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Download completed')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Download failed')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('URL is empty')),
                    );
                  }
                },
                child: Text('Download File'),
              ),
              SizedBox(height: 20),
              if (_downloadedFilePath.isNotEmpty)
                Text(
                  'File downloaded to:\n$_downloadedFilePath',
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
