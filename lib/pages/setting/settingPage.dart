import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  final String version;
  final String loginType;
  const SettingPage(this.version, this.loginType, {Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          '設定',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: homeScreenBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(0),
          physics: const ClampingScrollPhysics(),
          children: [
            if (UserHelper.instance.isMember) _userInfo(),
            _settingTile(context),
            if (UserHelper.instance.isMember) _accountTile(context),
          ],
        ),
      ),
    );
  }

  Widget _userInfo() {
    String email = '';
    if (UserHelper.instance.currentUser.email!.contains('[0x0001]')) {
      email = UserHelper.instance.currentUser.nickname;
    } else {
      email = '${UserHelper.instance.currentUser.email}';
    }
    Widget icon = Container();
    if (widget.loginType == 'apple') {
      icon = const FaIcon(
        FontAwesomeIcons.apple,
        size: 18,
        color: Colors.black,
      );
    } else if (widget.loginType == 'facebook') {
      icon = const FaIcon(
        FontAwesomeIcons.facebookSquare,
        size: 18,
        color: Color.fromRGBO(59, 89, 152, 1),
      );
    } else if (widget.loginType == 'google') {
      icon = SvgPicture.asset(
        googleLogoSvg,
        width: 16,
        height: 16,
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            email,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          icon,
        ],
      ),
    );
  }

  Widget _settingTile(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          _settingButton(
            text: '顯示新聞範圍',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              int duration = prefs.getInt('newsCoverage') ?? 24;
              context.pushRoute(SetNewsCoverageRoute(duration: duration));
            },
          ),
          const Divider(
            color: Colors.black12,
            height: 1,
          ),
          _settingButton(
            text: '關於',
            onPressed: () => AutoRouter.of(context).push(const AboutRoute()),
            hideArrow: true,
          ),
          const Divider(
            color: Colors.black12,
            height: 1,
          ),
          SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '版本',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  widget.version,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingButton({
    required String text,
    void Function()? onPressed,
    bool hideArrow = false,
  }) {
    return SizedBox(
      height: 56,
      child: InkWell(
        onTap: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            if (!hideArrow)
              const Icon(
                Icons.arrow_forward_ios_outlined,
                color: Colors.black54,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _accountTile(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            child: Container(
              height: 56,
              alignment: Alignment.centerLeft,
              child: const Text(
                '登出',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              AutoRouter.of(context).pushAndPopUntil(const Initial(),
                  predicate: (route) => false);
            },
          ),
          const Divider(
            color: Colors.black12,
            height: 1,
          ),
          InkWell(
            child: Container(
              height: 56,
              alignment: Alignment.centerLeft,
              child: const Text(
                '刪除帳號',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.red,
                ),
              ),
            ),
            onTap: () {
              context.pushRoute(const DeleteMemberRoute());
            },
          ),
        ],
      ),
    );
  }
}
