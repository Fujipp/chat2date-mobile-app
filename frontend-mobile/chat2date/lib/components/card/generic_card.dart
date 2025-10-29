import 'package:flutter/material.dart';

enum CardIconType { image, avatar, icon, none }

enum CardActionType { button, chevron, none }

class GenericCard extends StatelessWidget {
  final CardIconType iconType;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackground;
  final String? imageUrl;

  final String title;
  final String? subtitle;

  final CardActionType actionType;
  final String? buttonText;
  final VoidCallback? onTap;
  final VoidCallback? onButtonTap;

  final Color? backgroundColor;
  final EdgeInsets? padding;

  const GenericCard({
    Key? key,
    this.iconType = CardIconType.none,
    this.icon,
    this.iconColor,
    this.iconBackground,
    this.imageUrl,
    required this.title,
    this.subtitle,
    this.actionType = CardActionType.none,
    this.buttonText,
    this.onTap,
    this.onButtonTap,
    this.backgroundColor,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Color(0xFFf8f9fe),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: iconType == CardIconType.image
                ? const EdgeInsets.only(right: 16) // ซ้าย 0 แต่เว้นขวา
                : padding ??
                      const EdgeInsets.all(
                        16,
                      ), // อื่น ๆ ใช้ padding ที่ส่งเข้ามาหรือ default
            child: Row(
              children: [
                // Left Icon/Avatar
                if (iconType != CardIconType.none) ...[
                  _buildLeadingIcon(),
                  const SizedBox(width: 16),
                ],

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Right Action (Button or Chevron)
                if (actionType != CardActionType.none) ...[
                  const SizedBox(width: 16),
                  _buildTrailingAction(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    switch (iconType) {
      case CardIconType.image:
        return Container(
          width: 80,
          height: 72,
          decoration: BoxDecoration(
            color: iconBackground ?? Color(0xFFeaf2ff),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              topRight: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
          ),
          child: imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.image, color: iconColor ?? Colors.blue[300]),
                  ),
                )
              : Icon(
                  Icons.image,
                  color: iconColor ?? Colors.blue[300],
                  size: 24,
                ),
        );

      case CardIconType.avatar:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBackground ?? Colors.blue[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      color: iconColor ?? Colors.blue[700],
                    ),
                  )
                : Icon(
                    icon ?? Icons.person,
                    color: iconColor ?? Colors.blue[700],
                    size: 25,
                  ),
          ),
        );

      case CardIconType.icon:
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBackground ?? Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon ?? Icons.favorite,
            color: iconColor ?? Color(0xFF006ffd),
            size: 28,
          ),
        );

      case CardIconType.none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTrailingAction() {
    switch (actionType) {
      case CardActionType.button:
        return OutlinedButton(
          onPressed: onButtonTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          child: Text(buttonText ?? 'Button'),
        );

      case CardActionType.chevron:
        return Icon(Icons.chevron_right, color: Colors.grey[400], size: 24);

      case CardActionType.none:
        return const SizedBox.shrink();
    }
  }
}
