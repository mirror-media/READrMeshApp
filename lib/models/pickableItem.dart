import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsStoryItem.dart';

abstract class PickableItem {
  final String targetId;
  final List<Member> pickedMemberList;
  final PickObjective objective;
  final bool isPicked;
  final int pickCount;
  final List<Comment> allComments;
  final List<Comment> popularComments;
  final String title;
  final String author;
  final int commentCount;
  PickableItem({
    required this.targetId,
    required this.pickedMemberList,
    required this.isPicked,
    required this.pickCount,
    required this.objective,
    required this.allComments,
    required this.popularComments,
    required this.title,
    required this.author,
    required this.commentCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PickableItem &&
          objective == other.objective &&
          targetId == other.targetId;

  @override
  int get hashCode => objective.hashCode ^ targetId.hashCode;
}

class NewsStoryItemPick implements PickableItem {
  final NewsStoryItem newsStoryItem;
  NewsStoryItemPick(this.newsStoryItem);

  @override
  String get targetId => newsStoryItem.id;

  @override
  PickObjective get objective => PickObjective.story;

  @override
  bool get isPicked => UserHelper.instance.isNewsPicked(targetId);

  @override
  int get pickCount {
    if (isPicked) {
      return UserHelper.instance.getNewsPickedItem(targetId)!.pickCount;
    } else if (newsStoryItem.myPickId != null) {
      return newsStoryItem.pickCount - 1;
    }
    return newsStoryItem.pickCount;
  }

  @override
  List<Member> get pickedMemberList {
    List<Member> list = [];
    list.addAll(newsStoryItem.followingPickMembers);
    list.addAll(newsStoryItem.otherPickMembers);
    return list;
  }

  @override
  List<Comment> get allComments => newsStoryItem.allComments;

  @override
  List<Comment> get popularComments => newsStoryItem.popularComments;

  @override
  String get title => newsStoryItem.title;

  @override
  String get author => newsStoryItem.source.title;

  @override
  int get commentCount => newsStoryItem.allComments.length;
}

class NewsListItemPick implements PickableItem {
  final NewsListItem newsListItem;
  NewsListItemPick(this.newsListItem);

  @override
  String get targetId => newsListItem.id;

  @override
  PickObjective get objective => PickObjective.story;

  @override
  bool get isPicked => UserHelper.instance.isNewsPicked(targetId);

  @override
  int get pickCount {
    if (isPicked) {
      return UserHelper.instance.getNewsPickedItem(targetId)!.pickCount;
    } else if (newsListItem.myPickId != null) {
      return newsListItem.pickCount - 1;
    }
    return newsListItem.pickCount;
  }

  @override
  List<Member> get pickedMemberList {
    List<Member> list = [];
    list.addAll(newsListItem.followingPickMembers);
    list.addAll(newsListItem.otherPickMembers);
    return list;
  }

  @override
  List<Comment> get allComments => [];

  @override
  List<Comment> get popularComments => [];

  @override
  String get title => newsListItem.title;

  @override
  String get author => newsListItem.source.title;

  @override
  int get commentCount => newsListItem.commentCount;
}
