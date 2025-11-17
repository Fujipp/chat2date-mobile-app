import 'package:chat2date/models/interest.dart';
import 'package:chat2date/models/lifestyle.dart';
import 'package:chat2date/models/tag.dart';
import 'package:chat2date/models/travelstyle.dart';

class PreferenceDto {
  final List<Travelstyle> travelStyles;
  final List<Lifestyle> lifeStyles;
  final List<Interest> interests;
  final List<Tag> tags;

  PreferenceDto({
    required this.travelStyles,
    required this.lifeStyles,
    required this.interests,
    required this.tags
  });

  factory PreferenceDto.fromJson(Map<String, dynamic> json) {
    return PreferenceDto(
      tags: (json['tags'] as List).map((x) => Tag.fromJson(x)).toList(),
      travelStyles:
          (json['travelStyles'] as List).map((x) => Travelstyle.fromJson(x)).toList(),
      lifeStyles:
          (json['lifeStyles'] as List).map((x) => Lifestyle.fromJson(x)).toList(),
      interests:
          (json['interests'] as List).map((x) => Interest.fromJson(x)).toList(),
    );
  }
}