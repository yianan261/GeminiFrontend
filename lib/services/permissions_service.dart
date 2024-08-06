import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/constants.dart';
import '/services/user_service.dart';

class PermissionsService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> requestLocationPermission(BuildContext context) async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Location permission granted'),
      ));
    } else {
      _showSettingsDialog(context, 'Location');
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        bool success = await updateUser({
          'email': user.email,
          'accessLocationAllowed': status.isGranted,
        });

        if (!success) {
          print('Failed to update user');
        }
      } catch (e) {
        print('Error updating user: $e');
      }
    }
  }


  Future<void> requestNotificationPermission(BuildContext context) async {
    var status = await Permission.notification.request();
    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Notification permission granted'),
      ));

      await _firebaseMessaging.requestPermission();
      final fCMToken = await _firebaseMessaging.getToken();
      //print('Token: $fCMToken');

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/updateUser?user_id=${user.email}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'email': user.email,
            'notificationAllowed': true,
          }),
        );

        if (response.statusCode == 200) {
          // Permission granted
        }
      }
    } else {
      _showSettingsDialog(context, 'Notification');
    }
  }

  void _showSettingsDialog(BuildContext context, String permissionType) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$permissionType permission denied. Please allow it from settings.'),
      action: SnackBarAction(
        label: 'Settings',
        onPressed: () {
          openAppSettings();
        },
      ),
    ));
  }
}
