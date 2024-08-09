import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final Icon icon;
  final VoidCallback onPressed;
  final double iconSize;

  const MyIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.iconSize = 24.0,
    // Default size is 24.0
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon.icon,
        color: icon.color,
        size: iconSize,
      ),
      onPressed: onPressed,
    );
  }
}
