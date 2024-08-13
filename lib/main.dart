import 'package:flutter/material.dart';
import 'pages/profile_page.dart';
import 'pages/auth_page.dart';
import 'pages/settings.dart';
import 'pages/places_list_page.dart';  // Import your PlacesList page
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'components/app_navigator_observer.dart'; // Import your observer
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/location_service.dart';
import 'package:wander_finds_gemini/services/places_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true
  );


  // Only after at least the action method is set, the notification events are delivered
  AwesomeNotifications().setListeners(
      onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
  );


  Workmanager().initialize(callbackDispatcher);

  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[50],
        ),
      ),
      home: const AuthPage(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/profile':
            return MaterialPageRoute(builder: (context) => ProfilePage());
          case '/settings':
            return MaterialPageRoute(builder: (context) => SettingsPage());
          default:
            return MaterialPageRoute(builder: (context) => AuthPage());
        }
      },
      navigatorObservers: [
        AppNavigatorObserver(
          onReturn: () {
            final profilePageState = context.findAncestorStateOfType<ProfilePageState>();
            profilePageState?.fetchUserData();  // Refresh data when returning to profile
          },
        ),
      ],
    );
  }
}


void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.value(false);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.value(false);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.value(false);
    }

    Position position = await Geolocator.getCurrentPosition();
    Position? lastPosition = await getLastPosition(); // Implement this function to get the last saved position

    if (lastPosition != null) {
      double distance = Geolocator.distanceBetween(
        lastPosition.latitude,
        lastPosition.longitude,
        position.latitude,
        position.longitude,
      );

      if (distance < 10000 || lastPosition == null) {


        // Get the current user's email from Firebase Authentication
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          print('No user logged in.');
        }
        final LocationService _locationService = LocationService();
        final weatherData = await _locationService.fetchWeatherData(position.latitude, position.longitude);

        final email = user?.email;
        List<Map<String, dynamic>> recommendedPlaces = [];

        recommendedPlaces = await fetchNearbyAttractions(
          position!.latitude,
          position!.longitude,
          25,
          weatherData['temperature']);

        final place = recommendedPlaces[0];
        final title = place['title'] ?? 'No Name';
        final address = place['address'] ?? 'No Address';
        final photo_url = place['photo_url'][0];




        AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 10,
              channelKey: 'basic_channel',
              title: "Do you want to explore " + title + " ?",
              body: address,
              notificationLayout: NotificationLayout.BigPicture,
              bigPicture: photo_url
          ),
        );
      }
    }

    saveLastPosition(position); // Implement this function to save the current position

    return Future.value(true);
  });
}

// Function to save the current position
Future<void> saveLastPosition(Position position) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('lastLatitude', position.latitude);
  await prefs.setDouble('lastLongitude', position.longitude);
  // await prefs.setDouble('test', position.longitude);
}

// Function to get the last saved position
Future<Position?> getLastPosition() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  double? latitude = prefs.getDouble('lastLatitude');
  double? longitude = prefs.getDouble('lastLongitude');
  if (latitude != null && longitude != null) {
    return Position(latitude: latitude, longitude: longitude, timestamp: DateTime.now(), accuracy: 0.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0);
  }
  return null;
}

class NotificationController {

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here

    // // Navigate into pages, avoiding to open the notification details page over another details page already opened
    // MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/notification-page',
    //         (route) => (route.settings.name != '/notification-page') || route.isFirst,
    //     arguments: receivedAction);
  }
}