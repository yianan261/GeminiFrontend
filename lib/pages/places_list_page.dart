import 'package:flutter/material.dart';
import '../components/place_card.dart';

class PlacesList extends StatelessWidget {
  final List<Map<String, dynamic>> places;

  const PlacesList({
    Key? key,
    required this.places,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Places To Visit'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0), // Add padding to the entire list
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0), // Add padding between list items
            child: PlaceCard(
              place: place,
            ),
          );
        },
      ),
    );
  }
}
