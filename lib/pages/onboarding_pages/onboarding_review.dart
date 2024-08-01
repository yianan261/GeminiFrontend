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
  String description = "";
  bool isLoading = true;
  String? errorMessage;
  List<String> additionalDescriptions = [];

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final responseData = await getUser();
      print(responseData);
      setState(() {
        if (responseData.isNotEmpty) {
          description = responseData['description'] ?? "";
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

  void _addDescription(String additionalDescription) {
    setState(() {
      additionalDescriptions.add(additionalDescription);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        navigateTo: OnboardingStep4(), // Adjust this as necessary
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : Padding(
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
            DescriptionBox(description: description),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.auto_awesome, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  'Generated with Gemini',
                  style: TextStyle(
                    fontSize: 12,
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
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
      ),
    );
  }
}
