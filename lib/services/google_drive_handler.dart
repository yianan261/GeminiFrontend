import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'sign_in.dart'; // Import the sign_in.dart to use the googleSignIn instance
import '/constants.dart'; // Import the constants.dart to use the baseUrl

class GoogleDriveHandler {
  Future<void> authenticateAndPickFile(BuildContext context) async {
    try {
      GoogleSignInAccount? googleUser = googleSignIn.currentUser;

      if (googleUser == null) {
        googleUser = await googleSignIn.signInSilently();
      }

      if (googleUser == null) {
        googleUser = await googleSignIn.signIn();
      }

      if (googleUser == null) {
        throw Exception('User not signed in');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null) {
        throw Exception('Failed to obtain access token');
      }

      // Authenticate with the Drive API
      final client = authenticatedClient(
        http.Client(),
        AccessCredentials(
          AccessToken(
            'Bearer',
            googleAuth.accessToken!,
            DateTime.now().toUtc().add(Duration(hours: 1)), // Ensure the DateTime is in UTC
          ),
          null, // No refresh token available
          [drive.DriveApi.driveScope, 'email'],
        ),
      );

      final driveApi = drive.DriveApi(client);

      // List files in the user's Google Drive
      final files = await driveApi.files.list(spaces: 'drive');

      // Handle file selection
      final selectedFile = await showDialog<drive.File?>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Pick a file'),
            content: Container(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: files.files?.length ?? 0,
                itemBuilder: (context, index) {
                  final file = files.files![index];
                  return ListTile(
                    title: Text(file.name ?? 'No name'),
                    onTap: () => Navigator.of(context).pop(file),
                  );
                },
              ),
            ),
          );
        },
      );

      if (selectedFile != null) {
        final media = await driveApi.files.get(selectedFile.id!,
            downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/${selectedFile.name}');
        final List<int> dataStore = [];
        await for (var data in media.stream) {
          dataStore.insertAll(dataStore.length, data);
        }
        await file.writeAsBytes(dataStore);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File selected: ${file.path}')));

        // Upload the file to the backend
        await uploadFileToBackend(file, googleUser.email, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No file selected')));
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  Future<void> uploadFileToBackend(File file, String? userEmail, BuildContext context) async {
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User email is required')));
      return;
    }

    final mimeType = lookupMimeType(file.path);
    final uri = Uri.parse('$baseUrl/process-takeout-files'); // Use the baseUrl
    final request = http.MultipartRequest('POST', uri)
      ..fields['email'] = userEmail
      ..files.add(await http.MultipartFile.fromPath(
        'files[]',
        file.path,
        contentType: MediaType.parse(mimeType!),
      ));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Files processed and saved successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to process files: ${response.statusCode}')));
      }
    } catch (error) {
      print('Error uploading file: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading file: $error')));
    }
  }
}
