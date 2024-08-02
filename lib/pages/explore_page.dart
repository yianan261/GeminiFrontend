import 'package:flutter/material.dart';
import '/services/user_service.dart';
import '/services/places_service.dart';
import '/components/search_bar.dart';
import '/components/places_grid.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String cityState = '';
  String weatherIcon = '';
  String temperature = '';
  String greeting = '';
  List<String> userInterests = [];
  List<Map<String, dynamic>> savedPlaces = []; // List to hold saved places
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userData = await getUser();
      userInterests = List<String>.from(userData['interests'] ?? []);
      final city = userData['location']['city'];
      final state = userData['location']['state'];
      cityState = '$city, $state';
      weatherIcon = userData['location']['weather'] ?? '🌡️';
      temperature = userData['location']['temperature'] ?? 'N/A';
      _setGreeting();

      // Fetch saved places
      savedPlaces = await fetchSavedPlaces();
    } catch (e) {
      print('Failed to initialize page: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 18) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }
  }

  void _searchPlaces() {
    // You can add logic to filter places based on search input
    print('Search: ${searchController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 80.0, 20.0, 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MySearchBar(
                controller: searchController,
                onSearch: _searchPlaces,
              ),
              SizedBox(height: 20),
              Text(
                '$cityState',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('$weatherIcon $temperature°F', style: TextStyle(fontSize: 16)),
              SizedBox(height: 40),
              Text(
                '$greeting! Here are some places you might enjoy!',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 20),
              PlacesGrid(savedPlaces: savedPlaces), // Use the PlacesGrid component
            ],
          ),
        ),
      ),
    );
  }
}
