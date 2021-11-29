import 'package:app_settings/app_settings.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readr/blocs/memberCenter/cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/member.dart';

class MemberCenterWidget extends StatefulWidget {
  @override
  _MemberCenterWidgetState createState() => _MemberCenterWidgetState();
}

class _MemberCenterWidgetState extends State<MemberCenterWidget> {
  bool _isLogin = false;
  String _versionAndBuildNumber = '';
  Member? member;

  @override
  void initState() {
    _loadMemberAndInfo();
    super.initState();
  }

  _loadMemberAndInfo() {
    context.read<MemberCenterCubit>().fetchMemberAndInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 246, 251, 1),
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        title: const Text(
          '會員中心',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<MemberCenterCubit, MemberCenterState>(
      builder: (context, state) {
        if (state is MemberCenterError) {
          final error = state.error;
          print('MemberCenterError: ${error.message}');
          _loadMemberAndInfo();
        }

        if (state is MemberCenterLoaded) {
          _versionAndBuildNumber = 'v${state.version} (${state.buildNumber})';
          member = state.member;
          if (member != null) {
            _isLogin = true;
          } else {
            _isLogin = false;
          }
        }

        return ListView(
          physics: MediaQuery.of(context).orientation == Orientation.portrait
              ? const NeverScrollableScrollPhysics()
              : null,
          children: [
            _memberTile(),
            const SizedBox(
              height: 12,
            ),
            _settingTile(),
            const SizedBox(
              height: 12,
            ),
            if (_isLogin) _accountTile(),
          ],
        );
      },
    );
  }

  Widget _memberTile() {
    Widget memberTileContent;
    double height;
    if (_isLogin) {
      height = 98;
      memberTileContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '會員',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
          const SizedBox(
            height: 4.5,
          ),
          Text(
            member!.email,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      );
    } else {
      height = 75;
      memberTileContent = InkWell(
        onTap: () async {
          bool? isLogin = await context.pushRoute(const LoginRoute());
          if (isLogin != null && isLogin) {
            _loadMemberAndInfo();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '註冊 / 登入會員',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_outlined,
              color: Colors.black54,
              size: 16,
            ),
          ],
        ),
      );
    }
    return Container(
      height: height,
      color: hightLightColor,
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(left: 12, right: 22),
        child: memberTileContent,
      ),
    );
  }

  Widget _settingTile() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _settingButton(
              text: '推播通知',
              onPressed: () => AppSettings.openNotificationSettings()),
          const Divider(
            color: Colors.black45,
            height: 1,
          ),
          _settingButton(
              text: '關於',
              onPressed: () => AutoRouter.of(context).push(const AboutRoute())),
          const Divider(
            color: Colors.black45,
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
                  _versionAndBuildNumber,
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

  Widget _settingButton({required String text, void Function()? onPressed}) {
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

  Widget _accountTile() {
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
            onTap: () {
              _loadMemberAndInfo();
            },
          ),
          const Divider(
            color: Colors.black45,
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
            onTap: () async {
              bool? isDeleted =
                  await context.pushRoute(DeleteMemberRoute(member: member!));
              if (isDeleted != null && isDeleted) {
                _loadMemberAndInfo();
              }
            },
          ),
        ],
      ),
    );
  }
}
