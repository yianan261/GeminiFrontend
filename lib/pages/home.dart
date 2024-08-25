
import 'package:flutter/material.dart';
import 'explore_page.dart';
import 'map_page.dart';
import 'profile_page.dart';
import 'package:workmanager/workmanager.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Keeping ExplorePage and MapPage persistent while recreating ProfilePage to ensure it refreshes
  final ExplorePage _explorePage = ExplorePage();
  final MapPage _mapPage = MapPage();

  @override
  void initState() {
    super.initState();
    /*
    Workmanager().registerPeriodicTask(
      "2", // Unique identifier for the task
      "locationTracking",
      frequency: Duration(minutes: 15), // Task name
    );*/

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _explorePage,
          _mapPage,
          if (_currentIndex == 2) ProfilePage() else Container(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
