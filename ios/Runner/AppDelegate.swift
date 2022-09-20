import UIKit
import Flutter
import google_mobile_ads

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
    let smallListFactory = SmallListNativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self, factoryId: "smallList", nativeAdFactory: smallListFactory)
    let FullFactory = FullNativeAdFactory()
      FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
          self, factoryId: "full", nativeAdFactory: FullFactory)
    let OutlineFactory = OutlineNativeAdFactory()
      FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
            self, factoryId: "outline", nativeAdFactory: OutlineFactory)
    let SlideshowFactory = SlideshowNativeAdFactory()
      FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
              self, factoryId: "slideshow", nativeAdFactory: SlideshowFactory)
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
