import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/navigation_utils.dart';
import '../pages/home.dart';
import 'user_service.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/drive.readonly'
  ],
);

final FirebaseFirestore firestore = FirebaseFirestore.instance;


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
        final String userEmail = user.email!;
        print("Firebase sign-in successful: $userEmail");

        // Check if the user is already in Firestore using email as the document ID
        final userDoc = await firestore.collection('users').doc(userEmail).get();
        Map<String, dynamic>? userData = userDoc.data();

        if (userData == null) {
          // User not found in Firestore, call the API to create the user
          userData = await createUser({
            'email': userEmail,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'accessLocationAllowed': false,
            'notificationAllowed': false,
            'onboarding_step3': false,
            'onboarding_step4': false,
            'onboardingCompleted': false,
            'interests': [],
          });

          if (userData != null) {
            final isNewUser = true;
            print('User successfully created in the API.');
            return {
              'user': user,
              'isNewUser': isNewUser,
              'userData': userData,
            };
          } else {
            print('Failed to create user via API.');
            return null;
          }
        } else {
          // User already exists in Firestore
          print('User already exists in Firestore.');
          return {
            'user': user,
            'isNewUser': false,
            'userData': userData,
          };
        }
      }
    }
  } catch (e) {
    print("Error during Google Sign-In: $e");
  }
  return null;
}

void handleSignIn(BuildContext context) async {
  try {
    var result = await signInWithGoogle();
    if (result != null) {
      User? user = result['user'];
      bool isNewUser = result['isNewUser'];
      Map<String, dynamic> userData = result['userData'];

      // Ensure boolean fields are not null
      bool onboardingCompleted = userData['onboardingCompleted'] ?? false;

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
  } catch (e) {
    print("Error in handleSignIn: $e");
  }
}
