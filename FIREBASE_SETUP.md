# Firebase Setup Instructions for PawSense

I've integrated Firebase into your PawSense app! Follow these steps to complete the setup:

## Step 1: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

## Step 2: Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a new project"
3. Name it "pawsense" and follow the setup wizard
4. Once created, go to Project Settings

## Step 3: Configure Firebase for Your App
Run the following command in your project root:
```bash
flutterfire configure
```

This will:
- Ask which platforms you want to configure (Android, iOS, Web)
- Automatically generate the correct `firebase_options.dart` file
- Register your app with Firebase
- Download required configuration files (google-services.json for Android, GoogleService-Info.plist for iOS)

## Step 4: Update Firestore Security Rules
Once your project is created, go to Firestore Database in Firebase Console:

1. Click on "Cloud Firestore" in the left menu
2. Click "Create Database"
3. Start in **Test Mode** (for development)
4. Choose your preferred location
5. Once created, go to the "Rules" tab and paste these security rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

Then click "Publish"

## Step 5: Enable Email/Password Authentication
1. In Firebase Console, go to Authentication
2. Click "Get started"
3. Click on "Email/Password" provider
4. Toggle "Enable" on
5. Click "Save"

## Step 6: Run the App
```bash
flutter pub get
flutter run
```

## Features Now Available
✅ **Authentication**: Users can sign up and log in with email/password
✅ **Database**: User profiles, pet profiles, and activity logs are stored in Firestore
✅ **Real-time Sync**: Changes sync across devices in real-time
✅ **Security**: Firestore security rules protect user data

## Troubleshooting

### "firebase_core not found"
- Run: `flutter pub get`
- Make sure you're using Flutter 3.0+

### Android Build Issues
- Check that you've run `flutterfire configure` and selected Android
- Delete `android/app/build` folder and rebuild

### iOS Build Issues
- Run: `cd ios && pod install && cd ..`
- Make sure your iOS deployment target is 11.0 or higher

### Firestore Connection Issues
- Check Firebase Console > Project Settings > Service Account
- Ensure your internet connection is working
- Check Firestore Security Rules are properly configured

## Next Steps
Once Firebase is fully set up:
1. Test sign up with a new account
2. Verify user data appears in Firestore
3. Try logging out and back in
4. Check that pet profiles save to Firestore

For detailed Firebase documentation, visit: https://firebase.google.com/docs/flutter/setup
