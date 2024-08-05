import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '/constants.dart';
import '/pages/onboarding_pages/onboarding_step4.dart';
import 'google_drive_handler.dart';

Future<void> updateOnboardingStep3(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('User not logged in');
    return;
  }

  String? userId = user.email;

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/updateUser?user_id=$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': user.email,
        'onboarding_step3': true,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingStep4()),
      );
    } else {
      print('Failed to update onboarding step: ${response.statusCode}');
    }
  } catch (e) {
    print('Error updating onboarding step: $e');
  }
}
final googleDriveHandler = GoogleDriveHandler();
Future<void> uploadTakeoutData(BuildContext context) async {
  try {
    await googleDriveHandler.authenticateAndPickFile(context);
    await updateOnboardingStep3(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}