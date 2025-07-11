import UIKit
import Flutter
import FirebaseCore
import FirebaseAppCheck
import GoogleSignIn

// 🔹 Custom provider for release/TestFlight
class MyAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    if #available(iOS 14.0, *) {
      return AppAttestProvider(app: app)      // App Attest
    } else {
      return DeviceCheckProvider(app: app)    // iOS 13 fallback
    }
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // 1️⃣ Register App Check provider factory *before* Firebase is configured
    #if DEBUG
      // Use the debug provider so attestation succeeds locally
      AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
    #else
      AppCheck.setAppCheckProviderFactory(MyAppCheckProviderFactory())
    #endif

    // 2️⃣ Register Flutter plugins (firebase_core will call
    //     Firebase.initializeApp() later from Dart)
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Google-Sign-In URL handler
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if GIDSignIn.sharedInstance.handle(url) { return true }
    return super.application(app, open: url, options: options)
  }
}
