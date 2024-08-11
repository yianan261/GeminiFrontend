import 'package:flutter/material.dart';
import '/services/user_service.dart'; // Import your services here
import '/pages/onboarding_pages/onboarding_review.dart';

Future<void> updateOnboardingStep4(BuildContext context, List<String> interests, String otherInterest) async {
  try {
    // Fetch the user's current data
    final userData = await getUser();

    if (userData.isEmpty) {
      print('Failed to fetch user data');
      return;
    }

    final bool onboardingCompleted = userData['onboardingCompleted'] ?? false;

    // Update the user's interests and set onboarding_step4 to true
    final updateSuccess = await updateUser({
      'interests': interests,
      'onboarding_step4': true,
    });

    if (updateSuccess) {
      if (onboardingCompleted) {
        Navigator.pop(context);
        getUser();// Go back to the previous page
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ReviewPage()), // Navigate to the review page
        );
      }
    } else {
      print('Failed to update user data');
    }
  } catch (e) {
    print('Error during onboarding step 4 update: $e');
  }
}
