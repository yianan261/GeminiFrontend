import 'package:flutter/material.dart';

class CountCard extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback? onTap;
  final Icon icon;

  const CountCard({
    Key? key,
    required this.title,
    required this.count,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 16.0, 30.0, 16.0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.black,
                radius: 18,
                child: Icon(
                  icon.icon,
                  color: Colors.yellow,
                  size: 18
                ),
              ),
              SizedBox(height:10),
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
