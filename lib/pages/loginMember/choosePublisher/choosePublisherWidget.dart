import 'package:auto_route/auto_route.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/chooseFollow/chooseFollow_cubit.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/followButton.dart';
import 'package:readr/pages/shared/publisherLogoWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChoosePublisherWidget extends StatefulWidget {
  const ChoosePublisherWidget({Key? key}) : super(key: key);

  @override
  State<ChoosePublisherWidget> createState() => _ChoosePublisherWidgetState();
}

class _ChoosePublisherWidgetState extends State<ChoosePublisherWidget> {
  int _followingCount = 0;
  late final List<Publisher> _allPublishers;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchPublishers();
  }

  _fetchPublishers() {
    context.read<ChooseFollowCubit>().fetchAllPublishers();
  }

  @override
  Widget build(BuildContext context) {
    String buttonText = '請至少選擇 1 個';
    if (_followingCount != 0 && UserHelper.instance.isVisitor) {
      buttonText = '完成';
    } else if (_followingCount != 0 && UserHelper.instance.isMember) {
      buttonText = '下一步';
    }
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: const Text(
            '請選擇您想追蹤的媒體',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: _buildContent(context),
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
          child: OutlinedButton(
            onPressed: _followingCount == 0
                ? null
                : () async {
                    if (UserHelper.instance.isMember) {
                      AutoRouter.of(context)
                          .push(ChooseMemberRoute(isFromPublisher: true));
                    } else {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isFirstTime', false);
                      AutoRouter.of(context).pushAndPopUntil(const Initial(),
                          predicate: (route) => false);
                    }
                  },
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: 16,
                color: _followingCount == 0 ? Colors.black26 : Colors.white,
              ),
            ),
            style: OutlinedButton.styleFrom(
              elevation: 0,
              backgroundColor: _followingCount == 0
                  ? const Color.fromRGBO(224, 224, 224, 1)
                  : Colors.black87,
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

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<ChooseFollowCubit, ChooseFollowState>(
      builder: (context, state) {
        if (state is ChooseFollowError) {
          final error = state.error;
          print('ChoosePublisherError: ${error.message}');

          return ErrorPage(
            error: error,
            onPressed: () => _fetchPublishers(),
            hideAppbar: true,
          );
        }

        if (state is PublisherListLoaded) {
          if (!_isLoaded) {
            _allPublishers = state.allPublisher;
            _isLoaded = true;
          }
          return _buildList(context);
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemBuilder: (context, index) =>
          _buildItem(context, _allPublishers[index]),
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Divider(
          color: Colors.black12,
          thickness: 1,
          height: 1,
        ),
      ),
      itemCount: _allPublishers.length,
    );
  }

  Widget _buildItem(BuildContext context, Publisher publisher) {
    return Row(
      children: [
        PublisherLogoWidget(publisher),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                publisher.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${publisher.followerCount} 人追蹤',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              )
            ],
          ),
        ),
        FollowButton(
          PublisherFollowableItem(publisher),
          onTap: (isFollow) {
            setState(() {
              if (isFollow) {
                _followingCount++;
                publisher.followerCount++;
              } else {
                _followingCount--;
                publisher.followerCount--;
              }
            });
          },
          whenFailed: (isFollow) {
            setState(() {
              if (isFollow) {
                _followingCount++;
                publisher.followerCount++;
              } else {
                _followingCount--;
                publisher.followerCount--;
              }
            });
          },
        ),
      ],
    );
  }
}
