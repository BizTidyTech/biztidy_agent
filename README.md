# BizTidy Agent App

Separate Flutter project for the BizTidy Agent app — published to Play Store & App Store.

## Package Names
- Android: `com.tidytech.agent`
- iOS: `com.tidytech.agent`

## Firebase Setup (REQUIRED before first build)
This app shares the same Firebase project (`tidytech-app`) as the client app.
You need to register the Agent app as a NEW app inside the SAME Firebase project:

### Android
1. Go to Firebase Console → tidytech-app → Project Settings → Add App → Android
2. Package name: `com.tidytech.agent`
3. Download `google-services.json`
4. Place it at: `android/app/google-services.json`

### iOS
1. Go to Firebase Console → tidytech-app → Project Settings → Add App → iOS
2. Bundle ID: `com.tidytech.agent`
3. Download `GoogleService-Info.plist`
4. Place it at: `ios/Runner/GoogleService-Info.plist`
5. Also update `lib/firebase_options.dart` with the new iOS appId

## Running the App
```bash
flutter pub get
flutter run
```

## Building for Release
```bash
# Android
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Key Info
- Shares Firestore database with the client app (same `Agents`, `AgentJobs`, `Bookings` collections)
- New agents sign up → `isApproved: false` → Admin approves in Admin app → Agent can log in
- Admin app is a separate private APK (not on stores)
