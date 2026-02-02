import 'dart:async';
import 'dart:ui';

import 'package:chat2date/components/chat/bot_message_component.dart';
import 'package:chat2date/components/chat/chat_text_component.dart';
import 'package:chat2date/components/chat/input_chat_component.dart';
import 'package:chat2date/components/chat/spin_date_component.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/status_bar/score_row.dart';
import 'package:chat2date/models/chat_access_status.dart';
import 'package:chat2date/models/chat_message.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/chat_service.dart';
import 'package:chat2date/services/chat_socket_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InsideChatScreen extends ConsumerStatefulWidget {
  final String? roomId;
  final String? targetUserId;
  final String? userName;
  final String? avatarUrl;

  const InsideChatScreen({
    super.key,
    this.roomId,
    this.targetUserId,
    this.userName,
    this.avatarUrl,
  });

  @override
  ConsumerState<InsideChatScreen> createState() => _InsideChatScreenState();
}

class _InsideChatScreenState extends ConsumerState<InsideChatScreen>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 20;
  bool _hasText = false;
  bool _isSending = false;
  double _currentPercent = 0.0;
  int _heartCount = 0; // 0 = ซ่อน, 1-2 = แสดง, 3 = rainbow
  bool _showWheelModal = false;
  bool _showUnlockDate = false;
  bool _showSpinWheel = false;
  bool firstTime = true;
  int talkCount = 0;

  bool _isLoadingMessages = true;
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  int _currentPage = 0;
  String? _messageError;
  int? _relationshipScore;
  final Set<String> _messageIds = {};
  ChatSocketService? _chatSocketService;
  StreamSubscription<ChatMessage>? _messageSubscription;
  StreamSubscription<ChatAccessStatus>? _accessSubscription;
  StreamSubscription<Map<String, dynamic>>? _readSubscription;
  String? _currentUserId;
  bool _hasEntered = false;
  bool _hasExited = false;
  Timer? _seenStatusTimer;
  bool _isChatDisabled = false; // true if report exists between users

  // === Chat User Data (ดึงจากข้อมูลจริง) ===
  String _chatUserName = 'Name';
  String? _chatUserAvatar;
  String? _chatUserId; // เพิ่ม userId สำหรับ Report

  // === Spinwheel Cooldown Logic ===
  DateTime? _lastSpinDate; // วันที่หมุนวงล้อล่าสุด
  int _cooldownDays = 7; // จำนวนวันที่ต้องรอก่อนหมุนได้อีกครั้ง
  bool _canSpin = true; // true = กดได้ (Chat 2/3), false = cooldown (Chat 4)
  ChatHeaderVariant _headerVariant = ChatHeaderVariant.chat1;

  // ข้อความแชท
  List<ChatMessage> _messages = [];

  // index ของข้อความที่ถูกกดเพื่อดูเวลาส่ง (-1 = ไม่มี)
  int _selectedMessageIndex = -1;

  @override
  void initState() {
    super.initState();
    // Register keyboard observer
    WidgetsBinding.instance.addObserver(this);
    // รับข้อมูลจาก arguments
    _chatUserId = widget.targetUserId;
    _chatUserName = widget.userName ?? 'Name';
    _chatUserAvatar = widget.avatarUrl;

    _scrollController.addListener(_handleScroll);
    _initializeChat();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <= 80) {
      _loadMoreMessages();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Scroll to bottom when keyboard opens
    final bottomInset = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
    if (bottomInset > 0) {
      // Keyboard is visible - scroll to bottom after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _scrollController.hasClients) {
          _scrollToBottom();
        }
      });
    }
  }

  Future<void> _initializeChat() async {
    await _enterRoomOnce();
    await _loadChatRoomMessages();
    _checkSpinWheelCondition();
  }

  Future<void> _loadChatRoomMessages() async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) {
      setState(() {
        _messageError = 'ไม่พบ roomId สำหรับแชทนี้';
        _isLoadingMessages = false;
      });
      return;
    }

    setState(() {
      _isLoadingMessages = true;
      _isLoadingMore = false;
      _messageError = null;
      _currentPage = 0;
      _hasMoreMessages = true;
    });

    try {
      final chatService = ref.read(chatServiceProvider);
      final roomData = await chatService.getChatMessages(roomId);
      if (!mounted) return;
      final sortedMessages = [...roomData.messages]
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      setState(() {
        _messages = sortedMessages;
        _isLoadingMessages = false;
        _messageIds
          ..clear()
          ..addAll(sortedMessages.map((message) => message.id));
        _hasMoreMessages = sortedMessages.length >= _pageSize;
        _relationshipScore = roomData.relationshipScore;
        _isChatDisabled = roomData.isChatDisabled;
        _applyRelationshipScore(roomData.relationshipScore);
        if (widget.userName == null && roomData.partnerName != null) {
          _chatUserName = roomData.partnerName!;
        }
        if (widget.avatarUrl == null && roomData.partnerImages.isNotEmpty) {
          _chatUserAvatar = roomData.partnerImages.first;
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animated: false);
      });
      _startChatSocket();
      await _syncAccessStatus();
      _checkSpinWheelCondition();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messageError = e.toString().replaceAll('Exception: ', '');
        _isLoadingMessages = false;
      });
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMessages || _isLoadingMore || !_hasMoreMessages) return;
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    final nextPage = _currentPage + 1;
    final prevMaxExtent = _scrollController.position.maxScrollExtent;
    final prevOffset = _scrollController.offset;

    try {
      final chatService = ref.read(chatServiceProvider);
      final roomData = await chatService.getChatMessages(
        roomId,
        paginate: nextPage,
      );
      if (!mounted) return;
      final olderMessages = roomData.messages
          .where((message) => !_messageIds.contains(message.id))
          .toList();
      setState(() {
        _currentPage = nextPage;
        _isLoadingMore = false;
        if (olderMessages.isNotEmpty) {
          _messages = [...olderMessages, ..._messages];
          _messageIds.addAll(olderMessages.map((message) => message.id));
        }
        _hasMoreMessages = roomData.messages.length >= _pageSize;
      });
      if (olderMessages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_scrollController.hasClients) return;
          final newMaxExtent = _scrollController.position.maxScrollExtent;
          final delta = newMaxExtent - prevMaxExtent;
          _scrollController.jumpTo(prevOffset + delta);
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _applyRelationshipScore(int? score) {
    final int safeScore = score ?? 0;
    final double percent = (safeScore / 100).clamp(0.0, 1.0);
    int heart;
    if (safeScore >= 90) {
      heart = 3;
    } else if (safeScore >= 60) {
      heart = 2;
    } else if (safeScore >= 30) {
      heart = 1;
    } else {
      heart = 0;
    }
    _currentPercent = percent;
    _heartCount = heart;
  }

  Future<void> _enterRoom() async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;
    try {
      final chatService = ref.read(chatServiceProvider);
      await chatService.enterRoom(roomId);
    } catch (_) {}
  }

  Future<void> _enterRoomOnce() async {
    if (_hasEntered) return;
    _hasEntered = true;
    await _enterRoom();
  }

  Future<void> _exitRoom() async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;
    try {
      final chatService = ref.read(chatServiceProvider);
      await chatService.exitRoom(roomId);
    } catch (_) {}
  }

  Future<void> _exitRoomOnce() async {
    if (_hasExited) return;
    _hasExited = true;
    await _exitRoom();
  }

  void _startChatSocket() {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;
    if (_chatSocketService != null) return;

    final userState = ref.read(userStoreProvider);
    final accessToken = userState['accessToken'] as String?;
    final user = userState['user'];
    if (user is! User) return;
    final userId = user.userId;
    _currentUserId = userId;

    final service = ChatSocketService(
      roomId: roomId,
      userId: userId,
      accessToken: accessToken,
    );
    service.connect();
    _chatSocketService = service;
    _messageSubscription = service.messageStream.listen(_handleIncomingMessage);
    _accessSubscription = service.accessStream.listen(_handleAccessStatus);
    _readSubscription = service.readStream.listen(_handleReadEvent);

    // Setup periodic timer as fallback (in case WebSocket events are missed)
    _seenStatusTimer?.cancel();
    _seenStatusTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _refreshReadStatus();
      }
    });
  }

  Future<void> _syncAccessStatus() async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;
    try {
      final chatService = ref.read(chatServiceProvider);
      final status = await chatService.getAccessStatus(roomId);
      if (!mounted) return;
      _handleAccessStatus(status);
    } catch (_) {}
  }

  void _handleIncomingMessage(ChatMessage message) {
    if (!mounted) return;
    if (_messageIds.contains(message.id)) return;
    setState(() {
      _messages.add(message);
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      _messageIds.add(message.id);
    });
    _scrollToBottom();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(position);
    }
  }

  void _handleAccessStatus(ChatAccessStatus status) {
    final currentUserId = _currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) return;
    // Access status changed - may need to refresh for edge cases
    _refreshReadStatus();
  }

  /// Handle real-time read event from WebSocket
  void _handleReadEvent(Map<String, dynamic> payload) {
    if (!mounted) return;
    final senderId = payload['senderId'] as String?;
    // If the senderId matches current user, it means our messages were read
    if (_currentUserId == senderId) {
      setState(() {
        _messages = _messages.map((msg) {
          if (msg.isOwn && !msg.isSeen) {
            return msg.copyWith(isSeen: true);
          }
          return msg;
        }).toList();
      });
    }
  }

  Future<void> _refreshReadStatus() async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;
    try {
      final chatService = ref.read(chatServiceProvider);
      final roomData = await chatService.getChatMessages(roomId);
      if (!mounted) return;
      final readMap = <String, bool>{
        for (final message in roomData.messages) message.id: message.isSeen,
      };
      bool hasUpdate = false;
      final updated = _messages.map((message) {
        if (message.isOwn && readMap[message.id] == true && !message.isSeen) {
          hasUpdate = true;
          return message.copyWith(isSeen: true);
        }
        return message;
      }).toList();
      if (hasUpdate) {
        setState(() {
          _messages = updated;
        });
      }
    } catch (_) {}
  }

  bool _isSvgImage(String? path) {
    if (path == null || path.isEmpty) return false;
    final uri = Uri.tryParse(path);
    final normalizedPath = (uri?.path ?? path).toLowerCase();
    return normalizedPath.endsWith('.svg');
  }

  Widget _buildChatAvatar() {
    const size = 50.0;
    final avatar = _chatUserAvatar;

    if (avatar == null || avatar.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.surfaceMuted,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(Icons.person, color: Colors.grey[400], size: 32),
      );
    }

    final bool isSvg = _isSvgImage(avatar);
    final Widget image = isSvg
        ? (avatar.startsWith('http')
              ? SvgPicture.network(
                  avatar,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                )
              : SvgPicture.asset(
                  avatar,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ))
        : (avatar.startsWith('http')
              ? Image.network(
                  avatar,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      color: Colors.grey[400],
                      size: 32,
                    );
                  },
                )
              : Image.asset(
                  avatar,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      color: Colors.grey[400],
                      size: 32,
                    );
                  },
                ));

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: image,
    );
  }

  String _formatChatTimestamp(DateTime time) {
    // แปลงเป็นเวลาไทย (UTC+7)
    final thailandTime = time.toUtc().add(const Duration(hours: 7));

    const weekdays = [
      'วันจันทร์',
      'วันอังคาร',
      'วันพุธ',
      'วันพฤหัสบดี',
      'วันศุกร์',
      'วันเสาร์',
      'วันอาทิตย์',
    ];
    final weekday = weekdays[thailandTime.weekday - 1];
    final hour = thailandTime.hour.toString().padLeft(2, '0');
    final minute = thailandTime.minute.toString().padLeft(2, '0');
    return '$weekday $hour:$minute';
  }

  Widget _buildChatTimestamp(DateTime time) {
    return Text(
      _formatChatTimestamp(time),
      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
    );
  }

  /// Format เวลาส่งจริงของข้อความ (แสดงเมื่อกดที่ข้อความ)
  String _formatMessageTime(DateTime time) {
    // แปลงเป็นเวลาไทย (UTC+7)
    final thailandTime = time.toUtc().add(const Duration(hours: 7));

    final hour = thailandTime.hour.toString().padLeft(2, '0');
    final minute = thailandTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Widget แสดงเวลาส่งจริงของข้อความ
  Widget _buildMessageTimeIndicator(DateTime time, bool isOwn) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: EdgeInsets.only(
          top: 4,
          left: isOwn ? 0 : 8,
          right: isOwn ? 8 : 0,
        ),
        child: Text(
          _formatMessageTime(time),
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
      ),
    );
  }

  bool _shouldShowTimestamp(int index) {
    if (index <= 0) return true;
    final current = _messages[index].timestamp;
    final previous = _messages[index - 1].timestamp;
    // แสดง timestamp เมื่อเปลี่ยนชั่วโมง (เช่น 01:xx → 02:xx) หรือเปลี่ยนวัน
    return current.hour != previous.hour ||
        current.day != previous.day ||
        current.month != previous.month ||
        current.year != previous.year;
  }

  bool _hasTimeBreakBefore(int index) {
    if (index <= 0) return false;
    return _shouldShowTimestamp(index);
  }

  bool _hasTimeBreakAfter(int index) {
    if (index >= _messages.length - 1) return false;
    return _shouldShowTimestamp(index + 1);
  }

  /// หาข้อความล่าสุดของเรา (ไม่สนใจว่าถูกอ่านหรือยัง)
  int _findLatestOwnMessageIndex() {
    for (int i = _messages.length - 1; i >= 0; i--) {
      final message = _messages[i];
      if (message.isOwn && !message.isBot) {
        return i;
      }
    }
    return -1;
  }

  /// คำนวณ cooldown สำหรับ spinwheel
  void _calculateSpinwheelCooldown() {
    if (_lastSpinDate == null) {
      // ยังไม่เคยหมุน - สามารถหมุนได้เลย
      setState(() {
        _canSpin = true;
        _cooldownDays = 0;
        _headerVariant = ChatHeaderVariant.chat2; // ไม่แสดง cooldown number
      });
      return;
    }

    final now = DateTime.now();
    final daysSinceLastSpin = now.difference(_lastSpinDate!).inDays;
    final cooldownPeriod = 7; // 7 วันก่อนหมุนได้อีก

    if (daysSinceLastSpin >= cooldownPeriod) {
      // หมดเวลา cooldown แล้ว - หมุนได้
      setState(() {
        _canSpin = true;
        _cooldownDays = 0;
        _headerVariant = ChatHeaderVariant.chat3; // แสดง 0 days (enabled)
      });
    } else {
      // ยังอยู่ใน cooldown - ห้ามหมุน
      final remainingDays = cooldownPeriod - daysSinceLastSpin;
      setState(() {
        _canSpin = false;
        _cooldownDays = remainingDays;
        _headerVariant = ChatHeaderVariant.chat4; // แสดง X days (disabled)
      });
    }
  }

  /// บันทึกเมื่อหมุนวงล้อสำเร็จ
  void _onSpinComplete() {
    setState(() {
      _lastSpinDate = DateTime.now();
      _showWheelModal = false;
    });
    _calculateSpinwheelCooldown();
    // TODO: บันทึก _lastSpinDate ไปยัง backend
  }

  /// เช็คเงื่อนไขว่า user ผ่านหรือไม่ก่อนเปิด spinwheel
  bool _checkUserEligibility() {
    // เงื่อนไขผ่าน: จำนวนหัวใจ >= 1 (0,1,2,3 โดย 3 จะเป็นรุ้ง)
    // ไม่ต้องเช็ค percent เพราะถ้าเต็มจะเป็น 1 อยู่แล้ว
    return _heartCount >= 1;
  }

  /// จัดการการกด spinwheel
  void _handleSpinwheelTap() {
    if (!_canSpin) {
      // อยู่ใน cooldown - แสดง message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณารออีก $_cooldownDays วันก่อนหมุนได้อีกครั้ง'),
          backgroundColor: AppColors.textMuted,
        ),
      );
      return;
    }

    if (!_checkUserEligibility()) {
      // ไม่ผ่านเงื่อนไข
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('คุณยังไม่ผ่านเงื่อนไขในการหมุนวงล้อ'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // ผ่านทุกเงื่อนไข - เปิด modal
    setState(() {
      _showWheelModal = true;
    });
  }

  void _checkSpinWheelCondition() {
    // เงื่อนไข: หลอดเต็ม (1.0) หรือ หัวใจครบตามที่กำหนด (เช่น 3 ดวง)
    // คำนวณ cooldown และ determine variant

    if (_heartCount < 1) {
      // ไม่ผ่านเงื่อนไข - แสดงแค่ Chat 1 (พื้นฐาน)
      setState(() {
        _headerVariant = ChatHeaderVariant.chat1;
      });
    } else {
      // ผ่านเงื่อนไข - คำนวณ cooldown
      _calculateSpinwheelCooldown();
    }
  }

  /// ส่งข้อความ
  Future<void> _sendMessage() async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messageController.clear();
      _hasText = false;
      _isSending = true;
    });

    try {
      final chatService = ref.read(chatServiceProvider);
      final sentMessage = await chatService.sendMessage(
        roomId: roomId,
        message: text,
      );
      if (!mounted) return;

      setState(() {
        if (firstTime) {
          _currentPercent = 0.05;
          firstTime = false;
          talkCount += 1;
        } else {
          talkCount += 1;
          if (talkCount >= 5) {
            _currentPercent += 0.08;
          }
          if (talkCount == 6) {
            _currentPercent = 1.0;
            if (_currentPercent == 1.0) {
              FocusManager.instance.primaryFocus?.unfocus();
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) {
                  _headerVariant = ChatHeaderVariant.chat2;
                  _triggerUnlockDate();
                }
              });
            }
          }
        }
        if (!_messageIds.contains(sentMessage.id)) {
          _messages.add(sentMessage);
          _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          _messageIds.add(sentMessage.id);
        }
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messageController.text = text;
        _hasText = true;
        _isSending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// คำนวณ position ของ bubble ในกลุ่ม (burger style)
  /// Returns: single, first, middle, last
  String _getBubblePosition(int index) {
    final current = _messages[index];
    if (current.isBot) return 'single';

    final bool hasPrevSameOwner =
        index > 0 &&
        _messages[index - 1].isOwn == current.isOwn &&
        !_messages[index - 1].isBot &&
        !_hasTimeBreakBefore(index);
    final bool hasNextSameOwner =
        index < _messages.length - 1 &&
        _messages[index + 1].isOwn == current.isOwn &&
        !_messages[index + 1].isBot &&
        !_hasTimeBreakAfter(index);

    if (!hasPrevSameOwner && !hasNextSameOwner) return 'single';
    if (!hasPrevSameOwner && hasNextSameOwner) return 'first';
    if (hasPrevSameOwner && hasNextSameOwner) return 'middle';
    return 'last';
  }

  /// คำนวณ border radius ตาม position และ isSent (burger style)
  /// Sent (ขวา): มุมขวาที่ติดกับ bubble อื่นจะเป็น 0 หรือ 5
  /// Received (ซ้าย): มุมซ้ายที่ติดกับ bubble อื่นจะเป็น 0 หรือ 5
  Map<String, double> _getBorderRadius(String position, bool isSent) {
    if (isSent) {
      // Sent messages (ขวา - เราส่งไป)
      switch (position) {
        case 'single':
          // ข้อความเดี่ยว: มุมล่างขวา = 0
          return {'tl': 20, 'tr': 20, 'bl': 20, 'br': 0};
        case 'first':
          // ข้อความแรก (บนสุด): มุมล่างขวา = 0 (ติดกับ bubble ถัดไป)
          return {'tl': 20, 'tr': 20, 'bl': 20, 'br': 0};
        case 'middle':
          // ข้อความกลาง: 2 มุมขวา = 5 (burger style 🍔)
          return {'tl': 20, 'tr': 5, 'bl': 20, 'br': 5};
        case 'last':
          // ข้อความสุดท้าย (ล่างสุด): มุมบนขวา = 0 (ติดกับ bubble ก่อนหน้า)
          return {'tl': 20, 'tr': 0, 'bl': 20, 'br': 20};
        default:
          return {'tl': 20, 'tr': 20, 'bl': 20, 'br': 0};
      }
    } else {
      // Received messages (ซ้าย - คนอื่นส่งมา)
      switch (position) {
        case 'single':
          // ข้อความเดี่ยว: มุมล่างซ้าย = 0
          return {'tl': 20, 'tr': 20, 'bl': 0, 'br': 20};
        case 'first':
          // ข้อความแรก (บนสุด): มุมล่างซ้าย = 0 (ติดกับ bubble ถัดไป)
          return {'tl': 20, 'tr': 20, 'bl': 0, 'br': 20};
        case 'middle':
          // ข้อความกลาง: 2 มุมซ้าย = 5 (burger style 🍔)
          return {'tl': 5, 'tr': 20, 'bl': 5, 'br': 20};
        case 'last':
          // ข้อความสุดท้าย (ล่างสุด): มุมบนซ้าย = 0 (ติดกับ bubble ก่อนหน้า)
          return {'tl': 0, 'tr': 20, 'bl': 20, 'br': 20};
        default:
          return {'tl': 20, 'tr': 20, 'bl': 0, 'br': 20};
      }
    }
  }

  /// ตรวจสอบว่าควรแสดง avatar หรือไม่ (แสดงที่ข้อความสุดท้ายในกลุ่ม)
  bool _shouldShowAvatar(int index) {
    if (_messages[index].isOwn) return false;
    if (_messages[index].isBot) return false;
    if (index >= _messages.length - 1) return true;
    return _messages[index + 1].isOwn ||
        _messages[index + 1].isBot ||
        _hasTimeBreakAfter(index);
  }

  /// ตรวจสอบว่าเป็นข้อความสุดท้ายในกลุ่มหรือไม่
  bool _isLastInGroup(int index) {
    if (index >= _messages.length - 1) return true;
    return _messages[index + 1].isOwn != _messages[index].isOwn ||
        _messages[index + 1].isBot ||
        _hasTimeBreakAfter(index);
  }

  void _triggerUnlockDate() {
    setState(() {
      _showUnlockDate = true;
    });

    // นับถอยหลัง 5 วินาทีแล้วปิด
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showUnlockDate = false;
          _currentPercent = 0.0;
          _heartCount = 1;
        });
      }
    });
  }

  /// สร้าง Widget สำหรับแต่ละ message
  Widget _buildMessageWidget(
    ChatMessage message,
    int index, {
    required int latestOwnIndex,
  }) {
    // Bot message
    if (message.isBot && message.botType != null) {
      return BotMessageComponent.fromMessage(
        message: message,
        onActionPressed: () {
          // Handle action button press
          debugPrint('Action pressed for message: ${message.id}');
        },
        onFirstChoice: () {
          // Handle "ใช่" choice
          debugPrint('First choice (ใช่) for message: ${message.id}');
        },
        onSecondChoice: () {
          // Handle "ไม่" choice
          debugPrint('Second choice (ไม่) for message: ${message.id}');
        },
      );
    }

    // User message (sent/received) - Burger style grouping
    final position = _getBubblePosition(index);
    final radius = _getBorderRadius(position, message.isOwn);
    final showAvatar = _shouldShowAvatar(index);
    // แสดง "เห็นแล้ว" เมื่อ:
    // 1. เป็นข้อความของเรา (isOwn)
    // 2. ถูกอ่านแล้ว (isSeen)
    // 3. เป็นข้อความล่าสุดของเรา (index == latestOwnIndex)
    // 4. ข้อความล่าสุดในแชทเป็นของเรา (ไม่มีข้อความอีกฝ่ายตามหลังมา)
    final isLastMessageOurs = _messages.isNotEmpty && _messages.last.isOwn;
    final showSeen =
        message.isOwn &&
        message.isSeen &&
        index == latestOwnIndex &&
        isLastMessageOurs;
    final showMessageTime = _selectedMessageIndex == index;

    if (message.isOwn) {
      // Sent message (ขวา - ชมพู)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedMessageIndex = _selectedMessageIndex == index
                    ? -1
                    : index;
              });
            },
            child: ChatTextComponent(
              text: message.text,
              isChatRight: true,
              topLeftRadius: radius['tl'],
              topRightRadius: radius['tr'],
              bottomLeftRadius: radius['bl'],
              bottomRightRadius: radius['br'],
            ),
          ),
          // แสดงเวลาส่งจริงเมื่อกดที่ข้อความ
          if (showMessageTime)
            _buildMessageTimeIndicator(message.timestamp, true),
          // แสดง "เห็นแล้ว" เฉพาะข้อความล่าสุดที่ถูกอ่าน
          if (showSeen && !showMessageTime)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: StatusTextComponent(
                text: 'เห็นแล้ว',
                textColor: AppColors.textMuted,
                textSize: 10,
                isMiddle: false,
                svgPath: 'assets/icons/icon_seen.svg',
                size: 12,
              ),
            ),
        ],
      );
    } else {
      // Received message (ซ้าย - เทา) - Avatar ที่ข้อความสุดท้ายในกลุ่ม
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar หรือ space (avatar อยู่ที่ข้อความสุดท้าย)
              if (showAvatar)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: _buildChatAvatar(),
                )
              else
                const SizedBox(width: 58),
              // Message bubble
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMessageIndex = _selectedMessageIndex == index
                          ? -1
                          : index;
                    });
                  },
                  child: ChatTextComponent(
                    text: message.text,
                    isChatRight: false,
                    topLeftRadius: radius['tl'],
                    topRightRadius: radius['tr'],
                    bottomLeftRadius: radius['bl'],
                    bottomRightRadius: radius['br'],
                  ),
                ),
              ),
            ],
          ),
          // แสดงเวลาส่งจริงเมื่อกดที่ข้อความ
          if (showMessageTime)
            Padding(
              padding: const EdgeInsets.only(left: 58),
              child: _buildMessageTimeIndicator(message.timestamp, false),
            ),
        ],
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _seenStatusTimer?.cancel();
    _messageSubscription?.cancel();
    _accessSubscription?.cancel();
    _readSubscription?.cancel();
    _chatSocketService?.dispose();
    _chatSocketService = null;
    _scrollController.removeListener(_handleScroll);
    _exitRoomOnce();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latestOwnIndex = _findLatestOwnMessageIndex();
    return WillPopScope(
      onWillPop: () async {
        await _exitRoomOnce();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            // ✅ ใช้ Stack เพื่อวาง Layer ของวงล้อทับส่วนแชท
            children: [
              Column(
                children: [
                  const SizedBox(height: 8),
                  // ใช้ Header.fromVariant เพื่อรองรับ 4 variants
                  Header.fromVariant(
                    variant: _headerVariant,
                    name: _chatUserName,
                    avatarUrl: _chatUserAvatar,
                    cooldownDays: _cooldownDays,
                    showBorder: false,
                    onBack: () async {
                      await _exitRoomOnce();
                      if (!mounted) return;
                      Navigator.maybePop(context);
                    },
                    onCalendar: () {
                      debugPrint('Calendar tapped');
                    },
                    onSpinwheel: _handleSpinwheelTap,
                    onFlag: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/report',
                        arguments: {
                          'roomId': widget.roomId,
                          'targetUserId': _chatUserId,
                          'userName': _chatUserName,
                          'avatarUrl': _chatUserAvatar,
                        },
                      );
                    },
                  ),

                  // --- ส่วนแชททั้งหมด (ScoreRow + ListView + Input) ---
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double barWidth =
                                  (constraints.maxWidth - 25 - 20).clamp(
                                    140,
                                    260,
                                  );
                              return ScoreRow(
                                basePercent: _currentPercent,
                                number: _heartCount,
                                barWidth: barWidth,
                                barHeight: 8,
                                rightIconSize: 18,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _isLoadingMessages
                              ? const Center(child: CircularProgressIndicator())
                              : _messageError != null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _messageError!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _loadChatRoomMessages,
                                        child: const Text('ลองใหม่'),
                                      ),
                                    ],
                                  ),
                                )
                              : _messages.isEmpty
                              ? const Center(
                                  child: Text(
                                    'ยังไม่มีข้อความ',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    12,
                                    20,
                                    12,
                                  ),
                                  itemCount:
                                      _messages.length +
                                      (_isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    final int offset = _isLoadingMore ? 1 : 0;
                                    if (_isLoadingMore && index == 0) {
                                      return const Padding(
                                        padding: EdgeInsets.only(bottom: 12),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    final messageIndex = index - offset;
                                    final message = _messages[messageIndex];
                                    final bool isGroupedWithNext =
                                        messageIndex < _messages.length - 1 &&
                                        _messages[messageIndex + 1].isOwn ==
                                            message.isOwn &&
                                        !_messages[messageIndex + 1].isBot &&
                                        !message.isBot;
                                    final double bottomGap = isGroupedWithNext
                                        ? 10
                                        : 12;
                                    final bool showTimestamp =
                                        _shouldShowTimestamp(messageIndex);

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        if (showTimestamp)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            child: Center(
                                              child: _buildChatTimestamp(
                                                message.timestamp,
                                              ),
                                            ),
                                          ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom: bottomGap,
                                          ),
                                          child: _buildMessageWidget(
                                            message,
                                            messageIndex,
                                            latestOwnIndex: latestOwnIndex,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                        if (_isChatDisabled)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border(top: BorderSide(color: Colors.grey.shade300)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.block, color: Colors.grey.shade600, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'ไม่สามารถส่งข้อความได้เนื่องจากมีการรายงาน',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        else
                          InputChatComponent(
                            svgPath: 'assets/icons/icon_more-options.svg',
                            svgPathLast: 'assets/icons/icon_send.svg',
                            leftIconColor: AppColors.surfaceLight,
                            sendIconColor: null,
                            sendIconBackgroundColor: null,
                            isSendEnabled:
                                _hasText &&
                                !_isSending &&
                                (widget.roomId?.isNotEmpty ?? false),
                            controller: _messageController,
                            onChanged: (value) => setState(
                              () => _hasText = value.trim().isNotEmpty,
                            ),
                            onSend:
                                _hasText &&
                                    !_isSending &&
                                    (widget.roomId?.isNotEmpty ?? false)
                                ? () => _sendMessage()
                                : null,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_showWheelModal) ...[
                // 1. ฉากหลังสีเทาจาง (Dim background)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _showWheelModal = false),
                    child: Container(color: Colors.black.withOpacity(0.5)),
                  ),
                ),

                // 2. ตัว SpinDateComponent
                // ✅ ใช้ Positioned.fill เพื่อกำหนดขอบเขตพื้นที่ที่เหลือจาก Header
                Positioned.fill(
                  top: 85, // เริ่มต้นที่ขอบล่างของ Header
                  child: Align(
                    alignment: Alignment.center, // จัดกลางใน "พื้นที่ที่เหลือ"
                    child: SingleChildScrollView(
                      // ✅ กันบั๊กกรณีจอเตี้ยเกินไปหรือ Content ยาวเกินจอ
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ), // ✅ เพิ่ม vertical padding กันติดขอบ
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SpinDateComponent(
                                  onCloseModal: () =>
                                      setState(() => _showWheelModal = false),
                                  onSpinComplete: _onSpinComplete,
                                  prizes: const [
                                    {'label': 'Coffee'},
                                    {'label': 'Pizza'},
                                    {'label': 'Movie'},
                                    {'label': 'Book'},
                                    {'label': 'Gift'},
                                    {'label': 'Ice-cream'},
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (_showUnlockDate) ...[
                // 1. Full Screen Blur
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),

                // 2. Animated Content
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.88,
                        decoration: BoxDecoration(
                          color: AppColors.background.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(45),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandPrimary.withOpacity(0.2),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // --- ด้านบนสุด: ตกแต่งด้วยรูปทรงวงกลมฟุ้งๆ ---
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(45),
                                topRight: Radius.circular(45),
                              ),
                              child: SizedBox(
                                height: 100,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: -50,
                                      left: -20,
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundColor: AppColors.info
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    Positioned(
                                      top: -20,
                                      right: -10,
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundColor: AppColors
                                            .brandPrimary200
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        "IT'S DATE TIME!",
                                        style: TextStyle(
                                          color: AppColors.brandPrimary700,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                              child: Column(
                                children: [
                                  // --- ไอคอน: กล้อง + หัวใจ ---
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              AppColors.brandPrimary200
                                                  .withOpacity(0.6),
                                              AppColors.background.withOpacity(
                                                0.0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              AppColors.brandPrimary,
                                              AppColors.brandPrimary700,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.brandPrimary
                                                  .withOpacity(0.4),
                                              blurRadius: 15,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(5),
                                        child: SvgPicture.asset(
                                          'assets/icons/icon_spinwheel.svg',
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: SvgPicture.asset(
                                          'assets/icons/HEART_STATUS_BAR.svg',
                                          width: 28,
                                          height: 28,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 10,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                            color: AppColors.textPrimary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: SvgPicture.asset(
                                            'assets/icons/icon_unlock.svg',
                                            width: 20,
                                            height: 20,
                                            color: AppColors.warning,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),

                                  const Text(
                                    'Unlock Your Date!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'เตรียมตัวไปสร้างเดทสุดพิเศษ\nกับคู่ของคุณกัน!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.btnPrimary,
                                          AppColors.btnHoverPrimary,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.btnPrimary
                                              .withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'ไปเดทกันเลย!',
                                        style: TextStyle(
                                          color: AppColors.btnTextPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
