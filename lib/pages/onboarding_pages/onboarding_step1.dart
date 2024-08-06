import 'package:flutter/material.dart';
import 'package:wander_finds_gemini/components/my_button.dart';
import 'package:wander_finds_gemini/pages/onboarding_pages/onboarding_step2.dart';
import '/components/icon_button.dart';
import '/services/sign_out.dart';
import '/services/permissions_service.dart';

class AllowLocationPage extends StatefulWidget {
  const AllowLocationPage({super.key});

  @override
  _AllowLocationPageState createState() => _AllowLocationPageState();
}

class _AllowLocationPageState extends State<AllowLocationPage> {
  final PermissionsService _permissionsService = PermissionsService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          MyIconButton(
            icon: Icon(Icons.logout),
            onPressed: () => signOut(context),
          ),
        ],
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
                    Icons.location_on,
                    size: 50.0,
                  ),
                  SizedBox(width: 10.0),
                  Flexible(
                    child: Text(
                      'Allow access to your location to explore places near you.',
                      style: TextStyle(fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              MyButton(
                text: "Next",
                onTap: () async {
                  await _permissionsService.requestLocationPermission(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AllowNotificationsPage()),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}