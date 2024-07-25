import 'package:flutter/material.dart';
import '/components/my_button.dart';
import 'sign_in.dart';

class Welcome extends StatelessWidget{
  const Welcome({super.key});
  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              //logo

              Image.asset(
                'assets/images/welcome.png',
                height: 400,
              ),

              //welcome message
              const Text(
                "Enhance experience",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 20),
              //app message
              const Text(
                "Discover hidden and unique nearby point of interests",
              ),
              const Text(
                "and personalize your exploration experience...",
              ),

              const SizedBox(height: 50),
              //login button
              MyButton(
                text: "Sign in with Google",
                onTap: () => handleSignIn(context),
                imagePath: 'assets/images/google.png',
              )
            ],
          ),
        )
    );
  }
}