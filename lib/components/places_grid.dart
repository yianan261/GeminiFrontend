import 'package:flutter/material.dart';
import '/components/place_card.dart';

class PlacesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> recommendedPlaces;
  final Function(int, bool) onBookmarkToggle;

  const PlacesGrid({
    Key? key,
    required this.recommendedPlaces,
    required this.onBookmarkToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GridView.builder(
          padding: EdgeInsets.only(top: 30),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount:
              recommendedPlaces.isNotEmpty ? recommendedPlaces.length : 1,
          itemBuilder: (context, index) {
            if (recommendedPlaces.isEmpty) {
              return Center(
                child: Text('No recommended places available.'),
              );
            }
            return PlaceCard(
              place: recommendedPlaces[index],
              onBookmarkToggle: (isBookmarked) =>
                  onBookmarkToggle(index, isBookmarked),
            );
          },
        ),
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
