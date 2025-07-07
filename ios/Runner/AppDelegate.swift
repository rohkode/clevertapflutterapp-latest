import Flutter
import UIKit
import CleverTapSDK
import clevertap_plugin
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var channel: FlutterMethodChannel?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      // Initialize CleverTap
      CleverTap.autoIntegrate()
      CleverTap.setDebugLevel(CleverTapLogLevel.debug.rawValue)
      UNUserNotificationCenter.current().delegate = self
      // Set the CleverTap URL Delegate
//      CleverTap.sharedInstance()?.setUrlDelegate(self)
      
      // Register for push notifications
      registerPush()
      
//      // Set up MethodChannel
//              if let controller = window?.rootViewController as? FlutterViewController {
//                  channel = FlutterMethodChannel(name: "myChannel", binaryMessenger: controller.binaryMessenger)
//              }
//
//      GeneratedPluginRegistrant.register(with: self)
      CleverTapPlugin.sharedInstance()?.applicationDidLaunch(options: launchOptions)

      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Push Notification Registration
    private func registerPush() {
            UNUserNotificationCenter.current().delegate = self
            let action1 = UNNotificationAction(identifier: "action_1", title: "Back", options: [])
            let action2 = UNNotificationAction(identifier: "action_2", title: "Next", options: [])
            let action3 = UNNotificationAction(identifier: "action_3", title: "View In App", options: [])
            let category = UNNotificationCategory(identifier: "CTNotification", actions: [action1, action2, action3], intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([category])
            // request permissions
            UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) {
                (granted, error) in
                if (granted) {
                    DispatchQueue.main.async {
                       UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }

  // MARK: - Handle Notifications in Foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    
      NSLog("Foreground Notification: %@", notification.request.content.userInfo)
      
      // Record notification viewed event
//      CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: notification.request.content.userInfo)
      completionHandler([.badge, .sound, .alert])
  }

  // MARK: - Handle Notification Clicks
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
//      _ = response.notification.request.content.userInfo
//
////          if let deepLink = userInfo["deep_link"] as? String {
//              channel?.invokeMethod("handleDeepLink", arguments: deepLink)
//          }
      NSLog("Notification Clicked: %@", response.notification.request.content.userInfo)

      // Handle notification click
//      CleverTap.sharedInstance()?.handleNotification(withData: response.notification.request.content.userInfo)
      
      // Pass the notification data to Flutter via MethodChannel
//      channel?.invokeMethod("pushClickedResponse", arguments: response.notification.request.content.userInfo)

      completionHandler()
  }
 
// // MARK: - CleverTapURLDelegate
//    public func shouldHandleCleverTap(_ url: URL?, for channel: CleverTapChannel) -> Bool {
//        print("Handling URL: \(url!) for channel: \(channel)")
//        
//        // You can decide whether to handle the URL or not.
//        // Return true to allow CleverTap to handle the URL, false otherwise.
//        return true
//    }
}
