import 'package:flutter/material.dart';
import '/components/icon_button.dart';
import '/services/sign_out.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? navigateTo;

  const CustomAppBar({
    Key? key,
    this.navigateTo, // Make navigateTo optional
  }) : super(key: key);

  void navigateBack(BuildContext context) {
    if (navigateTo != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => navigateTo!),
      );
    } else {
      Navigator.pop(context); // Just pop the current page
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: MyIconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => navigateBack(context),
      ),
      actions: <Widget>[
        MyIconButton(
          icon: Icon(Icons.logout),
          onPressed: () => signOut(context),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
