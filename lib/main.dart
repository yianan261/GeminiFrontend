import 'package:flutter/material.dart';
import 'pages/profile_page.dart';
import 'pages/auth_page.dart';
import 'pages/settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'components/app_navigator_observer.dart'; // Import your observer
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/location_service.dart';
import 'package:wander_finds_gemini/services/places_service.dart';

const locationTracking = "locationTracking";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Workmanager().cancelAll();
  await initializeWorkManager();
  Workmanager().registerPeriodicTask(
    "locationTracking",
    locationTracking,
    frequency: Duration(minutes: 15),
  );
  Workmanager().printScheduledTasks();
  runApp(const MyApp());
}

Future<void> initializeWorkManager() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  print("WorkManager initialization complete.");
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  print("Workmanager task started.");
  Workmanager().executeTask((task, inputData) async {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Basic group',
        )
      ],
      debug: true,
    );

    if (task == locationTracking) {
      print("Task executed: $task");
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'basic_channel',
          title: "Hello from WorkManager!",
          body: "This is a simple notification triggered by the WorkManager task.",
        ),
      );
      print("Notification sent.");
    }
    return Future.value(true);
  });
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
            profilePageState?.fetchUserData();
          },
        ),
      ],
    );
  }
}

// Function to save the current position
Future<void> saveLastPosition(Position position) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('lastLatitude', position.latitude);
  await prefs.setDouble('lastLongitude', position.longitude);
}

// Function to get the last saved position
Future<Position?> getLastPosition() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  double? latitude = prefs.getDouble('lastLatitude');
  double? longitude = prefs.getDouble('lastLongitude');
  if (latitude != null && longitude != null) {
    return Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }
  return null;
}

class NotificationController {

  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
  }
}
