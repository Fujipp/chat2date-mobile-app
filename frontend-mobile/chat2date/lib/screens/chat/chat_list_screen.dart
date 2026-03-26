import 'dart:async';

import 'package:chat2date/components/card/card_chat_component.dart';
import 'package:chat2date/components/chat/content_switcher.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/layout/menu_bar.dart';
import 'package:chat2date/models/chat_room.dart';
import 'package:chat2date/models/dto/match_event_dto.dart';
import 'package:chat2date/models/match.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/screens/main_tabs.dart';
import 'package:chat2date/services/chat_list_socket_service.dart';
import 'package:chat2date/services/chat_service.dart';
import 'package:chat2date/services/match_socket_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  final bool showBottomNav;

  const ChatListScreen({super.key, this.showBottomNav = true});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 1;
  int selectedIndex1 = 0;
  final Set<String> _viewedMatchIds = {};
  final Set<String> _clearedUnreadRoomIds = {};

  // State สำหรับข้อมูลจาก API
  List<ChatRoom> _chatRooms = [];
  List<Match> _matches = [];
  bool _isLoadingChats = true;
  bool _isLoadingMatches = true;
  String? _chatError;
  String? _matchError;
  List<Map<String, String>> pendingNotis = [];

  // WebSocket for realtime updates
  ChatListSocketService? _chatListSocket;
  StreamSubscription<ChatListUpdateEvent>? _chatListSubscription;
  MatchSocketService? _matchSocket;
  StreamSubscription<MatchEventDto>? _matchSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _initChatListSocket();
    _initMatchSocket();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh data when app resumes from background
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
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
      // New match received - reload matches list
      _loadMatches();
    });
  }

  void _handleChatListUpdate(ChatListUpdateEvent event) {
    // อัพเดท unread count แบบ realtime
    setState(() {
      final roomIndex = _chatRooms.indexWhere(
        (room) => room.roomId == event.roomId,
      );

      if (roomIndex >= 0) {
        // อัพเดทห้องที่มีอยู่แล้ว
        final updatedRoom = _chatRooms[roomIndex].copyWith(
          unreadCount: event.unreadCount,
          lastMessage: event.lastMessage ?? _chatRooms[roomIndex].lastMessage,
          lastMessageTime:
              event.lastMessageTime ?? _chatRooms[roomIndex].lastMessageTime,
        );
        _chatRooms[roomIndex] = updatedRoom;

        // ถ้า unread count = 0 ให้เพิ่มเข้า cleared list เพื่อแสดง 0 ทันที
        if (event.unreadCount == 0) {
          _clearedUnreadRoomIds.add(event.roomId);
        } else {
          // ถ้า unread count > 0 ให้ลบออกจาก cleared list
          _clearedUnreadRoomIds.remove(event.roomId);
        }
      } else if (event.unreadCount > 0) {
        // ห้องใหม่ที่ยังไม่มีใน list - reload เพื่อดึงข้อมูลเต็ม
        _loadChatRooms();
      }
    });
  }

  String _formatRelativeLastMessageTime(DateTime? time) {
    if (time == null) {
      return '';
    }

    final now = DateTime.now();
    var difference = now.difference(time);
    if (difference.isNegative) {
      difference = Duration.zero;
    }

    if (difference.inMinutes < 1) {
      return 'เมื่อสักครู่';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} วันที่แล้ว';
    }
    if (difference.inDays < 30) {
      return '${difference.inDays ~/ 7} สัปดาห์ที่แล้ว';
    }
    if (difference.inDays < 365) {
      return '${difference.inDays ~/ 30} เดือนที่แล้ว';
    }
    return '${difference.inDays ~/ 365} ปีที่แล้ว';
  }

  String _buildChatSubtitle(ChatRoom room) {
    final lastMessage = (room.lastMessage ?? '').trim();
    final relativeTime = _formatRelativeLastMessageTime(room.lastMessageTime);

    if (lastMessage.isEmpty) {
      return 'ยังไม่มีข้อความ';
    }
    if (relativeTime.isEmpty) {
      return lastMessage;
    }
    return '$lastMessage ส่งเมื่อ $relativeTime';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatListSubscription?.cancel();
    _chatListSocket?.dispose();
    _matchSubscription?.cancel();
    _matchSocket?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadChatRooms(), _loadMatches()]);
  }

  Future<void> _checkAndShowNotifications(
    String roomId,
    String partnerName,
  ) async {
    if (!mounted) return;
    final chatService = ref.read(chatServiceProvider);

    // เช็ค Noti ของทุกห้อง
    try {
      // เช็ค Noti เฉพาะห้องที่ส่ง Id เข้ามา
      final String notiType = await chatService.checkNotiStatus(roomId);

      if (notiType != "NONE" && notiType.isNotEmpty) {
        final List<Map<String, String>> toShow = [
          {'name': partnerName, 'type': notiType, 'roomId': roomId},
        ];

        // แสดง Dialog (ใช้ Logic เดิมของคุณ)
        await _showSequentialDialogs(toShow);
      }
    } catch (e) {
      debugPrint('Check Noti Error for $roomId: $e');
    }
  }

  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoadingChats = true;
      _chatError = null;
    });

    try {
      pendingNotis = [];
      final chatService = ref.read(chatServiceProvider);
      final rooms = await chatService.getChatRooms();
      if (mounted) {
        setState(() {
          _chatRooms = rooms.where((room) => room.type != 'new').toList();
          // เมื่อ API คืน unreadCount = 0 แสดงว่าข้อมูลถูก sync แล้ว
          // ลบ roomId ออกจาก clearedUnreadRoomIds เพราะไม่จำเป็นต้อง override อีกต่อไป
          final syncedRoomIds = _chatRooms
              .where((room) => room.unreadCount == 0)
              .map((room) => room.roomId)
              .toSet();
          _clearedUnreadRoomIds.removeWhere(syncedRoomIds.contains);
          _isLoadingChats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chatError = e.toString().replaceAll('Exception: ', '');
          _isLoadingChats = false;
        });
      }
    }
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoadingMatches = true;
      _matchError = null;
    });

    try {
      pendingNotis = [];
      final chatService = ref.read(chatServiceProvider);
      final matches = await chatService.getMatches();

      if (mounted) {
        setState(() {
          _matches = matches.where((match) => match.type == 'new').toList();
          _isLoadingMatches = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _matchError = e.toString().replaceAll('Exception: ', '');
          _isLoadingMatches = false;
        });
      }
    }
  }

  Future<void> _showSequentialDialogs(List<Map<String, String>> notis) async {
    final chatService = ref.read(chatServiceProvider);

    for (var noti in notis) {
      if (!mounted) return;

      final isBefore = noti['type'] == "BEFORE";

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header พร้อมวงกลมซ้อนหลัง
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isBefore
                            ? AppColors.badgeWarning
                            : AppColors.badgeErrorBg,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SvgPicture.asset(
                      isBefore
                          ? 'assets/icons/icon_warning.svg' // <-- ใส่ path ของคุณที่นี่
                          : 'assets/icons/icon_bad-ending.svg', // <-- ใส่ path ของคุณที่นี่
                      width: 40,
                      height: 40,
                      colorFilter: ColorFilter.mode(
                        isBefore
                            ? AppColors.warning
                            : AppColors.brandAccentStrong,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  isBefore ? "ใกล้หมดเวลาแล้วนะ!" : "ความสัมพันธ์สิ้นสุดลง",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Content
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: "คุณและ "),
                      TextSpan(
                        text: "${noti['name']} ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: isBefore
                            ? "ไม่ได้คุยกันนานแล้ว รีบทักไปคุยก่อนจะสายเกินไปนะ!"
                            : "Unmatch กันเรียบร้อยแล้ว เนื่องจากไม่ได้มีการเคลื่อนไหวในช่วงที่ผ่านมา",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBefore
                          ? AppColors.btnPrimary
                          : AppColors.brandPrimary200,
                      foregroundColor: AppColors.btnTextPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "รับทราบ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // หลังจากกดปิด Dialog แล้ว ค่อยแจ้ง Backend
      try {
        await chatService.triggerNotificationUpdate(noti['roomId']!);

        if (!isBefore) {
          // ถ้าเป็น UNMATCH (ความสัมพันธ์จบแล้ว) ให้ลบออกจาก List ทันที
          setState(() {
            _chatRooms.removeWhere((room) => room.roomId == noti['roomId']);
            _matches.removeWhere((match) => match.matchId == noti['roomId']);
          });
        }
      } catch (e) {
        debugPrint("Failed to trigger update: $e");
      }
    }
  }

  bool _isSvgImage(String? path) {
    if (path == null || path.isEmpty) return false;
    final uri = Uri.tryParse(path);
    final normalizedPath = (uri?.path ?? path).toLowerCase();
    return normalizedPath.endsWith('.svg');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 25),
          ChatToDateHeaderWhite(
            leftIconPath: 'assets/icons/icon_chat2date_full.svg',
            rightIconPath: '',
            iconColor: const Color(0xFF5ce1e6),
            onBack: () async => true,
            onSettings: () async => true,
          ),
          const SizedBox(height: 10),
          ContentSwitcher(
            items: const ['CHAT', 'MATCH'],
            selectedIndex: selectedIndex1,
            onChanged: (index) => setState(() => selectedIndex1 = index),
          ),
          const SizedBox(height: 10),

          // แสดงเนื้อหาตาม tab ที่เลือก
          Expanded(
            child: selectedIndex1 == 0 ? _buildChatTab() : _buildMatchTab(),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomNav
          ? CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onTap: (index) {
                if (!mounted) return;
                setState(() => _selectedIndex = index);
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => MainTabs(initialIndex: index),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            )
          : null,
    );
  }

  Widget _buildChatTab() {
    // Loading state
    if (_isLoadingChats) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (_chatError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _chatError!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChatRooms,
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (_chatRooms.isEmpty) {
      return const Center(
        child: Text(
          'ยังไม่มีแชท',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    // Data state
    return RefreshIndicator(
      onRefresh: _loadChatRooms,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _chatRooms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final room = _chatRooms[index];
          final avatarPath = room.partnerImage;
          final isSvgAvatar = _isSvgImage(avatarPath);
          final bool isCleared = _clearedUnreadRoomIds.contains(room.roomId);
          final int displayUnreadCount = isCleared ? 0 : room.unreadCount;
          print(
            '[ChatList] roomId=${room.roomId}, isCleared=$isCleared, room.unreadCount=${room.unreadCount}, display=$displayUnreadCount',
          );
          return CardChatComponent(
            svgPath: isSvgAvatar ? avatarPath : null,
            imagePath: isSvgAvatar ? null : avatarPath,
            title: room.partnerName,
            subtitle: _buildChatSubtitle(room),
            unreadCount: displayUnreadCount,
            colors: [AppColors.backgroundWhite],
            onClick: () async {
              setState(() {
                _clearedUnreadRoomIds.add(room.roomId);
              });

              final chatService = ref.read(chatServiceProvider);
              try {
                await chatService.updateRelationshipBar(room.roomId);
              } catch (e) {
                debugPrint("Stats update failed: $e");
              }

              await _checkAndShowNotifications(room.roomId, room.partnerName);

              final bool roomStillExists = _chatRooms.any(
                (r) => r.roomId == room.roomId,
              );

              if (roomStillExists) {
                await Navigator.pushNamed(
                  context,
                  '/chat',
                  arguments: {
                    'roomId': room.roomId,
                    'targetUserId': room.partnerId,
                    'userName': room.partnerName,
                    'avatarUrl': room.partnerImage,
                  },
                );
              }
              if (!mounted) return;
              await _loadChatRooms();
            },
          );
        },
      ),
    );
  }

  Widget _buildMatchTab() {
    // Loading state
    if (_isLoadingMatches) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (_matchError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _matchError!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMatches,
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (_matches.isEmpty) {
      return const Center(
        child: Text(
          'ยังไม่มี match',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    // Data state
    return RefreshIndicator(
      onRefresh: _loadMatches,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _matches.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final match = _matches[index];
          final isNew =
              match.type == 'new' && !_viewedMatchIds.contains(match.matchId);
          final avatarPath = match.partnerImage;
          final isSvgAvatar = _isSvgImage(avatarPath);
          return CardChatComponent(
            svgPath: isSvgAvatar ? avatarPath : null,
            imagePath: isSvgAvatar ? null : avatarPath,
            title: match.partnerName,
            subtitle: match.matchDuration,
            isNewMatch: isNew,
            colors: isNew ? null : [AppColors.backgroundWhite],
            onClick: () async {
              final chatService = ref.read(chatServiceProvider);
              try {
                await chatService.updateRelationshipBar(match.matchId);
              } catch (e) {
                debugPrint("Stats update failed: $e");
              }

              setState(() {
                _viewedMatchIds.add(match.matchId);
              });

              // เปิดแชทกับ match
              await _checkAndShowNotifications(
                match.matchId,
                match.partnerName,
              );

              final bool matchStillExists = _matches.any(
                (m) => m.matchId == match.matchId,
              );

              if (matchStillExists) {
                await Navigator.pushNamed(
                  context,
                  '/chat',
                  arguments: {
                    'roomId': match.matchId,
                    'targetUserId': match.partnerId,
                    'userName': match.partnerName,
                    'avatarUrl': match.partnerImage,
                  },
                );
              }
              if (!mounted) return;
              await Future.wait([_loadMatches(), _loadChatRooms()]);
            },
          );
        },
      ),
    );
  }
}
