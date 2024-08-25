import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/constants.dart';

class LocationService {
  Future<Map<String, dynamic>> fetchWeatherData(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$openWeatherMapApiKey&units=imperial'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final weather = data['weather'][0]['main'].toLowerCase();
      final temperature = data['main']['temp'].toString();

      return {'icon': getWeatherIcon(weather), 'temperature': temperature};
    } else {
      print('Failed to fetch weather');
      return {'icon': '🌡️', 'temperature': 'N/A'};
    }
  }

  Future<Map<String, dynamic>?> fetchWeatherDataByCityName(String cityName) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$openWeatherMapApiKey&units=imperial'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final weather = data['weather'][0]['main'].toLowerCase();
      final temperature = data['main']['temp'].toString();

      return {
        'icon': getWeatherIcon(weather),
        'temperature': temperature,
        'description': weather
      };
    } else {
      print('Failed to fetch weather for $cityName');
      return null;
    }
  }

  String getWeatherIcon(String weather) {
    switch (weather.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'rain':
        return '🌧️';
      case 'clouds':
        return '☁️';
      case 'snow':
        return '❄️';
      case 'wind':
        return '🌬️';
      default:
        return '';
    }
  }
}
