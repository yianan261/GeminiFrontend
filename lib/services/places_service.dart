import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '/constants.dart';

Future<String?> getUserEmail() async {
  final User? user = FirebaseAuth.instance.currentUser;
  return user?.email;
}

Future<List<Map<String, dynamic>>> fetchNearbyAttractions(double latitude, double longitude, int radius, String weather) async {
  final String? email = await getUserEmail();
  if (email == null) {
    throw Exception('No user logged in');
  }

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
  var request = http.Request('POST', uri)
    ..body = requestBody
    ..headers.addAll(headers);

  // Send the request and get the streamed response
  http.StreamedResponse response = await request.send();
  // Fetch bookmarked places
  List<String> bookmarkedPlaceIds = [];
  bookmarkedPlaceIds = await fetchBookmarkedPlaces(email);
  // Process the response
  if (response.statusCode == 200) {
    var responseBody = await response.stream.bytesToString();
    var data = jsonDecode(responseBody);
    List<Map<String, dynamic>> places = List<Map<String, dynamic>>.from(data['data']);
    // Print out the response data
    //print('Response data: $data');
    for (var place in places){
      place['bookmarked'] = bookmarkedPlaceIds.contains(place['place_id']);
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
  final response = await http.post(
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
  final String? email = await getUserEmail();
  if (email == null) {
    throw Exception('No user logged in');
  }

  final url = Uri.parse('$baseUrl/save-places-to-visit');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'email': email,
      'place_id': place['place_id'],
      'title': place['title'],
      'photo_url': place['photo_url'],
      'distance': place['distance'],
      'bookmarked': true,
      'visited': false
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

Future<List<Map<String, dynamic>>> searchPointOfInterest(String query, double latitude, double longitude, int radius, String weather) async {
  final String? email = await getUserEmail();
  if (email == null) {
    throw Exception('No user logged in');
  }

  final url = Uri.parse('$baseUrl/search-points-of-interest');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'email': email,
      'query': query,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'weather': weather
    }),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load search results');
  }
}

Future<Map<String, dynamic>> fetchPlaceDetails(
    String placeID, double currentLatitude, double currentLongitude) async {

  final String? email = await getUserEmail();
  if (email == null) {
    throw Exception('No user logged in');
  }

  var headers = {
    'Content-Type': 'application/json',
  };

  // Create the request URL
  var uri = Uri.parse('$baseUrl/place-details');
  // Create the request body
  var requestBody = json.encode({
    "email": email,
    "placeId": placeID,
    "latitude": currentLatitude,
    "longitude": currentLongitude,
  });

  var request = http.Request('POST', uri)
    ..body = requestBody
    ..headers.addAll(headers);

  // Send the request and get the streamed response
  http.StreamedResponse response = await request.send();

  // Fetch bookmarked places with full details
  Map<String, dynamic> bookmarkedPlaces = await fetchDetailedBookmarkedPlaces(email);

  if (response.statusCode == 200) {
    var responseBody = await response.stream.bytesToString();
    var place = jsonDecode(responseBody)['data'];

    // Set the bookmarked and visited status based on bookmarked places
    if (bookmarkedPlaces.containsKey(placeID)) {
      place['bookmarked'] = true;
      place['visited'] = bookmarkedPlaces[placeID]['visited'];
    } else {
      place['bookmarked'] = false;
      place['visited'] = false;
    }

    return place;
  } else {
    throw Exception('Failed to fetch place details');
  }
}

Future<Map<String, dynamic>> fetchDetailedBookmarkedPlaces(String email) async {
  final url = Uri.parse('$baseUrl/get-bookmarked-places?email=$email');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data['success'] == true) {
      Map<String, dynamic> bookmarkedPlaces = {};
      for (var place in data['data']) {
        bookmarkedPlaces[place['place_id']] = place;
      }
      return bookmarkedPlaces;
    } else {
      throw Exception('Failed to fetch bookmarked places: ${data['message']}');
    }
  } else {
    throw Exception('Failed to fetch bookmarked places');
  }
}
