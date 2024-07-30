import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '/constants.dart';

Future<void> fetchUserInfo(BuildContext context, Function(Map<String, dynamic>?) callback) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print('User not logged in');
    callback(null);
    return;
  }

  String userId = currentUser.uid;

  try {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body) as Map<String, dynamic>?;
      print('Response data: $responseData'); // Print the response data
      callback(responseData);
    } else {
      print('Error fetching user info: ${response.statusCode}');
      callback(null);
    }
  } catch (e) {
    print('Error fetching user info: $e');
    callback(null);
  }
}