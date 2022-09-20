import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdWidget extends StatefulWidget {
  final String adUnitId;
  final String factoryId;
  final Widget? topWidget;
  final Widget? bottomWidget;
  final double? adWidth;
  final double? adHeight;
  final Color? adBgColor;
  const NativeAdWidget({
    required this.adUnitId,
    required this.factoryId,
    this.topWidget,
    this.bottomWidget,
    this.adWidth,
    this.adHeight,
    this.adBgColor,
    Key? key,
  }) : super(key: key);

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _ad;
  bool _loadSeccess = false;

  @override
  void initState() {
    super.initState();

    _ad = NativeAd(
      adUnitId: widget.adUnitId,
      factoryId: widget.factoryId,
      request: const AdRequest(),
      nativeAdOptions: NativeAdOptions(
        mediaAspectRatio: MediaAspectRatio.landscape,
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad = ad as NativeAd;
            _loadSeccess = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    _ad?.load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadSeccess) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.topWidget != null) widget.topWidget!,
          Container(
            width: widget.adWidth,
            height: widget.adHeight,
            alignment: Alignment.center,
            color: widget.adBgColor,
            child: AdWidget(ad: _ad!),
          ),
          if (widget.bottomWidget != null) widget.bottomWidget!,
        ],
      );
    }
    return Container();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }
}
