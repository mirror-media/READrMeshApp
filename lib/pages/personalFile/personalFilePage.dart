import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/analyticsHelper.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/dynamicLinkHelper.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/editPersonalFilePage.dart';
import 'package:readr/pages/personalFile/followerListPage.dart';
import 'package:readr/pages/personalFile/followingListPage.dart';
import 'package:readr/pages/personalFile/personalFileSkeletonScreen.dart';
import 'package:readr/pages/setting/settingPage.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';
import 'package:readr/pages/shared/follow/followButton.dart';
import 'package:readr/services/personalFileService.dart';
import 'package:share_plus/share_plus.dart';
import 'package:validated/validated.dart' as validate;

class PersonalFilePage extends GetView<PersonalFilePageController> {
  final Member viewMember;
  final bool isFromBottomTab;
  late final String controllerTag;
  PersonalFilePage({
    required this.viewMember,
    this.isFromBottomTab = false,
  }) {
    controllerTag = viewMember.memberId;
  }

  @override
  String get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PersonalFilePageController>(tag: controllerTag)) {
      Get.put(
        PersonalFilePageController(
          personalFileRepos: PersonalFileService(),
          viewMember: viewMember,
        ),
        tag: controllerTag,
        permanent:
            controllerTag == Get.find<UserService>().currentUser.memberId,
      );
    } else {
      controller.fetchMemberData();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildBar(context),
      body: Obx(
        () {
          if (controller.isError.isTrue) {
            return ErrorPage(
              error: controller.error,
              onPressed: () => controller.initPage(),
              hideAppbar: true,
            );
          }

          if (controller.isLoading.isFalse) {
            return _buildBody();
          }

          return const PersonalFileSkeletonScreen();
        },
      ),
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: isFromBottomTab
          ? IconButton(
              icon: Icon(
                PlatformIcons(context).gearSolid,
                color: readrBlack,
              ),
              onPressed: () {
                Get.to(() => SettingPage());
              },
            )
          : IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_outlined,
                color: readrBlack87,
              ),
              onPressed: () => Get.back(),
            ),
      title: Obx(
        () {
          String title = '';
          if (Get.find<UserService>().isMember.isFalse && isFromBottomTab) {
            title = '個人檔案';
          } else if (controller.isLoading.isTrue) {
            title = viewMember.customId;
          } else {
            title = controller.viewMemberData.value.customId;
          }
          return Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: readrBlack87,
            ),
          );
        },
      ),
      centerTitle: GetPlatform.isIOS,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Icon(
            PlatformIcons(context).ellipsis,
            color: readrBlack87,
          ),
          onPressed: () async => await _showShareBottomSheet(context),
        ),
      ],
    );
  }

  Future<void> _showShareBottomSheet(BuildContext context) async {
    String shareButtonText = '分享這個個人檔案';
    if (controllerTag == Get.find<UserService>().currentUser.memberId) {
      shareButtonText = '分享我的個人檔案';
    }
    String? result = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('copy'),
            child: const Text(
              '複製個人檔案連結',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('share'),
            child: Text(
              shareButtonText,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop('cancel'),
          child: const Text(
            '取消',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );

    String url = '';
    if (result != null && result != 'cancel') {
      if (controller.isLoading.isTrue) {
        url = await DynamicLinkHelper.createPersonalFileLink(viewMember);
      } else {
        url = await DynamicLinkHelper.createPersonalFileLink(
            controller.viewMemberData.value);
      }
    }

    if (result == 'copy') {
      Clipboard.setData(ClipboardData(text: url));
      showToastWidget(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            color: const Color.fromRGBO(0, 9, 40, 0.66),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.white,
              ),
              SizedBox(
                width: 6.0,
              ),
              Text(
                '已複製連結',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        context: context,
        animation: StyledToastAnimation.slideFromTop,
        reverseAnimation: StyledToastAnimation.slideToTop,
        position: StyledToastPosition.top,
        startOffset: const Offset(0.0, -3.0),
        reverseEndOffset: const Offset(0.0, -3.0),
        duration: const Duration(seconds: 3),
        //Animation duration   animDuration * 2 <= duration
        animDuration: const Duration(milliseconds: 250),
        curve: Curves.linear,
        reverseCurve: Curves.linear,
      );
    } else if (result == 'share') {
      Share.shareWithResult(url).then((value) {
        if (value.status == ShareResultStatus.success) {
          AnalyticsHelper.logShare('member', viewMember.memberId, value.raw);
        }
      });
    }
  }

  Widget _buildBody() {
    return ExtendedNestedScrollView(
      onlyOneScrollInBody: true,
      physics: const AlwaysScrollableScrollPhysics(),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: _memberDataWidget(),
          ),
          const SliverToBoxAdapter(
            child: Divider(
              color: readrBlack10,
              thickness: 0.5,
              height: 0.5,
            ),
          ),
          SliverAppBar(
            pinned: true,
            primary: false,
            elevation: 0,
            toolbarHeight: 8,
            backgroundColor: Colors.white,
            bottom: TabBar(
              indicatorColor: tabBarSelectedColor,
              labelColor: readrBlack87,
              unselectedLabelColor: readrBlack30,
              indicatorWeight: 0.5,
              tabs: controller.tabs,
              controller: controller.tabController,
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: controller.tabController,
        children: controller.tabWidgets,
      ),
    );
  }

  Widget _memberDataWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 32),
      child: Column(
        children: [
          Obx(
            () => ProfilePhotoWidget(
              controller.viewMemberData.value,
              40,
              textSize: 40,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Obx(
                  () => ExtendedText(
                    controller.viewMemberData.value.nickname,
                    maxLines: 1,
                    joinZeroWidthSpace: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: readrBlack87,
                    ),
                  ),
                ),
              ),
              Obx(
                () {
                  if (controller.viewMemberData.value.verified) {
                    return const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.verified,
                        size: 16,
                        color: readrBlack87,
                      ),
                    );
                  }
                  return Container();
                },
              )
            ],
          ),
          const SizedBox(height: 4),
          Obx(
            () {
              if (controller.viewMemberData.value.intro != null &&
                  controller.viewMemberData.value.intro!.isNotEmpty) {
                return _buildIntro(controller.viewMemberData.value.intro!);
              }

              return Container();
            },
          ),
          const SizedBox(height: 12),
          Obx(
            () {
              if (Get.find<UserService>().isMember.isTrue &&
                  controller.viewMemberData.value.memberId ==
                      Get.find<UserService>().currentUser.memberId) {
                return _editProfileButton();
              }

              return FollowButton(
                MemberFollowableItem(controller.viewMemberData.value),
                expanded: true,
                textSize: 16,
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Obx(
                    () => RichText(
                      text: TextSpan(
                        text:
                            _convertNumberToString(controller.pickCount.value),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: readrBlack87,
                        ),
                        children: const [
                          TextSpan(
                            text: '\n精選',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: readrBlack50,
                            ),
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 20,
                child: const VerticalDivider(
                  color: readrBlack10,
                  thickness: 0.5,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => FollowerListPage(
                        viewMember: viewMember,
                      ));
                },
                child: Obx(
                  () => RichText(
                    text: TextSpan(
                      text: _convertNumberToString(
                          controller.followerCount.value),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: readrBlack87,
                      ),
                      children: [
                        const TextSpan(
                          text: '\n粉絲 ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: readrBlack50,
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: SvgPicture.asset(
                            personalFileArrowSvg,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 20,
                child: const VerticalDivider(
                  color: readrBlack10,
                  thickness: 0.5,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => FollowingListPage(
                            viewMember: viewMember,
                          ));
                    },
                    child: Obx(
                      () => RichText(
                        text: TextSpan(
                          text: _convertNumberToString(
                              controller.followingCount.value),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: readrBlack87,
                          ),
                          children: [
                            const TextSpan(
                              text: '\n追蹤中 ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: readrBlack50,
                              ),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: SvgPicture.asset(
                                personalFileArrowSvg,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  String _convertNumberToString(int number) {
    if (number >= 10000) {
      double newNumber = number / 10000;
      return '${newNumber.toStringAsFixed(newNumber.truncateToDouble() == newNumber ? 0 : 1)}萬';
    } else {
      return number.toString();
    }
  }

  Widget _buildIntro(String intro) {
    List<String> introChar = intro.characters.toList();
    return RichText(
      text: TextSpan(
        text: introChar[0],
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: validate.isEmoji(introChar[0]) ? readrBlack : readrBlack50,
        ),
        children: [
          for (int i = 1; i < introChar.length; i++)
            TextSpan(
              text: introChar[i],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color:
                    validate.isEmoji(introChar[i]) ? readrBlack : readrBlack50,
              ),
            )
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _editProfileButton() {
    return OutlinedButton(
      onPressed: () async {
        final needReload = await Get.to(
          () => EditPersonalFilePage(),
          fullscreenDialog: true,
        );

        if (needReload is bool && needReload) {
          controller.fetchMemberData();
        }
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: readrBlack87, width: 1),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      ),
      child: const Text(
        '編輯個人檔案',
        softWrap: true,
        maxLines: 1,
        style: TextStyle(
          fontSize: 16,
          color: readrBlack87,
        ),
      ),
    );
  }
}
