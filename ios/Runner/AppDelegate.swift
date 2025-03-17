import Flutter
import UIKit
import CleverTapSDK
import clevertap_plugin
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, CleverTapURLDelegate {
  private var channel: FlutterMethodChannel?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      // Initialize CleverTap
      CleverTap.autoIntegrate()
      CleverTapPlugin.sharedInstance()?.applicationDidLaunch(options: launchOptions)
      CleverTap.setDebugLevel(CleverTapLogLevel.debug.rawValue)
      
      // Set the CleverTap URL Delegate
      CleverTap.sharedInstance()?.setUrlDelegate(self)
      
      // Register for push notifications
      registerForPush()
      
      // Set up MethodChannel
              if let controller = window?.rootViewController as? FlutterViewController {
                  channel = FlutterMethodChannel(name: "myChannel", binaryMessenger: controller.binaryMessenger)
              }

      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Push Notification Registration
  private func registerForPush() {
      UNUserNotificationCenter.current().delegate = self
      UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert]) { granted, error in
          if granted {
              DispatchQueue.main.async {
                  UIApplication.shared.registerForRemoteNotifications()
              }
          } else if let error = error {
              NSLog("Push Notification Permission Error: %@", error.localizedDescription)
          }
      }
  }

  // MARK: - Handle Notifications in Foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      NSLog("Foreground Notification: %@", notification.request.content.userInfo)
      
      // Record notification viewed event
      CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: notification.request.content.userInfo)
      completionHandler([.badge, .sound, .alert])
  }

  // MARK: - Handle Notification Clicks
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
      let userInfo = response.notification.request.content.userInfo

          if let deepLink = userInfo["deep_link"] as? String {
              channel?.invokeMethod("handleDeepLink", arguments: deepLink)
          }
      NSLog("Notification Clicked: %@", response.notification.request.content.userInfo)

      // Handle notification click
      CleverTap.sharedInstance()?.handleNotification(withData: response.notification.request.content.userInfo)
      
      // Pass the notification data to Flutter via MethodChannel
      channel?.invokeMethod("pushClickedResponse", arguments: response.notification.request.content.userInfo)

      completionHandler()
  }
 
 // MARK: - CleverTapURLDelegate
    public func shouldHandleCleverTap(_ url: URL?, for channel: CleverTapChannel) -> Bool {
        print("Handling URL: \(url!) for channel: \(channel)")
        
        // You can decide whether to handle the URL or not.
        // Return true to allow CleverTap to handle the URL, false otherwise.
        return true
    }
}
