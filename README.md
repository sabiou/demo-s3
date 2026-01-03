# s3_firebase_demo

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase setup (secrets stripped)
- `lib/firebase_options.dart`, `android/app/google-services.json`, and `ios/Runner/GoogleService-Info.plist` now contain placeholders only; real keys and IDs must be supplied locally before running.
- Provide runtime values to `firebase_options.dart` via `--dart-define`, e.g. `flutter run --dart-define=FIREBASE_ANDROID_API_KEY=...`.
- Keep real `google-services.json` and `GoogleService-Info.plist` files out of git; copy the placeholders and fill them locally.
