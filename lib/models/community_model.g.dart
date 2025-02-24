// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunityModel _$CommunityModelFromJson(Map<String, dynamic> json) =>
    CommunityModel(
      timestamp: (json['timestamp'] as num).toInt(),
      stories: json['stories'] as List<dynamic>,
      members: json['members'] as List<dynamic>,
    );

Map<String, dynamic> _$CommunityModelToJson(CommunityModel instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'stories': instance.stories,
      'members': instance.members,
    };
