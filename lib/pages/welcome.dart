import 'package:flutter/material.dart';
import 'package:google_gemini/components/my_button.dart';

class Welcome extends StatelessWidget{
  const Welcome({super.key});

  void login(){

  }
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
            Text(
              "Enhance experience",
              style: TextStyle(
                  fontSize: 20,
              ),
            ),

            const SizedBox(height: 20),
            //app message
            Text(
              "Discover hidden and unique nearby point of interests",
            ),
            Text(
              "and personalize your exploration experience...",
            ),

            const SizedBox(height: 50),
            //login button
            MyButton(
              text: "Sign in with Google",
              onTap: login,
            )
          ],
        ),
      )
    );
  }
}