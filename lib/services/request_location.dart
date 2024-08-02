import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/pages/onboarding_pages/onboarding_step2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package

Future<void> requestLocation(BuildContext context) async {
  var status = await Permission.location.request();
  if (status.isGranted) {
    // Inform the user that permission was granted
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Location permission granted'),
    ));

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    final Placemark placemark = placemarks[0];
    final city = placemark.locality ?? '';
    final state = placemark.administrativeArea ?? '';

    final weatherData = await fetchWeatherData(position);

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
              'longtitude': position.longitude,
              'city': city,
              'state': state,
              'weather': weatherData['icon'],
              'temperature': weatherData['temperature'],
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

Future<Map<String, dynamic>> fetchWeatherData(Position position) async {
  final response = await http.get(Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$openWeatherMapApiKey&units=imperial'));

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
