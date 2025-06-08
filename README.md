# IAQuick
IAQuick application for indoor air quality (IAQ) assessments and report creation. Designed to drastically improve the workflow and efficiency of indoor air quality assessments by 85+%

Learn more at [sohum1094.github.io](url)

## Firebase Setup

1. **Install the FlutterFire CLI**

   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure Firebase for this project**

   Run the following command in the project root and follow the prompts to select your Firebase project:

   ```bash
   flutterfire configure
   ```

   This will generate `lib/firebase_options.dart` containing your project's configuration.

3. **Platform configuration files**

   - Place your Android `google-services.json` file in `android/app/`.
   - Place your iOS `GoogleService-Info.plist` file in `ios/Runner/`.

After the configuration files are in place, the app can initialize Firebase using the generated options.
