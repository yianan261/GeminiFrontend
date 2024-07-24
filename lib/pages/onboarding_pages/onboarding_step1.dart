import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'onboarding_step2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../sign_out.dart'; // Import the sign-out function

class AllowLocationPage extends StatefulWidget {
  const AllowLocationPage({Key? key}) : super(key: key);

  @override
  _AllowLocationPageState createState() => _AllowLocationPageState();
}

class _AllowLocationPageState extends State<AllowLocationPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _checkLocationPermission() async {
    // Request location permission using permission_handler
    print('Requesting location permission...');
    PermissionStatus permissionStatus = await Permission.locationWhenInUse.request();
    print('Location permission status: $permissionStatus');

    if (permissionStatus.isGranted) {
      print('Location permission granted');
      // Update the onboarding step in Firestore
      User? user = auth.currentUser;
      if (user != null) {
        await firestore.collection('users').doc(user.uid).update({
          'accessLocationAllowed': true,
        });
        print('Location access allowed updated in Firestore');

        // Navigate to the next onboarding step
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AllowNotificationsPage()),
        );
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      print('Location permission permanently denied. Opening app settings.');
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => signOut(context), // Call the sign-out function
          ),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 50.0,
                    color: Colors.black,
                  ),
                  SizedBox(width: 10.0),
                  Flexible(
                    child: Text(
                      'Allow access to your location to explore places near you.',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _checkLocationPermission,
                child: Text('Next', style: TextStyle(fontFamily: 'Roboto')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
