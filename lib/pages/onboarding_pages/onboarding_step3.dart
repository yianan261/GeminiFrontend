import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/components/back_button.dart';
import '/components/my_button.dart';
import 'onboarding_step2.dart';

class UploadGoogleTakeout extends StatelessWidget {
  const UploadGoogleTakeout({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> fetchUserInfo() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching user info: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: MyBackButton(
          navigateTo: const AllowNotificationsPage(),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching user info'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('User not found'));
          } else {
            String userName = snapshot.data!['displayName'] ?? 'User';
            return Center(
              child: Text(
                'Welcome, $userName!',
                style: TextStyle(fontSize: 24),
              ),
            );
          }
        },
      ),
    );
  }
}
