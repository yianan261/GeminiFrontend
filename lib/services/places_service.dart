import 'package:http/http.dart' as http;
import 'dart:convert';
import '/constants.dart'; // Make sure to update this path as necessary

Future<List<Map<String, dynamic>>> fetchPlacesOfInterest(String email, String location) async {
  final uri = Uri.parse('$baseUrl/getPointOfInterest').replace(queryParameters: {
    'email': email,
    'location': location,
  });

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['data']);
  } else {
    throw Exception('Failed to load places of interest');
  }
}
