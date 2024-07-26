import 'package:flutter/material.dart';
import '../services/sign_out.dart';

class SignoutButton extends StatelessWidget {

  const SignoutButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return IconButton(
        icon: Icon(Icons.logout),
        onPressed: () => signOut(context),
    );
  }
}