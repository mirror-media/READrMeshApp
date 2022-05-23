import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/pages/home/recommendFollow/recommendFollowItem.dart';

class RecommendFollowPage extends StatelessWidget {
  final List<FollowableItem> recommendedItems;
  const RecommendFollowPage(this.recommendedItems);

  @override
  Widget build(BuildContext context) {
    List<FollowableItem> recommendedItemList = [];
    recommendedItemList.addAll(recommendedItems);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: readrBlack87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '推薦追蹤',
          style: TextStyle(
            color: readrBlack,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeLoaded && recommendedItems.isNotEmpty) {
              if (recommendedItems[0].type == FollowableItemType.member &&
                  state.recommendedMembers.isEmpty) {
                Navigator.pop(context);
              } else if (recommendedItems[0].type ==
                      FollowableItemType.publisher &&
                  state.recommendedPublishers.isEmpty) {
                Navigator.pop(context);
              }
            }
          },
          builder: (context, state) {
            if (state is HomeLoaded && recommendedItems.isNotEmpty) {
              if (recommendedItems[0].type == FollowableItemType.member) {
                recommendedItemList = [];
                recommendedItemList.addAll(state.recommendedMembers);
              } else if (recommendedItems[0].type ==
                  FollowableItemType.publisher) {
                recommendedItemList = [];
                recommendedItemList.addAll(state.recommendedPublishers);
              }
            }

            int itemLength = recommendedItemList.length;
            if (itemLength > 20) itemLength = 20;

            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.73,
              ),
              itemBuilder: (context, index) =>
                  RecommendFollowItem(recommendedItemList[index]),
              itemCount: itemLength,
            );
          },
        ),
      ),
    );
  }
}
