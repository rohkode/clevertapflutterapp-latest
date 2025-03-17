# CleverTap Flutter App - Updated to v3.2.0

This project is a sample Flutter application integrated with **CleverTap SDK v3.2.0**. This guide outlines the steps taken to successfully upgrade to the latest SDK version and resolve compatibility issues.

## Prerequisites
- Flutter **3.2.0**
- Android Studio with JDK 17
- Gradle 8.0+

---

## Steps to Upgrade to CleverTap SDK v3.2.0

### 1. **Update `build.gradle` Files**
#### `android/app/build.gradle`
- Updated `compileSdkVersion` to **35**
- Updated `sourceCompatibility` and `targetCompatibility` to **JavaVersion.VERSION_17**
- Updated Kotlin JVM target to **`17`**

**Updated Code:**
```gradle
android {
    compileSdkVersion 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}
```

#### `android/build.gradle`
- Added Kotlin Gradle Plugin dependency for **v1.9.0**

**Updated Code:**
```gradle
buildscript {
    dependencies {
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0'
    }
}
```

---

### 2. **Add/Update `.gitignore` File**
To prevent unwanted files from being tracked, the following entries were added to `.gitignore`:
```gitignore
# Flutter build files
build/
*.lock
.dart_tool/
.packages
.pub/
.idea/
.vscode/
.flutter-plugins
.flutter-plugins-dependencies
*.iml
```

---

### 3. **Remove Unwanted Files (If Already Tracked)**
The following command was used to clean up previously committed build and config files:
```bash
git rm -r --cached build .dart_tool .idea .vscode .flutter-plugins-dependencies
```

---

### 4. **Clean and Rebuild the Project**
After the changes, the project was cleaned and dependencies were fetched again to ensure compatibility:
```bash
flutter clean
flutter pub get
flutter build apk
```

---

### 5. **Test the Integration**
- Verified successful data flow to the CleverTap dashboard
- Tested push notifications, in-app messages, and user profile updates

---

## Common Issues and Fixes
### Error: `Unknown Kotlin JVM target: 1.9`
**Solution:** Ensure the following settings are correctly updated:
- `kotlinOptions { jvmTarget = "17" }`
- `sourceCompatibility = JavaVersion.VERSION_17`
- `targetCompatibility = JavaVersion.VERSION_17`

### Error: `'compileReleaseJavaWithJavac' and 'compileReleaseKotlin' have different JVM targets`
**Solution:** Ensure Java and Kotlin versions are aligned to **17** as shown in the steps above.

---

## Repository Information
- **Author:** Rohit Khandka
- **GitHub Repository:** [clevertapflutterapp-latest](https://github.com/rohkode/clevertapflutterapp-latest)

For further guidance, refer to the [CleverTap Flutter SDK Documentation](https://developer.clevertap.com/docs/flutter-sdk).
