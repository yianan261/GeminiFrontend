import 'package:flutter/material.dart';

class InterestCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const InterestCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        trailing: Image.asset(
          imagePath,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        onTap: onTap,
      ),
    );
  }
}
