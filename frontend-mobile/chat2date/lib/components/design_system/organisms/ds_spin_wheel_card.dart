import 'dart:async';
import 'dart:math';

import 'package:chat2date/components/design_system/buttons/index.dart';
import 'package:chat2date/components/design_system/controls/index.dart';
import 'package:chat2date/core/theme/app_assets.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/body_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum DsSpinWheelVariant { pair, single }

class DsSpinWheelItem {
  const DsSpinWheelItem({
    required this.label,
    this.imageProvider,
  });

  final String label;
  final ImageProvider? imageProvider;
}

class DsSpinWheelCard extends StatefulWidget {
  const DsSpinWheelCard({
    super.key,
    required this.items,
    this.title = 'SPIN TO CHOOSE',
    this.userALabel = 'Name A',
    this.userBLabel = 'Name B',
    this.initialVariant = DsSpinWheelVariant.pair,
    this.initialReferenceIndex = 0,
    this.initialDistanceKm = 10,
    this.width = 340,
    this.onClose,
    this.onReset,
    this.onSpinComplete,
    this.onDistanceChanged,
    this.onVariantChanged,
    this.onReferenceChanged,
  });

  final List<DsSpinWheelItem> items;
  final String title;
  final String userALabel;
  final String userBLabel;
  final DsSpinWheelVariant initialVariant;
  final int initialReferenceIndex;
  final double initialDistanceKm;
  final double width;
  final VoidCallback? onClose;
  final VoidCallback? onReset;
  final ValueChanged<DsSpinWheelItem>? onSpinComplete;
  final ValueChanged<double>? onDistanceChanged;
  final ValueChanged<DsSpinWheelVariant>? onVariantChanged;
  final ValueChanged<int>? onReferenceChanged;

  @override
  State<DsSpinWheelCard> createState() => _DsSpinWheelCardState();
}

class _DsSpinWheelCardState extends State<DsSpinWheelCard>
    with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _blinkController;
  late DsSpinWheelVariant _variant;
  late int _referenceIndex;
  late double _distanceKm;
  int _highlightedIndex = 0;
  List<int> _spinSequence = const [];
  // ignore: unused_field, prefer_final_fields
  int _blinkCycles = 0;
  Timer? _autoCloseTimer;

  // Keeps hot-reloaded older controller listeners from crashing while the new
  // highlight-only selection flow is active.
  // ignore: unused_element
  Animation<double>? get _rotationAnimation => null;

  @override
  void initState() {
    super.initState();
    _variant = widget.initialVariant;
    _referenceIndex = widget.initialReferenceIndex.clamp(0, 1);
    _distanceKm = widget.initialDistanceKm.clamp(1, 20);

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..addListener(() {
        if (_spinSequence.isEmpty) {
          return;
        }
        final lastIndex = _spinSequence.length - 1;
        final progress = Curves.easeOutCubic.transform(_spinController.value);
        final sequenceIndex = (progress * lastIndex).round().clamp(0, lastIndex);
        setState(() {
          _highlightedIndex = _spinSequence[sequenceIndex];
        });
      });

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _spinController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  bool get _isSpinning => _spinController.isAnimating;

  double get _blinkStrength {
    if (!_blinkController.isAnimating) {
      return 0;
    }
    return Curves.easeInOut.transform(_blinkController.value);
  }

  void _handleSpin() {
    if (_isSpinning) {
      return;
    }
    final count = max(widget.items.length, 10);
    final targetIndex = Random().nextInt(count);
    final startIndex = _highlightedIndex % count;
    final absoluteTarget = targetIndex >= startIndex
        ? targetIndex
        : targetIndex + count;
    final endIndex = startIndex + (count * 5) + (absoluteTarget - startIndex);
    _spinSequence = List<int>.generate(
      (endIndex - startIndex) + 1,
      (index) => (startIndex + index) % count,
    );
    _autoCloseTimer?.cancel();
    _blinkController.stop();
    _blinkController.value = 0;
    _spinController.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _highlightedIndex = targetIndex;
        _spinSequence = const [];
      });
      _blinkController.repeat(reverse: true);
      _autoCloseTimer = Timer(const Duration(seconds: 5), () {
        if (!mounted) {
          return;
        }
        _blinkController.stop();
        _blinkController.value = 0;
        widget.onClose?.call();
      });
      if (widget.items.isEmpty) {
        return;
      }
      final safeIndex = targetIndex % widget.items.length;
      widget.onSpinComplete?.call(widget.items[safeIndex]);
    });
  }

  void _handleReset() {
    if (_isSpinning) {
      return;
    }
    _autoCloseTimer?.cancel();
    _blinkController.stop();
    _blinkController.value = 0;
    setState(() {
      _distanceKm = widget.initialDistanceKm.clamp(1, 20);
      _highlightedIndex = 0;
    });
    widget.onDistanceChanged?.call(_distanceKm);
    widget.onReset?.call();
  }

  void _handleVariantChanged(DsUserSelectorValue value) {
    if (_isSpinning) {
      return;
    }
    final variant = value == DsUserSelectorValue.group
        ? DsSpinWheelVariant.pair
        : DsSpinWheelVariant.single;
    setState(() {
      _variant = variant;
    });
    widget.onVariantChanged?.call(variant);
  }

  @override
  Widget build(BuildContext context) {
    const wheelSize = 232.0;
    const wheelRadius = 98.0;
    final formattedDistance = _distanceKm.round();

    return Container(
      width: widget.width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SpinWheelHeader(
            title: widget.title,
            onReset: _handleReset,
            onClose: widget.onClose,
          ),
          const SizedBox(height: 20),
          if (_variant == DsSpinWheelVariant.single) ...[
            SizedBox(
              width: 280,
              child: DsSegmentedSwitcher(
                items: [widget.userALabel, widget.userBLabel],
                selectedIndex: _referenceIndex,
                onChanged: (index) {
                  if (_isSpinning) {
                    return;
                  }
                  setState(() {
                    _referenceIndex = index;
                  });
                  widget.onReferenceChanged?.call(index);
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: wheelSize,
            height: wheelSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size.square(wheelSize),
                  painter: _SpinWheelPainter(
                    highlightedIndex:
                        _highlightedIndex % max(widget.items.length, 10),
                    glowStrength: _isSpinning ? 1 : 0.75,
                    blinkStrength: _isSpinning ? 0 : _blinkStrength,
                    radius: wheelRadius,
                    itemCount: max(widget.items.length, 10),
                  ),
                ),
                const _StaticNeedle(),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 309,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ระยะห่างสถานที่สูงสุด',
                  style: AppBodyTextStyles.body.copyWith(
                    fontSize: 18,
                    height: 24 / 18,
                    color: AppColors.textBlack,
                  ),
                ),
                Text(
                  '$formattedDistance Km.',
                  style: AppBodyTextStyles.body.copyWith(
                    fontSize: 18,
                    height: 24 / 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          DsSlider(
            value: _distanceKm,
            min: 1,
            max: 20,
            width: 309,
            onChanged: (value) {
              if (_isSpinning) {
                return;
              }
              setState(() {
                _distanceKm = value;
              });
              widget.onDistanceChanged?.call(value);
            },
          ),
          const SizedBox(height: 14),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'หมายเหตุ',
                textAlign: TextAlign.center,
                style: AppBodyTextStyles.bodyBold.copyWith(
                  fontSize: 16,
                  height: 22 / 16,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _variant == DsSpinWheelVariant.pair
                    ? 'ระบบจะคำนวณหาจุดกึ่งกลางระหว่างผู้ใช้งานทั้งสองคน แล้วใช้ระยะทางที่กำหนดเป็นรัศมีเพื่อค้นหาสถานที่ใกล้เคียง'
                    : 'ระบบจะคำนวณจากตำแหน่งของคนที่เลือก แล้วใช้ระยะทางที่กำหนดเป็นรัศมีเพื่อค้นหาสถานที่ใกล้เคียง',
                textAlign: TextAlign.center,
                style: AppBodyTextStyles.body.copyWith(
                  color: AppColors.textSupport,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          DsUserSelector(
            value: _variant == DsSpinWheelVariant.pair
                ? DsUserSelectorValue.group
                : DsUserSelectorValue.single,
            onChanged: _handleVariantChanged,
            width: 160,
          ),
          const SizedBox(height: 18),
          DsButton(
            label: 'สุ่มสถานที่เดต',
            onPressed: _handleSpin,
            variant: DsButtonVariant.primary,
            width: 300,
          ),
        ],
      ),
    );
  }
}

class _SpinWheelHeader extends StatelessWidget {
  const _SpinWheelHeader({
    required this.title,
    this.onReset,
    this.onClose,
  });

  final String title;
  final VoidCallback? onReset;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SpinWheelHeaderButton(
          assetPath: 'assets/icons/ui/icon_refresh.svg',
          onTap: onReset,
          tintColor: AppColors.brandSecondary,
        ),
        Expanded(
          child: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppBodyTextStyles.bodyBold.copyWith(
                  fontSize: 18,
                  height: 24 / 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        _SpinWheelHeaderButton(
          assetPath: AppAssets.closeIcon,
          onTap: onClose,
          tintColor: AppColors.error,
        ),
      ],
    );
  }
}

class _SpinWheelHeaderButton extends StatefulWidget {
  const _SpinWheelHeaderButton({
    required this.assetPath,
    this.onTap,
    this.tintColor,
  });

  final String assetPath;
  final VoidCallback? onTap;
  final Color? tintColor;

  @override
  State<_SpinWheelHeaderButton> createState() => _SpinWheelHeaderButtonState();
}

class _SpinWheelHeaderButtonState extends State<_SpinWheelHeaderButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        offset: _pressed ? const Offset(0, -0.06) : Offset.zero,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: SvgPicture.asset(
              widget.assetPath,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              colorFilter: widget.tintColor == null
                  ? null
                  : ColorFilter.mode(widget.tintColor!, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

class _StaticNeedle extends StatelessWidget {
  const _StaticNeedle();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -8),
          child: SvgPicture.asset(
            AppAssets.spinWheelArrowIllustration,
            width: 52,
            height: 52,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _SpinWheelPainter extends CustomPainter {
  const _SpinWheelPainter({
    required this.itemCount,
    required this.highlightedIndex,
    required this.glowStrength,
    required this.blinkStrength,
    required this.radius,
  });

  final int itemCount;
  final int highlightedIndex;
  final double glowStrength;
  final double blinkStrength;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (itemCount <= 0) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final sweep = (2 * pi) / itemCount;

    canvas.drawCircle(
      center,
      radius + 10,
      Paint()..color = AppColors.surface,
    );

    for (var i = 0; i < itemCount; i++) {
      final segmentRotation = i * sweep;
      final startAngle = (-pi / 2) - (sweep / 2);
      final isHighlighted = i == highlightedIndex;

      final segment = Path()
        ..moveTo(0, 0)
        ..lineTo(
          cos(startAngle) * radius,
          sin(startAngle) * radius,
        )
        ..arcTo(
          Rect.fromCircle(center: Offset.zero, radius: radius),
          startAngle,
          sweep,
          false,
        )
        ..close();

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(segmentRotation);
      canvas.drawPath(
        segment,
        Paint()
          ..color = i.isEven ? AppColors.brandSecondary : AppColors.brandPrimary,
      );
      if (isHighlighted) {
        canvas.drawPath(
          segment,
          Paint()
            ..color = AppColors.background.withValues(alpha: 0.22 * glowStrength)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
        );
        canvas.drawPath(
          segment,
          Paint()
            ..color = AppColors.background
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.2,
        );
        canvas.drawPath(
          segment,
          Paint()
            ..color = AppColors.brandSecondary.withValues(alpha: 0.95 * glowStrength)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
        );
        if (blinkStrength > 0) {
          canvas.drawPath(
            segment,
            Paint()
              ..color = AppColors.brandSecondary.withValues(
                alpha: 0.95 * blinkStrength,
              )
              ..style = PaintingStyle.stroke
              ..strokeWidth = 16
              ..maskFilter = MaskFilter.blur(
                BlurStyle.normal,
                24,
              ),
          );
        }
      }
      canvas.restore();
    }

    canvas.drawCircle(
      center,
      radius + 10,
      Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
  }

  @override
  bool shouldRepaint(covariant _SpinWheelPainter oldDelegate) {
    return oldDelegate.highlightedIndex != highlightedIndex ||
        oldDelegate.itemCount != itemCount ||
        oldDelegate.glowStrength != glowStrength ||
        oldDelegate.blinkStrength != blinkStrength;
  }
}
