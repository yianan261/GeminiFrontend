import 'package:flutter/material.dart';
import 'explore_page.dart';
import 'map_page.dart';
import 'profile_page.dart';

import 'package:workmanager/workmanager.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Workmanager().registerPeriodicTask(
      "1", // Unique identifier for the task
      "locationTracking", // Task name
      // frequency: Duration(seconds: 20), // Set the frequency to 1 hour
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: GlobalKey<NavigatorState>(),
        onGenerateRoute: (RouteSettings settings) {
          Widget page;
          switch (_currentIndex) {
            case 0:
              page = ExplorePage(); // Always return a new instance of ExplorePage
              break;
            case 1:
              page = MapPage();
              break;
            case 2:
              page = ProfilePage();
              break;
            default:
              page = ExplorePage();
          }
          return MaterialPageRoute(builder: (_) => page);
        },
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
