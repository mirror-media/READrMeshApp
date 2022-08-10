import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collectionPick.dart';

class AddToCollectionItem {
  final String? id;
  final String title;
  final String? heroImageUrl;
  final List<CollectionPick>? collectionPicks;
  final CollectionFormat format;

  const AddToCollectionItem({
    this.id,
    required this.title,
    this.heroImageUrl,
    this.collectionPicks,
    this.format = CollectionFormat.folder,
  });

  factory AddToCollectionItem.fromAlreadyPickedCollection(
      Map<String, dynamic> json) {
    return AddToCollectionItem(
      title: json['title'],
    );
  }

  factory AddToCollectionItem.fromNotPickedCollection(
      Map<String, dynamic> json) {
    CollectionFormat format = CollectionFormat.folder;
    if (json['format'] == 'timeline') {
      format = CollectionFormat.timeline;
    }

    List<CollectionPick> collectionPicks = [];
    for (var item in json['collectionpicks']) {
      collectionPicks.add(CollectionPick.fromAddToCollection(item));
    }

    return AddToCollectionItem(
      id: json['id'],
      title: json['title'],
      heroImageUrl: json['heroImage']['resized']['original'],
      format: format,
      collectionPicks: collectionPicks,
    );
  }
}
