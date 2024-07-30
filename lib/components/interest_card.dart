import 'package:flutter/material.dart';
import '/models/interests_model.dart';

class InterestCard extends StatelessWidget {
  final Interests interest;
  final bool isSelected;
  final VoidCallback onTap;

  const InterestCard({
    Key? key,
    required this.interest,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(
            color: isSelected ? Colors.black : Colors.white,
            width: 1.0,
          ),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              //SizedBox(width: 16),
              Expanded(
                child: Text(
                  interest.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (interest.imagePath != null)
                Image.asset(interest.imagePath!,
                    width: 38, height: 38, fit: BoxFit.cover),
            ],
          ),
        ),
      ),
    );
  }
}
