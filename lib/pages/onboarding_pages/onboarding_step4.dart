import 'package:flutter/material.dart';
import '/components/my_button.dart';
import '/components/my_appbar.dart';
import 'onboarding_step3.dart';
import '/services/update_interests.dart';
import '/services/user_service.dart';
import '/components/interest_list.dart';
import '/components/my_textfield.dart';
import '/models/interests_model.dart';

class OnboardingStep4 extends StatefulWidget {
  const OnboardingStep4({Key? key}) : super(key: key);

  @override
  _OnboardingStep4State createState() => _OnboardingStep4State();
}

class _OnboardingStep4State extends State<OnboardingStep4> {
  static List<Interests> predefinedInterests = [
    Interests(title: 'Architecture', imagePath: 'assets/images/architecture.png'),
    Interests(title: 'Art & Culture', imagePath: 'assets/images/art.png'),
    Interests(title: 'Food, Drink & Fun', imagePath: 'assets/images/food.png'),
    Interests(title: 'History', imagePath: 'assets/images/history.png'),
    Interests(title: 'Nature', imagePath: 'assets/images/nature.png'),
    Interests(title: 'Cool & Unique', imagePath: 'assets/images/unique.png'),
  ];

  List<Interests> allInterests = [];
  List<String> _selectedInterests = [];
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
          _selectedInterests = List<String>.from(responseData['interests'] ?? []);
          allInterests = [...predefinedInterests];

          // Add any additional interests that are not in the predefined list
          for (var interest in _selectedInterests) {
            if (!allInterests.any((item) => item.title == interest)) {
              allInterests.add(Interests(title: interest, imagePath: 'assets/images/default.png', isOriginal: false));
            }
          }

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

  void _toggleInterest(String interestTitle) {
    setState(() {
      if (_selectedInterests.contains(interestTitle)) {
        _selectedInterests.remove(interestTitle);
      } else {
        _selectedInterests.add(interestTitle);
      }
    });
  }

  void _addInterest(String interestTitle) {
    if (_selectedInterests.contains(interestTitle)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Already added')),
      );
    } else if (interestTitle.isNotEmpty) {
      setState(() {
        Interests newInterest = Interests(title: interestTitle, imagePath: 'assets/images/default.png', isOriginal: false);
        allInterests.add(newInterest);
        _selectedInterests.add(interestTitle);
      });
    }
  }

  void _deleteInterest(String interestTitle) {
    setState(() {
      _selectedInterests.remove(interestTitle);
      allInterests.removeWhere((interest) => interest.title == interestTitle && !interest.isOriginal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : errorMessage != null
            ? Text(errorMessage!)
            : Padding(
          padding: const EdgeInsets.fromLTRB(50.0, 16.0, 50.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Select your interests",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Expanded( // Use Expanded to make the list take up available space and be scrollable
                child: ListView(
                  children: [
                    InterestList(
                      items: allInterests, // Use the combined list
                      selectedInterests: _selectedInterests,
                      onInterestToggle: _toggleInterest,
                      onInterestDelete: _deleteInterest,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              AddableTextField(
                onAdd: _addInterest,
                hintText: "Add your other interests...",
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: MyButton(
                  text: "Submit",
                  onTap: () {
                    updateOnboardingStep4(
                      context,
                      _selectedInterests,
                      "",
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
