import 'package:flutter/material.dart';

class BackButtonComponent extends StatelessWidget {
  final Color color;
  final Widget? navigateTo; // Widget to navigate to

  const BackButtonComponent({
    Key? key,
    this.color = Colors.black,
    this.navigateTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: color),
      onPressed: () {
        if (navigateTo != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => navigateTo!),
          );
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}
