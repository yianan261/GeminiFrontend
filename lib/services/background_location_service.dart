import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/constants.dart';

class BackgroundLocationService {
  void configure() {
    /*
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      _sendLocationToBackend(location.coords.latitude, location.coords.longitude);
    });*/

    bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 50.0,
      stopOnTerminate: false,
      startOnBoot: true,
      enableHeadless: true,
    ));
  }

  void start() {
    bg.BackgroundGeolocation.start();
  }

  void stop() {
    bg.BackgroundGeolocation.stop();
  }

  /*
  * Future<void> _sendLocationToBackend(double latitude, double longitude) async {
    final weatherData = await fetchWeatherData(latitude, longitude);

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/updateLocation'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'user_id': user.uid,
            'location': {
              'latitude': latitude,
              'longitude': longitude,
              'weather': weatherData['icon'],
              'temperature': weatherData['temperature'],
            },
          }),
        );

        if (response.statusCode != 200) {
          print('Failed to update location: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Error updating location: $e');
      }
    }
  }*/

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
}
