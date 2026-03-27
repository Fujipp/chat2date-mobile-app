import 'dart:async';

import 'package:chat2date/theme/app_assets.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:chat2date/theme/tokens/typography/body_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ToastType { info, success, warning, error }

typedef DsToast = Toast;
typedef DsToastType = ToastType;

class Toast extends StatelessWidget {
  const Toast({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.onClose,
    this.durationSeconds = 10,
    this.autoDismiss = true,
    this.showCountdown = false,
  });

  final ToastType type;
  final String title;
  final String message;
  final VoidCallback? onClose;
  final int durationSeconds;
  final bool autoDismiss;
  final bool showCountdown;

  static void show(
    BuildContext context, {
    required ToastType type,
    required String title,
    required String message,
    int durationSeconds = 10,
    bool showCountdown = false,
    bool autoDismiss = true,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late final OverlayEntry entry;
    Timer? dismissTimer;

    void removeEntry() {
      dismissTimer?.cancel();
      if (entry.mounted) {
        entry.remove();
      }
    }

    entry = OverlayEntry(
      builder: (_) => SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 342),
                child: Toast(
                  type: type,
                  title: title,
                  message: message,
                  durationSeconds: durationSeconds,
                  autoDismiss: autoDismiss,
                  showCountdown: showCountdown,
                  onClose: removeEntry,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    if (autoDismiss) {
      dismissTimer = Timer(Duration(seconds: durationSeconds), removeEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTitle = title.trim().isNotEmpty;
    final hasMessage = message.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ToastStatusIcon(type: type),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTitle)
                  Text(
                    title,
                    style: AppBodyTextStyles.captionBold.copyWith(
                      color: AppColors.textOnDark,
                    ),
                  ),
                if (hasTitle && hasMessage) const SizedBox(height: 4),
                if (hasMessage)
                  Text(
                    message,
                    style: AppBodyTextStyles.overline.copyWith(
                      color: AppColors.textOnDark,
                    ),
                  ),
              ],
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 16),
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 12,
                height: 12,
                child: SvgPicture.asset(
                  AppAssets.v4ToastCloseIcon,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textOnDark,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToastStatusIcon extends StatelessWidget {
  const _ToastStatusIcon({required this.type});

  final ToastType type;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(_badgeAsset, width: 22, height: 22),
            SvgPicture.asset(
              _glyphAsset,
              width: _glyphWidth,
              height: _glyphHeight,
            ),
          ],
        ),
      ),
    );
  }

  String get _badgeAsset {
    switch (type) {
      case ToastType.info:
        return AppAssets.v4ToastInfoBadge;
      case ToastType.success:
        return AppAssets.v4ToastSuccessBadge;
      case ToastType.warning:
        return AppAssets.v4ToastWarningBadge;
      case ToastType.error:
        return AppAssets.v4ToastErrorBadge;
    }
  }

  String get _glyphAsset {
    switch (type) {
      case ToastType.info:
        return AppAssets.v4ToastInfoGlyph;
      case ToastType.success:
        return AppAssets.v4ToastSuccessGlyph;
      case ToastType.warning:
      case ToastType.error:
        return AppAssets.v4ToastWarningErrorGlyph;
    }
  }

  double get _glyphWidth {
    switch (type) {
      case ToastType.info:
        return 6.41;
      case ToastType.success:
        return 10.15;
      case ToastType.warning:
      case ToastType.error:
        return 2.74;
    }
  }

  double get _glyphHeight {
    switch (type) {
      case ToastType.info:
        return 10.94;
      case ToastType.success:
        return 7.9;
      case ToastType.warning:
      case ToastType.error:
        return 12.11;
    }
  }
}
