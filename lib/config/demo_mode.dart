/// Set to true to run the app in demo mode.
/// Demo mode: no API calls, no auth checks, hardcoded mockup data.
/// Build with: flutter run --dart-define=DEMO_MODE=true
const bool kDemoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: false);
