import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsListItemList.dart';
import 'package:readr/pages/home/newsInfo.dart';
import 'package:readr/pages/shared/headShotStack.dart';
import 'package:readr/pages/shared/headShotWidget.dart';

class FollowingBlock extends StatelessWidget {
  final NewsListItemList newsHaveCommentsOrPicks;
  const FollowingBlock(this.newsHaveCommentsOrPicks);

  @override
  Widget build(BuildContext context) {
    if (newsHaveCommentsOrPicks.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            '快去追蹤些人吧!',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        color: homeScreenBackgroundColor,
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          itemBuilder: (context, index) =>
              _followingItem(context, newsHaveCommentsOrPicks[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 8.5),
          itemCount: newsHaveCommentsOrPicks.length,
        ),
      ),
    );
  }

  Widget _followingItem(BuildContext context, NewsListItem item) {
    return InkWell(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            _pickBar(item.followingPickMembers),
            CachedNetworkImage(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width / (16 / 9),
              imageUrl: item.heroImageUrl,
              placeholder: (context, url) => Container(
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey,
                child: const Icon(Icons.error),
              ),
              fit: BoxFit.cover,
            ),
            if (item.source != null)
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
                child: Text(
                  item.source!.title,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 4, left: 20, right: 20, bottom: 8),
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              child: NewsInfo(item),
            ),
            if (item.followingComments.isNotEmpty) ...[
              const Divider(
                indent: 20,
                endIndent: 20,
                color: Colors.black12,
                height: 1,
                thickness: 1,
              ),
              _commentsWidget(item.followingComments),
            ]
          ],
        ),
      ),
      onTap: () {},
    );
  }

  Widget _pickBar(List<Member> members) {
    if (members.isEmpty) {
      return Container();
    }
    List<Member> firstTwoMember = [];
    for (int i = 0; i < members.length && i < 2; i++) {
      firstTwoMember.add(members[i]);
    }

    Widget text;
    if (firstTwoMember.length == 1) {
      text = RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: firstTwoMember[0].nickname,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          children: const [
            TextSpan(
              text: '精選了這篇',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            )
          ],
        ),
      );
    } else {
      text = RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: firstTwoMember[0].nickname,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          children: [
            const TextSpan(
              text: '及',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            TextSpan(
              text: firstTwoMember[1].nickname,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            const TextSpan(
              text: '都精選了這篇',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            )
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          HeadShotStack(firstTwoMember, 28),
          text,
        ],
      ),
    );
  }

  Widget _commentsWidget(List<Comment> comments) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, right: 20, left: 20),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        bool hasEmail = false;
        if (comments[index].member.email != null &&
            comments[index].member.email!.contains('@')) {
          hasEmail = true;
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeadShotWidget(
              comments[index].member.nickname,
              44,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  Text(
                    comments[index].member.nickname,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hasEmail)
                    Text(
                      '@${comments[index].member.email!.split('@')[0]}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  const SizedBox(height: 8.5),
                  Text(
                    comments[index].content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
      itemCount: comments.length,
    );
  }
}
