import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/chooseFollow/chooseFollow_cubit.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/memberListItemWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseMemberWidget extends StatefulWidget {
  const ChooseMemberWidget({Key? key}) : super(key: key);

  @override
  State<ChooseMemberWidget> createState() => _ChooseMemberWidgetState();
}

class _ChooseMemberWidgetState extends State<ChooseMemberWidget> {
  late final List<Member> _recommendedMembers;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  _fetchMembers() {
    context.read<ChooseFollowCubit>().fetchRecommendMember();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChooseFollowCubit, ChooseFollowState>(
      builder: (context, state) {
        if (state is ChooseFollowError) {
          final error = state.error;
          print('ChooseMemberError: ${error.message}');

          return ErrorPage(
            error: error,
            onPressed: () => _fetchMembers(),
            hideAppbar: true,
          );
        }

        if (state is MemberListLoaded) {
          if (!_isLoaded) {
            _recommendedMembers = state.recommendedMembers;
            _isLoaded = true;
          }

          return _buildContents(context);
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _buildContents(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: const Text(
            '根據您的喜好，我們推薦您追蹤這些人物',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemBuilder: (context, index) => MemberListItemWidget(
              viewMember: _recommendedMembers[index],
            ),
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(
                color: Colors.black12,
                thickness: 1,
                height: 1,
              ),
            ),
            itemCount: _recommendedMembers.length,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.black12,
                width: 0.5,
              ),
            ),
          ),
          child: ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isFirstTime', false);
              AutoRouter.of(context).pushAndPopUntil(const Initial(),
                  predicate: (route) => false);
            },
            child: const Text(
              '完成',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              primary: Colors.black87,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
