import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/pages/onboarding_pages/onboarding_step3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/constants.dart';

final _firebaseMessaging = FirebaseMessaging.instance;

Future<void> initNotifications() async {
  await _firebaseMessaging.requestPermission();
  final fCMToken = await _firebaseMessaging.getToken();
  print('Token: $fCMToken');
}

Future<void> permissionNotification(BuildContext context) async {
  var status = await Permission.notification.request();
  if (status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification permission granted')));

    //INIT NOTIFICATION
    initNotifications();

    //update firestore
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

      //navigate to onboarding step 3
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingStep3()),
        );
      }
    }

  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          'Notification permission permanently denied. Please allow it from settings.'),
      action: SnackBarAction(
        label: 'Settings',
        onPressed: () {
          openAppSettings();
        },
      ),
    ));
  }
}
