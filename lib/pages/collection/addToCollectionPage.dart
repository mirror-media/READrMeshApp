import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/addToCollectionPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0.5,
        title: const Text(
          '加入集錦',
          style: TextStyle(
            fontSize: 18,
            color: readrBlack,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              PlatformIcons(context).clear,
              color: readrBlack87,
              size: 26,
            ),
            tooltip: '回前頁',
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: _buildBody(context),
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 0.5,
              color: readrBlack10,
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
            side: const BorderSide(color: readrBlack, width: 1),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
          child: const Text(
            '建立新集錦',
            maxLines: 1,
            style: TextStyle(
              fontSize: 16,
              color: readrBlack,
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
            banner = const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '你目前還沒有任何集錦...',
                style: TextStyle(
                  fontSize: 14,
                  color: readrBlack50,
                ),
              ),
            );
          } else if (controller.notPickCollections.isEmpty) {
            banner = const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '你之前已將這篇新聞加入你所有的集錦囉',
                style: TextStyle(
                  fontSize: 14,
                  color: readrBlack50,
                ),
              ),
            );
          } else if (controller.alreadyPickCollections.length == 1) {
            banner = Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: ExtendedText.rich(
                TextSpan(
                  text: '你之前已將這篇新聞加入「',
                  style: const TextStyle(
                    fontSize: 14,
                    color: readrBlack50,
                  ),
                  children: [
                    TextSpan(
                      text: controller.alreadyPickCollections[0].title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: readrBlack87,
                      ),
                    ),
                    const TextSpan(
                      text: '」集錦囉',
                      style: TextStyle(
                        fontSize: 14,
                        color: readrBlack50,
                      ),
                    )
                  ],
                ),
                joinZeroWidthSpace: true,
                maxLines: 2,
                overflowWidget: TextOverflowWidget(
                  child: RichText(
                    text: const TextSpan(
                      text: '...',
                      style: TextStyle(
                        fontSize: 14,
                        color: readrBlack87,
                      ),
                      children: [
                        TextSpan(
                          text: '」集錦囉',
                          style: TextStyle(
                            fontSize: 14,
                            color: readrBlack50,
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
                  text: '你之前已將這篇新聞加入',
                  style: const TextStyle(
                    fontSize: 14,
                    color: readrBlack50,
                  ),
                  children: [
                    for (int i = 0;
                        i < controller.alreadyPickCollections.length;
                        i++)
                      TextSpan(
                        text: '「',
                        style: const TextStyle(
                          fontSize: 14,
                          color: readrBlack50,
                        ),
                        children: [
                          TextSpan(
                            text: controller.alreadyPickCollections[i].title,
                            style: const TextStyle(
                              fontSize: 14,
                              color: readrBlack87,
                            ),
                          ),
                          const TextSpan(
                            text: '」',
                            style: TextStyle(
                              fontSize: 14,
                              color: readrBlack50,
                            ),
                          ),
                          if (i < controller.alreadyPickCollections.length - 1)
                            const TextSpan(
                              text: '、',
                              style: TextStyle(
                                fontSize: 14,
                                color: readrBlack50,
                              ),
                            ),
                        ],
                      ),
                    TextSpan(
                      text: '等${controller.alreadyPickCollections.length}個集錦囉',
                      style: const TextStyle(
                        fontSize: 14,
                        color: readrBlack50,
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: readrBlack87,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '等${controller.alreadyPickCollections.length}個集錦囉',
                          style: const TextStyle(
                            fontSize: 14,
                            color: readrBlack50,
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
                                  baseColor:
                                      const Color.fromRGBO(0, 9, 40, 0.15),
                                  highlightColor:
                                      const Color.fromRGBO(0, 9, 40, 0.1),
                                  child: Container(
                                    width: 96,
                                    height: 48,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(),
                            ),
                          )
                        : null,
                    title: Text(
                      controller.notPickCollections[index].title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: readrBlack87,
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
                    color: readrBlack10,
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
