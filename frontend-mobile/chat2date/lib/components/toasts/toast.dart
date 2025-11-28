import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum ToastType { info, success, warning, error }

class Toast extends StatelessWidget {
  final ToastType type;
  final String title;
  final String message;
  final VoidCallback? onClose;

  const Toast({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.onClose,
  });

  Color _backgroundColor(ToastType type) {
    switch (type) {
      case ToastType.info:
        return const Color(0xFF78CEFF);
      case ToastType.success:
        return const Color(0xFFC5F6D6);
      case ToastType.warning:
        return const Color(0xFFFFE59E);
      case ToastType.error:
        return const Color(0xFFFFB3B3);
    }
  }

  Color _iconColor(ToastType type) {
    switch (type) {
      case ToastType.info:
        return const Color(0xFF075985);
      case ToastType.success:
        return const Color(0xFF15803D);
      case ToastType.warning:
        return const Color(0xFFB45309);
      case ToastType.error:
        return const Color(0xFFB91C1C);
    }
  }

  String _iconAsset(ToastType type) {
    switch (type) {
      case ToastType.info:
        return 'assets/icons/icon_info.svg';
      case ToastType.success:
        return 'assets/icons/icon_check.svg';
      case ToastType.warning:
        return 'assets/icons/icon_exclamation.svg';
      case ToastType.error:
        return 'assets/icons/icon_exclamation.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: _backgroundColor(type),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 4),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
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
          const SizedBox(width: 16),

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
    );
  }
}
