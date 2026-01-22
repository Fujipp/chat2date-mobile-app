class ChatAccessStatus {
  final String roomId;
  final List<ChatAccessMember> roomMember;

  const ChatAccessStatus({
    required this.roomId,
    required this.roomMember,
  });

  factory ChatAccessStatus.fromJson(Map<String, dynamic> json) {
    final members = (json['roomMember'] as List<dynamic>?)
            ?.map(
              (member) => ChatAccessMember.fromJson(
                member as Map<String, dynamic>,
              ),
            )
            .toList() ??
        <ChatAccessMember>[];
    return ChatAccessStatus(
      roomId: json['roomId']?.toString() ?? '',
      roomMember: members,
    );
  }
}

class ChatAccessMember {
  final String userId;
  final String type;

  const ChatAccessMember({
    required this.userId,
    required this.type,
  });

  factory ChatAccessMember.fromJson(Map<String, dynamic> json) {
    return ChatAccessMember(
      userId: json['userId']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}
