import 'package:flutter/material.dart';
import '/services/places_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
    _getCurrentPositionAndFetchDetails();
  }

  Future<void> _getCurrentPositionAndFetchDetails() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final details = await fetchPlaceDetails(widget.placeId,
          _currentPosition!.latitude, _currentPosition!.longitude);
      setState(() {
        placeDetails = details;
        //print(placeDetails);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to get current position: $e';
        isLoading = false;
      });
    }
  }

  void _toggleBookmark() async {
    if (placeDetails != null) {
      try {
        if (placeDetails!['bookmarked']) {
          await removeBookmarkedPlace(place: placeDetails!);
        } else {
          await savePlace(place: placeDetails!);
        }

        setState(() {
          placeDetails!['bookmarked'] = !placeDetails!['bookmarked'];
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
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.black,
                radius: 16,
                child: IconButton(
                  icon: Icon(
                    placeDetails!['bookmarked']
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: placeDetails!['bookmarked']
                        ? Colors.yellow
                        : Colors.white,
                  ),
                  iconSize: 15.0,
                  onPressed: _toggleBookmark,
                ),
              ),
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
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Image.network(
                                            placeDetails!['photo_url'][index],
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Location',
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(placeDetails!['address'] ??
                                          'No Address'),
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
                                    ), // Horizontal line
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
                                          fontWeight: FontWeight.bold),
                                    ),
                                    ...placeDetails!['reviews']
                                            ?.map<Widget>((review) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  review['author_name'] ??
                                                      'Anonymous',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  review['text'] ?? '',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          );
                                        })?.toList() ??
                                        [],
                                  ],
                                ))
                          ]),
                    ),
    );
  }
}
