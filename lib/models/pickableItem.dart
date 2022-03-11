import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsStoryItem.dart';

abstract class PickableItem {
  final String targetId;
  final List<Member> pickedMemberList;
  final PickObjective objective;
  final bool isPicked;
  final int pickCount;
  final int commentCount;
  PickableItem({
    required this.targetId,
    required this.pickedMemberList,
    required this.isPicked,
    required this.pickCount,
    required this.commentCount,
    required this.objective,
  });
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
  int get commentCount {
    if (isPicked) {
      return UserHelper.instance.getNewsPickedItem(targetId)!.commentCount;
    } else if (newsStoryItem.myPickCommentId != null) {
      return newsStoryItem.allComments.length - 1;
    }
    return newsStoryItem.allComments.length;
  }

  @override
  List<Member> get pickedMemberList {
    List<Member> list = [];
    list.addAll(newsStoryItem.followingPickMembers);
    list.addAll(newsStoryItem.otherPickMembers);
    return list;
  }
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
  int get commentCount {
    if (isPicked) {
      return UserHelper.instance.getNewsPickedItem(targetId)!.commentCount;
    } else if (newsListItem.myPickCommentId != null) {
      return newsListItem.commentCount - 1;
    }
    return newsListItem.commentCount;
  }

  @override
  List<Member> get pickedMemberList {
    List<Member> list = [];
    list.addAll(newsListItem.followingPickMembers);
    list.addAll(newsListItem.otherPickMembers);
    return list;
  }
}
