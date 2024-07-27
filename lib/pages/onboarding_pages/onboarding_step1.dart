import 'package:flutter/material.dart';
import 'package:wander_finds_gemini/components/my_button.dart';
import '/components/signout_button.dart';
import '/services/request_location.dart';

class AllowLocationPage extends StatelessWidget {
  const AllowLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          SignoutButton(),
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
                onTap: () => requestLocation(context),
              )
            ],
          ),
        ),
      ),
    );
  }
}