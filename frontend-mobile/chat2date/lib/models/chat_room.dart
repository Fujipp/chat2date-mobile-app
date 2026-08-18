import 'package:chat2date/core/utils/backend_datetime_parser.dart';

/// Model สำหรับข้อมูลห้องแชท
/// ใช้กับ GET /api/v1/chats/rooms
class ChatRoom {
  final String roomId;
  final String partnerId;
  final String partnerName;
  final String? partnerImage;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final String type; // "new" or "old"

  ChatRoom({
    required this.roomId,
    required this.partnerId,
    required this.partnerName,
    this.partnerImage,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.type = 'old',
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      roomId: json['roomId'] ?? '',
      partnerId: json['partnerId'] ?? '',
      partnerName: json['partnerName'] ?? '',
      partnerImage: json['partnerImage'],
      lastMessage: json['lastMessage'],
      lastMessageTime: parseBackendDateTime(
        json['lastMessageTime']?.toString(),
      ),
      unreadCount: json['unreadCount'] ?? 0,
      type: json['type'] ?? 'old',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'partnerImage': partnerImage,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'type': type,
    };
  }

  ChatRoom copyWith({
    String? roomId,
    String? partnerId,
    String? partnerName,
    String? partnerImage,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    String? type,
  }) {
    return ChatRoom(
      roomId: roomId ?? this.roomId,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      partnerImage: partnerImage ?? this.partnerImage,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      type: type ?? this.type,
    );
  }
}
