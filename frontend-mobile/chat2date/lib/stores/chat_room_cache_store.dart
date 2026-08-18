import 'package:chat2date/models/chat_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatRoomCacheEntry {
  const ChatRoomCacheEntry({
    required this.roomId,
    this.messages = const [],
    this.partnerName,
    this.partnerImages = const [],
    this.relationshipScore,
    this.isChatDisabled = false,
    this.lastUpdated,
  });

  final String roomId;
  final List<ChatMessage> messages;
  final String? partnerName;
  final List<String> partnerImages;
  final int? relationshipScore;
  final bool isChatDisabled;
  final DateTime? lastUpdated;

  ChatRoomCacheEntry copyWith({
    List<ChatMessage>? messages,
    String? partnerName,
    List<String>? partnerImages,
    int? relationshipScore,
    bool? isChatDisabled,
    DateTime? lastUpdated,
  }) {
    return ChatRoomCacheEntry(
      roomId: roomId,
      messages: messages ?? this.messages,
      partnerName: partnerName ?? this.partnerName,
      partnerImages: partnerImages ?? this.partnerImages,
      relationshipScore: relationshipScore ?? this.relationshipScore,
      isChatDisabled: isChatDisabled ?? this.isChatDisabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class ChatRoomCacheNotifier
    extends StateNotifier<Map<String, ChatRoomCacheEntry>> {
  ChatRoomCacheNotifier() : super(const {});

  ChatRoomCacheEntry? getByRoomId(String roomId) => state[roomId];

  void setRoom(ChatRoomCacheEntry entry) {
    state = {
      ...state,
      entry.roomId: entry.copyWith(lastUpdated: DateTime.now()),
    };
  }
}

final chatRoomCacheProvider =
    StateNotifierProvider<ChatRoomCacheNotifier, Map<String, ChatRoomCacheEntry>>(
      (ref) => ChatRoomCacheNotifier(),
    );
