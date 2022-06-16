import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/member.dart';

class DynamicLinkHelper {
  static Future<String> createCollectionLink(Collection collection) async {
    String url =
        '${Get.find<EnvironmentService>().config.readrMeshWebsite}/mesh/collection?=${collection.id}';

    return _buildDynamicLink(
      url: url,
      socialMediaTitle: collection.title,
      socialMediaDescription: '看看大家精選了哪些新聞？READr MESH集錦，客製化挑選喜愛的報導。',
    );
  }

  static Future<String> createPersonalFileLink(Member member) async {
    String url =
        '${Get.find<EnvironmentService>().config.readrMeshWebsite}/mesh/member?=${member.memberId}';

    return _buildDynamicLink(
      url: url,
      socialMediaTitle: '${member.nickname}的精選的新聞和集錦',
      socialMediaDescription:
          '快來看看${member.nickname}在READr MESH 挑選了哪些新聞和集錦？加入READr MESH建立專屬的個人頁面。',
    );
  }

  static Future<String> _buildDynamicLink({
    required String url,
    String? socialMediaTitle,
    String? socialMediaDescription,
  }) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final longDynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(url),
      uriPrefix: Get.find<EnvironmentService>().config.dynamicLinkDomain,
      androidParameters: AndroidParameters(
        packageName: packageInfo.packageName,
        minimumVersion: 31,
      ),
      iosParameters: IOSParameters(
        bundleId: packageInfo.packageName,
        appStoreId: '1596246729',
        minimumVersion: '1.2.0',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: socialMediaTitle,
        description: socialMediaDescription,
        //imageUrl: Uri.parse("https://example.com/image.png"),
      ),
    );
    final Uri longLink =
        await FirebaseDynamicLinks.instance.buildLink(longDynamicLinkParams);
    final Uri newLongLink = Uri.parse(
        "${longLink.toString()}&ofl=${Get.find<EnvironmentService>().config.readrWebsiteLink}");
    final shortDynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(url),
      uriPrefix: Get.find<EnvironmentService>().config.dynamicLinkDomain,
      longDynamicLink: newLongLink,
    );
    final dynamicLink = await FirebaseDynamicLinks.instance
        .buildShortLink(shortDynamicLinkParams);
    return dynamicLink.shortUrl.toString();
  }
}
