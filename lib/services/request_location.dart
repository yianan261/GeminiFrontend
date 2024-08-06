import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/pages/onboarding_pages/onboarding_step2.dart';
import 'user_service.dart';  // Import the user_service file
import 'location_service.dart'; // Import the location_service file

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

      // Fetch the current location using LocationService
      LocationService locationService = LocationService();

      // Update onboarding step in Firestore
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          bool success = await updateUser({
            'email': user.email, // Add the email to the request body
            'accessLocationAllowed': true,
          });

          // Check the response status
          if (success) {
            // Navigate to onboarding step 2
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AllowNotificationsPage()),
            );
          } else {
            // Handle the error
            print('Failed to update user');
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
