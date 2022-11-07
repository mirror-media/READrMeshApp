import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/collection/createAndEdit/chooseStoryPage.dart';
import 'package:readr/pages/collection/shared/collectionHeader.dart';

class CollectionEmptyWidget extends StatelessWidget {
  final Collection collection;
  const CollectionEmptyWidget(this.collection);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: CollectionHeader(collection),
              ),
            ];
          },
          body: ListView(
            children: [
              const SizedBox(
                height: 40,
              ),
              Obx(
                () {
                  if (Get.find<UserService>().isMember.isTrue &&
                      collection.creator.memberId ==
                          Get.find<UserService>().currentUser.memberId) {
                    return Column(
                      children: [
                        Text(
                          'myCollectionEmptyTitle'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .extension<CustomColors>()
                                ?.primaryLv4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        if (Get.find<UserService>().currentUser.pickCount !=
                                null &&
                            Get.find<UserService>().currentUser.bookmarkCount !=
                                null &&
                            (Get.find<UserService>().currentUser.pickCount! +
                                    Get.find<UserService>()
                                        .currentUser
                                        .bookmarkCount! >
                                0))
                          ElevatedButton(
                            onPressed: () => Get.to(() => ChooseStoryPage(
                                  isAddToEmpty: true,
                                  collection: collection,
                                )),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Theme.of(context)
                                  .extension<CustomColors>()
                                  ?.primary700,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            child: Text(
                              'myCollectionEmptyButtonText'.tr,
                              style: TextStyle(
                                color: Theme.of(context).backgroundColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                      ],
                    );
                  }

                  return Text(
                    'viewCollectionEmpty'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primaryLv4,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ],
          )),
    );
  }
}
