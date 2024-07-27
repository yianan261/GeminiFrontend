import 'package:flutter/material.dart';
import 'interest_card.dart';

class CardList extends StatelessWidget {
  final List<Map<String, String>> interests;

  const CardList({Key? key, required this.interests}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: interests.map((interest) {
        return InterestCard(
          title: interest['title']!,
          imagePath: interest['imagePath']!,
          onTap: () {
            // Handle tile tap
          },
        );
      }).toList(),
    );
  }
}
