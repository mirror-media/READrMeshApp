import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/collection/createAndEdit/chooseStoryPage.dart';
import 'package:readr/pages/collection/shared/collectionHeader.dart';

class CollectionEmptyWidget extends StatelessWidget {
  final Collection collection;
  const CollectionEmptyWidget(this.collection);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: meshGray,
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
                        const Text(
                          '從精選新聞或書籤中\n將數篇新聞打包成集錦',
                          style: TextStyle(
                            fontSize: 16,
                            color: readrBlack30,
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
                              primary: readrBlack87,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            child: const Text(
                              '立即嘗試',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                      ],
                    );
                  }

                  return const Text(
                    '這個集錦還沒有新聞',
                    style: TextStyle(
                      fontSize: 16,
                      color: readrBlack30,
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
