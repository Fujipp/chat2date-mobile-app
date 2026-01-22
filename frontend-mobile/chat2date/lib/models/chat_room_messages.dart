import 'package:chat2date/models/chat_message.dart';

class ChatRoomMessages {
  final String roomId;
  final bool isRead;
  final String? partnerName;
  final List<String> partnerImages;
  final int? relationshipScore;
  final List<ChatMessage> messages;

  const ChatRoomMessages({
    required this.roomId,
    required this.isRead,
    required this.partnerName,
    required this.partnerImages,
    required this.relationshipScore,
    required this.messages,
  });

  factory ChatRoomMessages.fromJson({
    required Map<String, dynamic> json,
    required String currentUserId,
  }) {
    final room = (json['room'] as Map<String, dynamic>?) ?? {};
    final isRead = room['isRead'] == true;
    final roomId = room['roomId']?.toString() ?? '';

    final partner = (json['partner'] as Map<String, dynamic>?) ?? {};
    final partnerName = partner['senderName']?.toString();
    final partnerImages = (partner['senderImage'] as List<dynamic>?)
            ?.map((image) => image.toString())
            .toList() ??
        <String>[];

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
      partnerName: partnerName,
      partnerImages: partnerImages,
      relationshipScore: json['relationshipScore'] as int?,
      messages: messages,
    );
  }
}
