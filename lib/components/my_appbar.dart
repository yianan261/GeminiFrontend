import 'package:flutter/material.dart';
import '/components/back_button.dart'; // Adjust the import according to your project's structure
import '/components/signout_button.dart'; // Adjust the import according to your project's structure

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget navigateTo;

  const CustomAppBar({
    Key? key,
    required this.navigateTo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: MyBackButton(navigateTo: navigateTo),
      actions: <Widget>[
        SignoutButton(),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
