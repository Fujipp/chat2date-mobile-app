import 'package:chat2date/models/dto/place_dto.dart';

class DateRecommendationResponse {
  final String roomId;
  final String mode;
  final String leaderId;
  final int winningIndex;
  final List<PlaceDTO> places;

  DateRecommendationResponse({
    required this.roomId,
    required this.mode,
    required this.leaderId,
    required this.winningIndex,
    required this.places,
  });

  factory DateRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return DateRecommendationResponse(
      roomId: json['roomId'] ?? '',
      mode: json['mode'] ?? '',
      leaderId: json['leaderId'] ?? '',
      winningIndex: json['winningIndex'] ?? 0,
      places: (json['places'] as List)
          .map((p) => PlaceDTO.fromJson(p))
          .toList(),
    );
  }
}