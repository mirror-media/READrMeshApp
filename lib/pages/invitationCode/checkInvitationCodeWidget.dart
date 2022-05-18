import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:readr/blocs/invitationCode/invitationCode_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/invitationCode.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';

class CheckInvitationCodeWidget extends StatelessWidget {
  CheckInvitationCodeWidget({Key? key}) : super(key: key);

  final List<InvitationCode> _usableCodeList = [];
  final List<InvitationCode> _activatedCodeList = [];

  @override
  Widget build(BuildContext context) {
    context.read<InvitationCodeCubit>().fetchMyInvitationCode();
    return BlocBuilder<InvitationCodeCubit, InvitationCodeState>(
      builder: (context, state) {
        if (state is InvitationCodeError) {
          return ErrorPage(
            error: state.error,
            onPressed: () =>
                context.read<InvitationCodeCubit>().fetchMyInvitationCode(),
            hideAppbar: true,
          );
        }

        if (state is InvitationCodeLoaded) {
          _usableCodeList.addAll(state.usableCodeList);
          _activatedCodeList.addAll(state.activatedCodeList);
          return _buildContent(context);
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const ClampingScrollPhysics(),
      children: [
        _buildUsableCodeList(context),
        if (_activatedCodeList.isNotEmpty) _buildActivatedCodeList(context),
      ],
    );
  }

  Widget _buildUsableCodeList(
    BuildContext context,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '可用的邀請碼',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: readrBlack87,
          ),
        ),
        const SizedBox(height: 12),
        if (_usableCodeList.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Text(
              '目前沒有可用的邀請碼...',
              style: TextStyle(
                color: readrBlack66,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                _usableCodeItem(context, _usableCodeList[index]),
            separatorBuilder: (context, index) => const Divider(
              color: readrBlack10,
              height: 1,
            ),
            itemCount: _usableCodeList.length,
          ),
        ),
      ],
    );
  }

  Widget _usableCodeItem(BuildContext context, InvitationCode invitationCode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            invitationCode.code,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: readrBlack87,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: invitationCode.code));
              showCopiedToast(context);
            },
            icon: const FaIcon(
              FontAwesomeIcons.link,
              size: 11,
              color: readrBlack87,
            ),
            label: const Text(
              '複製邀請碼',
              style: TextStyle(
                color: readrBlack87,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
            style: OutlinedButton.styleFrom(
              primary: readrBlack87,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              side: const BorderSide(color: readrBlack87),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActivatedCodeList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '已使用',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: readrBlack87,
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                _activatedCodeItem(context, _activatedCodeList[index]),
            separatorBuilder: (context, index) => const Divider(
              color: readrBlack10,
              height: 1,
            ),
            itemCount: _activatedCodeList.length,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _activatedCodeItem(
      BuildContext context, InvitationCode invitationCode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Text(
            invitationCode.code,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: readrBlack30,
            ),
          ),
          const SizedBox(width: 20),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Get.to(() =>
                  PersonalFilePage(viewMember: invitationCode.activeMember!));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  invitationCode.activeMember!.nickname,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: readrBlack87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 8),
                ProfilePhotoWidget(invitationCode.activeMember!, 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showCopiedToast(BuildContext context) {
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
              '已複製邀請碼',
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
  }
}
