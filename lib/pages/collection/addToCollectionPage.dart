import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/addToCollectionPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/collection/createAndEdit/titleAndOgPage.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/services/collectionService.dart';
import 'package:shimmer/shimmer.dart';

class AddToCollectionPage extends StatelessWidget {
  final NewsListItem news;
  const AddToCollectionPage(this.news);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0.5,
        title: Text(
          'addToCollection'.tr,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).extension<CustomColors>()?.primary700,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              PlatformIcons(context).clear,
              color: Theme.of(context).extension<CustomColors>()?.primary700,
              size: 26,
            ),
            tooltip: 'back'.tr,
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: _buildBody(context),
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 0.5,
              color: Theme.of(context).extension<CustomColors>()!.primaryLv6!,
            ),
          ),
        ),
        child: OutlinedButton(
          onPressed: () => Get.to(
            () => TitleAndOgPage(
              null,
              news.heroImageUrl ?? meshLogoImage,
              [news.heroImageUrl ?? meshLogoImage],
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Theme.of(context).extension<CustomColors>()!.primary700!,
              width: 1,
            ),
            backgroundColor: Theme.of(context).backgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
          child: Text(
            'createNewCollection'.tr,
            maxLines: 1,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).extension<CustomColors>()?.primary700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return GetBuilder<AddToCollectionPageController>(
      init: AddToCollectionPageController(CollectionService(), news),
      builder: (controller) {
        if (controller.error != null) {
          return ErrorPage(
            error: controller.error,
            onPressed: () => controller.fetchAllOwnCollections(),
            hideAppbar: true,
          );
        }

        if (!controller.isLoading) {
          Widget banner = Container();
          if (controller.alreadyPickCollections.isEmpty &&
              controller.notPickCollections.isEmpty) {
            banner = Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'userNoCollection'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(context).extension<CustomColors>()?.primary500,
                ),
              ),
            );
          } else if (controller.notPickCollections.isEmpty) {
            banner = Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'alreadyAddToAllCollections'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(context).extension<CustomColors>()?.primary500,
                ),
              ),
            );
          } else if (controller.alreadyPickCollections.length == 1) {
            banner = Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: ExtendedText.rich(
                TextSpan(
                  text: 'alreadyAddToACollectionPrefix'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        Theme.of(context).extension<CustomColors>()?.primary500,
                  ),
                  children: [
                    TextSpan(
                      text: controller.alreadyPickCollections[0].title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .extension<CustomColors>()
                            ?.primary700,
                      ),
                    ),
                    TextSpan(
                      text: 'alreadyAddToACollectionSuffix'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .extension<CustomColors>()
                            ?.primary500,
                      ),
                    )
                  ],
                ),
                joinZeroWidthSpace: true,
                maxLines: 2,
                overflowWidget: TextOverflowWidget(
                  child: RichText(
                    text: TextSpan(
                      text: '...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .extension<CustomColors>()
                            ?.primary700,
                      ),
                      children: [
                        TextSpan(
                          text: 'alreadyAddToACollectionSuffix'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .extension<CustomColors>()
                                ?.primary500,
                          ),
                        )
                      ],
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            );
          } else if (controller.alreadyPickCollections.length > 1) {
            banner = Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: ExtendedText.rich(
                TextSpan(
                  text: 'alreadyAddToCollectionsPrefix'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        Theme.of(context).extension<CustomColors>()?.primary500,
                  ),
                  children: [
                    for (int i = 0;
                        i < controller.alreadyPickCollections.length;
                        i++)
                      TextSpan(
                        text: 'upperQuotationMarks'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .extension<CustomColors>()
                              ?.primary500,
                        ),
                        children: [
                          TextSpan(
                            text: controller.alreadyPickCollections[i].title,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .extension<CustomColors>()
                                  ?.primary700,
                            ),
                          ),
                          TextSpan(
                            text: 'lowerQuotationMarks'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .extension<CustomColors>()
                                  ?.primary500,
                            ),
                          ),
                          if (i < controller.alreadyPickCollections.length - 1)
                            TextSpan(
                              text: 'comma'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .extension<CustomColors>()
                                    ?.primary500,
                              ),
                            ),
                        ],
                      ),
                    TextSpan(
                      text:
                          '${'alreadyAddToCollectionsSuffix1'.tr}${controller.alreadyPickCollections.length}${'alreadyAddToCollectionsSuffix2'.tr}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .extension<CustomColors>()
                            ?.primary500,
                      ),
                    ),
                  ],
                ),
                joinZeroWidthSpace: true,
                maxLines: 2,
                overflowWidget: TextOverflowWidget(
                  child: RichText(
                    text: TextSpan(
                      text: '...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .extension<CustomColors>()
                            ?.primary700,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '${'alreadyAddToCollectionsSuffix1'.tr}${controller.alreadyPickCollections.length}${'alreadyAddToCollectionsSuffix2'.tr}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .extension<CustomColors>()
                                ?.primary500,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              banner,
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) => ListTile(
                    leading: controller
                                .notPickCollections[index].heroImageUrl !=
                            null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: CachedNetworkImage(
                              imageUrl: controller
                                  .notPickCollections[index].heroImageUrl!,
                              fit: BoxFit.cover,
                              width: 96,
                              height: 48,
                              placeholder: (context, url) => SizedBox(
                                width: 96,
                                height: 48,
                                child: Shimmer.fromColors(
                                  baseColor: Theme.of(context)
                                      .extension<CustomColors>()!
                                      .shimmerBaseColor!,
                                  highlightColor: Theme.of(context)
                                      .extension<CustomColors>()!
                                      .primaryLv6!,
                                  child: Container(
                                    width: 96,
                                    height: 48,
                                    color: Theme.of(context).backgroundColor,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(),
                            ),
                          )
                        : null,
                    title: Text(
                      controller.notPickCollections[index].title,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context)
                            .extension<CustomColors>()
                            ?.primary700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    onTap: () {
                      controller.addStoryToCollection(
                          controller.notPickCollections[index]);
                      Get.back();
                    },
                    horizontalTitleGap: 12,
                  ),
                  separatorBuilder: (context, index) => const Divider(
                    thickness: 0.5,
                    height: 0.5,
                  ),
                  itemCount: controller.notPickCollections.length,
                ),
              )
            ],
          );
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }
}
