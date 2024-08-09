import 'package:flutter/material.dart';

class AppNavigatorObserver extends NavigatorObserver {
  final VoidCallback onReturn;

  AppNavigatorObserver({required this.onReturn});

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    if (previousRoute != null && previousRoute.settings.name == "/profile") {
      onReturn(); // Trigger the data fetch when returning to ProfilePage
    }
  }
}
