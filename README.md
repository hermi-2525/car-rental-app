# Hermi Car Rental App

A Flutter implementation of the Car Rental App connected to Firebase.

## Setup Instructions

### 1. Firebase Configuration ([Crucial Step])
This app depends on Firebase. You must configure it for your platform (Android/iOS).

1.  Go to the [Firebase Console](https://console.firebase.google.com/).
2.  Create a new project.
3.  Add an Android app:
    *   Package name: `com.example.hermi` (or check `android/app/build.gradle`)
    *   Download `google-services.json` and place it in `android/app/`.
4.  Add an iOS app (if on Mac):
    *   Bundle ID: `com.example.hermi`
    *   Download `GoogleService-Info.plist` and place it in `ios/Runner/`.
5.  Enable **Authentication** (Email/Password) in Firebase Console.
6.  Enable **Firestore Database** in Firebase Console.

### 2. Run the App
```bash
flutter pub get
flutter run
```

### 3. Features Implemented
*   **Authentication**: Login and Sign Up (Renter/Owner roles).
*   **Home Screen**: List of available cars (fetched from Firestore).
*   **Car Details**: View car images, features, price, and owner.
*   **Booking**: Placeholder for booking flow.

### 4. Firestore Data
The app expects a `cars` collection. You can manually add a document to test:
*   Collection: `cars`
*   Document Fields:
    *   `name`: "Tesla Model 3"
    *   `image`: "https://..."
    *   `price`: 150
    *   `rating`: 4.8
    *   `type`: "Sedan"
    *   `features`: ["Autopilot", "GPS"]
    *   ... (see `lib/models/car.dart` for full schema)
