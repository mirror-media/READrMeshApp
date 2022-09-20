
import google_mobile_ads

class SmallListNativeAdFactory : FLTNativeAdFactory {

    func createNativeAd(_ nativeAd: GADNativeAd,
                        customOptions: [AnyHashable : Any]? = nil) -> GADNativeAdView? {
        let nibView = Bundle.main.loadNibNamed("SmallListNativeAdView", owner: nil, options: nil)!.first
        let nativeAdView = nibView as! GADNativeAdView

        (nativeAdView.headlineView as! UILabel).text = nativeAd.headline

        (nativeAdView.bodyView as! UILabel).text = nativeAd.body
        nativeAdView.bodyView!.isHidden = nativeAd.body == nil
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        nativeAdView.iconView?.layer.cornerRadius = 4
        nativeAdView.iconView?.clipsToBounds = true
        nativeAdView.iconView?.layer.borderWidth = 0.5
        nativeAdView.iconView?.layer.borderColor = UIColor(red: 0, green: 9, blue: 40, alpha: 0.5).cgColor
        
        (nativeAdView.advertiserView as! UILabel).text = nativeAd.advertiser
        nativeAdView.advertiserView!.isHidden = nativeAd.advertiser == nil

        nativeAdView.callToActionView?.isUserInteractionEnabled = false

        nativeAdView.nativeAd = nativeAd

        return nativeAdView
    }
}
