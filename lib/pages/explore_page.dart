import 'package:flutter/material.dart';
import '/services/user_service.dart';
import '/components/search_bar.dart'; // Ensure the correct path
import '/services/request_location.dart';  // Import the request_location.dart file

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String places = '';
  bool isLoading = false;
  String location = '';
  String cityState = '';
  String weatherIcon = '';
  String temperature = '';
  String greeting = '';
  List<String> userInterests = [];
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
      final latitude = userData['location']['latitude'];
      final longitude = userData['location']['longitude'];
      location = 'Lat: $latitude, Lon: $longitude';

      await _fetchCityStateAndWeather(latitude, longitude);
      _setGreeting();
      // await _generatePlaces();
    } catch (e) {
      print('Failed to initialize page: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCityStateAndWeather(double latitude, double longitude) async {
    final cityStateData = await fetchCityState(latitude, longitude);
    final weatherData = await fetchWeatherData(latitude, longitude);
    setState(() {
      cityState = '${cityStateData['city']}, ${cityStateData['state']}';
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
              Text('$weatherIcon $temperature°F',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  )),
              SizedBox(height: 40),
              Text(
                '$greeting! Here are some places you might enjoy!',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
