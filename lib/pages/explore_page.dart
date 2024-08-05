import 'package:flutter/material.dart';
import '/services/user_service.dart';
import '/services/places_service.dart';
import '/components/search_bar.dart';
import '/components/places_grid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '/services/background_location_service.dart';

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
  List<Map<String, dynamic>> recommendedPlaces = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  final BackgroundLocationService _backgroundLocationService = BackgroundLocationService();

  @override
  void initState() {
    super.initState();
    _initializePage();
    _backgroundLocationService.configure();
  }

  Future<void> _initializePage() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch user data
      final userData = await getUser();
      userInterests = List<String>.from(userData['interests'] ?? []);
      await _updateLocationAndWeather();
      _setGreeting();

      // Fetch places of interest based on user location
      String userLocation = userData['location'] ?? "37.7749,-122.4194"; // Default to San Francisco
      recommendedPlaces = await fetchPlacesOfInterest(userData['email'], userLocation);

      // Print out the locations
      for (var place in recommendedPlaces) {
        print('Place: ${place['name']}, Location: ${place['vicinity']}');
      }
    } catch (e) {
      print('Failed to initialize page: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateLocationAndWeather() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    final Placemark placemark = placemarks[0];
    final city = placemark.locality ?? '';
    final state = placemark.administrativeArea ?? '';

    final weatherData = await _backgroundLocationService.fetchWeatherData(position.latitude, position.longitude);

    setState(() {
      cityState = '$city, $state';
      weatherIcon = weatherData['icon'];
      temperature = weatherData['temperature'];
    });
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
              PlacesGrid(savedPlaces: recommendedPlaces), // Display the places in a grid
            ],
          ),
        ),
      ),
    );
  }
}
