import 'dart:async';
import 'dart:convert';

import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/calendar/calendar_modal.dart';
import 'package:chat2date/components/chat/bot_message_component.dart';
import 'package:chat2date/components/chat/chat_text_component.dart';
import 'package:chat2date/components/chat/input_chat_component.dart';
import 'package:chat2date/components/chat/spin_date_component.dart';
import 'package:chat2date/components/common/modal_component.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/modal/feature_guide_modal.dart';
import 'package:chat2date/components/modal/relationship_mission_modal.dart';
import 'package:chat2date/components/page/unlock_date_modal.dart';
import 'package:chat2date/components/status_bar/gps_alert.dart';
import 'package:chat2date/components/status_bar/score_row.dart';
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/models/appointment.dart';
import 'package:chat2date/models/chat_access_status.dart';
import 'package:chat2date/models/chat_message.dart';
import 'package:chat2date/models/relationship_bar.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/screens/game/guessing_game_screen.dart';
import 'package:chat2date/services/appointment_service.dart';
import 'package:chat2date/services/chat_service.dart';
import 'package:chat2date/services/chat_socket_service.dart';
import 'package:chat2date/services/date_recommend_service.dart';
import 'package:chat2date/services/emergency_service.dart';
import 'package:chat2date/services/game_service.dart';
import 'package:chat2date/services/game_socket_service.dart';
import 'package:chat2date/services/location_service.dart';
import 'package:chat2date/services/review_service.dart';
import 'package:chat2date/services/sos_service.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/game_store.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool firstTime = true;
  int talkCount = 0;
  int _steakDays = 0;
  bool _isFirstMessageBonus = false;
  int _dailyMessagesCount = 0;
  String nickname = '';
  List<Map<String, dynamic>> _dynamicPrizes = [];
  String? _myConfirmStatus = "";
  bool? _myReviewSatisfied;
  int? winningIndex;
  int _indexMode = 1;
  int _indexSelected = 1;
  String? _leaderId;
  double _currentRange = 20;

  // === Appointment / Calendar ===
  Appointment? _existingAppointment;
  bool _calendarHasUnreadUpdate = false;
  String _lastSpunPlaceId = ''; // ★ แก้: ไม่ใช่ final เพื่อให้อัพเดตได้
  String _lastSpunPlaceName = ''; // ★ แก้: ไม่ใช่ final เพื่อให้อัพเดตได้
  bool _isCalendarLoading = false;
  DateTime? _lastSpinTime;
  // overlay state (เหมือน SpinWheel)
  bool _showCalendarModal = false;
  String _calendarPlaceName = '';
  String _calendarPlaceId = '';
  bool _calendarIsEditMode = false;
  bool _calendarHasUnsavedChanges = false;
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
  StreamSubscription<Map<String, dynamic>>? _relationshipSubscription;
  StreamSubscription<Map<String, dynamic>>? _appointmentSubscription;
  StreamSubscription<Map<String, dynamic>>? _reviewSubscription;
  String? _currentUserId;
  bool _hasEntered = false;
  bool _hasExited = false;
  Timer? _seenStatusTimer;
  Timer?
  _markReadDebounce; // Debounce timer for marking incoming messages as read
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

  //Game
  GameSocketService? _gameSocketService;
  StreamSubscription? _gameSubscription;

  //Location
  List<String> _emergencyNumbers = [];

  void _initGameSocket() {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;

    final userState = ref.read(userStoreProvider);
    final accessToken = userState['accessToken'] as String?;

    _gameSocketService = GameSocketService(
      roomId: roomId,
      accessToken: accessToken,
    );
    _gameSocketService!.connect();

    _gameSubscription = _gameSocketService!.gameStream.listen((payload) {
      if (!mounted) return;

      final type = payload['type'];

      if (type == 'WAITING_START') {
        print("⏳ Received WAITING_START. Going to Waiting Room...");
        if (mounted) {
          _navigateToGameScreen(roomId);
        }
      }

      if (type == 'GAME_START') {
        print("🎮 Received GAME_START via Socket!");
        if (mounted) {
          _navigateToGameScreen(roomId);
        }
      }

      if (type == 'SCORE_UPDATE' || type == 'PLAYER_READY') {
        final userState = ref.read(userStoreProvider);
        final User? userObj = userState['user'] as User?;
        final myUserId = userObj?.userId;
        if (myUserId != null && mounted) {
          try {
            ref.read(gameProvider.notifier).socketMessage(payload, myUserId);
          } catch (e) {
            print("❌ Error forwarding event: $e");
          }
        }
      }
    });
  }

  List<ChatMessage> _updateBotMessagesByGameStatus(
    List<ChatMessage> messages,
    String gameStatus,
  ) {
    if (gameStatus == 'COMPLETED_FINISHED' || gameStatus == 'EXPIRED') {
      return messages.map((msg) {
        if ((msg.botType == BotMessageType.minigame ||
                msg.botType == BotMessageType.minigameFail) &&
            msg.botType != BotMessageType.ask) {
          return msg.copyWith(
            isActionDisabled: true,
            actionButtonText: 'เกมจบแล้ว',
          );
        }
        return msg;
      }).toList();
    }

    return _updateBotMessageStatus(messages);
  }

  @override
  void initState() {
    super.initState();
    // Register keyboard observer
    WidgetsBinding.instance.addObserver(this);
    // รับข้อมูลจาก arguments
    final userStore = ref.read(userStoreProvider);
    final userStoreMap = userStore as Map<String, dynamic>?;
    final user = userStoreMap?['user'] as User?;
    nickname = user?.nickname ?? 'คุณ';
    _chatUserId = widget.targetUserId;
    _chatUserName = widget.userName ?? 'Name';
    _chatUserAvatar = widget.avatarUrl;
    _scrollController.addListener(_handleScroll);
    _initUpdateRelationshipBar(false);
    _initializeChat();
    _initGameSocket();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <= 80) {
      _loadMoreMessages();
    }
  }

  Future<void> _handleAppointmentEvent(Map<String, dynamic> payload) async {
    if (!mounted) return;

    final type = payload['type'];
    if (type != 'APPOINTMENT_CHANGE') return;

    final actorUserId = payload['actorUserId'] as String?;
    final isSelfChange = actorUserId != null && actorUserId == _currentUserId;

    await _refreshCalendarAppointmentState(markAsSeen: isSelfChange);
  }

  //game
  Future<void> _handleGameStart() async {
    final roomId = widget.roomId;
    if (roomId == null) return;

    try {
      final statusData = await ref
          .read(gameServiceProvider)
          .checkGameStatus(roomId as int);

      // ✅ อัปเดต Switch Case ให้ตรงกับ Backend
      switch (statusData.gameStatus) {
        case 'NEW':
        case 'RESUME':
          _navigateToGameScreen(roomId);
          break;

        case 'RETRY_AVAILABLE':
          _addLocalBotMessage(
            type: BotMessageType.minigameFail,
            text: "เกมรอบที่แล้วยังไม่จบ/หลุด",
            description: "คุณสามารถเริ่มเกมใหม่ได้ทันที",
            actionText: "เริ่มเกมใหม่",
            isDisabled: false,
            remainingSeconds: statusData.remainingSeconds?.toInt() ?? 0,
            onAction: () {
              _navigateToGameScreen(roomId);
            },
          );
          break;

        // 🟢 กรณีชนะ/จบสมบูรณ์ (ต้องรอหลอดถัดไป)
        case 'COMPLETED_FINISHED':
          _addLocalBotMessage(
            type: BotMessageType.askSuccess, // หรือ minigameFail แล้วแต่ดีไซน์
            text: "คุณเล่นเกมรอบนี้สำเร็จแล้ว",
            description: "กรุณารอสะสมหลอดความสัมพันธ์เพื่อเล่นรอบถัดไป",
            actionText: "เจอกันรอบหน้า",
            isDisabled: true, // ❌ ปุ่มกดไม่ได้
          );
          break;

        // 🔴 กรณีหมดเวลา 24 ชม. แล้วยังไม่ชนะ (หมดสิทธิ์)
        case 'EXPIRED':
          _addLocalBotMessage(
            type: BotMessageType.minigameFail,
            text: "หมดเวลาการเล่นรอบนี้",
            description: "คุณพลาดโอกาสในรอบนี้ไปแล้ว",
            actionText: "ไม่สามารถเล่นได้",
            isDisabled: true,
          );
          break;
      }
    } catch (e) {
      print("Error checking game: $e");
    }
  }

  // ฟังก์ชันสำหรับจัดการสถานะปุ่มของ Bot Message
  List<ChatMessage> _updateBotMessageStatus(List<ChatMessage> messages) {
    if (messages.isEmpty) return messages;

    // 1. หาข้อความที่เป็นประเภท Fail ทั้งหมด
    final failMessages = messages
        .where((m) => m.botType == BotMessageType.minigameFail)
        .toList();

    if (failMessages.isEmpty) return messages;

    // 2. หาข้อความตัว "ล่าสุด" (Timestamp มากที่สุด)
    // ใช้ logic เปรียบเทียบเวลา
    final latestFailMsg = failMessages.reduce(
      (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b,
    );

    // 3. สร้าง List ใหม่ โดยไล่เช็คทีละข้อความ
    return messages.map((msg) {
      // ถ้าเป็น Fail Message และ "ไม่ใช่" ตัวล่าสุด
      if (msg.botType == BotMessageType.minigameFail &&
          msg.id != latestFailMsg.id) {
        // ให้ Copy object เดิม แต่แก้ค่าให้ปุ่ม Disabled
        return msg.copyWith(
          isActionDisabled: true, // ทำให้ปุ่มกดไม่ได้
          actionButtonText:
              'หมดเวลาแล้ว', // เปลี่ยนข้อความปุ่ม (ตามที่คุณต้องการ)
        );
      }
      // ถ้าเป็นตัวล่าสุด หรือข้อความอื่น ให้คืนค่าเดิม
      return msg;
    }).toList();
  }

  void _addLocalBotMessage({
    required BotMessageType type,
    required String text,
    String? description,
    String? actionText,
    bool isDisabled = false,
    int? remainingSeconds,
    VoidCallback? onAction,
  }) {
    final botMsg = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      isOwn: false,
      isBot: true,
      timestamp: DateTime.now(),
      botType: type,
      description: description,
      actionButtonText: actionText,
      isActionDisabled: isDisabled,
      remainingSeconds: remainingSeconds,
    );

    setState(() {
      _messages.add(botMsg);
      _scrollToBottom();
    });
  }

  bool _isNavigatingToGame = false;

  Future<void> _navigateToGameScreen(String roomId) async {
    if (_isNavigatingToGame) return; // ✅ block ทันที ก่อน delay
    _isNavigatingToGame = true; // ✅ ไม่ต้อง setState เพราะแค่ guard flag

    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) {
      _isNavigatingToGame = false;
      return;
    }

    try {
      await ref.read(gameServiceProvider).createGame(int.parse(roomId));
    } catch (e) {
      if (e.toString().contains('403')) {
        if (mounted) {
          Toast.show(
            context,
            type: ToastType.warning,
            title: 'ไม่สามารถเริ่มเกมได้',
            message: 'ต้องรอคู่ของคุณอยู่ในบทสนทนาก่อน',
            durationSeconds: 3,
            showCountdown: false,
          );
          Future.delayed(const Duration(seconds: 5), () {
            _isNavigatingToGame = false;
          });
        } else {
          _isNavigatingToGame = false;
        }
        return;
      }
      _isNavigatingToGame = false;
      rethrow;
    }

    setState(() {
      _messages = _messages.map((m) {
        if (m.isBot && !(m.isActionDisabled ?? false)) {
          return m.copyWith(
            isActionDisabled: true,
            actionButtonText: "เริ่มเกมไปแล้ว",
          );
        }
        return m;
      }).toList();
    });

    _gameSocketService?.dispose();
    _gameSubscription?.cancel();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuessingGameScreen(roomId: int.tryParse(roomId)),
      ),
    );

    if (mounted) {
      _initGameSocket();
    }

    _isNavigatingToGame = false;
    if (mounted) {
      await _initUpdateRelationshipBar(true);
      _initGameSocket();
    }
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return "-";
    final duration = Duration(seconds: seconds);
    return "${duration.inHours} ชม. ${duration.inMinutes % 60} นาที";
  }

  Future<void> _initUpdateRelationshipBar(bool onUpdate) async {
    int oldHeartCount = 10;

    if (onUpdate) {
      final chatService = ref.read(chatServiceProvider);
      final roomData = await chatService.updateRelationshipBar(widget.roomId!);
      if (!mounted) return;
      setState(() {
        oldHeartCount = _heartCount;
        if (roomData!.score >= 400) {
          _heartCount = 3; // ตันที่ 3 ดวง
          _currentPercent = 1.0; // ตันที่ 100% (1.0)
        } else {
          _heartCount = roomData.score ~/ 100;
          _currentPercent = (roomData.score % 100) / 100.0;
        }
        _steakDays = roomData.streakDays;
        _isFirstMessageBonus = roomData.isFirstMessageBonus;
        _dailyMessagesCount = roomData.dailyMessageCount;
      });

      if (oldHeartCount == 0 && _heartCount >= 1) {
        FocusScope.of(context).unfocus();
        await Future.delayed(const Duration(milliseconds: 300));
        _triggerUnlockDate();
      }
    } else {
      final chatService = ref.read(chatServiceProvider);
      final roomData =
          await chatService.getRelationshipBar(widget.roomId!)
              as RelationshipBar?;
      if (!mounted) return;
      setState(() {
        if (roomData!.score >= 400) {
          _heartCount = 3; // ตันที่ 3 ดวง
          _currentPercent = 1.0; // ตันที่ 100% (1.0)
        } else {
          _heartCount = roomData.score ~/ 100;
          _currentPercent = (roomData.score % 100) / 100.0;
        }
        _steakDays = roomData.streakDays;
        _isFirstMessageBonus = roomData.isFirstMessageBonus;
        _dailyMessagesCount = roomData.dailyMessageCount;
      });

      if (oldHeartCount == 0 && _heartCount >= 1) {
        FocusScope.of(context).unfocus();
        await Future.delayed(const Duration(milliseconds: 300));
        _triggerUnlockDate();
      }

      return;
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Scroll to bottom when keyboard opens
    final bottomInset = WidgetsBinding
        .instance
        .platformDispatcher
        .views
        .first
        .viewInsets
        .bottom;
    if (bottomInset > 0) {
      // Keyboard is visible - scroll to bottom after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _scrollController.hasClients) {
          _scrollToBottom();
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // กรณีพับหน้าจอ (Paused) หรือ ปิดแอป (Detached)
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      print("App is backgrounded or killed: Exiting room");
      _exitRoomOnce();
    }

    // กรณีกลับเข้ามาใหม่ (Resumed)
    if (state == AppLifecycleState.resumed) {
      if (_hasExited) {
        setState(() {
          _hasExited = false;
        });
        _enterRoom();
      }

      _fetchInitialAppointment();
    }
  }

  Future<void> _initializeChat() async {
    await _enterRoomOnce();
    await _loadChatRoomMessages();
    await _fetchInitialAppointment();
    await _initConfirmStatus();
    await _checkSpinWheelCondition();
    await _checkAndShowReviewModal();
    try {
      final numbers = await ref
          .read(emergencyCallServiceProvider)
          .getEmergencyCalls();
      if (mounted)
        setState(() {
          _emergencyNumbers = numbers;
          _isEmergencyLoaded = true;
        });
    } catch (_) {
      if (mounted) setState(() => _isEmergencyLoaded = true);
    }

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFeatureGuide();
      });
    }
  }

  Future<void> _initConfirmStatus() async {
    try {
      final service = ref.read(dateRecommendProvider);
      final status = await service.checkConfirmPlace(roomId: widget.roomId);

      if (mounted) {
        setState(() {
          _myConfirmStatus = status ?? "BLANK";
        });
      }
    } catch (e) {
      debugPrint('Error fetching confirm status: $e');
    }
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
      final gameStatus = await ref
          .read(gameServiceProvider)
          .checkGameStatus(int.parse(roomId));
      if (!mounted) return;
      final sortedMessages = [...roomData.messages]
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      setState(() {
        _messages = sortedMessages;
        _messages = _updateBotMessagesByGameStatus(
          _messages,
          gameStatus.gameStatus,
        );
        _isLoadingMessages = false;
        _messageIds
          ..clear()
          ..addAll(sortedMessages.map((message) => message.id));
        _hasMoreMessages = sortedMessages.length >= _pageSize;
        _relationshipScore = roomData.relationshipScore;
        _isChatDisabled = roomData.isChatDisabled;
        //  _applyRelationshipScore(roomData.relationshipScore);
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

  StreamSubscription? _scoreSubscription;

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
    int oldHeartCount = 10;
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
    _reviewSubscription = service.reviewStream.listen(_handleReviewEvent);
    _appointmentSubscription = service.appointmentStream.listen(
      _handleAppointmentEvent,
    );
    _relationshipSubscription = service.relationshipStream.listen((data) {
      if (!mounted) return;
      setState(() {
        oldHeartCount = _heartCount;
        if (data['score'] >= 400) {
          _heartCount = 3; // ตันที่ 3 ดวง
          _currentPercent = 1.0; // ตันที่ 100% (1.0)
        } else {
          _heartCount = data['score'] ~/ 100;
          _currentPercent = (data['score'] % 100) / 100.0;
        }
        _steakDays = data['streakDays'] ?? 0;
        _dailyMessagesCount = data['dailyMessageCount'] ?? 0;
        _isFirstMessageBonus = data['isFirstMessageBonus'] ?? false;
      });

      // เช็คเงื่อนไขปลดล็อกฟีเจอร์ใหม่ (เช่น หัวใจดวงแรก)
      if (oldHeartCount == 0 && _heartCount >= 1) {
        _triggerUnlockDate();
      }
    });

    _chatSocketService?.spinStream.listen((payload) {
      if (!mounted) return;

      final type = payload['type'];

      if (type == 'FRESH_MODE') {
        final rawData = payload['data'];
        Map<String, dynamic> data;
        try {
          if (rawData is String) {
            data = jsonDecode(rawData);
          } else {
            // ถ้ามาเป็น Map อยู่แล้ว (จังหวะดึงใหม่) ก็ใช้ได้เลย
            data = Map<String, dynamic>.from(rawData);
          }
          final String modeStr = payload['mode'] ?? 'MIDPOINT';
          final String targetStr = payload['userTarget'] ?? 'PARTNER';
          final String leaderIdFromSocket =
              payload['leaderId']?.toString() ?? '';

          setState(() {
            _showWheelModal = true;
            _leaderId = leaderIdFromSocket;

            _indexMode = (modeStr == 'DISTANCE') ? 0 : 1;

            if (_currentUserId == leaderIdFromSocket) {
              _indexSelected = (targetStr == nickname) ? 1 : 0;
            } else {
              _indexSelected = (targetStr == _chatUserName) ? 0 : 1;
            }

            final List placesList = data['places'] ?? [];
            _dynamicPrizes = placesList.map((place) {
              return {
                "name": place['name'],
                "imageUrl": place['imageUrl'],
                "placeId": place['googlePlaceId'], // เก็บไว้ใช้จองนัดหมาย
              };
            }).toList();
            _currentRange = (payload['range'] as num).toDouble();
            winningIndex = null;
          });
        } catch (e) {
          debugPrint("❌ Error in FRESH_MODE listener: $e");
        }
      } else if (type == 'CMD_SPIN_START') {
        setState(() {
          winningIndex = payload['winningIndex'];
        });
      } else if (type == 'CMD_CLOSE_MODAL') {
        _clearWheelState();
      }
    });

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
    setState(() {
      final existingIndex = _messages.indexWhere((m) => m.id == message.id);

      if (existingIndex != -1) {
        _messages[existingIndex] = message;
      } else {
        _messages.add(message);
        _messageIds.add(message.id);
      }

      if (message.isBot && message.gameStatus != null) {
        _messages = _updateBotMessagesByGameStatus(
          _messages,
          message.gameStatus!,
        );
      } else {
        _messages = _updateBotMessageStatus(_messages);
      }

      if (message.isBot) {
        _initConfirmStatus();
        unawaited(_fetchInitialAppointment());
        _checkSpinWheelCondition();
      }

      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animated: true);
    });
    // If the incoming message is from the other person (not ours),
    // mark it as read since we're currently viewing the chat.
    // This triggers the backend to broadcast "เห็นแล้ว" to the sender in real-time.
    // Debounced to avoid flooding the API when multiple messages arrive quickly.

    if (!message.isOwn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animated: true);
      });
      _markReadDebounce?.cancel();
      _markReadDebounce = Timer(const Duration(milliseconds: 500), () {
        _enterRoom();
      });
    }
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

  void _clearWheelState() {
    setState(() {
      _showWheelModal = false;
      _leaderId = null;
      winningIndex = null;
      _dynamicPrizes = [];
      _indexMode = 1;
      _currentRange = 20;
    });
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

  Future<void> _fetchInitialAppointment() async {
    await _refreshCalendarAppointmentState();
  }

  String _calendarSeenPrefsKey(String roomId) {
    final userId = _currentUserId ?? 'guest';
    return 'calendar_seen_appointment_${userId}_$roomId';
  }

  String _appointmentCalendarSignature(Appointment appointment) {
    final updatedAt = appointment.updatedAt?.toUtc().toIso8601String() ?? '';
    return '${appointment.appointmentId}:${appointment.status}:$updatedAt';
  }

  Future<void> _markCalendarAppointmentAsSeen(Appointment? appointment) async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final prefsKey = _calendarSeenPrefsKey(roomId);
    final signature = appointment == null
        ? null
        : _appointmentCalendarSignature(appointment);

    if (signature == null) {
      await prefs.remove(prefsKey);
    } else {
      await prefs.setString(prefsKey, signature);
    }

    if (!mounted) return;
    setState(() {
      _calendarHasUnreadUpdate = false;
    });
  }

  Future<void> _refreshCalendarAppointmentState({
    bool markAsSeen = false,
  }) async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;

    try {
      final appointmentService = ref.read(appointmentServiceProvider);
      final appointments = await appointmentService.getAppointments(
        int.parse(roomId),
      );

      final latestAppointment =
          _findLatestActiveAppointment(appointments) ??
          _findLatestNotActiveAppointment(appointments);

      final prefs = await SharedPreferences.getInstance();
      final prefsKey = _calendarSeenPrefsKey(roomId);
      final signature = latestAppointment == null
          ? null
          : _appointmentCalendarSignature(latestAppointment);
      final savedSignature = prefs.getString(prefsKey);

      if (markAsSeen) {
        if (signature == null) {
          await prefs.remove(prefsKey);
        } else {
          await prefs.setString(prefsKey, signature);
        }
      }

      if (!mounted) return;
      setState(() {
        _existingAppointment = latestAppointment;
        _calendarHasUnreadUpdate =
            signature != null && signature != savedSignature && !markAsSeen;
      });
    } catch (e) {
      debugPrint('Error refreshing appointment state: $e');
    }
  }

  Appointment? _findLatestActiveAppointment(List<Appointment> appointments) {
    final active =
        appointments
            .where(
              (a) => a.status == 'PLACE_SELECTED' || a.status == 'SCHEDULED',
            )
            .toList()
          ..sort((a, b) => b.appointmentId.compareTo(a.appointmentId));

    return active.isNotEmpty ? active.first : null;
  }

  Appointment? _findLatestNotActiveAppointment(List<Appointment> appointments) {
    final active =
        appointments
            .where((a) => a.status == 'CANCELLED' || a.status == 'COMPLETED')
            .toList()
          ..sort((a, b) => b.appointmentId.compareTo(a.appointmentId));

    return active.isNotEmpty ? active.first : null;
  }

  bool get _shouldShowCalendarIcon => _existingAppointment != null;

  bool get _isCalendarViewOnly {
    final appointment = _existingAppointment;
    if (appointment == null) return false;

    final status = appointment.status;
    if (status == 'CANCELLED' || status == 'COMPLETED') return true;

    final dateTime = appointment.dateTime;
    if (dateTime == null) return false;

    final today = DateUtils.dateOnly(DateTime.now());
    final appointmentDay = DateUtils.dateOnly(dateTime.toLocal());
    return !today.isBefore(appointmentDay);
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
    final day = thailandTime.day.toString().padLeft(2, '0');
    final month = thailandTime.month.toString().padLeft(2, '0');
    final year = thailandTime.year.toString();
    return '$weekday $day/$month/$year $hour:$minute';
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

    final day = thailandTime.day.toString().padLeft(2, '0');
    final month = thailandTime.month.toString().padLeft(2, '0');
    final year = thailandTime.year.toString();
    final hour = thailandTime.hour.toString().padLeft(2, '0');
    final minute = thailandTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
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

  void _onSpinComplete(Map<String, dynamic> result) async {
    setState(() {
      _lastSpinDate = DateTime.now();
      _lastSpunPlaceId = (result['placeId'] as String?) ?? '';
      _lastSpunPlaceName = (result['name'] as String?) ?? '';
    });
    _checkSpinWheelCondition();
    if (_leaderId == _currentUserId) {
      final service = ref.read(dateRecommendProvider);
      try {
        String mode = (_indexMode == 0) ? "DISTANCE" : "MIDPOINT";
        String userTarget = (_indexSelected == 1) ? "ME" : "PARTNER";
        await service.confirmPlace(
          roomId: widget.roomId,
          placeName: result['name'],
          action: 'BLANK',
          mode: mode,
          userTarget: userTarget,
        );
        await service.closeRemoteModal(widget.roomId!);
        _clearWheelState();
      } catch (e) {
        print("Error fetching date recommendations: $e");
      }
    }
  }

  /// เช็คเงื่อนไขว่า user ผ่านหรือไม่ก่อนเปิด spinwheel
  bool _checkUserEligibility() {
    // เงื่อนไขผ่าน: จำนวนหัวใจ >= 1 (0,1,2,3 โดย 3 จะเป็นรุ้ง)
    // ไม่ต้องเช็ค percent เพราะถ้าเต็มจะเป็น 1 อยู่แล้ว

    return _heartCount >= 1;
  }

  /// จัดการการกด spinwheel
  void _handleSpinwheelTap() async {
    if (!_canSpin) {
      // อยู่ใน cooldown - แสดง message
      if (_cooldownDays == 0) {
        Toast.show(
          context,
          type: ToastType.warning,
          title: "ไม่สามารถสุ่มใหม่ได้",
          message:
              "กรุณาสรุปสถานที่เดตปัจจุบัน หรือจัดการนัดหมายเดิมให้เสร็จก่อน",
        );
      } else {
        // 📢 กรณีติด Cooldown วัน
        Toast.show(
          context,
          type: ToastType.info,
          title: "อยู่ในช่วงพักเดต",
          message: "กรุณารอให้ครบกำหนด Cooldown ก่อนหมุนอีกครั้ง",
        );
      }
      return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('กรุณารออีก $_cooldownDays วันก่อนหมุนได้อีกครั้ง'),
      //     backgroundColor: AppColors.textMuted,
      //   ),
      // );
      // return;
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

    await _prepareBeforeSpin(20, "MIDPOINT", "", false);
    // ผ่านทุกเงื่อนไข - เปิด modal
    setState(() {
      _showWheelModal = true;
    });
  }

  Future<void> _prepareBeforeSpin(
    double range,
    String? mode,
    String? userTarget,
    bool refresh,
  ) async {
    final service = ref.read(dateRecommendProvider);

    try {
      final recommendations = await service.getRecommendations(
        roomId: widget.roomId,
        range: range.round(),
        mode: mode,
        userTarget: userTarget,
        forceRefresh: refresh,
      );
      if (!mounted) return;
      setState(() {
        _dynamicPrizes = recommendations.places.map((place) {
          return {
            "name": place.name,
            "imageUrl": place.imageUrl,
            "placeId": place.googlePlaceId,
          };
        }).toList();
      });
    } catch (e) {
      if (!mounted) return;

      Toast.show(
        context,
        type: ToastType.error,
        title: 'ไม่สามารถโหลดข้อมูลสถานที่ได้',
        message: e.toString().replaceAll('Exception: ', ''),
        durationSeconds: 3,
      );
      _clearWheelState();
      await ref.read(dateRecommendProvider).closeRemoteModal(widget.roomId!);
    }
  }

  // ===================== Calendar / Appointment Logic =====================

  /// กด Calendar icon ใน Header: เปิด modal สร้าง/แก้ไขนัดหมาย
  Future<void> _handleCalendarTap() async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;

    if (_isCalendarLoading) return;
    setState(() => _isCalendarLoading = true);

    try {
      await _refreshCalendarAppointmentState(markAsSeen: true);

      if (!mounted) return;
      setState(() {
        _isCalendarLoading = false;
      });

      _showCalendarModalSheet();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCalendarLoading = false);
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ไม่สามารถโหลดข้อมูลนัดหมายได้',
        message: e.toString().replaceAll('Exception: ', ''),
        durationSeconds: 3,
        showCountdown: false,
      );
    }
  }

  /// แสดง CalendarModal overlay (เหมือน SpinWheel)
  void _showCalendarModalSheet() {
    final existing = _existingAppointment;
    final isEditMode = existing != null;
    final placeName = isEditMode ? existing.placeName : _lastSpunPlaceName;
    final placeId = isEditMode ? existing.placeId : _lastSpunPlaceId;
    setState(() {
      _calendarPlaceName = placeName;
      _calendarPlaceId = placeId;
      _calendarIsEditMode = isEditMode;
      _calendarHasUnsavedChanges = false;
      _showCalendarModal = true;
    });
  }

  /// ปิด CalendarModal overlay
  void _closeCalendar() {
    setState(() {
      _showCalendarModal = false;
      _calendarHasUnsavedChanges = false;
    });
  }

  /// บันทึกนัดหมาย (create หรือ update)
  Future<void> _saveAppointment({
    required DateTime date,
    required bool isEditMode,
    int? existingId,
    required String placeId,
    required String placeName,
  }) async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;

    try {
      final service = ref.read(appointmentServiceProvider);
      Appointment result;
      if (isEditMode && existingId != null) {
        result = await service.updateAppointment(
          appointmentId: existingId,
          dateTime: date,
        );
      } else {
        result = await service.createAppointment(
          roomId: int.parse(roomId),
          placeId: placeId.isNotEmpty ? placeId : 'unknown',
          placeName: placeName.isNotEmpty ? placeName : 'ไม่ระบุชื่อสถานที่',
          dateTime: date,
        );
      }

      if (!mounted) return;
      setState(() => _existingAppointment = result);
      await _markCalendarAppointmentAsSeen(result);
      _showSaveSuccessDialog(result);
    } catch (e) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ไม่สามารถบันทึกนัดหมายได้',
        message: e.toString().replaceAll('Exception: ', ''),
        durationSeconds: 3,
        showCountdown: false,
      );
    }
  }

  /// State 2: success dialog หลังบันทึก
  void _showSaveSuccessDialog(Appointment appointment) {
    final dt = appointment.dateTime?.toLocal();
    String dateStr;
    if (dt != null) {
      final thaiMonths = [
        'มกราคม',
        'กุมภาพันธ์',
        'มีนาคม',
        'เมษายน',
        'พฤษภาคม',
        'มิถุนายน',
        'กรกฎาคม',
        'สิงหาคม',
        'กันยายน',
        'ตุลาคม',
        'พฤศจิกายน',
        'ธันวาคม',
      ];
      final hour = dt.hour;
      final amPm = hour < 12 ? 'AM' : 'PM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      dateStr =
          '${dt.day} ${thaiMonths[dt.month - 1]} ${dt.year} $hour12:$minute $amPm';
    } else {
      dateStr = 'ยังไม่ได้ระบุวันที่';
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'บันทึกเสร็จสิ้น',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dateStr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'ระบบจะแจ้งเตือนก่อนวันนัด 1 วัน',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),
              DsButton(
                label: 'ตกลง',
                variant: DsButtonVariant.primary,
                size: DsButtonSize.md,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// State 6: ยืนยันก่อนยกเลิกการแก้ไข (close X ใน edit mode)
  void _showCancelEditConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ModalComponent(
          svgPath: 'assets/icons/ui/icon_warning.svg',
          heightSvg: 68,
          widthSvg: 77,
          topic: 'ยกเลิกการแก้ไข',
          description:
              'ต้องการยกเลิกวันออกเดตใช่หรือไม่\nข้อมูลที่เลือกจะสูญหาย',
          choice: true,
          firstChoiceText: 'ออกจากหน้า',
          secondChoiceText: 'กลับไปแก้ต่อ',
          onFirstChoice: () {
            Navigator.pop(ctx);
            _closeCalendar();
          },
          onSecondChoice: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  /// State 7: ยืนยันยกเลิกนัดหมาย
  void _showDeleteConfirmDialog(int appointmentId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ModalComponent(
          svgPath: 'assets/icons/ui/icon_warning.svg',
          heightSvg: 68,
          widthSvg: 77,
          topic: 'ยืนยันที่จะยกเลิกวันเดตหรือไม่',
          description:
              'หากยืนยัน ระบบจะยกเลิกนัดหมายนี้ และคุณจะต้องสุ่มสถานที่ใหม่อีกครั้ง',
          choice: true,
          firstChoiceText: 'ยืนยัน',
          secondChoiceText: 'ยกเลิก',
          onFirstChoice: () {
            Navigator.pop(ctx);
            _closeCalendar();
            _deleteAppointment(appointmentId);
          },
          onSecondChoice: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  /// ยกเลิก appointment + แสดง State 8 success
  Future<void> _deleteAppointment(int appointmentId) async {
    try {
      final service = ref.read(appointmentServiceProvider);
      await service.deleteAppointment(appointmentId);
      if (!mounted) return;
      setState(() => _existingAppointment = null);
      await _markCalendarAppointmentAsSeen(null);
      _showDeleteSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ไม่สามารถยกเลิกนัดหมายได้',
        message: e.toString().replaceAll('Exception: ', ''),
        durationSeconds: 3,
        showCountdown: false,
      );
    }
  }

  /// State 8: แสดง success dialog หลังยกเลิก
  void _showDeleteSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ลบสำเร็จแล้ว',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ยกเลิกวันเดตเรียบร้อยแล้ว\nนัดหมายนี้ถูกปรับเป็นยกเลิกแล้ว',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),
              DsButton(
                label: 'ตกลง',
                variant: DsButtonVariant.primary,
                size: DsButtonSize.md,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkSpinWheelCondition() async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;

    try {
      final service = ref.read(dateRecommendProvider);
      final data = await service.checkStatusSpin(roomId: roomId);

      _canSpin = data['canSpin'] ?? false;
      if (_canSpin && _existingAppointment != null) {
        try {
          await service.deleteAppointmentAfterCooldown(roomId: roomId);
          if (mounted) setState(() => _existingAppointment = null);
        } catch (e) {
          debugPrint('Delete appointment error: $e');
        }
      }

      if (!mounted) return;

      setState(() {
        _canSpin = data['canSpin'];
        _cooldownDays = data['cooldownDays'];

        if (_heartCount == 0) {
          _headerVariant = ChatHeaderVariant.chat1;
          _canSpin = false; // ป้องกันการกดผ่าน SnackBar
          return;
        }
        if (_canSpin) {
          if (_cooldownDays == 0) {
            _headerVariant = ChatHeaderVariant.chat3;
          } else {
            _headerVariant = ChatHeaderVariant.chat2;
          }
        } else {
          _headerVariant = ChatHeaderVariant.chat4;
        }
      });
    } catch (e) {
      debugPrint("Error in _checkSpinWheelCondition: $e");
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
        if (!_messageIds.contains(sentMessage.id)) {
          _messages.add(sentMessage);
          _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          _messageIds.add(sentMessage.id);
        }
        _isSending = false;
      });
      _scrollToBottom();
      _initUpdateRelationshipBar(true);
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

  void _triggerUnlockDate() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _showUnlockDate = true;
      _headerVariant = ChatHeaderVariant.chat2;
    });

    // นับถอยหลัง 5 วินาทีแล้วปิด
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showUnlockDate = false;
        });
      }
    });
  }

  Future<void> _handleConfirmAction(ChatMessage message, String action) async {
    final service = ref.read(dateRecommendProvider);
    try {
      // LAYER 1: เช็คสถานะล่าสุดจาก Server ก่อน (Double Check ตามที่คุณต้องการ)
      final latestStatus = await service.checkConfirmPlace(
        roomId: widget.roomId,
      );

      if (latestStatus != null && latestStatus != "BLANK") {
        setState(() {
          _myConfirmStatus = latestStatus;
        });
        return;
      }

      String firstPart = message.text.split('|').first.trim();
      String placeNameOnly = firstPart
          .replaceAll('สุ่มได้ไปเที่ยวที่ ', '')
          .replaceAll(' !!!', '')
          .trim();
      await service.confirmPlace(
        roomId: widget.roomId,
        placeName: placeNameOnly,
        action: action,
      );

      setState(() {
        _myConfirmStatus = action;
      });
    } catch (e) {
      debugPrint('Confirm Error: $e');
    }
  }

  //review & emergency suggestion
  bool _isResultModalShown = false;
  bool _hasShownBadEnding = false;
  bool _hasShownEmergencySuggestion = false;
  bool _isEmergencyLoaded = false;
  Future<void> _handleReviewEvent(Map<String, dynamic> payload) async {
    if (!mounted) return;
    final type = payload['type'];

    if (type == 'REVIEW_WAITING') {
      _showWaitingModal();
      return;
    }

    if (type == 'REVIEW_RESULT') {
      await _fetchInitialAppointment();
      final outcome = payload['outcome'] as String?;

      if (mounted) {
        final currentRoute = ModalRoute.of(context);
        try {
          final nav = Navigator.of(context, rootNavigator: false);
          if (currentRoute != null && !currentRoute.isCurrent) {
            nav.pop();
          }
        } catch (_) {}
      }

      if (_isResultModalShown &&
          outcome != 'UNMATCH' &&
          outcome != 'CONTINUE') {
        return;
      }
      _isResultModalShown = true;

      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;

      switch (outcome) {
        case 'BOTH_SATISFIED':
          _showGoodEndingModal();
          break;
        case 'ONE_SIDED':
          _showOneSidedModal(appt: _existingAppointment!);
          break;
        case 'BOTH_UNSATISFIED':
          if (!_hasShownBadEnding) {
            _hasShownBadEnding = true;
            _showBadEndingModal(appt: _existingAppointment!);
          } else {
            _isResultModalShown = false;
          }
          break;
        case 'CONTINUE':
          await _initUpdateRelationshipBar(false);
          _showGoodEndingModal();
          break;
        case 'UNMATCH':
          Toast.show(
            context,
            type: ToastType.info,
            title: 'แยกย้าย',
            message: 'ยุติความสัมพันธ์เรียบร้อยแล้ว',
            durationSeconds: 2,
            showCountdown: false,
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
          break;
      }
    }
  }

  // ==================== Review Flow ====================
  bool _isReviewModalShown = false;
  Future<void> _checkAndShowReviewModal() async {
    if (_isReviewModalShown) return;

    final appt = _existingAppointment;
    if (appt == null ||
        appt.dateTime == null ||
        !DateTime.now().isAfter(
          appt.dateTime!.toLocal().add(const Duration(hours: 3)),
        )) {
      return;
    }

    try {
      final reviewService = ref.read(reviewServiceProvider);
      final isReviewed = await reviewService.checkReviewStatus(
        appt.appointmentId,
      );
      if (!mounted) return;

      if (!isReviewed) {
        setState(() => _isReviewModalShown = true);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) _showReviewFlow();
      }
    } catch (e) {
      debugPrint('Error checking review status: $e');
    }
  }

  void _showReviewFlow() {
    final appt = _existingAppointment;
    if (appt == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ModalComponent(
          imagePath: _chatUserAvatar,
          heightSvg: 68,
          widthSvg: 77,
          imageName: _chatUserName,
          topic: 'ประเมินคู่เดตของคุณ',
          topicTop: true,
          description: 'คุณพึงพอใจกับคู่เดตของคุณหรือไม่',
          choice: true,
          firstChoiceText: 'ไม่พอใจ',
          secondChoiceText: 'พอใจ',
          subDescription: true,
          headingSubDescriptionText: 'คำเตือน: ',
          subDescriptionText:
              'การเลือกจะมีผลต่อความสัมพันธ์คู่ของคุณ\n'
              'พึงพอใจทั้งคู่ ถือว่าทั้งคู่ประสบความสำเร็จ\n'
              'ไม่พึงพอใจทั้งคู่ จะมีให้เลือกว่าจะ unmatch หรือไม่\n'
              'ไม่พอใจฝ่ายใดฝ่ายหนึ่ง จะมีให้เลือกไปต่อหรือพอแค่นี้\n'
              'หากฝ่ายใดฝ่ายหนึ่งเลือก unmatch หรือ พอแค่นี้ จะจบทันที',
          onFirstChoice: () async {
            Navigator.pop(ctx);
            setState(() => _myReviewSatisfied = false);
            await _submitReview(appt: appt, isSatisfied: false);
          },
          onSecondChoice: () async {
            Navigator.pop(ctx);
            setState(() => _myReviewSatisfied = true);
            await _submitReview(appt: appt, isSatisfied: true);
          },
        ),
      ),
    );
  }

  Future<void> _submitReview({
    required Appointment appt,
    required bool isSatisfied,
  }) async {
    try {
      final reviewService = ref.read(reviewServiceProvider);
      await reviewService.submitReview(
        appointmentId: appt.appointmentId,
        targetUserId: _chatUserId ?? '',
        isSatisfied: isSatisfied,
        wantToContinue: null,
        wantToUnmatch: null,
      );
    } catch (e) {
      print("❌ submitReview error: $e");
    }
  }

  void _showWaitingModal() {
    final dialogKey = GlobalKey();
    bool isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 5), () {
          if (isDialogOpen && ctx.mounted) {
            isDialogOpen = false;
            Navigator.of(ctx).pop();
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: ModalComponent(
            svgPath: 'assets/icons/ui/icon_done.svg',
            heightSvg: 78,
            widthSvg: 77,
            topic: 'รอผลการประเมิน',
            description:
                'คุณได้ทำการประเมินเรียบร้อยแล้ว\n'
                'รอให้อีกฝ่ายประเมินสักครู่นะ\n'
                'ระบบจะแจ้งเตือนเมื่ออีกฝ่ายตอบแล้ว',
            spaceBottom: 15,
            spaceTop: 15,
          ),
        );
      },
    ).then((_) => isDialogOpen = false);
  }

  void _showGoodEndingModal() {
    bool isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 5), () {
          if (isDialogOpen && ctx.mounted) {
            isDialogOpen = false;
            Navigator.of(ctx).pop();
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: ModalComponent(
            svgPath: 'assets/icons/ui/icon_good-ending.svg',
            heightSvg: 68,
            widthSvg: 77,
            topic: 'ยินดีด้วย!',
            description:
                'คุณทั้งคู่มีความเห็นตรงกัน\n'
                'หวังว่าการเดินทางครั้งนี้\n'
                'จะเป็นก้าวแรกของความสัมพันธ์ที่ดีขึ้นไปอีก\n\n'
                '🎉 +20 คะแนนความสัมพันธ์',
            spaceBottom: 15,
            spaceTop: 15,
          ),
        );
      },
    ).then((_) async {
      isDialogOpen = false;
      _isResultModalShown = false;
      await _initUpdateRelationshipBar(false);
    });
  }

  void _showOneSidedModal({required Appointment appt}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ModalComponent(
          svgPath: 'assets/icons/ui/icon_one-sided.svg',
          heightSvg: 68,
          widthSvg: 77,
          topic: 'มีฝ่ายหนึ่งรู้สึกไม่พอใจกับการเดินทางครั้งนี้',
          description:
              'คุณต้องการเปิดโอกาสพูดคุยเพื่อทำความเข้าใจและ\n'
              'ไปต่อกับคู่ของคุณหรือไม่?',
          choice: true,
          firstChoiceText: 'ไม่ต้องการ',
          secondChoiceText: 'ต้องการ',
          onFirstChoice: () async {
            // ไม่ต้องการไปต่อ
            Navigator.pop(ctx);
            await _submitWantToContinue(
              appt: appt,
              wantToContinue: false,
              wantToUnmatch: null,
            ); // ส่ง null
          },
          onSecondChoice: () async {
            // ต้องการไปต่อ
            Navigator.pop(ctx);
            await _submitWantToContinue(
              appt: appt,
              wantToContinue: true,
              wantToUnmatch: null,
            ); // ส่ง null
          },
        ),
      ),
    ).then((_) => _isResultModalShown = false);
  }

  void _showBadEndingModal({required Appointment appt}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ModalComponent(
          svgPath: 'assets/icons/ui/icon_bad-ending.svg',
          heightSvg: 68,
          widthSvg: 77,
          topic: 'เสียใจด้วย',
          description: 'ต้องการ ยกเลิกการจับคู่ (Unmatch) กับคู่ของคุณหรือไม่?',
          choice: true,
          firstChoiceText: 'ไม่ต้องการ',
          secondChoiceText: 'ต้องการ',
          onFirstChoice: () async {
            // ไม่ต้องการ Unmatch = ไปต่อ
            Navigator.pop(ctx);
            await _submitWantToContinue(
              appt: appt,
              wantToContinue: null,
              wantToUnmatch: false,
            );
          },
          onSecondChoice: () async {
            // ต้องการ Unmatch = จบกัน
            Navigator.pop(ctx);
            await _submitWantToContinue(
              appt: appt,
              wantToContinue: null,
              wantToUnmatch: true,
            );
          },
        ),
      ),
    ).then((_) => _isResultModalShown = false);
  }

  Future<void> _submitWantToContinue({
    required Appointment appt,
    bool? wantToContinue,
    bool? wantToUnmatch,
  }) async {
    try {
      final reviewService = ref.read(reviewServiceProvider);
      await reviewService.submitReview(
        appointmentId: appt.appointmentId,
        targetUserId: _chatUserId ?? '',
        isSatisfied: _myReviewSatisfied ?? false,
        wantToContinue: wantToContinue,
        wantToUnmatch: wantToUnmatch,
      );
    } catch (e) {
      debugPrint('submitWantToContinue error: $e');
    }
  }

  //Real time
  void _showEmergencyNumberSuggestionDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ModalComponent(
          svgPath: 'assets/icons/ui/icon_warning.svg',
          heightSvg: 68,
          widthSvg: 77,
          topic: 'เพื่อความปลอดภัยของคุณ',
          description:
              'คุณยังไม่ได้กรอกเบอร์โทรฉุกเฉิน\n'
              'หากเกิดเหตุฉุกเฉิน ระบบจะแสดงปุ่มโทรหา 191\n\n'
              'ต้องการเพิ่มเบอร์คนใกล้ชิดเพื่อกดโทรได้ทันทีไหม?',
          choice: true,
          firstChoiceText: 'ไม่ต้องการ',
          secondChoiceText: 'เพิ่มเบอร์',
          spaceTop: 15,
          spaceBottom: 15,
          onFirstChoice: () => Navigator.pop(ctx),
          onSecondChoice: () {
            Navigator.pop(ctx);
            Navigator.pushNamed(context, '/account-settings');
          },
        ),
      ),
    );
  }

  /// สร้าง Widget สำหรับแต่ละ message
  Widget _buildMessageWidget(
    ChatMessage message,
    int index, {
    required int latestOwnIndex,
  }) {
    // Bot message
    if (message.isBot && message.botType != null) {
      final bool isAlreadyActioned =
          _myConfirmStatus != null && _myConfirmStatus != 'BLANK';
      return BotMessageComponent.fromMessage(
        message: message,
        onActionPressed: () async {
          if (message.botType == BotMessageType.ask && isAlreadyActioned) {
            return;
          }
          if (message.isActionDisabled ?? false) return;
          _navigateToGameScreen(widget.roomId!);
          setState(() {
            _messages[index] = message.copyWith(
              isActionDisabled: true,
              actionButtonText: "เริ่มเกมไปแล้ว",
            );
          });
          if (message.botType == BotMessageType.minigame ||
              message.botType == BotMessageType.minigameFail) {
            print("🚀 Navigating to Game...");
            _navigateToGameScreen(widget.roomId!);
          } else {
            print("⚠️ Unhandled bot type: ${message.botType}");
          }
        },
        onFirstChoice: isAlreadyActioned
            ? null
            : () async {
                await _handleConfirmAction(message, 'AGREED');
              },
        onSecondChoice: isAlreadyActioned
            ? null
            : () async {
                await _handleConfirmAction(message, 'DISAGREED');
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
                svgPath: 'assets/icons/ui/icon_seen.svg',
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

  void _showFeatureGuide() async {
    final userState = ref.read(userStoreProvider);
    final userService = ref.read(userServiceProvider);
    final userObj = userState['user'] as User?;
    final fetchUser = await userService.getUser(userObj!.userId);

    if (fetchUser?.isTutorial == false) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const FeatureGuideModal(),
      );
      try {
        final user = User(
          userId: fetchUser!.userId,
          version: fetchUser.version,
          isTutorial: true,
        );
        final updatedUser = await userService.updateUser(user);
      } catch (e) {
        debugPrint('Error updating tutorial status: $e');
      }
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
    _markReadDebounce?.cancel();
    _exitRoomOnce();
    _messageController.dispose();
    _scrollController.dispose();
    _gameSocketService?.dispose();
    _gameSubscription?.cancel();
    _relationshipSubscription?.cancel();
    _appointmentSubscription?.cancel();
    _reviewSubscription?.cancel();
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
                    showCalendar: _shouldShowCalendarIcon,
                    showFlag: !_isChatDisabled,
                    calendarHasUnreadUpdate: _calendarHasUnreadUpdate,
                    showBorder: false,
                    onBack: () async {
                      await _exitRoomOnce();
                      if (!mounted) return;
                      Navigator.maybePop(context);
                    },
                    onCalendar: _handleCalendarTap,
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
                                onRightIconTap: () => {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors
                                        .transparent, // เพื่อให้เห็นเงาโค้งของ Container ข้างใน
                                    builder: (context) => RelationshipMissionModal(
                                      heart: _heartCount,
                                      currentScore: (_currentPercent * 100)
                                          .round(),
                                      isFirstMessageBonus: _isFirstMessageBonus,
                                      streakDays:
                                          _steakDays, // ใช้ตัวแปรใน State ของคุณ
                                      dailyMessages:
                                          _dailyMessagesCount, // ใช้ตัวแปรใน State ของคุณ
                                    ),
                                  ),
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_existingAppointment != null &&
                            _existingAppointment!.dateTime != null)
                          Builder(
                            builder: (context) {
                              final now = DateTime.now();
                              final appointmentTime = _existingAppointment!
                                  .dateTime!
                                  .toLocal();

                              final dateStartTime = appointmentTime.subtract(
                                const Duration(hours: 2),
                              );
                              final dateEndTime = appointmentTime.add(
                                const Duration(hours: 3),
                              );

                              // เช็กว่าเลยเวลานัดมาแล้ว AND ยังไม่หมดเวลาเดต
                              if (now.isAfter(dateStartTime) &&
                                  now.isBefore(dateEndTime)) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (_emergencyNumbers.isEmpty &&
                                      mounted &&
                                      !_hasShownEmergencySuggestion &&
                                      _isEmergencyLoaded) {
                                    _hasShownEmergencySuggestion = true;
                                    _showEmergencyNumberSuggestionDialog();
                                  }
                                });
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: GpsMapAlert(
                                    emergencyNumbers: _emergencyNumbers,
                                    destinationPlaceId:
                                        _existingAppointment?.placeId,
                                    googleApiKey:
                                        dotenv.env['GOOGLE_API_KEY'] ?? '',
                                    onLocate: () {
                                      Toast.show(
                                        context,
                                        type: ToastType.info,
                                        title: 'อัปเดตตำแหน่ง',
                                        message: 'กำลังดึงพิกัดล่าสุด...',
                                        durationSeconds: 2,
                                        showCountdown: false,
                                      );
                                    },
                                    onShareLocation: () async {
                                      try {
                                        final pos =
                                            await Geolocator.getCurrentPosition();

                                        final shareUrl = await ref
                                            .read(locationServiceProvider)
                                            .shareLocation(
                                              latitude: pos.latitude,
                                              longitude: pos.longitude,
                                            );

                                        if (shareUrl.isNotEmpty) {
                                          await Share.share(
                                            'ฉันกำลังไปเดตนะ! สามารถติดตามโลเคชันแบบเรียลไทม์ของฉันได้ที่ลิงก์นี้เลย:\n$shareUrl',
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          Toast.show(
                                            context,
                                            type: ToastType.error,
                                            title: 'ข้อผิดพลาด',
                                            message: 'ไม่สามารถแชร์โลเคชันได้',
                                            durationSeconds: 3,
                                            showCountdown: false,
                                          );
                                        }
                                      }
                                    },
                                    onSosTriggered: (calledNumber) async {
                                      try {
                                        final pos =
                                            await Geolocator.getCurrentPosition(
                                              desiredAccuracy:
                                                  LocationAccuracy.high,
                                            );

                                        await ref
                                            .read(sosServiceProvider)
                                            .triggerSos(
                                              appointmentId:
                                                  _existingAppointment!
                                                      .appointmentId,
                                              latitude: pos.latitude,
                                              longitude: pos.longitude,
                                              calledNumber: calledNumber,
                                            );
                                      } catch (e) {
                                        if (mounted) {
                                          Toast.show(
                                            context,
                                            type: ToastType.error,
                                            title: 'ผิดพลาด',
                                            message:
                                                'ไม่สามารถส่งข้อมูล SOS ได้',
                                            durationSeconds: 3,
                                            showCountdown: false,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        const SizedBox(height: 6),
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
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.block,
                                  color: Colors.grey.shade600,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'ไม่สามารถส่งข้อความได้เนื่องจากมีการรายงาน',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          InputChatComponent(
                            svgPathLast: 'assets/icons/ui/icon_send.svg',
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

              //ปุ่มเทสเกม
              // Positioned(
              //   top: 100, // ปรับตำแหน่งแนวตั้ง (ให้หลบ Header)
              //   right: 0, // ชิดขวา
              //   child: Container(
              //     decoration: const BoxDecoration(
              //       color: Colors.red, // สีแดงเด่นๆ ให้รู้ว่าเป็นปุ่ม Test
              //       borderRadius: BorderRadius.only(
              //         topLeft: Radius.circular(20),
              //         bottomLeft: Radius.circular(20),
              //       ),
              //     ),
              //     child: IconButton(
              //       icon: const Icon(
              //         Icons.videogame_asset,
              //         color: Colors.white,
              //       ),
              //       onPressed: () async {
              //         // ✅ แบบที่ถูก: ยิงไปบอก Server ให้ Server สั่งเปิดเกมพร้อมกัน
              //         final roomId = widget.roomId;
              //         // ⚠️ เปลี่ยน IP เป็น IP เครื่องคอมคุณ
              //         final url = Uri.parse(
              //           'http://cp25ssi2.sit.kmutt.ac.th:8080/api/v1/test/trigger-game/$roomId',
              //         );
              //         try {
              //           print("Shooting trigger to $url");
              //           await http.post(url);
              //         } catch (e) {
              //           print("Error triggering game: $e");
              //         }
              //       },
              //     ),
              //   ),
              // ),
              if (_showWheelModal) ...[
                // 1. ฉากหลังสีเทาจาง (Dim background)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () async {
                      if (_currentUserId == _leaderId) {
                        await ref
                            .read(dateRecommendProvider)
                            .closeRemoteModal(widget.roomId!);
                        _clearWheelState();
                      } else {
                        Toast.show(
                          context,
                          type: ToastType.warning,
                          title: "ไม่สามารถปิดได้",
                          message: "กรุณารอคู่ของคุณจัดการวงล้อ",
                        );
                      }
                    },
                    child: Container(color: Colors.black.withOpacity(0.5)),
                  ),
                ),

                // 2. ตัว SpinDateComponent
                // ✅ ใช้ Positioned.fill เพื่อกำหนดขอบเขตพื้นที่ที่เหลือจาก Header
                Positioned.fill(
                  top: 0, // เริ่มต้นที่ขอบล่างของ Header
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
                                  key: ValueKey(
                                    '${_leaderId}_${_indexMode}_$_indexSelected',
                                  ),
                                  currentRange: _currentRange,
                                  indexMode: _indexMode,
                                  indexSelected: _indexSelected,
                                  winningIndex: winningIndex,
                                  isLeader: _currentUserId == _leaderId,
                                  onTriggerSpin: () async {
                                    await ref
                                        .read(dateRecommendProvider)
                                        .triggerSpin(widget.roomId!);
                                  },
                                  onCloseModal: () async {
                                    if (_currentUserId == _leaderId) {
                                      setState(() => _showWheelModal = false);
                                      await ref
                                          .read(dateRecommendProvider)
                                          .closeRemoteModal(widget.roomId!);
                                    } else {
                                      Toast.show(
                                        context,
                                        type: ToastType.warning,
                                        title: "ไม่สามารถปิดได้",
                                        message: "กรุณารอคู่ของคุณจัดการวงล้อ",
                                      );
                                    }
                                  },
                                  onSpinComplete: _onSpinComplete,
                                  firstPersonName: _chatUserName,
                                  secondPersonName: nickname,
                                  prizes: _dynamicPrizes,
                                  onFilterChanged:
                                      (mode, target, radius, isRefresh) async {
                                        if (_currentUserId != _leaderId) {
                                          Toast.show(
                                            context,
                                            type: ToastType.warning,
                                            title: "สิทธิ์ถูกจำกัด",
                                            message:
                                                "เฉพาะหัวหน้าห้องเท่านั้นที่เปลี่ยนโหมดได้",
                                          );
                                          return; // 🛑 หยุดการทำงาน ไม่ให้สั่ง setState หรือยิง API
                                        }

                                        setState(() {
                                          _indexMode = (mode == 'DISTANCE')
                                              ? 0
                                              : 1;
                                          _indexSelected = (target == nickname)
                                              ? 1
                                              : 0;
                                        });
                                        if (isRefresh) {
                                          await _prepareBeforeSpin(
                                            radius,
                                            mode,
                                            target,
                                            isRefresh,
                                          );
                                          setState(() {
                                            _lastSpinTime = DateTime.now();
                                          });
                                        } else {
                                          _prepareBeforeSpin(
                                            radius,
                                            mode,
                                            target,
                                            isRefresh,
                                          );
                                        }
                                      },
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
              UnlockDateModal(
                isVisible: _showUnlockDate,
                onConfirm: () {
                  setState(() {
                    _showUnlockDate = false;
                  });
                },
              ),

              // === Calendar Modal (เหมือน SpinWheel overlay) ===
              if (_showCalendarModal) ...[
                CalendarModal(
                  isVisible: _showCalendarModal,
                  placeName: _calendarPlaceName,
                  placeCountText: 'คุณมี 1 สถานที่เดต!!',
                  hasUnsavedChanges: _calendarHasUnsavedChanges,
                  isReadOnly: _calendarIsEditMode && _isCalendarViewOnly,
                  initialMonth: () {
                    final dt = _calendarIsEditMode
                        ? (_existingAppointment?.dateTime?.toLocal() ??
                              DateTime.now())
                        : DateTime.now();
                    return DateTime(dt.year, dt.month, 1);
                  }(),
                  // ★ แก้: เปิดใหม่ (new) = null ไม่มีเวลา default
                  //         edit mode = เวลาที่นัดไว้
                  initialTime: _calendarIsEditMode
                      ? () {
                          final dt =
                              _existingAppointment?.dateTime?.toLocal() ??
                              DateTime.now();
                          return TimeOfDay.fromDateTime(dt);
                        }()
                      : null,
                  // ★ ใหม่: pre-select เฉพาะ edit mode เท่านั้น
                  initialSelectedDate: _calendarIsEditMode
                      ? _existingAppointment?.dateTime?.toLocal()
                      : null,
                  isEditMode: _calendarIsEditMode,
                  onDirtyChanged: (dirty) {
                    if (!mounted) return;
                    setState(() {
                      _calendarHasUnsavedChanges = dirty;
                    });
                  },
                  onClose: (hasUnsavedChanges) {
                    if (hasUnsavedChanges) {
                      _showCancelEditConfirmDialog();
                    } else {
                      _closeCalendar();
                    }
                  },
                  onTrash: () {
                    final id = _existingAppointment?.appointmentId;
                    if (id != null) _showDeleteConfirmDialog(id);
                  },
                  onSave: (date, time) async {
                    _closeCalendar();
                    await _saveAppointment(
                      date: date,
                      isEditMode: _calendarIsEditMode,
                      existingId: _existingAppointment?.appointmentId,
                      placeId: _calendarPlaceId,
                      placeName: _calendarPlaceName,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
