import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/services/pickService.dart';

abstract class PickableItem {
  String? pickId;
  PickableItem(this.pickId);

  Future<String?> createPick();
  Future<Map<String, dynamic>?> createPickAndComment(String comment);
  Future<bool> deletePick();
}

class StoryPick implements PickableItem {
  final String storyId;
  String? myPickId;
  StoryPick(this.storyId, this.myPickId);

  String? pickCommentId;
  final PickService _pickService = PickService();

  @override
  String? get pickId => myPickId;

  @override
  Future<String?> createPick() async {
    myPickId = await _pickService.createPick(
      targetId: storyId,
      objective: PickObjective.story,
      state: PickState.public,
      kind: PickKind.read,
    );
    return pickId;
  }

  @override
  Future<Map<String, dynamic>?> createPickAndComment(String comment) async {
    var result = await _pickService.createPickAndComment(
      targetId: storyId,
      objective: PickObjective.story,
      state: PickState.public,
      kind: PickKind.read,
      commentContent: comment,
    );
    if (result != null) {
      myPickId = result['pickId'];
    }
    return result;
  }

  @override
  Future<bool> deletePick() async {
    if (pickId == null) return false;
    if (await _pickService.deletePick(pickId!)) {
      myPickId = null;
      return true;
    }
    return false;
  }

  @override
  set pickId(String? _pickId) {
    myPickId = _pickId;
  }
}
