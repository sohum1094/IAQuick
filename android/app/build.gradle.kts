plugins {
  id("com.android.application")
  id("org.jetbrains.kotlin.android")
  // Flutter’s Gradle plugin
  id("dev.flutter.flutter-gradle-plugin")
  // Firebase / Google-services plugin
  id("com.google.gms.google-services")
}

android {
    namespace = "com.iaquick.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.iaquick.appp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        ndkVersion = "27.0.12077973"
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}


dependencies {
  // use the Firebase BOM so all Firebase libs stay in sync
  implementation(platform("com.google.firebase:firebase-bom:32.2.2"))

  // Firebase Auth KTX
  implementation("com.google.firebase:firebase-auth-ktx")

  // other dependencies …
}

// apply plugin: 'com.google.gms.google-services'
