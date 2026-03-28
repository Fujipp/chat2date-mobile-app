import 'dart:async';

import 'package:chat2date/components/design_system/buttons/index.dart';
import 'package:chat2date/core/theme/app_assets.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/body_text_styles.dart';
import 'package:flutter/material.dart';

enum DsBotChatType {
  minigame,
  minigameFail,
  ask,
  askAnswer,
  askSuccess,
  askFail,
}

class DsBotChat extends StatefulWidget {
  const DsBotChat({
    super.key,
    required this.type,
    this.title,
    this.description,
    this.subDescription,
    this.actionLabel = 'เริ่ม',
    this.declineLabel = 'ไม่ไป',
    this.acceptLabel = 'ไป',
    this.answeredCount = 0,
    this.totalCount = 2,
    this.createdAt,
    this.now,
    this.onActionPressed,
    this.onDeclinePressed,
    this.onAcceptPressed,
    this.width = 360,
    this.avatarImage,
    this.avatar,
  });

  final DsBotChatType type;
  final String? title;
  final String? description;
  final String? subDescription;
  final String actionLabel;
  final String declineLabel;
  final String acceptLabel;
  final int answeredCount;
  final int totalCount;
  final DateTime? createdAt;
  final DateTime? now;
  final VoidCallback? onActionPressed;
  final VoidCallback? onDeclinePressed;
  final VoidCallback? onAcceptPressed;
  final double width;
  final ImageProvider<Object>? avatarImage;
  final Widget? avatar;

  @override
  State<DsBotChat> createState() => _DsBotChatState();
}

class _DsBotChatState extends State<DsBotChat> {
  Timer? _timer;
  late DateTime _currentNow;

  @override
  void initState() {
    super.initState();
    _currentNow = widget.now ?? DateTime.now();
    if (_shouldTick) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          _currentNow = _currentNow.add(const Duration(seconds: 1));
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant DsBotChat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.now != oldWidget.now) {
      _currentNow = widget.now ?? DateTime.now();
    }
    if (_shouldTick != (oldWidget.type == DsBotChatType.minigame)) {
      _timer?.cancel();
      if (_shouldTick) {
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() {
            _currentNow = _currentNow.add(const Duration(seconds: 1));
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _shouldTick => widget.type == DsBotChatType.minigame;

  bool get _isMinigameExpired {
    if (widget.type != DsBotChatType.minigame) return false;
    final createdAt = widget.createdAt;
    if (createdAt == null) return false;
    return _currentNow.difference(createdAt) >= const Duration(hours: 24);
  }

  DsBotChatType get _effectiveType =>
      _isMinigameExpired ? DsBotChatType.minigameFail : widget.type;

  String get _resolvedTitle {
    if (widget.title != null) return widget.title!;
    return switch (_effectiveType) {
      DsBotChatType.minigame || DsBotChatType.minigameFail => 'กลับไปเล่นใหม่อีกรอบ',
      DsBotChatType.ask || DsBotChatType.askAnswer => 'สุ่มได้สถานที่ : อควาเรียมบางแสน',
      DsBotChatType.askSuccess => 'สำเร็จ!',
      DsBotChatType.askFail => 'เสียใจด้วย!',
    };
  }

  String? get _resolvedDescription {
    if (widget.description != null) return widget.description!;
    return switch (_effectiveType) {
      DsBotChatType.minigame || DsBotChatType.minigameFail =>
        'หมายเหตุ: เมื่อกดเริ่มแล้วจะไม่สามารถกลับ\nมาเล่นอีกรอบได้ควรคุยหรือรอคู่ของคุณก่อน',
      DsBotChatType.ask || DsBotChatType.askAnswer => 'คุณอยากไปเที่ยวหรือไม่',
      DsBotChatType.askSuccess => 'กรุณากรอกวันที่ออกเดตของคุณในปฏิทิน',
      DsBotChatType.askFail => 'คุณทั้ง 2 คนความคิดเห็นไม่ตรงกัน',
    };
  }

  String? get _resolvedSubDescription {
    if (widget.subDescription != null) return widget.subDescription!;
    if (_effectiveType == DsBotChatType.minigame) {
      return _remainingLabel;
    }
    if (_effectiveType == DsBotChatType.minigameFail) {
      return 'หมดเวลาแล้ว';
    }
    if (_effectiveType == DsBotChatType.ask || _effectiveType == DsBotChatType.askAnswer) {
      return 'ตอบแล้ว ${widget.answeredCount}/${widget.totalCount}';
    }
    return null;
  }

  String get _remainingLabel {
    final createdAt = widget.createdAt;
    if (createdAt == null) return 'เหลือเวลาเริ่มใหม่ 24 ชั่วโมง';
    final expiresAt = createdAt.add(const Duration(hours: 24));
    final remaining = expiresAt.difference(_currentNow);
    if (remaining <= Duration.zero) return 'หมดเวลาแล้ว';

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    return 'เหลือเวลาเริ่มใหม่ '
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Color get _bubbleColor {
    return switch (_effectiveType) {
      DsBotChatType.askSuccess => const Color(0xFF8BF78D),
      DsBotChatType.askFail => AppColors.denied,
      _ => AppColors.warning,
    };
  }

  bool get _isCenteredResult =>
      _effectiveType == DsBotChatType.askSuccess ||
      _effectiveType == DsBotChatType.askFail;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10, bottom: 4),
            child: _BotAvatar(
              avatar: widget.avatar,
              avatarImage: widget.avatarImage,
            ),
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 76),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _bubbleColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_effectiveType == DsBotChatType.askSuccess ||
        _effectiveType == DsBotChatType.askFail) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _resolvedTitle,
            textAlign: TextAlign.center,
            style: AppBodyTextStyles.bodyBold.copyWith(
              fontSize: 16,
              height: 22 / 16,
              color: AppColors.textBlack,
            ),
          ),
          if ((_resolvedDescription ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _resolvedDescription!,
              textAlign: TextAlign.center,
              style: AppBodyTextStyles.body.copyWith(
                color: AppColors.textBlack,
              ),
            ),
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          _isCenteredResult ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          _resolvedTitle,
          style: AppBodyTextStyles.bodyBold.copyWith(
            fontSize: 16,
            height: 22 / 16,
            color: AppColors.textBlack,
          ),
        ),
        if ((_resolvedDescription ?? '').isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            _resolvedDescription!,
            style: AppBodyTextStyles.body.copyWith(
              color: AppColors.textSupport,
            ),
          ),
        ],
        if ((_resolvedSubDescription ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: Text(
              _resolvedSubDescription!,
              textAlign: TextAlign.center,
              style: AppBodyTextStyles.overline.copyWith(
                color: _effectiveType == DsBotChatType.minigameFail
                    ? AppColors.textSupport
                    : AppColors.error,
              ),
            ),
          ),
        ],
        if (_effectiveType == DsBotChatType.minigame ||
            _effectiveType == DsBotChatType.minigameFail) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: DsButton(
              label: widget.actionLabel,
              onPressed: _effectiveType == DsBotChatType.minigame
                  ? widget.onActionPressed ?? () {}
                  : null,
              variant: DsButtonVariant.primary,
              width: 231,
              visualOverride: _effectiveType == DsBotChatType.minigameFail
                  ? DsButtonVisualState.disabled
                  : null,
            ),
          ),
        ],
        if (_effectiveType == DsBotChatType.ask ||
            _effectiveType == DsBotChatType.askAnswer) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DsButton(
                label: widget.declineLabel,
                onPressed: _effectiveType == DsBotChatType.ask
                    ? widget.onDeclinePressed ?? () {}
                    : null,
                variant: DsButtonVariant.error,
                width: 100,
                visualOverride: _effectiveType == DsBotChatType.askAnswer
                    ? DsButtonVisualState.disabled
                    : null,
              ),
              const SizedBox(width: 32),
              DsButton(
                label: widget.acceptLabel,
                onPressed: _effectiveType == DsBotChatType.ask
                    ? widget.onAcceptPressed ?? () {}
                    : null,
                variant: DsButtonVariant.secondary,
                width: 100,
                visualOverride: _effectiveType == DsBotChatType.askAnswer
                    ? DsButtonVisualState.disabled
                    : null,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _BotAvatar extends StatelessWidget {
  const _BotAvatar({
    this.avatar,
    this.avatarImage,
  });

  final Widget? avatar;
  final ImageProvider<Object>? avatarImage;

  @override
  Widget build(BuildContext context) {
    if (avatar != null) {
      return SizedBox(width: 50, height: 50, child: avatar);
    }
    if (avatarImage != null) {
      return Image(
        image: avatarImage!,
        width: 50,
        height: 50,
        fit: BoxFit.contain,
      );
    }
    return Image.asset(
      AppAssets.botChatIllustration,
      width: 50,
      height: 50,
      fit: BoxFit.contain,
    );
  }
}
