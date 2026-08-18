import 'package:chat2date/models/chat_room.dart';
import 'package:chat2date/models/match.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatListCacheState {
  const ChatListCacheState({
    this.chatRooms = const [],
    this.matches = const [],
    this.lastUpdated,
  });

  final List<ChatRoom> chatRooms;
  final List<Match> matches;
  final DateTime? lastUpdated;

  ChatListCacheState copyWith({
    List<ChatRoom>? chatRooms,
    List<Match>? matches,
    DateTime? lastUpdated,
  }) {
    return ChatListCacheState(
      chatRooms: chatRooms ?? this.chatRooms,
      matches: matches ?? this.matches,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class ChatListCacheNotifier extends StateNotifier<ChatListCacheState> {
  ChatListCacheNotifier() : super(const ChatListCacheState());

  void setChatRooms(List<ChatRoom> chatRooms) {
    state = state.copyWith(
      chatRooms: List<ChatRoom>.from(chatRooms),
      lastUpdated: DateTime.now(),
    );
  }

  void setMatches(List<Match> matches) {
    state = state.copyWith(
      matches: List<Match>.from(matches),
      lastUpdated: DateTime.now(),
    );
  }

  void setAll({
    required List<ChatRoom> chatRooms,
    required List<Match> matches,
  }) {
    state = ChatListCacheState(
      chatRooms: List<ChatRoom>.from(chatRooms),
      matches: List<Match>.from(matches),
      lastUpdated: DateTime.now(),
    );
  }
}

final chatListCacheProvider =
    StateNotifierProvider<ChatListCacheNotifier, ChatListCacheState>(
      (ref) => ChatListCacheNotifier(),
    );
