# MedStreak Firebase Setup Guide

This guide provides instructions for setting up and configuring Firebase for the MedStreak application.

## Prerequisites

- Firebase account
- Flutter SDK installed
- Firebase CLI installed (`npm install -g firebase-tools`)

## Initial Setup

1. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**
   ```bash
   firebase login
   ```

3. **Initialize Firebase in your project**
   ```bash
   firebase init
   ```
   Select the following services:
   - Firestore
   - Authentication
   - Storage
   - Analytics

4. **Install FlutterFire CLI**
   ```bash
   dart pub global activate flutterfire_cli
   ```

5. **Configure Firebase for Flutter**
   ```bash
   flutterfire configure
   ```
   This will create the necessary configuration files for all platforms.

## Firebase Services Configuration

### Authentication

1. **Enable Authentication Methods**
   - Go to the Firebase Console > Authentication > Sign-in method
   - Enable Email/Password authentication
   - Enable Google authentication
   - Configure any other authentication methods as needed

2. **Set up OAuth consent screen (for Google Sign-in)**
   - Go to Google Cloud Console > APIs & Services > OAuth consent screen
   - Fill in the required information
   - Add necessary scopes (email, profile)

### Firestore Database

1. **Create Firestore Database**
   - Go to Firebase Console > Firestore Database
   - Start in production mode
   - Choose a location close to your target users

2. **Set up Security Rules**
   - Basic security rules are already in your `firestore.rules` file
   - Customize as needed for your specific requirements

3. **Database Structure**
   The MedStreak app uses the following collections:
   - `users`: User profiles and settings
   - `streaks`: User streak information
   - `game_results`: Game play history and results

### Storage

1. **Configure Storage Rules**
   - Basic rules are in your `storage.rules` file
   - Adjust permissions as needed

## Android Configuration

1. **Update google-services.json**
   - This file should be in `android/app/`
   - It was generated during the FlutterFire configuration

2. **Ensure NDK version is compatible**
   - Firebase requires NDK version 27.0.12077973
   - This is already configured in your `build.gradle.kts` file

## iOS Configuration (if applicable)

1. **Update GoogleService-Info.plist**
   - This file should be in `ios/Runner/`
   - It was generated during the FlutterFire configuration

2. **Configure iOS signing**
   - Update the Bundle ID in Xcode
   - Set up signing certificates

## Web Configuration (if applicable)

1. **Update firebaseConfig**
   - The configuration is in `web/index.html`
   - It was generated during the FlutterFire configuration

## Testing Firebase Integration

1. **Test Authentication**
   ```dart
   final authService = AuthService();
   await authService.signInWithEmail(email: 'test@example.com', password: 'password');
   ```

2. **Test Firestore**
   ```dart
   final firestoreService = FirestoreService();
   await firestoreService.createOrUpdateUser(userId: 'test-user', displayName: 'Test User');
   ```

## Troubleshooting

- **Authentication Issues**
  - Check if the correct authentication methods are enabled in Firebase Console
  - Verify SHA-1 fingerprint for Android Google Sign-in

- **Firestore Access Issues**
  - Check security rules in Firebase Console
  - Ensure user is authenticated before accessing protected data

- **Build Issues**
  - Verify that all Firebase dependencies are correctly added to pubspec.yaml
  - Run `flutter clean` and `flutter pub get`

## Deployment

1. **Deploy Firebase Rules**
   ```bash
   firebase deploy --only firestore:rules
   firebase deploy --only storage:rules
   ```

2. **Deploy Functions (if applicable)**
   ```bash
   firebase deploy --only functions
   ```

## Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview)
