import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '/constants.dart';
import 'dart:convert';

// Function to create a new user
Future<Map<String, dynamic>?> createUser(Map<String, dynamic> data) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body)["data"];
    } else if (response.statusCode == 409) {
      // Handle user already exists case
      //print('User already exists.');
      return null;
    } else {
      print('Failed to create user: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error creating user: $e');
    return null;
  }
}

// Function to get user data
Future<Map<String, dynamic>> getUser() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    //print('User not logged in');
    return {};
  }

  String userEmail = currentUser.email!;
  final String url = '$baseUrl/users/$userEmail';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        "email": userEmail,  // If your API expects email in the body
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return data['data'];
      } else {
        print('Failed to fetch user data: ${data['message']}');
        return {};
      }
    } else {
      print('Failed to fetch user data: ${response.statusCode}');
      return {};
    }
  } catch (e) {
    print('Error fetching user data: $e');
    return {};
  }
}

// Function to update user data
Future<bool> updateUser(Map<String, dynamic> data) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print('User not logged in');
    return false;
  }

  String userId = currentUser.email!; // Using email as UID
  data['email'] = userId;
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/updateUser?user_id=$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update user data: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error updating user data: $e');
    return false;
  }
}

Future<String?> generateUserDescription() async {
  User? currentUser = FirebaseAuth.instance.currentUser;

  String email = currentUser!.email!;

  final url = Uri.parse('$baseUrl/generateUserDescription');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'email': email}),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['data']['geminiDescription'];
  } else {
    throw Exception('Failed to generate user description');
  }
}
