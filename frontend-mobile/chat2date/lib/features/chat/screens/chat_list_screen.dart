import 'dart:async';

import 'package:chat2date/components/common/app_raw_scrollbar.dart';
import 'package:chat2date/components/design_system/index.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/data_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/main_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/input_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/text_colors.dart';
import 'package:chat2date/features/discovery/screens/main_tabs.dart';
import 'package:chat2date/models/chat_room.dart';
import 'package:chat2date/models/dto/match_event_dto.dart';
import 'package:chat2date/models/match.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/chat_list_socket_service.dart';
import 'package:chat2date/services/chat_service.dart';
import 'package:chat2date/services/match_socket_service.dart';
import 'package:chat2date/stores/chat_list_cache_store.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

enum _ChatListTab { chat, match }

class ChatListScreen extends ConsumerStatefulWidget {
  final bool showBottomNav;

  const ChatListScreen({super.key, this.showBottomNav = true});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 1;
  _ChatListTab _selectedTab = _ChatListTab.chat;
  final Set<String> _viewedMatchIds = {};
  final Set<String> _clearedUnreadRoomIds = {};
  final ScrollController _chatListScrollController = ScrollController();

  List<ChatRoom> _chatRooms = [];
  List<Match> _matches = [];
  bool _isLoadingChats = true;
  bool _isLoadingMatches = true;
  String? _chatError;
  String? _matchError;
  List<Map<String, String>> pendingNotis = [];

  ChatListSocketService? _chatListSocket;
  StreamSubscription<ChatListUpdateEvent>? _chatListSubscription;
  MatchSocketService? _matchSocket;
  StreamSubscription<MatchEventDto>? _matchSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _hydrateFromCache();
    _loadData(silent: _chatRooms.isNotEmpty || _matches.isNotEmpty);
    _initChatListSocket();
    _initMatchSocket();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatListScrollController.dispose();
    _chatListSubscription?.cancel();
    _chatListSocket?.dispose();
    _matchSubscription?.cancel();
    _matchSocket?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadData(silent: true);
    }
  }

  void _hydrateFromCache() {
    final cache = ref.read(chatListCacheProvider);
    if (cache.chatRooms.isEmpty && cache.matches.isEmpty) return;

    setState(() {
      _chatRooms = List<ChatRoom>.from(cache.chatRooms);
      _matches = List<Match>.from(cache.matches);
      _isLoadingChats = false;
      _isLoadingMatches = false;
      _chatError = null;
      _matchError = null;
    });
  }

  void _syncChatRoomsCache() {
    ref.read(chatListCacheProvider.notifier).setChatRooms(_chatRooms);
  }

  void _syncMatchesCache() {
    ref.read(chatListCacheProvider.notifier).setMatches(_matches);
  }

  void _initChatListSocket() {
    final userState = ref.read(userStoreProvider);
    final user = userState['user'] as User?;
    final userId = user?.userId;
    final accessToken = userState['accessToken'] as String?;

    if (userId == null || userId.isEmpty) return;

    _chatListSocket = ChatListSocketService(
      userId: userId,
      accessToken: accessToken,
    );
    _chatListSocket?.connect();

    _chatListSubscription = _chatListSocket?.updateStream.listen((event) {
      if (!mounted) return;
      _handleChatListUpdate(event);
    });
  }

  void _initMatchSocket() {
    final userState = ref.read(userStoreProvider);
    final user = userState['user'] as User?;
    final userId = user?.userId;
    final accessToken = userState['accessToken'] as String?;

    if (userId == null || userId.isEmpty) return;

    _matchSocket = MatchSocketService(userId: userId, accessToken: accessToken);
    _matchSocket?.connect();

    _matchSubscription = _matchSocket?.stream.listen((event) {
      if (!mounted) return;
      _loadMatches();
    });
  }

  void _handleChatListUpdate(ChatListUpdateEvent event) {
    setState(() {
      final roomIndex = _chatRooms.indexWhere(
        (room) => room.roomId == event.roomId,
      );

      if (roomIndex >= 0) {
        final updatedRoom = _chatRooms[roomIndex].copyWith(
          unreadCount: event.unreadCount,
          lastMessage: event.lastMessage ?? _chatRooms[roomIndex].lastMessage,
          lastMessageTime:
              event.lastMessageTime ?? _chatRooms[roomIndex].lastMessageTime,
        );
        _chatRooms[roomIndex] = updatedRoom;

        if (event.unreadCount == 0) {
          _clearedUnreadRoomIds.add(event.roomId);
        } else {
          _clearedUnreadRoomIds.remove(event.roomId);
        }
      } else if (event.unreadCount > 0) {
        _loadChatRooms(silent: true);
      }
    });
    _syncChatRoomsCache();
  }

  Future<void> _loadData({bool silent = false}) async {
    await Future.wait([
      _loadChatRooms(silent: silent),
      _loadMatches(silent: silent),
    ]);
  }

  Future<void> _loadChatRooms({bool silent = false}) async {
    if (!silent || _chatRooms.isEmpty) {
      setState(() {
        _isLoadingChats = true;
        _chatError = null;
      });
    }

    try {
      pendingNotis = [];
      final chatService = ref.read(chatServiceProvider);
      final rooms = await chatService.getChatRooms();
      final filteredRooms = rooms.where((room) => room.type != 'new').toList();
      if (!mounted) return;
      setState(() {
        _chatRooms = filteredRooms;
        final syncedRoomIds = _chatRooms
            .where((room) => room.unreadCount == 0)
            .map((room) => room.roomId)
            .toSet();
        _clearedUnreadRoomIds.removeWhere(syncedRoomIds.contains);
        _isLoadingChats = false;
      });
      _syncChatRoomsCache();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (_chatRooms.isEmpty) {
          _chatError = e.toString().replaceAll('Exception: ', '');
        }
        _isLoadingChats = false;
      });
    }
  }

  Future<void> _loadMatches({bool silent = false}) async {
    if (!silent || _matches.isEmpty) {
      setState(() {
        _isLoadingMatches = true;
        _matchError = null;
      });
    }

    try {
      pendingNotis = [];
      final chatService = ref.read(chatServiceProvider);
      final matches = await chatService.getMatches();
      final filteredMatches = matches
          .where((match) => match.type == 'new')
          .toList();

      if (!mounted) return;
      setState(() {
        _matches = filteredMatches;
        _isLoadingMatches = false;
      });
      _syncMatchesCache();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (_matches.isEmpty) {
          _matchError = e.toString().replaceAll('Exception: ', '');
        }
        _isLoadingMatches = false;
      });
    }
  }

  Future<void> _showSequentialDialogs(List<Map<String, String>> notis) async {
    final chatService = ref.read(chatServiceProvider);

    for (var noti in notis) {
      if (!mounted) return;

      final isBefore = noti['type'] == 'BEFORE';

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isBefore
                            ? AppColors.badgeWarning
                            : AppColors.deniedDisabled,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(
                      isBefore
                          ? Icons.warning_amber_rounded
                          : Icons.heart_broken_rounded,
                      size: 40,
                      color: isBefore
                          ? AppColors.badgeSecondaryBg
                          : AppColors.denied,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  isBefore ? 'ใกล้หมดเวลาแล้วนะ!' : 'ความสัมพันธ์สิ้นสุดลง',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'คุณและ '),
                      TextSpan(
                        text: '${noti['name']} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: isBefore
                            ? 'ไม่ได้คุยกันนานแล้ว รีบทักไปคุยก่อนจะสายเกินไปนะ!'
                            : 'Unmatch กันเรียบร้อยแล้ว เนื่องจากไม่ได้มีการเคลื่อนไหวในช่วงที่ผ่านมา',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: DsButton(
                    label: 'รับทราบ',
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    variant: DsButtonVariant.primary,
                    size: DsButtonSize.md,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      try {
        await chatService.triggerNotificationUpdate(noti['roomId']!);

        if (!isBefore) {
          setState(() {
            _chatRooms.removeWhere((room) => room.roomId == noti['roomId']);
            _matches.removeWhere((match) => match.matchId == noti['roomId']);
          });
          _syncChatRoomsCache();
          _syncMatchesCache();
        }
      } catch (_) {}
    }
  }

  bool _isSvgImage(String? path) {
    if (path == null || path.isEmpty) return false;
    final uri = Uri.tryParse(path);
    final normalizedPath = (uri?.path ?? path).toLowerCase();
    return normalizedPath.endsWith('.svg');
  }

  String _formatRelativeLastMessageTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    var difference = now.difference(time);
    if (difference.isNegative) difference = Duration.zero;

    if (difference.inMinutes < 1) return 'เมื่อสักครู่';
    if (difference.inHours < 1) return '${difference.inMinutes} นาทีที่แล้ว';
    if (difference.inDays < 1) return '${difference.inHours} ชั่วโมงที่แล้ว';
    if (difference.inDays < 7) return '${difference.inDays} วันที่แล้ว';
    if (difference.inDays < 30)
      return '${difference.inDays ~/ 7} สัปดาห์ที่แล้ว';
    if (difference.inDays < 365)
      return '${difference.inDays ~/ 30} เดือนที่แล้ว';
    return '${difference.inDays ~/ 365} ปีที่แล้ว';
  }

  String _buildChatSubtitle(ChatRoom room) {
    final lastMessage = (room.lastMessage ?? '').trim();
    final relativeTime = _formatRelativeLastMessageTime(room.lastMessageTime);

    if (lastMessage.isEmpty) return 'ยังไม่มีข้อความ';
    if (relativeTime.isEmpty) return lastMessage;
    return lastMessage;
  }

  String _buildMatchSubtitle(Match match) {
    final date = match.matchedAt;
    if (date == null) return 'แมทต์เมื่อไม่นานมานี้';
    return 'แมทต์เมื่อวันที่ ${DateFormat('d MMMM yyyy', 'th').format(date)}';
  }

  Future<void> _openChatRoom({
    required String roomId,
    required String partnerId,
    required String partnerName,
    required String? avatarUrl,
  }) async {
    final chatService = ref.read(chatServiceProvider);
    if (!mounted) return;
    final String notiType = await chatService.checkNotiStatus(roomId);

    if (notiType != 'NONE' && notiType.isNotEmpty) {
      final List<Map<String, String>> toShow = [
        {'name': partnerName, 'type': notiType, 'roomId': roomId},
      ];

      await _showSequentialDialogs(toShow);
      if (notiType != 'BEFORE') {
        return;
      }
    }

    final navigation = Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'roomId': roomId,
        'targetUserId': partnerId,
        'userName': partnerName,
        'avatarUrl': avatarUrl,
      },
    );

    unawaited(() async {
      try {
        await chatService.updateRelationshipBar(roomId);
      } catch (_) {}
    }());

    await navigation;
  }

  Widget _buildListBody({
    required bool isLoading,
    required String? error,
    required bool isEmpty,
    required VoidCallback onRetry,
    required Future<void> Function() onRefresh,
    required String emptyTitle,
    required String emptySubtitle,
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandPrimary),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 36,
                color: TextColors.supportText,
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TextColors.supportText,
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
              const SizedBox(height: 16),
              DsButton(
                label: 'ลองใหม่',
                onPressed: onRetry,
                variant: DsButtonVariant.outlinePrimary,
                size: DsButtonSize.sm,
                width: 140,
              ),
            ],
          ),
        ),
      );
    }

    if (isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.forum_outlined,
                size: 38,
                color: TextColors.supportText,
              ),
              const SizedBox(height: 12),
              Text(
                emptyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TextColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 22 / 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TextColors.supportText,
                  fontSize: 12,
                  height: 16 / 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.brandPrimary,
      onRefresh: onRefresh,
      child: AppRawScrollbar(
        controller: _chatListScrollController,
        child: ListView.separated(
          controller: _chatListScrollController,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 110),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: itemBuilder,
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    return _buildListBody(
      isLoading: _isLoadingChats,
      error: _chatError,
      isEmpty: _chatRooms.isEmpty,
      onRetry: _loadChatRooms,
      onRefresh: () => _loadChatRooms(silent: true),
      emptyTitle: 'ยังไม่มีแชท',
      emptySubtitle: 'เมื่อเริ่มคุยกับคู่เดต รายการแชทจะขึ้นที่นี่',
      itemCount: _chatRooms.length,
      itemBuilder: (context, index) {
        final room = _chatRooms[index];
        final avatarPath = room.partnerImage;
        final isCleared = _clearedUnreadRoomIds.contains(room.roomId);
        final displayUnreadCount = isCleared ? 0 : room.unreadCount;
        final highlighted = displayUnreadCount > 0;

        return _ChatListCard(
          avatarPath: avatarPath,
          isSvgAvatar: _isSvgImage(avatarPath),
          title: room.partnerName,
          subtitle: _buildChatSubtitle(room),
          highlighted: highlighted,
          unreadCount: displayUnreadCount,
          onTap: () async {
            setState(() {
              _clearedUnreadRoomIds.add(room.roomId);
            });

            await _openChatRoom(
              roomId: room.roomId,
              partnerId: room.partnerId,
              partnerName: room.partnerName,
              avatarUrl: room.partnerImage,
            );

            if (!mounted) return;
            await _loadChatRooms();
          },
        );
      },
    );
  }

  Widget _buildMatchTab() {
    return _buildListBody(
      isLoading: _isLoadingMatches,
      error: _matchError,
      isEmpty: _matches.isEmpty,
      onRetry: _loadMatches,
      onRefresh: () => _loadMatches(silent: true),
      emptyTitle: 'ยังไม่มีแมทช์',
      emptySubtitle: 'เมื่อมีคู่เดตใหม่ รายการแมทช์จะขึ้นที่นี่',
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        final match = _matches[index];
        return _ChatListCard(
          avatarPath: match.partnerImage,
          isSvgAvatar: _isSvgImage(match.partnerImage),
          title: match.partnerName,
          subtitle: _buildMatchSubtitle(match),
          highlighted: false,
          unreadCount: null,
          onTap: () async {
            setState(() {
              _viewedMatchIds.add(match.matchId);
            });

            await _openChatRoom(
              roomId: match.matchId,
              partnerId: match.partnerId,
              partnerName: match.partnerName,
              avatarUrl: match.partnerImage,
            );

            if (!mounted) return;
            await Future.wait([_loadMatches(), _loadChatRooms()]);
          },
        );
      },
    );
  }

  void _handleBottomNavTap(int index) {
    if (!mounted) return;
    setState(() => _selectedIndex = index);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MainTabs(initialIndex: index),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            DsAppHomeHeader(showBottomBorder: true, bottomBorderSpacing: 0),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(29, 20, 29, 20),
                    child: _ChatSwitcher(
                      selectedTab: _selectedTab,
                      onChanged: (tab) {
                        setState(() => _selectedTab = tab);
                      },
                    ),
                  ),
                  Expanded(
                    child: _selectedTab == _ChatListTab.chat
                        ? _buildChatTab()
                        : _buildMatchTab(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onTap: _handleBottomNavTap,
            )
          : null,
    );
  }
}

class _ChatSwitcher extends StatelessWidget {
  const _ChatSwitcher({required this.selectedTab, required this.onChanged});

  final _ChatListTab selectedTab;
  final ValueChanged<_ChatListTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 39,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InputColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ChatSwitcherItem(
              label: 'CHAT',
              selected: selectedTab == _ChatListTab.chat,
              onTap: () => onChanged(_ChatListTab.chat),
            ),
          ),
          Container(width: 1, height: 10, color: InputColors.border),
          Expanded(
            child: _ChatSwitcherItem(
              label: 'MATCH',
              selected: selectedTab == _ChatListTab.match,
              onTap: () => onChanged(_ChatListTab.match),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatSwitcherItem extends StatelessWidget {
  const _ChatSwitcherItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.textOnDark : TextColors.supportText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 16 / 12,
          ),
        ),
      ),
    );
  }
}

class _ChatListCard extends StatefulWidget {
  const _ChatListCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.avatarPath,
    this.isSvgAvatar = false,
    this.highlighted = false,
    this.unreadCount,
  });

  final String? avatarPath;
  final bool isSvgAvatar;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlighted;
  final int? unreadCount;

  @override
  State<_ChatListCard> createState() => _ChatListCardState();
}

class _ChatListCardState extends State<_ChatListCard> {
  bool _isPressed = false;
  static const LinearGradient _highlightGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [MainColors.primary, DataColors.pastel5],
  );

  @override
  Widget build(BuildContext context) {
    final bool showUnread =
        widget.unreadCount != null && widget.unreadCount! > 0;
    final borderColor = _isPressed
        ? AppColors.surface.withValues(alpha: 0.16)
        : Colors.transparent;

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      scale: _isPressed ? 0.985 : 1,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (value) {
          if (_isPressed == value) return;
          setState(() => _isPressed = value);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          height: 80,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.highlighted ? null : AppColors.background,
            gradient: widget.highlighted ? _highlightGradient : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: _isPressed
                ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              _ChatAvatar(
                avatarPath: widget.avatarPath,
                isSvgAvatar: widget.isSvgAvatar,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: TextColors.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.highlighted
                            ? AppColors.textOnDark
                            : TextColors.supportText,
                        fontSize: 12,
                        fontWeight: widget.highlighted
                            ? FontWeight.w700
                            : FontWeight.w400,
                        height: 16 / 12,
                        letterSpacing: 0.12,
                      ),
                    ),
                  ],
                ),
              ),
              if (showUnread)
                _UnreadBadge(count: widget.unreadCount!)
              else
                const SizedBox(width: 33),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({this.avatarPath, required this.isSvgAvatar});

  final String? avatarPath;
  final bool isSvgAvatar;
  static const double _size = 60;

  @override
  Widget build(BuildContext context) {
    if (avatarPath != null && avatarPath!.isNotEmpty && !isSvgAvatar) {
      return Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: Colors.white, width: 2),
          image: DecorationImage(
            image: avatarPath!.startsWith('http')
                ? NetworkImage(avatarPath!)
                : AssetImage(avatarPath!) as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: SizedBox.square(dimension: _size, child: _buildAvatarContent()),
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (avatarPath == null || avatarPath!.isEmpty) {
      return ColoredBox(color: AppColors.surface, child: _fallback());
    }

    if (isSvgAvatar) {
      final svg = avatarPath!.startsWith('http')
          ? SvgPicture.network(
              avatarPath!,
              width: _size,
              height: _size,
              fit: BoxFit.cover,
            )
          : SvgPicture.asset(
              avatarPath!,
              width: _size,
              height: _size,
              fit: BoxFit.cover,
            );

      return ColoredBox(
        color: AppColors.surface,
        child: SizedBox.square(dimension: _size, child: svg),
      );
    }

    return ColoredBox(color: AppColors.surface, child: _fallback());
  }

  Widget _fallback() {
    return const Center(
      child: Icon(Icons.person, size: 34, color: AppColors.textOnDark),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 9 ? '9+' : '$count';
    return Container(
      width: 33,
      alignment: Alignment.centerRight,
      child: Container(
        width: 23,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.textOnDark,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.deniedActive,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 16 / 14,
            letterSpacing: 0.14,
          ),
        ),
      ),
    );
  }
}
