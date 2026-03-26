import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum ToastType { info, success, warning, error }

class Toast extends StatelessWidget {
  final ToastType type;
  final String title;
  final String message;
  final VoidCallback? onClose;
  final int durationSeconds;
  final bool autoDismiss;
  final bool showCountdown;

  const Toast({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.onClose,
    this.durationSeconds = 10,
    this.autoDismiss = true,
    this.showCountdown = true,
  });

  /// Convenience helper to show a toast via Overlay at bottom-center
  static void show(
    BuildContext context, {
    required ToastType type,
    required String title,
    required String message,
    int durationSeconds = 10,
    bool showCountdown = true,
  }) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Toast(
                    type: type,
                    title: title,
                    message: message,
                    durationSeconds: durationSeconds,
                    autoDismiss: true,
                    showCountdown: showCountdown,
                    onClose: () {
                      if (entry.mounted) entry.remove();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
  }

  Color _backgroundColor(ToastType type) {
    switch (type) {
      case ToastType.info:
        return AppColors.info;
      case ToastType.success:
        return AppColors.brandSecondary;
      case ToastType.warning:
        return const Color(0xFFFFE59E);
      case ToastType.error:
        return const Color(0xFFFFB3B3);
    }
  }

  Color _iconColor(ToastType type) {
    switch (type) {
      case ToastType.info:
        return AppColors.infoIcon;
      case ToastType.success:
        return AppColors.successText;
      case ToastType.warning:
        return const Color(0xFFB45309);
      case ToastType.error:
        return const Color(0xFFB91C1C);
    }
  }

  String _iconAsset(ToastType type) {
    switch (type) {
      case ToastType.info:
        return 'assets/icons/ui/icon_info.svg';
      case ToastType.success:
        return 'assets/icons/ui/icon_check.svg';
      case ToastType.warning:
        return 'assets/icons/ui/icon_exclamation.svg';
      case ToastType.error:
        return 'assets/icons/ui/icon_exclamation.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      constraints: const BoxConstraints(minHeight: 56),
      decoration: ShapeDecoration(
        color: _backgroundColor(type),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(),
            child: Stack(
              children: [
                Positioned(
                  left: 1,
                  top: 1,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const ShapeDecoration(
                      color: Color(0xFFD9D9D9),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _iconColor(type),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        _iconAsset(type),
                        width: 12,
                        height: 12,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (title.isNotEmpty) const SizedBox(height: 2),
                Text(
                  message,
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    letterSpacing: 0.12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCountdown && autoDismiss)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: durationSeconds.toDouble(), end: 0),
                  duration: Duration(seconds: durationSeconds),
                  onEnd: () {
                    if (autoDismiss && onClose != null) onClose!.call();
                  },
                  builder: (context, value, child) {
                    final remaining = value.ceil();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${remaining}s',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(width: 8),
              if (onClose != null)
                InkWell(
                  onTap: onClose,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Color(0xFF71727A),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
