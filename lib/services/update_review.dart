import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/user_service.dart';
import '/pages/home.dart';

// Function to update onboarding step
Future<void> updateReview(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('User not logged in');
    return;
  }

  try {
    bool success = await updateUser({
      'email': user.email,
      'onboardingCompleted': true,
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      print('Failed to update onboarding step.');
    }
  } catch (e) {
    print('Error updating onboarding step: $e');
  }
}

// Function to add description
Future<void> addDescription(BuildContext context, String additionalDescription) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('User not logged in');
    return;
  }

  try {
    bool success = await updateUser({
      'email': user.email,
      'userDescription': additionalDescription,
    });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update description')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating description: $e')));
  }
}
