import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/navigation_utils.dart';
import '/pages/onboarding_pages/onboarding_step3.dart';

final _firebaseMessaging = FirebaseMessaging.instance;

Future<void> initNotifications() async {
  await _firebaseMessaging.requestPermission();
  final fCMToken = await _firebaseMessaging.getToken();
  print('Token: $fCMToken');
}

Future<void> permissionNotification(BuildContext context) async {
  var status = await Permission.notification.request();
  if (status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification permission granted')));

    //INIT NOTIFICATION
    initNotifications();

    //update firestore
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null){
      await firestore.collection('users').doc(user.uid).update({
        'notificationAllowed': true,
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UploadGoogleTakeout()),
      );
    }

    //navigate to onboarding step 3
    //navigate to step 2



  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          'Notification permission permanently denied. Please allow it from settings.'),
      action: SnackBarAction(
        label: 'Settings',
        onPressed: () {
          openAppSettings();
        },
      ),
    ));
  }
}
