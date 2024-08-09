import 'package:flutter/material.dart';

class CountCard extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback? onTap;

  const CountCard({
    Key? key,
    required this.title,
    required this.count,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
