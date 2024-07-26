import 'package:flutter/material.dart';

class MyBackButton extends StatelessWidget {
  final Widget? navigateTo;

  const MyBackButton({
    Key? key,
    this.navigateTo,
}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        if (navigateTo != null){
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => navigateTo!),
          );
        } else {
          Navigator.pop(context);
        }
      }
    );
  }
}