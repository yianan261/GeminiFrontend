import 'package:flutter/material.dart';
import '/components/my_appbar.dart';
import 'onboarding_step4.dart';

class OnboardingReviewPage extends StatelessWidget {
  const OnboardingReviewPage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        navigateTo: const OnboardingStep4(), // Adjust this as necessary
      ),
      body: const Center(
        child: Text('Review Page!'),
      ),
    );
  }
}