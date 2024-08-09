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
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  String userName = '';
  String photoUrl = '';
  String coverPhotoUrl = 'assets/images/defaultcover.jpg';
  List<Map<String, dynamic>> bookmarkedPlaces = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await getUser();
      setState(() {
        userName = userData['displayName'] ?? '';
        photoUrl = userData['photoURL'] ?? '';
        coverPhotoUrl = userData['coverPhotoURL'] ?? 'assets/images/defaultcover.jpg';
        bookmarkedPlaces = List<Map<String, dynamic>>.from(userData['bookmarked_places'].values.toList() ?? []);
        print(bookmarkedPlaces);
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
            //print('Task state: ${snapshot.state}');
            //print('Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
          }, onError: (e) {
            //print('Error: $e');
          });

          TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
          String downloadUrl = await snapshot.ref.getDownloadURL();
          //print('Download URL: $downloadUrl');

          bool success = await _updateCoverPhotoUrl(downloadUrl);
          if (success) {
            setState(() {
              coverPhotoUrl = downloadUrl;
            });
          }
        } else {
          //print('No file selected');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Photo permission is required to select a cover photo.'),
        ));
      }
    } catch (e) {
      //print('Error picking image: $e');
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

      print('Payload being sent: $payload');

      bool success = await updateUser(payload);

      if (!success) {
        throw 'Failed to update cover photo URL';
      }
      return true;
    } catch (e) {
      print('Error updating user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update cover photo. Please try again.'),
      ));
      return false;
    }
  }

  void _navigateToBookmarkedPlaces() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacesList(
          places: bookmarkedPlaces,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()), // Ensure SettingsPage is created
              );
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
                      backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty ? Icon(Icons.person, size: 50) : null,
                    ),
                    SizedBox(height: 10),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        backgroundColor: Colors.black45, // Slight background for text readability
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
                        count: 10, // Replace 10 with your dynamic count
                      ),
                      CountCard(
                        title: 'Places to Visit',
                        count: bookmarkedPlaces.length,
                        onTap: _navigateToBookmarkedPlaces,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Add more user information here if needed
          ],
        ),
      ),
    );
  }
}
