import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '/services/user_service.dart';
import '/services/places_service.dart';
import '/components/search_bar.dart';
import '/components/places_grid.dart';
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
  List<Map<String, dynamic>> recommendedPlaces = [];
  bool isLoading = false;
  bool locationError = false;
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
      bool locationFetched = await _updateLocationAndWeather();
      if (!locationFetched) {
        setState(() {
          locationError = true;
        });
        return;
      }
      _setGreeting();

      // Fetch nearby attractions based on user location
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      recommendedPlaces = await fetchNearbyAttractions('${position.latitude},${position.longitude}', 5000);

    } catch (e) {
      print('Failed to initialize page: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> _updateLocationAndWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print('Current position: ${position.latitude}, ${position.longitude}'); // Print current location
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

      return true;
    } catch (e) {
      print('Failed to fetch location: $e');
      return false;
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
          : locationError
          ? Center(child: Text("Cannot fetch places without accessing your location."))
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
              //SizedBox(height: 20),
              PlacesGrid(savedPlaces: recommendedPlaces), // Display the places in a grid
            ],
          ),
        ),
      ),
    );
  }
}
