package com.readr.news

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class SlideshowNativeAdFactory(private val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
            nativeAd: NativeAd,
            customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
                .inflate(R.layout.slideshow_native_ad, null) as NativeAdView

        with(nativeAdView) {
            val mediaView = findViewById<MediaView>(R.id.native_ad_media)
            mediaView.setMediaContent(nativeAd.mediaContent!!)
            mediaView.setImageScaleType(ImageView.ScaleType.CENTER_CROP)
            this.mediaView = mediaView

            val headlineView = findViewById<TextView>(R.id.native_ad_headline)
            headlineView.text = nativeAd.headline
            this.headlineView = headlineView

            val bodyView = findViewById<TextView>(R.id.native_ad_body)
            with(bodyView) {
                text = nativeAd.body
                nativeAd.body?.let {
                    visibility = if (nativeAd.body!!.isNotEmpty()) View.VISIBLE else View.INVISIBLE
                }
            }
            this.bodyView = bodyView

            val advertiserView = findViewById<TextView>(R.id.advertiser_name)
            with(advertiserView) {
                text = nativeAd.advertiser
                nativeAd.advertiser?.let {
                    visibility = if (nativeAd.advertiser!!.isNotEmpty()) View.VISIBLE else View.INVISIBLE
                }
            }

            setNativeAd(nativeAd)
        }

        return nativeAdView
    }
}