import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '/constants.dart'; // Import the config file
import 'dart:convert';



Future<Map<String, dynamic>> getUser() async{
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print('User not logged in');
    return Map();
  }

  String userId = currentUser.uid;
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }
    );
    print(response);

    if (response.statusCode == 200) {

      return json.decode(response.body)["data"];
    } else {
      print('Failed to update onboarding step: ${response.statusCode}');
      return Map();
    }
  } catch (e) {
    print('Error updating onboarding step: $e');
    return Map();
  }

}





Future<bool> updateUser(Map<String, dynamic> data) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print('User not logged in');
    return false;
  }

  String userId = currentUser.uid;

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
      print('Failed to update onboarding step: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error updating onboarding step: $e');
    return false;
  }
}
