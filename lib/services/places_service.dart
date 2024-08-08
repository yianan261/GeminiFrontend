import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '/constants.dart';

Future<List<Map<String, dynamic>>> fetchNearbyAttractions(String email, double latitude, double longitude, int radius, String weather) async {
  // Define the headers
  var headers = {
    'Content-Type': 'application/json',
  };

  // Create the request URL
  var uri = Uri.parse('$baseUrl/get-points-of-interest');

  // Create the request body
  var requestBody = json.encode({
    "email": email,
    "latitude": latitude,
    "longitude": longitude,
    "radius": radius,
    "weather": weather,
  });

  // Create the HTTP request
  var request = http.Request('GET', uri)
    ..body = requestBody
    ..headers.addAll(headers);

  // Send the request and get the streamed response
  http.StreamedResponse response = await request.send();
  final User? user = FirebaseAuth.instance.currentUser;
  final String? userEmail = user?.email;

  // Fetch bookmarked places
  List<String> bookmarkedPlaceIds = [];
  if (userEmail != null) {
    bookmarkedPlaceIds = await fetchBookmarkedPlaces(userEmail);
  }
  // Process the response
  if (response.statusCode == 200) {
    var responseBody = await response.stream.bytesToString();
    var data = jsonDecode(responseBody);
    List<Map<String, dynamic>> places = List<Map<String, dynamic>>.from(data['data']);
    // Print out the response data
    //print('Response data: $data');
    for (var place in places){
      place['bookmarked'] = bookmarkedPlaceIds.contains(place['place_id']);
      place['email'] = userEmail;
    }
    print("places: $places");
    return places;
  } else {
    print('Request failed with status: ${response.statusCode}');
    print('Reason: ${response.reasonPhrase}');
    throw Exception('Failed to load nearby attractions');
  }
}


Future<List<String>> fetchBookmarkedPlaces(String email) async {
  final url = Uri.parse('$baseUrl/get-bookmarked-places?email=$email');
  final response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data['success'] == true) {
      List<String> placeIds = List<String>.from(data['data'].map((place) => place['place_id']));
      return placeIds;
    } else {
      throw Exception('Failed to fetch bookmarked places: ${data['message']}');
    }
  } else {
    throw Exception('Failed to fetch bookmarked places');
  }
}


Future<void> savePlace({
  required Map<String, dynamic> place,
}) async {
  final url = Uri.parse('$baseUrl/save-places-to-visit');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'email': place['email'],
      'place_id': place['place_id'],
      'address': place['address'],
      'name': place['title'],
    }),
  );

  if (response.statusCode == 200) {
    place['bookmarked'] = true;
    print('Place bookmarked successfully');
  } else {
    throw Exception('Failed to save place');
  }
}

Future<void> removeBookmarkedPlace({required Map<String, dynamic> place}) async {
  final url = Uri.parse('$baseUrl/remove-bookmarked-place');
  final response = await http.delete(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(place),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to remove bookmarked place');
  }
}

Future<Map<String, dynamic>> fetchPlaceDetails(String placeID, double currentLatitude, double currentLongitude) async {
  var headers = {
    'Content-Type': 'application/json',
  };

  // Create the request URL
  var uri = Uri.parse('$baseUrl/place-details');
  final User? user = FirebaseAuth.instance.currentUser;
  final String? userEmail = user?.email;
  // Create the request body
  var requestBody = json.encode({
    "email": userEmail,
    "placeId": placeID,
    "latitude": currentLatitude,
    "longitude": currentLongitude,
  });

  var request = http.Request('GET', uri)
    ..body = requestBody
    ..headers.addAll(headers);

  // Send the request and get the streamed response
  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    var responseBody = await response.stream.bytesToString();
    var place = jsonDecode(responseBody);
    return place;
  } else {
    throw Exception('Failed to fetch place details');
  }
}
