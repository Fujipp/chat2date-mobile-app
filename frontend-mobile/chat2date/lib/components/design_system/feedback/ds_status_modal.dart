import 'dart:async';
import 'dart:ui';

import 'package:chat2date/theme/app_assets.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:chat2date/theme/tokens/typography/body_text_styles.dart';
import 'package:chat2date/theme/tokens/typography/display_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum DsStatusModalType { success, warning, ban, congrats }

enum DsStatusModalBodyMode { textOnly, inlineIcon }

class DsStatusModal extends StatelessWidget {
  const DsStatusModal({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.trailingMessage,
    this.bodyMode = DsStatusModalBodyMode.textOnly,
    this.width = 310,
    this.minHeight = 220,
  });

  final DsStatusModalType type;
  final String title;
  final String message;
  final String? trailingMessage;
  final DsStatusModalBodyMode bodyMode;
  final double width;
  final double minHeight;

  static void show(
    BuildContext context, {
    required DsStatusModalType type,
    required String title,
    required String message,
    String? trailingMessage,
    DsStatusModalBodyMode bodyMode = DsStatusModalBodyMode.textOnly,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late final OverlayEntry entry;
    Timer? timer;

    void remove() {
      timer?.cancel();
      if (entry.mounted) {
        entry.remove();
      }
    }

    entry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: ColoredBox(
                  color: AppColors.overlay.withValues(alpha: 0.18),
                ),
              ),
            ),
            Center(
              child: DsStatusModal(
                type: type,
                title: title,
                message: message,
                trailingMessage: trailingMessage,
                bodyMode: bodyMode,
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(entry);
    timer = Timer(duration, remove);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child: SvgPicture.asset(_iconAsset, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppDisplayTextStyles.subtitleBold.copyWith(
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          if (bodyMode == DsStatusModalBodyMode.inlineIcon)
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 2,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: AppBodyTextStyles.bodySmall.copyWith(
                    color: AppColors.textSupport,
                  ),
                ),
                Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.textBlack,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 7,
                    height: 7,
                    child: SvgPicture.asset(
                      AppAssets.infoIcon,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textBlack,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                if (trailingMessage != null)
                  Text(
                    trailingMessage!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: AppBodyTextStyles.bodySmall.copyWith(
                      color: AppColors.textSupport,
                    ),
                  ),
              ],
            )
          else
            Text(
              [message, trailingMessage]
                  .where((part) => part != null && part.trim().isNotEmpty)
                  .join('\n'),
              textAlign: TextAlign.center,
              maxLines: 5,
              style: AppBodyTextStyles.bodySmall.copyWith(
                color: AppColors.textSupport,
              ),
            ),
        ],
      ),
    );
  }

  String get _iconAsset {
    switch (type) {
      case DsStatusModalType.success:
        return AppAssets.successRingIcon;
      case DsStatusModalType.warning:
        return AppAssets.warningIcon;
      case DsStatusModalType.ban:
        return AppAssets.banningIcon;
      case DsStatusModalType.congrats:
        return AppAssets.goodEndingIcon;
    }
  }
}
