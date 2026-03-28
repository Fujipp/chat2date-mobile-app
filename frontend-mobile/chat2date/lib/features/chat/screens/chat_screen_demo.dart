import 'package:chat2date/components/chat/bot_message_component.dart';
import 'package:chat2date/components/chat/chat_text_component.dart';
import 'package:chat2date/components/chat/input_chat_component.dart';
import 'package:chat2date/components/chat/spin_date_component.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/status_bar/score_row.dart';
import 'package:chat2date/models/chat_message.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Chat Screen ที่รองรับ Figma variants ทั้งหมด:
///
/// - Design 1 (4131-16076): Inside Chat View - ข้อความปกติ
/// - Design 2 (4131-14998): Inside Chat View - ข้อความ + เห็นแล้ว
/// - Design 3 (4131-16486): Bot Chat View - Bot Minigame
/// - Design 4 (4131-18071): Answer Yes View - Bot Ask Success
/// - Design 5 (4131-15316): Inside Chat View - Keyboard
/// - Design 6 (4131-18300): Level 3 View - Rainbow Progress Bar
/// - Design 7 (4131-18205): Answer No View - Bot Ask Fail
enum ChatScreenVariant {
  /// Design 1 & 2: ข้อความปกติ
  normalChat,

  /// Design 3: Bot Minigame
  botMinigame,

  /// Design 4: Bot Ask Success
  botSuccess,

  /// Design 5: มี keyboard
  withKeyboard,

  /// Design 6: Rainbow progress bar (Level 3)
  level3Rainbow,

  /// Design 7: Bot Ask Fail
  botFail,
}

class ChatScreenDemo extends StatefulWidget {
  final ChatScreenVariant variant;

  const ChatScreenDemo({
    super.key,
    this.variant = ChatScreenVariant.normalChat,
  });

  @override
  State<ChatScreenDemo> createState() => _ChatScreenDemoState();
}

class _ChatScreenDemoState extends State<ChatScreenDemo> {
  final TextEditingController _messageController = TextEditingController();
  bool _hasText = false;
  bool _showWheelModal = false;

  // ค่าตาม Figma
  double get _currentPercent {
    switch (widget.variant) {
      case ChatScreenVariant.level3Rainbow:
        return 1.0; // เต็ม 100%
      default:
        return 0.35; // 90px / 255px ≈ 35%
    }
  }

  int get _heartNumber {
    switch (widget.variant) {
      case ChatScreenVariant.level3Rainbow:
        return 3; // Rainbow heart
      default:
        return 0; // ไม่แสดงเลข
    }
  }

  ChatHeaderVariant get _headerVariant {
    switch (widget.variant) {
      case ChatScreenVariant.normalChat:
      case ChatScreenVariant.botMinigame:
        return ChatHeaderVariant.chat1;
      case ChatScreenVariant.botFail:
        return ChatHeaderVariant.chat2;
      case ChatScreenVariant.botSuccess:
      case ChatScreenVariant.level3Rainbow:
      case ChatScreenVariant.withKeyboard:
        return ChatHeaderVariant.chat3;
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
          children: [
            Column(
              children: [
                const SizedBox(height: 8),
                _buildHeader(),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _buildProgressBar(),
                      const SizedBox(height: 12),
                      Text(
                        'วันเสาร์ 13:30',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      Expanded(child: _buildMessageList()),
                      _buildInputArea(),
                    ],
                  ),
                ),
              ],
            ),
            if (_showWheelModal) _buildWheelModal(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Header.fromVariant(
      variant: _headerVariant,
      name: 'Name',
      cooldownDays: 7,
      showBorder: false,
      onBack: () => Navigator.maybePop(context),
      onSpinwheel: () {
        setState(() {
          _showWheelModal = true;
        });
      },
      onFlag: () {
        Navigator.pushReplacementNamed(context, '/report');
      },
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double barWidth = (constraints.maxWidth - 25 - 20).clamp(
            140.0,
            260.0,
          );
          return ScoreRow(
            basePercent: _currentPercent,
            number: _heartNumber,
            barWidth: barWidth,
            barHeight: 8,
            rightIconSize: 18,
          );
        },
      ),
    );
  }

  Widget _buildMessageList() {
    final messages = _getMessagesForVariant();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildMessageWidget(message),
        );
      },
    );
  }

  List<ChatMessage> _getMessagesForVariant() {
    switch (widget.variant) {
      case ChatScreenVariant.normalChat:
      case ChatScreenVariant.withKeyboard:
        return [
          ChatMessage.sent(id: '1', text: 'text message'),
          ChatMessage.received(id: '2', text: 'text message'),
          ChatMessage.received(id: '3', text: 'text message'),
          ChatMessage.sent(id: '4', text: 'text message', isSeen: true),
        ];

      case ChatScreenVariant.botMinigame:
        return [
          ChatMessage.sent(id: '1', text: 'text message'),
          ChatMessage.botMinigame(
            id: '2',
            text: 'กลับไปเล่นใหม่อีกรอบ',
            description:
                'หมายเหตุ เมื่อกดเริ่มแล้วจะไม่สามารถกลับมาเล่นอีกรอบได้ควรคุยหรือรอคู่ของคุณก่อน',
            subDescription: 'เหลือเวลาเริ่มใหม่ 24 ชั่วโมง',
            actionButtonText: 'เริ่ม',
          ),
        ];

      case ChatScreenVariant.botSuccess:
        return [
          ChatMessage.sent(id: '1', text: 'text message'),
          ChatMessage.received(id: '2', text: 'text message'),
          ChatMessage.received(id: '3', text: 'text message'),
          ChatMessage.sent(id: '4', text: 'text message'),
          ChatMessage.botAskSuccess(
            id: '5',
            text: 'สำเร็จ!',
            description: 'กรุณากรอกวันที่ออกเดตของคุณในปฏิทิน',
          ),
        ];

      case ChatScreenVariant.level3Rainbow:
        return [
          ChatMessage.sent(id: '1', text: 'text message'),
          ChatMessage.received(id: '2', text: 'text message'),
          ChatMessage.received(id: '3', text: 'text message'),
          ChatMessage.sent(id: '4', text: 'text message'),
          ChatMessage.botAskSuccess(
            id: '5',
            text: 'สำเร็จ!',
            description: 'กรุณากรอกวันที่ออกเดตของคุณในปฏิทิน',
          ),
        ];

      case ChatScreenVariant.botFail:
        return [
          ChatMessage.sent(id: '1', text: 'text message'),
          ChatMessage.received(id: '2', text: 'text message'),
          ChatMessage.received(id: '3', text: 'text message'),
          ChatMessage.sent(id: '4', text: 'text message'),
          ChatMessage.botAskFail(
            id: '5',
            text: 'เสียใจด้วย!',
            description: 'คุณทั้ง 2 คนความคิดเห็นไม่ตรงกัน',
          ),
        ];
    }
  }

  Widget _buildMessageWidget(ChatMessage message) {
    // Bot message
    if (message.isBot && message.botType != null) {
      return BotMessageComponent.fromMessage(
        message: message,
        onActionPressed: () {
          debugPrint('Action pressed for message: ${message.id}');
        },
        onFirstChoice: () {
          debugPrint('First choice (ใช่) for message: ${message.id}');
        },
        onSecondChoice: () {
          debugPrint('Second choice (ไม่) for message: ${message.id}');
        },
      );
    }

    // User message
    return Column(
      crossAxisAlignment: message.isOwn
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        ChatTextComponent(
          text: message.text,
          isChatRight: message.isOwn,
          bottomLeftRadius: message.isOwn ? 20 : 0,
          bottomRightRadius: message.isOwn ? 0 : 20,
        ),
        if (message.isOwn && message.isSeen)
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
  }

  Widget _buildInputArea() {
    return InputChatComponent(
      svgPath: 'assets/icons/ui/icon_new-black.svg',
      svgPathLast: _hasText ? 'assets/icons/ui/icon_send.svg' : null,
      leftIconColor: AppColors.surfaceLight,
      sendIconColor: Colors.white,
      sendIconBackgroundColor: AppColors.surfaceLight,
      isSendEnabled: _hasText,
      controller: _messageController,
      onChanged: (value) => setState(() => _hasText = value.trim().isNotEmpty),
      onSend: () {
        // Handle send
      },
    );
  }

  Widget _buildWheelModal() {
    return Stack(
      children: [
        Positioned.fill(
          top: 85,
          child: GestureDetector(
            onTap: () => setState(() => _showWheelModal = false),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
        ),
        Positioned.fill(
          top: 85,
          child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
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
    );
  }
}
