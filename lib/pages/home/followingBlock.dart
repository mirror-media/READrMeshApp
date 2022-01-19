import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsListItemList.dart';
import 'package:readr/pages/home/newsInfo.dart';
import 'package:readr/pages/shared/headShotStack.dart';
import 'package:readr/pages/shared/headShotWidget.dart';
import 'package:readr/pages/shared/timestamp.dart';

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
          shrinkWrap: true,
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
              InkWell(
                onTap: () {},
                child: _commentsWidget(item.followingComments),
              ),
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

    List<Widget> children = [
      HeadShotStack(firstTwoMember, 14),
      const SizedBox(width: 8),
    ];
    if (firstTwoMember.length == 1) {
      children.add(Flexible(
        child: Text(
          firstTwoMember[0].nickname,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ));
      children.add(const Text(
        '精選了這篇',
        style: TextStyle(fontSize: 14, color: Colors.black54),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ));
    } else {
      children.add(Flexible(
        child: Text(
          firstTwoMember[0].nickname,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ));
      children.add(const Text(
        '及',
        style: TextStyle(fontSize: 14, color: Colors.black54),
        maxLines: 1,
      ));
      children.add(Flexible(
        child: Text(
          firstTwoMember[1].nickname,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ));
      children.add(const Text(
        '都精選了這篇',
        style: TextStyle(fontSize: 14, color: Colors.black54),
        maxLines: 1,
      ));
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: children,
      ),
    );
  }

  Widget _commentsWidget(List<Comment> comments) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, right: 20, left: 20),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeadShotWidget(
              comments[index].member,
              22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          comments[index].member.nickname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 2,
                        margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black26,
                        ),
                      ),
                      Timestamp(comments[index].publishDate),
                    ],
                  ),
                  const SizedBox(height: 8.5),
                  ExtendedText(
                    comments[index].content,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Color.fromRGBO(0, 9, 40, 0.66),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    joinZeroWidthSpace: true,
                    overflowWidget: TextOverflowWidget(
                      position: TextOverflowPosition.end,
                      child: RichText(
                        text: const TextSpan(
                          text: '... ',
                          style: TextStyle(
                            color: Color.fromRGBO(0, 9, 40, 0.66),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(
                              text: '看完整留言',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ),
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
