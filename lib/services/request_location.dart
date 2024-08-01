import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/pages/onboarding_pages/onboarding_step2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/constants.dart';
import 'package:geolocator/geolocator.dart';

Future<void> requestLocation(BuildContext context) async {
  var status = await Permission.location.request();
  if (status.isGranted) {
    // Inform the user that permission was granted
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Location permission granted'),
    ));

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // Update onboarding step in Firestore
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/updateUser?user_id=${user.uid}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'accessLocationAllowed': true,
            'location': {
              'latitude': position.latitude,
              'longitude': position.longitude,
            },
          }),
        );

        // Check the response status
        if (response.statusCode == 200) {
          // Navigate to onboarding step 3
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AllowNotificationsPage()),
          );
        } else {
          // Handle the error
          print('Failed to update user: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        // Print exceptions
        print('Error updating user: $e');
      }
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Location permission denied. Please allow it from settings.'),
      action: SnackBarAction(
        label: 'Settings',
        onPressed: () {
          openAppSettings();
        },
      ),
    ));
  }
}

Future<Map<String, String>> fetchCityState(double latitude, double longitude) async {
  final response = await http.get(Uri.parse(
      'https://api.opencagedata.com/geocode/v1/json?q=$latitude+$longitude&key=$openCageApiKey'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final components = data['results'][0]['components'];
    final city = components['city'] ?? components['town'] ?? components['village'] ?? '';
    final state = components['state'] ?? '';
    return {'city': city, 'state': state};
  } else {
    print('Failed to fetch city and state');
    return {'city': '', 'state': ''};
  }
}

Future<Map<String, dynamic>> fetchWeatherData(double latitude, double longitude) async {
  final response = await http.get(Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$openWeatherMapApiKey&units=imperial'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final weather = data['weather'][0]['main'].toLowerCase();
    final temperature = data['main']['temp'].toString();

    String icon;
    switch (weather) {
      case 'clear':
        icon = '☀️';
        break;
      case 'rain':
        icon = '🌧️';
        break;
      case 'clouds':
        icon = '☁️';
        break;
      case 'snow':
        icon = '❄️';
        break;
      case 'wind':
        icon = '🌬️';
        break;
      default:
        icon = '🌡️';
    }

    return {'icon': icon, 'temperature': temperature};
  } else {
    print('Failed to fetch weather');
    return {'icon': '🌡️', 'temperature': 'N/A'};
  }
}