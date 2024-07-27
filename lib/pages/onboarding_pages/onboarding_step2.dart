import 'package:flutter/material.dart';
import 'package:wander_finds_gemini/pages/onboarding_pages/onboarding_step1.dart';
import 'package:wander_finds_gemini/services/request_notifications.dart';
import '/components/my_button.dart';
import '/components/my_appbar.dart';

class AllowNotificationsPage extends StatelessWidget {
  const AllowNotificationsPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: CustomAppBar(
        navigateTo: const AllowLocationPage(), // Adjust this as necessary
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: 50.0,
                  ),
                  SizedBox(width: 10.0),
                  Flexible(
                    child: Text(
                      'Allow notifications to receive updateds for point of interests.',
                      style: TextStyle(fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              MyButton(
                text: "Next",
                onTap: () => permissionNotification(context),
              )
            ],
          ),
        ),
      ),
    );
  }
}