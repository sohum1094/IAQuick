import UIKit
import Flutter

import FirebaseCore
import FirebaseAppCheck
import GoogleSignIn

// 1️⃣ Create your App Check provider factory
class MyAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    if #available(iOS 14.0, *) {
      // Uses Apple’s App Attest
      return AppAttestProvider(app: app)
    } else {
      // Falls back to DeviceCheck on older iOS
      return DeviceCheckProvider(app: app)
    }
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 🔹 Configure Firebase
    // FirebaseApp.configure()

    // 🔹 Wire up App Check
    #if DEBUG
      // Built-in debug provider logs a token you register in the console
      AppCheck.setAppCheckProviderFactory(DebugAppCheckProviderFactory())
    #else
      // Your custom factory from above
      AppCheck.setAppCheckProviderFactory(MyAppCheckProviderFactory())
    #endif

    // 🔹 Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 🔹 Google Sign-In callback support
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }
}
