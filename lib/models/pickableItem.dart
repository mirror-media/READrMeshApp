import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/services/pickService.dart';

abstract class PickableItem {
  final String targetId;
  final String type;
  final String? pickId;
  final String? pickCommentId;
  final List<Member> pickedMemberList;
  final int pickCount;
  PickableItem(
    this.targetId,
    this.type,
    this.pickId,
    this.pickCommentId,
    this.pickedMemberList,
    this.pickCount,
  );

  Future<String?> createPick();
  Future<Map<String, dynamic>?> createPickAndComment(String comment);
  Future<bool> deletePick();
  void updateId(String? pickId, String? pickCommentId);
}

class NewsStoryItemPick implements PickableItem {
  final NewsStoryItem newsStoryItem;
  NewsStoryItemPick(this.newsStoryItem);

  final PickService _pickService = PickService();

  @override
  String get type => 'story';

  @override
  List<Member> get pickedMemberList {
    List<Member> memberList = [];
    memberList.addAll(newsStoryItem.followingPickMembers);
    memberList.addAll(newsStoryItem.otherPickMembers);
    return memberList;
  }

  @override
  String get targetId => newsStoryItem.id;

  @override
  String? get pickId => newsStoryItem.myPickId;

  @override
  Future<String?> createPick() async {
    newsStoryItem.myPickId = await _pickService.createPick(
      targetId: targetId,
      objective: PickObjective.story,
      state: PickState.public,
      kind: PickKind.read,
    );
    if (newsStoryItem.myPickId != null) {
      newsStoryItem.pickCount++;
    }
    return pickId;
  }

  @override
  Future<Map<String, dynamic>?> createPickAndComment(String comment) async {
    var result = await _pickService.createPickAndComment(
      targetId: targetId,
      objective: PickObjective.story,
      state: PickState.public,
      kind: PickKind.read,
      commentContent: comment,
    );
    if (result != null) {
      newsStoryItem.myPickId = result['pickId'];
      newsStoryItem.myPickCommentId = result['pickComment'].id;
      newsStoryItem.pickCount++;
    }
    return result;
  }

  @override
  Future<bool> deletePick() async {
    if (pickId == null) return false;
    if (await _pickService.deletePick(pickId!)) {
      newsStoryItem.myPickId = null;
      return true;
    }
    return false;
  }

  @override
  String? get pickCommentId => newsStoryItem.myPickCommentId;

  @override
  int get pickCount => newsStoryItem.pickCount;

  @override
  void updateId(String? pickId, String? pickCommentId) {
    newsStoryItem.myPickId = pickId;
    newsStoryItem.myPickCommentId = pickCommentId;
  }
}

class NewsListItemPick implements PickableItem {
  final NewsListItem newsListItem;
  NewsListItemPick(this.newsListItem);

  final PickService _pickService = PickService();

  @override
  String get type => 'story';

  @override
  List<Member> get pickedMemberList {
    List<Member> memberList = [];
    memberList.addAll(newsListItem.followingPickMembers);
    memberList.addAll(newsListItem.otherPickMembers);
    return memberList;
  }

  @override
  String get targetId => newsListItem.id;

  @override
  String? get pickId => newsListItem.myPickId;

  @override
  Future<String?> createPick() async {
    newsListItem.myPickId = await _pickService.createPick(
      targetId: targetId,
      objective: PickObjective.story,
      state: PickState.public,
      kind: PickKind.read,
    );
    if (newsListItem.myPickId != null) {
      newsListItem.pickCount++;
    }
    return pickId;
  }

  @override
  Future<Map<String, dynamic>?> createPickAndComment(String comment) async {
    var result = await _pickService.createPickAndComment(
      targetId: targetId,
      objective: PickObjective.story,
      state: PickState.public,
      kind: PickKind.read,
      commentContent: comment,
    );
    if (result != null) {
      newsListItem.myPickId = result['pickId'];
      newsListItem.myPickCommentId = result['pickComment'].id;
      newsListItem.pickCount++;
    }
    return result;
  }

  @override
  Future<bool> deletePick() async {
    if (pickId == null) return false;
    if (await _pickService.deletePick(pickId!)) {
      newsListItem.myPickId = null;
      newsListItem.pickCount--;
      return true;
    }
    return false;
  }

  @override
  String? get pickCommentId => newsListItem.myPickCommentId;

  @override
  int get pickCount => newsListItem.pickCount;

  @override
  void updateId(String? pickId, String? pickCommentId) {
    newsListItem.myPickId = pickId;
    newsListItem.myPickCommentId = pickCommentId;
  }
}
