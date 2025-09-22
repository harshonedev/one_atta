# Google Maps API Configuration

## Issue Fixed
The app was crashing due to a missing Google Maps API key in the Android configuration. I've added the necessary configuration placeholders.

## Steps to Configure Google Maps API Key

### 1. Get Google Maps API Key
1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the "Maps SDK for Android" API
4. Go to "Credentials" and create a new API key
5. Restrict the API key to your app's package name: `com.example.one_atta`

### 2. Update Android Configuration
Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` in the following file with your actual API key:

**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

### 3. iOS Configuration (if needed)
If you're also building for iOS, add your API key to:

**File:** `ios/Runner/AppDelegate.swift`

```swift
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Changes Made

### AndroidManifest.xml
- Added Google Maps API key meta-data tag
- Added location permissions:
  - `ACCESS_FINE_LOCATION`
  - `ACCESS_COARSE_LOCATION`
  - `ACCESS_BACKGROUND_LOCATION`

### Security Note
- Never commit your actual API key to version control
- Consider using environment variables or build configurations for different environments
- Restrict your API key to your specific package name and required APIs only

## Testing
After adding your API key, the Google Maps should work without crashing the app.