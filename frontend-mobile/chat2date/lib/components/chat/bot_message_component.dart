import 'package:chat2date/models/chat_message.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Bot Message Component ตาม Figma Design
/// รองรับ 5 variants:
/// - Bot Minigame: พื้นเหลือง + ปุ่ม "เริ่ม" สีฟ้า
/// - Bot Minigame Fail: พื้นเหลือง + ปุ่ม disabled
/// - Bot Ask: พื้นเหลือง + ปุ่ม choice 2 ปุ่ม
/// - Bot Ask Success: พื้นเขียว + ข้อความสำเร็จ
/// - Bot Ask Fail: พื้นแดง + ข้อความเสียใจ
class BotMessageComponent extends StatelessWidget {
  final BotMessageType type;
  final String title;
  final String? description;
  final String? subDescription;
  final String? actionButtonText;
  final bool isActionDisabled;
  final VoidCallback? onActionPressed;
  final String? firstChoiceText;
  final String? secondChoiceText;
  final VoidCallback? onFirstChoice;
  final VoidCallback? onSecondChoice;
  final int answeredCount;
  final int totalCount;

  const BotMessageComponent({
    super.key,
    required this.type,
    required this.title,
    this.description,
    this.subDescription,
    this.actionButtonText,
    this.isActionDisabled = false,
    this.onActionPressed,
    this.firstChoiceText,
    this.secondChoiceText,
    this.onFirstChoice,
    this.onSecondChoice,
    this.answeredCount = 0,
    this.totalCount = 2,
  });

  /// สร้างจาก ChatMessage model
  factory BotMessageComponent.fromMessage({
    required ChatMessage message,
    VoidCallback? onActionPressed,
    VoidCallback? onFirstChoice,
    VoidCallback? onSecondChoice,
  }) {
    return BotMessageComponent(
      type: message.botType ?? BotMessageType.minigame,
      title: message.text,
      description: message.description,
      subDescription: message.subDescription,
      actionButtonText: message.actionButtonText,
      isActionDisabled: message.isActionDisabled ?? false,
      onActionPressed: onActionPressed,
      firstChoiceText: message.firstChoiceText,
      secondChoiceText: message.secondChoiceText,
      onFirstChoice: onFirstChoice,
      onSecondChoice: onSecondChoice,
      answeredCount: message.answeredCount ?? 0,
      totalCount: message.totalCount ?? 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Bot Icon
        Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColors.textMuted,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/icon_bot.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        // Message bubble
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case BotMessageType.minigame:
      case BotMessageType.minigameFail:
      case BotMessageType.ask:
        return AppColors.badgeWarning; // #FFF2CC
      case BotMessageType.askSuccess:
        return const Color(0xFFE9FFE9); // สีเขียวอ่อน
      case BotMessageType.askFail:
        return AppColors.badgeErrorBg; // #FFE6E6
    }
  }

  Color _getDescriptionColor() {
    switch (type) {
      case BotMessageType.minigame:
      case BotMessageType.minigameFail:
      case BotMessageType.ask:
        return const Color(0xFF7A4D0B); // สีน้ำตาลเข้ม
      case BotMessageType.askSuccess:
        return AppColors.successText; // #14532D
      case BotMessageType.askFail:
        return const Color(0xFF991B1B); // สีแดงเข้ม
    }
  }

  Widget _buildContent() {
    switch (type) {
      case BotMessageType.minigame:
      case BotMessageType.minigameFail:
        return _buildMinigameContent();
      case BotMessageType.ask:
        return _buildAskContent();
      case BotMessageType.askSuccess:
      case BotMessageType.askFail:
        return _buildResultContent();
    }
  }

  /// Bot Minigame / Minigame Fail
  Widget _buildMinigameContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(
            description!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _getDescriptionColor(),
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),
        ],
        if (subDescription != null) ...[
          const SizedBox(height: 8),
          Text(
            subDescription!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),
        ],
        const SizedBox(height: 12),
        // Action Button
        _buildActionButton(),
      ],
    );
  }

  /// Bot Ask (พร้อมปุ่ม choice)
  Widget _buildAskContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(
            description!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _getDescriptionColor(),
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),
        ],
        // Answered counter
        const SizedBox(height: 4),
        Text(
          'ตอบแล้ว $answeredCount/$totalCount',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        // Choice buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ปุ่ม "ไม่" (แดง)
            _buildChoiceButton(
              text: secondChoiceText ?? 'ไม่',
              color: const Color(0xFFFF6B6B),
              onPressed: onSecondChoice,
            ),
            const SizedBox(width: 12),
            // ปุ่ม "ใช่" (เขียว)
            _buildChoiceButton(
              text: firstChoiceText ?? 'ใช่',
              color: const Color(0xFF98FB98),
              onPressed: onFirstChoice,
            ),
          ],
        ),
      ],
    );
  }

  /// Bot Ask Success / Fail
  Widget _buildResultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title (bold)
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(
            description!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _getDescriptionColor(),
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton() {
    final bool disabled = isActionDisabled || type == BotMessageType.minigameFail;
    
    return GestureDetector(
      onTap: disabled ? null : onActionPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.btnDisabledPrimary
              : AppColors.btnPrimary, // #5CE1E6
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          actionButtonText ?? 'เริ่ม',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: disabled ? AppColors.textMuted : AppColors.textPrimary,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String text,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
        ),
      ),
    );
  }
}
