import 'package:flutter/material.dart';
import '/components/icon_button.dart';
import '/services/sign_out.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget navigateTo;

  const CustomAppBar({
    Key? key,
    required this.navigateTo,
  }) : super(key: key);

  void navigateBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => navigateTo),
    );
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
