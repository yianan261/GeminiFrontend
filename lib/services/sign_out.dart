import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sign_in.dart';
import '../pages/welcome.dart';

//final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
Future<void> signOut(BuildContext context) async {
  try {
    // Sign out from GoogleSignIn
    print('Attempting to sign out from GoogleSignIn...');
    await googleSignIn.signOut();
    print('Signed out from GoogleSignIn.');

    // Sign out from FirebaseAuth
    print('Attempting to sign out from FirebaseAuth...');
    await FirebaseAuth.instance.signOut();
    print('Signed out from FirebaseAuth.');

    // Check if signed out successfully
    if (FirebaseAuth.instance.currentUser == null) {
      print('Successfully signed out from Firebase.');
      // Navigate to the Welcome page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Welcome()),
            (route) => false,
      );
    } else {
      print('Error: User is still signed in Firebase.');
    }
  } catch (e) {
    print('Error signing out: $e');
  }
}