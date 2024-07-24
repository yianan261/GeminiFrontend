import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import '/components/back_button.dart';
import '/components/my_button.dart';
import 'onboarding_step3.dart';
import 'onboarding_step1.dart';
import '../sign_out.dart';

class AllowNotificationsPage extends StatefulWidget {
  const AllowNotificationsPage({Key? key}) : super(key: key);

  @override
  _AllowNotificationPageState createState() => _AllowNotificationPageState();
}

class _AllowNotificationPageState extends State<AllowNotificationsPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestPermission();
  }

  Future<void> _checkNotificationPermission() async {
    PermissionStatus _permissionGranted = await Permission.notification.status;
    if (_permissionGranted.isDenied || _permissionGranted.isPermanentlyDenied) {
      _permissionGranted = await Permission.notification.request();
      if (_permissionGranted.isDenied || _permissionGranted.isPermanentlyDenied) {
        return;
      }
    }

    User? user = auth.currentUser;
    if (user != null) {
      await firestore.collection('users').doc(user.uid).update({
        'notificationAllowed': true,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UploadGoogleTakeoutPage()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButtonComponent(
          navigateTo: const AllowLocationPage(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () => signOut(context),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: 50.0, // Smaller size for the icon
                    color: Colors.black,
                  ),
                  //SizedBox(width: 5.0), // Space between icon and text
                  Flexible(
                    child: Text(
                      'Allow notifications to receive updates for point of interests.',
                      style: TextStyle(fontSize: 30),
                      textAlign: TextAlign.center, // Center the text within the Row
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                  onPressed: _checkNotificationPermission,
                  child: const Text('Next', style: TextStyle(fontFamily: 'Roboto')),
              )
            ],
          ),
        ),
      ),
    );
  }
}
