import 'package:flutter/material.dart';

class DescriptionBox extends StatelessWidget {
  final String description;

  const DescriptionBox({
    Key? key,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Adding a background color for better visibility
        ),
        child: Text(
          description,
          style: TextStyle(
            fontSize: 16,
            //fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
