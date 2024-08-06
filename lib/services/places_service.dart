import 'package:http/http.dart' as http;
import 'dart:convert';
import '/constants.dart'; // Ensure this path is correct

Future<List<Map<String, dynamic>>> fetchNearbyAttractions(String location, int radius) async {
  // Define the headers
  var headers = {
    'Content-Type': 'application/json',
  };

  // Create the request URL
  var uri = Uri.parse('$baseUrl/nearby-attractions');

  // Create the request body
  var requestBody = json.encode({
    "location": location,
    "radius": radius,
  });

  // Create the HTTP request
  var request = http.Request('GET', uri)
    ..body = requestBody
    ..headers.addAll(headers);

  // Send the request and get the streamed response
  http.StreamedResponse response = await request.send();

  // Process the response
  if (response.statusCode == 200) {
    var responseBody = await response.stream.bytesToString();
    var data = jsonDecode(responseBody);

    // Print out the response data
    //print('Response data: $data');

    // Extract the list of places from the nested structure
    if (data['data'] is Map && data['data']['results'] is List) {
      List<Map<String, dynamic>> places = List<Map<String, dynamic>>.from(data['data']['results']);
      // Add photo URL for each place
      for (var place in places) {
        if (place['photos'] != null && place['photos'].isNotEmpty) {
          var photoReference = place['photos'][0]['photo_reference'];
          place['photo_url'] = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$googleMapAPI';
        }
      }
      return places;
    } else {
      throw Exception('Unexpected response format');
    }
  } else {
    print('Request failed with status: ${response.statusCode}');
    print('Reason: ${response.reasonPhrase}');
    throw Exception('Failed to load nearby attractions');
  }
}

Future<void> savePlace({
  required String email,
  required String place_id,
  required String address,
  required String name,
}) async {
  final url = Uri.parse('$baseUrl/save-places-to-visit');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'place_id': place_id,
      'address': address,
      'name': name,
    }),
  );

  if (response.statusCode == 200) {
    print('Place saved successfully');
  } else {
    throw Exception('Failed to save place');
  }
}
