import 'package:flutter/material.dart';
import 'pages/welcome.dart';
import 'package:google_gemini/theme/light_mode.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Welcome(),
      theme: lightMode,
    );
  }
}

