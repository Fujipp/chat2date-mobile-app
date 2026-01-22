/// Model สำหรับข้อมูลห้องแชท
/// ใช้กับ GET /api/v1/chats/rooms
class ChatRoom {
  final String roomId;
  final String partnerId;
  final String partnerName;
  final String? partnerImage;
  final String? lastMessage;
  final int unreadCount;
  final String type; // "new" or "old"

  ChatRoom({
    required this.roomId,
    required this.partnerId,
    required this.partnerName,
    this.partnerImage,
    this.lastMessage,
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
      'unreadCount': unreadCount,
      'type': type,
    };
  }
}
