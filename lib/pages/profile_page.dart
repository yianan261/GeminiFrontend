import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/user_service.dart'; // Ensure this imports correctly
import '/pages/settings.dart'; // Ensure this imports correctly

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  String userName = '';
  String photoUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await getUser(); // Fetch user data from your database
      setState(() {
        userName = userData['name'] ?? '';
        photoUrl = userData['photoUrl'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()), // Ensure SettingsPage is created
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty ? Icon(Icons.person, size: 50) : null,
            ),
            SizedBox(height: 20),
            Text(
              userName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Add more user information here if needed
          ],
        ),
      ),
    );
  }
}
