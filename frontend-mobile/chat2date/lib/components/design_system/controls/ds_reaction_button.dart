import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum DsReactionButtonType { match, pass }

enum DsReactionButtonState { base, active }

class DsReactionButton extends StatefulWidget {
  const DsReactionButton({
    super.key,
    required this.type,
    this.state = DsReactionButtonState.base,
    this.onTap,
    this.size = 60,
  });

  final DsReactionButtonType type;
  final DsReactionButtonState state;
  final VoidCallback? onTap;
  final double size;

  @override
  State<DsReactionButton> createState() => _DsReactionButtonState();
}

class _DsReactionButtonState extends State<DsReactionButton> {
  bool _pressed = false;

  bool get _isActive =>
      widget.state == DsReactionButtonState.active || _pressed;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _isActive;
    final backgroundColor = switch ((widget.type, isActive)) {
      (DsReactionButtonType.match, false) => AppColors.background,
      (DsReactionButtonType.match, true) => AppColors.brandPrimary,
      (DsReactionButtonType.pass, false) => AppColors.background,
      (DsReactionButtonType.pass, true) => AppColors.error,
    };
    final iconColor = switch ((widget.type, isActive)) {
      (DsReactionButtonType.match, false) => AppColors.brandPrimary,
      (DsReactionButtonType.match, true) => AppColors.background,
      (DsReactionButtonType.pass, false) => AppColors.error,
      (DsReactionButtonType.pass, true) => AppColors.background,
    };
    final glowColor = switch (widget.type) {
      DsReactionButtonType.match => AppColors.brandPrimary,
      DsReactionButtonType.pass => AppColors.error,
    };

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 220),
              tween: Tween<double>(begin: 0, end: isActive ? 1 : 0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.55),
                  child: Opacity(
                    opacity: value * 0.72,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            glowColor.withValues(alpha: 0.95),
                            glowColor.withValues(alpha: 0.55),
                            glowColor.withValues(alpha: 0),
                          ],
                          stops: const [0.15, 0.55, 1],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedScale(
              scale: isActive ? 1.0 : 0.96,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (!isActive)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    if (isActive)
                      BoxShadow(
                        color: glowColor.withValues(alpha: 0.55),
                        blurRadius: 22,
                        spreadRadius: 3,
                        offset: const Offset(0, 0),
                      ),
                    if (isActive)
                      BoxShadow(
                        color: glowColor.withValues(alpha: 0.3),
                        blurRadius: 38,
                        spreadRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Center(
                  child: AnimatedScale(
                    scale: isActive ? 1.02 : 1,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    child: _ReactionGlyph(
                      type: widget.type,
                      color: iconColor,
                      size: widget.type == DsReactionButtonType.match ? 31 : 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionGlyph extends StatelessWidget {
  const _ReactionGlyph({
    required this.type,
    required this.color,
    required this.size,
  });

  final DsReactionButtonType type;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case DsReactionButtonType.match:
        return Icon(
          Icons.favorite_rounded,
          size: size,
          color: color,
        );
      case DsReactionButtonType.pass:
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _PassGlyphPainter(color: color),
          ),
        );
    }
  }
}

class _PassGlyphPainter extends CustomPainter {
  const _PassGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.26
      ..strokeCap = StrokeCap.round;

    final inset = size.width * 0.18;
    canvas.drawLine(
      Offset(inset, inset),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PassGlyphPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
