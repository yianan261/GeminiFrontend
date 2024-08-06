import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/places_service.dart';
import '/components/icon_button.dart';

class PlaceCard extends StatefulWidget {
  final Map<String, dynamic> place;
  final Position currentPosition;

  const PlaceCard({
    Key? key,
    required this.place,
    required this.currentPosition,
  }) : super(key: key);

  @override
  _PlaceCardState createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  bool isBookmarked = false;

  void _savePlace() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? userEmail = user?.email;

    if (userEmail == null) {
      print('User not logged in');
      return;
    }

    if (widget.place['place_id'] == null ||
        widget.place['vicinity'] == null ||
        widget.place['name'] == null) {
      print('Required place details are missing');
      return;
    }

    await savePlace(
      email: userEmail,
      place_id: widget.place['place_id'],
      address: widget.place['vicinity'] ?? 'No Address',
      name: widget.place['name'] ?? 'No Name',
    );

    setState(() {
      isBookmarked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lat = widget.place['geometry']?['location']?['lat'];
    final lng = widget.place['geometry']?['location']?['lng'];

    if (lat == null || lng == null) {
      return Text('Location data not available');
    }

    final distanceInMeters = Geolocator.distanceBetween(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
      lat,
      lng,
    );

    final distanceInMiles = distanceInMeters * 0.000621371; // Convert to miles

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: widget.place['photo_url'] != null
                    ? Image.network(
                  widget.place['photo_url'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 150,
                  color: Colors.grey,
                  child: Icon(Icons.photo, size: 100, color: Colors.white),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 16,
                  child: MyIconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? Colors.yellow : Colors.white,
                    ),
                    iconSize: 15.0,
                    onPressed: _savePlace,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.place['name'] ?? 'No Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              widget.place['vicinity'] ?? 'No Address',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              '${distanceInMiles.toStringAsFixed(2)} mi',
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}
