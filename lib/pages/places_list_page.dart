import 'package:flutter/material.dart';
import '../components/place_card.dart'; // Import your PlaceCard widget

class PlacesList extends StatelessWidget {
  final List<Map<String, dynamic>> places;
  final String title;

  const PlacesList({
    Key? key,
    required this.places,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title), // Display the title
      ),
      body: places.isEmpty
          ? Center(
        child: Text(
          'No places found',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: PlaceCard(
              place: place,
            ),
          );
        },
      ),
    );
  }
}
