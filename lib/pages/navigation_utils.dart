import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome.dart';
import 'home.dart';
import 'onboarding_pages/onboarding_step1.dart';
import 'onboarding_pages/onboarding_step2.dart';
import 'onboarding_pages/onboarding_step3.dart';
import 'onboarding_pages/onboarding_review.dart';
import 'onboarding_pages/onboarding_step4.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<void> navigateUser(BuildContext context, User user) async {
  DocumentSnapshot userDoc = await firestore.collection('users').doc(user.uid).get();

  if (userDoc.exists) {
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    bool accessLocationAllowed = userData?['accessLocationAllowed'] ?? false;
    bool notificationAllowed = userData?['notificationAllowed'] ?? false;
    bool onboarding_step3 = userData?['onboarding_step3'] ?? false;
    bool onboarding_step4 = userData?['onboarding_step4'] ?? false;
    bool onboardingCompleted = userData?['onboardingCompleted'] ?? false;

    if (!accessLocationAllowed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AllowLocationPage()),
      );
    } else if (!notificationAllowed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AllowNotificationsPage()),
      );
    } else if (!onboarding_step3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingStep3()),
      );
    } else if (!onboarding_step4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingStep4()),
      );
    } else if (!onboardingCompleted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingReviewPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  } else {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Welcome()),
    );
  }
}