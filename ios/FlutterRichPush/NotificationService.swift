//
//  NotificationService.swift
//  FlutterRichPush
//  Created by Rohit Khandka on 19/05/25.
//

import UserNotifications
import CTNotificationService
import CleverTapSDK

class NotificationService: CTNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        print("🚀 NSE called — Notification payload: \(request.content.userInfo)")

//        let userDefaults = UserDefaults(suiteName: "group.ct12.rnsample")
//        let userId = userDefaults?.object(forKey: "identity")
//        let userEmail = userDefaults?.object(forKey: "email")
//
//        if let userId = userId {
//            let profile: [String: Any] = [
//                "Identity": userId,
//                "Email": userEmail as Any
//            ]
//            CleverTap.sharedInstance()?.onUserLogin(profile)
//        }

        CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: request.content.userInfo)

        super.didReceive(request, withContentHandler: contentHandler)
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
