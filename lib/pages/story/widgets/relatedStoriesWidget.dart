import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/shared/news/newsListItemWidget.dart';

class RelatedStoriesWidget extends StatelessWidget {
  final List<NewsListItem> relatedStories;
  const RelatedStoriesWidget(this.relatedStories, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (relatedStories.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'relatedNews'.tr,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 20),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => NewsListItemWidget(
              relatedStories[index],
              hidePublisher: true,
              pushReplacement: true,
              key: Key(relatedStories[index].id),
            ),
            separatorBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.only(top: 16, bottom: 20),
                child: Divider(),
              );
            },
            itemCount: relatedStories.length,
          ),
        ],
      ),
    );
  }
}
