import 'package:flutter/material.dart';
import '/services/places_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '/services/user_service.dart';

class PlaceDetailPage extends StatefulWidget {
  final String placeId;

  const PlaceDetailPage({
    Key? key,
    required this.placeId,
  }) : super(key: key);

  @override
  _PlaceDetailPageState createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  Map<String, dynamic>? placeDetails;
  Position? _currentPosition;
  bool isLoading = true;
  String? errorMessage;
  bool isVisited = false; // Track if the place is visited
  bool isBookmarked = false; // Track if the place is bookmarked

  @override
  void initState() {
    super.initState();
    _getCurrentPositionAndFetchDetails();
  }

  Future<void> _getCurrentPositionAndFetchDetails() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final details = await fetchPlaceDetails(
          widget.placeId, _currentPosition!.latitude, _currentPosition!.longitude);
      print(details);
      setState(() {
        placeDetails = details;
        isLoading = false;
        isVisited = placeDetails?['visited'] ?? false;
        isBookmarked = placeDetails?['bookmarked'] ?? false; // Set initial bookmarked state
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to get current position: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _toggleVisited() async {
    if (placeDetails != null) {
      try {
        final String placeId = widget.placeId;

        // Fetch the current bookmarked_places data
        final userData = await getUser(); // Fetch current user data
        Map<String, dynamic> bookmarkedPlaces = userData['bookmarked_places'];

        // Toggle the visited field for the specific placeId
        bookmarkedPlaces[placeId]['visited'] = !isVisited;

        // Prepare the payload to update the bookmarked_places in the backend
        final Map<String, dynamic> updateData = {
          'bookmarked_places': bookmarkedPlaces,
        };

        // Call the updateUser function to save the changes
        bool success = await updateUser(updateData);

        if (success) {
          setState(() {
            isVisited = !isVisited;
            placeDetails!['visited'] = isVisited; // Toggle the UI state for visited
          });
        } else {
          print('Failed to update user with visited place.');
        }
      } catch (e) {
        print('Failed to toggle visited: $e');
      }
    }
  }

  void _toggleBookmark() async {
    if (placeDetails != null) {
      try {
        if (isBookmarked) {
          await removeBookmarkedPlace(place: placeDetails!);
        } else {
          await savePlace(place: placeDetails!);
        }

        setState(() {
          isBookmarked = !isBookmarked; // Toggle the bookmarked state
          placeDetails!['bookmarked'] = isBookmarked; // Update the place details
        });
      } catch (e) {
        print('Failed to toggle bookmark: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (placeDetails != null)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 16,
                    child: IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? Colors.yellow : Colors.white,
                      ),
                      iconSize: 15.0,
                      onPressed: _toggleBookmark,
                    ),
                  ),
                ),
                if (isBookmarked) // Show flag/checkmark only if bookmarked
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 16,
                      child: IconButton(
                        icon: Icon(
                          isVisited ? Icons.flag : Icons.emoji_flags_outlined,
                          color: isVisited ? Colors.yellow : Colors.white,
                        ),
                        iconSize: 15.0,
                        onPressed: _toggleVisited,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : placeDetails == null
          ? Center(child: Text('No data found'))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (placeDetails!['photo_url'] != null &&
                placeDetails!['photo_url'].isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: placeDetails!['photo_url'].length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Image.network(
                            placeDetails!['photo_url'][index],
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 8.0),
                            color: Colors.black54,
                            child: Text(
                              '${index + 1}/${placeDetails!['photo_url'].length}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                placeDetails!['title'] ?? 'No Name',
                style: TextStyle(
                    fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  Text(
                    placeDetails!['editorial_summary'] ?? '',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10.0),
                  Divider(color: Colors.grey[300]),
                ])),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(placeDetails!['address'] ?? 'No Address'),
                      TextButton.icon(
                        onPressed: () async {
                          final String googleMapsUrl =
                              "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(placeDetails!['address'] ?? '')}";
                          if (await canLaunch(googleMapsUrl)) {
                            await launch(googleMapsUrl);
                          } else {
                            throw 'Could not open the map.';
                          }
                        },
                        icon: Icon(Icons.directions,
                            color: Colors.blue),
                        label: Text(
                          'Get Directions',
                          style: TextStyle(color: Colors.blue),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50, 30),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Divider(color: Colors.grey[300]),
                    ])),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interesting Facts',
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),
                    // Add space between title and Gemini text
                    Align(
                      alignment: Alignment.centerLeft, // Align to the left
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                LinearGradient(
                                  colors: [Colors.blue, Colors.purple],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                            child: Icon(Icons.auto_awesome,
                                color: Colors.white, size: 16),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Generated with Gemini',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      placeDetails!['interesting_facts'] ??
                          'No interesting facts available',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10.0),
                    Divider(color: Colors.grey[300]),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (placeDetails!['rating'] != null) ...[
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          placeDetails!['rating'].toString(),
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 5),
                        _buildRatingStars(
                            (placeDetails!['rating'] as num).toDouble()),
                        SizedBox(width: 5),
                      ],
                    ),
                  ],
                  ...placeDetails!['reviews']
                      ?.map<Widget>((review) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            review['author_name'] ?? 'Anonymous',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            review['text'] ?? '',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }).toList() ??
                      [],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor(); // Full stars
    bool hasHalfStar = rating - fullStars > 0; // Check for half star

    return Row(
      children: [
        ...List.generate(fullStars, (index) =>
            Icon(Icons.star, color: Colors.orange, size: 20)),
        if (hasHalfStar) Icon(Icons.star_half, color: Colors.orange, size: 20),
        ...List.generate(5 - fullStars - (hasHalfStar ? 1 : 0),
                (index) => Icon(Icons.star_border, color: Colors.orange, size: 20)),
      ],
    );
  }
}
