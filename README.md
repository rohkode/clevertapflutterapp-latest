# 📱 CleverTap Flutter App – Push Notifications & Deep Linking

A **Flutter application** demonstrating the **integration of CleverTap SDK** with the following features:

✅ **Push Notifications** (Click Handling & Deep Linking)
✅ **CleverTap App Inbox**
✅ **Internal Deep Links** (`myapp://details`)
✅ **Universal Links** (`https://ct-web-sdk-react.vercel.app/details`)

This project is designed for developers looking to implement **engagement and retention features** in their Flutter apps using CleverTap.

---

## 🚀 Features Implemented

### ✅ 1. CleverTap SDK Integration

* Initialization of CleverTap SDK
* Push Notification Channel creation for Android
* Debugging enabled (`setDebugLevel`)
* User personalization enabled
* Location & network reporting configured

---

### 🔔 2. Push Notifications

* Push notifications received and tracked via CleverTap
* Custom payload handling for:

  * `wzrk_dl` (CleverTap default deep link key)
  * `deep_link` (custom property)
* Implemented **Push Primer** for iOS to request push permission with a custom UI

---

### 📬 3. CleverTap App Inbox

* Fully functional **App Inbox** integration
* Supports tabs:

  * Offers
  * Promotions
* Customized appearance:

  * Background color
  * Button styles
  * Empty state text

---

### 🔗 4. Deep Link Handling

#### 📦 Internal Deep Links

* Format: `myapp://details`
* Uses **iOS custom URL scheme**
* Handled via **MethodChannel** in `AppDelegate.swift` to communicate with Flutter
* Displays **alert dialog** to confirm handling

#### 🌐 Universal Links

* Format: `https://ct-web-sdk-react.vercel.app/details`
* Implemented using:

  * iOS **Associated Domains** (`applinks:ct-web-sdk-react.vercel.app`)
  * Flutter **uni\_links** package
* Navigates directly to `DetailsScreen` on click

---

## 🏗️ Project Structure

```
clevertapflutterapp/
├── android/                # Android native code
├── ios/                    # iOS native code
│   └── Runner/
│       └── AppDelegate.swift   # Handles Universal Links & MethodChannel
├── lib/
│   └── main.dart           # Flutter UI & CleverTap integration
├── pubspec.yaml
└── README.md
```

---

## 🔧 Setup & Installation

### **1. Clone the repository**

```bash
git clone https://github.com/rohkode/clevertapflutterapp-latest.git
cd clevertapflutterapp-latest
```

### **2. Install dependencies**

```bash
flutter pub get
```

### **3. Run the app**

```bash
flutter run
```

---

## ✅ Testing Features

### **Deep Link Testing**

* Internal Deep Link:

  * Use: `myapp://details`
  * Trigger via **push notification payload**
* Universal Link:

  * Open Safari and visit:

    ```
    https://ct-web-sdk-react.vercel.app/details
    ```
  * App should open and navigate to **Details Screen**

---

## 🔒 iOS Configuration Details

### **Info.plist**

* Add custom scheme for internal deep links:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>myapp</string>
</array>
```

### **Associated Domains**

* Enable in Xcode → Signing & Capabilities → Associated Domains:

```
applinks:ct-web-sdk-react.vercel.app
```

### **AppDelegate.swift**

* Implemented:

```swift
application(_:continue:restorationHandler:)
```

* Passes the Universal Link to Flutter via **MethodChannel**

---
