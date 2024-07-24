import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome.dart';
import 'navigation_utils.dart'; // Import the utility function

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Use a Future to delay the navigation until after the initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserStatus();
    });
  }

  Future<void> _checkUserStatus() async {
    User? user = _auth.currentUser;

    if (user == null) {
      // User is not signed in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Welcome()),
      );
    } else {
      // User is signed in, navigate to the appropriate page
      await navigateUser(context, user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
