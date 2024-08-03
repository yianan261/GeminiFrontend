import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/navigation_utils.dart';
import '../pages/home.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/drive.readonly'
  ],

);

Future<Map<String, dynamic>?> signInWithGoogle() async {
  try {
    print("Attempting to sign in with Google...");
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      print("Google sign-in successful: ${googleSignInAccount.email}");
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        print("Firebase sign-in successful: ${user.email}");
        print("User ID: ${user.uid}");
        print("User Name: ${user.displayName}");
        print("User Email: ${user.email}");
        print("User Photo URL: ${user.photoURL}");

        // Check if the user is already in the database
        final userDoc = await firestore.collection('users').doc(user.uid).get();
        bool isNewUser = false;
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

        if (userData == null) {
          // User not found in the database, create a new user
          userData = {
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
            'accessLocationAllowed': false,
            'notificationAllowed': false,
            'onboarding_step3': false,
            'onboarding_step4': false,
            'onboardingCompleted': false,
          };
          await firestore.collection('users').doc(user.uid).set(userData);
          isNewUser = true;
        }
        return {
          'user': user,
          'isNewUser': isNewUser,
          'userData': userData,
        };
      }
    }
  } catch (e) {
    print("Error during Google Sign-In: $e");
  }
  return null;
}

void handleSignIn(BuildContext context) async {
  var result = await signInWithGoogle();
  if (result != null) {
    User? user = result['user'];
    bool isNewUser = result['isNewUser'];
    Map<String, dynamic> userData = result['userData'];
    bool onboardingCompleted = userData['onboardingCompleted'];

    print("User: ${user?.email}, Is New User: $isNewUser");

    if (isNewUser || !onboardingCompleted) {
      print("User needs to complete onboarding: ${user?.email}");
      await navigateUser(context, user!);
    } else {
      print("User has completed onboarding: ${user?.email}");
      // Navigate to the home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }
}

