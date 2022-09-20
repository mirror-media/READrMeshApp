package com.readr.news

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // TODO: Register the ListTileNativeAdFactory
        GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterEngine, "smallList", SmallListNativeAdFactory(context))
        GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterEngine, "full", FullNativeAdFactory(context))
        GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterEngine, "outline", OutlineNativeAdFactory(context))
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)

        // TODO: Unregister the ListTileNativeAdFactory
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "smallList")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "full")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "outline")
    }
}
