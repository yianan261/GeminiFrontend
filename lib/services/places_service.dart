import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> fetchSavedPlaces() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print('User not logged in');
    return [];
  }

  String userId = currentUser.uid;
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('saved_places')
        .where('user_id', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (e) {
    print('Error fetching saved places: $e');
    return [];
  }
}
