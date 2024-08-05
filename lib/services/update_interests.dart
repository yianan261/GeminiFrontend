import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '/constants.dart';
import '/pages/onboarding_pages/onboarding_review.dart';

Future<void> updateOnboardingStep4(BuildContext context, List<String> interests, String otherInterest) async {
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
        'interests': interests,
        'onboarding_step4': true,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReviewPage()),
      );
    } else {
      print('Failed to update onboarding step: ${response.statusCode}');
    }
  } catch (e) {
    print('Error updating onboarding step: $e');
  }
}
