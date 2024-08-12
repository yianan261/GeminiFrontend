import 'package:flutter/material.dart';
import 'pages/profile_page.dart';
import 'pages/auth_page.dart';
import 'pages/settings.dart';
import 'pages/places_list_page.dart';  // Import your PlacesList page
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'components/app_navigator_observer.dart'; // Import your observer

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[50],
        ),
      ),
      home: const AuthPage(),
      navigatorObservers: [
        AppNavigatorObserver(
          onReturn: () {
            final profilePageState = context.findAncestorStateOfType<ProfilePageState>();
            profilePageState?.fetchUserData();  // Refresh data when returning to profile
          },
        ),
      ],
    );
  }
}
