import Flutter
import UIKit
import GoogleMaps
import workmanager
import awesome_notifications
import shared_preferences_foundation


@main
@objc class AppDelegate: FlutterAppDelegate {

  // Static variable to ensure background task is registered only once
  static var hasRegisteredBackgroundTask = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBfw6L1DuggFx0JPSfTn2gACUl4PZUHkao")
    GeneratedPluginRegistrant.register(with: self)

    SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
              SwiftAwesomeNotificationsPlugin.register(
                with: registry.registrar(forPlugin: "AwesomeNotificationsPlugin")!)
              SharedPreferencesPlugin.register( // replace here
                                with: registry.registrar(forPlugin: "io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin")!)
          }

    // Register background tasks only if not already registered
    if !AppDelegate.hasRegisteredBackgroundTask {
        WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "iOSBackgroundProcessing")

        // Register a periodic task in iOS 13+
        WorkmanagerPlugin.registerPeriodicTask(
            withIdentifier: "locationTracking",
            frequency: NSNumber(value: 15 * 60)
        )

        AppDelegate.hasRegisteredBackgroundTask = true
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

}
