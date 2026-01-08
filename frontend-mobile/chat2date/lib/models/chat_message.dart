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
  });
  
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
      botType: isDisabled ? BotMessageType.minigameFail : BotMessageType.minigame,
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
    String firstChoiceText = 'ใช่',
    String secondChoiceText = 'ไม่',
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
