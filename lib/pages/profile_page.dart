import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '/services/user_service.dart';
import 'settings.dart';
import 'places_list_page.dart';
import '/components/count_card.dart'; // Import the CountCard component

class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  User? user;
  String userName = '';
  String photoUrl = '';
  String coverPhotoUrl = 'assets/images/defaultcover.jpg';
  List<Map<String, dynamic>> bookmarkedPlaces = [];
  List<Map<String, dynamic>> placesToVisit = [];
  List<Map<String, dynamic>> placesVisited = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await getUser();
      setState(() {
        userName = userData['displayName'] ?? '';
        photoUrl = userData['photoURL'] ?? '';
        coverPhotoUrl = userData['coverPhotoURL'] ?? 'assets/images/defaultcover.jpg';
        bookmarkedPlaces = List<Map<String, dynamic>>.from(userData['bookmarked_places'].values.toList() ?? []);

        // Segregate the places based on 'visited' status
        placesToVisit = bookmarkedPlaces.where((place) => place['visited'] == false).toList();
        placesVisited = bookmarkedPlaces.where((place) => place['visited'] == true).toList();
      });
    }
  }

  Future<void> _uploadCoverPhoto() async {
    try {
      final status = await Permission.photos.request();

      if (status.isGranted) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          File coverPhotoFile = File(pickedFile.path);
          String fileName = 'coverPhotos/${user?.uid}.jpg';
          Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
          UploadTask uploadTask = storageReference.putFile(coverPhotoFile);

          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            // Progress listener (optional)
          }, onError: (e) {
            // Error listener (optional)
          });

          TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
          String downloadUrl = await snapshot.ref.getDownloadURL();

          bool success = await _updateCoverPhotoUrl(downloadUrl);
          if (success) {
            setState(() {
              coverPhotoUrl = downloadUrl;
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('No file selected.'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Photo permission is required to select a cover photo.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to pick image. Please try again.'),
      ));
    }
  }

  Future<bool> _updateCoverPhotoUrl(String url) async {
    try {
      final payload = {
        'email': user?.email,
        'coverPhotoURL': url,
      };

      bool success = await updateUser(payload);

      if (!success) {
        throw 'Failed to update cover photo URL';
      }
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update cover photo. Please try again.'),
      ));
      return false;
    }
  }

  Future<void> _navigateToPlacesToVisit() async {
    await Navigator.pushNamed(context, '/places_to_visit', arguments: placesToVisit);
    fetchUserData(); // Refresh data after returning from the list page
  }

  Future<void> _navigateToPlacesVisited() async {
    await Navigator.pushNamed(context, '/places_visited', arguments: placesVisited);
    fetchUserData(); // Refresh data after returning from the list page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                coverPhotoUrl.startsWith('http')
                    ? Image.network(
                  coverPhotoUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  coverPhotoUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.black),
                    onPressed: _uploadCoverPhoto,
                  ),
                ),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl.isEmpty
                          ? Icon(Icons.person, size: 50)
                          : null,
                    ),
                    SizedBox(height: 10),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        backgroundColor: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CountCard(
                        title: 'Places Visited',
                        count: placesVisited.length,
                        onTap: _navigateToPlacesVisited,
                      ),
                      CountCard(
                        title: 'Places to Visit',
                        count: placesToVisit.length,
                        onTap: _navigateToPlacesToVisit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
