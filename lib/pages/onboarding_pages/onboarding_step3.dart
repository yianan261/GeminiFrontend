import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '/components/back_button.dart';
import '/components/my_button.dart';
import 'onboarding_step2.dart';
import '/constants.dart'; // Import the config file

class OnboardingStep3 extends StatefulWidget {
  const OnboardingStep3({Key? key}) : super(key: key);

  @override
  _OnboardingStep3State createState() => _OnboardingStep3State();
}

class _OnboardingStep3State extends State<OnboardingStep3> {
  String? userName;
  bool isLoading = true;
  String? errorMessage;

  Future<void> fetchUserInfo(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>?;
        //print(responseData);
        setState(() {
          userName = responseData?['data']?['displayName'] ?? 'User';
          //print(userName);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error fetching user info: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching user info: $e';
        isLoading = false;
      });
    }
  }

  void uploadTakeoutData() {
    // Define the function to handle data upload
  }

  @override
  void initState() {
    super.initState();
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      fetchUserInfo(currentUser.uid);
    } else {
      setState(() {
        errorMessage = 'User not logged in';
        isLoading = false;
      });
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
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : errorMessage != null
            ? Text(errorMessage!)
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome, $userName!',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Flexible(
                child: Text(
                  'To enhance your experience, you can upload your Google Takeout data. This will help us discover personalized point of interests for you',
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              MyButton(
                text: "Upload Google Takeout Data",
                onTap: uploadTakeoutData,
              ),
              GestureDetector(
                onTap: () {
                  // Define click action here
                },
                child: Text(
                  'Maybe later',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
