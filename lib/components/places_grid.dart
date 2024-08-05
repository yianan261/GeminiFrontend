import 'package:flutter/material.dart';

class PlacesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> savedPlaces;

  const PlacesGrid({Key? key, required this.savedPlaces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2 / 3,
      ),
      itemCount: savedPlaces.length,
      itemBuilder: (context, index) {
        final place = savedPlaces[index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              place['photo_url'] != null
                  ? Image.network(
                place['photo_url'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 150,
                color: Colors.grey,
                child: Icon(Icons.photo, size: 100, color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  place['name'] ?? 'No Name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  place['vicinity'] ?? 'No Address',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
