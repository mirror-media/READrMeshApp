class AddToCollectionItem {
  final String? id;
  final String title;
  final String? heroImageUrl;
  final int? collectionpicksCount;

  const AddToCollectionItem({
    this.id,
    required this.title,
    this.heroImageUrl,
    this.collectionpicksCount,
  });

  factory AddToCollectionItem.fromAlreadyPickedCollection(
      Map<String, dynamic> json) {
    return AddToCollectionItem(
      title: json['title'],
    );
  }

  factory AddToCollectionItem.fromNotPickedCollection(
      Map<String, dynamic> json) {
    return AddToCollectionItem(
      id: json['id'],
      title: json['title'],
      heroImageUrl: json['heroImage']['resized']['original'],
      collectionpicksCount: json['collectionpicksCount'],
    );
  }
}
