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
    int itemLength = recommendedItems.length;
    if (itemLength > 20) itemLength = 20;
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
        child: BlocProvider(
          create: (context) => HomeBloc(),
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.74,
            ),
            itemBuilder: (context, index) =>
                RecommendFollowItem(recommendedItems[index]),
            itemCount: itemLength,
          ),
        ),
      ),
    );
  }
}
