# Firebase Setup Guide

This guide will help you configure Firebase for this Flutter project.

## Prerequisites

- Node.js and npm installed
- Flutter SDK installed
- Access to the Firebase project

## Setup Steps

### 1. Install Firebase Tools

```bash
npm install -g firebase-tools
```

### 2. Login to Firebase

```bash
firebase login
```

This will open a browser window for you to authenticate with your Google account.

### 3. Activate FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 4. Configure FlutterFire

```bash
flutterfire configure
```

This command will:
- Connect to your Firebase project
- Generate `lib/firebase_options.dart` with your configuration
- Set up Firebase for all platforms (iOS, Android, Web)

### 5. Download Platform-Specific Configuration Files

Go to the [Firebase Console](https://console.firebase.google.com/) and download the following files:

#### For iOS:
1. Navigate to Project Settings → Your iOS app
2. Download `GoogleService-Info.plist`
3. Place it in: `ios/Runner/GoogleService-Info.plist`

#### For Android:
1. Navigate to Project Settings → Your Android app
2. Download `google-services.json`
3. Place it in: `android/app/google-services.json`

## Verification

After completing the setup, verify that the following files exist:

```
✅ lib/firebase_options.dart
✅ ios/Runner/GoogleService-Info.plist
✅ android/app/google-services.json
```

## Running the App

Once Firebase is configured, you can run the app:

```bash
flutter pub get
flutter run
```

## Troubleshooting

**Issue: `flutterfire` command not found**
- Solution: Make sure Dart's global packages are in your PATH
  ```bash
  export PATH="$PATH":"$HOME/.pub-cache/bin"
  ```

**Issue: Firebase configuration not found**
- Solution: Re-run `flutterfire configure` and ensure you select the correct Firebase project

**Issue: Build errors related to Firebase**
- Solution: Run `flutter clean` and `flutter pub get`, then rebuild

## Notes

- (`firebase_options.dart`, `GoogleService-Info.plist`, `google-services.json`) are not committed to version control for security reasons
- Each developer needs to run this setup process on their local machine
