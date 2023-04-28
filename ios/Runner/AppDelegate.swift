import UIKit
import Flutter
import google_mobile_ads
import FCL_SDK

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

  override func application(
    _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        fcl.application(open: url)
        return true
    }
        
  override func application(
    _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        fcl.continueForLinks(userActivity)
        return true
    }
}
