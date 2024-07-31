import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '/constants.dart';
import '/pages/onboarding_pages/onboarding_review.dart';
import '/models/interests_model.dart';

Future<void> updateOnboardingStep4(BuildContext context, List<String> interests, String otherInterest) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print('User not logged in');
    return;
  }

  String userId = currentUser.uid;

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/updateUser?user_id=$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'Interests': interests,
        'otherInterest': otherInterest,
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
