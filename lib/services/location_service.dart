import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/constants.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, do something
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, do something
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, do something
      return Future.error('Location permissions are permanently denied');
    }

    // Get the current location
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
}
