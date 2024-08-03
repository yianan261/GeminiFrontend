import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'sign_in.dart'; // Import the sign_in.dart to use the googleSignIn instance

class GoogleDriveHandler {
  Future<void> authenticateAndPickFile(BuildContext context) async {
    try {
      GoogleSignInAccount? googleUser = googleSignIn.currentUser;

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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No file selected')));
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }
}
