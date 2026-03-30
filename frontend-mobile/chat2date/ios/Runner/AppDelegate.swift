import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String ?? ""
    GMSServices.provideAPIKey(apiKey)
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = self.registrar(forPlugin: "IosThemedTextViewPlugin") {
      let factory = IosThemedTextViewFactory(messenger: registrar.messenger())
      registrar.register(factory, withId: "chat2date/ios-themed-text-view")
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
