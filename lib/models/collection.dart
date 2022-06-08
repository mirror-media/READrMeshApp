import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/models/member.dart';

class Collection {
  final String id;
  String title;
  final String slug;
  final Member creator;
  CollectionFormat format;
  CollectionPublic public;
  List<CollectionStory>? collectionPicks;
  final String controllerTag;
  String ogImageUrl;
  final DateTime publishedTime;

  Collection({
    required this.id,
    required this.title,
    required this.slug,
    required this.creator,
    required this.controllerTag,
    required this.ogImageUrl,
    required this.publishedTime,
    this.format = CollectionFormat.folder,
    this.public = CollectionPublic.public,
    this.collectionPicks,
  });
}
