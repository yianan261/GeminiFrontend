import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/navigation_utils.dart';
import '/pages/onboarding_pages/onboarding_step2.dart';
 
Future<void> requestLocation(BuildContext context) async {
  var status = await Permission.location.request();
  if (status.isGranted){
    //informed user for permission granted
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Location permission granted'),
    ));

    //update onboarding step in firestore
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null){
      await firestore.collection('users').doc(user.uid).update({
        'accessLocationAllowed': true,
      });
    }

    //navigate to step 2
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AllowNotificationsPage()),
    );

    
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Location permission denied. Please allow it from settings.'),
      action: SnackBarAction(
        label: 'Settings',
        onPressed: () {
          openAppSettings();
        },
      ),
    ));
  }
}