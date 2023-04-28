
import google_mobile_ads

class FullNativeAdFactory : FLTNativeAdFactory {

    func createNativeAd(_ nativeAd: GADNativeAd,
                        customOptions: [AnyHashable : Any]? = nil) -> GADNativeAdView? {
        let nibView = Bundle.main.loadNibNamed("FullNativeAdView", owner: nil, options: nil)!.first
        let nativeAdView = nibView as! GADNativeAdView

        (nativeAdView.headlineView as! UILabel).text = nativeAd.headline
        if #available(iOS 13.0, *){
            if UITraitCollection.current.userInterfaceStyle == .dark {
                (nativeAdView.headlineView as! UILabel).font = UIFont.systemFont(ofSize: (nativeAdView.headlineView as! UILabel).font!.pointSize, weight: .medium)
            }
        }
        
        

        (nativeAdView.bodyView as! UILabel).text = nativeAd.body
        nativeAdView.bodyView!.isHidden = nativeAd.body == nil
        
        (nativeAdView.advertiserView as! UILabel).text = nativeAd.advertiser
        nativeAdView.advertiserView!.isHidden = nativeAd.advertiser == nil
        
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
        // ratio of the media it displays.
        if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
            let heightConstraint = NSLayoutConstraint(
              item: mediaView,
              attribute: .height,
              relatedBy: .equal,
              toItem: mediaView,
              attribute: .width,
              multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
              constant: 0)
            heightConstraint.isActive = true
          }
        
        nativeAdView.callToActionView?.isUserInteractionEnabled = false

        nativeAdView.nativeAd = nativeAd

        return nativeAdView
    }
}
