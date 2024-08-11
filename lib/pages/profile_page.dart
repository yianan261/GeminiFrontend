import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wander_finds_gemini/pages/settings.dart';
import '/services/user_service.dart';
import '/components/count_card.dart';
import 'onboarding_pages/onboarding_step4.dart';
import 'places_list_page.dart';// Import the InterestCard component

class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  User? user;
  String userName = '';
  String photoUrl = '';
  String coverPhotoUrl = 'assets/images/defaultcover.png';
  List<Map<String, dynamic>> bookmarkedPlaces = [];
  List<Map<String, dynamic>> placesToVisit = [];
  List<Map<String, dynamic>> placesVisited = [];
  List<String> userInterests = [];

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
        coverPhotoUrl =
            userData['coverPhotoURL'] ?? 'assets/images/defaultcover.png';
        bookmarkedPlaces = List<Map<String, dynamic>>.from(
            userData['bookmarked_places'].values.toList() ?? []);
        userInterests = List<String>.from(userData['interests'] ?? []);

        // Segregate the places based on 'visited' status
        placesToVisit = bookmarkedPlaces
            .where((place) => place['visited'] == false)
            .toList();
        placesVisited = bookmarkedPlaces
            .where((place) => place['visited'] == true)
            .toList();
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
          Reference storageReference =
              FirebaseStorage.instance.ref().child(fileName);
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
          content:
              Text('Photo permission is required to select a cover photo.'),
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacesList(
          places: placesToVisit,
          title: 'Places to Visit',
        ),
      ),
    );
    fetchUserData(); // Refresh data after returning from the list page
  }

  Future<void> _navigateToPlacesVisited() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacesList(
          places: placesVisited,
          title: 'Places to Visit',
        ),
      ),
    );
    fetchUserData();// Refresh data after returning from the list page
  }

  Future<void> _navigateToEditInterests() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OnboardingStep4()), // or your specific interest editing page
    );
    fetchUserData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 13,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  coverPhotoUrl.startsWith('http')
                      ? Image.network(
                          coverPhotoUrl,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          coverPhotoUrl,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height,
                          fit: BoxFit.cover,
                        ),
                  Positioned(
                    top: 50,
                    right: 10,
                    child: IconButton(
                      icon: Icon(Icons.settings, color: Colors.black),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SettingsPage())
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 10,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.black),
                      onPressed: _uploadCoverPhoto,
                    ),
                  ),
                  SizedBox(height: 20),
                  Positioned(
                    top: 170,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Interests',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: _navigateToEditInterests,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 80, // Shorter height
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: userInterests.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 140,
                          // Longer width
                          margin: EdgeInsets.only(right: 8.0),
                          // Space between cards
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: BorderSide(
                                  color: Colors.black, width: 1), // Add border
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              // Smaller padding
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      userInterests[index],
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 50),
                  Text(
                    'My Lists',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CountCard(
                        icon: Icon(Icons.flag),
                        title: 'Places Visited',
                        count: placesVisited.length,
                        onTap: _navigateToPlacesVisited,
                      ),
                      CountCard(
                        icon: Icon(Icons.bookmark),
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
