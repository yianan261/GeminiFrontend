import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome.dart';
import 'home.dart';
import 'onboarding_pages/onboarding_step1.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<void> navigateUser(BuildContext context, User user) async {
  DocumentSnapshot userDoc = await firestore.collection('users').doc(user.uid).get();

  if (userDoc.exists) {
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    bool accessLocationAllowed = userData?['accessLocationAllowed'] ?? false;
    /*
    bool notificationAllowed = userData?['notificationAllowed'] ?? false;
    bool googleTakeoutUploaded = userData?['googleTakeoutUploaded'] ?? false;
    bool interestSelected = userData?['interestSelected'] ?? false;
    bool onboardingCompleted = userData?['onboardingCompleted'] ?? false;*/

    if (!accessLocationAllowed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AllowLocationPage()),
      );
    } /*else if (!notificationAllowed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AllowNotificationsPage()),
      );
    } else if (!googleTakeoutUploaded) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UploadGoogleTakeoutPage()),
      );
    } else if (!interestSelected) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SelectInterestPage()),
      );
    } else if (!onboardingCompleted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReviewConfirmPage()),
      );
    } */ else {
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