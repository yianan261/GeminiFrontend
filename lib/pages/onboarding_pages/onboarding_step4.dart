import 'package:flutter/material.dart';
import '/components/my_appbar.dart'; // Make sure this points to your custom app bar file
import '/components/card_list.dart'; // Import the card list component
import 'onboarding_step3.dart';

class OnboardingStep4 extends StatelessWidget {
  const OnboardingStep4({Key? key}) : super(key: key);

  final List<Map<String, String>> interests = const [
    {'title': 'Architecture', 'imagePath': 'assets/images/architecture.jpg'},
    {'title': 'Art & Culture', 'imagePath': 'assets/images/art_culture.jpg'},
    {'title': 'Food, Drink & Fun', 'imagePath': 'assets/images/food_drink_fun.jpg'},
    {'title': 'History', 'imagePath': 'assets/images/history.jpg'},
    {'title': 'Nature', 'imagePath': 'assets/images/nature.jpg'},
    {'title': 'Cool & Unique', 'imagePath': 'assets/images/cool_unique.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        navigateTo: OnboardingStep3(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: CardList(interests: interests),
            ),
            SizedBox(height: 10),
            SizedBox(height: 8), // Same margin as the cards
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), // Same vertical padding as card margin
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Enter Other Interest',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



