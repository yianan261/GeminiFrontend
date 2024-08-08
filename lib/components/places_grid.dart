import 'package:flutter/material.dart';
import 'place_card.dart';

class PlacesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> recommendedPlaces;

  const PlacesGrid({
    Key? key,
    required this.recommendedPlaces,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: 2 / 3,
      ),
      itemCount: recommendedPlaces.length,
      itemBuilder: (context, index) {
        final place = recommendedPlaces[index];
        //print('passing place to placecard: $place');
        return PlaceCard(
          place: place,
        );
      },
    );
  }
}
