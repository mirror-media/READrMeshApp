import 'package:get/get.dart';
import 'package:readr/models/followableItem.dart';

abstract class RecommendItemController extends GetxController {
  RxList<FollowableItem> get recommendItems;
  FollowableItemType get itemType;
}
