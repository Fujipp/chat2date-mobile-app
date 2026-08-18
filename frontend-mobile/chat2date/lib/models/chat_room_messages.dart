import 'package:chat2date/models/chat_message.dart';

class ChatRoomMessages {
  final String roomId;
  final bool isRead;
  final bool isChatDisabled; // NEW: true if report exists between users
  final String? partnerName;
  final List<String> partnerImages;
  final Map<String, dynamic> partnerProfile;
  final double? partnerDistance;
  final int? relationshipScore;
  final List<ChatMessage> messages;

  const ChatRoomMessages({
    required this.roomId,
    required this.isRead,
    required this.isChatDisabled,
    required this.partnerName,
    required this.partnerImages,
    required this.partnerProfile,
    required this.partnerDistance,
    required this.relationshipScore,
    required this.messages,
  });

  factory ChatRoomMessages.fromJson({
    required Map<String, dynamic> json,
    required String currentUserId,
  }) {
    final room = (json['room'] as Map<String, dynamic>?) ?? {};
    final isRead = room['isRead'] == true;
    final isChatDisabled = room['isChatDisabled'] == true;
    final roomId = room['roomId']?.toString() ?? '';

    final partner = (json['partner'] as Map<String, dynamic>?) ?? {};
    final partnerProfile = <String, dynamic>{
      ...partner,
      ..._mapFromAny(json['partnerProfile']),
      ..._mapFromAny(room['partnerProfile']),
    };
    final partnerName = partner['senderName']?.toString();
    final partnerImages =
        (partner['senderImage'] as List<dynamic>?)
            ?.map((image) => image.toString())
            .toList() ??
        <String>[];
    final partnerDistance = _doubleFromAny(
      json['matchedDistance'] ??
          json['distance'] ??
          room['matchedDistance'] ??
          room['distance'] ??
          partner['matchedDistance'] ??
          partner['distance'],
    );

    final chatList = (json['chat'] as List<dynamic>?) ?? [];
    final messages = chatList
        .map(
          (item) => ChatMessage.fromApi(
            json: (item as Map<String, dynamic>?) ?? {},
            currentUserId: currentUserId,
          ),
        )
        .toList();

    return ChatRoomMessages(
      roomId: roomId,
      isRead: isRead,
      isChatDisabled: isChatDisabled,
      partnerName: partnerName,
      partnerImages: partnerImages,
      partnerProfile: partnerProfile,
      partnerDistance: partnerDistance,
      relationshipScore: json['relationshipScore'] as int?,
      messages: messages,
    );
  }

  static double? _doubleFromAny(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static Map<String, dynamic> _mapFromAny(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
    }
    return const {};
  }
}
