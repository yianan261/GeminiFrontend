import 'package:flutter/material.dart';
import '/components/my_button.dart';
import '/components/my_appbar.dart';
import 'onboarding_step2.dart';
import '/services/user_service.dart';
import '/services/update_step3.dart';

class OnboardingStep3 extends StatefulWidget {
  const OnboardingStep3({Key? key}) : super(key: key);

  @override
  _OnboardingStep3State createState() => _OnboardingStep3State();
}

class _OnboardingStep3State extends State<OnboardingStep3> {
  String? userName;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final responseData = await getUser();
      setState(() {
        if (responseData.isNotEmpty) {
          userName = responseData['displayName'] ?? 'User';
          isLoading = false;
        } else {
          errorMessage = 'Error fetching user info';
          isLoading = false;
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching user info: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        navigateTo: const AllowNotificationsPage(), // Adjust this as necessary
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
              SizedBox(height: 100),
              MyButton(
                text: "Upload Google Takeout Data",
                onTap: uploadTakeoutData
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  updateOnboardingStep3(context);
                },
                child: Text(
                  'Maybe later',
                  style: TextStyle(
                    fontSize: 12,
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
