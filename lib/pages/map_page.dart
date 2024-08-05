import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '/services/places_service.dart';

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
      List<Map<String, dynamic>> places = await fetchNearbyAttractions("$latitude,$longitude", 5000);
      setState(() {
        markers.addAll(places.map((place) => Marker(
          markerId: MarkerId(place['place_id']),
          position: LatLng(place['geometry']['location']['lat'], place['geometry']['location']['lng']),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: place['name'],
            snippet: place['vicinity'],
          ),
        )));
        isLoading = false;
      });
    } catch (e) {
      print('Failed to load nearby places: $e');
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

    if (distance > 1000) { // Threshold distance in meters
      setState(() {
        showSearchButton = true;
      });
    } else {
      setState(() {
        showSearchButton = false;
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
              zoom: 12,
            ),
            markers: markers,
            onMapCreated: (controller) {
              mapController = controller;
            },
            onCameraMove: _onCameraMove,
          ),
          if (showSearchButton)
            Positioned(
              top: 80,
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
