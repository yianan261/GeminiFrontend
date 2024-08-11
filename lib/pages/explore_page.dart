import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '/services/places_service.dart';
import '/components/search_bar.dart';
import '/components/places_grid.dart';
import 'package:geocoding/geocoding.dart';
import '/services/location_service.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String cityState = '';
  String weatherIcon = '';
  String temperature = '';
  String greeting = '';
  String queryLocationWeather = '';
  String queryCityState = '';
  bool isQueryLocation = false;
  List<Map<String, dynamic>> recommendedPlaces = [];
  bool isLoading = false;
  bool locationError = false;
  TextEditingController searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  Position? _currentPosition;

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
      bool locationFetched = await _updateLocationAndWeather();
      if (!locationFetched) {
        if (!mounted) return;
        setState(() {
          locationError = true;
        });
        return;
      }
      _setGreeting();

      _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final weather = temperature;
      recommendedPlaces = await fetchNearbyAttractions(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        25,
        weather,
      );

    } catch (e) {
      print('Failed to initialize page: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> _updateLocationAndWeather({double? latitude, double? longitude}) async {
    try {
      Position position;
      if (latitude != null && longitude != null) {
        position = Position(
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      } else {
        position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      final Placemark placemark = placemarks[0];
      final city = placemark.locality;
      final state = placemark.administrativeArea;
      final weatherData = await _locationService.fetchWeatherData(position.latitude, position.longitude);
      if (!mounted) return false;

      setState(() {
        cityState = '${city ?? 'Unknown city'}, ${state ?? 'Unknown state'}';
        weatherIcon = weatherData['icon'] ?? '';
        temperature = weatherData['temperature'] ?? 'Unknown';
      });

      return true;
    } catch (e) {
      print('Failed to fetch location or weather: $e');
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

  Future<void> _searchPlaces() async {
    if (_currentPosition == null) return;

    setState(() {
      isLoading = true;
      locationError = false;
    });

    try {
      String query = searchController.text.trim();
      print("Search query: $query");

      recommendedPlaces = await searchPointOfInterest(
        query,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        25,
        temperature, // Use the current temperature for the search
      );

      if (recommendedPlaces.isNotEmpty) {
        String firstAddress = recommendedPlaces[0]['address'];
        await _updateLocationAndWeatherForQuery(firstAddress);
      }
    } catch (e) {
      print('Failed to search places: $e');
      setState(() {
        locationError = true;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateLocationAndWeatherForQuery(String address) async {
    try {
      // Attempt to geocode the address to get location details
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final queryLocation = locations.first;
        List<Placemark> placemarks = await placemarkFromCoordinates(queryLocation.latitude, queryLocation.longitude);
        final Placemark placemark = placemarks[0];
        final city = placemark.locality;
        final state = placemark.administrativeArea;

        final queryWeatherData = await _locationService.fetchWeatherData(queryLocation.latitude, queryLocation.longitude);
        print(queryWeatherData);
        if (queryWeatherData != null) {
          setState(() {
            isQueryLocation = true;
            queryCityState = '${city ?? 'Unknown city'}, ${state ?? 'Unknown state'}';
            queryLocationWeather = '${queryWeatherData['icon']} ${queryWeatherData['temperature']}°F';
          });
        } else {
          setState(() {
            isQueryLocation = false;
          });
        }
      } else {
        setState(() {
          isQueryLocation = false;
        });
      }
    } catch (e) {
      print('Failed to identify the location: $e');
      setState(() {
        isQueryLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : locationError
          ? Center(child: Text("Cannot fetch places without accessing your location."))
          : Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 80.0, 20.0, 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MySearchBar(
                controller: searchController,
                onSearch: _searchPlaces, // Triggers search and updates location/weather
              ),
              SizedBox(height: 20),
              if (!isQueryLocation) ...[
                Text(
                  '$cityState',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('$weatherIcon $temperature°F', style: TextStyle(fontSize: 16)),
              ] else ...[
                Text(
                  '$queryCityState',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('$queryLocationWeather', style: TextStyle(fontSize: 16)),
              ],
              SizedBox(height: 30),
              Text(
                '$greeting! Here are some places you might enjoy!',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              _currentPosition != null
                  ? PlacesGrid(
                recommendedPlaces: recommendedPlaces,
              )
                  : Center(child: Text("Unable to fetch your current location.")),
            ],
          ),
        ),
      ),
    );
  }
}
