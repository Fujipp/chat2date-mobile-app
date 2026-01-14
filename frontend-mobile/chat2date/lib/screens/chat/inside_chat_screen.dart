import 'dart:ui';

import 'package:chat2date/components/chat/bot_message_component.dart';
import 'package:chat2date/components/chat/chat_text_component.dart';
import 'package:chat2date/components/chat/input_chat_component.dart';
import 'package:chat2date/components/chat/spin_date_component.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/status_bar/score_row.dart';
import 'package:chat2date/models/chat_message.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';

class InsideChatScreen extends StatefulWidget {
  const InsideChatScreen({super.key});

  @override
  State<InsideChatScreen> createState() => _InsideChatScreenState();
}

class _InsideChatScreenState extends State<InsideChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _hasText = false;
  final double _currentPercent = 0.35; // 90px / 255px ≈ 0.35 ตาม Figma
  final int _heartCount = 1; // 0 = ซ่อน, 1-2 = แสดง, 3 = rainbow
  bool _showWheelModal = false;
  bool _showUnlockDate = false;

  // === Chat User Data (ดึงจากข้อมูลจริง) ===
  String _chatUserName = 'Name';
  String? _chatUserAvatar;

  // === Spinwheel Cooldown Logic ===
  DateTime? _lastSpinDate; // วันที่หมุนวงล้อล่าสุด
  int _cooldownDays = 7; // จำนวนวันที่ต้องรอก่อนหมุนได้อีกครั้ง
  bool _canSpin = true; // true = กดได้ (Chat 2/3), false = cooldown (Chat 4)
  ChatHeaderVariant _headerVariant = ChatHeaderVariant.chat1;

  // ตัวอย่างข้อความแชทตาม Figma designs
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _loadChatUserData();
    _checkSpinWheelCondition();
    _initSampleMessages();
  }

  /// ดึงข้อมูล user ของแชทนี้ (avatar, name)
  Future<void> _loadChatUserData() async {
    // TODO: ดึงข้อมูลจาก backend/argument
    // ตัวอย่าง: final chatUser = await chatService.getChatUser(chatId);
    setState(() {
      _chatUserName = 'Name'; // chatUser.name
      _chatUserAvatar = null; // chatUser.avatarUrl
    });
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

  void _initSampleMessages() {
    _messages = [
      // ข้อความปกติ
      ChatMessage.sent(id: '1', text: 'text message', isSeen: false),
      ChatMessage.received(id: '2', text: 'text message'),
      ChatMessage.received(id: '3', text: 'text message'),
      ChatMessage.sent(id: '4', text: 'text message', isSeen: true),
    ];
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
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage.sent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _messageController.text.trim(),
          isSeen: false,
        ),
      );
      _messageController.clear();
      _hasText = false;
    });
  }

  /// คำนวณ position ของ bubble ในกลุ่ม (burger style)
  /// Returns: single, first, middle, last
  String _getBubblePosition(int index) {
    final current = _messages[index];
    if (current.isBot) return 'single';

    final bool hasPrevSameOwner =
        index > 0 &&
        _messages[index - 1].isOwn == current.isOwn &&
        !_messages[index - 1].isBot;
    final bool hasNextSameOwner =
        index < _messages.length - 1 &&
        _messages[index + 1].isOwn == current.isOwn &&
        !_messages[index + 1].isBot;

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
    return _messages[index + 1].isOwn || _messages[index + 1].isBot;
  }

  /// ตรวจสอบว่าเป็นข้อความสุดท้ายในกลุ่มหรือไม่
  bool _isLastInGroup(int index) {
    if (index >= _messages.length - 1) return true;
    return _messages[index + 1].isOwn != _messages[index].isOwn ||
        _messages[index + 1].isBot;
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
        });
      }
    });
  }

  /// สร้าง Widget สำหรับแต่ละ message
  Widget _buildMessageWidget(ChatMessage message, int index) {
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
    final showSeen = message.isOwn && message.isSeen && _isLastInGroup(index);

    if (message.isOwn) {
      // Sent message (ขวา - ชมพู)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ChatTextComponent(
            text: message.text,
            isChatRight: true,
            topLeftRadius: radius['tl'],
            topRightRadius: radius['tr'],
            bottomLeftRadius: radius['bl'],
            bottomRightRadius: radius['br'],
          ),
          if (showSeen)
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
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar หรือ space (avatar อยู่ที่ข้อความสุดท้าย)
          if (showAvatar)
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: Icon(Icons.person, color: Colors.grey[400], size: 32),
            )
          else
            const SizedBox(width: 58),
          // Message bubble
          Flexible(
            child: ChatTextComponent(
              text: message.text,
              isChatRight: false,
              topLeftRadius: radius['tl'],
              topRightRadius: radius['tr'],
              bottomLeftRadius: radius['bl'],
              bottomRightRadius: radius['br'],
            ),
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onBack: () => Navigator.maybePop(context),
                  onCalendar: () {
                    // TODO: เปิด Calendar
                    debugPrint('Calendar tapped');
                  },
                  onSpinwheel:
                      _handleSpinwheelTap,
                      //_triggerUnlockDate,
                  onFlag: () {
                    Navigator.pushReplacementNamed(context, '/report');
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
                              number: 0,
                              barWidth: barWidth,
                              barHeight: 8,
                              rightIconSize: 18,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'วันเสาร์ 13:30',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            // Gap: 10px สำหรับ grouped messages, 12px สำหรับ different owner
                            final bool isGroupedWithNext =
                                index < _messages.length - 1 &&
                                _messages[index + 1].isOwn == message.isOwn &&
                                !_messages[index + 1].isBot &&
                                !message.isBot;
                            final double bottomGap = isGroupedWithNext
                                ? 10
                                : 12;

                            return Padding(
                              padding: EdgeInsets.only(bottom: bottomGap),
                              child: _buildMessageWidget(message, index),
                            );
                          },
                        ),
                      ),
                      InputChatComponent(
                        svgPath: 'assets/icons/icon_more-options.svg',
                        svgPathLast: 'assets/icons/icon_send.svg',
                        leftIconColor: AppColors.surfaceLight,
                        sendIconColor: null, // icon_send.svg already has colors
                        sendIconBackgroundColor:
                            null, // icon_send.svg already has bg
                        isSendEnabled: _hasText,
                        controller: _messageController,
                        onChanged: (value) =>
                            setState(() => _hasText = value.trim().isNotEmpty),
                        onSend: _hasText ? () => _sendMessage() : null,
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
              // 1. Full Screen Blur (โทนฟ้าสว่างเหมือนท้องฟ้าตอนสายๆ)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withOpacity(0.4),
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
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(45),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade200.withOpacity(0.3),
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
                                      backgroundColor: Colors.blue.shade50,
                                    ),
                                  ),
                                  Positioned(
                                    top: -20,
                                    right: -10,
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.lightBlue.shade100
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  const Center(
                                    child: Text(
                                      "IT'S DATE TIME!",
                                      style: TextStyle(
                                        color: Color(0xFF0284C7),
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
                                // --- ไอคอน: กล้องสีฟ้าพาสเทล + หัวใจ 3D ---
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // แสงออร่าสีฟ้าอ่อน
                                    Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.blue.shade100,
                                            Colors.white.withOpacity(0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // กล้องถ่ายรูป (Soft Blue Gradient)
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF7DD3FC),
                                            Color(0xFF0EA5E9),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF0EA5E9,
                                            ).withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.photo_camera_back_rounded,
                                        color: Colors.white,
                                        size: 45,
                                      ),
                                    ),
                                    // หัวใจสีชมพูพีช (เพื่อให้ดูรักๆ แต่เข้ากับสีฟ้า)
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: const Icon(
                                        Icons.favorite_rounded,
                                        color: Color(0xFFF472B6),
                                        size: 38,
                                      ),
                                    ),
                                    // เข็มทิศสีน้ำเงินเข้ม
                                    Positioned(
                                      bottom: 0,
                                      left: 10,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF0369A1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.explore_rounded,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // --- ข้อความหัวข้อ ---
                                const Text(
                                  'Unlock Your Date!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'เตรียมตัวไปสร้างเดทสุดพิเศษ\nกับคู่ของคุณกัน!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueGrey.shade600,
                                    height: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // --- ปุ่ม Let's Go (Sky Blue Gradient) ---
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF38BDF8),
                                        Color(0xFF0284C7),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF0284C7,
                                        ).withOpacity(0.3),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      'ไปเดทกันเลย!',
                                      style: TextStyle(
                                        color: Colors.white,
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
    );
  }
}
