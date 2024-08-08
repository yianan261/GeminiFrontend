import 'package:flutter/material.dart';
import '/services/places_service.dart';
import 'package:geolocator/geolocator.dart';

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
      _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final details = await fetchPlaceDetails(widget.placeId, _currentPosition!.latitude, _currentPosition!.longitude);
      print("details: $details");
      setState(() {
        placeDetails = details['data'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to get current position: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Place Details"),
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
            if (placeDetails!['photo_url'] != null && placeDetails!['photo_url'].isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: placeDetails!['photo_url'].length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.network(placeDetails!['photo_url'][index]),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                placeDetails!['title'] ?? 'No Name',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                placeDetails!['address'] ?? 'No Address',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                placeDetails!['editorial_summary'] ?? '',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Handle get directions
                },
                child: Text('Get Directions'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Interesting Facts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                placeDetails!['interesting_facts'] ?? 'No interesting facts available',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Current Opening Hours',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ...placeDetails!['currentOpeningHours']?.map<Widget>((hour) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  hour,
                  style: TextStyle(fontSize: 16),
                ),
              );
            })?.toList() ?? [Text('No opening hours available')],
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Reviews',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ...placeDetails!['reviews']?.map<Widget>((review) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['author_name'] ?? 'Anonymous',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      review['text'] ?? '',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            })?.toList() ?? [],
          ],
        ),
      ),
    );
  }
}