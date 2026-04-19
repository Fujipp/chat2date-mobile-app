import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:chat2date/components/calendar/calendar_modal.dart';
import 'package:chat2date/components/card/generic_card.dart';
import 'package:chat2date/components/chat/chat_text_component.dart';
import 'package:chat2date/components/common/app_raw_scrollbar.dart';
import 'package:chat2date/components/common/modal_component.dart';
import 'package:chat2date/components/design_system/controls/ds_level_progress_bar.dart';
import 'package:chat2date/components/design_system/feedback/index.dart';
import 'package:chat2date/components/design_system/inputs/ds_chat_message_input.dart';
import 'package:chat2date/components/design_system/inputs/ios_themed_chat_text_view.dart';
import 'package:chat2date/components/design_system/organisms/ds_app_secondary_header.dart';
import 'package:chat2date/components/design_system/organisms/ds_bot_chat.dart';
import 'package:chat2date/components/design_system/organisms/ds_gps_alert.dart';
import 'package:chat2date/components/design_system/organisms/ds_spin_wheel_card.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:chat2date/components/modal/feature_guide_modal.dart';
import 'package:chat2date/components/modal/relationship_mission_modal.dart';
import 'package:chat2date/components/page/unlock_date_modal.dart';
import 'package:chat2date/core/theme/app_assets.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/body_text_styles.dart';
import 'package:chat2date/core/theme/tokens/typography/display_text_styles.dart';
import 'package:chat2date/features/game/screens/guessing_game_screen.dart';
import 'package:chat2date/features/profile/screens/selection_icon_mapper.dart';
import 'package:chat2date/models/appointment.dart';
import 'package:chat2date/models/chat_access_status.dart';
import 'package:chat2date/models/chat_message.dart';
import 'package:chat2date/models/relationship_bar.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/appointment_service.dart';
import 'package:chat2date/services/chat_service.dart';
import 'package:chat2date/services/chat_socket_service.dart';
import 'package:chat2date/services/date_recommend_service.dart';
import 'package:chat2date/services/emergency_service.dart';
import 'package:chat2date/services/game_service.dart';
import 'package:chat2date/services/game_socket_service.dart';
import 'package:chat2date/services/location_service.dart';
import 'package:chat2date/services/preference_service.dart';
import 'package:chat2date/services/review_service.dart';
import 'package:chat2date/services/sos_service.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/chat_room_cache_store.dart';
import 'package:chat2date/stores/game_store.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final GlobalKey _chatInputKey = GlobalKey();
  static const int _pageSize = 20;
  bool _hasText = false;
  bool _isSending = false;
  double _currentPercent = 0.0;
  int _heartCount = 0; // 0 = ซ่อน, 1-2 = แสดง, 3 = rainbow
  bool _showWheelModal = false;
  bool _showUnlockDate = false;
  bool _hasSeenCalendarUnlockIntro = false;
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
  bool _isSpinSessionActive = false;
  int _storedSpinIndexMode = 1;
  int _storedSpinIndexSelected = 1;
  double _storedSpinRange = 20;
  bool _isSpinLoading = false;
  DateTime? _spinSearchCooldownUntil;
  Timer? _spinSearchCooldownTimer;
  final Map<String, ImageProvider> _spinWheelImageProviderCache = {};

  // === Appointment / Calendar ===
  Appointment? _existingAppointment;
  bool _calendarHasUnreadUpdate = false;
  String _lastSpunPlaceId = ''; // ★ แก้: ไม่ใช่ final เพื่อให้อัพเดตได้
  String _lastSpunPlaceName = ''; // ★ แก้: ไม่ใช่ final เพื่อให้อัพเดตได้
  String _lastSpunPlaceImageUrl = '';
  bool _isCalendarLoading = false;
  // overlay state (เหมือน SpinWheel)
  bool _showCalendarModal = false;
  String _calendarPlaceName = '';
  String _calendarPlaceId = '';
  bool _calendarIsEditMode = false;
  bool _calendarHasUnsavedChanges = false;
  bool _isLoadingMessages = true;
  bool _isInitialViewportReady = false;
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
  List<String> _chatUserImages = [];
  int? _chatUserAge;
  String? _chatUserId; // เพิ่ม userId สำหรับ Report
  User? _chatUserMeta;
  Map<String, dynamic> _chatUserProfileRaw = const {};
  double? _chatUserDistance;

  // === Spinwheel Cooldown Logic ===
  int _cooldownDays = 7; // จำนวนวันที่ต้องรอก่อนหมุนได้อีกครั้ง
  bool _canSpin = true; // true = กดได้ (Chat 2/3), false = cooldown (Chat 4)
  ChatHeaderVariant _headerVariant = ChatHeaderVariant.chat1;

  // ข้อความแชท
  List<ChatMessage> _messages = [];

  // index ของข้อความที่ถูกกดเพื่อดูเวลาส่ง (-1 = ไม่มี)
  int _selectedMessageIndex = -1;
  int _pressedMessageIndex = -1;

  //Game
  GameSocketService? _gameSocketService;
  StreamSubscription? _gameSubscription;
  bool _didScheduleBootstrap = false;

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
        debugPrint("⏳ Received WAITING_START. Going to Waiting Room...");
        if (mounted) {
          _navigateToGameScreen(roomId);
        }
      }

      if (type == 'GAME_START') {
        debugPrint("🎮 Received GAME_START via Socket!");
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
            debugPrint("❌ Error forwarding event: $e");
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
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      _chatUserImages = [widget.avatarUrl!];
    }
    _scrollController.addListener(_handleScroll);
    _hydrateFromRoomCache();
    _scheduleBootstrap();
  }

  void _hydrateFromRoomCache() {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;
    final cache = ref.read(chatRoomCacheProvider)[roomId];
    if (cache == null || cache.messages.isEmpty) return;

    _messages = List<ChatMessage>.from(cache.messages)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _messageIds
      ..clear()
      ..addAll(_messages.map((message) => message.id));
    _relationshipScore = cache.relationshipScore;
    _isChatDisabled = cache.isChatDisabled;
    _isLoadingMessages = false;
    _isInitialViewportReady = true;

    if ((widget.userName == null || widget.userName!.isEmpty) &&
        cache.partnerName != null &&
        cache.partnerName!.isNotEmpty) {
      _chatUserName = cache.partnerName!;
    }
    if (widget.avatarUrl == null && cache.partnerImages.isNotEmpty) {
      _chatUserAvatar = cache.partnerImages.first;
    }
    if (cache.partnerImages.isNotEmpty) {
      _chatUserImages = List<String>.from(cache.partnerImages);
    }
  }

  void _syncCurrentRoomCache() {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;
    ref
        .read(chatRoomCacheProvider.notifier)
        .setRoom(
          ChatRoomCacheEntry(
            roomId: roomId,
            messages: List<ChatMessage>.from(_messages),
            partnerName: _chatUserName,
            partnerImages: List<String>.from(_chatUserImages),
            relationshipScore: _relationshipScore,
            isChatDisabled: _isChatDisabled,
          ),
        );
  }

  void _scheduleBootstrap() {
    if (_didScheduleBootstrap) return;
    _didScheduleBootstrap = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_bootstrapChatScreen());
    });
  }

  Future<void> _bootstrapChatScreen() async {
    unawaited(_initUpdateRelationshipBar(false));
    _initGameSocket();
    await _initializeChat();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 80) {
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

  bool _isNavigatingToGame = false;

  Future<void> _navigateToGameScreen(String roomId) async {
    if (_isNavigatingToGame) return; // ✅ block ทันที ก่อน delay
    _isNavigatingToGame = true; // ✅ ไม่ต้อง setState เพราะแค่ guard flag

    final nav = Navigator.of(context);
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
            actionButtonText: 'กำลังเข้าสู่เกม...',
          );
        }
        return m;
      }).toList();
    });

    _gameSocketService?.dispose();
    _gameSubscription?.cancel();

    await nav.push(
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

  Future<void> _initUpdateRelationshipBar(bool onUpdate) async {
    if (onUpdate) {
      final chatService = ref.read(chatServiceProvider);
      final roomData = await chatService.updateRelationshipBar(widget.roomId!);
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

      return;
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding
        .instance
        .platformDispatcher
        .views
        .first
        .viewInsets
        .bottom;
    if (bottomInset > 0) {
      _lockToBottomForKeyboard();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // กรณีพับหน้าจอ (Paused) หรือ ปิดแอป (Detached)
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      debugPrint("App is backgrounded or killed: Exiting room");
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

    await Future.wait<void>([
      _loadChatUserMeta(),
      _fetchInitialAppointment(),
      _initConfirmStatus(),
      _checkSpinWheelCondition(),
      _checkAndShowReviewModal(),
      _restoreSpinSessionIfNeeded(),
    ]);
    try {
      final numbers = await ref
          .read(emergencyCallServiceProvider)
          .getEmergencyCalls();
      if (mounted) {
        setState(() {
          _emergencyNumbers = numbers;
          _isEmergencyLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isEmergencyLoaded = true);
    }

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFeatureGuide();
      });
    }
  }

  Future<void> _loadChatUserMeta() async {
    final targetUserId = _chatUserId;
    if (targetUserId == null || targetUserId.isEmpty) return;

    // ใช้ profileRaw ที่ set แล้วจาก _loadChatRoomMessages
    final raw = _chatUserProfileRaw;
    debugPrint('📋 profileRaw keys: ${raw.keys.toList()}');
    debugPrint('📋 profileRaw birthday: ${raw['birthday']}');

    final rawAge = raw['age'];
    final rawBirthday = raw['birthday'] ?? raw['birthDate'];

    DateTime? birthday;
    if (rawBirthday is String) {
      birthday = DateTime.tryParse(rawBirthday);
    }

    final age = rawAge is int
        ? rawAge
        : (birthday != null ? _calculateAge(birthday) : null);

    if (mounted) {
      setState(() => _chatUserAge = age);
    }
  }

  int? _calculateAge(DateTime? birthday) {
    if (birthday == null) return null;
    final now = DateTime.now();
    int age = now.year - birthday.year;
    final hadBirthdayThisYear =
        now.month > birthday.month ||
        (now.month == birthday.month && now.day >= birthday.day);
    if (!hadBirthdayThisYear) age -= 1;
    return age >= 0 ? age : null;
  }

  String get _chatDisplayName => _chatUserAge == null
      ? _chatUserName
      : '$_chatUserName (${_chatUserAge!})';

  String _latestSpunPlaceNamePrefsKey(String roomId) =>
      'latest_spun_place_name_$roomId';

  String _latestSpunPlaceImagePrefsKey(String roomId) =>
      'latest_spun_place_image_$roomId';

  Future<void> _restoreLatestSpunPlacePreview() async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final savedName =
        prefs.getString(_latestSpunPlaceNamePrefsKey(roomId)) ?? '';
    final savedImage =
        prefs.getString(_latestSpunPlaceImagePrefsKey(roomId)) ?? '';
    if (!mounted) {
      return;
    }
    setState(() {
      _lastSpunPlaceName = savedName;
      _lastSpunPlaceImageUrl = savedImage;
    });
  }

  Future<void> _persistLatestSpunPlacePreview() async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _latestSpunPlaceNamePrefsKey(roomId),
      _lastSpunPlaceName,
    );
    await prefs.setString(
      _latestSpunPlaceImagePrefsKey(roomId),
      _lastSpunPlaceImageUrl,
    );
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

    final hasExistingMessages = _messages.isNotEmpty;
    setState(() {
      _isLoadingMessages = !hasExistingMessages;
      _isInitialViewportReady = hasExistingMessages;
      _isLoadingMore = false;
      _messageError = null;
      _currentPage = 0;
      _hasMoreMessages = true;
    });

    try {
      final chatService = ref.read(chatServiceProvider);
      final results = await Future.wait<dynamic>([
        chatService.getChatMessages(roomId),
        ref.read(gameServiceProvider).checkGameStatus(int.parse(roomId)),
      ]);
      if (!mounted) return;
      final roomData = results[0] as dynamic;
      final gameStatus = results[1] as dynamic;
      final sortedMessages = List<ChatMessage>.from(roomData.messages)
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      setState(() {
        _messages = sortedMessages;
        _messages = _updateBotMessagesByGameStatus(
          _messages,
          gameStatus.gameStatus,
        );
        _isLoadingMessages = false;
        _isInitialViewportReady = true;
        _messageIds
          ..clear()
          ..addAll(sortedMessages.map((message) => message.id));
        _hasMoreMessages = sortedMessages.length >= _pageSize;
        _relationshipScore = roomData.relationshipScore;
        _isChatDisabled = roomData.isChatDisabled;
        _chatUserDistance = roomData.partnerDistance;
        _chatUserProfileRaw = Map<String, dynamic>.from(
          roomData.partnerProfile,
        );
        //  _applyRelationshipScore(roomData.relationshipScore);
        if (widget.userName == null && roomData.partnerName != null) {
          _chatUserName = roomData.partnerName!;
        }
        if (widget.avatarUrl == null && roomData.partnerImages.isNotEmpty) {
          _chatUserAvatar = roomData.partnerImages.first;
        }
        if (roomData.partnerImages.isNotEmpty) {
          _chatUserImages = roomData.partnerImages;
        }
      });
      _syncCurrentRoomCache();
      unawaited(_restoreLatestSpunPlacePreview());
      _startChatSocket();
      unawaited(_syncAccessStatus());
      unawaited(_checkSpinWheelCondition());
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
    if (_isSpinSessionActive && _leaderId == _currentUserId) {
      try {
        await ref.read(dateRecommendProvider).closeRemoteModal(widget.roomId!);
      } catch (_) {}
      await _clearPersistedSpinSession();
    }
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
    _reviewSubscription = service.reviewStream.listen(_handleReviewEvent);
    _appointmentSubscription = service.appointmentStream.listen(
      _handleAppointmentEvent,
    );
    _relationshipSubscription = service.relationshipStream.listen((data) {
      if (!mounted) return;
      setState(() {
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
    });

    _chatSocketService?.spinStream.listen((payload) async {
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
          final List placesList = data['places'] ?? [];
          final mappedPrizes = _mapSpinPlaces(placesList);

          await _precacheSpinPrizeImages(mappedPrizes);
          if (!mounted) {
            return;
          }

          setState(() {
            if (!_isSpinSessionActive || _currentUserId == leaderIdFromSocket) {
              _showWheelModal = true;
              _isSpinSessionActive = true;
            }
            _leaderId = leaderIdFromSocket;

            _indexMode = (modeStr == 'DISTANCE') ? 0 : 1;

            if (_currentUserId == leaderIdFromSocket) {
              _indexSelected = (targetStr == "ME") ? 1 : 0;
            } else {
              _indexSelected = (targetStr == "PARTNER") ? 1 : 0;
            }

            _dynamicPrizes = mappedPrizes;
            _currentRange = (payload['range'] as num).toDouble();
            _storedSpinIndexMode = _indexMode;
            _storedSpinIndexSelected = _indexSelected;
            _storedSpinRange = _currentRange;
            _isSpinLoading = false;
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
    _syncCurrentRoomCache();
    _ensureLatestMessagePinned();
    // If the incoming message is from the other person (not ours),
    // mark it as read since we're currently viewing the chat.
    // This triggers the backend to broadcast "เห็นแล้ว" to the sender in real-time.
    // Debounced to avoid flooding the API when multiple messages arrive quickly.

    if (!message.isOwn) {
      _ensureLatestMessagePinned();
      _markReadDebounce?.cancel();
      _markReadDebounce = Timer(const Duration(milliseconds: 500), () {
        _enterRoom();
      });
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position.minScrollExtent;
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
    _spinSearchCooldownTimer?.cancel();
    unawaited(_clearPersistedSpinSession());
    setState(() {
      _isSpinSessionActive = false;
      _showWheelModal = false;
      _leaderId = null;
      winningIndex = null;
      _dynamicPrizes = [];
      _indexMode = 1;
      _indexSelected = 1;
      _currentRange = 20;
      _storedSpinIndexMode = 1;
      _storedSpinIndexSelected = 1;
      _storedSpinRange = 20;
      _isSpinLoading = false;
      _spinSearchCooldownUntil = null;
    });
  }

  String _spinSessionPrefsKey(String roomId) {
    final userId = _currentUserId ?? 'guest';
    return 'spin_session_${userId}_$roomId';
  }

  Future<void> _persistSpinSession() async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty || _leaderId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _spinSessionPrefsKey(roomId),
      jsonEncode({
        'leaderId': _leaderId,
        'indexMode': _indexMode,
        'indexSelected': _indexSelected,
        'range': _currentRange,
        'prizes': _dynamicPrizes,
      }),
    );
  }

  Future<void> _clearPersistedSpinSession() async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_spinSessionPrefsKey(roomId));
  }

  Future<void> _restoreSpinSessionIfNeeded() async {
    final roomId = widget.roomId;
    final currentUserId = _currentUserId;
    if (roomId == null || roomId.isEmpty || currentUserId == null) return;

    try {
      final service = ref.read(dateRecommendProvider);
      final sessionData = await service.getRoomSession(roomId);

      if (sessionData == null) {
        await _clearPersistedSpinSession();
        if (mounted) _clearWheelState();
        return;
      }

      final leaderId = sessionData['leaderId']?.toString();
      final modeStr = sessionData['mode'] ?? 'MIDPOINT';
      final targetStr = sessionData['userTarget'] ?? 'PARTNER';
      final rawData = sessionData['data'] ?? {};
      final placesList = rawData['places'] as List? ?? [];
      final mappedPrizes = _mapSpinPlaces(placesList);

      await _precacheSpinPrizeImages(mappedPrizes);
      if (!mounted) return;

      setState(() {
        _isSpinSessionActive = true;
        _leaderId = leaderId;
        _showWheelModal = true;

        _indexMode = (modeStr == 'DISTANCE') ? 0 : 1;

        if (currentUserId == leaderId) {
          _indexSelected = (targetStr == "ME") ? 1 : 0;
        } else {
          _indexSelected = (targetStr == "PARTNER") ? 1 : 0;
        }

        _currentRange = (sessionData['range'] as num?)?.toDouble() ?? 20;
        _storedSpinIndexMode = _indexMode;
        _storedSpinIndexSelected = _indexSelected;
        _storedSpinRange = _currentRange;
        _dynamicPrizes = mappedPrizes;
        winningIndex = null;
      });
    } catch (e) {
      await _clearPersistedSpinSession();
      if (mounted) _clearWheelState();
    }
  }

  bool get _isSpinLeader => _leaderId != null && _leaderId == _currentUserId;
  bool get _hasActiveSpinSession => _isSpinSessionActive && _leaderId != null;
  bool get _hasSpinSearchChanges =>
      _indexMode != _storedSpinIndexMode ||
      _indexSelected != _storedSpinIndexSelected ||
      (_currentRange - _storedSpinRange).abs() > 0.01;
  bool get _isSpinSearchCoolingDown =>
      _spinSearchCooldownUntil != null &&
      DateTime.now().isBefore(_spinSearchCooldownUntil!);
  int get _spinSearchCooldownSecondsLeft {
    final until = _spinSearchCooldownUntil;
    if (until == null) {
      return 0;
    }
    final remaining = until.difference(DateTime.now()).inSeconds;
    return remaining <= 0 ? 0 : remaining + 1;
  }

  bool get _canAdjustSpinFilters =>
      !_isSpinSearchCoolingDown && !_isSpinLoading;
  String get _spinPrimaryActionLabel {
    if (!_isSpinLeader) {
      return 'กำลังรอคู่ของคุณสุ่ม';
    }
    if (_isSpinLoading) {
      return 'กำลังค้นหาสถานที่เดต...';
    }
    if (_isSpinSearchCoolingDown && _hasSpinSearchChanges) {
      return 'รอ $_spinSearchCooldownSecondsLeft วิ เพื่อค้นหาใหม่';
    }
    if (_hasSpinSearchChanges) {
      return 'ค้นหาสถานที่เดตก่อน';
    }
    return 'สุ่มสถานที่เดต';
  }

  String? get _spinStatusMessage {
    if (_isSpinLoading) {
      return 'กำลังโหลดสถานที่เดตจากระยะที่เลือก';
    }
    if (_isSpinSearchCoolingDown) {
      return 'สามารถเลื่อนระยะและค้นหาสถานที่เดตใหม่ได้อีกใน $_spinSearchCooldownSecondsLeft วินาที';
    }
    return 'เปิดครั้งแรกสามารถเลื่อนระยะได้ทันที หลังค้นหาแล้วจะติดคูลดาวน์ 10 วินาที';
  }

  String _spinModeFromIndex(int indexMode) {
    return indexMode == 0 ? 'DISTANCE' : 'MIDPOINT';
  }

  String? _spinUserTargetFromIndex(int indexMode, int indexSelected) {
    if (indexMode != 0) {
      return null;
    }
    return indexSelected == 1 ? 'ME' : 'PARTNER';
  }

  List<DsSpinWheelItem> get _spinWheelItems {
    return _dynamicPrizes.map((place) {
      final imageUrl = place['imageUrl'] as String?;
      return DsSpinWheelItem(
        label: (place['name'] as String?) ?? 'Place',
        imageProvider: (imageUrl?.isNotEmpty ?? false)
            ? _spinWheelImageProviderCache.putIfAbsent(
                imageUrl!,
                () => NetworkImage(imageUrl),
              )
            : null,
      );
    }).toList();
  }

  ImageProvider<Object>? _botPlaceImageProvider(ChatMessage message) {
    if (message.botType != BotMessageType.ask) {
      return null;
    }

    final lastImageUrl = _lastSpunPlaceImageUrl.trim();
    if (lastImageUrl.isNotEmpty &&
        (_lastSpunPlaceName.isNotEmpty &&
            (message.text.contains(_lastSpunPlaceName) ||
                (message.description ?? '').contains(_lastSpunPlaceName)))) {
      return _spinWheelImageProviderCache.putIfAbsent(
        lastImageUrl,
        () => NetworkImage(lastImageUrl),
      );
    }

    final haystacks = <String>[
      message.text,
      message.description ?? '',
      _lastSpunPlaceName,
    ].where((value) => value.trim().isNotEmpty).toList();

    for (final place in _dynamicPrizes) {
      final placeName = (place['name'] as String?)?.trim();
      final imageUrl = (place['imageUrl'] as String?)?.trim();
      if (placeName == null ||
          placeName.isEmpty ||
          imageUrl == null ||
          imageUrl.isEmpty) {
        continue;
      }
      final matchesPlace = haystacks.any((text) => text.contains(placeName));
      if (matchesPlace) {
        return _spinWheelImageProviderCache.putIfAbsent(
          imageUrl,
          () => NetworkImage(imageUrl),
        );
      }
    }

    return null;
  }

  ImageProvider<Object>? _botIllustrationProvider(ChatMessage message) {
    if (message.botType == BotMessageType.ask) {
      return _botPlaceImageProvider(message);
    }
    if (message.botType == BotMessageType.minigame ||
        message.botType == BotMessageType.minigameFail) {
      return const AssetImage(AppAssets.botChatIllustration);
    }
    return null;
  }

  List<Map<String, dynamic>> _mapSpinPlaces(List placesList) {
    return placesList.map<Map<String, dynamic>>((place) {
      final map = Map<String, dynamic>.from(place as Map);
      return {
        "name": map['name'],
        "imageUrl": map['imageUrl'],
        "placeId": map['googlePlaceId'] ?? map['placeId'],
      };
    }).toList();
  }

  Future<void> _precacheSpinPrizeImages(
    List<Map<String, dynamic>> prizes,
  ) async {
    if (!mounted) {
      return;
    }

    await Future.wait(
      prizes.map((place) async {
        final imageUrl = place['imageUrl'] as String?;
        if (imageUrl == null || imageUrl.isEmpty) {
          return;
        }
        try {
          await precacheImage(NetworkImage(imageUrl), context);
        } catch (_) {}
      }),
    );
  }

  void _startSpinSearchCooldown() {
    _spinSearchCooldownTimer?.cancel();
    final until = DateTime.now().add(const Duration(seconds: 10));
    setState(() {
      _spinSearchCooldownUntil = until;
    });
    _spinSearchCooldownTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!_isSpinSearchCoolingDown) {
        timer.cancel();
        setState(() {
          _spinSearchCooldownUntil = null;
        });
        return;
      }
      setState(() {});
    });
  }

  void _updateSpinFilters({int? indexMode, int? indexSelected, double? range}) {
    if (!_canAdjustSpinFilters) {
      return;
    }
    setState(() {
      _indexMode = indexMode ?? _indexMode;
      _indexSelected = indexSelected ?? _indexSelected;
      _currentRange = range ?? _currentRange;
    });
  }

  Future<void> _searchSpinPlaces() async {
    if (!_isSpinLeader || _isSpinLoading) {
      return;
    }
    if (_isSpinSearchCoolingDown) {
      Toast.show(
        context,
        type: ToastType.info,
        title: 'รอก่อนนะ',
        message: 'สามารถปรับระยะและค้นหาสถานที่เดตใหม่ได้ทุก 10 วินาที',
      );
      return;
    }
    await _prepareBeforeSpin(
      _currentRange,
      _spinModeFromIndex(_indexMode),
      _spinUserTargetFromIndex(_indexMode, _indexSelected),
      true,
    );
  }

  Future<void> _handleSpinModalClose() async {
    if (_isSpinLeader) {
      await ref.read(dateRecommendProvider).closeRemoteModal(widget.roomId!);
      if (!mounted) {
        return;
      }
      _clearWheelState();
      return;
    }

    setState(() {
      _showWheelModal = false;
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
        _syncCurrentRoomCache();
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

  String _calendarUnlockIntroPrefsKey(String roomId) {
    final userId = _currentUserId ?? 'guest';
    return 'calendar_unlock_intro_${userId}_$roomId';
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

      final activeAppointment = _findLatestActiveAppointment(appointments);
      final inactiveAppointment = _findLatestNotActiveAppointment(appointments);

      if (inactiveAppointment != null) {
        try {
          await ref
              .read(dateRecommendProvider)
              .deleteAppointmentAfterCooldown(roomId: roomId);
        } catch (_) {}
      }

      final latestAppointment = activeAppointment;

      final prefs = await SharedPreferences.getInstance();
      final prefsKey = _calendarSeenPrefsKey(roomId);
      final unlockPrefsKey = _calendarUnlockIntroPrefsKey(roomId);
      final signature = latestAppointment == null
          ? null
          : _appointmentCalendarSignature(latestAppointment);
      final savedSignature = prefs.getString(prefsKey);
      final hasSeenUnlockIntro = prefs.getBool(unlockPrefsKey) ?? false;

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
        _hasSeenCalendarUnlockIntro = hasSeenUnlockIntro;
      });

      if (latestAppointment != null &&
          !hasSeenUnlockIntro &&
          !_showUnlockDate) {
        _triggerUnlockDate();
      }
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

  bool get _shouldShowCalendarIcon =>
      _existingAppointment != null && _hasSeenCalendarUnlockIntro;

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

  Future<void> _copyMessageText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: trimmed));
  }

  Future<void> _showMessageContextMenu({
    required String text,
    required BuildContext bubbleContext,
    required int messageIndex,
  }) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final bubbleRenderBox = bubbleContext.findRenderObject() as RenderBox?;
    if (overlay == null || bubbleRenderBox == null) return;

    final bubbleTopLeft = bubbleRenderBox.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    final bubbleRect = bubbleTopLeft & bubbleRenderBox.size;
    final anchorPoint = Offset(bubbleRect.center.dx, bubbleRect.top - 8);

    if (mounted) {
      setState(() {
        _pressedMessageIndex = messageIndex;
      });
    }

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromCenter(center: anchorPoint, width: 1, height: 1),
        Offset.zero & overlay.size,
      ),
      color: const Color(0xFF2C2C2E),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: const [
        PopupMenuItem<String>(
          value: 'copy',
          height: 32,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            'คัดลอก',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );

    if (mounted) {
      setState(() {
        _pressedMessageIndex = -1;
      });
    }

    if (selected == 'copy') {
      await _copyMessageText(text);
    }
  }

  Widget _buildPressableMessageBubble({
    required int messageIndex,
    required bool isOwn,
    required Map<String, double> radius,
    required String text,
  }) {
    final isPressed = _pressedMessageIndex == messageIndex;
    return ChatTextComponent(
      text: text,
      isChatRight: isOwn,
      topLeftRadius: radius['tl'],
      topRightRadius: radius['tr'],
      bottomLeftRadius: radius['bl'],
      bottomRightRadius: radius['br'],
      bubbleOverlayColor: isPressed
          ? Colors.black.withValues(alpha: 0.14)
          : null,
    );
  }

  DsAppSecondaryHeaderVariant _mapDsHeaderVariant() {
    if (_isChatDisabled) {
      return DsAppSecondaryHeaderVariant.chat1;
    }
    switch (_headerVariant) {
      case ChatHeaderVariant.chat1:
        return DsAppSecondaryHeaderVariant.chat1;
      case ChatHeaderVariant.chat2:
        return DsAppSecondaryHeaderVariant.chat3;
      case ChatHeaderVariant.chat3:
        return DsAppSecondaryHeaderVariant.chat4;
      case ChatHeaderVariant.chat4:
        return DsAppSecondaryHeaderVariant.chat4;
    }
  }

  ImageProvider<Object>? _chatUserAvatarProvider() {
    if (_isChatDisabled) {
      return const AssetImage(AppAssets.reportUserAvatar);
    }
    final avatar = _chatUserAvatar;
    if (avatar == null || avatar.isEmpty) return null;
    if (_isSvgImage(avatar)) return null;
    return avatar.startsWith('http')
        ? NetworkImage(avatar)
        : AssetImage(avatar) as ImageProvider<Object>;
  }

  List<String> get _effectiveChatUserImages {
    if (_isChatDisabled) {
      return const <String>[];
    }
    final images = <String>[
      ..._chatUserImages.where((image) => image.isNotEmpty),
    ];
    final avatar = _chatUserAvatar;
    if (avatar != null && avatar.isNotEmpty && !images.contains(avatar)) {
      images.insert(0, avatar);
    }
    return images;
  }

  Future<void> _openChatUserProfile({int initialIndex = 0}) async {
    final images = _effectiveChatUserImages;
    if (images.isEmpty) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return _ChatUserProfileScreen(
            images: images,
            initialIndex: initialIndex.clamp(0, images.length - 1),
            userName: _chatUserName,
            targetUserId: _chatUserId,
            initialUser: _chatUserMeta,
            initialProfileJson: _chatUserProfileRaw,
            initialDistance: _chatUserDistance,
            relationshipScore: _relationshipScore,
          );
        },
      ),
    );
  }

  Widget _buildChatHeaderCenter() {
    return GestureDetector(
      onTap: _isChatDisabled || _effectiveChatUserImages.isEmpty
          ? null
          : _openChatUserProfile,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            child: _chatUserAvatarProvider() != null
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: _chatUserAvatarProvider()!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : SvgPicture.asset(
                    AppAssets.headerSecondaryAvatar,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            _chatDisplayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 20 / 14,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipBar() {
    final displayHeartCount = _isChatDisabled ? 0 : _heartCount;
    final displayProgress = _isChatDisabled ? 0.0 : _currentPercent;

    return DsLevelProgressBar(
      level: displayHeartCount,
      progress: displayProgress,
      width: 322,
      barWidth: 255,
      barThickness: 10,
      heartWidth: 25,
      heartHeight: 22,
      trailingIconSize: 20,
      onInfoTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => RelationshipMissionModal(
            heart: displayHeartCount,
            currentScore: (displayProgress * 100).round(),
            isFirstMessageBonus: _isFirstMessageBonus,
            streakDays: _steakDays,
            dailyMessages: _dailyMessagesCount,
          ),
        );
      },
    );
  }

  void _openReportScreen() {
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
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    IosThemedChatTextView.dismissActiveKeyboard();
  }

  void _handleRootPointerDown(PointerDownEvent event) {
    final inputContext = _chatInputKey.currentContext;
    if (inputContext != null) {
      final renderBox = inputContext.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final topLeft = renderBox.localToGlobal(Offset.zero);
        final inputRect = topLeft & renderBox.size;
        if (inputRect.contains(event.position)) {
          return;
        }
      }
    }
    _dismissKeyboard();
  }

  void _keepLatestMessageVisible({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToBottom(animated: animated);
    });
  }

  void _ensureLatestMessagePinned() {
    _keepLatestMessageVisible(animated: false);
    Future.delayed(const Duration(milliseconds: 1), () {
      if (!mounted) return;
      _keepLatestMessageVisible(animated: false);
    });
    Future.delayed(const Duration(milliseconds: 16), () {
      if (!mounted) return;
      _keepLatestMessageVisible(animated: false);
    });
    Future.delayed(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      _keepLatestMessageVisible(animated: false);
    });
    Future.delayed(const Duration(milliseconds: 140), () {
      if (!mounted) return;
      _keepLatestMessageVisible(animated: false);
    });
  }

  void _lockToBottomForKeyboard() {
    _ensureLatestMessagePinned();
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
      _lastSpunPlaceId = (result['placeId'] as String?) ?? '';
      _lastSpunPlaceName = (result['name'] as String?) ?? '';
      _lastSpunPlaceImageUrl = (result['imageUrl'] as String?) ?? '';
    });
    unawaited(_persistLatestSpunPlacePreview());
    _checkSpinWheelCondition();
    if (_leaderId == _currentUserId) {
      final service = ref.read(dateRecommendProvider);
      try {
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted || _leaderId != _currentUserId) {
          return;
        }
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
        await _clearPersistedSpinSession();
        _clearWheelState();
      } catch (e) {
        await service.closeRemoteModal(widget.roomId!);
        await _clearPersistedSpinSession();
        _clearWheelState();
        debugPrint("Error fetching date recommendations: $e");
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
    if (_hasActiveSpinSession) {
      setState(() {
        _showWheelModal = true;
      });
      return;
    }

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

    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;

    final service = ref.read(dateRecommendProvider);
    final sessionData = await service.getRoomSession(roomId);

    if (sessionData != null) {
      final leaderId = sessionData['leaderId']?.toString();
      final modeStr = sessionData['mode'] ?? 'MIDPOINT';
      final targetStr = sessionData['userTarget'] ?? 'PARTNER';
      final rawData = sessionData['data'] ?? {};
      final placesList = rawData['places'] as List? ?? [];
      final mappedPrizes = _mapSpinPlaces(placesList);

      setState(() {
        _isSpinSessionActive = true;
        _leaderId = leaderId;
        _showWheelModal = true;

        _indexMode = (modeStr == 'DISTANCE') ? 0 : 1;

        if (_currentUserId == leaderId) {
          _indexSelected = (targetStr == "ME") ? 1 : 0;
        } else {
          _indexSelected = (targetStr == "PARTNER") ? 1 : 0;
        }

        _currentRange = (sessionData['range'] as num?)?.toDouble() ?? 20;
        _storedSpinIndexMode = _indexMode;
        _storedSpinIndexSelected = _indexSelected;
        _storedSpinRange = _currentRange;
        _dynamicPrizes = mappedPrizes;
        winningIndex = null;
      });
      return;
    }

    setState(() {
      _leaderId = _currentUserId;
      _isSpinSessionActive = true;
      _showWheelModal = true;
    });
    final loaded = await _prepareBeforeSpin(20, "MIDPOINT", "", false);
    if (!loaded || !mounted) {
      _clearWheelState();
      return;
    }
  }

  Future<bool> _prepareBeforeSpin(
    double range,
    String? mode,
    String? userTarget,
    bool refresh,
  ) async {
    final service = ref.read(dateRecommendProvider);
    if (mounted) {
      setState(() {
        _isSpinLoading = true;
      });
    }

    try {
      final recommendations = await service.getRecommendations(
        roomId: widget.roomId,
        range: range.round(),
        mode: mode,
        userTarget: userTarget,
        forceRefresh: refresh,
      );
      final mappedPrizes = recommendations.places.map((place) {
        return {
          "name": place.name,
          "imageUrl": place.imageUrl,
          "placeId": place.googlePlaceId,
        };
      }).toList();
      await _precacheSpinPrizeImages(mappedPrizes);
      if (!mounted) return false;
      setState(() {
        _dynamicPrizes = mappedPrizes;
        _storedSpinRange = range;
        _storedSpinIndexMode = mode == 'DISTANCE' ? 0 : 1;
        _storedSpinIndexSelected = mode == 'DISTANCE'
            ? (userTarget == 'ME' ? 1 : 0)
            : _indexSelected;
        _currentRange = range;
        _indexMode = _storedSpinIndexMode;
        _indexSelected = _storedSpinIndexSelected;
        _isSpinLoading = false;
      });
      if (refresh) {
        _startSpinSearchCooldown();
      }
      return true;
    } catch (e) {
      if (!mounted) return false;

      Toast.show(
        context,
        type: ToastType.error,
        title: 'ไม่สามารถโหลดข้อมูลสถานที่ได้',
        message: e.toString().replaceAll('Exception: ', ''),
        durationSeconds: 3,
      );
      setState(() {
        _isSpinLoading = false;
      });
      return false;
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
    DsCalendarStatusModal.show(
      context,
      title: 'บันทึกเสร็จสิ้น',
      message: dt == null
          ? 'ยังไม่ได้ระบุวันที่และเวลา'
          : 'วันและเวลาออกเดตของคุณคือ ${_formatCalendarModalDate(dt)}\nเราจะแจ้งเตือนคุณอีกครั้งล่วงหน้าก่อนวันนัด 1 วัน',
    );
  }

  /// State 6: ยืนยันก่อนยกเลิกการแก้ไข (close X ใน edit mode)
  void _showCancelEditConfirmDialog() {
    DsCalendarDecisionModal.show(
      context,
      title: 'ละทิ้งการแก้ไขหรือไม่',
      description: 'การเปลี่ยนแปลงที่คุณแก้ไขไว้จะไม่ถูกบันทึก',
      negativeLabel: 'ยกเลิก',
      positiveLabel: 'ละทิ้ง',
      onNegativePressed: () => Navigator.of(context, rootNavigator: true).pop(),
      onPositivePressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        _closeCalendar();
      },
    );
  }

  /// State 7: ยืนยันยกเลิกนัดหมาย
  void _showDeleteConfirmDialog(int appointmentId) {
    DsCalendarDecisionModal.show(
      context,
      title: 'ยืนยันที่จะลบนัดเดตหรือไม่',
      description:
          'การลบนัดเดต สถานที่เดตวันนั้นจะหายไปด้วย\nคุณจะต้อง สุ่มเดตใหม่ หากต้องการเดตอีกครั้ง',
      negativeLabel: 'ยกเลิก',
      positiveLabel: 'ยืนยัน',
      onNegativePressed: () => Navigator.of(context, rootNavigator: true).pop(),
      onPositivePressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        _closeCalendar();
        _deleteAppointment(appointmentId);
      },
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
    DsCalendarStatusModal.show(
      context,
      title: 'ลบเสร็จสิ้น',
      message:
          'สถานที่เดตคุณลบเรียบร้อย\nหากต้องการเดตอีกครั้ง กรุณาสุ่มเดตใหม่',
    );
  }

  String _formatCalendarModalDate(DateTime dt) {
    const thaiMonths = [
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

    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${thaiMonths[dt.month - 1]} ${dt.year}\nเวลา $hour.$minute น.';
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
          _headerVariant = ChatHeaderVariant.chat2;
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
      _syncCurrentRoomCache();
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

  void _triggerUnlockDate() async {
    if (_showUnlockDate || _hasSeenCalendarUnlockIntro) {
      return;
    }
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _showUnlockDate = true;
    });
  }

  Future<void> _confirmCalendarUnlockIntro() async {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_calendarUnlockIntroPrefsKey(roomId), true);
    if (!mounted) return;
    setState(() {
      _hasSeenCalendarUnlockIntro = true;
      _showUnlockDate = false;
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
          final apptOneSided = _existingAppointment;
          if (apptOneSided == null) return;
          _showOneSidedModal(appt: apptOneSided);
          break;
        case 'BOTH_UNSATISFIED':
          if (!_hasShownBadEnding) {
            final apptBad = _existingAppointment;
            if (apptBad == null) return;
            _hasShownBadEnding = true;
            _showBadEndingModal(appt: apptBad);
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
              Navigator.of(context, rootNavigator: true).popUntil(
                (route) => route.isFirst || route.settings.name == '/chat-list',
              );
            }
          });
          break;
      }

      if (outcome != 'UNMATCH') {
        await _fetchInitialAppointment();
      }
    }
  }

  // ==================== Review Flow ====================
  bool _isReviewModalShown = false;
  Future<void> _checkAndShowReviewModal() async {
    if (_isReviewModalShown) return;

    final appt = _existingAppointment;
    if (appt == null || appt.dateTime == null) {
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
      debugPrint("❌ submitReview error: $e");
    }
  }

  void _showWaitingModal() {
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
    DsActionModal.show(
      context,
      barrierDismissible: true,
      child: DsChoiceModal(
        title: 'เพื่อความปลอดภัยของคุณ',
        description:
            'คุณยังไม่ได้กรอกเบอร์โทรฉุกเฉิน\n'
            'หากเกิดเหตุฉุกเฉิน ระบบจะแสดงปุ่มโทรหา 191\n\n'
            'ต้องการเพิ่มเบอร์คนใกล้ชิดเพื่อกดโทรได้ทันทีไหม?',
        negativeLabel: 'ไม่ต้องการ',
        positiveLabel: 'เพิ่มเบอร์',
        minHeight: 280,
        topVisual: SvgPicture.asset(
          'assets/icons/ui/icon_warning.svg',
          width: 77,
          height: 68,
        ),
        onNegativePressed: () => Navigator.of(context).pop(),
        onPositivePressed: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/account-settings');
        },
      ),
    );
  }

  bool _shouldShowGpsOverlay() {
    final appointment = _existingAppointment;
    final appointmentTime = appointment?.dateTime?.toLocal();
    if (appointmentTime == null) return false;
    final now = DateTime.now();
    final dateStartTime = appointmentTime.subtract(const Duration(hours: 2));
    final dateEndTime = appointmentTime.add(const Duration(hours: 3));
    return now.isAfter(dateStartTime) && now.isBefore(dateEndTime);
  }

  void _maybeShowEmergencySuggestionForGps() {
    if (_emergencyNumbers.isNotEmpty ||
        !_isEmergencyLoaded ||
        _hasShownEmergencySuggestion ||
        !mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasShownEmergencySuggestion) return;
      _hasShownEmergencySuggestion = true;
      _showEmergencyNumberSuggestionDialog();
    });
  }

  Widget _buildGpsOverlayWidget() {
    return GpsMapAlert(
      emergencyNumbers: _emergencyNumbers,
      destinationPlaceId: _existingAppointment?.placeId,
      googleApiKey: dotenv.env['GOOGLE_API_KEY'] ?? '',
      onLocate: () {
        ref.read(locationServiceProvider).tryUpdateLocationSilently();
      },
      onShareLocation: () async {
        try {
          final pos = await Geolocator.getCurrentPosition();

          final shareUrl = await ref
              .read(locationServiceProvider)
              .shareLocation(latitude: pos.latitude, longitude: pos.longitude);

          if (shareUrl.isNotEmpty) {
            await SharePlus.instance.share(
              ShareParams(
                text:
                    'ฉันกำลังไปเดตนะ! นี่คือตำแหน่งล่าสุดของฉันตอนนี้นะ:\n$shareUrl',
              ),
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
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
          if (calledNumber == '191') return;

          await ref
              .read(sosServiceProvider)
              .triggerSos(
                appointmentId: _existingAppointment!.appointmentId,
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
              message: 'ไม่สามารถส่งข้อมูล SOS ได้',
              durationSeconds: 3,
              showCountdown: false,
            );
          }
        }
      },
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
      return DsBotChat(
        type: _mapDsBotChatType(
          message: message,
          isAlreadyActioned: isAlreadyActioned,
        ),
        title: message.text,
        description: message.description,
        subDescription: message.subDescription,
        actionLabel: message.actionButtonText ?? 'เริ่ม',
        declineLabel: message.secondChoiceText ?? 'ไม่ไป',
        acceptLabel: message.firstChoiceText ?? 'ไป',
        answeredCount: message.answeredCount ?? 0,
        totalCount: message.totalCount ?? 2,
        createdAt: message.timestamp,
        illustrationImage: _botIllustrationProvider(message),
        onActionPressed: () async {
          if (message.botType == BotMessageType.ask && isAlreadyActioned) {
            return;
          }
          if (message.isActionDisabled ?? false) return;
          setState(() {
            _messages[index] = message.copyWith(
              isActionDisabled: true,
              actionButtonText: "เริ่มเกมไปแล้ว",
            );
          });
          if (message.botType == BotMessageType.minigame ||
              message.botType == BotMessageType.minigameFail) {
            _navigateToGameScreen(widget.roomId!);
          }
        },
        onDeclinePressed: isAlreadyActioned
            ? null
            : () async {
                await _handleConfirmAction(message, 'DISAGREED');
              },
        onAcceptPressed: isAlreadyActioned
            ? null
            : () async {
                await _handleConfirmAction(message, 'AGREED');
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
          Builder(
            builder: (bubbleContext) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMessageIndex = _selectedMessageIndex == index
                      ? -1
                      : index;
                });
              },
              onLongPressStart: (_) => _showMessageContextMenu(
                text: message.text,
                bubbleContext: bubbleContext,
                messageIndex: index,
              ),
              child: _buildPressableMessageBubble(
                messageIndex: index,
                isOwn: true,
                radius: radius,
                text: message.text,
              ),
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
                child: Builder(
                  builder: (bubbleContext) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMessageIndex = _selectedMessageIndex == index
                            ? -1
                            : index;
                      });
                    },
                    onLongPressStart: (_) => _showMessageContextMenu(
                      text: message.text,
                      bubbleContext: bubbleContext,
                      messageIndex: index,
                    ),
                    child: _buildPressableMessageBubble(
                      messageIndex: index,
                      isOwn: false,
                      radius: radius,
                      text: message.text,
                    ),
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

  DsBotChatType _mapDsBotChatType({
    required ChatMessage message,
    required bool isAlreadyActioned,
  }) {
    switch (message.botType) {
      case BotMessageType.minigame:
        return DsBotChatType.minigame;
      case BotMessageType.minigameFail:
        return DsBotChatType.minigameFail;
      case BotMessageType.ask:
        return isAlreadyActioned ? DsBotChatType.askAnswer : DsBotChatType.ask;
      case BotMessageType.askSuccess:
        return DsBotChatType.askSuccess;
      case BotMessageType.askFail:
        return DsBotChatType.askFail;
      case null:
        return DsBotChatType.minigame;
    }
  }

  void _showFeatureGuide() async {
    final userState = ref.read(userStoreProvider);
    final userService = ref.read(userServiceProvider);
    final userObj = userState['user'] as User?;
    final fetchUser = await userService.getUser(userObj!.userId);

    if (fetchUser?.isTutorial == false && mounted) {
      await showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'feature-guide',
        barrierColor: Colors.transparent,
        pageBuilder: (context, _, __) => Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: ColoredBox(
                  color: AppColors.overlay.withValues(alpha: 0.7),
                ),
              ),
            ),
            const FeatureGuideModal(),
          ],
        ),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      );
      try {
        final user = User(
          userId: fetchUser!.userId,
          version: fetchUser.version,
          isTutorial: true,
        );
        await userService.updateUser(user);
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
    _spinSearchCooldownTimer?.cancel();
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
    final showGpsOverlay = _shouldShowGpsOverlay();
    final gpsOverlayTop = MediaQuery.paddingOf(context).top + 120;
    if (showGpsOverlay) {
      _maybeShowEmergencySuggestionForGps();
    }
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) await _exitRoomOnce();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,

        body: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: _handleRootPointerDown,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _dismissKeyboard,
            child: Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      DsAppSecondaryHeader(
                        variant: _mapDsHeaderVariant(),
                        center: _buildChatHeaderCenter(),
                        trailing: _isChatDisabled
                            ? const SizedBox.shrink()
                            : null,
                        cooldownText: _cooldownDays == -1
                            ? '-'
                            : '${_cooldownDays.clamp(1, 9)}',
                        showCalendarAction: _isChatDisabled
                            ? false
                            : _shouldShowCalendarIcon,
                        showCalendarUnreadDot: _calendarHasUnreadUpdate,
                        showBottomBorder: false,
                        onBackTap: () async {
                          final nav = Navigator.of(context);
                          await _exitRoomOnce();
                          if (!mounted) return;
                          nav.maybePop();
                        },
                        onPrimaryActionTap:
                            _headerVariant == ChatHeaderVariant.chat1
                            ? (_isChatDisabled ? null : _openReportScreen)
                            : (_shouldShowCalendarIcon
                                  ? _handleCalendarTap
                                  : null),
                        onCalendarActionTap: _isChatDisabled
                            ? null
                            : (_shouldShowCalendarIcon
                                  ? _handleCalendarTap
                                  : null),
                        onSecondaryActionTap:
                            (_headerVariant == ChatHeaderVariant.chat2)
                            ? _handleSpinwheelTap
                            : null,
                        onTertiaryActionTap: _isChatDisabled
                            ? null
                            : _openReportScreen,
                      ),

                      // --- ส่วนแชททั้งหมด (ScoreRow + ListView + Input) ---
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 6),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 19,
                              ),
                              child: _buildRelationshipBar(),
                            ),
                            const SizedBox(height: 8),
                            const SizedBox(height: 4),
                            Expanded(
                              child: _isLoadingMessages
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : _messageError != null
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                  : !_isInitialViewportReady
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.brandPrimary,
                                      ),
                                    )
                                  : AppRawScrollbar(
                                      controller: _scrollController,
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        reverse: true,
                                        padding: EdgeInsets.fromLTRB(
                                          20,
                                          showGpsOverlay ? 128 : 12,
                                          20,
                                          24,
                                        ),
                                        itemCount:
                                            _messages.length +
                                            (_isLoadingMore ? 1 : 0),
                                        itemBuilder: (context, index) {
                                          if (_isLoadingMore &&
                                              index == _messages.length) {
                                            return const Padding(
                                              padding: EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );
                                          }

                                          final messageIndex =
                                              _messages.length - 1 - index;
                                          final message =
                                              _messages[messageIndex];
                                          final bool isGroupedWithNext =
                                              messageIndex > 0 &&
                                              _messages[messageIndex - 1]
                                                      .isOwn ==
                                                  message.isOwn &&
                                              !_messages[messageIndex - 1]
                                                  .isBot &&
                                              !message.isBot;
                                          final double bottomGap =
                                              isGroupedWithNext ? 10 : 12;
                                          final bool showTimestamp =
                                              _shouldShowTimestamp(
                                                messageIndex,
                                              );

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              if (showTimestamp)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                  latestOwnIndex:
                                                      latestOwnIndex,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                            ),
                            if (_isChatDisabled)
                              Padding(
                                key: _chatInputKey,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: DsChatMessageInput(
                                  width: double.infinity,
                                  enabled: false,
                                  disabledText:
                                      'ห้องแชทนี้ถูกระงับการสนทนาเนื่องจากมีการรายงาน',
                                ),
                              )
                            else
                              Padding(
                                key: _chatInputKey,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: DsChatMessageInput(
                                  width: double.infinity,
                                  enabled: widget.roomId?.isNotEmpty ?? false,
                                  hintText: 'พิมพ์ข้อความ',
                                  disabledText:
                                      'ไม่สามารถส่งข้อความได้เนื่องจากมีการรายงาน',
                                  controller: _messageController,
                                  onFocusChanged: (hasFocus) {
                                    if (hasFocus) {
                                      _lockToBottomForKeyboard();
                                    }
                                  },
                                  onChanged: (value) {
                                    setState(
                                      () => _hasText = value.trim().isNotEmpty,
                                    );
                                    _keepLatestMessageVisible(animated: false);
                                  },
                                  onSend:
                                      _hasText &&
                                          !_isSending &&
                                          (widget.roomId?.isNotEmpty ?? false)
                                      ? () => _sendMessage()
                                      : null,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                //           debugPrint("Shooting trigger to $url");
                //           await http.post(url);
                //         } catch (e) {
                //           debugPrint("Error triggering game: $e");
                //         }
                //       },
                //     ),
                //   ),
                // ),
                if (showGpsOverlay)
                  Positioned(
                    top: gpsOverlayTop,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      ignoring: false,
                      child: Center(
                        child: SizedBox(
                          width: 333,
                          child: _buildGpsOverlayWidget(),
                        ),
                      ),
                    ),
                  ),
                if (_showWheelModal) ...[
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          color: AppColors.overlay.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 340),
                            child: DsSpinWheelCard(
                              key: ValueKey(_leaderId),
                              width: 340,
                              items: _spinWheelItems,
                              userALabel: _chatUserName,
                              userBLabel: nickname,
                              initialVariant: _indexMode == 1
                                  ? DsSpinWheelVariant.pair
                                  : DsSpinWheelVariant.single,
                              initialReferenceIndex: _indexSelected,
                              initialDistanceKm: _currentRange,
                              externalWinningIndex: winningIndex,
                              isLoading: _isSpinLoading,
                              isInteractive: _isSpinLeader,
                              enableFilterControls:
                                  _isSpinLeader && _canAdjustSpinFilters,
                              enablePrimaryAction:
                                  _isSpinLeader &&
                                  !_isSpinLoading &&
                                  (!_hasSpinSearchChanges ||
                                      !_isSpinSearchCoolingDown),
                              enableResetAction:
                                  _isSpinLeader &&
                                  !_isSpinLoading &&
                                  _dynamicPrizes.isNotEmpty,
                              showResetAction: _isSpinLeader,
                              actionLabel: _spinPrimaryActionLabel,
                              statusMessage: _spinStatusMessage,
                              onClose: _handleSpinModalClose,
                              onReset: () async {
                                if (_hasSpinSearchChanges) {
                                  Toast.show(
                                    context,
                                    type: ToastType.info,
                                    title: 'ค้นหาสถานที่ก่อน',
                                    message:
                                        'ปรับระยะแล้ว ต้องค้นหาสถานที่เดตก่อนจึงจะสุ่มจากชุดใหม่ได้',
                                  );
                                  return;
                                }
                                await ref
                                    .read(dateRecommendProvider)
                                    .triggerSpin(widget.roomId!);
                              },
                              onSpinRequested: () async {
                                if (_hasSpinSearchChanges) {
                                  await _searchSpinPlaces();
                                  return;
                                }
                                await ref
                                    .read(dateRecommendProvider)
                                    .triggerSpin(widget.roomId!);
                              },
                              onSpinComplete: (result) {
                                _onSpinComplete({
                                  'name': result.label,
                                  ...?_dynamicPrizes
                                      .cast<Map<String, dynamic>?>()
                                      .firstWhere(
                                        (place) =>
                                            place?['name'] == result.label,
                                        orElse: () => null,
                                      ),
                                });
                              },
                              onDistanceChanged: (value) async {
                                if (!mounted) {
                                  return;
                                }
                                setState(() {
                                  _currentRange = value;
                                });
                              },
                              onVariantChanged: (variant) async {
                                _updateSpinFilters(
                                  indexMode: variant == DsSpinWheelVariant.pair
                                      ? 1
                                      : 0,
                                );
                              },
                              onReferenceChanged: (index) async {
                                _updateSpinFilters(indexSelected: index);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                UnlockDateModal(
                  isVisible: _showUnlockDate,
                  onConfirm: _confirmCalendarUnlockIntro,
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
                    initialTime: _calendarIsEditMode
                        ? () {
                            final dt =
                                _existingAppointment?.dateTime?.toLocal() ??
                                DateTime.now();
                            return TimeOfDay.fromDateTime(dt);
                          }()
                        : null,
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
      ),
    );
  }
}

class _ChatUserProfileScreen extends ConsumerStatefulWidget {
  const _ChatUserProfileScreen({
    required this.images,
    required this.initialIndex,
    required this.userName,
    required this.targetUserId,
    required this.initialUser,
    required this.initialProfileJson,
    required this.initialDistance,
    required this.relationshipScore,
  });

  final List<String> images;
  final int initialIndex;
  final String userName;
  final String? targetUserId;
  final User? initialUser;
  final Map<String, dynamic> initialProfileJson;
  final double? initialDistance;
  final int? relationshipScore;

  @override
  ConsumerState<_ChatUserProfileScreen> createState() =>
      _ChatUserProfileScreenState();
}

class _ChatUserProfileScreenState
    extends ConsumerState<_ChatUserProfileScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  User? _user;
  _ChatUserProfileData? _profile;
  bool _isLoadingUser = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _user = widget.initialUser;
    _profile = _ChatUserProfileData.fromProfileJson(
      widget.initialProfileJson,
      fallbackDistance: widget.initialDistance,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_loadProfileData());
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final targetUserId = widget.targetUserId;
    if (targetUserId == null || targetUserId.isEmpty) return;

    setState(() => _isLoadingUser = true);
    final userService = ref.read(userServiceProvider);
    User? fetchedUser = _user;
    Map<String, dynamic> profileJson = widget.initialProfileJson;
    try {
      await ref.read(preferenceServiceProvider).getPreference();
    } catch (_) {
      // Preference catalog is a helper only; raw labels can still render.
    }
    try {
      fetchedUser ??= await userService.fetchUserById(targetUserId);
    } catch (_) {}
    try {
      profileJson = await userService.fetchProfileById(targetUserId);
    } catch (_) {}

    final prefs = ref.read(userStoreProvider)['preferences'];
    if (!mounted) return;
    setState(() {
      _user = fetchedUser;
      _profile = _ChatUserProfileData.fromProfileJson(
        profileJson,
        preferences: prefs is Map ? prefs : null,
        fallbackDistance: widget.initialDistance,
      );
      _isLoadingUser = false;
    });
  }

  bool _isSvg(String path) {
    final uri = Uri.tryParse(path);
    final normalizedPath = (uri?.path ?? path).toLowerCase();
    return normalizedPath.endsWith('.svg');
  }

  Widget _buildImage(String path) {
    if (_isSvg(path)) {
      return path.startsWith('http')
          ? SvgPicture.network(path, fit: BoxFit.contain)
          : SvgPicture.asset(path, fit: BoxFit.contain);
    }

    return path.startsWith('http')
        ? Image.network(
            path,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.person_rounded,
                color: AppColors.textDisabled,
                size: 72,
              );
            },
          )
        : Image.asset(
            path,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.person_rounded,
                color: AppColors.textDisabled,
                size: 72,
              );
            },
          );
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.images.length) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _goNext() => _goTo((_currentIndex + 1) % widget.images.length);

  void _goPrevious() =>
      _goTo((_currentIndex - 1 + widget.images.length) % widget.images.length);

  int? _calculateAge(DateTime? birthday) {
    if (birthday == null) return null;
    final now = DateTime.now();
    int age = now.year - birthday.year;
    final hadBirthdayThisYear =
        now.month > birthday.month ||
        (now.month == birthday.month && now.day >= birthday.day);
    if (!hadBirthdayThisYear) age -= 1;
    return age >= 0 ? age : null;
  }

  String get _displayName {
    final user = _user;
    final nickname = user?.nickname;
    if (nickname != null && nickname.trim().isNotEmpty) {
      return nickname.trim();
    }
    return widget.userName;
  }

  String get _ageText {
    final age = _profile?.age ?? _calculateAge(_user?.birthday);
    return age == null ? 'ไม่ระบุอายุ' : '$age ปี';
  }

  int? get _rawAge => _profile?.age ?? _calculateAge(_user?.birthday);

  String get _profileInfoTitle => _displayName;

  Widget _buildProfileSection(String title, List<String> items) {
    final labels = items.map(displaySelectionLabel).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppDisplayTextStyles.subtitleBold.copyWith(
            color: AppColors.textBlack,
          ),
        ),
        const SizedBox(height: 8),
        if (labels.isEmpty)
          GenericCard(
            iconType: CardIconType.icon,
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.textSupport,
            iconBackground: AppColors.surfaceMuted,
            title: _isLoadingUser ? 'กำลังโหลดข้อมูล' : 'ยังไม่มีข้อมูล',
            backgroundColor: AppColors.surfaceMuted,
            padding: const EdgeInsets.all(12),
          )
        else
          TagSelection(
            items: labels,
            initialSelected: List<int>.generate(
              labels.length,
              (index) => index,
            ),
            shape: TagShape.rounded,
            readOnly: true,
          ),
      ],
    );
  }

  Widget _buildDistanceCard() {
    final distance = _profile?.distance;
    final subtitle = distance == null
        ? 'ยังไม่มีข้อมูลระยะห่าง'
        : '${distance.round()} km.';
    return GenericCard(
      iconType: CardIconType.icon,
      icon: Icons.location_on_rounded,
      iconColor: AppColors.brandPrimary,
      iconBackground: AppColors.surfaceMuted,
      title: 'ระยะห่างที่แมต',
      subtitle: subtitle,
      backgroundColor: AppColors.background,
      padding: const EdgeInsets.all(12),
    );
  }

  Widget _buildProfileInfoPanel() {
    final profile = _profile;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.inputBorder)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.46,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: _profileInfoTitle,
                        style: AppDisplayTextStyles.subtitleBold.copyWith(
                          color: AppColors.textBlack,
                          fontSize: 20,
                        ),
                        children: [
                          if (_rawAge != null)
                            TextSpan(
                              text: ', $_rawAge',
                              style: AppDisplayTextStyles.subtitleBold.copyWith(
                                color: AppColors.textBlack.withOpacity(0.6),
                                fontSize: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_isLoadingUser)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),

              _buildProfileSection('ไลฟ์สไตล์', profile?.lifestyles ?? []),
              const SizedBox(height: 14),
              _buildProfileSection('สิ่งที่สนใจ', profile?.interests ?? []),
              const SizedBox(height: 14),
              _buildProfileSection(
                'สไตล์การท่องเที่ยว',
                profile?.travelStyles ?? [],
              ),
              const SizedBox(height: 14),
              _buildDistanceCard(),
            ],
          ),
        ),
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
            DsAppSecondaryHeader(
              variant: DsAppSecondaryHeaderVariant.baseText,
              title: "ข้อมูลเกี่ยวกับคู่เดต",
              showBottomBorder: true,
              bottomBorderSpacing: 0,
              onBackTap: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.surface,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: widget.images.length,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return Center(
                          child: InteractiveViewer(
                            minScale: 1,
                            maxScale: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: _buildImage(widget.images[index]),
                            ),
                          ),
                        );
                      },
                    ),
                    if (widget.images.length > 1) ...[
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 96,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _goPrevious,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: 96,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _goNext,
                        ),
                      ),
                    ],
                    Positioned(
                      right: 16,
                      top: 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.46),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text(
                            '${_currentIndex + 1}/${widget.images.length}',
                            style: AppBodyTextStyles.captionBold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.images.length > 1)
              SizedBox(
                height: 74,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentIndex;
                    return GestureDetector(
                      onTap: () => _goTo(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 54,
                        height: 54,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.brandPrimary
                                : AppColors.inputBorder,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: _buildImage(widget.images[index]),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemCount: widget.images.length,
                ),
              ),
            _buildProfileInfoPanel(),
          ],
        ),
      ),
    );
  }
}

class _ChatUserProfileData {
  const _ChatUserProfileData({
    required this.lifestyles,
    required this.interests,
    required this.travelStyles,
    required this.tags,
    this.age,
    this.distance,
  });

  final List<String> lifestyles;
  final List<String> interests;
  final List<String> travelStyles;
  final List<String> tags;
  final int? age;
  final double? distance;

  factory _ChatUserProfileData.fromProfileJson(
    Map<String, dynamic> json, {
    Map<dynamic, dynamic>? preferences,
    double? fallbackDistance,
  }) {
    final lifeCatalog = _catalogList(preferences?['lifeStyles']);
    final interestCatalog = _catalogList(preferences?['interests']);
    final travelCatalog = _catalogList(preferences?['travelStyles']);
    final tagCatalog = _catalogList(preferences?['tags']);

    int? resolvedAge = _intFromAny(json['age']);
    if (resolvedAge == null) {
      final rawBirthday = json['birthday'] ?? json['birthDate'];
      if (rawBirthday is String) {
        final bday = DateTime.tryParse(rawBirthday);
        if (bday != null) {
          final now = DateTime.now();
          int age = now.year - bday.year;
          if (now.month < bday.month ||
              (now.month == bday.month && now.day < bday.day)) {
            age -= 1;
          }
          resolvedAge = age >= 0 ? age : null;
        }
      }
    }

    return _ChatUserProfileData(
      lifestyles: _resolveSelectionList(
        _firstValue(json, const [
          'lifestyles',
          'lifeStyles',
          'lifeStyle',
          'lifestyle',
          'userLifeStyles',
          'userLifestyles',
          'userHasLifestyles',
        ]),
        lifeCatalog,
        labelKeys: const ['lifestyle', 'lifeStyle', 'name', 'label'],
      ),
      interests: _resolveSelectionList(
        _firstValue(json, const [
          'interests',
          'interest',
          'userInterests',
          'userHasInterests',
        ]),
        interestCatalog,
        labelKeys: const ['interest', 'name', 'label'],
      ),
      travelStyles: _resolveSelectionList(
        _firstValue(json, const [
          'travelStyles',
          'travelStyle',
          'travelstyles',
          'travelstyle',
          'userTravelStyles',
          'userTravelstyles',
          'userHasTravelstyles',
          'userHasTravelStyles',
        ]),
        travelCatalog,
        labelKeys: const ['travelstyle', 'travelStyle', 'name', 'label'],
      ),
      tags: _resolveSelectionList(
        json['tags'],
        tagCatalog,
        labelKeys: const ['tag', 'name', 'label'],
      ),
      age: resolvedAge,
      distance:
          _doubleFromAny(
            json['matchedDistance'] ??
                json['distance'] ??
                json['matchDistance'] ??
                json['distanceKm'],
          ) ??
          fallbackDistance,
    );
  }

  static List<dynamic> _catalogList(Object? value) {
    if (value is List) return value;
    return const [];
  }

  static List<String> _resolveSelectionList(
    Object? raw,
    List<dynamic> catalog, {
    required List<String> labelKeys,
  }) {
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        return _resolveSelectionList(decoded, catalog, labelKeys: labelKeys);
      } catch (_) {
        return raw.trim().isEmpty ? const [] : [raw];
      }
    }
    if (raw is! List) return const [];
    final labels = <String>[];
    for (final item in raw) {
      final label = _labelFromSelectionItem(
        item,
        catalog,
        labelKeys: labelKeys,
      );
      if (label != null && label.trim().isNotEmpty) {
        labels.add(label.trim());
      }
    }
    return labels.toSet().toList();
  }

  static String? _labelFromSelectionItem(
    Object? item,
    List<dynamic> catalog, {
    required List<String> labelKeys,
  }) {
    if (item == null) return null;
    if (item is String) return item;
    if (item is num) return _labelFromCatalog(item.toInt(), catalog, labelKeys);
    if (item is Map) {
      for (final key in labelKeys) {
        final value = item[key];
        if (value != null &&
            value is! Map &&
            value is! List &&
            value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
      for (final key in labelKeys) {
        final nested = item[key] ?? item['${key}_data'];
        if (nested is Map) {
          final nestedLabel = _labelFromSelectionItem(
            nested,
            catalog,
            labelKeys: labelKeys,
          );
          if (nestedLabel != null) return nestedLabel;
        }
      }
      final id = _intFromAny(
        item['id'] ??
            item['interestId'] ??
            item['lifestyleId'] ??
            item['travelstyleId'] ??
            item['travelStyleId'] ??
            item['tagId'] ??
            item['interest_interestId'] ??
            item['lifestyle_lifestyleId'] ??
            item['travelstyle_travelId'] ??
            item['travelStyle_travelId'] ??
            item['tag_tagId'],
      );
      if (id != null) return _labelFromCatalog(id, catalog, labelKeys);
    }
    return null;
  }

  static String? _labelFromCatalog(
    int id,
    List<dynamic> catalog,
    List<String> labelKeys,
  ) {
    for (final item in catalog) {
      final itemId = _intFromAny(_dynamicValue(item, 'id'));
      if (itemId != id) continue;
      for (final key in labelKeys) {
        final label = _dynamicValue(item, key);
        if (label != null && label.toString().trim().isNotEmpty) {
          return label.toString();
        }
      }
    }
    return null;
  }

  static Object? _dynamicValue(Object? object, String key) {
    if (object is Map) return object[key];
    try {
      final dynamic dynamicObject = object;
      switch (key) {
        case 'id':
          return dynamicObject.id;
        case 'interest':
          return dynamicObject.interest;
        case 'lifestyle':
          return dynamicObject.lifestyle;
        case 'lifeStyle':
          return dynamicObject.lifestyle;
        case 'travelstyle':
          return dynamicObject.travelstyle;
        case 'travelStyle':
          return dynamicObject.travelstyle;
        case 'tag':
          return dynamicObject.tag;
        case 'name':
          return dynamicObject.name;
        case 'label':
          return dynamicObject.label;
      }
    } catch (_) {}
    return null;
  }

  static int? _intFromAny(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _doubleFromAny(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static Object? _firstValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        return json[key];
      }
    }
    return null;
  }
}
