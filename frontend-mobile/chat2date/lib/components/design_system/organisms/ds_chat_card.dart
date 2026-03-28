import 'package:chat2date/theme/app_colors.dart';
import 'package:chat2date/theme/tokens/colors/app_gradients.dart';
import 'package:chat2date/theme/tokens/typography/body_text_styles.dart';
import 'package:flutter/material.dart';

enum DsChatCardVariant { basic, highlighted }

class DsChatCard extends StatelessWidget {
  const DsChatCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.variant = DsChatCardVariant.basic,
    this.avatarImage,
    this.avatar,
    this.unreadCount,
    this.onTap,
    this.width = 370,
  });

  final String title;
  final String subtitle;
  final DsChatCardVariant variant;
  final ImageProvider? avatarImage;
  final Widget? avatar;
  final int? unreadCount;
  final VoidCallback? onTap;
  final double width;

  bool get _isHighlighted => variant == DsChatCardVariant.highlighted;
  bool get _showBadge => _isHighlighted && unreadCount != null && unreadCount! > 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 82,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isHighlighted ? null : AppColors.background,
          gradient: _isHighlighted ? AppGradients.themeApp2 : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppBodyTextStyles.bodyBold.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppBodyTextStyles.caption.copyWith(
                      color: _isHighlighted
                          ? AppColors.textOnDark
                          : AppColors.textSupport,
                      letterSpacing: 0.12,
                      fontWeight:
                          _isHighlighted ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (_showBadge) ...[
              const SizedBox(width: 16),
              _UnreadBadge(count: unreadCount!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (avatar != null) {
      return SizedBox(
        width: 50,
        height: 50,
        child: ClipOval(child: avatar!),
      );
    }

    if (avatarImage != null) {
      return ClipOval(
        child: Image(
          image: avatarImage!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
      ),
      child: const Icon(
        Icons.person,
        color: AppColors.background,
        size: 28,
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 9 ? '9+' : '$count';
    return SizedBox(
      width: 33,
      height: 33,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(minWidth: 23, minHeight: 24),
          padding: const EdgeInsets.symmetric(horizontal: 3),
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppBodyTextStyles.bodyBold.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.deniedActive,
              letterSpacing: 0.14,
            ),
          ),
        ),
      ),
    );
  }
}
