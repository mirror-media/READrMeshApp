import 'package:json_annotation/json_annotation.dart';

part 'community_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CommunityModel {
  @JsonKey(name: 'timestamp')
  final int timestamp;

  @JsonKey(name: 'stories')
  final List<dynamic> stories;

  @JsonKey(name: 'members')
  final List<dynamic> members;

  CommunityModel({
    required this.timestamp,
    required this.stories,
    required this.members,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) => _$CommunityModelFromJson(json);
  Map<String, dynamic> toJson() => _$CommunityModelToJson(this);
}
