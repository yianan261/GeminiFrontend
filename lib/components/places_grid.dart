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
    return Stack(
      children: [
        // The GridView
        GridView.builder(
          padding: EdgeInsets.only(top: 30), // Add padding to push the grid down if needed
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 3 / 4,
          ),
          itemCount: recommendedPlaces.length,
          itemBuilder: (context, index) {
            final place = recommendedPlaces[index];
            return PlaceCard(
              place: place,
            );
          },
        ),
        // "Generated with Gemini" text aligned at the top right
        Positioned(
          top: 5,
          right: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 16),
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
      ],
    );
  }
}
