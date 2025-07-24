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
      
      // Push and URL Delegate
      UNUserNotificationCenter.current().delegate = self
      CleverTap.sharedInstance()?.setUrlDelegate(self) // For intercepting deep links
      CleverTap.sharedInstance()?.setPushNotificationDelegate(self) // For push click control
      
      // Register for push notifications
      registerPush()
      
      // MethodChannel for Deeplink forwarding
       if let controller = window?.rootViewController as? FlutterViewController {
           channel = FlutterMethodChannel(name: "myChannel", binaryMessenger: controller.binaryMessenger)
       }

      GeneratedPluginRegistrant.register(with: self)
      CleverTapPlugin.sharedInstance()?.applicationDidLaunch(options: launchOptions)

      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Push Notification Registration
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

  // Handle Notifications in Foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    
      NSLog("Foreground Notification: %@", notification.request.content.userInfo)
      completionHandler([.badge, .sound, .alert])
  }
    
    // Handle Universal Links
    override func application(_ application: UIApplication,
                                  continue userActivity: NSUserActivity,
                                  restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
            if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
               let url = userActivity.webpageURL {
                print("Universal Link opened: \(url.absoluteString)")
                channel?.invokeMethod("handleDeepLink", arguments: url.absoluteString)
            }
            return true
        }
    
    // Handle Custom URL Schemes (optional)
    override func application(_ app: UIApplication,
                                  open url: URL,
                                  options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            print("Custom URL opened: \(url.absoluteString)")
            channel?.invokeMethod("handleDeepLink", arguments: url.absoluteString)
            return true
        }
    }
    
    //CleverTap Push Notification Delegate
    extension AppDelegate: CleverTapPushNotificationDelegate {
        func pushNotificationClicked(withPayload payload: [AnyHashable : Any]!, openDeepLinksInForeground: Bool) {
            print("Push Clicked Payload: \(payload ?? [:])")

            // Extract deep link and forward to Flutter
            if let deepLink = payload["wzrk_dl"] as? String {
                channel?.invokeMethod("handleDeepLink", arguments: deepLink)
            }
        }
    }

    // CleverTap URL Delegate
    extension AppDelegate: CleverTapURLDelegate {
        func shouldHandleCleverTap(_ url: URL?, for channel: CleverTapChannel) -> Bool {
            print("Intercepted URL: \(url?.absoluteString ?? "")")
            
            if let link = url?.absoluteString {
                self.channel?.invokeMethod("handleDeepLink", arguments: link)
            }
            return false // Prevent Safari
        }
    }

  // Handle Notification Clicks
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  didReceive response: UNNotificationResponse,
                                  withCompletionHandler completionHandler: @escaping () -> Void) {
          NSLog("Notification Clicked: %@", response.notification.request.content.userInfo)

      completionHandler()
  }
