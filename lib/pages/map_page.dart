import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '/services/places_service.dart';
import '/components/place_card.dart';
import '/services/location_service.dart';
import '/components/search_bar.dart';  // Assuming you have a reusable search bar component
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  late Position currentPosition;
  Set<Marker> markers = {};
  bool isLoading = true;
  bool showSearchButton = false;
  late LatLng initialPosition;
  Map<String, Map<String, dynamic>> places = {}; // Store place details
  final LocationService _locationService = LocationService();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  void _setCurrentLocation() async {
    currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    initialPosition = LatLng(currentPosition.latitude, currentPosition.longitude);
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId("current_location"),
          position: initialPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
      _fetchNearbyPlaces(initialPosition.latitude, initialPosition.longitude);
    });
  }

  void _fetchNearbyPlaces(double latitude, double longitude) async {
    try {
      final weatherData = await _locationService.fetchWeatherData(latitude, longitude);
      final weather = weatherData['temperature']; // Use temperature as a proxy for weather
      List<Map<String, dynamic>> fetchedPlaces = await fetchNearbyAttractions(
        latitude,
        longitude,
        5,
        weather,
      );

      setState(() {
        markers.addAll(fetchedPlaces.map((place) {
          final lat = place['location']['latitude'];
          final lng = place['location']['longitude'];
          final parsedLat = lat is String ? double.parse(lat) : lat;
          final parsedLng = lng is String ? double.parse(lng) : lng;
          places[place['place_id']] = place; // Store the place details
          return Marker(
            markerId: MarkerId(place['place_id']),
            position: LatLng(parsedLat, parsedLng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            onTap: () {
              _showPlaceCard(place['place_id']);
            },
            infoWindow: InfoWindow(
              title: place['title'],
              snippet: place['address'],
            ),
          );
        }));
        isLoading = false;
      });
    } catch (e) {
      print('Failed to load nearby places: $e');
    }
  }

  void _showPlaceCard(String placeId) {
    final place = places[placeId];
    if (place != null) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.5, // Adjust this value to make the modal bottom sheet shorter
            child: PlaceCard(
              place: place,
            ),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        ),
      );
    }
  }

  void _onSearchThisArea() {
    mapController.getVisibleRegion().then((bounds) {
      double latitude = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
      double longitude = (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
      _fetchNearbyPlaces(latitude, longitude);
    });
  }

  void _onCameraMove(CameraPosition position) {
    double distance = Geolocator.distanceBetween(
      initialPosition.latitude,
      initialPosition.longitude,
      position.target.latitude,
      position.target.longitude,
    );

    if (distance > 5000) { // Threshold distance in meters
      setState(() {
        showSearchButton = true;
      });
    } else {
      setState(() {
        showSearchButton = false;
      });
    }
  }

  Future<void> _searchPlaces() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Location> locations = await locationFromAddress(searchController.text);
      if (locations.isNotEmpty) {
        final location = locations[0];
        final latitude = location.latitude;
        final longitude = location.longitude;

        // Move the map to the searched location
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(latitude, longitude),
            13, // Adjust the zoom level as needed
          ),
        );

        // Fetch and display places near the searched location
        _fetchNearbyPlaces(latitude, longitude);
      } else {
        print("No locations found for the given search query.");
      }
    } catch (e) {
      print('Failed to search places: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(currentPosition.latitude, currentPosition.longitude),
              zoom: 13,
            ),
            markers: markers,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              mapController = controller;
            },
            onCameraMove: _onCameraMove,
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: MySearchBar(
              controller: searchController,
              onSearch: _searchPlaces,
            ),
          ),
          if (showSearchButton)
            Positioned(
              top: 120, // Adjusted top position to move the button down
              left: MediaQuery.of(context).size.width / 2 - 80,
              child: ElevatedButton.icon(
                icon: Icon(Icons.search),
                label: Text('Search this area'),
                onPressed: _onSearchThisArea,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              child: Icon(Icons.my_location),
              onPressed: () {
                mapController.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(currentPosition.latitude, currentPosition.longitude),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
