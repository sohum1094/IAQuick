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

4. **Provide your own Firebase config locally**

   The `google-services.json` file is excluded from version control. Copy
   your project's `google-services.json` and `GoogleService-Info.plist`
   to the above paths before running the app.

After the configuration files are in place, the app can initialize Firebase using the generated options.

### Enable Authentication

To authenticate users, enable Email/Password sign-in in the Firebase console:

1. Open the **Authentication** section of your Firebase project.
2. On the **Sign-in method** tab, enable **Email/Password**.
3. Optionally create user accounts in the **Users** tab so they can log in.

The application uses the Firebase user's `displayName` to derive your initials
when naming saved files. You can set this value when creating the account or
later in the Firebase console.

#### Google Sign‑In

1. On the **Sign‑in method** tab also enable **Google**.
2. Add your Android and iOS package names and SHA‑1 keys in the Firebase console.

#### Resolving "Requests to this API ... SignInWithPassword are blocked"

If you see an error similar to `Requests to this API identitytoolkit method
google.cloud.identitytoolkit.v1.AuthenticationService.SignInWithPassword are
blocked`, verify that the **Identity Toolkit API** (also called "Identity
Platform") is enabled for your Google Cloud project. This API is required for
email/password authentication.

## Camera Permission

The app captures photos as part of room readings. Grant camera access when
prompted. On iOS add an `NSCameraUsageDescription` entry in `Info.plist`, and on
Android declare `android.permission.CAMERA` in `AndroidManifest.xml`.

## Offline Excel Export Example

A helper script `scripts/export_to_excel.py` demonstrates how to create an IAQ Excel
report using the bundled template. It fills the template with sample data and
saves the result to a new `.xlsx` file.

Run it with Python 3:

```bash
python3 scripts/export_to_excel.py output.xlsx
```

This will create `output.xlsx` following the same layout as the
`assets/IAQ_template_v2.xlsx` file.

## Exporting Survey Data from Firebase

The `scripts/firebase_export.py` tool connects to Firestore using
`firebase_admin` and exports a survey document to Excel. Provide the survey ID
and a service account JSON file:

```bash
python3 scripts/firebase_export.py --credentials path/to/service.json <surveyId>
```

Workbooks are saved inside an output folder named after the survey site. Both
Indoor Air Quality and Visual Assessment files will be created when applicable.
