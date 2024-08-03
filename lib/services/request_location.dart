import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/pages/onboarding_pages/onboarding_step2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/constants.dart';
import 'background_location_service.dart';  // Import the background location service

Future<void> requestLocation(BuildContext context) async {
  var status = await Permission.locationWhenInUse.request();
  if (status.isGranted) {
    // Request background location permission
    var backgroundStatus = await Permission.locationAlways.request();
    if (backgroundStatus.isGranted) {
      // Inform the user that permission was granted
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Background location permission granted'),
      ));

      // Start background location service
      BackgroundLocationService().start();

      // Update onboarding step in Firestore
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final response = await http.post(
            Uri.parse('$baseUrl/updateUser?user_id=${user.uid}'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'accessLocationAllowed': true,
            }),
          );

          // Check the response status
          if (response.statusCode == 200) {
            // Navigate to onboarding step 3
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AllowNotificationsPage()),
            );
          } else {
            // Handle the error
            print('Failed to update user: ${response.statusCode}');
            print('Response body: ${response.body}');
          }
        } catch (e) {
          // Print exceptions
          print('Error updating user: $e');
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Background location permission denied. Please allow it from settings.'),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () {
            openAppSettings();
          },
        ),
      ));
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Location permission denied. Please allow it from settings.'),
      action: SnackBarAction(
        label: 'Settings',
        onPressed: () {
          openAppSettings();
        },
      ),
    ));
  }
}
