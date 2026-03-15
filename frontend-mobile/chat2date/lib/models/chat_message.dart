import 'package:chat2date/utils/backend_datetime_parser.dart';
import 'package:geolocator/geolocator.dart';

/// ประเภทข้อความ Bot ตาม Figma design
enum BotMessageType {
  /// Bot Minigame - พื้นเหลือง พร้อมปุ่ม "เริ่ม" สีฟ้า (enabled)
  minigame,

  /// Bot Minigame Fail - พื้นเหลือง ปุ่ม disabled "หมดเวลาแล้ว"
  minigameFail,

  /// Bot Ask - พื้นเหลือง พร้อมปุ่ม choice 2 ปุ่ม (ใช่/ไม่)
  ask,

  /// Bot Ask Success - พื้นเขียว "สำเร็จ!"
  askSuccess,

  /// Bot Ask Fail - พื้นแดง "เสียใจด้วย!"
  askFail,
}

/// Model สำหรับข้อความแชท
class ChatMessage {
  final String id;
  final String text;
  final bool isOwn;
  final DateTime timestamp;
  final bool isSeen;
  final int? remainingSeconds;

  // สำหรับ Bot messages
  final bool isBot;
  final BotMessageType? botType;
  final String? description;
  final String? subDescription;
  final String? actionButtonText;
  final bool? isActionDisabled;
  final String? firstChoiceText;
  final String? secondChoiceText;
  final int? answeredCount;
  final int? totalCount;
  final String? gameStatus;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isOwn,
    required this.timestamp,
    this.isSeen = false,
    this.isBot = false,
    this.botType,
    this.description,
    this.subDescription,
    this.actionButtonText,
    this.isActionDisabled,
    this.firstChoiceText,
    this.secondChoiceText,
    this.answeredCount,
    this.totalCount,
    this.remainingSeconds,
    this.gameStatus,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isOwn,
    DateTime? timestamp,
    bool? isSeen,
    bool? isBot,
    BotMessageType? botType,
    String? description,
    String? subDescription,
    String? actionButtonText,
    bool? isActionDisabled,
    String? firstChoiceText,
    String? secondChoiceText,
    int? answeredCount,
    int? totalCount,
    String? gameStatus,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isOwn: isOwn ?? this.isOwn,
      timestamp: timestamp ?? this.timestamp,
      isSeen: isSeen ?? this.isSeen,
      isBot: isBot ?? this.isBot,
      botType: botType ?? this.botType,
      description: description ?? this.description,
      subDescription: subDescription ?? this.subDescription,
      actionButtonText: actionButtonText ?? this.actionButtonText,
      isActionDisabled: isActionDisabled ?? this.isActionDisabled,
      firstChoiceText: firstChoiceText ?? this.firstChoiceText,
      secondChoiceText: secondChoiceText ?? this.secondChoiceText,
      answeredCount: answeredCount ?? this.answeredCount,
      totalCount: totalCount ?? this.totalCount,
      gameStatus: gameStatus ?? this.gameStatus,
    );
  }

  /// สร้างข้อความจาก API (/chats/{roomId})
  factory ChatMessage.fromApi({
    required Map<String, dynamic> json,
    required String currentUserId,
  }) {
    final senderId = json['senderId']?.toString() ?? '';
    final message = json['message']?.toString() ?? '';
    final createdRaw = json['created']?.toString();

    // แปลง timestamp - ใช้ parser กลางให้ logic ตรงกันทั้งแอป
    final typeStr =
        json['messageType']?.toString() ?? json['type']?.toString() ?? 'TEXT';

    final timestamp = parseBackendDateTime(createdRaw) ?? DateTime.now();
    final isOwn = senderId == currentUserId;
    final rawRead =
        json['isRead'] ?? json['is_read'] ?? json['isread'] ?? json['read'];
    final bool messageRead = rawRead is bool
        ? rawRead
        : rawRead is num
        ? rawRead != 0
        : rawRead is String
        ? rawRead == '1' || rawRead.toLowerCase() == 'true'
        : false;

    // --- ส่วน Logic Bot ---
    bool isBotMessage = false;
    BotMessageType? mappedBotType;
    String? displayTitle;
    String? displayDescription;
    String? btnText;
    int? answerCount;

    if (senderId == 'SYSTEM' || typeStr != 'TEXT') {
      if (typeStr == 'GAME') {
        isBotMessage = true;
        mappedBotType = BotMessageType.minigame;
        displayTitle = "🎮 Guessing Game";

        displayDescription = message;

        // Debug log เพื่อตรวจสอบค่า isRead ที่ได้รับจาก API
        print(
          '[ChatMessage.fromApi] messageId=${json['messageId']}, senderId=$senderId, currentUserId=$currentUserId, isOwn=$isOwn, rawRead=$rawRead (${rawRead.runtimeType}), messageRead=$messageRead, isSeen=${isOwn && messageRead}',
        );
        btnText = "เข้าร่วม / เริ่มเกม";
      } else if (typeStr == 'FAIL' &&
          message.contains('ความคิดเห็นที่ไม่ตรงกัน')) {
        isBotMessage = true;
        mappedBotType = BotMessageType.askFail;
      } else if (typeStr == 'FAIL') {
        isBotMessage = true;
        mappedBotType = BotMessageType.minigameFail;
        displayTitle = "⚠️ เกมจบไม่สมบูรณ์";

        displayDescription = message;

        btnText = "เริ่มเกมใหม่";
      } else if (typeStr == 'DATE') {
        isBotMessage = true;
        mappedBotType = BotMessageType.ask;
        final parts = message.split('|');
        displayTitle = parts[0].trim();
        displayDescription = parts[1].trim();

        // --- เพิ่มส่วนการแกะตัวเลขตรงนี้ ---
        if (parts.length > 2) {
          // parts[2] คือ "ตอบแล้ว 1/2"
          final regExp = RegExp(r'(\d+)/(\d+)');
          final match = regExp.firstMatch(parts[2]);

          if (match != null) {
            // ดึงเลข 1 และเลข 2 ออกมา
            answerCount = int.tryParse(match.group(1) ?? '');
          }
        }

        //displayDescription = ;
      } else if (typeStr == 'SUCCESS') {
        isBotMessage = true;
        mappedBotType = BotMessageType.askSuccess;
      }
    }

    return ChatMessage(
      id:
          json['messageId']?.toString() ??
          timestamp.millisecondsSinceEpoch.toString(),

      text: isBotMessage ? (displayTitle ?? message) : message,

      isOwn: isOwn,
      timestamp: timestamp,
      isSeen: isOwn && messageRead,

      // bot fields
      isBot: isBotMessage,
      botType: mappedBotType,
      description: displayDescription,
      actionButtonText: btnText,
      isActionDisabled: false,
      answeredCount: answerCount,
    );
  }

  /// สร้าง User message (ส่งออก - ขวา)
  factory ChatMessage.sent({
    required String id,
    required String text,
    DateTime? timestamp,
    bool isSeen = false,
  }) {
    return ChatMessage(
      id: id,
      text: text,
      isOwn: true,
      timestamp: timestamp ?? DateTime.now(),
      isSeen: isSeen,
    );
  }

  /// สร้าง User message (รับเข้า - ซ้าย)
  factory ChatMessage.received({
    required String id,
    required String text,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id,
      text: text,
      isOwn: false,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// สร้าง Bot Minigame message
  factory ChatMessage.botMinigame({
    required String id,
    required String text,
    required String description,
    String? subDescription,
    String actionButtonText = 'เริ่ม',
    bool isDisabled = false,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id,
      text: text,
      isOwn: false,
      isBot: true,
      botType: isDisabled
          ? BotMessageType.minigameFail
          : BotMessageType.minigame,
      description: description,
      subDescription: subDescription,
      actionButtonText: actionButtonText,
      isActionDisabled: isDisabled,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// สร้าง Bot Ask message (พร้อมปุ่ม ใช่/ไม่)
  factory ChatMessage.botAsk({
    required String id,
    required String text,
    required String description,
    String firstChoiceText = 'ไป',
    String secondChoiceText = 'ไม่ไป',
    int answeredCount = 0,
    int totalCount = 2,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id,
      text: text,
      isOwn: false,
      isBot: true,
      botType: BotMessageType.ask,
      description: description,
      firstChoiceText: firstChoiceText,
      secondChoiceText: secondChoiceText,
      answeredCount: answeredCount,
      totalCount: totalCount,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// สร้าง Bot Ask Success message
  factory ChatMessage.botAskSuccess({
    required String id,
    String text = 'สำเร็จ!',
    String? description,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id,
      text: text,
      isOwn: false,
      isBot: true,
      botType: BotMessageType.askSuccess,
      description: description ?? 'กรุณากรอกวันที่ออกเดตของคุณในปฏิทิน',
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// สร้าง Bot Ask Fail message
  factory ChatMessage.botAskFail({
    required String id,
    String text = 'เสียใจด้วย!',
    String? description,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id,
      text: text,
      isOwn: false,
      isBot: true,
      botType: BotMessageType.askFail,
      description: description ?? 'คุณทั้ง 2 คนความคิดเห็นไม่ตรงกัน',
      timestamp: timestamp ?? DateTime.now(),
    );
  }
}
