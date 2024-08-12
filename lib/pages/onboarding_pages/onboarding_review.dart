import 'package:flutter/material.dart';
import '/components/my_textfield.dart';
import '/services/update_review.dart';
import '/services/user_service.dart';
import '/components/my_button.dart';
import '/components/my_appbar.dart';
import 'onboarding_step4.dart';
import '/components/container.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({Key? key}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  String geminiDescription = "";
  String userDescription = "";
  bool isLoading = true;
  String? errorMessage;
  List<String> additionalDescriptions = [];

  @override
  void initState() {
    super.initState();
    _generateAndFetchDescription();
  }

  Future<void> _generateAndFetchDescription() async {
    try {
      // Step 1: Generate the description
      final generateResponse = await generateUserDescription();

      // Step 2: Fetch the generated description from the database
      final responseData = await getUser();
      print(responseData);
      setState(() {
        if (responseData.isNotEmpty) {
          geminiDescription = responseData['geminiDescription'] ?? "";
          userDescription = responseData['userDescription'] ?? "";
          isLoading = false;
        } else {
          errorMessage = 'Error fetching user info';
          isLoading = false;
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error generating or fetching user info: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _addDescription(String additionalDescription) async {
    setState(() {
      additionalDescriptions.add(additionalDescription);
      userDescription += " $additionalDescription";
    });

    await addDescription(context, userDescription);
    // Show Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Got it!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        navigateTo: OnboardingStep4(), // Adjust this as necessary
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Your Description',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                Text(
                  'Based on your input, here is what we learned about you',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                DescriptionBox(description: geminiDescription),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                      child: Icon(
                          Icons.auto_awesome, color: Colors.white, size: 16),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Generated with Gemini',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Text(
                  'Feel free to add to or correct the description here.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.start,
                ),
                AddableTextField(
                  onAdd: _addDescription,
                  hintText:
                  "I like to explore hidden places on my walk with my dog in the afternoon...",
                ),
                SizedBox(height: 130),
              ],
            ),
          ),
          Positioned(
            bottom: 30, // 30 pixels above the bottom of the screen
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: MyButton(
                text: "Confirm & Start Exploring",
                onTap: () async {
                  await updateReview(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}